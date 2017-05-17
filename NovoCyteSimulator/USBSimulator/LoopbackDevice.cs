using NPOI.HPSF;
using SOFTUSB;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Runtime.InteropServices.ComTypes;
using System.Text;
using System.Threading.Tasks;
namespace NovoCyteSimulator.USBSimulator
{
    public class LoopbackDevice : iLoopbackDevice
    {
        private SoftUSBDevice m_piSoftUSBDevice; //Underlying SoftUSBDevice object
        private SoftUSBEndpoint m_piINEndpoint;       //IN Endpoint
        private SoftUSBEndpoint m_piOUTEndpoint;      //OUT Endpoint
        private IConnectionPoint m_piConnectionPoint;  //Connection point interface
        private ushort usProductId = 0x930A;
        private ushort usVendorId = 0x045E;

        private string Manufacturer;
        private string ProductDesc;

        private int m_dwConnectionCookie;
        private int m_iInterfaceString;   //Index of interface identifier string
        private int m_iConfigString;      //Index of config identifier string

        private byte STRING_IDX_MANUFACTURER = 1;
        private byte STRING_IDX_PRODUCT_DESC = 2;
        private byte STRING_IDX_CONFIG = 3;
        private byte STRING_IDX_INTERFACE = 4;

        public LoopbackDevice()
        {
            Manufacturer = "Microsoft Corporation";
            ProductDesc = "Simulated Generic USB device";
            m_iInterfaceString = 0;
            m_iConfigString = 0;
            m_dwConnectionCookie = 0;

            try
            {
                DSF.DSF dsf = new DSF.DSF();
            }
            catch (Exception ee)
            {

            }

            CreateUSBDevice();
        }
        public void ConfigureDevice()
        {
            SoftUSBConfiguration piConfig = null;
            SoftUSBInterface piInterface = null;
            ISoftUSBConfigurations piConfigurations = null;
            ISoftUSBInterfaces piInterfaces = null;
            ISoftUSBEndpoints piEndpoints = null;

            var varIndex = Variant.VT_ERROR;

            m_piINEndpoint = new SoftUSBEndpoint();
            ConfigureINEndpoint();

            m_piOUTEndpoint = new SoftUSBEndpoint();
            ConfigureOUTEndpoint();

            piInterface = new SoftUSBInterface();
            ConfigureInterface(piInterface);

            //Add the Endpoints to the endpoint collection
            piEndpoints = piInterface.Endpoints;
            piEndpoints.Add(m_piINEndpoint, varIndex);
            piEndpoints.Add(m_piOUTEndpoint, varIndex+1);

            piConfig = new SoftUSBConfiguration();
            ConfigureConfig(piConfig);

            piInterfaces = piConfig.Interfaces;
            piInterfaces.Add(piInterface, varIndex);

            piConfigurations = m_piSoftUSBDevice.Configurations;
            piConfigurations.Add(piConfig, varIndex);
        }

        /// <summary>
        /// Creates all the strings used by the device. These strings are
        /// added to the strings collection which is maintained by the USB device.
        /// </summary>
        private void CreateStrings()
        {
            SoftUSBStrings piStrings = null;
            SoftUSBString piStringManufacturer = null;
            SoftUSBString piStringProductDesc = null;
            SoftUSBString piStringConfig = null;
            SoftUSBString piStringEndpoint = null;

            string bstrManufacturer = "Microsoft Corporation";
            string bstrProductDesc = "Simulated Generic USB device";
            string bstrConfig = "Configuration with a single interface";
            string bstrEndpoint = "Interface with bulk IN endpoint and bulk OUT endpoint";

            piStrings = m_piSoftUSBDevice.Strings;

            piStringManufacturer = new SoftUSBString();
            piStringManufacturer.Value = bstrManufacturer;
            piStrings.Add(piStringManufacturer, STRING_IDX_MANUFACTURER);

            piStringProductDesc = new SoftUSBString();
            piStringProductDesc.Value = bstrProductDesc;
            piStrings.Add(piStringProductDesc, STRING_IDX_PRODUCT_DESC);

            piStringConfig = new SoftUSBString();
            piStringConfig.Value = bstrConfig;
            piStrings.Add(piStringConfig, STRING_IDX_CONFIG);

            piStringEndpoint = new SoftUSBString();
            piStringEndpoint.Value = bstrEndpoint;
            piStrings.Add(piStringEndpoint, STRING_IDX_INTERFACE);
        }

        /// <summary>
        /// Initializes the IN Endpoint interface 
        /// </summary>
        public void ConfigureINEndpoint()
        {
            if (m_piINEndpoint == null)
            {
                return;
            }
            else
            {
                m_piINEndpoint.EndpointAddress = 0x81;// Endpoint #1 IN 
                m_piINEndpoint.Attributes = 0x02;//Bulk data endpoint
                m_piINEndpoint.MaxPacketSize = 1024;
                m_piINEndpoint.Interval = 0;
                m_piINEndpoint.Halted = false;
            }
        }

        /// <summary>
        /// Initializes the OUT Endpoint interface  
        /// </summary>
        public void ConfigureOUTEndpoint()
        {
            if (m_piOUTEndpoint == null)
            {
                return;
            }
            else
            {
                m_piOUTEndpoint.EndpointAddress = 0x02;// Endpoint #1 IN 
                m_piOUTEndpoint.Attributes = 0x02;//Bulk data endpoint
                m_piOUTEndpoint.MaxPacketSize = 1024;
                m_piOUTEndpoint.Interval = 0;
                m_piOUTEndpoint.Halted = false;
            }
        }

        public void CreateUSBDevice()
        {
            SoftUSBDeviceQualifier piDeviceQual = new SoftUSBDeviceQualifier();

            m_piSoftUSBDevice = new SoftUSBDevice();
            //Setup the device qualifier
            piDeviceQual.USB = 0x0200;//binary coded decimal USB version 2.0
            piDeviceQual.DeviceClass = 0xff;//FF=Vendor specfic device class
            piDeviceQual.DeviceSubClass = 0xff;//FF = Vendor specific device sub-class
            piDeviceQual.DeviceProtocol = 0xff;//FF = Vendor specific device protocol
            piDeviceQual.MaxPacketSize0 = 64;//max packet size endpoint 0
            piDeviceQual.NumConfigurations = 1;//Number of configurations

            //Setup the device 
            m_piSoftUSBDevice.USB = 0x0200;
            m_piSoftUSBDevice.DeviceClass = 0xff;//FF=Vendor specfic device class
            m_piSoftUSBDevice.DeviceSubClass = 0xff;//FF = Vendor specific device sub-class
            m_piSoftUSBDevice.DeviceProtocol = 0xff;//FF = Vendor specific device protocol
            m_piSoftUSBDevice.MaxPacketSize0 = 64;//max packet size endpoint 0
            m_piSoftUSBDevice.Product = (short)usProductId;//product id - BulkUSB
            m_piSoftUSBDevice.Vendor = (short)usVendorId;//Vendor ID - Microsoft
            m_piSoftUSBDevice.Device = 0x0100;
            m_piSoftUSBDevice.RemoteWakeup = false;
            m_piSoftUSBDevice.Manufacturer = STRING_IDX_MANUFACTURER;
            m_piSoftUSBDevice.ProductDesc = STRING_IDX_PRODUCT_DESC;
            m_piSoftUSBDevice.HasExternalPower = true;
            CreateStrings();

            m_piSoftUSBDevice.DeviceQualifier = piDeviceQual;
        }

        /// <summary>
        /// Initialize the USB configuration data 
        /// </summary>
        /// <param name="piConfig">the SoftUSBCondiguration interface to be initialized</param>
        private void ConfigureConfig(ISoftUSBConfiguration piConfig)
        {
            piConfig.ConfigurationValue = 1;
            piConfig.Configuration = (byte)m_iConfigString;
            piConfig.MaxPower = 0;
        }

        /// <summary>
        /// Initialize the devices USB interface  
        /// </summary>
        /// <param name="piInterface">the device Interface interface</param>
        private void ConfigureInterface(ISoftUSBInterface piInterface)
        {
            piInterface.InterfaceNumber = 0;
            piInterface.AlternateSetting = 0;
            piInterface.InterfaceClass = 0xFF;//Vendor specific class code
            piInterface.InterfaceProtocol = 0xFF;//Vendor specific protcol
            piInterface.InterfaceSubClass = 0xFF;//Vendor specific sub class code

            //Index for string describing the interface
            piInterface.Interface = (byte)m_iInterfaceString;
        }

        public void InitMemberVariables()
        {
            throw new NotImplementedException();
        }

        /// <summary>
        /// Setup the connection point to the OUT Endpoint.It validates that 
        /// the punkObject supports IConnectionPointContainer then finds the 
        /// correct connection point and attaches this object as the event sink.
        /// </summary>
        /// <param name="usbEndpoint"></param>
        /// <param name="iidConnectionPoint"></param>
        public void SetupConnectionPoint(SoftUSBEndpoint usbEndpoint, ref Guid iidConnectionPoint)
        {
            IConnectionPointContainer piConnectionPointContainer = null;
            if (m_piConnectionPoint != null)
            {
                ReleaseConnectionPoint();
            }
            Guid guid = new Guid("B196B284-BAB4-101A-B69C-00AA00341D07");
            Type type = Type.GetTypeFromCLSID(guid);
            object comObj = Activator.CreateInstance(type);
            IntPtr punkSink = Marshal.GetIUnknownForObject(comObj);
            IntPtr pInterface;

            Marshal.QueryInterface(punkSink, ref guid, out pInterface);

            piConnectionPointContainer = (IConnectionPointContainer)comObj;

            piConnectionPointContainer.FindConnectionPoint(iidConnectionPoint, out m_piConnectionPoint);

            m_piConnectionPoint.Advise(punkSink, out m_dwConnectionCookie);
        }

        /// <summary>
        /// Release the connection point to the OUT Endpoint if one has been established.
        /// </summary>
        public void ReleaseConnectionPoint()
        {
            if (m_piConnectionPoint != null)
            {
                m_piConnectionPoint.Unadvise(m_dwConnectionCookie);
                m_dwConnectionCookie = 0;
            }
        }
    }
}
