using NovoCyteSimulator.Messages;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovoCyteSimulator.Protocols.Messages
{
    public enum SleepType
    {
        ExitSleep = 0, // 退出休眠
        ClearTime = 1 // 清除休眠计时时间
    };
    public class C2D : CBase
    {
        private C78 _c78;//应答命令

        public SleepType SleepType;

        public delegate void UpdateState();

        public UpdateState UpdateStateHandler;

        public C2D()
        {
            this.message = 0x2D;
            SleepType = SleepType.ExitSleep;
        }

        public override bool Decode(byte[] buf)
        {
            if (this.Decode(message, buf, out parameter))
            {
                byte cmdType = parameter[0];
                _c78.R = 0x01;
                _c78.M = this.message;
                SleepType = GetSleepType(cmdType);
                return true;
            }
            else
            {
                return false;
            }
        }

        private SleepType GetSleepType(byte type)
        {
            SleepType sleepType = SleepType.ExitSleep;
            if (type == 0)
            {
                sleepType = SleepType.ExitSleep;
                UpdateStateHandler?.Invoke();
            }
            else if (type == 1)
            {
                sleepType = SleepType.ClearTime;
            }
            return sleepType;
        }

        public override byte[] Encode()
        {
            return this._c78.Encode();
        }
    }
}
