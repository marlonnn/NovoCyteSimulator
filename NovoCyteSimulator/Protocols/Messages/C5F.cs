using NovoCyteSimulator.Messages;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovoCyteSimulator.Protocols.Messages
{
    /// <summary>
    /// Weight 系统信息
    /// </summary>
    public class C5F : CBase
    {
        public enum WeightInfo : byte
        {
            /* 公司名称 */
            IDX_WEIGHT_COMPANY_NAME = 0x00,
            /* 仪器名称 */
            IDX_WEIGHT_SYSTEM_NAME = 0x01,
            /* 仪器型号 */
            IDX_WEIGHT_SYSTEM_TYPE = 0x02,
            /* 仪器序列号 */
            IDX_WEIGHT_SERIAL_NUMBER = 0x03,
            /* 仪器生产日期 */
            IDX_WEIGHT_PRODUCTION_DATE = 0x04,
            /* Firmware版本 */
            IDX_WEIGHT_FIRMWARE_VERSION = 0x05,
            /* Firmware 类型 */
            IDX_FIRMWARE_TYPE = 0x06,
            /* Firmware编译日期 */
            IDX_WEIGHT_FIRMWARE_BUILD_DATE = 0x07,
            /* Hardware版本 */
            IDX_WEIGHT_HARDWARE_VERSION = 0x08,
            /* PCB版本号 */
            IDX_WEIGHT_PCB_VERSION = 0x09
        }

        public byte Y { set; get; }

        public byte[] Y1 { set; get; }

        public C5F(byte message)
        {
            this.message = message;
        }

        private void CreateAutoSampleInfo()
        {
            string autoSampleInfo = "";
            switch (Y)
            {
                case (byte)WeightInfo.IDX_WEIGHT_COMPANY_NAME:
                    autoSampleInfo = config.Weight.CompanyName;
                    break;
                case (byte)WeightInfo.IDX_WEIGHT_SYSTEM_NAME:
                    autoSampleInfo = config.Weight.SystemName;
                    break;
                case (byte)WeightInfo.IDX_WEIGHT_SYSTEM_TYPE:
                    autoSampleInfo = config.Weight.SystemType;
                    break;
                case (byte)WeightInfo.IDX_WEIGHT_SERIAL_NUMBER:
                    autoSampleInfo = config.Weight.SerialNumber;
                    break;
                case (byte)WeightInfo.IDX_WEIGHT_PRODUCTION_DATE:
                    autoSampleInfo = config.Weight.ProductionDate;
                    break;
                case (byte)WeightInfo.IDX_WEIGHT_FIRMWARE_VERSION:
                    autoSampleInfo = config.Weight.FirmwareVersion;
                    break;
                case (byte)WeightInfo.IDX_FIRMWARE_TYPE:
                    autoSampleInfo = config.Weight.FirmwareType;
                    break;
                case (byte)WeightInfo.IDX_WEIGHT_FIRMWARE_BUILD_DATE:
                    autoSampleInfo = config.Weight.FirmwareBuildDate;
                    break;
                case (byte)WeightInfo.IDX_WEIGHT_HARDWARE_VERSION:
                    autoSampleInfo = config.Weight.HardwareVersion;
                    break;
                case (byte)WeightInfo.IDX_WEIGHT_PCB_VERSION:
                    autoSampleInfo = config.Weight.PCBVersion;
                    break;
            }
            Y1 = Encoding.Default.GetBytes(autoSampleInfo);
        }

        private byte[] CreateParam()
        {
            CreateAutoSampleInfo();
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
