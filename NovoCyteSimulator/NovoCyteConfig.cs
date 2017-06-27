using NovoCyteSimulator.Equipment;
using NovoCyteSimulator.Util;
using System;
using System.IO;

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

        public static NovoCyteConfig novoCyteConfig = null;

        public static NovoCyteConfig GetInstance()
        {
            if (novoCyteConfig == null)
            {
                string path = string.Format(@"{0}\\{1}", System.Environment.CurrentDirectory, "Config\\novosys_cfg.json");
                if (File.Exists(path))
                {
                    string jsonText = File.ReadAllText(path);
                    novoCyteConfig = JsonFile.GetNovoCyteConfigFromJsonText(jsonText);
                }
            }
            return novoCyteConfig;
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
