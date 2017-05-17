using SOFTUSB;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovoCyteSimulator.USBSimulator
{
    public interface iLoopbackDevice 
    {
        void InitMemberVariables();
        void CreateUSBDevice();
        void ConfigureDevice();
        void ConfigureOUTEndpoint();
        void ConfigureINEndpoint();
        void SetupConnectionPoint(SoftUSBEndpoint usbEndpoint, ref Guid iidConnectionPoint);
        void ReleaseConnectionPoint();
    }
}
