using NovoCyteSimulator.Messages;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovoCyteSimulator.Protocols.Messages
{
    public class C78 : CBase
    {
        public byte M { set; get; } //上位发来的命令
        public byte R { set; get; } //0 不接收,1 接收

        public C78(byte message)
        {
            this.message = message;
        }

        public override bool Decode(byte[] buf)
        {
            throw new NotImplementedException();
        }

        public override byte[] Encode()
        {
            byte[] param = new byte[2];
            param[0] = M;
            param[1] = R;
            return this.Encode(message, param);
        }
    }
}
