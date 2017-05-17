using NovoCyteSimulator.ADO;
using NovoCyteSimulator.Equipment;
using NovoCyteSimulator.ExpClass;
using NovoCyteSimulator.USBSimulator;
using NovoCyteSimulator.Util;
using Summer.System.Core;
using Summer.System.Log;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace NovoCyteSimulator
{
    public partial class NovoCyteSimulatorForm : DevComponents.DotNetBar.Office2007RibbonForm
    {
        private string _jsonFilePath;
        private Config _config;

        private DBADOFactory _dbADOFactory;

        private IList<TSampleData> _sampleDataList;

        private IList<TSampleDataData> _sampleDataDataList;

        private IList<TSampleConfig> _sampleConfigList;

        private SampleData _sampleData;

        private string _connectString;

        private RunUSBDevice _runUSBDevice;

        private Thread RunUSBThread;

        public NovoCyteSimulatorForm()
        {
            InitializeComponent();
        }

        public NovoCyteSimulatorForm(Config Config, string jsonFilePath)
        {
            InitializeComponent();
            this.Load += NovoCyteSimulatorForm_Load;
            this.FormClosing += NovoCyteSimulatorForm_FormClosing;
            this.ribbonControl1.KeyDown += NovoCyteSimulatorForm_KeyDown;
            this._config = Config;
            this._jsonFilePath = jsonFilePath;
            InitializeMachineStatus();
        }

        private void NovoCyteSimulatorForm_FormClosing(object sender, FormClosingEventArgs e)
        {
            _runUSBDevice.KeepLooping = false;
            RunUSBThread.Abort();
            _runUSBDevice.UnPlugUSB();
        }

        private void NovoCyteSimulatorForm_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.Control == true && e.KeyCode == Keys.F7)
            {
                viewLog(new string[] {"Simulator.log", "Simulator.send"});
            }
        }

        private void viewLog(string[] logname)
        {
            string logView = string.Format("{0}\\Resources\\LogView.exe", System.Environment.CurrentDirectory);
            string logFile = "";
            foreach (var log in logname)
            {
                logFile += string.Format("\"{0}\\log\\{1}\" ", System.Environment.CurrentDirectory, log);
            }
            try
            {
                System.Diagnostics.Process.Start("\"" + logView + "\"", logFile);
            }
            catch (Exception)
            {
            }
        }
        private void InitializeMachineStatus()
        {
            var v = _config.Device.SystemWorkModeIntervalDic.Keys.ToArray();
            foreach (var item in _config.Device.SystemWorkModeIntervalDic.Keys)
            {
                this.cbBoxMachineStatus.Items.Add(item);
            }
            this.cbBoxMachineStatus.SelectedIndex = 1;
            //this.cbBoxMachineStatus.SelectedItem = "Power Up Init";
            this._config.Device.SystemMainWorkMode = _config.Device.SystemWorkModeIntervalDic[cbBoxMachineStatus.SelectedItem.ToString()];
            //this.ribbonControl1.Focus();
        }

        private void NovoCyteSimulatorForm_Load(object sender, System.EventArgs e)
        {
            LoadJsonFile();
            RunUSBThread = new Thread(new ThreadStart(_runUSBDevice.EnumSimulatedDevices));
            RunUSBThread.IsBackground = true;
            RunUSBThread.Priority = ThreadPriority.Highest;
            RunUSBThread.Start();
        }

        private void LoadJsonFile()
        {
            //string path = string.Format(@"{0}\\{1}", System.Environment.CurrentDirectory, _jsonFilePath);
            //if (File.Exists(path))
            //{
            //    string jsonText = File.ReadAllText(path);
            //    _novoCyteConfig.Config = JsonFile.GetNovoCyteConfigFromJsonText(jsonText).Config;
            //}
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

        //加载ncf实验数据
        private void btnItemOpen_Click(object sender, EventArgs e)
        {
            OpenFileDialog openFileDialog1 = new OpenFileDialog();
            openFileDialog1.Filter = "ncf Files(*.ncf)|*.ncf|All Files (*.*)|*.*";
            openFileDialog1.InitialDirectory = string.Format("{0}\\{1}", System.Environment.CurrentDirectory, "NCFData");

            DialogResult res = openFileDialog1.ShowDialog(this);

            if (res == DialogResult.OK)
            {
                string fileName = openFileDialog1.FileName;
                _connectString = string.Format("Data Source={0}; Version=3", fileName);
                try
                {
                    _dbADOFactory = new DBADOFactory(_connectString);
                    _sampleDataList = _dbADOFactory.QueryAllSampleData();

                    _sampleDataDataList = _dbADOFactory.QueryAllSampleDataData();

                    var v = _dbADOFactory.QuerySampleDataData(2);

                    _sampleConfigList = _dbADOFactory.QueryAllSampleConfig();

                    _sampleData.SetParameters(_sampleConfigList);
                    _sampleData.SetBytes(v);
                }
                catch (Exception ee)
                {
                    LogHelper.GetLogger<NovoCyteSimulatorForm>().Debug(ee.Message);
                    throw ee;
                }
            }
        }

        private void MachineStatus_SelectedIndexChanged(object sender, EventArgs e)
        {
            this.txtInstrumentState.Text = this.cbBoxMachineStatus.SelectedItem.ToString();
            this._config.Device.SystemMainWorkMode = _config.Device.SystemWorkModeIntervalDic[cbBoxMachineStatus.SelectedItem.ToString()];
            this.ribbonControl1.Focus();
        }
    }
}
