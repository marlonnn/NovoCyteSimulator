using NovoCyteSimulator.Protocols;
using Summer.System.Core;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Windows.Forms;

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
            NovoCyteSimulatorForm novoCyteSimulatorForm;
            SimulatorForm simulatorForm;
            try
            {
                Application.EnableVisualStyles();
                Application.SetCompatibleTextRenderingDefault(false);
                //novoCyteSimulatorForm = SpringHelper.GetObject<NovoCyteSimulatorForm>("novoCyteSimulatorForm");
                simulatorForm = SpringHelper.GetObject<SimulatorForm>("simulatorForm");
                Application.Run(simulatorForm);
            }
            catch (Exception ee)
            {

            }
        }
    }
}
