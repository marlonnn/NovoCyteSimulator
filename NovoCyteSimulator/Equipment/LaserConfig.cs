using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovoCyteSimulator.Equipment
{
    [Serializable]
    public enum LaserType
    {
        nm405nm488nm640,
        nm561nm488nm640,
        nm405nm561nm488,
        nm488nm561nm640,
    }

    [Serializable]
    public class LaserConfig
    {
        public Dictionary<LaserType, FLChannel> LaserChannelIDDic;
        public List<FLChannel> FLChannels;
        public LaserConfig()
        {
            LaserChannelIDDic = new Dictionary<LaserType, FLChannel>();
            FLChannel ch1 = new FLChannel();
            string[] c1 = new string[] {               "FSC",
              "SSC",
              "BL1",
              "BL2",
              "BL3",
              "BL4",
              "BL5",
              "RL1",
              "RL2",
              "VL1",
              "VL2",
              "VL3",
              "VL4",
              "VL5",
              "VL6"};
            ch1.ChannelID = new List<string>();
            ch1.ChannelID.AddRange(c1);
            LaserChannelIDDic[LaserType.nm405nm488nm640] = ch1;

            FLChannel ch2 = new FLChannel();
            string[] c2 = new string[] {               "FSC",
              "SSC",
              "VL1",
              "VL3",
              "YL1",
              "VL5",
              "YL3",
              "BL4",
              "VL6",
              "YL4",
              "VL2",
              "BL1",
              "VL4",
              "YL2",
              "BL3"};
            ch2.ChannelID = new List<string>();
            ch2.ChannelID.AddRange(c2);
            LaserChannelIDDic[LaserType.nm405nm561nm488] = ch2;

            FLChannel ch3 = new FLChannel();
            string[] c3 = new string[] {              "FSC",
              "SSC",
              "BL2",
              "YL1",
              "BL3",
              "YL2",
              "BL6",
              "YL5",
              "RL3",
              "YL4",
              "RL2",
              "BL1",
              "BL4",
              "YL3",
              "RL1"};
            ch3.ChannelID = new List<string>();
            ch3.ChannelID.AddRange(c3);
            LaserChannelIDDic[LaserType.nm488nm561nm640] = ch3;
        }
    }
}
