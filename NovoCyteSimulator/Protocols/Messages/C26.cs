using NovoCyteSimulator.Messages;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovoCyteSimulator.Protocols.Messages
{
    /// <summary>
    /// 细胞采集触发门限
    /// </summary>
    public class C26 : CBase
    {
        private C78 _c78;//应答命令
        public C26(byte message)
        {
            this.message = message;
        }

        public override bool Decode(byte[] buf)
        {
            if (this.Decode(message, buf, out parameter))
            {
                //To do

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
