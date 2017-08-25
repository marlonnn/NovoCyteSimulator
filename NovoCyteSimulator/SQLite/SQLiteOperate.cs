using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SQLite;
using System.Data.SqlClient;
using System.Data.Common;
using System.Data.OleDb;

namespace NovoCyteSimulator.SQLite
{
    ///
    /// SQLiteHelper类
    ///
    public class SQLiteOperate : DBOperate
    {

        public SQLiteOperate(string pathName)
        {
            PathName = pathName;
            ReadOnly = false;
        }

        // 创建适配器
        public override DbDataAdapter CreateDataAdapter(string sql)
        {
            return new SQLiteDataAdapter(sql, (SQLiteConnection)conn);
        }

        public override bool Connect(bool exclusive)
        {
            if (string.IsNullOrEmpty(PathName))
            {
                return false;
            }

            if (this.conn != null)  // make sure old connection object is closed and disposed
            {
                Close(true);
            }

            SQLiteConnectionStringBuilder connsb = new SQLiteConnectionStringBuilder();
            connsb.DataSource = PathName;
            connsb.Password = "";
            connsb.ReadOnly = ReadOnly;

            // if not readonly, delete journal file
            if (!ReadOnly)
            {
                try
                {
                    System.IO.File.Delete(PathName + "-journal");
                }
                catch (System.Exception)
                {
                	
                }
            }

            this.conn = new SQLiteConnection(connsb.ToString(), true);

            if (this.Open())
            {
                if (TryExecuteNonQuery("PRAGMA synchronous = off;", null) != -1)
                {  // set synchronous off
                    return true;
                }
            }
            return false;
        }

        public override IDbDataParameter CreateDbDataParameter(string paraName, OleDbType dataType)
        {
            switch (dataType)
            {
                case OleDbType.Date:
                    return new SQLiteParameter(paraName, DbType.DateTime);
                case OleDbType.DBTimeStamp:
                    return new SQLiteParameter(paraName, DbType.DateTime);
                case OleDbType.VarBinary:
                    return new SQLiteParameter(paraName, DbType.Binary);
                case OleDbType.Binary:
                    return new SQLiteParameter(paraName, DbType.Binary);
                case OleDbType.Boolean:
                    return new SQLiteParameter(paraName, DbType.Boolean);//Sqlite没有单独的布尔存储类型，它使用INTEGER作为存储类型，0为false，1为true
                case OleDbType.Integer:
                    return new SQLiteParameter(paraName, DbType.Int32);
                case OleDbType.VarChar:
                    return new SQLiteParameter(paraName, DbType.String);
                case OleDbType.TinyInt:
                    return new SQLiteParameter(paraName, DbType.Int16);
                case OleDbType.BSTR:
                    return new SQLiteParameter(paraName, DbType.String);
                default:
                    return new SQLiteParameter(paraName, DbType.String);
            }
        }

        public override IDbDataParameter CreateDbDataParameter(string paraName, OleDbType dataType, int size)
        {
            if (dataType == OleDbType.VarChar)
                return new SQLiteParameter(paraName, DbType.String, size);
            else
                return CreateDbDataParameter(paraName, dataType);
        }

        public override void TryExecuteCompressSQLite(string PathName)
        {
            SQLiteConnectionStringBuilder connsb = new SQLiteConnectionStringBuilder();
            connsb.DataSource = PathName;
            using (SQLiteConnection connection = new SQLiteConnection(connsb.ToString()))
            {
                using (SQLiteCommand cmd = new SQLiteCommand("VACUUM", connection))
                {
                    try
                    {
                        connection.Open();
                        cmd.ExecuteNonQuery();
                    }
                    catch (System.Data.SQLite.SQLiteException E)
                    {

                    }
                    finally
                    {
                        cmd.Dispose();
                        connection.Close();
                    }
                }
            }
        }

    }
}