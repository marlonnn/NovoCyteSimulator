using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovoCyteSimulator.LuaScript.LuaInterface
{
    public enum WorkState : int
    {
        WORK_STARTUP = 1,         //表示时序初始化状态
        WORK_IDLE = 2,            //表示待机状态
        WORK_MEASURE = 3,         //表示测试状态
        WORK_MAINTAIN = 4,        //表示维护状态
        WORK_ERROR = 6,           //表示错误处理状态
        WORK_SLEEP = 8,           //表示休眠状态
        WORK_SHUTDOWN = 9,        //表示关机状态
        WORK_INITPRIMING = 10,    //表示首次灌注状态
        WORK_DRAIN = 11,          //表示排空状态
        WORK_SLEEPENTER = 12,     //表示进入休眠状态
        WORK_SLEEPEXIT = 13,      //表示退出休眠状态
        WORK_DECONTAMINATION = 14 //表示消毒状态
    }
    public class ToLua
    {
        private double ticks;
        public double Ticks
        {
            get
            {
                return ticks;
            }
            set
            {
                this.ticks = value;
            }
        }
        //取值为`WORK_STARTUP`、`WORK_IDLE`、`WORK_MEASURE`、`WORK_MAINTAIN`、`WORK_ERROR`、
        //`WORK_SLEEP`、`WORK_SHUTDOWN`、`WORK_INITPRIMING`、`WORK_DRAIN`、`WORK_SLEEPENTER`、`WORK_SLEEPEXIT`、
        //`WORK_DECONTAMINATION`,表示执行的流程
        private int stateto;
        public int Stateto
        {
            get
            {
                return stateto;
            }
            set
            {
                if (value != this.stateto)
                {
                    this.stateto = value;
                }
            }
        }
        //表示下一级参数,对于`WORK_MAINTAIN`表示执行的维护流程,对于`WORK_INITPRIMING`、`WORK_DRAIN`、`WORK_DECONTAMINATION`表示执行步骤
        private int subref1;
        public int Subref1
        {
            get
            {
                return subref1;
            }
            set
            {
                this.subref1 = value;
            }
        }
        //预留
        private int subref2;
        public int Subref2
        {
            get
            {
                return subref2;
            }
            set
            {
                this.subref2 = value;
            }
        }

        //`TEST_IS_ABS`表示绝对计数测试,`TEST_IS_PID`表示PID测试
        private int testsel;

        public int Testsel
        {
            get
            {
                return testsel;
            }
            set
            {
                testsel = value;
            }
        }

        //`true`表示扩展测试,`false`表示正常测试
        private bool isextdata;

        public bool Isextdata
        {
            get
            {
                return isextdata;
            }
            set
            {
                isextdata = value;
            }
        }

        //测试完成后清洗次数
        private int numclean;

        public int Numclean
        {
            get
            {
                return numclean;
            }
            set
            {
                numclean = value;
            }
        }

        //采集样本量,单位:`uL`
        private int size;

        public int Size
        {
            get
            {
                return size;
            }
            set
            {
                this.size = value;
            }
        }

        //推样速度,单位:`uL/min`
        private int rate;

        public int Rate
        {
            get
            {
                return rate;
            }
            set
            {
                rate = value;
            }
        }

        private bool hasAutoSampler;
        public bool HasAutoSampler
        {
            get
            {
                return this.hasAutoSampler;
            }
            set
            {
                this.hasAutoSampler = value;
            }
        }

        private int lowrounds;

        public int Lowrounds
        {
            get
            {
                return this.lowrounds;
            }
            set
            {
                this.lowrounds = value;
            }
        }
        public ToLua()
        {
            this.stateto = (int)WorkState.WORK_IDLE;
            this.subref1 = 1;
            this.subref2 = 0;

            this.hasAutoSampler = false;
            this.lowrounds = 10;
            //设置默认样本量和推样速度
            size = 100;
            rate = 100;

            numclean = 0;
        }
    }
}
