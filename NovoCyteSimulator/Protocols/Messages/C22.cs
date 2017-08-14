using NovoCyteSimulator.ExpClass;
using NovoCyteSimulator.Messages;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;

namespace NovoCyteSimulator.Protocols.Messages
{

    [StructLayout(LayoutKind.Sequential)]
    public struct Event
    {
        public uint Index;  // 细胞序号 
        public uint Time;   // 细胞采集时间点 
        public float Width; // 细胞波形宽度 
        [MarshalAs(UnmanagedType.ByValArray)]
        public uint[] Overlaps;
        [MarshalAs(UnmanagedType.ByValArray)]
        public Channel[] Channels;

        public void SetChannels(Channel[] channals)
        {
            Index = 0;
            Time = 0;
            Width = 0;
            Overlaps = new uint[3];
            Channels = channals;
        }
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct Channel
    {
        public int Height; // 细胞波形高度 
        public int Area;  // 细胞波形面积 
    }

    //细胞采集结束方式。
    public enum CompletedReason
    {
        NotCompleted = -1,
        Error,
        ByUser,
        Time,
        Events,
        Volume,
    }

    /// <summary>
    /// 细胞数据读取
    /// </summary>
    public class C22 : CBase
    {
        private SampleData _sampleData;

        //表示采集的细胞数据还未传输结束
        private byte y1;

        //表示Y3包含细胞数据个数(0≤Y2≤20000)
        private ushort y2;

        public bool Completed
        {
            get
            {
                return y1 == 0;
            }
        }

        private int Index = 0;
        public static uint ChannelCount
        {
            get { return FLChannelCount + 2; }    // FL + FSC + SSC
        }

        public static uint FLChannelCount = 13;
        public C22()
        {
            this.message = 0x22;
        }

        private byte[] CreateStopParam()
        {
            return new byte[2] { 0, 2};
        }

        private byte[] CreateTransferParam(int length)
        {
            length = 0;
            byte[] param = new byte[3 + length * 144];
            //Y1=1表示采集的细胞数据还未传输结束
            param[0] = 0x01;

            //细胞数据个数
            y2 = (ushort)length;
            param[1] = (byte)y2;
            param[2] = (byte)(y2 >> 8);

            //for (int i = 0; i < length; i++) 
            //{
            //    byte[] Temp = new byte[144];
            //    //Index
            //    byte[] index = BitConverter.GetBytes(Index);
            //    Array.Copy(index, 0, Temp, 0, 4);
            //    //Time
            //    float time = GetValue("Time", Index);
            //    byte[] Times = BitConverter.GetBytes(time);
            //    Array.Copy(Times, 0, Temp, 4, 4);
            //    //width
            //    float width = GetValue("Width", Index);
            //    byte[] Widths = BitConverter.GetBytes(width);
            //    Array.Copy(Widths, 0, Temp, 8, 4);
            //    for (int j = 0; j < 3; j++)
            //    {
            //        Temp[12 + j * 4] = 0;
            //    }
            //    for (int j=0; j<2; j++)
            //    {
            //        float area = GetValue(string.Format("{0}{1}", GetChannel(j), "-A"), Index);
            //        float height = GetValue(string.Format("{0}{1}", GetChannel(j), "-H"), Index);
            //        byte[] Heights = BitConverter.GetBytes(height);
            //        Array.Copy(Heights, 0, Temp, 24 + j * 4, 4);

            //        byte[] Areas = BitConverter.GetBytes(area);
            //        Array.Copy(Areas, 0, Temp, 28 + j * 4, 4);
            //    }
            //    for (int j = 0; j < 13; j++)
            //    {
            //        float area = GetValue(string.Format("{0}{1}", GetChannel(j), "-A"), Index);
            //        float height = GetValue(string.Format("{0}{1}", GetChannel(j), "-H"), Index);

            //        byte[] Heights = BitConverter.GetBytes(height);
            //        Array.Copy(Heights, 0, Temp, 32 + j * 4, 4);

            //        byte[] Areas = BitConverter.GetBytes(area);
            //        Array.Copy(Areas, 0, Temp, 36 + j * 4, 4);
            //    }
            //    Array.Copy(Temp, 0, param, 3 + i * 144, 144);
            //    Index++;
            //}

            return param;
        }

        private string GetChannel(int index)
        {
            //暂时使用405 488 640 机型
            var channelIDs = config.LaserConfig.LaserChannelIDDic[Equipment.LaserType.nm405nm488nm640];
            return channelIDs.ChannelID[index];
        }

        private float GetValue(string key, int index)
        {
            return _sampleData.Data[key][index];
        }

        private byte[] StructToBytes(Event structure)
        {
            int size = Marshal.SizeOf(structure);
            IntPtr buffer = Marshal.AllocHGlobal(size);
            try
            {
                Marshal.StructureToPtr(structure, buffer, false);
                Byte[] bytes = new Byte[size];
                Marshal.Copy(buffer, bytes, 0, size);
                return bytes;
            }
            finally
            {
                Marshal.FreeHGlobal(buffer);
            }
        }

        public override bool Decode(byte[] buf)
        {
            if(this.Decode(message, buf, out parameter))
            {
                y1 = parameter[0];
                return true;
            }
            else
            {
                return false;
            }
        }

        public override byte[] Encode()
        {
            byte[] param = null;
            int remain = _sampleData.Data["Time"].Count - Index;
            if (remain >= 500)
            {
                param = CreateTransferParam(500);
            }
            else if (remain != 0)
            {
                param = CreateTransferParam(remain);
                Index = 0;
            }
            else
            {
                param = new byte[2] { 0x00, 0x02 };
                return this.Encode(message, param);
            }
            return this.Encode(message, param);
        }
    }
}
