using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovoCyteSimulator.ExpClass
{
    public class NCFData
    {
        public NCFData()
        {
            configs = new List<SampleConfig>();
        }
        public static NCFData data;
        public static NCFData GetData()
        {
            if (data == null)
            {
                data = new NCFData();
            }
            return data;
        }

        private List<SampleConfig> configs;
        public List<SampleConfig> Configs
        {
            get
            {
                return configs;
            }
            set
            {
                configs = value;
            }
        }
    }
}
