using DSF;
using SOFTUSB;
using SoftUSBLoopbackLib;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Runtime.InteropServices.ComTypes;
using System.Text;
using System.Threading.Tasks;

namespace NovoCyteSimulator.USBSimulator
{
    public class USBDevice
    {
        private SoftUSBDevice m_piSoftUSBDevice; //Underlying SoftUSBDevice object

        public SoftUSBDevice SoftUSBDevice
        {
            get { return this.m_piSoftUSBDevice; }
        }
        private SoftUSBEndpoint m_piINEndpoint;       //IN Endpoint

        public SoftUSBEndpoint INEndpont
        {
            get { return this.m_piINEndpoint; }
        }

        private SoftUSBEndpoint m_piOUTEndpoint;      //OUT Endpoint

        public SoftUSBEndpoint OUTEndpoint
        {
            get { return this.m_piOUTEndpoint; }
        }
        //USB Product and Vendor ID
        private ushort usProductId = 0x930A;
        private ushort usVendorId = 0x045E;

        private byte STRING_IDX_MANUFACTURER = 1;
        private byte STRING_IDX_PRODUCT_DESC = 2;
        private byte STRING_IDX_CONFIG = 3;
        private byte STRING_IDX_INTERFACE = 4;

        private int m_iInterfaceString = 0;   //Index of interface identifier string
        private int m_iConfigString = 0;      //Index of config identifier string

        public const byte USB_ACK = 2;
        /// <summary>
        /// Create and config USB device
        /// </summary>
        public USBDevice()
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

            ConfigureDevice();

        }

        public void ConfigureDevice()
        {
            SoftUSBConfiguration piConfig = null;
            SoftUSBInterface piInterface = null;
            ISoftUSBInterfaces piInterfaces = null;
            ISoftUSBEndpoints piEndpoints = null;

            m_piINEndpoint = new SoftUSBEndpoint();
            ConfigureINEndpoint();

            m_piOUTEndpoint = new SoftUSBEndpoint();
            ConfigureOUTEndpoint();

            piInterface = new SoftUSBInterface();
            ConfigureInterface(piInterface);

            //Add the Endpoints to the endpoint collection
            piEndpoints = piInterface.Endpoints;
            piEndpoints.Add(m_piINEndpoint, 0);
            piEndpoints.Add(m_piOUTEndpoint, 1);

            piConfig = new SoftUSBConfiguration();
            ConfigureConfig(piConfig);

            piInterfaces = piConfig.Interfaces;
            piInterfaces.Add(piInterface, 0);

            m_piSoftUSBDevice.Configurations.Add(piConfig, 0);

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

        private IConnectionPoint m_piConnectionPoint;
        private int cookie = -1;     // The cookie for the connection
        private void SetupConnectionPoint()
        {
            IConnectionPointContainer piConnectionPointContainer = (IConnectionPointContainer)(m_piSoftUSBDevice);
            Guid guid = typeof(_ILoopbackDeviceEvents).GUID;
            piConnectionPointContainer.FindConnectionPoint(ref guid, out m_piConnectionPoint);
            m_piConnectionPoint.Advise(this, out cookie);
        }

    }
}
