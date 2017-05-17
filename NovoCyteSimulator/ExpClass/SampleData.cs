using NovoCyteSimulator.ADO;
using NovoCyteSimulator.Equipment;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovoCyteSimulator.ExpClass
{
    public class SampleData
    {
        public static readonly char ParaNamesSeparator = '\t';

        private Parameters Parameters { get; set; }

        /// <summary>
        /// store original event data and compensated data
        /// </summary>
        public Dictionary<string, List<float>> Data
        {
            get;
            private set;
        }

        public void SetParameters(IList<TSampleConfig> sampleConfigs)
        {
            foreach (var sampleConfig in sampleConfigs)
            {
                Parameters = new Parameters(sampleConfig.ParameterNames, ParaNamesSeparator);
            }
        }

        public void SetBytes(IEnumerable<byte[]> datas)
        {
            Data = new Dictionary<string, List<float>>();

            foreach(Parameter para in Parameters)
            {
                Data.Add(para.Name, new List<float>());
            }
            int size = 4;
            long totalSize = 0;
            foreach (byte[] data in datas)
            {
                totalSize += data.Length;
            }
            int totalEvents = (int)(totalSize / (size * Parameters.Count));

            string[] keys = Data.Keys.ToArray();
            List<float>[] values = Data.Values.ToArray();

            uint[] multiple = new uint[Parameters.Count];
            for (int i=0; i<keys.Length; i++)
            {
                //为了与老的软件兼容，无论节拍是5ms或1us，始终用5ms
                multiple[i] = keys[i].ToLower() == "time" ? 5u : 1u;
                values[i].Clear();
                values[i].Capacity = totalEvents;
            }

            foreach (byte[] data in datas)
            {
                int index = 0;
                int events = data.Length / (size * keys.Length);
                for (int i = 0; i < keys.Length; i++)
                {
                    for (int j = 0; j < events; j++)
                    {
                        if (index + size > data.Length) break;
                        values[i].Add(BitConverter.ToSingle(data, index) * multiple[i]);
                        index += size;
                    }
                }
            }
        }
    }
}
