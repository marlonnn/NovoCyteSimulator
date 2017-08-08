using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Threading.Tasks;

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
            get { return round; }
            set { round = value; }
        }

        private double totalRound;

        //当前转速(单位:`rpm`)
        private double speed;
        public double Speed
        {
            get { return speed; }
            set { speed = value; }
        }

        private bool isStop;

        private double constantSpeed;
        private Timer timer;

        private double totalTime;
        public Motor(int id)
        {
            this.id = id;
            //电机加速度,默认值为`4800rpm/s`
            this.alpha = 4800;
            isStop = true;
        }

        private void InitializeTimer()
        {
            timer = new Timer();
            timer.Interval = 100;
            timer.Enabled = false;
            timer.Tick += Timer_Tick;
        }

        private double currentTime;

        private void Timer_Tick(object sender, EventArgs e)
        {
            currentTime += 0.1;
            switch (this.motorMode.Mode)
            {
                case "Triangle":
                    if (currentTime - this.motorMode.AccTime > 0)
                    {
                        this.timer.Enabled = false;
                        this.isStop = true;
                        this.speed = 0;
                        this.round = 0;
                        currentTime = 0;
                    }
                    else if (currentTime < this.motorMode.AccTime / 2)//匀加速
                    {
                        this.isStop = false;
                        this.speed = this.alpha * currentTime;
                        this.round = this.speed * currentTime / 2;
                    }
                    else if (currentTime > this.motorMode.AccTime / 2)//匀减速
                    {
                        this.isStop = false;
                        this.speed = this.alpha * this.motorMode.AccTime / 2 - (currentTime - this.motorMode.AccTime / 2) * this.alpha;
                        this.round = 2 * this.alpha * Math.Pow((this.motorMode.AccTime / 2), 2) - this.speed * (currentTime - this.motorMode.AccTime / 2) / 2;
                    }
                    break;
                case "Trapezpoid":
                    if (currentTime - this.motorMode.AccTime - this.motorMode .ConstTime> 0)
                    {
                        this.timer.Enabled = false;
                        this.isStop = true;
                        this.speed = 0;
                        this.round = 0;
                        currentTime = 0;
                    }
                    else if (currentTime < this.motorMode.AccTime / 2)
                    {
                        //先匀加速
                        this.isStop = false;
                        this.speed = this.alpha * currentTime;
                        this.round = this.speed * currentTime / 2;
                    }
                    else if (currentTime > this.motorMode.AccTime / 2 && currentTime < this.motorMode.AccTime / 2 + this.motorMode.ConstTime)
                    {
                        //匀速
                        this.isStop = false;
                        this.speed = this.constantSpeed;
                        this.round = this.speed * this.motorMode.AccTime / 4 + this.speed * (currentTime - this.motorMode.AccTime / 2);
                    }
                    else if (currentTime > this.motorMode.AccTime / 2 + this.motorMode.ConstTime && currentTime < this.motorMode.AccTime + this.motorMode.ConstTime)
                    {
                        //匀减速
                        this.isStop = false;
                        this.speed = this.constantSpeed - (currentTime - this.motorMode.AccTime / 2 - this.motorMode.ConstTime) * this.alpha;
                        this.round = this.constantSpeed * this.motorMode.AccTime / 2 + this.constantSpeed * this.motorMode.ConstTime - this.speed * (this.motorMode.AccTime + this.motorMode.ConstTime - currentTime) / 2;
                    }
                    break;
            }
        }

        /// <summary>
        /// 控制电机转动
        /// </summary>
        /// <param name="round">转动总圈数(单位:`r`)</param>
        /// <param name="speed">转速,带方向(单位:`rpm`)</param>
        public void run(double round, double speed)
        {
            this.totalRound = round;
            this.constantSpeed = speed;
            double time = this.constantSpeed / this.alpha;
            double constantRound = this.constantSpeed * time / 2;
            if (constantRound > round)
            {
                //未达到speed前就匀减速运动
                var value = (4 * this.totalRound) / this.alpha;
                this.totalTime = Math.Sqrt(value);
                this.motorMode = new MotorMode("Triangle", this.totalTime, 0d);
            }
            else
            {
                //先匀加速，匀速，再匀减速运动
                var t1 = speed / this.alpha;//匀加速时间
                var s = speed * t1;//匀加速和匀减速的圈数
                var s1 = round - s;//匀速的圈数
                var t2 = s1 / speed;
                this.totalTime = 2 * t1 + t2;
                this.motorMode = new MotorMode("Trapezpoid", 2* t1, t2);
            }

            timer.Enabled = true;
        }
        private MotorMode motorMode;
        public class MotorMode
        {
            private string mode;
            public string Mode
            {
                get { return mode; }
                set { mode = value; }
            }
            //匀加速、匀减速时间
            private double accTime;
            public double AccTime
            {
                get { return accTime; }
                set { this.accTime = value; }
            }
            //匀速运动时间
            private double constTime;
            public double ConstTime
            {
                get { return constTime; }
                set { constTime = value; }
            }
            public MotorMode(string mode, double accTime, double constTime)
            {
                this.mode = mode;
                this.accTime = accTime;
                this.constTime = constTime;
            }
        }

        public void chspeed(int newspeed)
        {
            //this.Speed = newspeed < 0 ? -newspeed : newspeed;
        }

        public void stop()
        {
            isStop = true;
            this.timer.Enabled = false;
        }

        public bool isstop()
        {
            return isStop;
        }
    }
}
