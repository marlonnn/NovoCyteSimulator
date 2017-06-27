using NovoCyteSimulator.Messages;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovoCyteSimulator.Protocols.Messages
{
    public enum PARA_TYPE : byte
    {
        TYPE_PmtGain = 1,   // PMT Gain 
        TYPE_WindowPara = 2,   // Window parameter 
        TYPE_SensorCoef = 3,    // Sensor Coef 
        TYPE_LaserPara = 4,   // Laser参数 
        TYPE_PMTCfg = 5,   // PMT配置 
        TYPE_PeriPumpOmega = 6,    // 蠕动泵转速 
        TYPE_SP_DST = 7, // 加样针下降圈数
        TYPE_ExtWindowParam = 8, // 窗口位置和扩展
        TYPE_ExtDmlParam = 9, // 解调参数
        TYPE_InjectorParam = 10, // 注射泵配置参数
        TYPE_InitialFluxPare = 11, //标准流量
        TYPE_ModemTblCfg = 12, // 调制解调表配置
        TYPE_CompensationParam = 13,// 补偿相关参数
        TYPE_UpdateIsLock = 14, // 读升级锁(仅 0xEC 命令有效)
        TYPE_SWAutoResumP = 15, // 压力是否自动释放
        TYPE_RecordForSoftware = 16,// 用于软件记录数据读取
        TYPE_ExtCompensationParam = 0x11, // 新补偿参数
        TYPE_ChannelSelect = 0x12, // 通道选择(通道是否启用)
        TYPE_LaserFilterAndMirrorInfo = 0x13, // 分光镜以及滤光片信息
    }

    /// <summary>
    /// 设置参数
    /// </summary>
    public class CEB : CBase
    {
        public byte Type { set; get; }
        private C78 _c78;

        public CEB()
        {
            this.message = 0xEB;
        }

        public override bool Decode(byte[] buf)
        {
            if (this.Decode(message, buf, out parameter))
            {
                Type = parameter[0];
                _c78.M = this.message;
                return true;
            }
            else
            {
                return false;
            }
        }

        public void Decode()
        {
            switch (Type)
            {
                case (byte)PARA_TYPE.TYPE_PmtGain:
                    for (int i = 1; i <= 8; i++)
                    {
                        byte[] voltageBytes = new byte[4];
                        Array.Copy(parameter, i * 4, voltageBytes, 0, 4);
                        float voltage = BitConverter.ToSingle(voltageBytes, 0);
                        config.Device.PMT.Voltage[i- 1] = voltage;
                    }
                    break;
                case (byte)PARA_TYPE.TYPE_LaserPara:
                    //for (int i = 0; i < 3; i++)
                    //{
                    //    byte[] laserCfg = new byte[5];
                    //    Array.Copy(parameter, i * 5, laserCfg, 0, 5);
                    //}
                    break;

                case (byte)PARA_TYPE.TYPE_PMTCfg:
                    byte MaskSel = parameter[1];
                    config.Device.PMT.MaskSel = MaskSel;
                    break;
            }
        }

        public override byte[] Encode()
        {
            return this._c78.Encode();
        }
    }
}
