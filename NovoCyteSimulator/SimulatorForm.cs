using NovoCyteSimulator.USBSimulator;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
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
        private Config _config;
        private RunUSBDevice _runUSBDevice;
        private Thread RunUSBThread;
        public SimulatorForm()
        {
            InitializeComponent();
        }

        public SimulatorForm(Config config)
        {
            InitializeComponent();
            this._config = config;
            InitializeMachineStatus();
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
            StartUSBThread();
        }

        private void SimulatorForm_FormClosing(object sender, FormClosingEventArgs e)
        {
            StopUSBThread();
        }

        private void StartUSBThread()
        {
            RunUSBThread = new Thread(new ThreadStart(_runUSBDevice.EnumSimulatedDevices));
            RunUSBThread.IsBackground = true;
            RunUSBThread.Priority = ThreadPriority.Highest;
            RunUSBThread.Start();
        }

        private void StopUSBThread()
        {
            _runUSBDevice.KeepLooping = false;
            RunUSBThread.Abort();
            _runUSBDevice.UnPlugUSB();
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
    }
}
