using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using System.Runtime.Serialization;
using System.Drawing;

namespace NovoCyteSimulator.ExpClass
{
    public enum FlowRateLevel
    {
        Slow,
        Medium,
        Fast,
        Custom
    }

    /// <summary>
    /// the class to save configuration of a sample
    /// </summary>
    [Serializable]
    public class SampleConfig : IDisposable
    {
        public SampleConfig()
        {
            _sampleGraph = new SampleGraph();
            _sampleData = new SampleData();
        }

        public void Dispose()
        {

            Parameters = null;
            SampleGraph = null;
            SampleData = null;

        }

        [NonSerialized]
        private SampleData _sampleData;
        /// <summary>
        /// related sample data of this config
        /// </summary>
        public SampleData SampleData
        {
            get { return _sampleData; }
            set { _sampleData = value; }
        }

        [NonSerialized]
        private bool _dataPreCleared;
        /// <summary>
        /// gets or sets flag which indicate if sample data is cleared or portion deleted 
        /// </summary>
        public bool DataPreCleared
        {
            get { return _dataPreCleared; }
            set { _dataPreCleared = value; }
        }

        public bool HasData
        {
            get { return SampleData != null; }
        }

        [NonSerialized]
        private bool _toCollect = false;
        /// <summary>
        /// this value indicate if we are going to collect this sample
        /// </summary>
        public bool ToCollect
        {
            get { return _toCollect; }// && !HasData; }
            set { _toCollect = value; }
        }

        [NonSerialized]
        private bool _selected = false;
        /// <summary>
        /// this value indicate if we select the config in well plate
        /// </summary>
        public bool Selected
        {
            get { return _selected; }
            set { _selected = value; }
        }

        [NonSerialized]
        private bool _lastCollected = false;
        /// <summary>
        /// this value indicate if the sample is last collected, auto export events after run use it
        /// </summary>
        public bool LastCollected
        {
            get { return _lastCollected; }
            set { _lastCollected = value; }
        }

        [NonSerialized]
        private int _washCycle = 1;
        /// <summary>
        /// this value indicate washing cycle
        /// </summary>
        public int WashCycle
        {
            get { return _washCycle; }
            set { _washCycle = value; }
        }

        [NonSerialized]
        public static readonly char ParaNamesSeparator = '\t';

        public Parameters Parameters
        {
            get { return _sampleGraph.Parameters; }
            set { _sampleGraph.Parameters = value; }
        }

        public Color Color
        {
            get { return _sampleGraph.Color; }
            set { _sampleGraph.Color = value; }
        }

        private SampleGraph _sampleGraph;

        public SampleGraph SampleGraph
        {
            get { return _sampleGraph; }
            set { _sampleGraph = value; }
        }

        [NonSerialized]
        private bool _qcSampleConfig = false;
        /// <summary>
        /// gets or sets flag which indicate if sample is create when qc 
        /// </summary>
        public bool QcSampleConfig
        {
            get { return _qcSampleConfig; }
            set { _qcSampleConfig = value; }
        }

        #region fields in database

        private int _sc_id;
        /// <summary>
        /// primary key
        /// </summary>      
        public int SC_ID
        {
            get { return _sc_id; }
            set { _sc_id = value; }
        }

        private string _sampleName = string.Empty;
        /// <summary>
        /// sample/well name
        /// </summary>      
        public string SampleName
        {
            get { return _sampleName; }
            set { _sampleName = value; }
        }

        public string FullName
        {
            get { return SampleName; }
        }

        private bool _unlimited;
        /// <summary>
        /// is unlimited
        /// </summary>
        public bool Unlimited
        {
            get
            {
                return TimeLimits == 0 && VolumeLimits == 0 && EventsLimits == 0;
            }
            set
            {
                // do nothing
            }
        }

        private uint _eventsLimits;
        /// <summary>
        /// Events limit in gate.
        /// </summary>       
        public uint EventsLimits
        {
            get { return _eventsLimits; }
            set { _eventsLimits = value; }
        }

        private string _gateLimits;
        /// <summary>
        /// the name of limits gate 
        /// </summary>
        public string GateLimits
        {
            get { return _gateLimits; }
            set { _gateLimits = value; }
        }

        private ushort _timeLimits;
        /// <summary>
        /// Run time limits(Unit: second)
        /// </summary>      
        public ushort TimeLimits
        {
            get { return _timeLimits; }
            set { _timeLimits = value; }
        }

        private ushort _volumeLimits;
        /// <summary>
        /// Sample volume limit(ul)
        /// </summary>      
        public ushort VolumeLimits
        {
            get { return _volumeLimits; }
            set { _volumeLimits = value; }
        }

        private FlowRateLevel _flowRateLevel;
        /// <summary>
        /// 0--slow, 1--medium, 2--fast
        /// </summary>      
        public FlowRateLevel FlowRateLevel
        {
            get { return _flowRateLevel; }
            set { _flowRateLevel = value; }
        }

        private ushort _customFlowRate;
        /// <summary>
        /// ul/min
        /// </summary>       
        public ushort CustomFlowRate
        {
            get { return _customFlowRate; }
            set { _customFlowRate = value; }
        }

        private int _primaryChannel;
        /// <summary>
        /// 0--None, 1--FFC, 2--SSC, 3--FL1, 4--FL2, 5--FL3, 6--FL4...
        /// </summary>      
        public int PrimaryChannel
        {
            get { return _primaryChannel; }
            set { _primaryChannel = value; }
        }

        private int _primaryThreshold;
        /// <summary>
        /// primary threshold value
        /// </summary>      
        public int PrimaryThreshold
        {
            get { return _primaryThreshold; }
            set { _primaryThreshold = value; }
        }

        private int _secondaryChannel;
        /// <summary>
        /// 0--No channel, 1--FFC, 2--SSC, 3--FL1, 4--FL2, 5--FL3, 6--FL4...
        /// </summary>       
        public int SecondaryChannel
        {
            get { return _secondaryChannel; }
            set { _secondaryChannel = value; }
        }

        private int _secondaryThreshold;
        /// <summary>
        /// secondary threshold value
        /// </summary>       
        public int SecondaryThreshold
        {
            get { return _secondaryThreshold; }
            set { _secondaryThreshold = value; }
        }

        private string _storageGate;
        /// <summary>
        /// the name of storage gate 
        /// </summary>
        public string StorageGate
        {
            get { return _storageGate; }
            set { _storageGate = value; }
        }

        #endregion

        [NonSerialized]
        public static readonly ushort[] FlowRates = new ushort[] { 14, 35, 66 };
        [NonSerialized]
        public static readonly int[] CoreSizes = new int[] { 10, 16, 22 };
        [NonSerialized]
        public static readonly int MaxEvents = 10000000; // 10 million
        [NonSerialized]
        public static readonly int MaxVolume = 5000;    // 5 ml
        [NonSerialized]
        public static readonly int MinVolume = 10;    // 10 ul
        [NonSerialized]
        public static readonly int MaxTime = 3659;   // 1 hour, 59s
        [NonSerialized]
        public static readonly int MaxThreshold = 500000000;
        [NonSerialized]
        public static readonly int MinThreshold = 10;

        /// <summary>
        /// gets flow rate value
        /// </summary>
        public ushort FlowRate
        {
            get
            {
                return FlowRateLevel == FlowRateLevel.Custom ? CustomFlowRate : FlowRates[(int)FlowRateLevel];
            }
            set
            {
                FlowRateLevel = FlowRateLevel.Custom;
                CustomFlowRate = value;
                for (FlowRateLevel level = FlowRateLevel.Slow; level <= FlowRateLevel.Fast; level++)
                {
                    if (value == FlowRates[(int)level])
                    {
                        FlowRateLevel = level;
                    }
                }
            }
        }

        public double CoreSize
        {
            get { return FlowRate2CoreSize(FlowRate); }
        }

        /// <summary>
        /// is primary channel threshold set
        /// </summary>
        public bool IsPrimaryChannelSet
        {
            get
            {
                return PrimaryChannel > 0;
            }
        }

        /// <summary>
        /// is secondary channel threshold set
        /// </summary>
        public bool IsSecondaryChannelSet
        {
            get
            {
                return SecondaryChannel > 0;
            }
        }

        public static double FlowRate2CoreSize(int flowRate)
        {
            return 1000000 * Math.Sqrt(2 * flowRate * 250 * 250 * 0.000000000001 * 0.001 / 3.14 / 9.3);
        }
    }
}
