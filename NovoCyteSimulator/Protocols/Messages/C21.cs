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
    /// 启动、停止细胞采集命令
    /// </summary>
    public class C21 : CBase
    {
        private C78 _c78;//应答命令
        public C21()
        {
            this.message = 0x21;
        }

        public override bool Decode(byte[] buf)
        {
            if (this.Decode(message, buf, out parameter))
            {
                SubWork.GetSubWork().ToLua.Numclean = parameter[2];
                SubWork.GetSubWork().ToLua.Testsel = parameter[3];
                SubWork.GetSubWork().ToLua.Isextdata = false;
                var StartStopCellCollection = parameter[0];
                var Version = parameter[1];
                var CleaningTimes = parameter[2];
                var TestSel = (Equipment.Device.TEST_Sel)parameter[3];
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
