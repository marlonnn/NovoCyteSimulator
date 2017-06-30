using DSF;
using NovoCyteSimulator.Messages;
using NovoCyteSimulator.Util;
using SOFTUSB;
using SoftUSBLoopbackLib;
using Summer.System.Log;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace NovoCyteSimulator.USBSimulator
{

    public class USBDevice
    {
        private const string IID_IDSFBus = "{E927C266-5364-449E-AE52-D6A782AFDA9C}";
        private const string IID_ISoftUSBDevice = "{9AC61697-81AE-459A-8629-BF5D5A838519}";

        private DSF.DSF dsf;
        private DSFBus bus;
        private SoftUSBDevice LoopbackUSBDev;
        private DSFDevice LoopbackDSFDev;

        private byte[] receiveBytes;

        private LoopbackDevice LoopbackDev;

        private const int status = 2;
        private Dictionary<byte, CBase> decoders;
        private byte msgType;

        public bool IsRunning { set; get; }

        public USBDevice()
        {
            IsRunning = false;
        }

        public void RunSimulatedDevices()
        {
            try
            {
                dsf = new DSF.DSF();
                object obj = Activator.CreateInstance(Type.GetTypeFromProgID("SoftUSBLoopback.LoopbackDevice"));
                LoopbackDev = (LoopbackDevice)obj;
                LoopbackDSFDev = LoopbackDev.DSFDevice;
                LoopbackUSBDev = LoopbackDSFDev.Object[IID_ISoftUSBDevice];
                bus = dsf.HotPlug(LoopbackDSFDev, "USB2.0");
                IsRunning = true;
                LoopbackDev.OnProcessingData += LoopbackDev_OnProcessingData;
                LoopbackDev.DoPolledLoopback(100);
            }
            catch (Exception ee)
            {
                UnPlugUSB();
                LogHelper.GetLogger<USBDevice>().Error(string.Format("Run simulate USB device error. Error message is : {0} \n {1}", ee.Message, ee.StackTrace));
            }
        }
        private Stopwatch stopwatch = new Stopwatch();
        private void LoopbackDev_OnProcessingData(int dataCount)
        {
            if (dataCount > 9)
            {
                receiveBytes = new byte[dataCount];
                try
                {
                    for (int i = 0; i < dataCount; i++)
                    {
                        receiveBytes[i] = LoopbackDev.TransData(i);
                    }
                    msgType = receiveBytes[6];
                    if (ProcessReceiveData(msgType))
                    {
                        byte[] txBytes = decoders[msgType].Encode();
                        //string readableByte = Util.StringUtil.Byte2ReadableXstring(txBytes);
                        LoopbackDev.SendData(ref txBytes[0], (uint)txBytes.Length, status, uint.MaxValue);
                    }
                }
                catch (Exception ee)
                {
                    LogHelper.GetLogger<USBDevice>().Error(string.Format("消息类型为： {0} 处理异常\n 异常Message： {1}, StackTrace: {2}",
                        string.Format("0x{0:X2} ", msgType), ee.Message, ee.StackTrace));
                }
            }

        }

        private bool ProcessReceiveData(byte msgType)
        {
            return decoders.ContainsKey(msgType) && decoders[msgType].Decode(receiveBytes);
        }

        public void UnPlugUSB()
        {
            try
            {
                bus.Unplug(LoopbackDSFDev);
                if (LoopbackUSBDev != null)
                    LoopbackUSBDev.Destroy();
                IsRunning = false;
            }
            catch (Exception e)
            {
                LogHelper.GetLogger<USBDevice>().Error(string.Format("拔出USB异常，异常消息Message： {0}, StackTrace: {1}", e.Message, e.StackTrace));
            }
        }
    }
}
