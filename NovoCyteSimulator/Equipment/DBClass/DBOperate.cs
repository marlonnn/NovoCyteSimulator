using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Common;
using System.Data.OleDb;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovoCyteSimulator.DBClass
{
    public abstract class DBOperate : IDisposable
    {
        /// <summary>

        /// 数据库连接对象。

        /// </summary>

        /// <author>天志</author>

        /// <log date="2007-04-05">创建</log>
        protected DbConnection conn;
        /// <summary>

        /// 事务处理对象。

        /// </summary>

        /// <author>天志</author>

        /// <log date="2007-04-05">创建</log>
        private DbTransaction _trans;

        public void Dispose()
        {
            if (_trans != null)
            {
                _trans.Dispose();
                _trans = null;
            }

            if (conn != null)
            {
                conn.Dispose();
                conn = null;
            }
        }

        /// <summary>

        /// 指示当前操作是否在事务中。

        /// </summary>

        /// <author>天志</author>

        /// <log date="2007-04-05">创建</log>
        private bool bInTrans = false;

        public bool InTransaction
        {
            get { return bInTrans; }
        }

        #region 打开关闭数据库连接
        /// <summary>

        /// 打开数据库连接

        /// </summary>

        /// <author>天志</author>

        /// <log date="2007-04-05">创建</log>
        public bool Open()
        {
            if (conn != null && conn.State.Equals(ConnectionState.Closed))
            {
                try
                {
                    conn.Open();
                }
                catch (System.Exception)
                {

                }
            }
            return IsOpen;
        }

        /// <summary>
        /// Is the database connection is open
        /// </summary>
        public bool IsOpen
        {
            get { return conn != null && conn.State.Equals(ConnectionState.Open); }
        }

        /// <summary>

        /// 关闭数据库连接

        /// </summary>

        /// <author>天志</author>

        /// <log date="2007-04-05">创建</log>
        public void Close(bool dispose)
        {
            if (conn != null && conn.State.Equals(ConnectionState.Open))
            {
                CommitTran();   // commit transaction before close connection
                conn.Close();
            }

            if (dispose) Dispose();
        }
        #endregion

        #region 事务支持
        /// <summary>
        /// 开始一个事务
        /// </summary>
        /// <author>天志</author>
        /// <log date="2007-04-05">创建</log>
        public void BeginTran()
        {
            try
            {
                if (!this.bInTrans)
                {
                    this.Open();
                    bInTrans = true;
                    _trans = conn.BeginTransaction();
                }
            }
            catch
            {

            }
        }

        public DbTransaction BeginTran(bool newTrans)
        {
            try
            {
                this.Open();
                return conn.BeginTransaction();
            }
            catch
            {

            }
            return null;
        }

        /// <summary>

        /// 提交一个事务

        /// </summary>

        /// <author>天志</author>

        /// <log date="2007-04-05">创建</log>
        public void CommitTran()
        {
            try
            {
                if (this.bInTrans)
                {
                    bInTrans = false;
                    _trans.Commit();
                    //this.Close();
                }
            }
            catch (System.Exception)
            {

            }
        }

        public void CommitTran(DbTransaction transaction)
        {
            try
            {
                if (transaction != null)
                {
                    transaction.Commit();
                }
            }
            catch (System.Exception)
            {

            }
        }

        /// <summary>

        /// 回滚一个事务

        /// </summary>

        /// <author>天志</author>

        /// <log date="2007-04-05">创建</log>
        public void RollBackTran()
        {
            try
            {
                if (this.bInTrans)
                {
                    _trans.Rollback();
                    bInTrans = false;
                    //this.Close();
                }
            }
            catch (System.Exception)
            {

            }
        }
        #endregion

        #region 生成命令对象
        /// <summary>
        /// 获取一个DbCommand对象
        /// </summary>
        /// <param name="strSql">sql语句名称</param>
        /// <param name="parameters">参数数组</param>
        /// <param name="strCommandType">命令类型</param>
        /// <returns>OdbcCommand对象</returns>

        private DbCommand GetPreCommand(string sql, IDataParameter[] parameters, DbTransaction trans)
        {
            // 初始化一个command对象
            DbCommand cmdSql = conn.CreateCommand();
            cmdSql.CommandText = sql;
            cmdSql.CommandType = this.GetCommandType(sql);
            // 判断是否在事务中
            if (this.bInTrans) { cmdSql.Transaction = trans; }
            if (parameters != null)
            {
                //指定各个参数的取值
                foreach (IDataParameter sqlParm in parameters)
                {
                    cmdSql.Parameters.Add(sqlParm);
                }
            }
            return cmdSql;
        }

        private DbCommand GetPreCommand(string sql, IDataParameter[] parameters)
        {
            return GetPreCommand(sql, parameters, _trans);
        }

        /// <summary>

        /// 取得SQL语句的命令类型。

        /// </summary>

        /// <param name="sql">SQL语句</param>

        /// <returns>命令类型</returns>

        /// <author>天志</author>

        /// <log date="2007-04-05">创建</log>

        private CommandType GetCommandType(string sql)
        {
            //记录SQL语句的开始字符
            string topText = "";
            if (sql.Length > 7)
            {
                //取出字符串的前位
                topText = sql.Substring(0, 7).ToUpper();
                // 如果不是存储过程
                if (topText.Equals("UPDATE ") || topText.Equals("INSERT ") ||

                    topText.Equals("DELETE ") || topText.Equals("ALTER T") ||

                    topText.Equals("ALTER ") || topText.Equals("BACKUP ") ||

                    topText.Equals("RESTORE") || topText.Equals("SELECT ") ||

                    topText.Equals("CREATE ") || topText.Equals("ALTER D") ||

                    topText.Equals("PRAGMA "))
                {
                    return CommandType.Text;
                }

            }
            return CommandType.StoredProcedure;
        }

        #endregion

        #region 执行无返回值SQL语句

        /// <summary>
        /// 执行添加，修改，删除之类的操作。
        /// </summary>
        /// <param name="strSql">sql语句名称</param>
        /// <param name="parameters">参数数组</param>
        /// <returns>受影响的条数</returns>
        public int ExecuteNonQuery(string sql, IDataParameter[] parameters, DbTransaction trans)
        {
            DbCommand cmdSql = this.GetPreCommand(sql, parameters, trans);
            try
            {
                // 打开数据库连接
                this.Open();
                return cmdSql.ExecuteNonQuery();
            }
            catch (Exception ex)
            {
                return -1;
            }

            finally
            {
                cmdSql.Parameters.Clear();
                cmdSql.Dispose();
            }
        }

        public int ExecuteNonQuery(string sql, IDataParameter[] parameters)
        {
            return ExecuteNonQuery(sql, parameters, _trans);
        }

        /// <summary>
        /// try ExecuteNonQuery ignore errors, does not throw exception
        /// </summary>
        public int TryExecuteNonQuery(string sql, IDataParameter[] parameters, DbTransaction trans)
        {
            try
            {
                return ExecuteNonQuery(sql, parameters, trans);
            }
            catch (Exception)
            {

            }
            return 0;
        }

        public int TryExecuteNonQuery(string sql, IDataParameter[] parameters)
        {
            return TryExecuteNonQuery(sql, parameters, _trans);
        }

        #endregion

        #region 返回单个值

        /// <summary>
        /// 返回结果集中第一行的第一列。
        /// </summary>
        /// <param name="sql">sql语句名称</param>
        /// <param name="parameters">参数数组</param>
        /// <returns>返回对象</returns>
        /// <author>天志</author>
        /// <log date="2007-04-05">创建</log>

        public object ExecuteScalar(string sql, IDataParameter[] parameters)
        {
            //初始化一个command对象
            DbCommand cmdSql = this.GetPreCommand(sql, parameters);
            try
            {
                // 打开数据库连接
                this.Open();
                return cmdSql.ExecuteScalar();
            }

            finally
            {
                cmdSql.Parameters.Clear();
                cmdSql.Dispose();
            }

        }

        /// <summary>
        /// try ExecuteScalar ignore errors, does not throw exception
        /// </summary>
        public object TryExecuteScalar(string sql, IDataParameter[] parameters)
        {
            try
            {
                return ExecuteScalar(sql, parameters);
            }
            catch (Exception)
            {

            }
            return null;
        }

        #endregion

        /// <summary>
        /// 返回DataReader。
        /// </summary>
        /// <param name="sql">sql语句名称</param>
        /// <param name="parameters">参数数组</param>
        /// <returns>DataReader对象</returns>
        /// <author>天志</author>
        /// <log date="2007-04-05">创建</log>

        public IDataReader ExecuteReader(string sql, IDataParameter[] parameters)
        {
            //初始化一个command对象
            DbCommand cmdSql = this.GetPreCommand(sql, parameters);
            try
            {
                // 打开数据库连接
                this.Open();
                //返回DataReader对象
                return cmdSql.ExecuteReader(/*CommandBehavior.CloseConnection*/);
            }
            finally
            {
                cmdSql.Parameters.Clear();
                cmdSql.Dispose();
            }

        }

        /// <summary>
        /// try ExecuteReader ignore errors, does not throw exception
        /// </summary>
        public IDataReader TryExecuteReader(string sql, IDataParameter[] parameters)
        {
            try
            {
                return ExecuteReader(sql, parameters);
            }
            catch (Exception)
            {

            }
            return null;
        }

        #region 返回DataTable

        /// <summary>
        /// 返回DataTable。
        /// </summary>
        /// <param name="sql">sql语句名称</param>
        /// <param name="parameters">参数数组</param>
        /// <returns>DataTable对象</returns>
        /// <author>天志</author>
        /// <log date="2007-04-05">创建</log>
        public DataTable ExecuteDataTable(string sql, IDataParameter[] parameters)
        {
            //初始化一个DataAdapter对象，一个DataTable对象
            DataTable dt = new DataTable();
            DbDataAdapter da = this.CreateDataAdapter(sql);
            //初始化一个command对象
            DbCommand cmdSql = this.GetPreCommand(sql, parameters);

            try
            {
                //返回DataTable对象
                da.SelectCommand = cmdSql;
                // 打开数据库连接
                this.Open();
                da.Fill(dt);
                return dt;
            }
            catch { return dt; }
            finally
            {
                //判断是否在事务中
                //                 if (!this.bInTrans)
                //                 {
                //                     this.Close();
                //                 }
                cmdSql.Parameters.Clear();
                cmdSql.Dispose();
                da.Dispose();
                dt.Dispose();
            }

        }

        /// <summary>
        /// try ExecuteDataTable ignore errors, does not throw exception
        /// </summary>
        /// <param name="sql"></param>
        /// <param name="parameters"></param>
        /// <returns></returns>
        public DataTable TryExecuteDataTable(string sql, IDataParameter[] parameters)
        {
            try
            {
                return ExecuteDataTable(sql, parameters);
            }
            catch (Exception)
            {

            }
            return null;
        }

        #endregion

        #region 返回DataSet
        /// <summary>
        /// 返回DataSet对象。
        /// </summary>
        /// <param name="sql">sql语句名称</param>
        /// <param name="parameters">参数数组</param>
        /// <param name="strTableName">操作表的名称</param>
        /// <returns>DataSet对象</returns>
        /// <author>天志</author>
        /// <log date="2007-04-05">创建</log>

        public DataSet ExecuteDataSet(string sql, IDataParameter[] parameters, string tableName)
        {
            //初始化一个DataSet对象，一个DataAdapter对象
            DataSet ds = new DataSet();
            DbDataAdapter da = this.CreateDataAdapter(sql);
            //初始化一个command对象
            DbCommand cmdSql = this.GetPreCommand(sql, parameters);
            try
            {
                // 返回DataSet对象
                da.SelectCommand = cmdSql;
                // 打开数据库连接
                this.Open();
                da.Fill(ds, tableName);
                return ds;
            }

            finally
            {
                //判断是否在事务中
                //                 if (!this.bInTrans)
                //                 {
                //                     this.Close();
                //                 }
                cmdSql.Parameters.Clear();
                cmdSql.Dispose();
                da.Dispose();
                ds.Dispose();
            }
        }

        /// <summary>
        /// try ExecuteDataSet ignore errors, does not throw exception
        /// </summary>
        public DataSet TryExecuteDataSet(string sql, IDataParameter[] parameters, string tableName)
        {
            try
            {
                return ExecuteDataSet(sql, parameters, tableName);
            }
            catch (Exception)
            {

            }
            return null;
        }
        #endregion

        /// <summary>
        /// 创建适配器
        /// </summary>
        /// <param name="sql"></param>
        /// <returns></returns>
        public abstract DbDataAdapter CreateDataAdapter(string sql);

        public static DBOperate CreateDBOperator(string filePath)
        {
            System.IO.FileStream fs = new System.IO.FileStream(filePath, FileMode.Open, FileAccess.Read, FileShare.ReadWrite);
            BinaryReader br = new BinaryReader(fs);
            string bx = " ";
            byte buffer;
            try
            {
                buffer = br.ReadByte();
                bx = buffer.ToString();
                buffer = br.ReadByte();
                bx += buffer.ToString();
            }
            catch (EndOfStreamException e)
            {
            }
            fs.Close();
            br.Close();

            if (bx == "01")
                return new OleDBOperate(filePath);
            else
                return new SQLiteOperate(filePath);
        }

        public bool IsOleDb
        {
            get { return this is OleDBOperate; }
        }

        public string PathName;

        public string Password;

        private bool _readOnly;
        public bool ReadOnly
        {
            get { return _readOnly; }
            set { _readOnly = value; }
        }

        /// <summary>
        /// connect to database, will call Open() and close first if already open
        /// </summary>
        /// <param name="exclusive"></param>
        /// <returns></returns>
        public abstract bool Connect(bool exclusive);

        public abstract IDbDataParameter CreateDbDataParameter(string paraName, OleDbType dataType, int size);

        public abstract IDbDataParameter CreateDbDataParameter(string paraName, OleDbType dataType);

        public abstract void TryExecuteCompressSQLite(string pathName);

        /// <summary>
        /// quote for date time in sql where
        /// </summary>
        public virtual char Quote
        {
            get { return '\''; }
        }

        public static readonly string DateTimeFormater = "yyyy-MM-dd HH:mm:ss";
    }
}
