using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovoCyteSimulator.Equipment
{
    public enum Laser
    {
        NotExist = -1,  // not exists
        [Description("405nm")]
        nm405,  //  do not change the names, it is write to NovoCyte by SysConfig.GetLaserConfigStringArray
        [Description("488nm")]
        nm488,
        [Description("640nm")]
        nm640,
        [Description("561nm")]
        nm561,
        Count
    }

    [Serializable]
    public class LaserInfo
    {
        private Laser _id;

        /// <summary>
        /// id of laser
        /// </summary>
        public Laser ID
        {
            get { return _id; }
            set { _id = value; }
        }

        /// <summary>
        /// laser power, unit mW, NaN means unknown
        /// </summary>
        private float _power;

        /// <summary>
        /// laser power, unit mW, NaN means unknown
        /// </summary>
        public float Power
        {
            get { return _power; }
            set { _power = value; }
        }

        /// <summary>
        /// if Power value is valid/known
        /// </summary>
        /// <returns></returns>
        public bool IsPowerKnown
        {
            get { return !float.IsNaN(Power) && Power > 0; }
        }

        public LaserInfo(Laser id)
        {
            _id = id;
            _power = 20;
        }
    }
}
