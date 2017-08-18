using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovoCyteSimulator.Equipment
{
    [Serializable]
    public class LaserParas
    {
        /// <summary>
        /// // 激光器类型
        /// </summary>
        public string Typeis { get; set; }

        /// <summary>
        /// 开机是否自动出光
        /// </summary>
        public bool AutoStart { get; set; }

        /// <summary>
        /// 模式,取值为"CWC"、"CWP"、"DIGITAL"、"ANALOG"、"MIXED"
        /// </summary>
        public string Mode { get; set; }

        /// <summary>
        /// 输出功率,单位:mW
        /// </summary>
        public float Power { get; set; }
    }
}
