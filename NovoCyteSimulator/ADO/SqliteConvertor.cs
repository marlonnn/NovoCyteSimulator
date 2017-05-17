using Spring.Data.Common;
using Summer.System.Data.VarietyDb;
using System;
using System.Collections.Generic;
using System.Data.SQLite;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovoCyteSimulator.ADO
{
    public class SqliteConvertor : SqlServerConvertor
    {
        public IDbProvider Provider { set { this.provider = value; } }
        public SqliteConvertor()
        {

        }

        public SqliteConvertor(IDbProvider provider)
        {
            this.provider = provider;
        }
        protected override global::System.Data.IDataParameter CreateDataParameter(string name, object value)
        {
            return new SQLiteParameter(name, value);
        }

    }
}
