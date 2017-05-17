using NovoCyteSimulator.Messages;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovoCyteSimulator.Protocols.Messages
{
    /// <summary>
    /// 细胞采集参数设置命令
    /// </summary>
    public class C20 : CBase
    {
        private C78 _c78;//应答命令

        public C20(byte message)
        {
            this.message = message;
        }

        public override bool Decode(byte[] buf)
        {
            if (this.Decode(message, buf, out parameter))
            {
                config.Device.Cell.Time = BitConverter.ToUInt16(parameter, 0);
                config.Device.Cell.Points = BitConverter.ToUInt32(parameter, 2);
                config.Device.Cell.Size = BitConverter.ToUInt16(parameter, 6);
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
