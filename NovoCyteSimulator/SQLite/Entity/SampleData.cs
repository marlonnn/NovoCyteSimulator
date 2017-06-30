using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovoCyteSimulator.SQLite.Entity
{
    public class SampleData
    {
        public int SD_ID { get; set; }

        public DateTime AcquisitionTime { get; set; }

        public int Events { get; set; }

        public int Duration { get; set; }

        public int Volume { get; set; }

        public string Operator { get; set; }
    }
}
