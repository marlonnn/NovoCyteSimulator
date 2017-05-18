using NovoCyteSimulator.Messages;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovoCyteSimulator.Protocols.Messages
{
    public class C14 : CBase
    {
        public byte Type { set; get; }
        private C78 _c78;

        public C14(byte message)
        {
            this.message = message;
        }

        public override bool Decode(byte[] buf)
        {
            if (this.Decode(message, buf, out parameter))
            {
                Type = parameter[0];
                _c78.R = 0x01;
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
