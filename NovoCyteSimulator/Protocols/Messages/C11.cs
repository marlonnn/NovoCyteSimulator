using NovoCyteSimulator.LuaScript.LuaInterface;
using NovoCyteSimulator.Messages;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovoCyteSimulator.Protocols.Messages
{
    //读取仪器状态
    public class C11 : CBase
    {
        private SubWork subwork;

        public C11()
        {
            this.message = 0x11;
        }

        public byte[] CreateDeviceWorkingStateParam()
        {
            byte[] param = new byte[35];
            byte[] M1 = new byte[4];
            subwork = SubWork.GetSubWork();
            int workMode = (int)subwork.FromLua.State;
            M1[0] = (byte)(workMode);
            M1[1] = (byte)(workMode >> 8);
            M1[2] = (byte)(workMode >> 16);
            M1[3] = (byte)(workMode >> 24);
            Array.Copy(M1, 0, param, 0, 4);

            byte[] M2 = new byte[4];
            int state = subwork.FromLua.Ref1;
            M2[0] = (byte)(state);
            M2[1] = (byte)(state >> 8);
            M2[2] = (byte)(state >> 16);
            M2[3] = (byte)(state >> 24);
            //switch (config.Device.SystemMainWorkMode)
            //{
            //    case Equipment.Device.ESystemMainWorkMode.WM_Testing:
            //        state = (int)config.Device.MeasState;
            //        M2[0] = (byte)(state);
            //        M2[1] = (byte)(state >> 8);
            //        M2[2] = (byte)(state >> 16);
            //        M2[3] = (byte)(state >> 24);
            //        break;
            //    case Equipment.Device.ESystemMainWorkMode.WM_FlowMaintenance:
            //        state = (int)config.Device.FlowMaintainMode;
            //        M2[0] = (byte)(state);
            //        M2[1] = (byte)(state >> 8);
            //        M2[2] = (byte)(state >> 16);
            //        M2[3] = (byte)(state >> 24);
            //        break;
            //    case Equipment.Device.ESystemMainWorkMode.WM_FirstPriming:
            //    case Equipment.Device.ESystemMainWorkMode.WM_Drain:
            //        //M2 - H | M2 - L
            //        //INT16U | INT16U
            //        //M2 - H为M2的高字节,0表示执行完成,1表示执行中
            //        //M2 - L为M2的低字节,表示执行的步骤
            //        //M2 = 0表示等待上位机命令
            //        break;
            //    case Equipment.Device.ESystemMainWorkMode.WM_ErrorHandle:
            //        //M2为错误代码值，表示正在执行的错误处理
            //        break;
            //    case Equipment.Device.ESystemMainWorkMode.WM_ShutDown:
            //        //M2 - H | M2 - L
            //        //INT16U | INT16U
            //        //M2 - H为M2的高字节,0表示执行完成,1表示执行中
            //        //M2 - L为M2的低字节,表示执行的步骤
            //        //M2 = 0表示正常关机流程
            //        break;
            //}
            Array.Copy(M2, 0, param, 4, 4);

            //当前警告数
            byte[] W = new byte[2];
            Array.Copy(W, 0, param, 8, 2);

            //当前错误个数
            byte[] E = new byte[2];
            Array.Copy(E, 0, param, 10, 2);

            //测试开始时间
            byte[] T = new byte[4];
            //double time = (double)SubWork.GetSubWork().StartTime;
            //double elapseTime = (DateTime.UtcNow - new DateTime(1970, 1, 1)).TotalMilliseconds - time;
            int time = (int)SubWork.GetSubWork().FromLua.Testsecs;
            //T = BitConverter.GetBytes(elapseTime);
            T[0] = (byte)(time);
            T[1] = (byte)(time >> 8);
            T[2] = (byte)(time >> 16);
            T[3] = (byte)(time >> 24);
            Array.Copy(T, 0, param, 12, 4);

            //测试样本量
            //byte[] V = new byte[4];
            float volum = (float)SubWork.GetSubWork().FromLua.Testsize;
            //V[0] = (byte)(volum);
            //V[1] = (byte)(volum >> 8);
            //V[2] = (byte)(volum >> 16);
            //V[3] = (byte)(volum >> 24);
            var bytes = BitConverter.GetBytes(volum);
            Array.Copy(bytes, 0, param, 16, 4);

            //重力传感器检测是否使能(0：关闭，1：开启)
            //byte C = novoCyteConfig.Config.Device.GravitySensorDetectionEnable;
            param[20] = config.Device.GravitySensorDetectionEnable;
            //Console.WriteLine("startTime:{0}, volum:{1}, " , time, volum);
            
            //流程执行的节拍数
            byte[] t1 = new byte[4];
            int ticks = (int)SubWork.GetSubWork().FromLua.Testsecs;
            t1[0] = (byte)(ticks);
            t1[1] = (byte)(ticks >> 8);
            t1[2] = (byte)(ticks >> 16);
            t1[3] = (byte)(ticks >> 24);
            Array.Copy(t1, 0, param, 21, 4);

            //总节拍数
            byte[] t2 = new byte[4];
            int TotalTicks = subwork.FromLua.Ttotal;
            t2[0] = (byte)(TotalTicks);
            t2[1] = (byte)(TotalTicks >> 8);
            t2[2] = (byte)(TotalTicks >> 16);
            t2[3] = (byte)(TotalTicks >> 24);
  
            Array.Copy(t2, 0, param, 25, 4);
            //Console.WriteLine("ticks:{0}, totalTicks:{1}, " , ticks, TotalTicks);
            //AutoSampler联机状态
            param[29] = (byte)config.Device.AutoSampleConnectStateType;

            //QC状态
            param[30] = (byte)config.Device.QCStateType;

            //子状态
            byte[] M3 = new byte[4];

            int M2State = BitConverter.ToInt32(M2, 0);
            if (M2State == (int)config.Device.BoostingState)
            {
                state = (int)config.Device.BoostingState;
                M3[0] = (byte)(state);
                M3[1] = (byte)(state >> 8);
                M3[2] = (byte)(state >> 16);
                M3[3] = (byte)(state >> 24);
            }
            else if (M2State == (int)config.Device.TestingState)
            {
                state = (int)config.Device.TestingState;
                M3[0] = (byte)(state);
                M3[1] = (byte)(state >> 8);
                M3[2] = (byte)(state >> 16);
                M3[3] = (byte)(state >> 24);
            }
            Array.Copy(M3, 0, param, 31, 4);
            return param;
        }

        public override bool Decode(byte[] buf)
        {
            return this.Decode(message, buf, out parameter);
        }

        public override byte[] Encode()
        {
            byte[] param = CreateDeviceWorkingStateParam();
            return this.Encode(message, param);
        }
    }
}
