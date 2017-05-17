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
            try
            {
                Application.EnableVisualStyles();
                Application.SetCompatibleTextRenderingDefault(false);
                novoCyteSimulatorForm = SpringHelper.GetObject<NovoCyteSimulatorForm>("novoCyteSimulatorForm");

                Application.Run(novoCyteSimulatorForm);
            }
            catch (Exception ee)
            {

            }
        }
    }
}
