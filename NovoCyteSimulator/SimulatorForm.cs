using NovoCyteSimulator.ExpClass;
using NovoCyteSimulator.SQLite;
using NovoCyteSimulator.SQLite.Entity;
using NovoCyteSimulator.USBSimulator;
using Summer.System.Core;
using Summer.System.Log;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SQLite;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace NovoCyteSimulator
{
    public partial class SimulatorForm : Form
    {
        private NovoCyteSimulator.ExpClass.SampleData _sampleData;

        private string _connectString;

        private Config _config;
        public Config Config
        {
            set { this._config = value; }
            get { return this._config; }
        }
        private USBDevice usbDevice;
        private Thread usbThread;

        public SimulatorForm()
        {
            InitializeComponent();
            this.Load += SimulatorForm_Load;
            this.FormClosing += SimulatorForm_FormClosing;
            this.KeyDown += SimulatorForm_KeyDown;
            this.comboBoxStatus.SelectedIndexChanged += ComboBoxStatus_SelectedIndexChanged;
        }

        private void ComboBoxStatus_SelectedIndexChanged(object sender, EventArgs e)
        {
        }

        private void SimulatorForm_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.Control == true && e.KeyCode == Keys.F7)
            {
                viewLog(new string[] { "Simulator.log", "Simulator.transfer" });
            }
        }

        private void InitializeMachineStatus()
        {
            foreach (var item in _config.Device.SystemWorkModeIntervalDic.Keys)
            {
                this.comboBoxStatus.Items.Add(item);
            }
            this.comboBoxStatus.SelectedIndex = 1;
            this._config.Device.SystemMainWorkMode = _config.Device.SystemWorkModeIntervalDic[comboBoxStatus.SelectedItem.ToString()];
        }

        private void SimulatorForm_Load(object sender, EventArgs e)
        {
            InitializeMachineStatus();
            StartUSBThread();
        }

        private void SimulatorForm_FormClosing(object sender, FormClosingEventArgs e)
        {
            StopUSBThread();
        }

        private void StartUSBThread()
        {
            //usbDevice = SpringHelper.GetObject<USBDevice>("usbDevice");
            usbThread = new Thread(new ThreadStart(usbDevice.RunSimulatedDevices));
            usbThread.IsBackground = true;
            usbThread.Priority = ThreadPriority.Highest;
            usbThread.Start();
        }

        private void StopUSBThread()
        {
            if (usbDevice.IsRunning)
            {
                usbThread.Abort();
                usbDevice.UnPlugUSB();
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
            catch (Exception e)
            {
                LogHelper.GetLogger<SimulatorForm>().Error(
                    string.Format("打开日志异常，异常消息Message： {0}, StackTrace: {1}", e.Message, e.StackTrace));
            }
        }

        private void btnNcf_Click(object sender, EventArgs e)
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
                    SQLiteConfig.DatabaseFile = openFileDialog1.FileName;
                    this.lbDB.Text = SQLiteConfig.DataSource;
                    InitializeSampleData();
                }
                catch (Exception ee)
                {
                    LogHelper.GetLogger<SimulatorForm>().Debug(ee.Message);
                }
            }
        }

        private void InitializeSampleData()
        {
            using (SQLiteConnection conn = new SQLiteConnection(SQLiteConfig.DataSource))
            {
                using (SQLiteCommand cmd = new SQLiteCommand())
                {
                    cmd.Connection = conn;
                    conn.Open();
                    SQLiteHelper sh = new SQLiteHelper(cmd);
                    try
                    {

                        string sampleConfigSql = "Select * from SampleConfig";
                        DataTable sampleConfigDt = sh.Select(sampleConfigSql);
                        List<object> sampleConfigs = EntityHelper.DataTableToList(sampleConfigDt, "SampleConfig");
                        _sampleData.SetParameters(sampleConfigs);

                        string sampleDataDataSql = string.Format(
                            "Select Data from SampleDataData where SD_ID = {0} Order by [Order]", 2);
                        DataTable sampleDataDataDt = sh.Select(sampleDataDataSql);
                        List<object> sampleDataDatas = EntityHelper.DataTableToList(sampleDataDataDt, "SampleDataData");
                        _sampleData.SetBytes(sampleDataDatas);
                    }
                    catch (Exception ex)
                    {
                        LogHelper.GetLogger<SimulatorForm>().Error(ex.Message);
                        LogHelper.GetLogger<SimulatorForm>().Error(ex.StackTrace);
                    }
                    conn.Close();
                }
            }
        }
    }
}
