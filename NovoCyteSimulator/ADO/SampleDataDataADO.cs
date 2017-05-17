using Spring.Data.Generic;
using Summer.System.Data;
using Summer.System.Data.DbMapping;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovoCyteSimulator.ADO
{
    public class SampleDataDataADO : SmrAdoTmplate<TSampleDataData>
    {
        public AdoTemplate AdoTmplate
        {
            set { this.adoTmplte = value; }
            get { return this.adoTmplte; }
        }
        public SqliteConvertor SqliteConvertor { set { this.convertor = value; } }

        public SampleDataDataADO()
        {

        }

        public SampleDataDataADO(AdoTemplate adoTmplate, SqliteConvertor sqliteConvertor)
        {
            this.adoTmplte = adoTmplate;
            this.convertor = sqliteConvertor;
        }
    }

    [TableAttribute("SampleDataData")]
    public class TSampleDataData
    {
        [FieldAttribute("SD_ID", PrimaryKey = true)]
        public int SD_ID;

        [FieldAttribute("Order")]
        public int Order;

        [FieldAttribute("Data")]
        public byte[] Data;
    }
}
