using NovoCyteSimulator.Messages;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovoCyteSimulator.Protocols.Messages
{
    public class CEC : CBase
    {
        public byte Type { set; get; }

        public CEC()
        {
            this.message = 0xEC;
        }

        public override bool Decode(byte[] buf)
        {
            if (this.Decode(message, buf, out parameter))
            {
                Type = parameter[0];
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
            switch (Type)
            {
                case (byte)PARA_TYPE.TYPE_PmtGain:
                    param = new byte[33] {
                        0x01, 0x33, 0x33, 0xF3, 0x3E, 0xE1, 0x7A, 0xD4, 0x3E, 0x83,
                        0xC0, 0x0A, 0x3F, 0x48, 0xE1, 0xFA, 0x3E, 0x25, 0x06, 0x01,
                        0x3F, 0x4C, 0x37, 0x09, 0x3F, 0x37, 0x89, 0x01, 0x3F, 0xC1, 0xCA, 0x01, 0x3F };
                    break;
                case (byte)PARA_TYPE.TYPE_LaserPara:
                    param = new byte[16] {
                        0x04, 0x03, 0x00, 0x03, 0x60, 0xEA, 0x05, 0x00, 0x02, 0x60,
                        0xEA, 0x04, 0x00, 0x03, 0x30, 0x75 };
                    break;
                case (byte)PARA_TYPE.TYPE_ChannelSelect:
                    param = new byte[9];
                    param[0] = Type;
                    for (int i = 1; i <= 8; i++)
                    {
                        param[i] = 0xFF;
                    }
                    break;
                case (byte)PARA_TYPE.TYPE_LaserFilterAndMirrorInfo:
                    param = new byte[1] { 0x13};
                    break;
            }
            return param;
        }
    }
}
