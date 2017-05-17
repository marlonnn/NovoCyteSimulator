using NovoCyteSimulator.Messages;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovoCyteSimulator.Protocols.Messages
{
    //读取系统信息
    public class C01 : CBase
    {
        public enum SYSTEMINFO : byte
        {
            /* 公司名称 */
            IDX_COMPANY_NAME = 0x00,
            /* 仪器名称 */
            IDX_SYSTEM_NAME = 0x01,
            /* 仪器型号 */
            IDX_SYSTEMTYPE = 0x02,
            /* 仪器序列号 */
            IDX_SERIAL_NUMBER = 0x03,
            /* 仪器生产日期 */
            IDX_PRODUCTION_DATE = 0x04,
            /* FPGA版本 */
            IDX_FPGA_FIRMWARE_VERSION = 0x05,
            /* SYSTEM Firmware版本 */
            IDX_SYSTEM_FIRMWARE_VERSION = 0x06,
            /* 仪器NIOS-II Firmware版本号 */
            IDX_NIOS_FIRMWARE_VERSION = 0x07,
            /* Nios-II Firmware type */
            IDX_FIRMWARE_TYPE = 0x08,
            /* Nios-II Firmware编译日期 */
            IDX_NIOS_FIRMWARE_BUILD_DATE = 0x09,
            /* Hardware版本 */
            IDX_HARDWARE_VERSION = 0x0A,
            /* PCB版本号 */
            IDX_PCB_VERSION = 0x0B,
            /* 流体时序版本 */
            IDX_FLUID_TIMING_VERSION = 0x0C,
            /* 主板序列号 */
            IDX_PCB_SN = 0x0D,
            /* 副版本号 */
            IDX_PART_FIRMWARE_VERSION = 0x0E
        }

        public byte Y { set; get; }

        public byte[] Y1 { set; get; }

        public C01(byte message)
        {
            this.message = message;
        }

        private void CreateSystemInfo()
        {
            string infomation = "";
            switch (Y)
            {
                case (byte)SYSTEMINFO.IDX_COMPANY_NAME:
                    infomation = config.SystemInfo.CompanyName;
                    break;
                case (byte)SYSTEMINFO.IDX_SYSTEMTYPE:
                    infomation = config.SystemInfo.SystemType;
                    break;
                case (byte)SYSTEMINFO.IDX_SERIAL_NUMBER:
                    infomation = config.SystemInfo.SerialNumber;
                    break;
                case (byte)SYSTEMINFO.IDX_PRODUCTION_DATE:
                    infomation = config.SystemInfo.ProductionDate;
                    break;
                case (byte)SYSTEMINFO.IDX_NIOS_FIRMWARE_VERSION:
                    infomation = config.SystemInfo.NIOSFirmwareVersion;
                    break;
                case (byte)SYSTEMINFO.IDX_FIRMWARE_TYPE:
                    infomation = config.SystemInfo.NIOSFirmwareType;
                    break;
                case (byte)SYSTEMINFO.IDX_FPGA_FIRMWARE_VERSION:
                    infomation = config.SystemInfo.FPGAFirmwareVersion;
                    break;
                case (byte)SYSTEMINFO.IDX_SYSTEM_FIRMWARE_VERSION:
                    infomation = config.SystemInfo.SystemFirmwareVersion;
                    break;
                case (byte)SYSTEMINFO.IDX_HARDWARE_VERSION:
                    infomation = config.SystemInfo.HardwareVersion;
                    break;
                case (byte)SYSTEMINFO.IDX_PCB_VERSION:
                    infomation = config.SystemInfo.PCBVersion;
                    break;
                case (byte)SYSTEMINFO.IDX_SYSTEM_NAME:
                    infomation = config.SystemInfo.SystemName;
                    break;
                case (byte)SYSTEMINFO.IDX_NIOS_FIRMWARE_BUILD_DATE:
                    infomation = config.SystemInfo.NIOSFirmwareBulidDate;
                    break;
                case (byte)SYSTEMINFO.IDX_FLUID_TIMING_VERSION:
                    infomation = config.SystemInfo.FluidTimingVersion;
                    break;
                case (byte)SYSTEMINFO.IDX_PCB_SN:
                    infomation = config.SystemInfo.PCBSN;
                    break;
                case (byte)SYSTEMINFO.IDX_PART_FIRMWARE_VERSION:
                    infomation = config.SystemInfo.PartFirmwareVersion;
                    break;
                default:
                    break;
            }
            Y1 = Encoding.Default.GetBytes(infomation);
        }

        private byte[] CreateParam()
        {
            CreateSystemInfo();
            byte[] param = new byte[1 + Y1.Length + 1];//最后一位为‘\0’结束标志00

            param[0] = Y;
            Array.Copy(Y1, 0, param, 1, Y1.Length);

            return param;
        }

        public override bool Decode(byte[] buf)
        {
            if (!this.Decode(message, buf, out parameter))
            {
                return false;
            }
            else
            {
                Y = parameter[0];
                return true;
            }
        }

        public override byte[] Encode()
        {
            byte[] param = CreateParam();
            return this.Encode(message, param);
        }
    }
}
