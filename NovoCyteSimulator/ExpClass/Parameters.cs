using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovoCyteSimulator.ExpClass
{
    public class Parameter
    {
        public enum ParaType
        {
            Height,
            Area,
            Width,
            Time,
            Histogram,
            Other,
            Overlap,
            Weight,
            Pressure,
        }

        private string _name;
        public string Name
        {
            get { return _name; }
            private set { _name = value; }
        }

        public Parameter(string name)
        {
            Name = name;
        }

        /// <summary>
        /// only for parameter of third party
        /// </summary>
        /// <param name="name"></param>
        /// <returns></returns>
        public static bool NameEndsWithArea(string name)
        {
            return name.EndsWith("-Area") || name.EndsWith("_Area"); //for FSC-Area, FL1-Log_Area (MoFlo)
        }

        /// <summary>
        /// only for parameter of third party
        /// </summary>
        /// <param name="name"></param>
        /// <returns></returns>
        public static bool NameEndsWithHeight(string name)
        {
            return name.EndsWith("-Height") || name.EndsWith("_Height"); //for FSC-Height, FL1-Log_Height (MoFlo)
        }

        public static ParaType Name2Type(string name)
        {
            if (name == "Width") return ParaType.Width;

            if (name.StartsWith("Ref-L")) return ParaType.Overlap;

            if (name.StartsWith("Weight")) return ParaType.Weight;

            if (name.StartsWith("Pressure")) return ParaType.Pressure;

            if (NameEndsWithArea(name)) return ParaType.Area; //for MoFlo parameter

            if (NameEndsWithHeight(name)) return ParaType.Height; //for MoFlo parameter

            string tail = name.Length > 2 ? name.Substring(name.Length - 2) : string.Empty;

            switch (tail)
            {
                case "-H":
                    return ParaType.Height;
                case "-A":
                    return ParaType.Area;
                case "-W":
                    return ParaType.Width;
                default:
                    return name == "Time" ? ParaType.Time : (name == "Count" ? ParaType.Histogram : ParaType.Other);
            }
        }
    }

    public class Parameters : List<Parameter>
    {
        public Parameter this[string paraName]
        {
            get { return this.FirstOrDefault(para => para.Name == paraName); }
        }

        public Parameters()
        {

        }

        public Parameters(IEnumerable<Parameter> paras) : base(paras)
        {

        }

        /// <summary>
        /// new a parameter list from names and separator width default range
        /// </summary>
        /// <param name="names">the names string</param>
        /// <param name="separator">separtor charactor in names</param>
        public Parameters(string names, char separator)
        {
            string[] paraNames = names.Split(new char[] { separator }, StringSplitOptions.RemoveEmptyEntries);
            foreach (string name in paraNames)
            {
                Add(new Parameter(name));    // this function just for old data
            }
        }

    }
}
