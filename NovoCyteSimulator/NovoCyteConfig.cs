using NovoCyteSimulator.Equipment;
using System;

namespace NovoCyteSimulator
{
    [Serializable]
    public class NovoCyteConfig
    {
        public Config Config { get; set; }
        public NovoCyteConfig(Config Config)
        {
            this.Config = Config;
        }
    }

    [Serializable]
    public class Config
    {
        public SystemInfo SystemInfo { get; set; }

        public AutoSample AutoSample { get; set; }

        public Weight Weight { get; set; }

        public Device Device { get; set; }

        public LaserConfig LaserConfig { get; set; }
    }
}
