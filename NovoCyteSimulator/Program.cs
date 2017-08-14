using LuaInterface;
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
                //var v = NovoCyteConfig.GetInstance().Config.LaserConfig;
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

                Application.EnableVisualStyles();
                Application.SetCompatibleTextRenderingDefault(false);
                //novoCyteSimulatorForm = SpringHelper.GetObject<NovoCyteSimulatorForm>("novoCyteSimulatorForm");
                simulatorForm = SpringHelper.GetObject<SimulatorForm>("simulatorForm");
                Config config = NovoCyteConfig.GetInstance().Config;
                var vv = NovoCyteConfig.GetInstance();
                vv.Config = new Config();
                Equipment.LaserConfig c = new Equipment.LaserConfig();
                vv.Config.LaserConfig = c;
                config.LaserConfig = c;
                simulatorForm.Config = config;
                var s = JsonFile.GetJsonTextFromNovoCyteConfig(vv);
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
