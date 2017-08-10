using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using NovoCyteSimulator.Messages;

namespace NovoCyteSimulator.Protocols.Messages
{
    public class CA8 : CBase
    {
        public enum PID_PT
        {
            TYPE_PID_Pt = 1, // PID 目标压力
        };

        public byte[] T;
        public byte[] R;
        public CA8()
        {
            this.message = 0xA8;
        }

        public override bool Decode(byte[] buf)
        {
            if (this.Decode(message, buf, out parameter))
            {
                T = new byte[2];
                Array.Copy(parameter, 0, T, 0, 2);
                return true;
            }
            else
            {
                return false;
            }
        }

        public byte[] CreateParam()
        {
            byte[] param = new byte[6];
            byte[] R = new byte[4];
            int workMode = 10;
            R[0] = (byte)(workMode);
            R[1] = (byte)(workMode >> 8);
            R[2] = (byte)(workMode >> 16);
            R[3] = (byte)(workMode >> 24);
            Array.Copy(T, 0, param,0, 2);
            Array.Copy(R, 0, param, 2, 4);
            return param;
        }

        public override byte[] Encode()
        {
            byte[] param = CreateParam();
            return this.Encode(message, param);
        }
    }
}
