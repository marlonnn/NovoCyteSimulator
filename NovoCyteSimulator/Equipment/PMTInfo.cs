using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovoCyteSimulator.Equipment
{
    public enum DetectionChannel
    {
        NotExist = -1,  // PMT not exists
        nm530,
        nm585,
        nm675,
        nm780,
        nm450,
        nm615,
        nm695,
        nm725,			// reserved ids
        nm2,
        nm3,
        nm4,
        nm5,
        APD1,           // FSC
        APD2,           // SSC
        Count,
        //NoFilter,       // PMT exists, but no filter and TIR mirror
    }

    [Serializable]
    public class PMTInfo
    {
        private DetectionChannel _id;

        /// <summary>
        /// id of pmt/detection channel
        /// </summary>
        public DetectionChannel ID
        {
            get { return _id; }
            set { _id = value; }
        }

        /// <summary>
        /// wavelength of filter
        /// </summary>
        private string _name;

        /// <summary>
        /// gets or sets wavelength of filter, null or empty means not exist
        /// </summary>
        public string Filter
        {
            get { return _name; }
            set { _name = value; }
        }

        /// <summary>
        /// PMT current voltage, unit V, NaN means unknown value
        /// </summary>
        private float _voltage;

        /// <summary>
        /// PMT current voltage (read from firmware), unit V, NaN means unknown
        /// </summary>
        public float Voltage
        {
            get { return _voltage; }
            set { _voltage = value; }
        }

        public bool IsVoltageKnown
        {
            get { return !float.IsNaN(Voltage) && Voltage > 0; }
        }

        /// <summary>
        /// PMT default voltage (read from firmware), unit V, -1 means unknown
        /// </summary>
        private float _defaultVoltage;

        /// <summary>
        /// PMT default voltage, unit V, -1 means unknown
        /// </summary>
        public float DefaultVoltage
        {
            get { return _defaultVoltage; }
            set { _defaultVoltage = float.IsNaN(value) ? -1 : value; }
        }

        public float GetVoltage(bool isDefaultVoltage)
        {
            return isDefaultVoltage ? DefaultVoltage : Voltage;
        }

        public void SetVoltage(bool isDefaultVoltage, float value)
        {
            if (isDefaultVoltage) DefaultVoltage = value;
            else Voltage = value;
        }

        public PMTInfo()
        {

        }

        public PMTInfo(DetectionChannel id)
        {
            _id = id;
            _name = string.Empty;
            _voltage = float.NaN;        // default to unknown
            _defaultVoltage = -1;        // default to unknown
        }
    }
}
