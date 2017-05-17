using NovoCyteSimulator.ADO;
using NovoCyteSimulator.DBClass;
using Spring.Data.Common;
using Spring.Data.Generic;
using Summer.System.Data.VarietyDb;
using Summer.System.Security;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovoCyteSimulator.ADO
{
    public class DBADOFactory
    {
        private SmrDbProvider _dbProvider;

        private AdoTemplate _adoTemplate;

        private SqliteConvertor _sqliteConvertor;

        private SampleDataADO _sampleDataADO;

        private SampleDataDataADO _sampleDataDataADO;

        private SampleConfigADO _sampleConfigADO;


        public DBADOFactory()
        {

        }

        //provider "System.Data.SQLite"
        //connectionString="Data Source=./NCFData/170410_0917.ncf;Version=3"
        public DBADOFactory(string connectionString)
        {
            _dbProvider = new SmrDbProvider("System.Data.SQLite", DESHelper.Encrypt(connectionString, SmrDbProvider.DESKey));

            _adoTemplate = new AdoTemplate(_dbProvider);

            _sqliteConvertor = new SqliteConvertor(_dbProvider);

            _sampleDataADO = new SampleDataADO(_adoTemplate, _sqliteConvertor);

            _sampleDataDataADO = new SampleDataDataADO(_adoTemplate, _sqliteConvertor);

            _sampleConfigADO = new SampleConfigADO(_adoTemplate, _sqliteConvertor);
        }

        public List<byte[]> QuerySampleDataData(int SD_ID)
        {
            List<byte[]> list = new List<byte[]>();
            string sql = string.Format("Select Data from SampleDataData where SD_ID = {0} Order by [Order]", SD_ID);
            _sampleDataDataADO.AdoTmplate.QueryWithRowCallbackDelegate(System.Data.CommandType.Text,
                sql, 
                (r) =>
                {
                    if (!r.IsDBNull(0))
                    {
                        var v = r.GetValue(0);
                        list.Add((byte[])v);
                    };
                });
            return list;
        }

        public IList<TSampleDataData> QueryAllSampleDataData()
        {
            string sql = "Select * from SampleDataData";
            return _sampleDataDataADO.FindAll(sql);
        }

        public IList<TSampleData> QueryAllSampleData()
        {
            string sql = "Select * from SampleData";
            return _sampleDataADO.FindAll(sql);
        }
        public IList<TSampleConfig> QueryAllSampleConfig()
        {
            string sql = "Select * from SampleConfig";
            return _sampleConfigADO.FindAll(sql);
        }
    }
}
