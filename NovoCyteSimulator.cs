using NovoCyteSimulator.Util;
using Summer.System.Core;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace NovoCyteSimulator
{
    public partial class NovoCyteSimulatorForm : Form
    {
        private string _jsonFilePath;
        private NovoCyteConfig _novoCyteConfig;
        public NovoCyteSimulatorForm()
        {
            InitializeComponent();
        }

        private void NovoCyteSimulatorForm_Load(object sender, System.EventArgs e)
        {
            LoadJsonFile();
            var novoCyteSimulatorForm = SpringHelper.GetObject<NovoCyteConfig>("novoCyteConfig");
        }

        private void LoadJsonFile()
        {
            string path = string.Format(@"{0}\\{1}", System.Environment.CurrentDirectory, _jsonFilePath);
            if (File.Exists(path))
            {
                string jsonText = File.ReadAllText(path);
                _novoCyteConfig.Config = JsonFile.GetNovoCyteConfigFromJsonText(jsonText).Config;
            }
        }

        private void Exit()
        {
            try
            {
                Quartz.Impl.StdScheduler scheduler = (Quartz.Impl.StdScheduler)SpringHelper.GetContext().GetObject("scheduler");
                scheduler.Shutdown();
            }
            catch (Exception ee)
            {
            }
        }
    }
}
