using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovoCyteSimulator.Equipment
{
    public enum LaserType
    {
        nm405nm488nm640,
        nm561nm488nm640,
        nm405nm561nm488,
        nm488nm561nm640,
    }

    public class LaserConfig
    {
        public Dictionary<LaserType, FLChannel> LaserChannelIDDic;
    }
}
