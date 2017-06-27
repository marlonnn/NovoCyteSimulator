using NovoCyteSimulator.Messages;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovoCyteSimulator.Protocols.Messages
{
    /// <summary>
    /// 读取当前细胞密度、样本流速
    /// </summary>
    public class C25 : CBase
    {
        public C25()
        {
            this.message = 0x25;
        }

        public override bool Decode(byte[] buf)
        {
            return (this.Decode(message, buf, out parameter));
        }

        public override byte[] Encode()
        {
            byte[] param = new byte[4];
            //样本密度(单位：个/uL，个每微升)
            param[0] = (byte)(config.Device.Cell.SampleDensity);
            param[1] = (byte)(config.Device.Cell.SampleDensity >> 8);

            //样本流速(单位：uL/min，微升每分钟)
            param[3] = (byte)(config.Device.Cell.SampleVelocity);
            param[4] = (byte)(config.Device.Cell.SampleVelocity >> 8);

            return this.Encode(message, param);
        }
    }
}
