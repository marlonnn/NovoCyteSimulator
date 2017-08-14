using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Timers;

namespace NovoCyteSimulator.LuaInterface
{
    public class Motor
    {
        // id: 电机ID
        private int id;
        public int ID
        {
            get { return id; }
            set { id = value; }
        }

        // microstep: 细分数,取值为`1/2/4/8/16/32/64/128/256`
        private int microstep;
        public int Microstep
        {
            get { return microstep; }
            set { microstep = value; }
        }

        // current: 电流百分比,取值范围为`[0,1]`
        private float currentPercentage;
        public float CurrentPercentage
        {
            get { return currentPercentage; }
            set { currentPercentage = value; }
        }

        private int current;
        public int Current
        {
            get { return current; }
            set { current = value; }
        }

        // alpha: 电机加速度,默认值为`4800rpm/s`
        private int alpha;
        public int Alpha
        {
            get { return alpha; }
            set { alpha = value; }
        }

        //当前转动圈数(单位:`r`)
        private double round;
        public double Round
        {
            get
            {
                lock (this)
                    return round;
            }
            set
            {
                lock (this)
                {
                    round = value;
                }
            }
        }

        private double totalRound;
        public double TotalRound
        {
            get
            {
                lock (this)
                    return totalRound;
            }
            set
            {
                lock (this)
                {
                    totalRound = value;
                }
            }
        }

        //当前转速(单位:`rpm`)
        private double speed;
        public double Speed
        {
            get
            {
                lock (this)
                    return speed;
            }
            set
            {
                lock (this)
                {
                    speed = value;
                }
            }
        }

        private bool isStop;

        private double constantSpeed;
        public double ConstantSpeed
        {
            get
            {
                lock (this)
                    return constantSpeed;
            }
            set
            {
                lock (this)
                {
                    constantSpeed = value;
                }
            }
        }

        private double totalTime;
        public double TotalTime
        {
            get
            {
                lock (this)
                    return totalTime;
            }
            set
            {
                lock (this)
                {
                    totalTime = value;
                }
            }
        }
        public Motor(int id)
        {
            this.id = id;
            //电机加速度,默认值为`4800rpm/s`
            this.alpha = 4800;
            isStop = true;
            InitializeTimer();
            //InitializeMotorThread();
        }

        private void InitializeMotorThread()
        {
            motorThread = new Thread(new ThreadStart(Run));
            motorThread.IsBackground = true;
            //motorThread.Start();
        }

        private double currentTime;
        public double CurrentTime
        {
            get
            {
                lock (this)
                {
                    return currentTime;
                }
            }
            set
            {
                lock(this)
                {
                    this.currentTime = value;
                }
            }
        }
        private Thread motorThread;

        private void Run()
        {
            this.Speed = this.ConstantSpeed * 600;
            this.Round = this.ConstantSpeed * this.CurrentTime;
            if (this.CurrentTime - this.TotalTime > 0)
            {
                stop();
            }
            this.CurrentTime += 100;
            //Console.WriteLine("---motor id: " + id);
            //Console.WriteLine("---time tick round: " + round);
            //Console.WriteLine("---time tick speed: " + speed);
        }

        private System.Threading.Timer stateTimer;
        private AutoResetEvent autoEvent;
        private void InitializeTimer()
        {
            autoEvent = new AutoResetEvent(false);

            Console.WriteLine("{0:h:mm:ss.fff} id: {1} Creating timer.\n",
                              DateTime.Now, id);
            stateTimer = new System.Threading.Timer(CheckStatus,
                                   autoEvent, 0, 100);
        }
        private int invokeCount = 0;

        // This method is called by the timer delegate.
        public void CheckStatus(Object stateInfo)
        {
            if (!isStop)
            {
                AutoResetEvent autoEvent = (AutoResetEvent)stateInfo;
                //Console.WriteLine("id: {0},  {1} Checking status {2,3}.",
                //    id, DateTime.Now.ToString("h:mm:ss.fff"),
                //    (++invokeCount).ToString());
                this.Speed = this.ConstantSpeed * 600;//转/毫秒
                this.Round = this.ConstantSpeed * this.CurrentTime / 1000;
                //Console.WriteLine("id: {0}, Speed: {1} ", id, Speed);
                //Console.WriteLine("id: {0}, Round: {1} ", id, Round);
                if (this.CurrentTime - this.TotalTime > 0)
                {
                    // Reset the counter and signal the waiting thread.
                    isStop = true;
                    this.currentTime = 0;
                    this.totalTime = 0;
                    this.speed = 0;
                    this.round = 0;
                    autoEvent.Set();
                }
                this.CurrentTime += 100;
            }
            else
            {
                autoEvent.Set();
            }
        }

        /// <summary>
        /// 控制电机转动
        /// </summary>
        /// <param name="round">转动总圈数(单位:`r`)</param>
        /// <param name="speed">转速,带方向(单位:`rpm`)</param>
        public void run(double round, double speed)
        {
            isStop = true;
            this.TotalRound = round;
            this.ConstantSpeed = speed < 0 ? -speed / 600 : speed / 600; //转/分 --> 转/100毫秒
            this.TotalTime = (round / this.ConstantSpeed) * 1000;//需要运行的时间
            this.CurrentTime = 0;
            //Console.WriteLine("id: {0}, round:{1}, speed:{2}, totalTime:{2} ms ", id, round, TotalTime);
            isStop = false;
            autoEvent.WaitOne();
            
        }

        public void chspeed(int newspeed)
        {
            //this.Speed = newspeed < 0 ? -newspeed : newspeed;
        }

        public void stop()
        {
            isStop = true;
            this.currentTime = 0;
            this.totalTime = 0;
            this.speed = 0;
            this.round = 0;
        }

        public bool isstop()
        {
            return isStop;
        }

        public void reset()
        {
            this.isStop = true;
            this.speed = 0;
            this.round = 0;
            this.currentTime = 0;
            this.totalTime = 0;
        }
    }
}
