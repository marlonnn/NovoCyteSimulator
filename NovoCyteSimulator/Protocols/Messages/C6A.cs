using NovoCyteSimulator.Messages;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovoCyteSimulator.Protocols.Messages
{
    public enum ReadClearTime
    {
        ClearTime = 0,
        ReadTime = 1,
        ReadNovoSamplerWorkTime = 3
    }

    public class C6A : CBase
    {
        private byte Y;

        public C6A(byte message)
        {
            this.Message = message;
        }

        public override bool Decode(byte[] buf)
        {
            if (this.Decode(message, buf, out parameter))
            {
                this.Y = parameter[0];
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

        private byte[] CreateParam()
        {
            byte[] param = new byte[] { };
            switch (Y)
            {
                case (byte)ReadClearTime.ClearTime:
                    param = new byte[5] { Y, 00, 00, 00, 00 };                    
                    break;
                case (byte)ReadClearTime.ReadTime:
                    param = new byte[9] { Y, 00, 00, 00, 00, 00, 00, 00, 00 };
                    break;
                case (byte)ReadClearTime.ReadNovoSamplerWorkTime:
                    param = new byte[9] { Y, 00, 00, 00, 00, 00, 00, 00, 00 };
                    break;
            }
            return param;
        }
    }
}
