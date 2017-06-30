using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovoCyteSimulator.SQLite.Entity
{
    public class SampleConfig
    {
        public int SC_ID { get; set;}

        public int R_ID { get; set;}

        public string WellID { get; set;}

        public string SampleName { get; set;}

        public byte Unlimited { get; set;}

        public int EventsLimits { get; set;}

        public int TimeLimits { get; set;}

        public int VolumeLimits { get; set;}

        public string GateLimits { get; set;}

        public byte FlowRateLevel { get; set;}

        public int CustomFlowRate { get; set;}

        public byte PrimaryChannel { get; set;}

        public int PrimaryThreshold { get; set;}

        public byte SecondaryChannel { get; set;}

        public int SecondaryThreshold { get; set;}

        public string ParameterNames { get; set;}

        public int GroupID { get; set;}

        public byte[] Graph { get; set;}

        public string StorageGate { get; set;}
    }
}
