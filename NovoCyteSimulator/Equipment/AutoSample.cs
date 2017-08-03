using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovoCyteSimulator.Equipment
{
    [Serializable]
    public class AutoSample
    {
        public enum AS_CONNECT_STATE_Type : int
        {
            CST_Nonexistent = 0, // AutoSampler 不存在
            CST_PowerUp, // NovoSampler 已连接,上电
            CST_PowerDown, // AutoSampler 已连接,断电
            CST_PowerUpPro // NovoSampler Pro已连接,上电
        };

        public AS_CONNECT_STATE_Type ConnectStateType;

        /* 公司名称 */
        public string CompanyName { set; get; }
        /* 仪器名称 */
        public string SystemName { set; get; }
        /* 仪器型号 */
        public string SystemType { set; get; }
        /* 仪器序列号 */
        public string SerialNumber { set; get; }
        /* 仪器生产日期 */
        public string ProductionDate { set; get; }
        /* Firmware版本 */
        public string FirmwareVersion { set; get; }
        /* Firmware 类型 */
        public string FirmwareType { set; get; }
        /* Firmware编译日期 */
        public string FirmwareBuildDate { set; get; }
        /* Hardware版本 */
        public string HardwareVersion { set; get; }
        /* PCB版本号 */
        public string PCBVersion { set; get; }
    }
}
