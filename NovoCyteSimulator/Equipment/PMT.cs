using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovoCyteSimulator.Equipment
{
    [Serializable]
    public class PMT
    {
        /// <summary>
        /// PMT选择码位,bitx对应PMTx使能,0表示未选择,1表示选择
        /// </summary>
        public byte MaskSel { get; set; }

        /// <summary>
        /// PMT电压
        /// </summary>
        public float[] Voltage { get; set; }
    }
}
