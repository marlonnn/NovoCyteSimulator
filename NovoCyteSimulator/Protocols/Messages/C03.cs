using NovoCyteSimulator.Messages;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovoCyteSimulator.Protocols.Messages
{
    public struct CheckFunctionResult
    {
        public Equipment.Device.CheckFunction T;
        public ushort R1;
        public uint R2;
    }
    public class C03 : CBase
    {
        public Equipment.Device.CheckFunction T { set; get; }

        public CheckFunctionResult Result;
        public C03(byte message)
        {
            this.message = message;
        }

        private bool AllNotSupport()
        {
            bool allnotsupport = true;
            foreach (var key in config.Device.SystemFunctionDic.Keys)
            {
                if (config.Device.SystemFunctionDic[key])
                {
                    allnotsupport = false;
                    break;
                }
            }
            return allnotsupport;
        }

        private byte[] CreateParam()
        {
            if (Result.T == 0)
            {
                //查询所有支持功能
                if (AllNotSupport())
                {
                    //所有功能都不支持
                    return new byte[6];
                }
                else
                {
                    //返回所有支持的功能
                    List<byte[]> bytes = new List<byte[]>();
                    foreach (var key in config.Device.SystemFunctionDic.Keys)
                    {
                        if (config.Device.SystemFunctionDic[key])
                        {
                            byte[] temp = new byte[6];
                            temp[0] = (byte)key;
                            bytes.Add(temp);
                        }
                    }
                    byte[] param = new byte[bytes.Count * 6];
                    for (int i = 0; i < bytes.Count; i++)
                    {
                        Array.Copy(bytes[i], 0, param, i * 6, 6);
                    }
                    return param;
                }
            }
            else
            {
                //返回某一项支持的功能 
                byte[] temp = new byte[8];
                temp[0] = (byte)Result.T;
                temp[2] = (byte)(config.Device.SystemFunctionDic[Result.T] ? 1 : 0);
                return temp;
            }
        }

        public override bool Decode(byte[] buf)
        {
            if (!this.Decode(message, buf, out parameter))
            {
                return false;
            }
            else
            {
                Result.T = (Equipment.Device.CheckFunction)parameter[0];

                return true;
            }
        }

        public override byte[] Encode()
        {
            byte[] param = CreateParam();
            return this.Encode(message, param);
        }
    }
}
