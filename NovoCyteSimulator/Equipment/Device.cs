using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovoCyteSimulator.Equipment
{
    /// <summary>
    /// 下位机
    /// </summary>
    [Serializable]
    public class Device
    {
        // 仪器处在的模式
        public enum ESystemMainWorkMode : int
        {
            WM_PowerUpInit = 1, // 系统开机初始化
            WM_Idle = 2, // 待机中
            WM_Testing = 3, // 测试中
            WM_FlowMaintenance = 4, // 液路维护中
            WM_Debug = 5, // 调试模式中
            WM_ErrorHandle = 6, // 错误处理中
            WM_MotorRunning = 7, // 电机运动中
            WM_Sleep = 8, // 休眠中
            WM_ShutDown = 9, // 关机中
            WM_FirstPriming = 10, // 第一次灌注
            WM_Drain = 11, // 排空
            WM_SleepEnter = 12, // 进入休眠
            WM_SleepQuit = 13, // 退出休眠
            WM_Decontamination = 14, // 消毒
            //>>>>>以下用于intellicyt iQue
            iQue_WM_Initialization = WM_PowerUpInit,
            iQue_WM_StandBy = WM_Idle,
            iQue_WM_DataAcquisition = WM_Testing,
            iQue_WM_FluidicsMaintenance = WM_FlowMaintenance,
            iQue_WM_ErrorHandling = WM_ErrorHandle,
            iQue_WM_ShuttingDown = WM_ShutDown,
            iQue_WM_InstallationPriming = WM_FirstPriming,
            iQue_WM_PurgeFluidicSystem = WM_Drain,
            iQue_WM_SuppyFluidics = 0x80 // 提供鞘液
        }

        //仪器状态
        public enum EMeasState : int
        {
            MEAS_UNKNOWN = 0, // 未知过程
            MEAS_BOOSTING = 1, // boosting过程
            MEAS_TESTING = 2, // testing过程
            MEAS_WASHING = 3, // washing过程
            MEAS_RESET = 4 // reset过程
        }

        //维护方式
        public enum EFlowMaintainMode : byte
        {
            MODE_STOP_MAINTAIN = 0, // 停止维护—预留
            MODE_DEBUBBLE = 1, // 排气泡
            MODE_DECONTAMINATION = 2, // 消毒
            MODE_NORMAL_CLEANING = 3, // 正常清洗
            MODE_EXT_CLEANING = 4, // 强化清洗
            MODE_PRIMING = 5, // 灌注
            MODE_UNCLOG = 6, // 消除堵塞
            MODE_BACKFLUSH = 7, // 反冲
            //>>>>>以下用于intellicyt
            ICYT_MODE_DailyClean = 0x80,
            ICYT_MODE_QuickClean = 0x81,
            ICYT_MODE_LongClean = 0x82,
            ICYT_MODE_Unclog = 0x83,
            ICYT_MODE_Debubble = 0x84,
            ICYT_MODE_Priming = 0x85,
            //>>>>>以下用于iQue QC工装
            ICYT_MODE_Drain = 0xF8
        }

        //QC状态
        public enum QC_StateType : byte
        {
            QC_StateInactive = 0, // 系统不在QC状态
            QC_StateAutoActive = 1, // 系统处在QC状态(自动设置状态)
            QC_StateHandActive = 2 // 系统处在QC状态(手动设置状态)
        }

        //子状态
        public enum EBoostingState : int
        {
            BOOSTING_Step1 = 0, // AutoSampler不能混匀
            BOOSTING_Step2 = 1 // AutoSampler可以混匀
        }

        //子状态
        public enum ETestingState : int
        {
            TESTING_StepNormal = 0, // 正常数据采集阶段
            TESTING_StepExt1 = 1, // boosting扩展采集阶段
            TESTING_StepExt2 = 2 // washing扩展采集阶段
        }

        //流体车类型
        public enum WEIGHT_Type : byte
        {
            WEIGHT_None = 0, // Connect weight type: None
            WEIGHT_Sensor = 1, // Connect weight type: Sensor
            WEIGHT_Arm = 2, // Connect weight type: ARM
        }

        //测试方式选择
        public enum TEST_Sel : byte
        {
            TEST_Normal = 0, // Normal
            TEST_PID = 1 // With PID
        }

        //C03相关 系统支持功能
        public enum CheckFunction : byte
        {
            Has_Query = 0,              // 查询所有支持功能
            Has_FT = 1,                 // 荧光触发 
            Has_PID = 2,                // PID功能
            Has_AutoResumePressure = 3, // 压力自动恢复
            Has_ShutWithCleanSIP = 4,   // 关机清洁样本针
            Has_HeightCheck = 5,        // 托盘及Plate高度检测
            Mod1us = 6,                // 节拍为1us
            Has_FMIPump = 7,             // 使用PMI泵
            Has_Decontaminate = 8,      //消毒功能
            Has_AdjustThresholdRealTime = 9,      //采集时调节阈值
            Has_FLChannelCount = 10,         // C22 荧光通道个数，不支持则为默认 13
        }

        //仪器所处模式
        public ESystemMainWorkMode SystemMainWorkMode { get; set; }

        public Dictionary<string, ESystemMainWorkMode> SystemWorkModeIntervalDic { get; set; }

        //C03系统支持功能
        public Dictionary<CheckFunction, bool> SystemFunctionDic { get; set; }

        //仪器状态 
        public EMeasState MeasState { get; set; }

        //维护方式
        public EFlowMaintainMode FlowMaintainMode { get; set; }

        //警告个数
        public short WarningNumber { get; set; }

        // 错误个数
        public short ErrorNumber { get; set; }

        //开始测试时间(单位：ms)
        public int StartTime { get; set; }

        //测试样本量(单位：uL)
        public float TestSampleSize { get; set; }

        //重力传感器检测是否使能(0：关闭，1：开启)
        public byte GravitySensorDetectionEnable { get; set; }

        //流程执行的节拍数
        public int Ticks { get; set; }

        //流程执行的总节拍数
        public int TotalTicks { get; set; }

        //AutoSampler联机状态
        public AutoSample.AS_CONNECT_STATE_Type AutoSampleConnectStateType { get; set; }

        //QC状态
        public QC_StateType QCStateType { get; set; }

        //子状态
        public EBoostingState BoostingState { get; set; }

        //子状态
        public ETestingState TestingState { get; set; }

        //流体车类型
        public WEIGHT_Type WeightType { get; set; }

        /// <summary>
        /// PMT相关参数
        /// </summary>
        public PMT PMT { get; set; }

        /// <summary>
        /// laser相关配置参数 Laser[0], Laser[1], Laser[2], Laser[3]分别对应Laser1, Laser2, Laser3, Laser4
        /// </summary>
        public LaserParas[] Laser { get; set; }

        /// <summary>
        /// 细胞采集相关参数设置
        /// </summary>
        public Cell Cell { get; set; }

    }

    public class Cell
    {
        /// <summary>
        /// 表示细胞采集时间(单位为秒)，为 0时表示采集时间不受限制，采集结束由细胞采集点数决定
        /// </summary>
        public ushort Time { set; get; }
        /// <summary>
        /// —表示细胞采集点数，为 0时表示采集点数不受限制，采集结束由细胞采集时间决定；
        /// </summary>
        public uint Points { set; get; }

        /// <summary>
        /// volume limits, 0 indicate no volume limits
        /// </summary>
        public ushort Size { set; get; }

        /// <summary>
        /// 开始/停止细胞采集控制，0：停止，1：开始
        /// </summary>
        public byte StartStopCellCollection { set; get; }

        /// <summary>
        /// 采集版本 0：debug版本， 1 ：Release版本
        /// </summary>
        public byte Version { set; get; }

        /// <summary>
        /// 测试完成后清洗次数
        /// </summary>
        public byte CleaningTimes { set; get; }

        /// <summary>
        /// 测试方式选择取值
        /// </summary>
        public Device.TEST_Sel TestSel { set; get; }

        /// <summary>
        /// 样本密度(单位：个/uL，个每微升)
        /// </summary>
        public ushort SampleDensity { set; get; }

        /// <summary>
        /// 样本流速(单位：uL/min，微升每分钟)
        /// </summary>
        public ushort SampleVelocity { set; get; }
    }
}
