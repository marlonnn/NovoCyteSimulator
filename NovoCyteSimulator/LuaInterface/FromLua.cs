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
                this.state = value;
            }
        }

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
        private int tstart; 
        public int Tstart
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
        private int ttotal; 
        public int Ttotal
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
        public FromLua()
        {

        }
    }
}
