using NovoCyteSimulator.Messages;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovoCyteSimulator.Protocols.Messages
{
    public class C18 : CBase
    {
        public C18()
        {
            this.message = 0x18;
        }

        public override bool Decode(byte[] buf)
        {
            return this.Decode(message, buf, out parameter);
        }

        public override byte[] Encode()
        {
            //TO DO
            throw new NotImplementedException();
        }
    }
}
