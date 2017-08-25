using LuaInterface;
using NovoCyteSimulator.Equipment;
using NovoCyteSimulator.ExpClass;
using NovoCyteSimulator.LuaScript.LuaInterface;
using NovoCyteSimulator.Messages;
using NovoCyteSimulator.Protocols.Messages;
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
        private string _connectString;

        private Config _config;
        public Config Config
        {
            set { this._config = value; }
            get { return this._config; }
        }
        private USBDevice usbDevice;
        private Thread usbThread;

        private Lua lua;

        private Dictionary<byte, CBase> decoders;

        private Thread luaThread;
        private Thread selectStateThread;

        private DBOperate dbOp;

        public SimulatorForm()
        {
            InitializeComponent();
            InitializeLuaInterface();
            this.Load += SimulatorForm_Load;
            this.FormClosing += SimulatorForm_FormClosing;
            this.KeyDown += SimulatorForm_KeyDown;
            this.comboBoxStatus.SelectedIndexChanged += ComboBoxStatus_SelectedIndexChanged;
        }

        private void SimulatorForm_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.Control == true && e.KeyCode == Keys.F7)
            {
                viewLog(new string[] { "Simulator.log", "Simulator.transfer" });
            }
        }

        private void InitializeLuaInterface()
        {
            lua = new Lua();
            lua.DoFile("LuaScript\\work.lua");
        }

        private void InitializeMachineStatus()
        {
            string[] status = new string[] { "Start Up", "Idle", "Measure", "Maintain", "Sleep" };
            this.comboBoxStatus.Items.AddRange(status);
        }

        private void SimulatorForm_Load(object sender, EventArgs e)
        {
            InitializeMachineStatus();
            InitializeStateChangeHandler();
            StartUSBThread();
            SetCommandHandler();
        }

        private void InitializeStateChangeHandler()
        {
            SubWork.GetSubWork().FromLua.StateChangeHandler += StateChangeHandler;
        }

        private void StateChangeHandler()
        {
            //this.comboBoxStatus.SelectedIndex = SubWork.GetSubWork().FromLua.State - 1;
            string state = GetState(SubWork.GetSubWork().FromLua.State);
            //this.toolStripStatus.Text = string.Format("Status: {0}", state);
            Console.WriteLine("simulator form set state to : " + state);
        }

        private void SetCommandHandler()
        {
            C2D c2d = decoders[0x2D] as C2D;
            if (c2d != null)
            {
                c2d.UpdateStateHandler += UpdateStateHandler;
            }
            C21 c21 = decoders[0x21] as C21;
            if (c21 != null)
            {
                c21.UpdateCellCollectionStateHandler += UpdateCellCollectionStateHandler;
            }
        }

        private void UpdateCellCollectionStateHandler(int state)
        {
            try
            {
                if (state == 1)
                {
                    //开始测试
                    StartSelectStateThread((int)WorkState.WORK_MEASURE);
                }
                else if (state == 0)
                {
                    //停止测试
                }
            }
            catch (Exception ee)
            {
            }
        }

        public void StartSelectStateThread(int state)
        {
            selectStateThread = new Thread(() => SelectWorkState(state));
            selectStateThread.IsBackground = true;
            selectStateThread.Start();
        }

        public void SelectWorkState(int state)
        {
            Select(state, 1, 1);
        }

        private void UpdateStateHandler()
        {
            StartSelectStateThread((int)WorkState.WORK_SLEEPEXIT);
        }

        private void ComboBoxStatus_SelectedIndexChanged(object sender, System.EventArgs e)
        {
            string status = this.comboBoxStatus.SelectedItem.ToString();
            switch (status)
            {
                case "Start Up":
                    StartSelectStateThread((int)WorkState.WORK_STARTUP);
                    break;
                case "Idle":
                    StartSelectStateThread((int)WorkState.WORK_IDLE);
                    break;
                case "Measure":
                    StartSelectStateThread((int)WorkState.WORK_MEASURE);
                    break;
                case "Maintain":
                    StartSelectStateThread((int)WorkState.WORK_MAINTAIN);
                    break;
                case "Sleep":
                    StartSelectStateThread((int)WorkState.WORK_SLEEP);
                    break;
            }
        }

        private string GetState(int state)
        {
            string s = "";
            switch  (state)
            {
                case 1:
                    s = "Start Up";
                    break;
                case 2:
                    s = "Idle";
                    break;
                case 3:
                    s = "Measure";
                    break;
                case 4:
                    s = "Maintain";
                    break;
                case 8:
                    s = "Sleep";
                    break;
            }
            return s;
        }

        private void SimulatorForm_FormClosing(object sender, FormClosingEventArgs e)
        {
            StopUSBThread();
        }

        private void StartUSBThread()
        {
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
            //var v = FLChannel.GetFLChannel(NovoCyteConfig.GetInstance().Config.CytometerInfo).channels;

            OpenFileDialog openFileDialog1 = new OpenFileDialog();
            openFileDialog1.Filter = "ncf Files(*.ncf)|*.ncf|All Files (*.*)|*.*";
            openFileDialog1.InitialDirectory = string.Format("{0}\\{1}", System.Environment.CurrentDirectory, "NCFData");

            DialogResult res = openFileDialog1.ShowDialog(this);

            if (res == DialogResult.OK)
            {
                try
                {
                    string fileName = openFileDialog1.FileName;
                    dbOp = DBOperate.CreateDBOperator(fileName);
                    if (dbOp.Connect(false))
                    {
                        ReadSampleConfig();
                    }
                    if (dbOp != null && dbOp.IsOpen)
                    {
                        dbOp.Close(false);
                    }
                }
                catch (Exception ex)
                {

                }
            }
        }

        private void ReadSampleConfig()
        {
            string sql = "Select * from SampleConfig";
            var table = dbOp.TryExecuteDataTable(sql, null);
            if (table != null)
            {
                NCFData.GetData().Configs.Clear();
                foreach (DataRow row in table.Rows)
                {
                    SampleConfig sample = new SampleConfig();
                    Parameters paras = new Parameters(Convert.ToString(row["ParameterNames"]), '\t');

                    sample.SC_ID = Convert.ToInt32(row["SC_ID"]);
                    sample.SampleName = Convert.ToString(row["SampleName"]);

                    sample.SampleName = Convert.ToString(row["SampleName"]);
                    sample.Unlimited = Convert.ToBoolean(row["Unlimited"]);
                    sample.EventsLimits = Convert.ToUInt32(row["EventsLimits"]);
                    sample.TimeLimits = Convert.ToUInt16(row["TimeLimits"]);
                    sample.VolumeLimits = Convert.ToUInt16(row["VolumeLimits"]);
                    sample.GateLimits = table.Columns.Contains("GateLimits") ? Convert.ToString(row["GateLimits"]) : string.Empty;
                    sample.FlowRateLevel = (FlowRateLevel)Convert.ToByte(row["FlowRateLevel"]);
                    sample.CustomFlowRate = Convert.ToUInt16(row["CustomFlowRate"]);
                    sample.PrimaryChannel = (SByte)Convert.ToByte(row["PrimaryChannel"]);
                    sample.PrimaryThreshold = Convert.ToInt32(row["PrimaryThreshold"]);
                    sample.SecondaryChannel = (SByte)Convert.ToByte(row["SecondaryChannel"]);
                    sample.SecondaryThreshold = Math.Max(Convert.ToInt32(row["SecondaryThreshold"]), 10);
                    sample.StorageGate = table.Columns.Contains("StorageGate") ? Convert.ToString(row["StorageGate"]) : string.Empty;

                    if (paras.Count > 0) sample.Parameters = paras;

                    ReadSampleDataData(sample, sample.SC_ID);
                    NCFData.GetData().Configs.Add(sample);
                }
                //var v = NCFData.GetData().Configs[0].SampleData;
                //C22 c22 = decoders[0x22] as C22;
                //c22.Test();
            }
        }

        private void ReadSampleDataData(SampleConfig sample, int sdid)
        {
            var reader = dbOp.TryExecuteReader(string.Format(@"Select Data from SampleDataData where SD_ID = {0} Order by [Order]", sdid), null);
            List<byte[]> data = new List<byte[]>();
            if (reader != null)
            {
                while (reader.Read())
                {
                    object o = reader.GetValue(0);
                    if (o is DBNull) continue;
                    data.Add((byte[])o);
                }
                sample.SampleData.SetBytes(data, sample.Parameters);
            }
        }

        public void Select(int stateto, int subref1, int subref2)
        {
            SubWork subwork = SubWork.GetSubWork();
            subwork.ToLua.Stateto = stateto;
            subwork.ToLua.Subref1 = subref1;
            subwork.ToLua.Subref2 = subref2;

            LuaTable table = lua.GetTable("work");
            LuaFunction function = (LuaFunction)table["setstate"];
            function.Call();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            SubWork subwork = SubWork.GetSubWork();
            var state = subwork.ToLua.Stateto;
            var fromState = subwork.FromLua.State;
        }

        private void timer1_Tick(object sender, EventArgs e)
        {

        }
    }
}
