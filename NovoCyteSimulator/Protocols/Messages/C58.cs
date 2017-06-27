using NovoCyteSimulator.Messages;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovoCyteSimulator.Protocols.Messages
{
    public enum AutoSamplerInfo
    {
        INFO_State = 0, // 读取 AutoSampler 状态信息
        INFO_ShakerHeight = 1, // 读取托盘/混匀器高度
        INFO_PlateHeight = 2,  // 读取 Plate 高度
        INFO_SIP2ResetPos = 3, //SIP 到混匀器复位距离(单位:mm)
        INFO_Moving = 0xff
    }

    public enum AutoSamplerState
    {
        AUTO_SAMPLER_INEXISTENCE = 0, // AutoSampler不存在
        AUTO_SAMPLER_DOOR_IS_OPENED = 1, // AutoSampler门打开
        AUTO_SAMPLER_STOP_RESET_POS = 2, // AutoSampler停在复位位置
        AUTO_SAMPLER_STOP_SET_POS = 3, // AutoSampler停止指定位置
        AUTO_SAMPLER_STOP_UNKNOWN = 4, // AutoSampler停止未知位置
        AUTO_SAMPLER_RUNNING = 5, // AutoSampler运行中
        AUTO_SAMPLER_SHAKING = 6, // AutoSampler震动中
        AUTO_SAMPLER_ADJUSTING = 7, // AutoSampler校准中
        AUTO_SAMPLER_ERROR = 8, // AutoSampler出错
        AUTO_SAMPLER_HEIGHT_CHECKING = 9, // AutoSampler高度检测中
        AUTO_SAMPLER_STAY_ZERO = 10, // AutoSampler 停在零位位置
    }

    public class C58 : CBase
    {
        private byte M;

        public C58()
        {
            this.Message = 0x58;
        }
        public override bool Decode(byte[] buf)
        {
            if (this.Decode(message, buf, out parameter))
            {
                this.M = parameter[0];
                return true;
            }
            else
            {
                return false;
            }
        }

        public override byte[] Encode()
        {
            byte[] param = CreateParam();
            return this.Encode(message, param);
        }

        private byte[] CreateParam()
        {
            byte[] param = new byte[] { };
            switch (M)
            {
                case (byte)AutoSamplerInfo.INFO_State:
                    param = new byte[6];
                    //test, need to do
                    param[0] = (byte)AutoSamplerState.AUTO_SAMPLER_INEXISTENCE;
                    param[1] = M;
                    param[2] = 0;
                    param[3] = 0;
                    param[4] = 0;
                    param[5] = 0;
                    break;
                case (byte)AutoSamplerInfo.INFO_ShakerHeight:
                    param = new byte[4];
                    param[0] = (byte)AutoSamplerState.AUTO_SAMPLER_INEXISTENCE;
                    param[1] = M;
                    param[2] = 0;
                    param[3] = 0;
                    break;
                case (byte)AutoSamplerInfo.INFO_PlateHeight:
                    param = new byte[4];
                    param[0] = (byte)AutoSamplerState.AUTO_SAMPLER_INEXISTENCE;
                    param[1] = M;
                    param[2] = 0;
                    param[3] = 0;
                    break;
                case (byte)AutoSamplerInfo.INFO_SIP2ResetPos:
                    break;

            }
            return param;
        }
    }
}
