using LuaInterface;
using NovoCyteSimulator.Equipment;
using NovoCyteSimulator.LuaInterface;
using NovoCyteSimulator.LuaScript;
using NovoCyteSimulator.Messages;
using NovoCyteSimulator.Protocols;
using NovoCyteSimulator.Protocols.Messages;
using NovoCyteSimulator.Util;
using Summer.System.Core;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using System.Windows.Forms;
using static NovoCyteSimulator.Equipment.Device;

namespace NovoCyteSimulator
{
    static class Program
    {
        /// <summary>
        /// 应用程序的主入口点。
        /// </summary>
        [STAThread]
        static void Main()
        {
            MiniDump.Init();
            SimulatorForm simulatorForm;
            try
            {
                //var v = NovoCyteConfig.GetInstance().Config.CytometerInfo;
                //var v1 = v.LaserConfig;
                //var v2 = FLChannel.FromLaserAndDetectionChannel(v.LaserConfig[0].ID, v.LaserConfig, v.PMTConfig[0].ID);
                //var v3 = FLChannel.FromLaserAndDetectionChannel(v.LaserConfig[1].ID, v.LaserConfig, v.PMTConfig[0].ID);
                //var vv = NovoCyteConfig.GetInstance().Config.LaserConfig.LaserChannelIDDic[Equipment.LaserType.nm405nm488nm640];
                //var startTime = (DateTime.UtcNow - new DateTime(1970, 1, 1)).TotalMilliseconds;
                //MotorManager motor = MotorManager.GetMotorManager();
                //motor.run(2, 40, -450);
                //Console.WriteLine("--->> C#中执行Lua脚本");
                ////C#中执行lua脚本文件
                //Lua lua = new Lua();
                //lua.DoFile("LuaScript\\subwork.lua");
                //lua.DoFile("LuaScript\\motor.lua");
                //lua.DoFile("LuaScript\\logtest.lua");
                //Console.ReadKey();

                //LaserConfig laserConfig = new LaserConfig();

                //CytometerInfo ci = new CytometerInfo();

                Application.EnableVisualStyles();
                Application.SetCompatibleTextRenderingDefault(false);
                //novoCyteSimulatorForm = SpringHelper.GetObject<NovoCyteSimulatorForm>("novoCyteSimulatorForm");
                simulatorForm = SpringHelper.GetObject<SimulatorForm>("simulatorForm");
                Config config = NovoCyteConfig.GetInstance().Config;

                //var v1 = FLChannel.GetFLChannel(config.CytometerInfo);
                //var channel = FLChannel.GetFLChannel(config.CytometerInfo).GetPxLxChannelID(0);
                //for (int i=0; i<13; i++)
                //{
                //    var C = FLChannel.GetFLChannel(config.CytometerInfo).GetPxLxChannelID(i).ToString();
                //    Console.WriteLine(C);
                //}
                //var vv = NovoCyteConfig.GetInstance();
                ////vv.Config = new Config();
                //vv.Config = config;
                //Equipment.LaserConfig c = new Equipment.LaserConfig();
                //vv.Config.CytometerInfo = ci;
                //config.CytometerInfo = ci;
                simulatorForm.Config = config;
                //var s = JsonFile.GetJsonTextFromNovoCyteConfig(vv);
                //string path = string.Format(@"{0}\\{1}", System.Environment.CurrentDirectory, "Config\\novosys_cfg.json");
                //try
                //{
                //    File.WriteAllText(path, s);
                //}
                //catch (Exception ee)
                //{

                //}
                Dictionary<byte, CBase> decoders = SpringHelper.GetObject<Dictionary<System.Byte, NovoCyteSimulator.Messages.CBase>>("decoders");
                foreach (var decoder in decoders.Values)
                {
                    decoder.Config = config;
                }
                Application.Run(simulatorForm);
            }
            catch (Exception ee)
            {

            }
        }
    }
}
