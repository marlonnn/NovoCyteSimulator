using NovoCyteSimulator.Equipment;
using Summer.System.Log;
using System;

namespace NovoCyteSimulator.Messages
{
    public abstract class CBase
    {
        protected Config config;

        protected byte message;
        /// <summary>
        /// message
        /// </summary>
        public byte Message
        {
            get
            {
                return message;
            }
            set
            {
                message = value;
            }
        }

        protected byte[] parameter;
        /// <summary>
        /// parameter
        /// </summary>
        public byte[] Parameter
        {
            get
            {
                return parameter;
            }
            set
            {
                parameter = value;
            }
        }

        public abstract bool Decode(byte[] buf);
        public abstract byte[] Encode();

        /// <summary>
        /// 包装协议头尾部
        /// </summary>
        /// <param name="mess">Message type</param>
        /// <param name="para">Parameter,可以为null</param>
        /// <returns></returns>
        protected byte[] Encode(byte mess, byte[] para) //message,parameter
        {
            int paralength = para == null ? 0 : para.Length;
            byte[] tempData = new byte[paralength + 10];

            tempData[0] = 0X7E; tempData[1] = 0X7E; //head

            int lgh = paralength + 4;
            tempData[2] = (byte)(lgh); //(length / 256 / 256);
            tempData[3] = (byte)(lgh >> 8);  //(length / 256);
            tempData[4] = (byte)(lgh >> 16);
            tempData[5] = (byte)(lgh >> 24);
            tempData[6] = mess;
            if (para != null && para.Length != 0)
            {
                para.CopyTo(tempData, 7);  //parameter
            }
            short tempCheckSum = 0;
            int tempDatalength = tempData.Length;
            for (int i = 0; i < tempDatalength - 3; i++)
            {
                tempCheckSum += tempData[i];
            }
            tempData[tempDatalength - 3] = (byte)(tempCheckSum);
            tempData[tempDatalength - 2] = (byte)(tempCheckSum >> 8);
            tempData[tempDatalength - 1] = 0X0D;
            string readableByte = Util.StringUtil.Byte2ReadableXstring(tempData);
            LogHelper.GetLogger<CBase>().Debug(string.Format("发送的消息类型为：{0}，消息内容：{1}", Message, readableByte));
            return tempData;
        }

        /// <summary>
        /// 解析报文头尾,并反回parameter字段
        /// </summary>
        /// <param name="comd"></param>
        /// <param name="data"></param>
        /// <param name="paradata"></param>
        /// <returns></returns>
        protected bool Decode(byte comd, byte[] data, out byte[] paradata)
        {
            int len = BitConverter.ToInt32(data, 2);
            bool success = false;
            paradata = null;
            int paraLength = len - 4;
            ushort chekSum = BitConverter.ToUInt16(data, 7 + paraLength);
            uint tempCheckSum = 0;
            for (int i = 0; i < data.Length - 3; i++)
            {
                tempCheckSum += data[i];
            }
            ushort temCheckSum = (ushort)tempCheckSum;
            if (temCheckSum == chekSum)
            {
                byte ed = data[data.Length - 1];
                if (0X0D == ed)
                {
                    success = true;
                }
                if (paraLength > 0)
                {
                    paradata = new byte[paraLength];
                    Array.Copy(data, 7, paradata, 0, paraLength);
                }
            }
            return success;
        }
    }
}
