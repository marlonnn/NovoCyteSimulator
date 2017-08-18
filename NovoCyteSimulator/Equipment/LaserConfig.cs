using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovoCyteSimulator.Equipment
{
    [Serializable]
    public enum Type
    {
        nm405nm488nm640,
        nm561nm488nm640,
        nm405nm561nm488,
        nm488nm561nm640,
    }

    [Serializable]
    public class LaserConfig
    {
        private LaserInfo[] _list;

        public LaserInfo[] LaserInfo { get { return this._list; } }

        /// <summary>
        /// get count of lasers in NovoCyte firmware, should return 3
        /// </summary>
        public int Length
        {
            get { return _list.Length; }
        }

        /// <summary>
        /// get laser at specified firmware position
        /// </summary>
        /// <param name="index">started at 0</param>
        /// <returns></returns>
        public LaserInfo this[int index]
        {
            get { return index >= 0 && index < Length ? _list[index] : new LaserInfo(Laser.NotExist); }
            private set { if (index >= 0 && index < Length) _list[index] = value; }
        }

        /// <summary>
        /// get laser by specified id, could return null if not exists
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        public LaserInfo this[Laser id]
        {
            get { return _list.FirstOrDefault(info => info.ID == id); }
        }

        /// <summary>
        /// is 561 laser system
        /// </summary>
        public bool Is561System
        {
            get { return Exist(Laser.nm561); }
        }

        /// <summary>
        /// create a default laser config with 405/488/640 lasers
        /// </summary>
        public LaserConfig()
        {
            Set(Laser.nm405, Laser.nm488, Laser.nm640);
        }

        /// <summary>
        /// if specified laser exist
        /// </summary>
        /// <param name="laser"></param>
        /// <returns></returns>
        public bool Exist(Laser laser)
        {
            return _list.Count(l => l.ID == laser) > 0;
        }

        /// <summary>
        /// if laser at specified firmware position exist
        /// </summary>
        /// <param name="index"></param>
        /// <returns></returns>
        public bool Exist(int index)
        {
            return this[index].ID != Laser.NotExist;
        }


        /// <summary>
        /// laser config type
        /// </summary>
        public Type ConfigType
        {
            get
            {
                if (_list[0].ID == Laser.nm561) return Type.nm561nm488nm640;
                else if (_list[1].ID == Laser.nm561 && _list[0].ID == Laser.nm405) return Type.nm405nm561nm488;
                else if (_list[1].ID == Laser.nm561) return Type.nm488nm561nm640;
                else return Type.nm405nm488nm640;
            }
        }

        /// <summary>
        /// set laser config according to lasers of each position
        /// </summary>
        /// <param name="L1"></param>
        /// <param name="L2"></param>
        /// <param name="L3"></param>
        /// <param name="existLasers">if not null, judge L1, L2, L3 exist by this parameter</param>
        public void Set(Laser L1, Laser L2, Laser L3, bool[] existLasers = null)
        {
            // make sure laser does not duplicate
            if (L1 == L2) L1 = Laser.NotExist;
            if (L3 == L2 || L3 == L1) L3 = Laser.NotExist;

            LaserInfo[] lasers = new LaserInfo[] { new LaserInfo(L1), new LaserInfo(L2), new LaserInfo(L3) };

            if (existLasers != null)
            {
                for (int i = 0; i < lasers.Length; i++)
                    if (!existLasers[(int)lasers[i].ID]) lasers[i].ID = Laser.NotExist;
            }
            _list = lasers;
        }

        //public Dictionary<LaserType, FLChannel> LaserChannelIDDic;
        //public List<FLChannel> FLChannels;
        //public LaserConfig()
        //{
        //    LaserChannelIDDic = new Dictionary<LaserType, FLChannel>();
        //    FLChannel ch1 = new FLChannel();
        //    string[] c1 = new string[] {               "FSC",
        //      "SSC",
        //      "VL2",
        //      "BL1",
        //      "VL3",
        //      "BL2",
        //      "VL5",
        //      "BL4",
        //      "RL1",
        //      "VL6",
        //      "BL5",
        //      "RL2",
        //      "VL1",
        //      "VL4",
        //      "BL3"};
        //    ch1.ChannelID = new List<string>();
        //    ch1.ChannelID.AddRange(c1);
        //    LaserChannelIDDic[LaserType.nm405nm488nm640] = ch1;

        //    FLChannel ch2 = new FLChannel();
        //    string[] c2 = new string[] {               "FSC",
        //      "SSC",
        //      "VL1",
        //      "VL3",
        //      "YL1",
        //      "VL5",
        //      "YL3",
        //      "BL4",
        //      "VL6",
        //      "YL4",
        //      "VL2",
        //      "BL1",
        //      "VL4",
        //      "YL2",
        //      "BL3"};
        //    ch2.ChannelID = new List<string>();
        //    ch2.ChannelID.AddRange(c2);
        //    LaserChannelIDDic[LaserType.nm405nm561nm488] = ch2;

        //    FLChannel ch3 = new FLChannel();
        //    string[] c3 = new string[] {              "FSC",
        //      "SSC",
        //      "BL2",
        //      "YL1",
        //      "BL3",
        //      "YL2",
        //      "BL6",
        //      "YL5",
        //      "RL3",
        //      "YL4",
        //      "RL2",
        //      "BL1",
        //      "BL4",
        //      "YL3",
        //      "RL1"};
        //    ch3.ChannelID = new List<string>();
        //    ch3.ChannelID.AddRange(c3);
        //    LaserChannelIDDic[LaserType.nm488nm561nm640] = ch3;
        //}
    }
}
