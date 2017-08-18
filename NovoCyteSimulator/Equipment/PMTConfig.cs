using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovoCyteSimulator.Equipment
{
    /// <summary>
    /// pmt config class
    /// </summary>
    [Serializable]
    public class PMTConfig
    {
        /// <summary>
        /// the Layout define PxLx order in firmware communication protocol
        /// </summary>
        public enum Layout
        {
            Legacy = 0,             // legacy pmt layout for NovoCyte 3000, VYB, RYB
            V6B4R3 = 1,             // for NovoCyte V6B4R3, firmware ends with D
            FL16 = 2,   			// for NovoCyte V6B5R4, firmware ends with E, the type support user customize
        }

        private Layout _layout;
        /// <summary>
        /// gets or sets the pmt config layout
        /// </summary>
        public Layout PMTLayout
        {
            get { return _layout; }
            set { _layout = value; }
        }

        /// <summary>
        /// the list of PMTs, total 8
        /// </summary>
        private PMTInfo[] _list;

        public PMTInfo[] List
        {
            get
            {
                return _list;
            }
            set
            {
                _list = value;
            }
        }

        /// <summary>
        /// get a copy of the list of PMT infos
        /// </summary>
        public PMTInfo[] GetList()
        {
            return _list.ToArray();    // create a copy of the internal list
        }

        /// <summary>
        /// get count of PMTs in NovoCyte firmware, should return 8
        /// </summary>
        public int Length
        {
            get { return _list.Length; }
        }

        /// <summary>
        /// get pmt at specified firmware position
        /// </summary>
        /// <param name="index">started at 0</param>
        /// <returns></returns>
        public PMTInfo this[int index]
        {
            get { return index >= 0 && index < Length ? _list[index] : new PMTInfo(DetectionChannel.NotExist); }
            private set { if (index >= 0 && index < Length) _list[index] = value; }
        }

        /// <summary>
        /// get pmt info by specified id
        /// </summary>
        /// <param name="id"></param>
        /// <returns>null if does not exists</returns>
        public PMTInfo this[DetectionChannel id]
        {
            get { return _list.FirstOrDefault(info => info.ID == id); }
        }

        /// <summary>
        /// if specified PMT exist
        /// </summary>
        /// <param name="laser"></param>
        /// <returns></returns>
        public bool Exist(DetectionChannel pmt)
        {
            if (pmt == DetectionChannel.APD1 || pmt == DetectionChannel.APD2)
                return true;

            return _list.Count(p => p.ID == pmt) > 0;
        }

        /// <summary>
        /// if PMT at specified firmware position exist
        /// </summary>
        /// <param name="index"></param>
        /// <returns></returns>
        public bool Exist(int index)
        {
            return this[index].ID != DetectionChannel.NotExist;
        }

        /// <summary>
        /// get an exists array of all pmts
        /// </summary>
        /// <returns></returns>
        public bool[] GetExists()
        {
            var exists = new bool[(int)DetectionChannel.Count];
            for (int i = 0; i < exists.Length; i++) exists[i] = Exist((DetectionChannel)i);
            return exists;
        }

        public void Set(Type laserCfgType, bool[] exists = null, bool firmwarePosition = true, Layout layout = Layout.Legacy, string[] filters = null, string[] mirrors = null)
        {
            _layout = layout;
            _list = new PMTInfo[8];     // most 8 pmts in NovoCyte
            for (int i = 0; i < _list.Length; i++) _list[i] = new PMTInfo(DetectionChannel.NotExist);

            // set according to laser config type
            if (layout == Layout.FL16 && filters != null)
            {
                for (int i = 0; i < _list.Length && i < filters.Length; i++)
                {
                    _list[i].ID = WaveLengthHelper.GetDetectionChannelFromFilter(filters[i]);
                }
            }
            else if (laserCfgType == Type.nm405nm561nm488)
            {
                _list[0].ID = DetectionChannel.nm450;
                _list[1].ID = DetectionChannel.nm585;
                _list[2].ID = DetectionChannel.nm675;
                _list[3].ID = DetectionChannel.nm780;
                _list[4].ID = DetectionChannel.nm530;
                _list[5].ID = DetectionChannel.nm615;
            }
            else if (laserCfgType == Type.nm488nm561nm640)
            {
                _list[0].ID = DetectionChannel.nm585;
                _list[1].ID = DetectionChannel.nm615;
                _list[2].ID = DetectionChannel.nm695;
                _list[3].ID = DetectionChannel.nm780;
                _list[4].ID = DetectionChannel.nm530;
                _list[5].ID = DetectionChannel.nm675;
            }
            else    // 3000 or 3002 or 3005
            {
                if (layout == Layout.V6B4R3)    // 3002(V6B4R3)
                {
                    _list[0].ID = DetectionChannel.nm530;
                    _list[1].ID = DetectionChannel.nm585;
                    _list[2].ID = DetectionChannel.nm725;   // D firmware, PMT3 is 725nm
                    _list[3].ID = DetectionChannel.nm780;
                    _list[4].ID = DetectionChannel.nm450;
                    _list[5].ID = DetectionChannel.nm675;
                }
                else if (layout == Layout.Legacy || filters == null)     // 3000 or default 3005 or nm561nm488nm640, nm405nm488nm640
                {
                    _list[0].ID = DetectionChannel.nm530;
                    _list[1].ID = DetectionChannel.nm585;
                    _list[2].ID = DetectionChannel.nm675;
                    _list[3].ID = DetectionChannel.nm780;
                    _list[4].ID = DetectionChannel.nm450;
                    _list[5].ID = DetectionChannel.nm615;
                }
            }

            // update according to exists array
            if (exists != null)
            {
                for (int i = 0; i < _list.Length; i++)
                {
                    int index = firmwarePosition ? i : (int)_list[i].ID;
                    if (_list[i].ID != DetectionChannel.NotExist && !exists[index]) _list[i].ID = DetectionChannel.NotExist;
                }
            }

            SetFilters(laserCfgType, layout, filters);
        }

        /// <summary>
        /// set PMT filters
        /// </summary>
        /// <param name="filters">null for default filters</param>
        private void SetFilters(Type laserCfgType, Layout layout, string[] filters = null)
        {
            // update filters            
            if (filters != null)
            {
                for (int i = 0; i < _list.Length && i < filters.Length; i++) _list[i].Filter = Exist(i) ? filters[i] : "";
            }
            else
            {
                var names = WaveLengthHelper.GetPMTDefaultNames(laserCfgType, layout);
                for (int i = 0; i < _list.Length; i++) _list[i].Filter = Exist(i) ? names[(int)_list[i].ID] : "";
            }
        }

        /// <summary>
        /// create a new pmt config with 6 pmts and 405/488/640 laser config
        /// </summary>
        public PMTConfig()
        {
            Set(Type.nm405nm488nm640, new bool[] { true, true, true, true, true, true, false, false }, true, Layout.FL16);
        }
    }
}
