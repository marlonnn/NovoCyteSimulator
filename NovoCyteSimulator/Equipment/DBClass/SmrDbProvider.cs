using Spring.Data.Common;
using Summer.System.Log;
using Summer.System.Security;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovoCyteSimulator.DBClass
{
    /// <summary>
    /// Summer数据库
    /// </summary>
    /// <remarks>
    /// 公司：CASCO
    /// 作者：张立鹏                 
    /// 创建日期：2015-5-4   
    /// </remarks>
    public class SmrDbProvider : IDbProvider
    {
        IDbProvider dbProvider;

        public static string DESKey = "UYZFLJ2T";

        /// <summary>
        /// 构造一个数据库提供者，此类和spring既有类的区别是使用了加密的连接字符串（DES算法）
        /// </summary>
        /// <param name="provider"></param>
        /// <param name="connectionString">加密过的连接字符串</param>
        public SmrDbProvider(string provider, string connectionString)
            : this(provider, connectionString, DESKey)
        {
        }

        /// <summary>
        /// 构造一个数据库提供者，此类和spring既有类的区别是使用了加密的连接字符串（DES算法）
        /// </summary>
        /// <param name="provider"></param>
        /// <param name="connectionString">加密过的连接字符串</param>
        /// <param name="DESkey">连接字符串解密key</param>
        public SmrDbProvider(string provider, string connectionString, string DESkey)
        {
            try
            {
                dbProvider = DbProviderFactory.GetDbProvider(provider);
                dbProvider.ConnectionString = DESHelper.Decrypt(connectionString, DESkey);
            }
            catch (Exception ee)
            {
                LogHelper.GetLogger<SmrDbProvider>().Error(ee.Message);
                LogHelper.GetLogger<SmrDbProvider>().Error(ee.StackTrace);
            }
        }

        public string ConnectionString { get; set; }

        public global::System.Data.IDbCommand CreateCommand()
        {
            return dbProvider.CreateCommand();
        }

        public object CreateCommandBuilder()
        {
            return dbProvider.CreateCommandBuilder();
        }

        public global::System.Data.IDbConnection CreateConnection()
        {
            return dbProvider.CreateConnection();
        }

        public global::System.Data.IDbDataAdapter CreateDataAdapter()
        {
            return dbProvider.CreateDataAdapter();
        }

        public global::System.Data.IDbDataParameter CreateParameter()
        {
            return dbProvider.CreateParameter();
        }

        public string CreateParameterName(string name)
        {
            return dbProvider.CreateParameterName(name);
        }

        public string CreateParameterNameForCollection(string name)
        {
            return dbProvider.CreateParameterNameForCollection(name);
        }

        public IDbMetadata DbMetadata
        {
            get { return dbProvider.DbMetadata; }
        }

        public string ExtractError(Exception e)
        {
            return dbProvider.ExtractError(e);
        }

        public bool IsDataAccessException(Exception e)
        {
            return dbProvider.IsDataAccessException(e);
        }
    }
}
