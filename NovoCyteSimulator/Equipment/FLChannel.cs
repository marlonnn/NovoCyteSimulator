using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovoCyteSimulator.Equipment
{
    public enum FLChannelID
    {
        FSC = -2,
        SSC = -1,
        NonFL = 0,  // not a FL channel
        BL1,    // 488nm 530nm
        BL2,    // 488nm 572nm
        BL3,    // 488nm 615nm
        BL4,    // 488nm 675nm
        BL5,    // 488nm 780nm
        RL1,    // 640nm 675nm
        RL2,    // 640nm 780nm
        VL1,    // 405nm 450nm
        VL2,    // 405nm 530nm
        VL3,    // 405nm 572nm
        VL4,    // 405nm 615nm
        VL5,    // 405nm 675nm
        VL6,    // 405nm 780nm
        YL1,    // 561nm 572nm
        YL2,    // 561nm 615nm
        YL3,    // 561nm 675nm
        YL4,    // 561nm 780nm
        YL5,    // 561nm 695nm
        BL6,    // 488nm 695nm
        RL3,    // 640nm 695nm
        VL7,    // 405nm 695nm
        BL7,    // 488nm 725nm
        VL8,    // 405nm 725nm
        RL4,    // 640nm 725nm
        YL6,    // 561nm 725nm
        Count,
    }

    [Serializable]
    public class FLChannel
    {
        public static FLChannel flChannel;
        private List<FLChannelID> channels;
        private CytometerInfo cytoInfo;

        public FLChannel(CytometerInfo cytoInfo)
        {
            this.cytoInfo = cytoInfo;
            InitializeChannels();
        }

        public static FLChannel GetFLChannel(CytometerInfo cytoInfo)
        {
            if (flChannel == null)
            {
                flChannel = new FLChannel(cytoInfo);
            }
            return flChannel;
        }

        private void InitializeChannels()
        {
            channels = new List<FLChannelID>();
            channels.Add(FromLaserAndDetectionChannel(cytoInfo.LaserConfig[0].ID, cytoInfo.LaserConfig, cytoInfo.PMTConfig[0].ID));

            channels.Add(FromLaserAndDetectionChannel(cytoInfo.LaserConfig[1].ID, cytoInfo.LaserConfig, cytoInfo.PMTConfig[0].ID));

            channels.Add(FromLaserAndDetectionChannel(cytoInfo.LaserConfig[0].ID, cytoInfo.LaserConfig, cytoInfo.PMTConfig[1].ID));

            channels.Add(FromLaserAndDetectionChannel(cytoInfo.LaserConfig[1].ID, cytoInfo.LaserConfig, cytoInfo.PMTConfig[1].ID));

            channels.Add(FromLaserAndDetectionChannel(cytoInfo.LaserConfig[0].ID, cytoInfo.LaserConfig, cytoInfo.PMTConfig[2].ID));

            channels.Add(FromLaserAndDetectionChannel(cytoInfo.LaserConfig[1].ID, cytoInfo.LaserConfig, cytoInfo.PMTConfig[2].ID));

            channels.Add(FromLaserAndDetectionChannel(cytoInfo.LaserConfig[2].ID, cytoInfo.LaserConfig, cytoInfo.PMTConfig[2].ID));

            channels.Add(FromLaserAndDetectionChannel(cytoInfo.LaserConfig[0].ID, cytoInfo.LaserConfig, cytoInfo.PMTConfig[3].ID));

            channels.Add(FromLaserAndDetectionChannel(cytoInfo.LaserConfig[1].ID, cytoInfo.LaserConfig, cytoInfo.PMTConfig[3].ID));

            channels.Add(FromLaserAndDetectionChannel(cytoInfo.LaserConfig[2].ID, cytoInfo.LaserConfig, cytoInfo.PMTConfig[3].ID));

            channels.Add(FromLaserAndDetectionChannel(cytoInfo.LaserConfig[0].ID, cytoInfo.LaserConfig, cytoInfo.PMTConfig[4].ID));

            channels.Add(FromLaserAndDetectionChannel(cytoInfo.LaserConfig[0].ID, cytoInfo.LaserConfig, cytoInfo.PMTConfig[5].ID));

            channels.Add(FromLaserAndDetectionChannel(cytoInfo.LaserConfig[1].ID, cytoInfo.LaserConfig, cytoInfo.PMTConfig[5].ID));

            //channels.Add(FromLaserAndDetectionChannel(cytoInfo.LaserConfig[2].ID, cytoInfo.LaserConfig, cytoInfo.PMTConfig[5].ID));

            //channels.Add(FromLaserAndDetectionChannel(cytoInfo.LaserConfig[2].ID, cytoInfo.LaserConfig, cytoInfo.PMTConfig[1].ID));

            //channels.Add(FromLaserAndDetectionChannel(cytoInfo.LaserConfig[2].ID, cytoInfo.LaserConfig, cytoInfo.PMTConfig[4].ID));
        }

        public FLChannelID GetPxLxChannelID(int id)
        {
            return channels[id];
        }

        /// <summary>
        /// get fl channel id from laser and detection channel
        /// </summary>
        public static FLChannelID FromLaserAndDetectionChannel(Laser laser, LaserConfig laserCfg, DetectionChannel dchannel)
        {
            for (FLChannelID id = FLChannelID.BL1; id < FLChannelID.Count; id++)
            {
                if (GetLaser(id, laserCfg) == laser && GetDetectionChannel(id) == dchannel)
                    return id;
            }
            return FLChannelID.NonFL;
        }

        /// <summary>
        /// get laser of specified fl channel id
        /// </summary>
        /// <param name="id"></param>
        /// <param name="laserCfg">only needed when get for FSC and SSC</param>
        /// <returns></returns>
        public static Laser GetLaser(FLChannelID id, LaserConfig laserCfg = null)
        {
            switch (id)
            {
                case FLChannelID.BL1:
                case FLChannelID.BL2:
                case FLChannelID.BL3:
                case FLChannelID.BL4:
                case FLChannelID.BL5:
                case FLChannelID.BL6:
                case FLChannelID.BL7:
                    return Laser.nm488;
                case FLChannelID.RL1:
                case FLChannelID.RL2:
                case FLChannelID.RL3:
                case FLChannelID.RL4:
                    return Laser.nm640;
                case FLChannelID.VL1:
                case FLChannelID.VL2:
                case FLChannelID.VL3:
                case FLChannelID.VL4:
                case FLChannelID.VL5:
                case FLChannelID.VL6:
                case FLChannelID.VL7:
                case FLChannelID.VL8:
                    return Laser.nm405;
                case FLChannelID.YL1:
                case FLChannelID.YL2:
                case FLChannelID.YL3:
                case FLChannelID.YL4:
                case FLChannelID.YL5:
                case FLChannelID.YL6:
                    return Laser.nm561;
                case FLChannelID.FSC:
                case FLChannelID.SSC:
                default:
                    return laserCfg != null && laserCfg.Exist(1) ? laserCfg[1].ID : Laser.nm488;    // FSC, SSC is laser 2 
            }
        }

        public static DetectionChannel GetDetectionChannel(FLChannelID id)
        {
            switch (id)
            {
                case FLChannelID.BL7:
                case FLChannelID.VL8:
                case FLChannelID.RL4:
                case FLChannelID.YL6:
                    return DetectionChannel.nm725;
                case FLChannelID.BL6:
                case FLChannelID.RL3:
                case FLChannelID.YL5:
                case FLChannelID.VL7:
                    return DetectionChannel.nm695;
                case FLChannelID.BL5:
                case FLChannelID.RL2:
                case FLChannelID.VL6:
                case FLChannelID.YL4:
                    return DetectionChannel.nm780;
                case FLChannelID.BL4:
                case FLChannelID.RL1:
                case FLChannelID.VL5:
                case FLChannelID.YL3:
                    return DetectionChannel.nm675;
                case FLChannelID.BL3:
                case FLChannelID.VL4:
                case FLChannelID.YL2:
                    return DetectionChannel.nm615;
                case FLChannelID.BL2:
                case FLChannelID.VL3:
                case FLChannelID.YL1:
                    return DetectionChannel.nm585;
                case FLChannelID.BL1:
                case FLChannelID.VL2:
                    return DetectionChannel.nm530;
                case FLChannelID.VL1:
                    return DetectionChannel.nm450;
                case FLChannelID.SSC:
                    return DetectionChannel.APD2;
                case FLChannelID.FSC:
                default:
                    return DetectionChannel.APD1;
            }
        }
    }
}
