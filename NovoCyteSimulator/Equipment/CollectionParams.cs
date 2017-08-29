using NovoCyteSimulator.LuaScript.LuaInterface;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovoCyteSimulator.Equipment
{
    /// <summary>
    /// 细胞采集参数
    /// </summary>
    public class CollectionParams
    {
        public static CollectionParams cParams;
        public CollectionParams()
        {
            this.size = 100;
        }

        public static CollectionParams GetCollectionParams()
        {
            if (cParams == null)
            {
                cParams = new CollectionParams();
            }
            return cParams;
        }

        public void SetParams(ushort time, uint points, ushort size)
        {
            this.time = time;
            this.points = points;
            this.size = size;
        }

        /// <summary>
        /// 达到测试预设时间
        /// </summary>
        /// <returns></returns>
        public bool ArrivedTime()
        {
            if (this.time == 0)
            {
                return false;
            }
            else
            {
                double time = SubWork.GetSubWork().FromLua.Testsecs * 5;
                TimeSpan duration = TimeSpan.FromMilliseconds(time);
                int mins = (int)duration.TotalMinutes;
                int secs = (int)Math.Round(duration.TotalSeconds - mins * 60);
                if (secs == 60)
                {
                    mins++;
                    secs = 0;
                }
                int totalseconds = mins * 60 + secs;
                if (totalseconds == this.time || DoubleEquals(totalseconds, this.time))
                {
                    SubWork.GetSubWork().ToLua.Stateto = (int)WorkState.WORK_IDLE;
                    SubWork.GetSubWork().workQuit = WOEK_QUIT.WORK_QUIT_Wait;
                    SubWork.GetSubWork().ToLua.Subref1 = 0;
                    SubWork.GetSubWork().ToLua.Subref2 = 0;
                    return true;
                }
                else
                {
                    return false;
                }
            }
        }

        /// <summary>
        /// 达到测试预设体积
        /// </summary>
        /// <returns></returns>
        public bool ArrivedSize()
        {
            double volumn = SubWork.GetSubWork().FromLua.Testsize;
            if (volumn == this.size || DoubleEquals(volumn, this.size))
            {
                SubWork.GetSubWork().ToLua.Stateto = (int)WorkState.WORK_IDLE;
                SubWork.GetSubWork().workQuit = WOEK_QUIT.WORK_QUIT_Wait;
                SubWork.GetSubWork().ToLua.Subref1 = 0;
                SubWork.GetSubWork().ToLua.Subref2 = 0;
                return true;
            }
            else
            {
                return false;
            }
        }

        private bool DoubleEquals(double a, double b)
        {
            return Math.Abs(a - b) < 0.05;
        }

        private ushort time;

        public ushort Time
        {
            get
            {
                return time;
            }
            set
            {
                time = value;
            }
        }

        private uint points; 
        public uint Points
        {
            get
            {
                return points;
            }
            set
            {
                points = value;
            }
        }

        private ushort size;
        public ushort Size
        {
            get
            {
                return size;
            }
            set
            {
                size = value;
            }
        }
    }
}
