using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovoCyteSimulator.LuaScript.LuaInterface
{
    public class FromLua
    {
        //主状态,表示系统处于哪个流程,取值为`WORK_STARTUP`、`WORK_IDLE`、`WORK_MEASURE`、
        //`WORK_MAINTAIN`、`WORK_ERROR`、`WORK_SLEEP`、`WORK_SHUTDOWN`、`WORK_INITPRIMING`、
        //`WORK_DRAIN`、`WORK_SLEEPENTER`、`WORK_SLEEPEXIT`、`WORK_DECONTAMINATION`
        private int state;
        public int State
        {
            get
            {
                return state;
            }
            set
            {
                if (value != this.state)
                {
                    this.state = value;
                    Console.WriteLine("FromLua state to:" + state);
                    StateChangeHandler?.Invoke();
                }
            }
        }

        public delegate void StateChange();
        public StateChange StateChangeHandler;
        //表示一级子状态
        private int ref1;
        public int Ref1
        {
            get
            {
                return ref1;
            }
            set
            {
                this.ref1 = value;
            }
        }

        //表示二级子状态
        private int ref2;
        public int Ref2
        {
            get
            {
                return ref2;
            }
            set
            {
                this.ref2 = value;
            }
        }

        //表示流程起始时刻的节拍数
        private double tstart; 
        public double Tstart
        {
            get
            {
                return tstart;
            }
            set
            {
                this.tstart = value;
            }
        }
        // 表示流程执行总节拍数
        private double ttotal; 
        public double Ttotal
        {
            get
            {
                return ttotal;
            }
            set
            {
                this.ttotal = value;
            }
        }

        //opt:相关操作,取值为`PID_Stop`、`PID_Start`、`PTC_Start`、`PTC_Stop`
        private int opt;

        public int Opt
        {
            get
            {
                return opt;
            }
            set
            {
                opt = value;
            }
        }

        private double testsecs;
        public double Testsecs
        {
            get
            {
                return testsecs;
            }
            set
            {
                testsecs = value;
            }
        }

        private double testsize;
        public double Testsize
        {
            get
            {
                return testsize;
            }
            set
            {
                testsize = value;
            }
        }
        public FromLua()
        {
            this.state = (int)WorkState.WORK_IDLE;
        }
    }
}
