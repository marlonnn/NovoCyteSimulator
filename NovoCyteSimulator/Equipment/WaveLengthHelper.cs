using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovoCyteSimulator.Equipment
{
    public static class WaveLengthHelper
    {
        /// <summary>
        /// get DetectionChannel from a known filter
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        public static DetectionChannel GetDetectionChannelFromFilter(string filter)
        {
            switch (filter)
            {
                case "445/45":
                    return DetectionChannel.nm450;
                case "530/30":
                    return DetectionChannel.nm530;
                case "586/20":
                case "572/28":
                    return DetectionChannel.nm585;
                case "615/20":
                    return DetectionChannel.nm615;
                case "675/30":
                case "660/20":
                    return DetectionChannel.nm675;
                case "695/40":
                    return DetectionChannel.nm695;
                case "725/40":
                    return DetectionChannel.nm725;
                case "780/60":
                    return DetectionChannel.nm780;
                default:
                    return DetectionChannel.NotExist;
            }
        }

        /// <summary>
        /// get names array for all pmts according to laser config type
        /// </summary>
        /// <param name="laserCfgType"></param>
        /// <returns></returns>
        public static string[] GetPMTDefaultNames(Type laserCfgType, PMTConfig.Layout layout)
        {
            if (laserCfgType == Type.nm561nm488nm640)
            {
                return new string[(int)DetectionChannel.Count] { "530/30", "586/20", "660/20", "780/60", "445/45", "615/20", "695/40", "-", "-", "-", "-", "-", "-", "-" };
            }
            else if (laserCfgType == Type.nm405nm561nm488)
            {
                return new string[(int)DetectionChannel.Count] { "530/30", "586/20", "660/20", "780/60", "445/45", "615/20", "695/40", "-", "-", "-", "-", "-", "-", "-" };
            }
            else if (laserCfgType == Type.nm488nm561nm640)
            {
                return new string[(int)DetectionChannel.Count] { "530/30", "586/20", "660/20", "780/60", "445/45", "615/20", "695/40", "-", "-", "-", "-", "-", "-", "-" };
            }
            else
            {
                if (layout == PMTConfig.Layout.V6B4R3)  // 3002 or 3005
                    return new string[(int)DetectionChannel.Count] { "530/30", "572/28", "660/20", "780/60", "445/45", "615/20", "695/40", "725/40", "-", "-", "-", "-", "-", "-" };
                else    // 3000
                    return new string[(int)DetectionChannel.Count] { "530/30", "572/28", "675/30", "780/60", "445/45", "615/20", "695/40", "725/40", "-", "-", "-", "-", "-", "-" };
            }
        }

        /// <summary>
        /// get mirrors array for all pmts according to laser config type
        /// </summary>
        /// <param name="laserCfgType"></param>
        /// <returns></returns>
        public static string[] GetPMTDefaultMirrors(Type laserCfgType, PMTConfig.Layout layout)
        {
            if (laserCfgType == Type.nm561nm488nm640)
            {
                return new string[(int)DetectionChannel.Count] { "", "572LP", "650LP", "735LP", "", "600LP", "685LP", "-", "-", "-", "-", "-", "-", "-" };
            }
            else if (laserCfgType == Type.nm405nm561nm488)
            {
                return new string[(int)DetectionChannel.Count] { "495LP", "572LP", "650LP", "735LP", "", "600LP", "-", "-", "-", "-", "-", "-", "-", "-" };
            }
            else if (laserCfgType == Type.nm488nm561nm640)
            {
                return new string[(int)DetectionChannel.Count] { "", "572LP", "650LP", "735LP", "", "600LP", "685LP", "-", "-", "-", "-", "-", "-", "-" };
            }
            else
            {
                if (layout == PMTConfig.Layout.V6B4R3)  // 3002 or 3005
                    return new string[(int)DetectionChannel.Count] { "505LP", "555LP", "650LP", "757LP", "472SP", "600LP", "685LP", "685LP"/*default for 725/40*/, "-", "-", "-", "-", "-", "-" };
                else    // 3000
                    return new string[(int)DetectionChannel.Count] { "505LP", "555LP", "650LP", "735LP", "472SP", "600LP", "685LP", "705LP", "-", "-", "-", "-", "-", "-" };
            }
        }
    }
}
