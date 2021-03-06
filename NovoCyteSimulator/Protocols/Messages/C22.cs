﻿using NovoCyteSimulator.Equipment;
using NovoCyteSimulator.ExpClass;
using NovoCyteSimulator.Messages;
using Summer.System.Log;
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
        //private SampleData _sampleData;

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
            byte[] param = new byte[3 + length * 144];
            //Y1=1表示采集的细胞数据还未传输结束
            param[0] = 0x01;

            //细胞数据个数
            y2 = (ushort)length;
            param[1] = (byte)y2;
            param[2] = (byte)(y2 >> 8);

            for (int i = 0; i < length; i++)
            {
                byte[] Temp = new byte[144];
                //Index
                byte[] index = BitConverter.GetBytes(Index);
                Array.Copy(index, 0, Temp, 0, 4);
                //Time
                float time = GetValue("Time", Index);
                byte[] Times = BitConverter.GetBytes(time);
                Array.Copy(Times, 0, Temp, 4, 4);
                //width
                float width = GetValue("Width", Index);
                byte[] Widths = BitConverter.GetBytes(width);
                Array.Copy(Widths, 0, Temp, 8, 4);
                for (int j = 0; j < 3; j++)
                {
                    Temp[12 + j * 4] = 0;
                }

                float fscapdArea = GetValue(string.Format("{0}{1}", "FSC", "-A"), Index);
                float fscapdHeight = GetValue(string.Format("{0}{1}", "FSC", "-H"), Index);

                byte[] fscHeights = BitConverter.GetBytes(fscapdHeight);
                byte[] fscAreas = BitConverter.GetBytes(fscapdArea);

                Array.Copy(fscHeights, 0, Temp, 24, 4);
                Array.Copy(fscAreas, 0, Temp, 28, 4);

                float sscapdArea = GetValue(string.Format("{0}{1}", "SSC", "-A"), Index);
                float sscapdHeight = GetValue(string.Format("{0}{1}", "SSC", "-H"), Index);

                byte[] sscHeights = BitConverter.GetBytes(sscapdHeight);
                byte[] sscAreas = BitConverter.GetBytes(sscapdArea);

                Array.Copy(sscHeights, 0, Temp, 32, 4);
                Array.Copy(sscAreas, 0, Temp, 36, 4);

                for (int j = 2; j < 15; j++)
                {
                    string channelName = GetChannel(j);
                    if (!string.IsNullOrEmpty(channelName))
                    {
                        float pmtArea = GetValue(string.Format("{0}{1}", GetChannel(j), "-A"), Index);
                        float pmtHeight = GetValue(string.Format("{0}{1}", GetChannel(j), "-H"), Index);
                        byte[] pmtHeights = BitConverter.GetBytes(pmtHeight);
                        Array.Copy(pmtHeights, 0, Temp, 40 + j * 4, 4);

                        byte[] pmtAreas = BitConverter.GetBytes(pmtArea);
                        Array.Copy(pmtAreas, 0, Temp, 44 + j * 4, 4);
                    }
                    else
                    {
                        byte[] pmtHeights = new byte[4];
                        Array.Copy(pmtHeights, 0, Temp, 40 + j * 4, 4);

                        byte[] pmtAreas = new byte[4];
                        Array.Copy(pmtAreas, 0, Temp, 44 + j * 4, 4);
                    }
                }
                Array.Copy(Temp, 0, param, 3 + i * 144, 144);
                Index++;
            }

            return param;
        }

        public void Test()
        {
            byte[] Temp = new byte[144];
            float fscapdArea = GetValue(string.Format("{0}{1}", "FSC", "-A"), Index);
            float fscapdHeight = GetValue(string.Format("{0}{1}", "FSC", "-H"), Index);

            byte[] fscHeights = BitConverter.GetBytes(fscapdHeight);
            byte[] fscAreas = BitConverter.GetBytes(fscapdArea);

            float sscapdArea = GetValue(string.Format("{0}{1}", "SSC", "-A"), Index);
            float sscapdHeight = GetValue(string.Format("{0}{1}", "SSC", "-H"), Index);

            byte[] sscHeights = BitConverter.GetBytes(sscapdHeight);
            byte[] sscAreas = BitConverter.GetBytes(sscapdArea);

            for (int j = 2; j < 15; j++)
            {
                string channelName = GetChannel(j);
                if (!string.IsNullOrEmpty(channelName))
                {
                    float apdArea = GetValue(string.Format("{0}{1}", GetChannel(j), "-A"), Index);
                    float apdHeight = GetValue(string.Format("{0}{1}", GetChannel(j), "-H"), Index);

                    byte[] Heights = BitConverter.GetBytes(apdHeight);
                    Array.Copy(Heights, 0, Temp, 24 + j * 4, 4);

                    byte[] Areas = BitConverter.GetBytes(apdArea);
                    Array.Copy(Areas, 0, Temp, 28 + j * 4, 4);
                }
                else
                {
                    byte[] Heights = new byte[4];
                    Array.Copy(Heights, 0, Temp, 24 + j * 4, 4);

                    byte[] Areas = new byte[4];
                    Array.Copy(Areas, 0, Temp, 28 + j * 4, 4);
                }
            }
        }

        private string GetChannel(int index)
        {
            //暂时使用405 488 640 机型
            //var channelIDs = config.LaserConfig.LaserChannelIDDic[Equipment.LaserType.nm405nm488nm640];
            //return channelIDs.ChannelID[index];
            var chanel = FLChannel.GetFLChannel(config.CytometerInfo).GetPxLxChannelID(index - 2);
            if (chanel == FLChannelID.NonFL)
            {
                return "";
            }
            else
            {
                return chanel.ToString();
            }
        }

        private float GetValue(string key, int index)
        {
            try
            {
                var v = FLChannel.GetFLChannel(config.CytometerInfo).channels;
                return NCFData.GetData().Configs[0].SampleData.Data[key][index];
            }
            catch (Exception ex)
            {
                Console.WriteLine(key);
                LogHelper.GetLogger<C22>().Error(ex.Message);
                LogHelper.GetLogger<C22>().Error(ex.StackTrace);
                return 0;
            }
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
            int remain = NCFData.GetData().Configs[0].SampleData.Data["Time"].Count - Index;
            //达到测试预设时间
            if (CollectionParams.GetCollectionParams().ArrivedTime())
            {
                param = new byte[2] { 0x00, 0x02 };
                return this.Encode(message, param);
            }
            else if (CollectionParams.GetCollectionParams().ArrivedSize())
            {
                param = new byte[2] { 0x00, 0x04 };
                return this.Encode(message, param);
            }
            else
            {
                if (remain >= 5)
                {
                    param = CreateTransferParam(5);
                }
                else if (remain != 0)
                {
                    param = CreateTransferParam(remain);
                    Index = 0;
                }
            }
            //if (remain >= 5)
            //{
            //    param = CreateTransferParam(5);
            //}
            //else if (remain != 0)
            //{
            //    param = CreateTransferParam(remain);
            //    Index = 0;
            //}
            //else
            //{
            //    param = new byte[2] { 0x00, 0x02 };
            //    return this.Encode(message, param);
            //}
            //for test no data
            //param = CreateTransferParam(0);
            return this.Encode(message, param);
        }
    }
}
