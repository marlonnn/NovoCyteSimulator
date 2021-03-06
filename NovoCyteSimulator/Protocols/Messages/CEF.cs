﻿using NovoCyteSimulator.Messages;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NovoCyteSimulator.Protocols.Messages
{
    public enum CmdType : byte
    {
        TYPE_PSW = 0x00,  // 发送密码 
        TYPE_PageRead = 0x01,  // 读取一页数据 
        TYPE_PageErase = 0x02,  // 擦除一页数据 
        TYPE_ChipErase = 0x03,  // 擦除整片Flash 
        TYPE_EventErase = 0x04,  // 擦除错误记录信息 
        TYPE_ProgSysInfo = 0x05,  // 烧写系统信息 
        TYPE_ProgWindowPara = 0x06,   // 烧写系统参数 
        TYPE_ProgLaserPara = 0x07,  // 烧写Laser参数 
        TYPE_ProgPMTGain = 0x08,   // 烧写PMT增益电压 
        TYPE_ProgSensorCoef = 0x09,   // 烧写传感器系数 
        TYPE_ProgPMTCfg = 0x0A, // 烧写PMT配置
        TYPE_ProgPeriPumpOmega = 0x0B, // 烧写蠕动泵转速
        TYPE_ProgSPDst = 0x0C, // 烧写加样针下降高度
        TYPE_ProgAutoSampleInfo = 0x0D, // 烧写AutoSampler系统信息
        TYPE_ProgInjectorParam = 0x0E, // 烧写Injector相关参数
        TYPE_ProgInitialFluxPara = 0x0F, // 烧写初始流量
        TYPE_ProgExtWindowParam = 0x10, // 烧写窗口位置和扩展
        TYPE_ProgExtDmlParam = 0x11, // 烧写解调参数
        TYPE_ProgModemTblCfg = 0x12, // 烧写调制解调配置表
        TYPE_ProgWeightInfo = 0x13, // 烧写 Weight 系统信息
        TYPE_ProgCompensationParam = 0x14, // 烧写补偿参数
        TYPE_ClearUpdateLock = 0x15, // 清除升级锁
        TYPE_ProgRecordForSoftware = 0x16 // 留给上位机记录数据(流体执行步骤等)
    }

    public class CEF : CBase
    {
        public byte Type { set; get; }

        public CEF()
        {
            this.message = 0xEF;
        }
        public override bool Decode(byte[] buf)
        {
            if (this.Decode(message, buf, out parameter))
            {
                Type = parameter[0];
                return true;
            }
            else
            {
                return false;
            }
        }

        public override byte[] Encode()
        {
            byte[] param = CreateParam();
            return this.Encode(message, param);
        }

        private byte[] CreateParam()
        {
            byte[] param = new byte[] { };
            switch (Type)
            {
                case (byte)CmdType.TYPE_PSW:
                    param = new byte[] { 0xEF, 0x01 };
                    break;
                case (byte)CmdType.TYPE_PageRead:
                    param = new byte[529] 
                    {
                        0xEF, 0x34, 0x00, 0x00, 0x00, 0x34, 0x00, 0x00, 0x00, 0x88,
                        0x02, 0x00, 0x00, 0xD4, 0x01, 0x00, 0x00, 0x20, 0x01, 0x00,
                        0x00, 0xDC, 0x0F, 0x49, 0x40, 0xDC, 0x0F, 0x49, 0x40, 0x00,
                        0x00, 0x70, 0x42, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x70,
                        0x42, 0x00, 0x19, 0x00, 0x00, 0x00, 0x19, 0x00, 0x00, 0x08,
                        0x00, 0x30, 0x00, 0xF8, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0xFF,
                        0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
                        0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
                        0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
                        0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
                        0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
                        0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
                        0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x4E,
                        0x4F, 0x00, 0x00, 0x03, 0x00, 0x03, 0x00, 0x60, 0xEA, 0x05,
                        0x00, 0x02, 0x00, 0x60, 0xEA, 0x04, 0x00, 0x03, 0x00, 0x30,
                        0x75, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
                        0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
                        0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
                        0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
                        0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
                        0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
                        0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
                        0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
                        0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
                        0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
                        0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
                        0xFF, 0xDF, 0x70, 0x00, 0x00, 0x33, 0x33, 0x73, 0x3F, 0xE1,
                        0x7A, 0x54, 0x3F, 0x83, 0xC0, 0x8A, 0x3F, 0x48, 0xE1, 0x7A,
                        0x3F, 0x25, 0x06, 0x81, 0x3F, 0x4C, 0x37, 0x89, 0x3F, 0x37,
                        0x89, 0x81, 0x3F, 0xC1, 0xCA, 0x81, 0x3F, 0x33, 0x33, 0x73,
                        0x3F, 0xE1, 0x7A, 0x54, 0x3F, 0x83, 0xC0, 0x8A, 0x3F, 0x48,
                        0xE1, 0x7A, 0x3F, 0x25, 0x06, 0x81, 0x3F, 0x4C, 0x37, 0x89,
                        0x3F, 0x37, 0x89, 0x81, 0x3F, 0xC1, 0xCA, 0x81, 0x3F, 0x33,
                        0x33, 0x73, 0x3F, 0xE1, 0x7A, 0x54, 0x3F, 0x83, 0xC0, 0x8A,
                        0x3F, 0x48, 0xE1, 0x7A, 0x3F, 0x25, 0x06, 0x81, 0x3F, 0x4C,
                        0x37, 0x89, 0x3F, 0x37, 0x89, 0x81, 0x3F, 0xC1, 0xCA, 0x81,
                        0x3F, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
                        0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
                        0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
                        0xFF, 0xFF, 0xFF, 0xBF, 0x46, 0x00, 0x00, 0x3F, 0xFF, 0xFF,
                        0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
                        0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
                        0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
                        0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
                        0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
                        0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
                        0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
                        0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
                        0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
                        0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
                        0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
                        0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
                        0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xC0, 0x7E, 0x00, 0x00
                    };
                    break;
            }
            return param;
        }
    }
}
