using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovoCyteSimulator.Equipment
{
    [Serializable]
    public class CytometerInfo
    {
        private PMTConfig _pmtConfig;

        /// <summary>
        /// PMT configuration and information, including exists, voltage, default voltage, name
        /// </summary>
        public PMTConfig PMTConfig
        {
            get { return _pmtConfig; }
            set { _pmtConfig = value; }
        }

        private LaserConfig _laserConfig;

        /// <summary>
        /// laser configuration and information
        /// </summary>
        public LaserConfig LaserConfig
        {
            get { return _laserConfig; }
            set { _laserConfig = value; }
        }

        public CytometerInfo()
        {
            PMTConfig = new PMTConfig();
            LaserConfig = new LaserConfig();
        }
    }
}
