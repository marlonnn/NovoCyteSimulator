using NovoCyteSimulator.Messages;
using NovoCyteSimulator.Protocols;
using NovoCyteSimulator.Protocols.Messages;
using NovoCyteSimulator.Util;
using Summer.System.Core;
using System;
using System.Collections.Generic;
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
                Application.EnableVisualStyles();
                Application.SetCompatibleTextRenderingDefault(false);
                //novoCyteSimulatorForm = SpringHelper.GetObject<NovoCyteSimulatorForm>("novoCyteSimulatorForm");
                simulatorForm = SpringHelper.GetObject<SimulatorForm>("simulatorForm");
                Config config = NovoCyteConfig.GetInstance().Config;
                simulatorForm.Config = config;
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
