using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.Serialization;
using System.Drawing;

namespace NovoCyteSimulator.ExpClass
{
    [Serializable]
    public class SampleGraph
    {
        private Parameters _parameters;
        public Parameters Parameters
        {
            get { return _parameters; }
            set { _parameters = value; }
        }

        [OptionalField(VersionAdded = 4)]
        private int _compensationID;    // for saving compensation for old data

        public int CompensationID
        {
            get { return _compensationID; }
            private set { _compensationID = value; }
        }

        private Color _color;

        public Color Color
        {
            get { return _color; }
            set { _color = value; }
        }

        // if sample data are stored as float
        private bool _floatSampleData;  // default to false

        public bool FloatSampleData
        {
            get { return _floatSampleData; }
            set { _floatSampleData = value; }
        }

        private int _widthFiltered;

        /// <summary>
        /// width filtered event count, less than zero means width filter not enabled
        /// </summary>
        public int WidthFiltered
        {
            get { return _widthFiltered; }
            set { _widthFiltered = value; }
        }

        private int _overlapFiltered;

        /// <summary>
        /// overlap filtered event count, less than zero means overlap filter not enabled
        /// </summary>
        public int OverlapFiltered
        {
            get { return _overlapFiltered; }
            set { _overlapFiltered = value; }
        }

        private int _distanceFiltered;

        /// <summary>
        /// distance filtered event count, less than zero means distance filter not enabled
        /// </summary>
        public int DistanceFiltered
        {
            get { return _distanceFiltered; }
            set { _distanceFiltered = value; }
        }

        /// <summary>
        /// gets the sum of WidthFiltered, OverlapFiltered and DistanceFiltered
        /// </summary>
        public int TotalFiltered
        {
            get { return Math.Max(0, WidthFiltered) + Math.Max(0, OverlapFiltered) + Math.Max(0, DistanceFiltered); }
        }

        private bool _showFilteredEvents;

        public bool ShowFilteredEvents
        {
            get { return _showFilteredEvents; }
            set { _showFilteredEvents = value; }
        }

        private bool _pmtGainInVolts;

        /// <summary>
        /// for third party data
        /// </summary>
        public bool PMTGainInVolts
        {
            get { return _pmtGainInVolts; }
            set { _pmtGainInVolts = value; }
        }

        private Color _lastGateColor;
        /// <summary>
        /// store last set gate color
        /// </summary>
        public Color LastGateColor
        {
            get { return _lastGateColor; }
            set { ;/*_lastGateColor = value;*/ }    // this field is not used any more
        }

        /// <summary>
        /// weight and sensor data while data collecting
        /// </summary>
        public List<float[]> WData { get; set; }
		
        private TimeSpan _collectDuration;
        /// <summary>
        /// record collect duration, different with SampleData.Duration, this value includes sample prepare and reset time;
        /// could be empty for old data;
        /// used as TimeOffset in sample time data for appending data
        /// </summary>
        public TimeSpan CollectDuration
        {
            get { return _collectDuration; }
            set { _collectDuration = value; }
        }

        public WDataParas WDataParas { get; set; }

        private bool _baselineOffset;
        /// <summary>
        /// only use for BC data with baseline offset
        /// </summary>
        public bool BaselineOffset
        {
            get { return _baselineOffset; }
            set { _baselineOffset = value; }
        }

        /// <summary>
        /// this field name is keep for old data, and is true for old PID test, should be renamed to _noAbs otherwise
        /// </summary>
        private bool _pIDTest;

        private int _lastSettingChangeIndex;
        /// <summary>
        /// gets or sets event index of last PMT voltage or threshold change, default is zero
        /// </summary>
        public int LastSettingChangeIndex
        {
            get { return _lastSettingChangeIndex; }
            set { _lastSettingChangeIndex = value; }
        }

        //$TimeStep
        private double _TimeStep = double.NaN;   // this filed is not used anymore, keep for old data
        public double TimeStep
        {
            set { _TimeStep = value; }
            get { return _TimeStep; }
        }

        private double _lastSettingChangeTime;
        /// <summary>
        /// gets or sets time in milliseconds of last PMT voltage or threshold change, default is zero
        /// </summary>
        public float LastSettingChangeTime
        {
            get { return (float)_lastSettingChangeTime; }
            set { _lastSettingChangeTime = value; }
        }

        private TimeSpan _lastSettingChangeDuration;
        /// <summary>
        /// gets or sets sample data duration when last PMT voltage or threshold change, default is zero
        /// </summary>
        public TimeSpan LastSettingChangeDuration
        {
            get { return _lastSettingChangeDuration; }
            set { _lastSettingChangeDuration = value; }
        }

        public double _lastSettingChangeVolume;
        /// <summary>
        /// gets or set sample volume when last PMT voltage or threshold change, default is zero
        /// </summary>
        public double LastSettingChangeVolume
        {
            get { return _lastSettingChangeVolume; }
            set { _lastSettingChangeVolume = value; }
        }

        public SampleGraph()
        {
            Constructor();
            SetDefault();
        }

        private void Constructor()
        {
            Parameters = Parameters ?? new Parameters();
            WData = WData ?? new List<float[]>();
            WDataParas = WDataParas ?? new WDataParas();
        }

        private void SetDefault()
        {
            // set default value for new field
            Software = "";
            Version = "";
            SampleOrder = 0;
            FloatSampleData = true; // value of width parameter could be float
            CollectDuration = TimeSpan.Zero;
            WidthFiltered = -1;
            OverlapFiltered = -1;
            DistanceFiltered = -1;

            ShowFilteredEvents = false;
            PMTGainInVolts = false;
            LastSettingChangeIndex = 0;
            LastSettingChangeTime = 0;
            LastSettingChangeDuration = TimeSpan.Zero;
            LastSettingChangeVolume = 0;
            FcsFileName = string.Empty;
        }

        /// <summary>
        /// clear sample data related informations
        /// </summary>
        public void ClearDataInfo()
        {
            Software = "";
            Version = "";
            FloatSampleData = true;   // using float to store 
            CollectDuration = TimeSpan.Zero;
            WidthFiltered = -1;
            OverlapFiltered = -1;
            DistanceFiltered = -1;
            WData = new List<float[]>();
            WDataParas = new WDataParas();
            //TestMode = TestMode.NotSet;   // do not clear test mode, keep it
            BaselineOffset = false;
            //PMTGainInVolts = false;       // keep this value for third party data
            ShowFilteredEvents = false;
            LastSettingChangeIndex = 0;
            LastSettingChangeTime = 0;
            LastSettingChangeDuration = TimeSpan.Zero;
            LastSettingChangeVolume = 0;
            FcsFileName = string.Empty;
        }

        /// <summary>
        /// copy sample data related informations
        /// </summary>
        /// <param name="src"></param>
        public void CopyDataInfo(SampleGraph src)
        {
            if (src == null) return;

            Software = src.Software;
            Version = src.Version;
            FloatSampleData = true;   // using float to store 
            CollectDuration = src.CollectDuration;
            WidthFiltered = src.WidthFiltered;
            OverlapFiltered = src.OverlapFiltered;
            DistanceFiltered = src.DistanceFiltered;
            BaselineOffset = src.BaselineOffset;
            PMTGainInVolts = src.PMTGainInVolts;
            ShowFilteredEvents = src.ShowFilteredEvents;
            LastSettingChangeIndex = src.LastSettingChangeIndex;
            LastSettingChangeTime = src.LastSettingChangeTime;
            LastSettingChangeDuration = src.LastSettingChangeDuration;
            LastSettingChangeVolume = src.LastSettingChangeVolume;
            FcsFileName = src.FcsFileName;
        }

        //$CYT
        private string _Cytometer;   // this filed is not used anymore, keep for old data

        //#NCSoftware
        private string _Software;
        /// <summary>
        /// gets or sets the software name that this sample created by, sets when data acquisition start
        /// </summary>
        public string Software
        {
            set { _Software = value; }
            get { return _Software; }
        }

        //#NCVersion
        private string _Version;
        /// <summary>
        /// gets or sets the software version that this sample is created by, sets when data acquisition start
        /// </summary>
        public string Version
        {
            set { _Version = value; }
            get { return _Version; }
        }

        private int _SampleOrder;
        public int SampleOrder
        {
            set { _SampleOrder = value; }
            get { return _SampleOrder; }
        }

        private double _absBloodVolume;

        public double AbsBloodVolume
        {
            get { return _absBloodVolume; }
            set { _absBloodVolume = value; }
        }

        private double _absTotalVolume;

        public double AbsTotalVolume
        {
            get { return _absTotalVolume; }
            set { _absTotalVolume = value; }
        }

        private double _absUnit;

        public double AbsUnit
        {
            get { return _absUnit; }
            set { _absUnit = value; }
        }

        private bool _absBeadsMethod;

        public bool AbsBeadsMethod
        {
            get { return _absBeadsMethod; }
            set { _absBeadsMethod = value; }
        }

        private double _absBeadsCount;

        public double AbsBeadsCount
        {
            get { return _absBeadsCount; }
            set { _absBeadsCount = value; }
        }

        private string _fcsFileName;

        /// <summary>
        /// gets or sets the imported fcs file name if sample is imported from fcs file, string.Empty by default
        /// </summary>
        public string FcsFileName
        {
            get { return _fcsFileName; }
            set { _fcsFileName = value; }
        }

        [OnDeserialized]
        private void OnDeserialized(StreamingContext sc)
        {
            if (WDataParas == null)
            {
                WDataParas = new WDataParas();
                WDataParas.OldData = true;
                WDataParas.Interval = 500;  // for old data file is 500
            }
            Constructor();
        }

        [OnDeserializing]
        private void OnDeserializing(StreamingContext sc)
        {
            SetDefault();
            FloatSampleData = false;    // for old data without this field, float sample data is false
        }

        [OnSerializing]
        private void OnSerializing(StreamingContext sc)
        {
            // now compensation id should always zero
            CompensationID = 0;// Compensation == null ? 0 : Compensation.Id;
            if (TimeStep <= 0) TimeStep = 0.005;
        }
    }

    [Serializable]
    public class WDataParas
    {
        private float _interval;

        /// <summary>
        /// the interval of wData in ms
        /// </summary>
        public float Interval
        {
            get { return _interval; }
            set { _interval = value; }
        }

        private int _testStartIndex;

        /// <summary>
        /// the index of test start time
        /// </summary>
        public int TestStartIndex
        {
            get { return _testStartIndex; }
            set { _testStartIndex = value; }
        }

        private int _testEndIndex;

        /// <summary>
        /// the index of test end time
        /// </summary>
        public int TestEndIndex
        {
            get { return _testEndIndex; }
            set { _testEndIndex = value; }
        }

        public bool _oldData;

        public bool OldData
        {
            get { return _oldData; }
            set { _oldData = value; }
        }


        public string _operation;

        public string Operation
        {
            get { return _operation; }
            set { _operation = value; }
        }

        public WDataParas()
        {
            Reset();
        }

        public WDataParas Clone()
        {
            return new WDataParas
            {
                TestStartIndex = TestStartIndex,
                TestEndIndex = TestEndIndex,
                Interval = Interval,
                OldData = OldData,
                Operation = Operation
            };
        }

        public void Reset()
        {
            TestStartIndex = 0;
            TestEndIndex = 0;
            OldData = false;
            Operation = string.Empty;
        }
    }
}
