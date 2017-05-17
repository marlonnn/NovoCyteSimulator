using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovoCyteSimulator.Equipment
{
    [Serializable]
    public class SystemInfo
    {
        /* 公司名称 */
        public string CompanyName { get; set; }
        /* 仪器名称 */
        public string SystemName { get; set; }
        /* 仪器型号 */
        public string SystemType { get; set; }
        /* 仪器序列号 */
        public string SerialNumber { get; set; }
        /* 仪器生产日期 */
        public string ProductionDate { get; set; }
        /* FPGA版本 */
        public string FPGAFirmwareVersion { get; set; }
        /* System Firmware版本 */
        public string SystemFirmwareVersion { get; set; }
        /* 仪器NIOS-II Firmware版本号 */
        public string NIOSFirmwareVersion { get; set; }
        /* Firmware 类型 */
        public string NIOSFirmwareType { get; set; }
        /* Nios-II Firmware编译日期 */
        public string NIOSFirmwareBulidDate { get; set; }
        /* Hardware版本 */
        public string HardwareVersion { get; set; }
        /* PCB版本号 */
        public string PCBVersion { get; set; }
        /* 流体时序版本 */
        public string FluidTimingVersion { get; set; }
        /* 主板序列号 */
        public string PCBSN { get; set; }
        /* 副版本号 */
        public string PartFirmwareVersion { get; set; }
    }
}
