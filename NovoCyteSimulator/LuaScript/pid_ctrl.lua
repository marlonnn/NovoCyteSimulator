
work_pidctrl = work_pidctrl or {}

work_pidctrl.constant  = {
    Pt       = 35,     --目标压力值（单位：Kpa，精度：小数后三位）
    Kp       = 150.0,  --比例系数
    Ki       = 18.0,   --积分系数
    Kd       = 260.0,  --微分系数
    T        = 100     --控制周期（单位：ms）
    OmegaMax = 900.0,  --转速调节上限
    OmegaMin = 10.0    --转速调节下限
}

work_pidctrl.switch  = {

}

function work_pidctrl:PID_START()
  local PRESSURE_SENOSR = TimingConst.PRESSURE_SENOSR
  local SENOSR1 = TimingConst.PRESSURE_SENOSR1 
  self.variable.Pr = psensor.get(PRESSURE_SENOSR,SENOSR1)  --当前读取的压力值
  
end


--[[
Pr——读取的压力值；
Pe——压力差；
n0——蠕动泵进入PID时的转速；

 u=n0
for（）
Pr=读取压力；
Pe=Pr-Pt；
Ek=Ek-1；
E k-1=E k-2；
E k-2=Pe；
Δu=Kp*（Ek - E k-1）+Ki* Ek +Kd*（Ek -2* Ek-1+ E k-2）
u=u-Δu
If
u ≥ nmax，则设n= nmax；
             u ≤ nmin，则设n= nmin；
else
             n=u；
delay T

****************************************
*         NovoCyte I C code            *
****************************************

/*
C********************************************************************************************************
*                                         Novocyte System Firmware
*
*                           (c) Copyright 2010-2014 ACEA Biosciences, Inc.
*                    All rights reserved.  Protected by international copyright laws.
*
* File      :  dri_pid.c
* By        :  AlexShi
* Email     :  shiweining123@gmail.com
* Version   :  V1.0.0
* Compiler  :  NIOS II 12.1 SBT
*********************************************************************************************************
* Note(s)   :
*
*
*
*********************************************************************************************************
*/

#define DRI_PID_GLOBALS


/*
*********************************************************************************************************
*                                             INCLUDE FILES
*********************************************************************************************************
*/

#include "sopc.h"


/*
*********************************************************************************************************
*                                              LOCAL MACROS
*********************************************************************************************************
*/

#define AVERAGE_ACTIVE_NUMS     10
#define VALUE_FILTER_ABNORMAL   50      // 50Kpa
#define VALUE_FILTER_RANGE      0.05f   // ±5%


/*
*********************************************************************************************************
*                                         LOCAL MACROS FUNCTIONS
*********************************************************************************************************
*/

#define PID_ENABLED(pctrl)          pctrl->pid_active = DEF_ENABLED
#define PID_DISABLED(pctrl)         pctrl->pid_active = DEF_DISABLED
#define AVERAGE_ENABLED(pctrl)      pctrl->average_active = DEF_ENABLED
#define AVERAGE_DISABLED(pctrl)     pctrl->average_active = DEF_DISABLED


/*
*********************************************************************************************************
*                                              LOCAL DEFINES
*********************************************************************************************************
*/



/*
*********************************************************************************************************
*                                            LOCAL DATA TYPES
*********************************************************************************************************
*/

typedef struct _pid_param {
    FP32    Kp;         // 比例系数
    FP32    Ki;         // 积分系数
    FP32    Kd;         // 微分系数
    INT16U  T;          // 控制周期
} pid_param_t;

typedef struct _pid_ctrl {
    FP32    Pr;         // 当前读取压力值
    FP32    Pt;         // 压力目标值 - 上一次测得值
    FP32    Pe[3];      // 压力差
    FP32    OmegaMax;   // 蠕动泵最大转速
    FP32    OmegaMin;   // 蠕动泵最小转速
    FP32    OmegaCur;   // PID控制中蠕动泵转速
    FP32    OmegaBak;   // PID控制中前一次蠕动泵转速
    pid_param_t pparam;
    average_calc_t ac[2];
    INT8U   pid_active;
    INT8U   average_active;
} pid_ctrl_t;


/*
*********************************************************************************************************
*                                       PRIVATE FUNCTION PROTOTYPES
*********************************************************************************************************
*/

static  void    TaskPIDInit  (void);
static  void    pid_control  (pid_ctrl_t *ppc);
static  INT16U  pid_opt_sel  (pid_ctrl_t *ppc, INT8U opt);
static  void    TaskPID      (void *parg);


/*
*********************************************************************************************************
*                                  PRIVATE GLOBAL CONSTANTS & VARIABLES
*********************************************************************************************************
*/

static  OS_STK  PIDTaskStk      [STK_PID_SIZE];
static  void   *QMSG_Pid        [PID_Q_SIZE];
static  pid_ctrl_t       pid_ctrl = {
    .Pt = 35.0f,
    .OmegaMax = 900.0f,
    .OmegaMin = 10.0f,
    .pparam   = {
        .Kp = 150.0f,
        .Ki = 18.0f,
        .Kd = 260.0f,
        .T  = 100   // 100ms
    },
    .ac = {
        [0] = {
            .cnt = 0,
            .average = 0
        },
        [1] = {
            .cnt = 0,
            .average = 0
        }
    },
    .pid_active = DEF_DISABLED,
    .average_active = DEF_DISABLED
};

static  message_pkt_t   msg_pkt_pid;
static  pid_adjust_param_t  pid_adjust_param;
static  INT8U filter_abnormal_en;


/*
*********************************************************************************************************
*                                  PUBLIC GLOBAL CONSTANTS & VARIABLES
*********************************************************************************************************
*/



/*
*********************************************************************************************************
*                                       PUBLIC FUNCTION DEFINITION
*********************************************************************************************************
*/

/**
 * @brief
 *
 * @param
 *
 * @return
 *
 * @notes
 */
void AppPIDCreate (void)
{
    #if OS_TASK_NAME_SIZE > 3
    INT8U  os_err;
    #endif

    (void)OSTaskCreate((void (*)(void *)) TaskPID,
                       (void          * ) 0,
                       (OS_STK        * )&PIDTaskStk[STK_PID_SIZE - 1],
                       (INT8U           ) TASK_PID_PRIO);

    #if OS_TASK_NAME_SIZE > 3
    OSTaskNameSet(TASK_PID_PRIO, (INT8U *)"PID", &os_err);
    OSErrorCheck(os_err, __FUNCTION__, __LINE__);
    #endif
}

INT8U PID_IS_ACTIVE(void)   { return (pid_ctrl.pid_active == DEF_ENABLED)? DEF_YES: DEF_NO;  }
INT8U PID_IS_INACTIVE(void) { return (pid_ctrl.pid_active == DEF_DISABLED)? DEF_YES: DEF_NO;  }


/*
*********************************************************************************************************
*                                       PRIVATE FUNCTION DEFINITION
*********************************************************************************************************
*/

/**
 * @brief
 *
 * @param
 *
 * @return
 *
 * @notes
 */
static void TaskPIDInit (void)
{
    Q_Pid = OSQCreate(&QMSG_Pid[0], PID_Q_SIZE);
    msg_pkt_pid.Src = PID_TASK;
    average_calc_init(&pid_ctrl.ac);
}

static void pid_control(pid_ctrl_t *ppc)
{
    FP32 *pPe = ppc->Pe;
    pid_param_t *ppp = &ppc->pparam;
    FP32  delta_Omega, OmegaTmp;

    OmegaTmp = ppc->OmegaCur;

    pPe[0] = pPe[1];
    pPe[1] = pPe[2];
    pPe[2] = ppc->Pr - ppc->Pt;

    delta_Omega = ppp->Kp * (pPe[2] - pPe[1])   \
                + ppp->Ki *  pPe[2]             \
                + ppp->Kd * (pPe[2] - 2*pPe[1] + pPe[0]);
    //SYS_DEBUGF(PID_DEBUG|SYS_DBG_TRACE, "OmegaTmp:%.3f delta_Omega:%.3f\r\n", OmegaTmp, delta_Omega);
    OmegaTmp -= delta_Omega;
    //SYS_DEBUGF(PID_DEBUG|SYS_DBG_TRACE, "OmegaTmp:%.3f\r\n", OmegaTmp);
    if (OmegaTmp > ppc->OmegaMax) {
        ppc->OmegaCur = ppc->OmegaMax;
    } else if (OmegaTmp < ppc->OmegaMin) {
        ppc->OmegaCur = ppc->OmegaMin;
    } else {
        ppc->OmegaCur = OmegaTmp;
    }
    //SYS_DEBUGF(PID_DEBUG|SYS_DBG_TRACE, "Pe0:%.3f Pe1:%.3f Pe2:%.3f delta:%.3f\r\n",
    //    pPe[0], pPe[1], pPe[2], delta_Omega);
}

#define DEFAULT_SENSOR_WAIT_TICKS   17  // 80+ms
static INT16U pid_opt_sel(pid_ctrl_t *ppc, INT8U opt)
{
    average_calc_t *pac = ppc->ac;
    INT16U  wait_ticks;

    switch (opt) {
    case PID_OPT_Start:
        wait_ticks = ppc->pparam.T/OS_TICK_RATE_MS + 1;
        GetPeriPumpOmega(&ppc->OmegaCur);
        ppc->OmegaBak = ppc->OmegaCur;
        memset(ppc->Pe, 0, sizeof(ppc->Pe));
        SYS_DEBUGF(PID_DEBUG|SYS_DBG_TRACE, "Pt:%.3f Kp:%.3f Ki:%.3f Kd:%.3f T:%u\r\n",
                   ppc->Pt, ppc->pparam.Kp, ppc->pparam.Ki,
                   ppc->pparam.Kd, ppc->pparam.T);
        PID_ENABLED(ppc);
        return wait_ticks;
    case PID_OPT_Stop:
        PID_DISABLED(ppc);
        break;
    case PT_MONITOR_Start:
    	SYS_DEBUGF(PID_DEBUG|SYS_DBG_TRACE, "PT Monitor Start...\r\n");
        average_calc_init(&pac[0]);
        average_calc_init(&pac[1]);
        AVERAGE_ENABLED(ppc);
        break;
    case PT_MONITOR_Stop:
        if (pac[0].cnt >= AVERAGE_ACTIVE_NUMS) {
            ppc->Pt = (FP32)pac[0].average;
            SYS_DEBUGF(PID_DEBUG|SYS_DBG_TRACE, "PT Monitor Stop average:[%u]%.3f\r\n", pac[0].cnt, ppc->Pt);
            if (pac[1].cnt >= AVERAGE_ACTIVE_NUMS) {
                if (pac[1].average - pac[0].average > VALUE_FILTER_ABNORMAL) {
                    filter_abnormal_en = DEF_ENABLED;
                } else {
                    filter_abnormal_en = DEF_DISABLED;
                }
            }
        } else {
        	SYS_DEBUGF(PID_DEBUG|SYS_DBG_TRACE, "PT Monitor Stop dots:[%u]\r\n", pac[0].cnt);
        }
        AVERAGE_DISABLED(ppc);
        break;
    default: break;
    }

    return DEFAULT_SENSOR_WAIT_TICKS;
}

static void TaskPID (void *parg)
{
    INT8U   os_err, err, adch;
    INT16U  acc;
    INT16U  wait_ticks = DEFAULT_SENSOR_WAIT_TICKS;
    message_pkt_t *pmsg;
    pid_ctrl_t *ppc = &pid_ctrl;
    average_calc_t *pac = ppc->ac;
    FP32    value, average, delta;

    (void)parg;
    TaskPIDInit();

    while (DEF_ON)
    {
        pmsg = (message_pkt_t *)OSQPend(Q_Pid, wait_ticks, &os_err);
        if (OS_ERR_NONE == os_err) {
            if (pmsg->Src == WORK_TASK) {
                wait_ticks = pid_opt_sel(ppc, pmsg->Opt);
                sensor_monitor(&err);
            }
        } else  if (OS_ERR_TIMEOUT == os_err) {
            adch = sensor_monitor(&err);
            if (ppc->pid_active == DEF_ENABLED) {
                ppc->Pr = get_mntr2_val(Mntr2_PressureID1);
                pid_control(ppc);
                pid_adjust_param.omega = ppc->OmegaCur;
                delta = ppc->OmegaCur - ppc->OmegaBak;
                if (delta < 0) delta = -delta;
                acc = delta * 1000 / ppc->pparam.T;   //计算转速变换时的加速度,acc单位rpm/s
                pid_adjust_param.acc = DEF_MAX(acc, 100);  //acc最小为100
                SYS_DEBUGF(PID_DEBUG|SYS_DBG_TRACE, "P:%.3f PeriPump Omega Cur:%.3frpm Bak:%.3frpm acc:%d\r\n",
                    ppc->Pr, ppc->OmegaCur, ppc->OmegaBak, pid_adjust_param.acc);
                msg_pkt_pid.Para = &pid_adjust_param;
                OSQPost(Q_PeriPump, &msg_pkt_pid);
                ppc->OmegaBak = ppc->OmegaCur;
            } else if (ppc->average_active == DEF_ENABLED) {
                if (err == AD7194_ERR_NONE) {
                    if (adch == Mntr2_PressureID1) {
                        value = get_mntr2_val(Mntr2_PressureID1);
                    	if (pac[0].cnt) {
							average = pac[0].average;
                            delta = value - average;
							if (DEF_ABS(delta)/average < VALUE_FILTER_RANGE) {
								average_calc_next(&pac[0], value);
							} else {
                                SYS_DEBUGF(PID_DEBUG|SYS_DBG_TRACE, TERM_COLOR_LIGHT_RED"[1]Remove: %.3f\r\n"TERM_COLOR_RESET, value);
							}
                    	} else {
                    		average_calc_next(&pac[0], value);
                        }
                    } else if (adch == Mntr2_PressureID2) {
                        value = get_mntr2_val(Mntr2_PressureID2);
                        average_calc_next(&pac[1], value);
                    }
                }
            }
        } else {
            OSErrorCheck(os_err, __FUNCTION__, __LINE__);
        }
    }
}

/*
*********************************************************************************************************
*                                               No More!
*********************************************************************************************************
*/

--]]
