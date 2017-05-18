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

    public class RunUSBDevice
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
        private Dictionary<byte, CBase> _decoders;
        private byte msgType;
        public RunUSBDevice()
        {
        }

        public void EnumSimulatedDevices()
        {
            try
            {
                dsf = new DSF.DSF();

                //usbDevice = new USBDevice();
                //LoopbackDSFDev = usbDevice.SoftUSBDevice.DSFDevice;
                //bus = dsf.HotPlug(LoopbackDSFDev, "USB2.0");

                object obj = Activator.CreateInstance(Type.GetTypeFromProgID("SoftUSBLoopback.LoopbackDevice"));
                LoopbackDev = (LoopbackDevice)obj;
                LoopbackDSFDev = LoopbackDev.DSFDevice;
                LoopbackUSBDev = LoopbackDSFDev.Object[IID_ISoftUSBDevice];
                SetEndpointDiagnostics(LoopbackUSBDev);
                bus = dsf.HotPlug(LoopbackDSFDev, "USB2.0");

                LoopbackDev.OnProcessingData += LoopbackDev_OnProcessingData;
                LoopbackDev.DoPolledLoopback(100);
            }
            catch (Exception ee)
            {
                UnPlugUSB();
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
                        byte[] txBytes = _decoders[msgType].Encode();
                        //string readableByte = Util.StringUtil.Byte2ReadableXstring(txBytes);
                        LoopbackDev.SendData(ref txBytes[0], (uint)txBytes.Length, status, uint.MaxValue);
                    }
                }
                catch (Exception ee)
                {
                    LogHelper.GetLogger<RunUSBDevice>().Error(string.Format("消息类型为： {0} 处理异常\n 异常Message： {1}, StackTrace: {2}",
                        string.Format("0x{0:X2} ", msgType), ee.Message, ee.StackTrace));
                    //UnPlugUSB();
                }
            }

        }

        private bool ProcessReceiveData(byte msgType)
        {
            return _decoders.ContainsKey(msgType) && _decoders[msgType].Decode(receiveBytes);
        }

        private bool keepLooping = true;
        public bool KeepLooping
        {
            get { return this.keepLooping; }
            set { this.keepLooping = value; }
        }

        public void UnPlugUSB()
        {
            try
            {
                bus.Unplug(LoopbackDSFDev);
                if (LoopbackUSBDev != null)
                    LoopbackUSBDev.Destroy();
            }
            catch (Exception e)
            {
            }
        }

        public void SetEndpointDiagnostics(SoftUSBDevice USBDevice)
        {
            string type = "";
            foreach (SoftUSBConfiguration config in USBDevice.Configurations)
            {
                Console.WriteLine(string.Format("Setting endpoint diagnostics for configuration {0}", config.ConfigurationValue));
                var Interfaces = config.Interfaces;
                foreach (SoftUSBInterface interf in Interfaces)
                {
                    Console.WriteLine(string.Format("Setting endpoint diagnostics for interface {0}, alternate {1}", interf.InterfaceNumber, interf.AlternateSetting));
                    var Endpoints = interf.Endpoints;
                    foreach (SoftUSBEndpoint endpoint in Endpoints)
                    {
                        var EPNum = endpoint.EndpointAddress & 0x0F;
                        var EPDir = endpoint.EndpointAddress & 0x80;
                        var EPType = endpoint.Attributes & 0x03;
                        switch (EPType)
                        {
                            case 0:
                                type = "Control";
                                break;
                            case 1:
                                type = "Isoch";
                                break;
                            case 2:
                                type = "Bulk";
                                break;
                            case 3:
                                type = "Interrupt";
                                break;
                        }
                        Console.WriteLine(string.Format("Endpoint.SetObjectFlags for {0} {1}, endpoint {2}", type, (EPDir == 0 ? "OUT" : "IN"), EPNum));
                    }
                }
            }
        }
    }
}
