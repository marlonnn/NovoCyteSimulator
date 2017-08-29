using NovoCyteSimulator.Equipment;
using NovoCyteSimulator.LuaScript.LuaInterface;
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
        
        public C20()
        {
            this.message = 0x20;
        }

        public override bool Decode(byte[] buf)
        {
            if (this.Decode(message, buf, out parameter))
            {
                var Time = BitConverter.ToUInt16(parameter, 0);
                var Points = BitConverter.ToUInt32(parameter, 2);
                var Size = BitConverter.ToUInt16(parameter, 6);
                CollectionParams.GetCollectionParams().SetParams(Time, Points, Size);
                SubWork.GetSubWork().ToLua.Size = Size;
                Console.WriteLine(string.Format("Time: {0}, Points: {1}, Size: {2}", Time, Points, Size));
                _c78.M = this.message;
                _c78.R = 0x01;
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
