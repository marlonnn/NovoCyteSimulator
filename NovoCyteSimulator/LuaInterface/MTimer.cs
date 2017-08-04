using System;
using System.Diagnostics;
using System.Threading;

namespace NovoCyteSimulator.LuaScript.LuaInterface
{
    public class MTimer
    {
        public static MTimer timer;
        private Stopwatch stopwatch;
        public Stopwatch Stopwatch
        {
            get
            {
                return this.stopwatch;
            }
        }
        public MTimer()
        {
            stopwatch = new Stopwatch();
            stopwatch.Start();
        }

        public static MTimer GetTimer()
        {
            if (timer == null)
            {
                timer = new MTimer();
            }
            return timer;
        }

        /// <summary>
        /// 获取系统当前节拍数
        /// 1s = 200节拍数
        /// 1节拍数 = 5微秒
        /// 1微妙 = 0.2节拍数
        /// Stopwatch中： 
        /// 1s = 1e7节拍数
        /// 1节拍数 = 10000微秒，所以需要转换，当前节拍数除以50000
        /// </summary>
        /// <returns></returns>
        public double systicks()
        {
            //ticks = stopwatch.Elapsed.Ticks / 50000;
            //SubWork.GetSubWork().ToLua.Ticks = ticks;
            return stopwatch.Elapsed.Ticks / 50000;
        }

        /// <summary>
        /// 获取系统每秒节拍数
        /// </summary>
        /// <returns></returns>
        public int tickspersec()
        {
            return 200;
        }

        public int tickspermin()
        {
            return 12000;
        }

        public void delayms(int ms)
        {
            Thread.Sleep(ms);
        }

        public void delays(int sec)
        {
            Thread.Sleep(sec * 1000);
        }

        public void Start()
        {
            stopwatch.Reset();
            stopwatch.Start();
        }

        public void Stop()
        {
            stopwatch.Stop();
        }

        public void TestStopWatch()
        {
            Start();
            // Do something
            for (int i = 0; i < 1000; i++)
            {
                Thread.Sleep(1);
            }

            // Stop timing
            stopwatch.Stop();

            // Write result
            Console.WriteLine("Time elapsed (s): {0}", stopwatch.Elapsed.TotalSeconds);
            Console.WriteLine("Time elapsed (ms): {0}", stopwatch.Elapsed.TotalMilliseconds);
            Console.WriteLine("Time elapsed (ns): {0}", stopwatch.Elapsed.TotalMilliseconds * 1000000);
            var v = stopwatch.Elapsed.Ticks / stopwatch.Elapsed.TotalMilliseconds;
            var v1 = stopwatch.Elapsed.Ticks / 50000;
            //var v3 = systicks();
            var v2 = v1 / stopwatch.Elapsed.TotalMilliseconds;
            Console.WriteLine("Time elapsed (ticks): {0}", stopwatch.Elapsed.Ticks);
        }
    }
}
