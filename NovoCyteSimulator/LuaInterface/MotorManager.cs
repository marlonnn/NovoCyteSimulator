using NovoCyteSimulator.LuaScript.LuaInterface;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovoCyteSimulator.LuaInterface
{
    public enum MOTOR
    {
        SMOTOR = 0,// SMotor(样本针电机) ID号
        IMOTOR = 1,// IMotor(注射器) ID号
        PMOTOR = 2 // PMotor(FMI泵) ID号
    }
    public class MotorManager
    {
        public static MotorManager motor;
        private ToLua toLua;

        private List<Motor> motors;
        public MotorManager()
        {
            toLua = new ToLua();
            InitializeMotors();
        }

        private void InitializeMotors()
        {
            motors = new List<Motor>();
            motors.Add(new Motor((int)MOTOR.SMOTOR));
            motors.Add(new Motor((int)MOTOR.IMOTOR));
            motors.Add(new Motor((int)MOTOR.PMOTOR));
        }

        public static MotorManager GetMotor()
        {
            if (motor == null)
            {
                motor = new MotorManager();
            }
            return motor;
        }

        public void config(int id, int microstep, float currentPercentage)
        {
            foreach (Motor m in motors)
            {
                if (m.ID == id)
                {
                    m.Microstep = microstep;
                    m.CurrentPercentage = currentPercentage;
                }
            }
        }

        /// <summary>
        /// 控制电机转动
        /// </summary>
        /// <param name="id"> 电机ID </param>
        /// <param name="round">转动总圈数(单位:`r`) </param>
        /// <param name="speed">转速,带方向(单位:`rpm`)</param>
        public void run(int id, int round, int speed)
        {
            motors[id].run(round, speed);
        }

        /// <summary>
        /// 获取电机状态
        /// </summary>
        /// <param name="id">电机ID</param>
        /// <param name="round">当前转动圈数(单位:`r`)</param>
        /// <param name="speed">当前转速(单位:`rpm`)</param>
        /// <param name="microstep">微步数</param>
        /// <param name="current">电流</param>
        public void status(int id, out double round, out double speed, out int microstep, out int current)
        {
            round = motors[id].Round;
            speed = motors[id].Speed;
            microstep = motors[id].Microstep;
            current = motors[id].Current;
        }

        /// <summary>
        /// 改变电机转速
        /// </summary>
        /// <param name="id"></param>
        /// <param name="newspeed">新的转速,带方向(单位:`rpm`)</param>
        public void chspeed(int id, int newspeed)
        {
            motors[id].Speed = newspeed;
        }

        /// <summary>
        /// 检查电机是否停止
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        public bool isstop(int id)
        {
            return motors[id].isstop();
        }

        /// <summary>
        /// 控制电机停止转动
        /// </summary>
        /// <param name="id"></param>
        public void stop(int id)
        {
            motors[id].stop();
        }
    }
}
