using NovoCyteSimulator.Messages;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovoCyteSimulator.Protocols.Messages
{
    public enum LaserWorkMode
    {
        Invalid = 0,
        StandBy = 1,
        Emission = 2
    }

    public enum LaserWorkState
    {
        Unknow = 0,
        Sleep = 1,
        SleepToStandBy = 2,
        StandBy = 3,
        StandByToRunning = 4,
        Running = 5
    }

    public class C64 : CBase
    {
        private bool AutoSleep
        {
            get;
            set;
        }

        private LaserWorkMode l1c;
        private LaserWorkMode l2c;
        private LaserWorkMode l3c;
        public C64()
        {
            this.message = 0x64;
        }

        public override bool Decode(byte[] buf)
        {
            if (this.Decode(message, buf, out parameter))
            {
                AutoSleep = parameter[0] == 1 ? true : false;
                l1c = (LaserWorkMode)parameter[1];
                l2c = (LaserWorkMode)parameter[2];
                l3c = (LaserWorkMode)parameter[3];
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

        public byte[] CreateParam()
        {
            byte[] param = new byte[3];
            for (int i = 0; i <= 2; i++)
            {
                param[i] = 0x03;
            }
            return param;
        }
    }
}
