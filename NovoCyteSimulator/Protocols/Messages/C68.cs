using NovoCyteSimulator.Messages;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovoCyteSimulator.Protocols.Messages
{
    public class C68 : CBase
    {
        public C68()
        {
            this.message = 0x68;
        }

        public override bool Decode(byte[] buf)
        {
            return this.Decode(message, buf, out parameter);
        }

        public override byte[] Encode()
        {
            byte[] param = new byte[8];
            return this.Encode(message, param);
        }
    }
}
