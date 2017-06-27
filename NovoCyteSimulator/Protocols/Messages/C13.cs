using NovoCyteSimulator.Equipment;
using NovoCyteSimulator.Messages;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovoCyteSimulator.Protocols.Messages
{
    public class C13 : CBase
    {
        public enum LASER_Type : byte
        {
            LASER_None = 0, // 激光器不存在
            LASER_Exist = 1, // 激光器存在(为了兼容旧的)
            LASER_405nm = 2, // 激光器为405nm
            LASER_488nm = 3, // 激光器为488nm
            LASER_640nm = 4, // 激光器为640nm
            LASER_561nm = 5 // 激光器为561nm
        }

        private LASER_Type GetLaserType(string waveLenght)
        {
            LASER_Type type = LASER_Type.LASER_None;
            switch (waveLenght)
            {
                case "0":
                    type = LASER_Type.LASER_None;
                    break;
                case "1":
                    type = LASER_Type.LASER_Exist;
                    break;
                case "405nm":
                    type = LASER_Type.LASER_405nm;
                    break;
                case "488nm":
                    type = LASER_Type.LASER_488nm;
                    break;
                case "640nm":
                    type = LASER_Type.LASER_640nm;
                    break;
                case "561nm":
                    type = LASER_Type.LASER_561nm;
                    break;
            }
            return type;
        }

        public C13()
        {
            this.message = 0x13;
        }

        /// <summary>
        /// 获取仪器配置信息
        /// </summary>
        /// <returns></returns>
        public byte[] CreateDeviceConfigParam()
        {
            byte[] param = new byte[6];
            LaserParas[] lasers = config.Device.Laser;
            param[0] = (byte)GetLaserType(lasers[0].Typeis);
            param[1] = (byte)GetLaserType(lasers[1].Typeis);
            param[2] = (byte)GetLaserType(lasers[2].Typeis);

            param[3] = (byte)config.Device.AutoSampleConnectStateType;
            param[4] = config.Device.PMT.MaskSel;
            param[5] = (byte)config.Device.WeightType;
            return param;
        }

        public override bool Decode(byte[] buf)
        {
            return this.Decode(message, buf, out parameter);
        }

        public override byte[] Encode()
        {
            byte[] param = CreateDeviceConfigParam();
            return this.Encode(message, param);
        }
    }
}
