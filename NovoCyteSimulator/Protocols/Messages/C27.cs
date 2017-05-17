using NovoCyteSimulator.Messages;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovoCyteSimulator.Protocols.Messages
{
    public class C27 : CBase
    {
        private C78 _c78;//应答命令
        public C27(byte message)
        {
            this.message = message;
        }

        public override bool Decode(byte[] buf)
        {
            if (this.Decode(message, buf, out parameter))
            {
                //清洗次数
                config.Device.Cell.CleaningTimes = parameter[0];
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
