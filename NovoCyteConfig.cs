using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace NovoCyteSimulator
{
    [Serializable]
    public class NovoCyteConfig
    {
        public Config Config { get; set; }
        public NovoCyteConfig(Config Config)
        {
            this.Config = Config;
        }
    }

    [Serializable]
    public class Config
    {
        /// <summary>
        /// 通道触发激光器
        /// </summary>
        public int[] ChLx { get; set; }

        /// <summary>
        /// 通道滤光片
        /// </summary>
        public int[] ChFx { get; set; }

        /// <summary>
        /// 荧光触发相关参数
        /// </summary>
        public Mxd Mxd { get; set; }

        /// <summary>
        /// PMT相关参数
        /// </summary>
        public PMT PMT { get; set; }

        public Mon1 Mon1 { get; set; }

        public Mon2 Mon2 { get; set; }

        public Mon3 Mon3 { get; set; }

        /// <summary>
        /// laser相关配置参数 Laser[0], Laser[1], Laser[2], Laser[3]分别对应Laser1, Laser2, Laser3, Laser4
        /// </summary>
        public LaserParas[] Laser { get; set; }

        public SystemInfo SystemInfo { get; set; }

        public Config()
        {
            ChLx = new int[32];
            ChFx = new int[32];
        }
    }

    [Serializable]
    public class Mxd
    {
        public Mxd_X A { get; set; }
    }

    [Serializable]
    public class Mxd_X
    {
        /// <summary>
        /// WPos[0], WPos[1], WPos[2], WPos[3]分别为相对于L1, L2, L3, L4触发的窗口位置
        /// WPos[X][0]: L1, WPos[X][1]: L2, WPos[X][2]: L3, WPos[X][3]: L4
        /// </summary>
        public List<int[]> WPos { get; set; }

        /// <summary>
        /// WDelta[0], WDelta[1], WDelta[2], WDelta[3]分别为相对于L1, L2, L3, L4触发的窗口拓宽点数
        /// WDelta[X][0]: PD, WDelta[X][1]: L2, WDelta[X][2]: Lx
        /// </summary>
        public List<int[]> WDelta { get; set; }

        /// <summary>
        /// Threshold[0]: FSC或SSC触发时识别门限, Threshold[1]: 荧光触发时识别门限
        /// Threshold[X][0]:WCT, Threshold[X][1]:DT
        /// </summary>
        public List<int[]> Threshold { get; set; }
    }

    [Serializable]
    public class PMT
    {
        /// <summary>
        /// PMT选择码位,bitx对应PMTx使能,0表示未选择,1表示选择
        /// </summary>
        public uint MaskSel { get; set; }

        /// <summary>
        /// SBoard-1 PMT电压
        /// </summary>
        public float[] Voltage1 { get; set; }

        /// <summary>
        /// SBoard-2 PMT电压
        /// </summary>
        public float[] Voltage2 { get; set; }

        /// <summary>
        /// SBoard-3 PMT电压
        /// </summary>
        public float[] Voltage3 { get; set; }

        /// <summary>
        /// SBoard-4 PMT电压
        /// </summary>
        public float[] Voltage4 { get; set; }
    }

    [Serializable]
    public class Mon1
    {
        public int Number { get; set; }
        public Mon1_Threshold Threshold { get; set; }
        public Mon1_Scale Scale { get; set; }
    }

    [Serializable]
    public class Mon1_Threshold
    {
        public ThresholdCheck U1 { get; set; }
        public ThresholdCheck U2 { get; set; }
        public ThresholdCheck U3 { get; set; }
        public ThresholdCheck U4 { get; set; }
        public ThresholdCheck U5 { get; set; }
        public ThresholdCheck U6 { get; set; }
        public ThresholdCheck U7 { get; set; }
        public ThresholdCheck U8 { get; set; }
        public ThresholdCheck U9 { get; set; }
        public ThresholdCheck U10 { get; set; }
        public ThresholdCheck U11 { get; set; }
        public ThresholdCheck U12 { get; set; }
        public ThresholdCheck U13 { get; set; }
        public ThresholdCheck U14 { get; set; }
        public ThresholdCheck U15 { get; set; }
        public ThresholdCheck U16 { get; set; }
        public ThresholdCheck U17 { get; set; }
        public ThresholdCheck U18 { get; set; }
        public ThresholdCheck U19 { get; set; }
        public ThresholdCheck U20 { get; set; }
        public ThresholdCheck U21 { get; set; }
        public ThresholdCheck U22 { get; set; }
        public ThresholdCheck U23 { get; set; }
        public ThresholdCheck U24 { get; set; }
        public ThresholdCheck U25 { get; set; }
        public ThresholdCheck U26 { get; set; }
        public ThresholdCheck U27 { get; set; }
        public ThresholdCheck U28 { get; set; }
        public ThresholdCheck U29 { get; set; }
        public ThresholdCheck U30 { get; set; }
        public ThresholdCheck U31 { get; set; }
    }

    [Serializable]
    public class Scale
    {
        public float K { get; set; }
        public int B { get; set; }
    }

    [Serializable]
    public class Mon1_Scale
    {
        public Scale U1 { get; set; }

        public Scale U2 { get; set; }

        public Scale U3 { get; set; }

        public Scale U4 { get; set; }

        public Scale U5 { get; set; }

        public Scale U6 { get; set; }

        public Scale U7 { get; set; }

        public Scale U8 { get; set; }

        public Scale U9 { get; set; }

        public Scale U10 { get; set; }

        public Scale U11 { get; set; }

        public Scale U12 { get; set; }

        public Scale U13 { get; set; }

        public Scale U14 { get; set; }

        public Scale U15 { get; set; }

        public Scale U16 { get; set; }

        public Scale U17 { get; set; }

        public Scale U18 { get; set; }

        public Scale U19 { get; set; }

        public Scale U20 { get; set; }

        public Scale U21 { get; set; }

        public Scale U22 { get; set; }

        public Scale U23 { get; set; }

        public Scale U24 { get; set; }

        public Scale U25 { get; set; }

        public Scale U26 { get; set; }

        public Scale U27 { get; set; }

        public Scale U28 { get; set; }

        public Scale U29 { get; set; }

        public Scale U30 { get; set; }

        public Scale U31 { get; set; }
    }

    [Serializable]
    public class Mon2_Scale
    {
        /// <summary>
        /// 压力传感器1转换系数
        /// </summary>
        public Scale P1 { get; set; }

        /// <summary>
        /// 压力传感器2转换系数
        /// </summary>
        public Scale P2 { get; set; }

        /// <summary>
        /// 压力传感器3转换系数
        /// </summary>
        public Scale P3 { get; set; }

        /// <summary>
        /// 压力传感器4转换系数
        /// </summary>
        public Scale P4 { get; set; }

        public Scale U1 { get; set; }

        public Scale U2 { get; set; }

        public Scale U3 { get; set; }

        public Scale U4 { get; set; }
    }

    [Serializable]
    public class Mon2
    {
        public int Number { get; set; }
        public string Threshold { get; set; }
        public Mon2_Scale Scale { get; set; }
    }

    [Serializable]
    public class ThresholdPara
    {
        public bool IsChk { get; set; }
        public float[] Value { get; set; }
    }

    [Serializable]
    public class ThresholdCheck
    {
        public ThresholdPara high { get; set; }
        public ThresholdPara low { get; set; }
    }

    [Serializable]
    public class Mon3_Threshold
    {
        /// <summary>
        /// 废液的警告和错误门限
        /// </summary>
        public ThresholdCheck Waste { get; set; }

        /// <summary>
        /// NovoRinse的警告和错误门限
        /// </summary>
        public ThresholdCheck NovoRinse { get; set; }

        /// <summary>
        /// NovoSheath的警告和错误门限
        /// </summary>
        public ThresholdCheck NovoSheath { get; set; }

        /// <summary>
        /// NovoClean的警告和错误门限
        /// </summary>
        public ThresholdCheck NovoClean { get; set; }
    }

    [Serializable]
    public class Mon3_Scale
    {
        /// <summary>
        /// 废液的转换系数
        /// </summary>
        public Scale Waste { get; set; }

        /// <summary>
        /// NovoRinse的转换系数
        /// </summary>
        public Scale NovoRinse { get; set; }

        /// <summary>
        /// NovoSheath的转换系数
        /// </summary>
        public Scale NovoSheath { get; set; }

        /// <summary>
        /// NovoClean的转换系数
        /// </summary>
        public Scale NovoClean { get; set; }
    }

    [Serializable]
    public class Mon3
    {
        public int Number { get; set; }
        public Mon3_Threshold Threshold { get; set; }
        public Mon3_Scale Scale { get; set; }
    }

    [Serializable]
    public class LaserParas
    {
        /// <summary>
        /// // 激光器类型
        /// </summary>
        public string Typeis { get; set; }

        /// <summary>
        /// 开机是否自动出光
        /// </summary>
        public bool AutoStart { get; set; }

        /// <summary>
        /// 模式,取值为"CWC"、"CWP"、"DIGITAL"、"ANALOG"、"MIXED"
        /// </summary>
        public string Mode { get; set; }

        /// <summary>
        /// 输出功率,单位:mW
        /// </summary>
        public float Power { get; set; }
    }

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
