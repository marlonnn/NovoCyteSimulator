using NovoCyteSimulator.ExpClass;
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
    public class SampleDataADO : SmrAdoTmplate<TSampleData>
    {
        public AdoTemplate AdoTmplate { set { this.adoTmplte = value; } }
        public SqliteConvertor SqliteConvertor { set { this.convertor = value; } }

        public SampleDataADO()
        {

        }
        public SampleDataADO(AdoTemplate adoTmplate, SqliteConvertor sqliteConvertor)
        {
            this.adoTmplte = adoTmplate;
            this.convertor = sqliteConvertor;
        }
    }

    [TableAttribute("SampleData")]
    public class TSampleData
    {
        [FieldAttribute("SD_ID", PrimaryKey = true)]
        public int SD_ID;

        [FieldAttribute("AcquisitionTime")]
        public DateTime AcquisitionTime;

        [FieldAttribute("Events")]
        public int Events;

        [FieldAttribute("Duration")]
        public int Duration;

        [FieldAttribute("Volume")]
        public int Volume;

        [FieldAttribute("Operator")]
        public string Operator;

    }
}
