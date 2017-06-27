using NovoCyteSimulator.Messages;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovoCyteSimulator.Protocols.Messages
{
    /// <summary>
    /// 启动、停止细胞采集命令
    /// </summary>
    public class C21 : CBase
    {
        private C78 _c78;//应答命令
        public C21()
        {
            this.message = 0x21;
        }

        public override bool Decode(byte[] buf)
        {
            if (this.Decode(message, buf, out parameter))
            {
                config.Device.Cell.StartStopCellCollection = parameter[0];
                config.Device.Cell.Version = parameter[1];
                config.Device.Cell.CleaningTimes = parameter[2];
                config.Device.Cell.TestSel = (Equipment.Device.TEST_Sel)parameter[3];
                _c78.M = this.message;
                return true;
            }
            else
            {
                return false;
            }
        }

        public override byte[] Encode()
        {
            return this._c78.Encode();
        }
    }
}
