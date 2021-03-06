﻿using System;
using System.Diagnostics;
using System.Threading;

namespace NovoCyteSimulator.LuaScript.LuaInterface
{
    public enum WOEK_QUIT : int
    {
        WORK_QUIT_Wait = 0, //等待时序节点
        WORK_QUIT_Next = 1, //下一个时序节点
        WORK_QUIT_Normal = 2,//正常退出
        WORK_QUIT_Abort = 3,// 异常中断退出
    }
    public class SubWork
    {
        public WOEK_QUIT workQuit;
        private ToLua toLua;
        public ToLua ToLua
        {
            get
            {
                return this.toLua;
            }
        }

        private FromLua fromLua;

        public FromLua FromLua
        {
            get
            {
                return this.fromLua;
            }
        }

        public static SubWork subwork;

        private Stopwatch stopwatch;

        private double itemTicks;
        public double ItemTicks
        {
            get
            {
                return itemTicks;
            }
            set
            {
                if (value != itemTicks)
                {
                    itemTicks = value;
                    currentTicks += itemTicks;
                }
            }
        }

        private double currentTicks;

        public double Ticks
        {
            get
            {
                return currentTicks;
            }
            set
            {
                currentTicks = value;
            }
        }

        public SubWork()
        {
            toLua = new ToLua();
            fromLua = new FromLua();
            stopwatch = new Stopwatch();
            workQuit = WOEK_QUIT.WORK_QUIT_Wait;
        }

        public static SubWork GetSubWork()
        {
            if (subwork == null)
            {
                subwork = new SubWork();
            }
            return subwork;
        }

        // 读取需要执行的流程,NovoExpress传递过来的控制参数
        // stateto: 取值为`WORK_STARTUP`、`WORK_IDLE`、`WORK_MEASURE`、`WORK_MAINTAIN`、`WORK_ERROR`、`WORK_SLEEP`、`WORK_SHUTDOWN`、`WORK_INITPRIMING`、`WORK_DRAIN`、`WORK_SLEEPENTER`、`WORK_SLEEPEXIT`、`WORK_DECONTAMINATION`,表示执行的流程
        // subref1: 表示下一级参数,对于`WORK_MAINTAIN`表示执行的维护流程,对于`WORK_INITPRIMING`、`WORK_DRAIN`、`WORK_DECONTAMINATION`表示执行步骤
        // subref2: 预留
        public void ctrlto(out int stateto, out int subref1, out int subref2)
        {
            stateto = toLua.Stateto;
            subref1 = toLua.Subref1;
            subref2 = toLua.Subref2;
        }

        // subwork.stateset(state, ref1, ref2)
        // 设置系统相关状态,用于NovoExpress状态的显示
        // state: 主状态,表示系统处于哪个流程,取值为`WORK_STARTUP`、`WORK_IDLE`、
        // `WORK_MEASURE`、`WORK_MAINTAIN`、`WORK_ERROR`、`WORK_SLEEP`、`WORK_SHUTDOWN`、`WORK_INITPRIMING`、
        // `WORK_DRAIN`、`WORK_SLEEPENTER`、`WORK_SLEEPEXIT`、`WORK_DECONTAMINATION`
        // ref1: 表示一级子状态
        // ref2: 表示二级子状态
        public void stateSet(int state, int ref1, int ref2)
        {
            fromLua.State = state;
            fromLua.Ref1 = ref1;
            fromLua.Ref2 = ref2;
            if (state == (int)WorkState.WORK_IDLE)
            {
                SubWork.GetSubWork().workQuit = WOEK_QUIT.WORK_QUIT_Wait;
            }
            Console.WriteLine(string.Format("state to: {0}, sub state: {1}", fromLua.State, fromLua.Ref1));
        }

        // 设置流程时间,用于NovoExpress显示时间
        // tstart: 表示流程起始时刻的节拍数
        // ttotal: 表示流程执行总节拍数
        public void timeset(double tstart, double ttotal)
        {
            fromLua.Tstart = tstart;
            fromLua.Ttotal = ttotal;
            //Console.WriteLine(string.Format("tstart: {0}, ttotal: {1}" , tstart, ttotal));
        }

        // 启动一个alarm
        // nticks: alarm定时节拍数
        public void alarmstart(double nticks)
        {
            //Console.WriteLine("alarm start: " + nticks);
            ItemTicks = nticks;
            stopwatch.Reset();
            stopwatch.Start();
        }

        // 关闭alarm
        public void alarmstop()
        {
            //Console.WriteLine("alarm stop");
            stopwatch.Stop();
        }

        // 等待一个时序节点的执行
        // awake: 等待过程中每隔awake个节拍唤醒查询一些相关信息,0表示不唤醒 awake 节拍数
        // result: 等待结果取值为`WORK_QUIT_Wait`、`WORK_QUIT_Next`、`WORK_QUIT_Normal`、`WORK_QUIT_Abort`
        public int alarmwait(double awake)
        {
            int state = (int)WOEK_QUIT.WORK_QUIT_Wait;
            //Console.WriteLine(string.Format("awake time: {0}, item ticks: {1}", awake, itemTicks));
            if (awake != 0)
            {
                Thread.Sleep(50);
                double ticks = stopwatch.Elapsed.Ticks / 50000;
                if (CompareDoubleTicks(ticks, itemTicks))
                {
                    alarmstop();
                    state = (int)WOEK_QUIT.WORK_QUIT_Next;
                    Console.WriteLine(string.Format("work state: {0}", WOEK_QUIT.WORK_QUIT_Next.ToString()));
                }
            }
            return state;
        }

        /// <summary>
        /// 判断上位机是否发送命令在ticks时间范围
        /// 有：WORK_QUIT_Normal
        /// 默认：WORK_QUIT_Wait
        /// </summary>
        /// <param name="ticks"></param>
        /// <returns></returns>
        public int idlewait(double ticks)
        {
            //To do
            Thread.Sleep((int)ticks * 5);
            Console.WriteLine(string.Format("idle wait,  work quit : {0}", workQuit.ToString()));
            return (int)workQuit;
        }

        private bool CompareDoubleTicks(double ticks, double itemTicks)
        {
            //Console.WriteLine(string.Format("ticks: {0}, itemTicks: {1} ", ticks, itemTicks));
            if (ticks - itemTicks > 0 && ticks - itemTicks <= 500)
            {
                return true;
            }
            else
            {
                return false;
            }
        }

        // pid控制
        // opt:相关操作,取值为`PID_Stop`、`PID_Start`、`PTC_Start`、`PTC_Stop`
        public void pidcontrol(int opt)
        {
            fromLua.Opt = opt;
            //Console.WriteLine("pid control: " + opt);
        }

        public void testinfoget(out int testsel, out bool isextdata, out int numclean)
        {
            testsel = toLua.Testsel;
            isextdata = toLua.Isextdata;
            numclean = toLua.Numclean;
        }

        public void testinfoset(double testsecs, double testsize)
        {
            fromLua.Testsecs = testsecs;
            fromLua.Testsize = testsize;
        }

        public void sampleinfo(out int size, out int rate)
        {
            size = toLua.Size;
            rate = toLua.Rate;
        }

        //配置细胞采集模块
        public void cellconfig()
        {

        }

        /// <summary>
        /// 启动细胞参数采集
        /// </summary>
        /// <returns></returns>
        public bool cellstart()
        {
            //startTime = (DateTime.UtcNow - new DateTime(1970, 1, 1)).TotalMilliseconds;
            Console.WriteLine("cell start");
            return true;
        }

        public void cellstop(int stopway)
        {
        }

        public bool cellisstop()
        {
            return false;
        }

        public void samplerounds(out bool hasAutoSampler, out int lowrounds )
        {
            hasAutoSampler = toLua.HasAutoSampler;
            lowrounds = toLua.Lowrounds;
        }

        public void Print(object obj)
        {
            if (obj != null)
            {
                Console.WriteLine("<---sub work print--->" + obj.ToString());
            }
            else
            {
                Console.WriteLine("-------------->: this object is null" );
            }

        }
    }
}
