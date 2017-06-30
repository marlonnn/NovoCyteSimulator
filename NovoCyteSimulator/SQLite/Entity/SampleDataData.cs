using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovoCyteSimulator.SQLite.Entity
{
    public class SampleDataData
    {
        public int SD_ID { get; set; }

        public int Order { get; set; }

        public byte[] Data { get; set; }
    }
}
