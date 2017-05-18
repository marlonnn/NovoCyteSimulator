﻿using NovoCyteSimulator.Messages;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovoCyteSimulator.Protocols.Messages
{
    /// <summary>
    /// 设置样本流速
    /// </summary>
    public class C24 : CBase
    {
        private C78 _c78;//应答命令
        public C24(byte message)
        {
            this.message = message;
        }

        public override bool Decode(byte[] buf)
        {
            if (this.Decode(message, buf, out parameter))
            {
                //样本流速(单位uL/min),范围5~120
                config.Device.Cell.SampleVelocity = BitConverter.ToUInt16(parameter, 0);
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