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
    public class SampleConfigADO : SmrAdoTmplate<TSampleConfig>
    {
        public AdoTemplate AdoTmplate { set { this.adoTmplte = value; } }
        public SqliteConvertor SqliteConvertor { set { this.convertor = value; } }

        public SampleConfigADO()
        {

        }
        public SampleConfigADO(AdoTemplate adoTmplate, SqliteConvertor sqliteConvertor)
        {
            this.adoTmplte = adoTmplate;
            this.convertor = sqliteConvertor;
        }
    }

    [TableAttribute("SampleConfig")]
    public class TSampleConfig
    {
        [FieldAttribute("SC_ID", PrimaryKey = true)]
        public int SC_ID;

        [FieldAttribute("R_ID")]
        public int R_ID;

        [FieldAttribute("WellID")]
        public string WellID;

        [FieldAttribute("SampleName")]
        public string SampleName;

        [FieldAttribute("Unlimited")]
        public byte Unlimited;

        [FieldAttribute("EventsLimits")]
        public int EventsLimits;

        [FieldAttribute("TimeLimits")]
        public int TimeLimits;

        [FieldAttribute("VolumeLimits")]
        public int VolumeLimits;

        [FieldAttribute("GateLimits")]
        public string GateLimits;

        [FieldAttribute("FlowRateLevel")]
        public byte FlowRateLevel;

        [FieldAttribute("CustomFlowRate")]
        public int CustomFlowRate;

        [FieldAttribute("PrimaryChannel")]
        public byte PrimaryChannel;

        [FieldAttribute("PrimaryThreshold")]
        public int PrimaryThreshold;

        [FieldAttribute("SecondaryChannel")]
        public byte SecondaryChannel;

        [FieldAttribute("SecondaryThreshold")]
        public int SecondaryThreshold;

        [FieldAttribute("ParameterNames")]
        public string ParameterNames;

        [FieldAttribute("GroupID")]
        public int GroupID;

        [FieldAttribute("Graph")]
        public byte[] Graph;

        [FieldAttribute("StorageGate")]
        public string StorageGate;
    }
}
