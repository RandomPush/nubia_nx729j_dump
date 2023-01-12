#=============================================================================
# Copyright (c) 2020-2022 Qualcomm Technologies, Inc.
# All Rights Reserved.
# Confidential and Proprietary - Qualcomm Technologies, Inc.
#
# Copyright (c) 2014-2017, The Linux Foundation. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of The Linux Foundation nor
#       the names of its contributors may be used to endorse or promote
#       products derived from this software without specific prior written
#       permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NON-INFRINGEMENT ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#=============================================================================

enable_tracing_events()
{
    # timer
    echo 1 > /sys/kernel/tracing/events/timer/timer_expire_entry/enable
    echo 1 > /sys/kernel/tracing/events/timer/timer_expire_exit/enable
    echo 1 > /sys/kernel/tracing/events/timer/hrtimer_cancel/enable
    echo 1 > /sys/kernel/tracing/events/timer/hrtimer_expire_entry/enable
    echo 1 > /sys/kernel/tracing/events/timer/hrtimer_expire_exit/enable
    echo 1 > /sys/kernel/tracing/events/timer/hrtimer_init/enable
    echo 1 > /sys/kernel/tracing/events/timer/hrtimer_start/enable
    #enble FTRACE for softirq events
    echo 1 > /sys/kernel/tracing/events/irq/enable
    #enble FTRACE for Workqueue events
    echo 1 > /sys/kernel/tracing/events/workqueue/enable
    echo 1 > /sys/kernel/tracing/events/workqueue/workqueue_execute_start/enable
    # schedular
    echo 1 > /sys/kernel/tracing/events/sched/sched_cpu_hotplug/enable
    echo 1 > /sys/kernel/tracing/events/sched/sched_migrate_task/enable
    echo 1 > /sys/kernel/tracing/events/sched/sched_pi_setprio/enable
    echo 1 > /sys/kernel/tracing/events/sched/sched_switch/enable
    echo 1 > /sys/kernel/tracing/events/sched/sched_wakeup/enable
    echo 1 > /sys/kernel/tracing/events/sched/sched_wakeup_new/enable
    # sound
    echo 1 > /sys/kernel/tracing/events/asoc/snd_soc_reg_read/enable
    echo 1 > /sys/kernel/tracing/events/asoc/snd_soc_reg_write/enable
    # mdp
    echo 1 > /sys/kernel/tracing/events/mdss/mdp_video_underrun_done/enable
    # video
    echo 1 > /sys/kernel/tracing/events/msm_vidc/enable
    # clock
    echo 1 > /sys/kernel/tracing/events/power/clock_set_rate/enable
    echo 1 > /sys/kernel/tracing/events/power/clock_enable/enable
    echo 1 > /sys/kernel/tracing/events/power/clock_disable/enable
    echo 1 > /sys/kernel/tracing/events/power/cpu_frequency/enable
    # regulator
    echo 1 > /sys/kernel/tracing/events/regulator/enable
    # power
    echo 1 > /sys/kernel/tracing/events/msm_low_power/enable
    # fastrpc
    echo 1 > /sys/kernel/tracing/events/fastrpc/enable

    echo 1 > /sys/kernel/tracing/tracing_on
}

# function to disable SF tracing on perf config
sf_tracing_disablement()
{
    # disable SF tracing if its perf config
    if [ ! -d /sys/module/msm_rtb ]
    then
        setprop debug.sf.enable_transaction_tracing 0
    fi
}

# function to enable ftrace events
enable_ftrace_event_tracing()
{
    # bail out if its perf config
    if [ ! -d /sys/module/msm_rtb ]
    then
        return
    fi

    # bail out if ftrace events aren't present
    if [ ! -d /sys/kernel/tracing/events ]
    then
        return
    fi

    enable_tracing_events
}

# function to enable ftrace event transfer to CoreSight STM
enable_stm_events()
{
    # bail out if its perf config
    if [ ! -d /sys/module/msm_rtb ]
    then
        return
    fi
    # bail out if coresight isn't present
    if [ ! -d /sys/bus/coresight ]
    then
        return
    fi
    # bail out if ftrace events aren't present
    if [ ! -d /sys/kernel/tracing/events ]
    then
        return
    fi

    echo $etr_size > /sys/bus/coresight/devices/coresight-tmc-etr/buffer_size
    echo 1 > /sys/bus/coresight/devices/coresight-tmc-etr/$sinkenable
    echo coresight-stm > /sys/class/stm_source/ftrace/stm_source_link
    echo 1 > /sys/bus/coresight/devices/coresight-stm/$srcenable
    echo 1 > /sys/kernel/tracing/tracing_on
    echo 0 > /sys/bus/coresight/devices/coresight-stm/hwevent_enable
}
enable_lpm_with_dcvs_tracing()
{
    # "Configure CPUSS LPM Debug events"
    echo 1 > /sys/bus/coresight/devices/coresight-tpdm-apss/reset
    echo 0x0 0x3 0x1 > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_edge_ctrl_mask
    echo 0x0 0x3 0 > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_edge_ctrl
    echo 0x4 0x4 0x1 > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_edge_ctrl_mask
    echo 0x4 0x4 0 > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_edge_ctrl
    echo 0x5 0x5 0x1 > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_edge_ctrl_mask
    echo 0x5 0x5 0 > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_edge_ctrl
    echo 0x6 0x8 0x1 > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_edge_ctrl_mask
    echo 0x6 0x8 0 > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_edge_ctrl
    echo 0xc 0xf 0x1 > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_edge_ctrl_mask
    echo 0xc 0xf 0x1 > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_edge_ctrl_mask
    echo 0xc 0xf 0 > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_edge_ctrl
    echo 0x1d 0x1d 0x1 > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_edge_ctrl_mask
    echo 0x1d 0x1d 0 > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_edge_ctrl
    echo 0x2b 0x3f 0x1 > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_edge_ctrl_mask
    echo 0x2b 0x3f 0 > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_edge_ctrl
    echo 0x80 0x9a 0x1 > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_edge_ctrl_mask
    echo 0x80 0x9a 0 > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_edge_ctrl
    echo 0 0x11111111  > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_msr
    echo 1 0x66660001  > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_msr
    echo 2 0x00000000  > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_msr
    echo 3 0x00100000  > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_msr
    echo 5 0x11111000  > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_msr
    echo 6 0x11111111  > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_msr
    echo 7 0x11111111  > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_msr
    echo 16 0x11111111  > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_msr
    echo 17 0x11111111  > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_msr
    echo 18 0x11111111  > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_msr
    echo 19 0x00000111  > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_msr
    echo 0 0xFFFFFFFF > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_patt_mask
    echo 1 0xFFFFFFFF > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_patt_mask
    echo 2 0xFFFFFFFF > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_patt_mask
    echo 3 0xFFFFFFFF > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_patt_mask
    echo 4 0xFFFFFFFF > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_patt_mask
    echo 5 0xFFFFFFFF > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_patt_mask
    echo 6 0xFFFFFFFF > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_patt_mask
    echo 7 0xFFFFFFFF > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_patt_mask
    echo 1 > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_patt_ts
    echo 1 > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_patt_type
    echo 0 > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_trig_ts


    # "Configure CPUCP Trace and Debug Bus ACTPM "
    echo 1 > /sys/bus/coresight/devices/coresight-tpdm-actpm/reset
    ### CMB_MSR : [10]: debug_en, [7:6] : 0x0-0x3 : clkdom0-clkdom3 debug_bus
    ###         : [5]: trace_en, [4]: 0b0:continuous mode 0b1 : legacy mode
    ###         : [3:0] : legacy mode : 0x0 : combined_traces 0x1-0x4 : clkdom0-clkdom3
    ### Select CLKDOM0 (L3) debug bus and all CLKDOM trace bus
    echo 0 0x420 > /sys/bus/coresight/devices/coresight-tpdm-actpm/cmb_msr
    echo 0 > /sys/bus/coresight/devices/coresight-tpdm-actpm/mcmb_lanes_select
    echo 1 0 > /sys/bus/coresight/devices/coresight-tpdm-actpm/cmb_mode
    echo 1 > /sys/bus/coresight/devices/coresight-tpda-actpm/cmbchan_mode
    echo 1 > /sys/bus/coresight/devices/coresight-tpdm-actpm/cmb_ts_all
    echo 1 > /sys/bus/coresight/devices/coresight-tpdm-actpm/cmb_patt_ts
    echo 0 0x20000000 > /sys/bus/coresight/devices/coresight-tpdm-actpm/cmb_patt_mask
    echo 0 0x20000000 > /sys/bus/coresight/devices/coresight-tpdm-actpm/cmb_patt_val

    # "Start Trace collection "
    echo 2 > /sys/bus/coresight/devices/coresight-tpdm-apss/enable_datasets
    echo 1 > /sys/bus/coresight/devices/coresight-tpdm-apss/enable_source
    echo 0x4 > /sys/bus/coresight/devices/coresight-tpdm-actpm/enable_datasets
    echo 1 > /sys/bus/coresight/devices/coresight-tpdm-actpm/enable_source

}


enable_stm_hw_events()
{
   #TODO: Add HW events
}

gemnoc_dump()
{
    #; gem_noc_fault_sbm
    echo 0x24183040 1 > $DCC_PATH/config
    echo 0x24183048 1 > $DCC_PATH/config

    #; gem_noc_qns_llcc0_poc_err
    echo 0x24102010 1 > $DCC_PATH/config
    echo 0x24102020 6 > $DCC_PATH/config
    #; gem_noc_qns_llcc2_poc_err
    echo 0x24102410 1 > $DCC_PATH/config
    echo 0x24102420 6 > $DCC_PATH/config
    #; gem_noc_qns_llcc1_poc_err
    echo 0x24142010 1 > $DCC_PATH/config
    echo 0x24142020 6 > $DCC_PATH/config
    #; gem_noc_qns_llcc3_poc_err
    echo 0x24142410 1 > $DCC_PATH/config
    echo 0x24142420 6 > $DCC_PATH/config
    #; gem_noc_qns_cnoc_poc_err
    echo 0x24182010 1 > $DCC_PATH/config
    echo 0x24182020 6 > $DCC_PATH/config
    #; gem_noc_qns_pcie_poc_err
    echo 0x24182410 1 > $DCC_PATH/config
    echo 0x24182420 6 > $DCC_PATH/config

    #; gem_noc_qns_llcc0_poc_dbg
    echo 0x24100810 1 > $DCC_PATH/config
    echo 0x24100838 1 > $DCC_PATH/config
    echo 0x24100830 2 > $DCC_PATH/config
    echo 0x24100830 2 > $DCC_PATH/config
    echo 0x24100830 2 > $DCC_PATH/config
    echo 0x24100830 2 > $DCC_PATH/config
    echo 0x24100838 1 > $DCC_PATH/config
    echo 0x24100830 2 > $DCC_PATH/config
    echo 0x24100830 2 > $DCC_PATH/config
    echo 0x24100830 2 > $DCC_PATH/config
    echo 0x24100830 2 > $DCC_PATH/config
    echo 0x24100838 1 > $DCC_PATH/config
    echo 0x24100830 2 > $DCC_PATH/config
    echo 0x24100830 2 > $DCC_PATH/config
    echo 0x24100830 2 > $DCC_PATH/config
    echo 0x24100830 2 > $DCC_PATH/config
    echo 0x24100838 1 > $DCC_PATH/config
    echo 0x24100830 2 > $DCC_PATH/config
    echo 0x24100830 2 > $DCC_PATH/config
    echo 0x24100830 2 > $DCC_PATH/config
    echo 0x24100830 2 > $DCC_PATH/config
    echo 0x24100808 2 > $DCC_PATH/config
    #; gem_noc_qns_llcc2_poc_dbg
    echo 0x24100C10 1 > $DCC_PATH/config
    echo 0x24100C38 1 > $DCC_PATH/config
    echo 0x24100C30 2 > $DCC_PATH/config
    echo 0x24100C30 2 > $DCC_PATH/config
    echo 0x24100C30 2 > $DCC_PATH/config
    echo 0x24100C30 2 > $DCC_PATH/config
    echo 0x24100C38 1 > $DCC_PATH/config
    echo 0x24100C30 2 > $DCC_PATH/config
    echo 0x24100C30 2 > $DCC_PATH/config
    echo 0x24100C30 2 > $DCC_PATH/config
    echo 0x24100C30 2 > $DCC_PATH/config
    echo 0x24100C38 1 > $DCC_PATH/config
    echo 0x24100C30 2 > $DCC_PATH/config
    echo 0x24100C30 2 > $DCC_PATH/config
    echo 0x24100C30 2 > $DCC_PATH/config
    echo 0x24100C30 2 > $DCC_PATH/config
    echo 0x24100C38 1 > $DCC_PATH/config
    echo 0x24100C30 2 > $DCC_PATH/config
    echo 0x24100C30 2 > $DCC_PATH/config
    echo 0x24100C30 2 > $DCC_PATH/config
    echo 0x24100C30 2 > $DCC_PATH/config
    echo 0x24100C08 2 > $DCC_PATH/config
    #; gem_noc_qns_llcc1_poc_dbg
    echo 0x24140810 1 > $DCC_PATH/config
    echo 0x24140838 1 > $DCC_PATH/config
    echo 0x24140830 2 > $DCC_PATH/config
    echo 0x24140830 2 > $DCC_PATH/config
    echo 0x24140830 2 > $DCC_PATH/config
    echo 0x24140830 2 > $DCC_PATH/config
    echo 0x24140838 1 > $DCC_PATH/config
    echo 0x24140830 2 > $DCC_PATH/config
    echo 0x24140830 2 > $DCC_PATH/config
    echo 0x24140830 2 > $DCC_PATH/config
    echo 0x24140830 2 > $DCC_PATH/config
    echo 0x24140838 1 > $DCC_PATH/config
    echo 0x24140830 2 > $DCC_PATH/config
    echo 0x24140830 2 > $DCC_PATH/config
    echo 0x24140830 2 > $DCC_PATH/config
    echo 0x24140830 2 > $DCC_PATH/config
    echo 0x24140838 1 > $DCC_PATH/config
    echo 0x24140830 2 > $DCC_PATH/config
    echo 0x24140830 2 > $DCC_PATH/config
    echo 0x24140830 2 > $DCC_PATH/config
    echo 0x24140830 2 > $DCC_PATH/config
    echo 0x24140808 2 > $DCC_PATH/config
    #; gem_noc_qns_llcc3_poc_dbg
    echo 0x24140C10 1 > $DCC_PATH/config
    echo 0x24140C38 1 > $DCC_PATH/config
    echo 0x24140C30 2 > $DCC_PATH/config
    echo 0x24140C30 2 > $DCC_PATH/config
    echo 0x24140C30 2 > $DCC_PATH/config
    echo 0x24140C30 2 > $DCC_PATH/config
    echo 0x24140C38 1 > $DCC_PATH/config
    echo 0x24140C30 2 > $DCC_PATH/config
    echo 0x24140C30 2 > $DCC_PATH/config
    echo 0x24140C30 2 > $DCC_PATH/config
    echo 0x24140C30 2 > $DCC_PATH/config
    echo 0x24140C38 1 > $DCC_PATH/config
    echo 0x24140C30 2 > $DCC_PATH/config
    echo 0x24140C30 2 > $DCC_PATH/config
    echo 0x24140C30 2 > $DCC_PATH/config
    echo 0x24140C30 2 > $DCC_PATH/config
    echo 0x24140C38 1 > $DCC_PATH/config
    echo 0x24140C30 2 > $DCC_PATH/config
    echo 0x24140C30 2 > $DCC_PATH/config
    echo 0x24140C30 2 > $DCC_PATH/config
    echo 0x24140C30 2 > $DCC_PATH/config
    echo 0x24140C08 2 > $DCC_PATH/config
    #; gem_noc_qns_cnoc_poc_dbg
    echo 0x24180010 1 > $DCC_PATH/config
    echo 0x24180038 1 > $DCC_PATH/config
    echo 0x24180030 2 > $DCC_PATH/config
    echo 0x24180030 2 > $DCC_PATH/config
    echo 0x24180030 2 > $DCC_PATH/config
    echo 0x24180030 2 > $DCC_PATH/config
    echo 0x24180038 1 > $DCC_PATH/config
    echo 0x24180030 2 > $DCC_PATH/config
    echo 0x24180030 2 > $DCC_PATH/config
    echo 0x24180030 2 > $DCC_PATH/config
    echo 0x24180030 2 > $DCC_PATH/config
    echo 0x24180038 1 > $DCC_PATH/config
    echo 0x24180030 2 > $DCC_PATH/config
    echo 0x24180030 2 > $DCC_PATH/config
    echo 0x24180030 2 > $DCC_PATH/config
    echo 0x24180030 2 > $DCC_PATH/config
    echo 0x24180038 1 > $DCC_PATH/config
    echo 0x24180030 2 > $DCC_PATH/config
    echo 0x24180030 2 > $DCC_PATH/config
    echo 0x24180030 2 > $DCC_PATH/config
    echo 0x24180030 2 > $DCC_PATH/config
    echo 0x24180008 2 > $DCC_PATH/config
    #; gem_noc_qns_pcie_poc_dbg
    echo 0x24180410 1 > $DCC_PATH/config
    echo 0x24180438 1 > $DCC_PATH/config
    echo 0x24180430 2 > $DCC_PATH/config
    echo 0x24180430 2 > $DCC_PATH/config
    echo 0x24180430 2 > $DCC_PATH/config
    echo 0x24180430 2 > $DCC_PATH/config
    echo 0x24180438 1 > $DCC_PATH/config
    echo 0x24180430 2 > $DCC_PATH/config
    echo 0x24180430 2 > $DCC_PATH/config
    echo 0x24180430 2 > $DCC_PATH/config
    echo 0x24180430 2 > $DCC_PATH/config
    echo 0x24180438 1 > $DCC_PATH/config
    echo 0x24180430 2 > $DCC_PATH/config
    echo 0x24180430 2 > $DCC_PATH/config
    echo 0x24180430 2 > $DCC_PATH/config
    echo 0x24180430 2 > $DCC_PATH/config
    echo 0x24180438 1 > $DCC_PATH/config
    echo 0x24180430 2 > $DCC_PATH/config
    echo 0x24180430 2 > $DCC_PATH/config
    echo 0x24180430 2 > $DCC_PATH/config
    echo 0x24180430 2 > $DCC_PATH/config
    echo 0x24180408 2 > $DCC_PATH/config

    #; Coherent_even_chain
    echo 0x24101018 1 > $DCC_PATH/config
    echo 0x24101008 1 > $DCC_PATH/config
    echo 0x24101010 2 > $DCC_PATH/config
    echo 0x24101010 2 > $DCC_PATH/config
    echo 0x24101010 2 > $DCC_PATH/config
    echo 0x24101010 2 > $DCC_PATH/config
    #; NonCoherent_even_chain
    echo 0x24101098 1 > $DCC_PATH/config
    echo 0x24101088 1 > $DCC_PATH/config
    echo 0x24101090 2 > $DCC_PATH/config
    echo 0x24101090 2 > $DCC_PATH/config
    echo 0x24101090 2 > $DCC_PATH/config
    echo 0x24101090 2 > $DCC_PATH/config
    echo 0x24101090 2 > $DCC_PATH/config
    #; Coherent_odd_chain
    echo 0x24141018 1 > $DCC_PATH/config
    echo 0x24141008 1 > $DCC_PATH/config
    echo 0x24141010 2 > $DCC_PATH/config
    echo 0x24141010 2 > $DCC_PATH/config
    echo 0x24141010 2 > $DCC_PATH/config
    echo 0x24141010 2 > $DCC_PATH/config
    #; NonCoherent_odd_chain
    echo 0x24141098 1 > $DCC_PATH/config
    echo 0x24141088 1 > $DCC_PATH/config
    echo 0x24141090 2 > $DCC_PATH/config
    echo 0x24141090 2 > $DCC_PATH/config
    echo 0x24141090 2 > $DCC_PATH/config
    echo 0x24141090 2 > $DCC_PATH/config
    echo 0x24141090 2 > $DCC_PATH/config
    #; Coherent_sys_chain
    echo 0x24181018 1 > $DCC_PATH/config
    echo 0x24181008 1 > $DCC_PATH/config
    echo 0x24181010 2 > $DCC_PATH/config
    echo 0x24181010 2 > $DCC_PATH/config
    echo 0x24181010 2 > $DCC_PATH/config
    #; NonCoherent_sys_chain
    echo 0x24181098 1 > $DCC_PATH/config
    echo 0x24181088 1 > $DCC_PATH/config
    echo 0x24181090 2 > $DCC_PATH/config
    echo 0x24181090 2 > $DCC_PATH/config
    echo 0x24181090 2 > $DCC_PATH/config
    echo 0x24181090 2 > $DCC_PATH/config
    echo 0x24181090 2 > $DCC_PATH/config
    echo 0x24181090 2 > $DCC_PATH/config
    echo 0x24181090 2 > $DCC_PATH/config
    echo 0x24181090 2 > $DCC_PATH/config
    echo 0x24181090 2 > $DCC_PATH/config
    echo 0x24181090 2 > $DCC_PATH/config
    echo 0x24181090 2 > $DCC_PATH/config
    echo 0x24181090 2 > $DCC_PATH/config
}

dc_noc_dump()
{
    #; dc_noc_dch_erl
    echo 0x240e0010 1 > $DCC_PATH/config
    echo 0x240e0020 8 > $DCC_PATH/config
    echo 0x240e0248 1 > $DCC_PATH/config
    #; dc_noc_ch_hm02_erl
    echo 0x245f0010 1 > $DCC_PATH/config
    echo 0x245f0020 8 > $DCC_PATH/config
    echo 0x245f0248 1 > $DCC_PATH/config
    #; dc_noc_ch_hm13_erl
    echo 0x247f0010 1 > $DCC_PATH/config
    echo 0x247f0020 8 > $DCC_PATH/config
    echo 0x247f0248 1 > $DCC_PATH/config
    #; llclpi_noc_erl
    echo 0x24330010 1 > $DCC_PATH/config
    echo 0x24330020 8 > $DCC_PATH/config
    echo 0x24330248 1 > $DCC_PATH/config

    #; dch/DebugChain
    echo 0x240e1018 1 > $DCC_PATH/config
    echo 0x240e1008 1 > $DCC_PATH/config
    echo 0x9  > $DCC_PATH/loop
    echo 0x240e1010 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop
    #; ch_hm02/DebugChain
    echo 0x245f2018 1 > $DCC_PATH/config
    echo 0x245f2008 1 > $DCC_PATH/config
    echo 0x3  > $DCC_PATH/loop
    echo 0x245f2010 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop
    #; ch_hm13/DebugChain
    echo 0x247f2018 1 > $DCC_PATH/config
    echo 0x247f2008 1 > $DCC_PATH/config
    echo 0x3  > $DCC_PATH/loop
    echo 0x247f2010 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop
    #; llclpi_noc/DebugChain
    echo 0x24331018 1 > $DCC_PATH/config
    echo 0x24331008 1 > $DCC_PATH/config
    echo 0x8  > $DCC_PATH/loop
    echo 0x24331010 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop
}


lpass_noc_dump()
{
    #; kailua_qtb_lpass_fault_sbm
    echo 0x00506048 1 > $DCC_PATH/config
    #; kailua_qtb_lpass/DebugChain
    echo 0x00510018 1 > $DCC_PATH/config
    echo 0x00510008 1 > $DCC_PATH/config
    echo 0x4  > $DCC_PATH/loop
    echo 0x00510010 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop
    #; kailua_qtb_lpass_QTB500/DebugChain
    echo 0x00511018 1 > $DCC_PATH/config
    echo 0x00511008 1 > $DCC_PATH/config
    echo 0x4  > $DCC_PATH/loop
    echo 0x00511010 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop

    #; lpass_lpiaon_noc_lpiaon_chipcx_erl
    echo 0x07400010 1 > $DCC_PATH/config
    echo 0x07400020 8 > $DCC_PATH/config
    echo 0x07402048 1 > $DCC_PATH/config
    #; lpass_lpiaon_noc_lpiaon_chipcx/DebugChain
    echo 0x07401018 1 > $DCC_PATH/config
    echo 0x07401008 1 > $DCC_PATH/config
    echo 0x07401010 2 > $DCC_PATH/config
    echo 0x07401010 2 > $DCC_PATH/config

    #; lpass_lpiaon_noc_lpiaon_lpicx_erl
    echo 0x07410010 1 > $DCC_PATH/config
    echo 0x07410020 8 > $DCC_PATH/config
    echo 0x07410248 1 > $DCC_PATH/config
    #; lpass_lpiaon_noc_lpiaon_lpicx/DebugChain
    echo 0x07402018 1 > $DCC_PATH/config
    echo 0x07402008 1 > $DCC_PATH/config
    echo 0x07402010 2 > $DCC_PATH/config
    echo 0x07402010 2 > $DCC_PATH/config
    echo 0x07402010 2 > $DCC_PATH/config

    #; lpass_lpicx_erl
    echo 0x07430010 1 > $DCC_PATH/config
    echo 0x07430020 8 > $DCC_PATH/config
    echo 0x07430248 1 > $DCC_PATH/config
    #; lpass_lpicx/DebugChain
    echo 0x07432018 1 > $DCC_PATH/config
    echo 0x07432008 1 > $DCC_PATH/config
    echo 0xd  > $DCC_PATH/loop
    echo 0x07432010 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop

    #; lpass_ag_noc_erl
    echo 0x074e0010 1 > $DCC_PATH/config
    echo 0x074e0020 8 > $DCC_PATH/config
    echo 0x074e0248 1 > $DCC_PATH/config
    #; lpass_ag_noc/DebugChain
    echo 0x074e2018 1 > $DCC_PATH/config
    echo 0x074e2008 1 > $DCC_PATH/config
    echo 0x6  > $DCC_PATH/loop
    echo 0x074e2010 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop
}

mmss_noc_dump()
{
    #; mmss_noc_erl
    echo 0x01780010 1 > $DCC_PATH/config
    echo 0x01780020 8 > $DCC_PATH/config
    echo 0x01780248 1 > $DCC_PATH/config
    #; mmss_noc/DebugChain
    echo 0x01782018 1 > $DCC_PATH/config
    echo 0x01782008 1 > $DCC_PATH/config
    echo 0xc  > $DCC_PATH/loop
    echo 0x01782010 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop
    #; mmss_noc_QTB500/DebugChain
    echo 0x01783018 1 > $DCC_PATH/config
    echo 0x01783008 1 > $DCC_PATH/config
    echo 0x11  > $DCC_PATH/loop
    echo 0x01783010 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop
}

system_noc_dump()
{
    #; system_noc_erl
    echo 0x01680010 1 > $DCC_PATH/config
    echo 0x01680020 8 > $DCC_PATH/config
    echo 0x01681048 1 > $DCC_PATH/config
    #; system_noc/DebugChain
    echo 0x01682018 1 > $DCC_PATH/config
    echo 0x01682008 1 > $DCC_PATH/config
    echo 0x6  > $DCC_PATH/loop
    echo 0x01682010 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop
}

aggre_noc_dump()
{
    #; a1_noc_aggre_noc_erl
    echo 0x016e0010 1 > $DCC_PATH/config
    echo 0x016e0020 8 > $DCC_PATH/config
    echo 0x016e0248 1 > $DCC_PATH/config
    #; a1_noc_aggre_noc_south/DebugChain
    echo 0x016e1018 1 > $DCC_PATH/config
    echo 0x016e1008 1 > $DCC_PATH/config
    echo 0x4  > $DCC_PATH/loop
    echo 0x016e1010 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop
    #; a1_noc_aggre_noc_ANOC_NIU/DebugChain
    echo 0x016e1098 1 > $DCC_PATH/config
    echo 0x016e1088 1 > $DCC_PATH/config
    echo 0x3  > $DCC_PATH/loop
    echo 0x016e1090 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop
    #; a1_noc_aggre_noc_ANOC_QTB/DebugChain
    echo 0x016e1118 1 > $DCC_PATH/config
    echo 0x016e1108 1 > $DCC_PATH/config
    echo 0x7  > $DCC_PATH/loop
    echo 0x016e1110 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop

    #; a2_noc_aggre_noc_erl
    echo 0x01700010 1 > $DCC_PATH/config
    echo 0x01700020 8 > $DCC_PATH/config
    echo 0x01700248 1 > $DCC_PATH/config
    #; a2_noc_aggre_noc_center/DebugChain
    echo 0x01701018 1 > $DCC_PATH/config
    echo 0x01701008 1 > $DCC_PATH/config
    echo 0x4  > $DCC_PATH/loop
    echo 0x01701010 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop
    #; a2_noc_aggre_noc_east/DebugChain
    echo 0x01701098 1 > $DCC_PATH/config
    echo 0x01701088 1 > $DCC_PATH/config
    echo 0x2  > $DCC_PATH/loop
    echo 0x01701090 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop
    #; a2_noc_aggre_noc_north/DebugChain
    echo 0x01701118 1 > $DCC_PATH/config
    echo 0x01701108 1 > $DCC_PATH/config
    echo 0x3  > $DCC_PATH/loop
    echo 0x01701110 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop
}

config_noc_dump()
{
    #; cnoc_cfg_erl
    echo 0x01600010 1 > $DCC_PATH/config
    echo 0x01600020 8 > $DCC_PATH/config
    echo 0x01600248 2 > $DCC_PATH/config
    echo 0x01600258 1 > $DCC_PATH/config
    #; cnoc_cfg_center/DebugChain
    echo 0x01602018 1 > $DCC_PATH/config
    echo 0x01602008 1 > $DCC_PATH/config
    echo 0x7  > $DCC_PATH/loop
    echo 0x01602010 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop
    #; cnoc_cfg_west/DebugChain
    echo 0x01602098 1 > $DCC_PATH/config
    echo 0x01602088 1 > $DCC_PATH/config
    echo 0x2  > $DCC_PATH/loop
    echo 0x01602090 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop
    #; cnoc_cfg_mmnoc/DebugChain
    echo 0x01602118 1 > $DCC_PATH/config
    echo 0x01602108 1 > $DCC_PATH/config
    echo 0x3  > $DCC_PATH/loop
    echo 0x01602110 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop
    #; cnoc_cfg_north/DebugChain
    echo 0x01602198 1 > $DCC_PATH/config
    echo 0x01602188 1 > $DCC_PATH/config
    echo 0x3  > $DCC_PATH/loop
    echo 0x01602190 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop
    #; cnoc_cfg_south/DebugChain
    echo 0x01602218 1 > $DCC_PATH/config
    echo 0x01602208 1 > $DCC_PATH/config
    echo 0x2  > $DCC_PATH/loop
    echo 0x01602210 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop
    #; cnoc_cfg_east/DebugChain
    echo 0x01602298 1 > $DCC_PATH/config
    echo 0x01602288 1 > $DCC_PATH/config
    echo 0x2  > $DCC_PATH/loop
    echo 0x01602290 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop

    #; cnoc_main_erl
    echo 0x01500010 1 > $DCC_PATH/config
    echo 0x01500020 8 > $DCC_PATH/config
    echo 0x01500248 1 > $DCC_PATH/config
    echo 0x01500448 1 > $DCC_PATH/config
    #; cnoc_main_center/DebugChain
    echo 0x01502018 1 > $DCC_PATH/config
    echo 0x01502008 1 > $DCC_PATH/config
    echo 0x7  > $DCC_PATH/loop
    echo 0x01502010 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop
    #; cnoc_main_north/DebugChain
    echo 0x01502098 1 > $DCC_PATH/config
    echo 0x01502088 1 > $DCC_PATH/config
    echo 0x7  > $DCC_PATH/loop
    echo 0x01502090 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop
}

nsp_noc_dump()
{
    #; kailua_qtb_nsp_fault_sbm
    echo 0x00526048 1 > $DCC_PATH/config
    #; kailua_qtb_nsp/DebugChain
    echo 0x00531018 1 > $DCC_PATH/config
    echo 0x00531008 1 > $DCC_PATH/config
    echo 0x4  > $DCC_PATH/loop
    echo 0x00531010 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop
    #; kailua_qtb_nsp_QTB500/DebugChain
    echo 0x00532018 1 > $DCC_PATH/config
    echo 0x00532008 1 > $DCC_PATH/config
    echo 0x4  > $DCC_PATH/loop
    echo 0x00532010 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop

    #; turing_nsp_erl
    echo 0x320c0010 1 > $DCC_PATH/config
    echo 0x320c0020 8 > $DCC_PATH/config
    echo 0x320c0248 1 > $DCC_PATH/config
    #; turing_nsp_noc/DebugChain
    echo 0x320c1018 1 > $DCC_PATH/config
    echo 0x320c1008 1 > $DCC_PATH/config
    echo 0x5  > $DCC_PATH/loop
    echo 0x320c1010 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop
}

config_dcc_ddr()
{
    #DDR -DCC starts here.
    #Start Link list #6
	#DDRSS
	echo 0x2407701c > $DCC_PATH/config
	echo 0x24077030 > $DCC_PATH/config
	echo 0x2408005c > $DCC_PATH/config
	echo 0x240800c8 > $DCC_PATH/config
	echo 0x240800d4 > $DCC_PATH/config
	echo 0x240800e0 > $DCC_PATH/config
	echo 0x240800ec > $DCC_PATH/config
	echo 0x240800f8 > $DCC_PATH/config
	echo 0x240801b4 > $DCC_PATH/config
	echo 0x240a80f8 > $DCC_PATH/config
	echo 0x240a80fc > $DCC_PATH/config
	echo 0x240a8100 > $DCC_PATH/config
	echo 0x240a8104 > $DCC_PATH/config
	echo 0x240a8108 > $DCC_PATH/config
	echo 0x240a810c > $DCC_PATH/config
	echo 0x240a8110 > $DCC_PATH/config
	echo 0x240a8178 > $DCC_PATH/config
	echo 0x240a817c > $DCC_PATH/config
	echo 0x240a8180 > $DCC_PATH/config
	echo 0x240a8184 > $DCC_PATH/config
	echo 0x240a8198 > $DCC_PATH/config
	echo 0x240a81a4 > $DCC_PATH/config
	echo 0x240a81b0 > $DCC_PATH/config
	echo 0x240a81bc > $DCC_PATH/config
	echo 0x240a81c8 > $DCC_PATH/config
	echo 0x240a81cc > $DCC_PATH/config
	echo 0x240a81f4 > $DCC_PATH/config
	echo 0x240a8214 > $DCC_PATH/config
	echo 0x240a8290 > $DCC_PATH/config
	echo 0x240a8804 > $DCC_PATH/config
	echo 0x240a880c > $DCC_PATH/config
	echo 0x240a8860 > $DCC_PATH/config
	echo 0x240a8864 > $DCC_PATH/config
	echo 0x240a8868 > $DCC_PATH/config
	echo 0x240ba28c > $DCC_PATH/config
	echo 0x240ba294 > $DCC_PATH/config
	echo 0x240ba29c > $DCC_PATH/config
	echo 0x24186100 > $DCC_PATH/config
	echo 0x24186104 > $DCC_PATH/config
	echo 0x24186108 > $DCC_PATH/config
	echo 0x2418610c > $DCC_PATH/config
	echo 0x24188100 > $DCC_PATH/config
	echo 0x2418d100 > $DCC_PATH/config
	echo 0x24401e64 > $DCC_PATH/config
	echo 0x24401ea0 > $DCC_PATH/config
	echo 0x24403e64 > $DCC_PATH/config
	echo 0x24403ea0 > $DCC_PATH/config
	echo 0x2440527c > $DCC_PATH/config
	echo 0x24405290 > $DCC_PATH/config
	echo 0x244054ec > $DCC_PATH/config
	echo 0x244054f4 > $DCC_PATH/config
	echo 0x24405514 > $DCC_PATH/config
	echo 0x2440551c > $DCC_PATH/config
	echo 0x24405524 > $DCC_PATH/config
	echo 0x24405548 > $DCC_PATH/config
	echo 0x24405550 > $DCC_PATH/config
	echo 0x24405558 > $DCC_PATH/config
	echo 0x244055b8 > $DCC_PATH/config
	echo 0x244055c0 > $DCC_PATH/config
	echo 0x244055ec > $DCC_PATH/config
	echo 0x24405870 > $DCC_PATH/config
	echo 0x244058a0 > $DCC_PATH/config
	echo 0x244058a8 > $DCC_PATH/config
	echo 0x244058b0 > $DCC_PATH/config
	echo 0x244058b8 > $DCC_PATH/config
	echo 0x244058d8 > $DCC_PATH/config
	echo 0x244058dc > $DCC_PATH/config
	echo 0x244058f4 > $DCC_PATH/config
	echo 0x244058fc > $DCC_PATH/config
	echo 0x24405920 > $DCC_PATH/config
	echo 0x24405928 > $DCC_PATH/config
	echo 0x24405944 > $DCC_PATH/config
	echo 0x24406604 > $DCC_PATH/config
	echo 0x2440660c > $DCC_PATH/config
	echo 0x24440310 > $DCC_PATH/config
	echo 0x24440400 > $DCC_PATH/config
	echo 0x24440404 > $DCC_PATH/config
	echo 0x24440410 > $DCC_PATH/config
	echo 0x24440414 > $DCC_PATH/config
	echo 0x24440418 > $DCC_PATH/config
	echo 0x24440428 > $DCC_PATH/config
	echo 0x24440430 > $DCC_PATH/config
	echo 0x24440440 > $DCC_PATH/config
	echo 0x24440448 > $DCC_PATH/config
	echo 0x244404a0 > $DCC_PATH/config
	echo 0x244404b0 > $DCC_PATH/config
	echo 0x244404b4 > $DCC_PATH/config
	echo 0x244404b8 > $DCC_PATH/config
	echo 0x244404d0 > $DCC_PATH/config
	echo 0x244404d4 > $DCC_PATH/config
	echo 0x2444341c > $DCC_PATH/config
	echo 0x24445804 > $DCC_PATH/config
	echo 0x2444590c > $DCC_PATH/config
	echo 0x24445a14 > $DCC_PATH/config
	echo 0x24445c1c > $DCC_PATH/config
	echo 0x24445c38 > $DCC_PATH/config
	echo 0x24449100 > $DCC_PATH/config
	echo 0x24449110 > $DCC_PATH/config
	echo 0x24449120 > $DCC_PATH/config
	echo 0x24449180 > $DCC_PATH/config
	echo 0x24449184 > $DCC_PATH/config
	echo 0x24460618 > $DCC_PATH/config
	echo 0x24460684 > $DCC_PATH/config
	echo 0x2446068c > $DCC_PATH/config
	echo 0x24481e64 > $DCC_PATH/config
	echo 0x24481ea0 > $DCC_PATH/config
	echo 0x24483e64 > $DCC_PATH/config
	echo 0x24483ea0 > $DCC_PATH/config
	echo 0x2448527c > $DCC_PATH/config
	echo 0x24485290 > $DCC_PATH/config
	echo 0x244854ec > $DCC_PATH/config
	echo 0x244854f4 > $DCC_PATH/config
	echo 0x24485514 > $DCC_PATH/config
	echo 0x2448551c > $DCC_PATH/config
	echo 0x24485524 > $DCC_PATH/config
	echo 0x24485548 > $DCC_PATH/config
	echo 0x24485550 > $DCC_PATH/config
	echo 0x24485558 > $DCC_PATH/config
	echo 0x244855b8 > $DCC_PATH/config
	echo 0x244855c0 > $DCC_PATH/config
	echo 0x244855ec > $DCC_PATH/config
	echo 0x24485870 > $DCC_PATH/config
	echo 0x244858a0 > $DCC_PATH/config
	echo 0x244858a8 > $DCC_PATH/config
	echo 0x244858b0 > $DCC_PATH/config
	echo 0x244858b8 > $DCC_PATH/config
	echo 0x244858d8 > $DCC_PATH/config
	echo 0x244858dc > $DCC_PATH/config
	echo 0x244858f4 > $DCC_PATH/config
	echo 0x244858fc > $DCC_PATH/config
	echo 0x24485920 > $DCC_PATH/config
	echo 0x24485928 > $DCC_PATH/config
	echo 0x24485944 > $DCC_PATH/config
	echo 0x24486604 > $DCC_PATH/config
	echo 0x2448660c > $DCC_PATH/config
	echo 0x244c0310 > $DCC_PATH/config
	echo 0x244c0400 > $DCC_PATH/config
	echo 0x244c0404 > $DCC_PATH/config
	echo 0x244c0410 > $DCC_PATH/config
	echo 0x244c0414 > $DCC_PATH/config
	echo 0x244c0418 > $DCC_PATH/config
	echo 0x244c0428 > $DCC_PATH/config
	echo 0x244c0430 > $DCC_PATH/config
	echo 0x244c0440 > $DCC_PATH/config
	echo 0x244c0448 > $DCC_PATH/config
	echo 0x244c04a0 > $DCC_PATH/config
	echo 0x244c04b0 > $DCC_PATH/config
	echo 0x244c04b4 > $DCC_PATH/config
	echo 0x244c04b8 > $DCC_PATH/config
	echo 0x244c04d0 > $DCC_PATH/config
	echo 0x244c04d4 > $DCC_PATH/config
	echo 0x244c341c > $DCC_PATH/config
	echo 0x244c5804 > $DCC_PATH/config
	echo 0x244c590c > $DCC_PATH/config
	echo 0x244c5a14 > $DCC_PATH/config
	echo 0x244c5c1c > $DCC_PATH/config
	echo 0x244c5c38 > $DCC_PATH/config
	echo 0x244c9100 > $DCC_PATH/config
	echo 0x244c9110 > $DCC_PATH/config
	echo 0x244c9120 > $DCC_PATH/config
	echo 0x244c9180 > $DCC_PATH/config
	echo 0x244c9184 > $DCC_PATH/config
	echo 0x244e0618 > $DCC_PATH/config
	echo 0x244e0684 > $DCC_PATH/config
	echo 0x244e068c > $DCC_PATH/config
	echo 0x24601e64 > $DCC_PATH/config
	echo 0x24601ea0 > $DCC_PATH/config
	echo 0x24603e64 > $DCC_PATH/config
	echo 0x24603ea0 > $DCC_PATH/config
	echo 0x2460527c > $DCC_PATH/config
	echo 0x24605290 > $DCC_PATH/config
	echo 0x246054ec > $DCC_PATH/config
	echo 0x246054f4 > $DCC_PATH/config
	echo 0x24605514 > $DCC_PATH/config
	echo 0x2460551c > $DCC_PATH/config
	echo 0x24605524 > $DCC_PATH/config
	echo 0x24605548 > $DCC_PATH/config
	echo 0x24605550 > $DCC_PATH/config
	echo 0x24605558 > $DCC_PATH/config
	echo 0x246055b8 > $DCC_PATH/config
	echo 0x246055c0 > $DCC_PATH/config
	echo 0x246055ec > $DCC_PATH/config
	echo 0x24605870 > $DCC_PATH/config
	echo 0x246058a0 > $DCC_PATH/config
	echo 0x246058a8 > $DCC_PATH/config
	echo 0x246058b0 > $DCC_PATH/config
	echo 0x246058b8 > $DCC_PATH/config
	echo 0x246058d8 > $DCC_PATH/config
	echo 0x246058dc > $DCC_PATH/config
	echo 0x246058f4 > $DCC_PATH/config
	echo 0x246058fc > $DCC_PATH/config
	echo 0x24605920 > $DCC_PATH/config
	echo 0x24605928 > $DCC_PATH/config
	echo 0x24605944 > $DCC_PATH/config
	echo 0x24606604 > $DCC_PATH/config
	echo 0x2460660c > $DCC_PATH/config
	echo 0x24640310 > $DCC_PATH/config
	echo 0x24640400 > $DCC_PATH/config
	echo 0x24640404 > $DCC_PATH/config
	echo 0x24640410 > $DCC_PATH/config
	echo 0x24640414 > $DCC_PATH/config
	echo 0x24640418 > $DCC_PATH/config
	echo 0x24640428 > $DCC_PATH/config
	echo 0x24640430 > $DCC_PATH/config
	echo 0x24640440 > $DCC_PATH/config
	echo 0x24640448 > $DCC_PATH/config
	echo 0x246404a0 > $DCC_PATH/config
	echo 0x246404b0 > $DCC_PATH/config
	echo 0x246404b4 > $DCC_PATH/config
	echo 0x246404b8 > $DCC_PATH/config
	echo 0x246404d0 > $DCC_PATH/config
	echo 0x246404d4 > $DCC_PATH/config
	echo 0x2464341c > $DCC_PATH/config
	echo 0x24645804 > $DCC_PATH/config
	echo 0x2464590c > $DCC_PATH/config
	echo 0x24645a14 > $DCC_PATH/config
	echo 0x24645c1c > $DCC_PATH/config
	echo 0x24645c38 > $DCC_PATH/config
	echo 0x24649100 > $DCC_PATH/config
	echo 0x24649110 > $DCC_PATH/config
	echo 0x24649120 > $DCC_PATH/config
	echo 0x24649180 > $DCC_PATH/config
	echo 0x24649184 > $DCC_PATH/config
	echo 0x24660618 > $DCC_PATH/config
	echo 0x24660684 > $DCC_PATH/config
	echo 0x2466068c > $DCC_PATH/config
	echo 0x24681e64 > $DCC_PATH/config
	echo 0x24681ea0 > $DCC_PATH/config
	echo 0x24683e64 > $DCC_PATH/config
	echo 0x24683ea0 > $DCC_PATH/config
	echo 0x2468527c > $DCC_PATH/config
	echo 0x24685290 > $DCC_PATH/config
	echo 0x246854ec > $DCC_PATH/config
	echo 0x246854f4 > $DCC_PATH/config
	echo 0x24685514 > $DCC_PATH/config
	echo 0x2468551c > $DCC_PATH/config
	echo 0x24685524 > $DCC_PATH/config
	echo 0x24685548 > $DCC_PATH/config
	echo 0x24685550 > $DCC_PATH/config
	echo 0x24685558 > $DCC_PATH/config
	echo 0x246855b8 > $DCC_PATH/config
	echo 0x246855c0 > $DCC_PATH/config
	echo 0x246855ec > $DCC_PATH/config
	echo 0x24685870 > $DCC_PATH/config
	echo 0x246858a0 > $DCC_PATH/config
	echo 0x246858a8 > $DCC_PATH/config
	echo 0x246858b0 > $DCC_PATH/config
	echo 0x246858b8 > $DCC_PATH/config
	echo 0x246858d8 > $DCC_PATH/config
	echo 0x246858dc > $DCC_PATH/config
	echo 0x246858f4 > $DCC_PATH/config
	echo 0x246858fc > $DCC_PATH/config
	echo 0x24685920 > $DCC_PATH/config
	echo 0x24685928 > $DCC_PATH/config
	echo 0x24685944 > $DCC_PATH/config
	echo 0x24686604 > $DCC_PATH/config
	echo 0x2468660c > $DCC_PATH/config
	echo 0x246c0310 > $DCC_PATH/config
	echo 0x246c0400 > $DCC_PATH/config
	echo 0x246c0404 > $DCC_PATH/config
	echo 0x246c0410 > $DCC_PATH/config
	echo 0x246c0414 > $DCC_PATH/config
	echo 0x246c0418 > $DCC_PATH/config
	echo 0x246c0428 > $DCC_PATH/config
	echo 0x246c0430 > $DCC_PATH/config
	echo 0x246c0440 > $DCC_PATH/config
	echo 0x246c0448 > $DCC_PATH/config
	echo 0x246c04a0 > $DCC_PATH/config
	echo 0x246c04b0 > $DCC_PATH/config
	echo 0x246c04b4 > $DCC_PATH/config
	echo 0x246c04b8 > $DCC_PATH/config
	echo 0x246c04d0 > $DCC_PATH/config
	echo 0x246c04d4 > $DCC_PATH/config
	echo 0x246c341c > $DCC_PATH/config
	echo 0x246c5804 > $DCC_PATH/config
	echo 0x246c590c > $DCC_PATH/config
	echo 0x246c5a14 > $DCC_PATH/config
	echo 0x246c5c1c > $DCC_PATH/config
	echo 0x246c5c38 > $DCC_PATH/config
	echo 0x246c9100 > $DCC_PATH/config
	echo 0x246c9110 > $DCC_PATH/config
	echo 0x246c9120 > $DCC_PATH/config
	echo 0x246c9180 > $DCC_PATH/config
	echo 0x246c9184 > $DCC_PATH/config
	echo 0x246e0618 > $DCC_PATH/config
	echo 0x246e0684 > $DCC_PATH/config
	echo 0x246e068c > $DCC_PATH/config
	echo 0x24840310 > $DCC_PATH/config
	echo 0x24840400 > $DCC_PATH/config
	echo 0x24840404 > $DCC_PATH/config
	echo 0x24840410 > $DCC_PATH/config
	echo 0x24840414 > $DCC_PATH/config
	echo 0x24840418 > $DCC_PATH/config
	echo 0x24840428 > $DCC_PATH/config
	echo 0x24840430 > $DCC_PATH/config
	echo 0x24840440 > $DCC_PATH/config
	echo 0x24840448 > $DCC_PATH/config
	echo 0x248404a0 > $DCC_PATH/config
	echo 0x248404b0 > $DCC_PATH/config
	echo 0x248404b4 > $DCC_PATH/config
	echo 0x248404b8 > $DCC_PATH/config
	echo 0x248404d0 > $DCC_PATH/config
	echo 0x248404d4 > $DCC_PATH/config
	echo 0x2484341c > $DCC_PATH/config
	echo 0x24845804 > $DCC_PATH/config
	echo 0x2484590c > $DCC_PATH/config
	echo 0x24845a14 > $DCC_PATH/config
	echo 0x24845c1c > $DCC_PATH/config
	echo 0x24845c38 > $DCC_PATH/config
	echo 0x24849100 > $DCC_PATH/config
	echo 0x24849110 > $DCC_PATH/config
	echo 0x24849120 > $DCC_PATH/config
	echo 0x24849180 > $DCC_PATH/config
	echo 0x24849184 > $DCC_PATH/config
	echo 0x24860618 > $DCC_PATH/config
	echo 0x24860684 > $DCC_PATH/config
	echo 0x2486068c > $DCC_PATH/config
	echo 0x248c0310 > $DCC_PATH/config
	echo 0x248c0400 > $DCC_PATH/config
	echo 0x248c0404 > $DCC_PATH/config
	echo 0x248c0410 > $DCC_PATH/config
	echo 0x248c0414 > $DCC_PATH/config
	echo 0x248c0418 > $DCC_PATH/config
	echo 0x248c0428 > $DCC_PATH/config
	echo 0x248c0430 > $DCC_PATH/config
	echo 0x248c0440 > $DCC_PATH/config
	echo 0x248c0448 > $DCC_PATH/config
	echo 0x248c04a0 > $DCC_PATH/config
	echo 0x248c04b0 > $DCC_PATH/config
	echo 0x248c04b4 > $DCC_PATH/config
	echo 0x248c04b8 > $DCC_PATH/config
	echo 0x248c04d0 > $DCC_PATH/config
	echo 0x248c04d4 > $DCC_PATH/config
	echo 0x248c341c > $DCC_PATH/config
	echo 0x248c5804 > $DCC_PATH/config
	echo 0x248c590c > $DCC_PATH/config
	echo 0x248c5a14 > $DCC_PATH/config
	echo 0x248c5c1c > $DCC_PATH/config
	echo 0x248c5c38 > $DCC_PATH/config
	echo 0x248c9100 > $DCC_PATH/config
	echo 0x248c9110 > $DCC_PATH/config
	echo 0x248c9120 > $DCC_PATH/config
	echo 0x248c9180 > $DCC_PATH/config
	echo 0x248c9184 > $DCC_PATH/config
	echo 0x248e0618 > $DCC_PATH/config
	echo 0x248e0684 > $DCC_PATH/config
	echo 0x248e068c > $DCC_PATH/config
	echo 0x25020348 > $DCC_PATH/config
	echo 0x25020480 > $DCC_PATH/config
	echo 0x25022400 > $DCC_PATH/config
	echo 0x25023220 > $DCC_PATH/config
	echo 0x25023224 > $DCC_PATH/config
	echo 0x25023228 > $DCC_PATH/config
	echo 0x2502322c > $DCC_PATH/config
	echo 0x25023258 > $DCC_PATH/config
	echo 0x2502325c > $DCC_PATH/config
	echo 0x25023308 > $DCC_PATH/config
	echo 0x25023318 > $DCC_PATH/config
	echo 0x25038100 > $DCC_PATH/config
	echo 0x2503c030 > $DCC_PATH/config
	echo 0x25042044 > $DCC_PATH/config
	echo 0x25042048 > $DCC_PATH/config
	echo 0x2504204c > $DCC_PATH/config
	echo 0x250420b0 > $DCC_PATH/config
	echo 0x25042104 > $DCC_PATH/config
	echo 0x25042114 > $DCC_PATH/config
	echo 0x25048004 > $DCC_PATH/config
	echo 0x25048008 > $DCC_PATH/config
	echo 0x2504800c > $DCC_PATH/config
	echo 0x25048010 > $DCC_PATH/config
	echo 0x25048014 > $DCC_PATH/config
	echo 0x2504c030 > $DCC_PATH/config
	echo 0x25050020 > $DCC_PATH/config
	echo 0x2506004c > $DCC_PATH/config
	echo 0x25060050 > $DCC_PATH/config
	echo 0x25060054 > $DCC_PATH/config
	echo 0x25060058 > $DCC_PATH/config
	echo 0x2506005c > $DCC_PATH/config
	echo 0x25060060 > $DCC_PATH/config
	echo 0x25060064 > $DCC_PATH/config
	echo 0x25060068 > $DCC_PATH/config
	echo 0x25220348 > $DCC_PATH/config
	echo 0x25220480 > $DCC_PATH/config
	echo 0x25222400 > $DCC_PATH/config
	echo 0x25223220 > $DCC_PATH/config
	echo 0x25223224 > $DCC_PATH/config
	echo 0x25223228 > $DCC_PATH/config
	echo 0x2522322c > $DCC_PATH/config
	echo 0x25223258 > $DCC_PATH/config
	echo 0x2522325c > $DCC_PATH/config
	echo 0x25223308 > $DCC_PATH/config
	echo 0x25223318 > $DCC_PATH/config
	echo 0x25238100 > $DCC_PATH/config
	echo 0x2523c030 > $DCC_PATH/config
	echo 0x25242044 > $DCC_PATH/config
	echo 0x25242048 > $DCC_PATH/config
	echo 0x2524204c > $DCC_PATH/config
	echo 0x252420b0 > $DCC_PATH/config
	echo 0x25242104 > $DCC_PATH/config
	echo 0x25242114 > $DCC_PATH/config
	echo 0x25248004 > $DCC_PATH/config
	echo 0x25248008 > $DCC_PATH/config
	echo 0x2524800c > $DCC_PATH/config
	echo 0x25248010 > $DCC_PATH/config
	echo 0x25248014 > $DCC_PATH/config
	echo 0x2524c030 > $DCC_PATH/config
	echo 0x25250020 > $DCC_PATH/config
	echo 0x2526004c > $DCC_PATH/config
	echo 0x25260050 > $DCC_PATH/config
	echo 0x25260054 > $DCC_PATH/config
	echo 0x25260058 > $DCC_PATH/config
	echo 0x2526005c > $DCC_PATH/config
	echo 0x25260060 > $DCC_PATH/config
	echo 0x25260064 > $DCC_PATH/config
	echo 0x25260068 > $DCC_PATH/config
	echo 0x25420348 > $DCC_PATH/config
	echo 0x25420480 > $DCC_PATH/config
	echo 0x25422400 > $DCC_PATH/config
	echo 0x25423220 > $DCC_PATH/config
	echo 0x25423224 > $DCC_PATH/config
	echo 0x25423228 > $DCC_PATH/config
	echo 0x2542322c > $DCC_PATH/config
	echo 0x25423258 > $DCC_PATH/config
	echo 0x2542325c > $DCC_PATH/config
	echo 0x25423308 > $DCC_PATH/config
	echo 0x25423318 > $DCC_PATH/config
	echo 0x25438100 > $DCC_PATH/config
	echo 0x2543c030 > $DCC_PATH/config
	echo 0x25442044 > $DCC_PATH/config
	echo 0x25442048 > $DCC_PATH/config
	echo 0x2544204c > $DCC_PATH/config
	echo 0x254420b0 > $DCC_PATH/config
	echo 0x25442104 > $DCC_PATH/config
	echo 0x25442114 > $DCC_PATH/config
	echo 0x25448004 > $DCC_PATH/config
	echo 0x25448008 > $DCC_PATH/config
	echo 0x2544800c > $DCC_PATH/config
	echo 0x25448010 > $DCC_PATH/config
	echo 0x25448014 > $DCC_PATH/config
	echo 0x2544c030 > $DCC_PATH/config
	echo 0x25450020 > $DCC_PATH/config
	echo 0x2546004c > $DCC_PATH/config
	echo 0x25460050 > $DCC_PATH/config
	echo 0x25460054 > $DCC_PATH/config
	echo 0x25460058 > $DCC_PATH/config
	echo 0x2546005c > $DCC_PATH/config
	echo 0x25460060 > $DCC_PATH/config
	echo 0x25460064 > $DCC_PATH/config
	echo 0x25460068 > $DCC_PATH/config
	echo 0x25620348 > $DCC_PATH/config
	echo 0x25620480 > $DCC_PATH/config
	echo 0x25622400 > $DCC_PATH/config
	echo 0x25623220 > $DCC_PATH/config
	echo 0x25623224 > $DCC_PATH/config
	echo 0x25623228 > $DCC_PATH/config
	echo 0x2562322c > $DCC_PATH/config
	echo 0x25623258 > $DCC_PATH/config
	echo 0x2562325c > $DCC_PATH/config
	echo 0x25623308 > $DCC_PATH/config
	echo 0x25623318 > $DCC_PATH/config
	echo 0x25638100 > $DCC_PATH/config
	echo 0x2563c030 > $DCC_PATH/config
	echo 0x25642044 > $DCC_PATH/config
	echo 0x25642048 > $DCC_PATH/config
	echo 0x2564204c > $DCC_PATH/config
	echo 0x256420b0 > $DCC_PATH/config
	echo 0x25642104 > $DCC_PATH/config
	echo 0x25642114 > $DCC_PATH/config
	echo 0x25648004 > $DCC_PATH/config
	echo 0x25648008 > $DCC_PATH/config
	echo 0x2564800c > $DCC_PATH/config
	echo 0x25648010 > $DCC_PATH/config
	echo 0x25648014 > $DCC_PATH/config
	echo 0x2564c030 > $DCC_PATH/config
	echo 0x25650020 > $DCC_PATH/config
	echo 0x2566004c > $DCC_PATH/config
	echo 0x25660050 > $DCC_PATH/config
	echo 0x25660054 > $DCC_PATH/config
	echo 0x25660058 > $DCC_PATH/config
	echo 0x2566005c > $DCC_PATH/config
	echo 0x25660060 > $DCC_PATH/config
	echo 0x25660064 > $DCC_PATH/config
	echo 0x25660068 > $DCC_PATH/config
	echo 0x25820348 > $DCC_PATH/config
	echo 0x25820480 > $DCC_PATH/config
	echo 0x25822400 > $DCC_PATH/config
	echo 0x25823220 > $DCC_PATH/config
	echo 0x25823224 > $DCC_PATH/config
	echo 0x25823228 > $DCC_PATH/config
	echo 0x2582322c > $DCC_PATH/config
	echo 0x25823258 > $DCC_PATH/config
	echo 0x2582325c > $DCC_PATH/config
	echo 0x25823308 > $DCC_PATH/config
	echo 0x25823318 > $DCC_PATH/config
	echo 0x25838100 > $DCC_PATH/config
	echo 0x2583c030 > $DCC_PATH/config
	echo 0x25842044 > $DCC_PATH/config
	echo 0x25842048 > $DCC_PATH/config
	echo 0x2584204c > $DCC_PATH/config
	echo 0x258420b0 > $DCC_PATH/config
	echo 0x25842104 > $DCC_PATH/config
	echo 0x25842114 > $DCC_PATH/config
	echo 0x25848004 > $DCC_PATH/config
	echo 0x25848008 > $DCC_PATH/config
	echo 0x2584800c > $DCC_PATH/config
	echo 0x25848010 > $DCC_PATH/config
	echo 0x25848014 > $DCC_PATH/config
	echo 0x2584c030 > $DCC_PATH/config
	echo 0x25850020 > $DCC_PATH/config
	echo 0x2586004c > $DCC_PATH/config
	echo 0x25860050 > $DCC_PATH/config
	echo 0x25860054 > $DCC_PATH/config
	echo 0x25860058 > $DCC_PATH/config
	echo 0x2586005c > $DCC_PATH/config
	echo 0x25860060 > $DCC_PATH/config
	echo 0x25860064 > $DCC_PATH/config
	echo 0x25860068 > $DCC_PATH/config
	echo 0x25a20348 > $DCC_PATH/config
	echo 0x25a20480 > $DCC_PATH/config
	echo 0x25a22400 > $DCC_PATH/config
	echo 0x25a23220 > $DCC_PATH/config
	echo 0x25a23224 > $DCC_PATH/config
	echo 0x25a23228 > $DCC_PATH/config
	echo 0x25a2322c > $DCC_PATH/config
	echo 0x25a23258 > $DCC_PATH/config
	echo 0x25a2325c > $DCC_PATH/config
	echo 0x25a23308 > $DCC_PATH/config
	echo 0x25a23318 > $DCC_PATH/config
	echo 0x25a38100 > $DCC_PATH/config
	echo 0x25a3c030 > $DCC_PATH/config
	echo 0x25a42044 > $DCC_PATH/config
	echo 0x25a42048 > $DCC_PATH/config
	echo 0x25a4204c > $DCC_PATH/config
	echo 0x25a420b0 > $DCC_PATH/config
	echo 0x25a42104 > $DCC_PATH/config
	echo 0x25a42114 > $DCC_PATH/config
	echo 0x25a48004 > $DCC_PATH/config
	echo 0x25a48008 > $DCC_PATH/config
	echo 0x25a4800c > $DCC_PATH/config
	echo 0x25a48010 > $DCC_PATH/config
	echo 0x25a48014 > $DCC_PATH/config
	echo 0x25a4c030 > $DCC_PATH/config
	echo 0x25a50020 > $DCC_PATH/config
	echo 0x25a6004c > $DCC_PATH/config
	echo 0x25a60050 > $DCC_PATH/config
	echo 0x25a60054 > $DCC_PATH/config
	echo 0x25a60058 > $DCC_PATH/config
	echo 0x25a6005c > $DCC_PATH/config
	echo 0x25a60060 > $DCC_PATH/config
	echo 0x25a60064 > $DCC_PATH/config
	echo 0x25a60068 > $DCC_PATH/config
	########## > $DCC_PATH/config ####LLCC LCP & LB ##
	echo 0x250a002c > $DCC_PATH/config
	echo 0x250a009c > $DCC_PATH/config
	echo 0x250a00a0 > $DCC_PATH/config
	echo 0x250a00a8 > $DCC_PATH/config
	echo 0x250a00ac > $DCC_PATH/config
	echo 0x250a00b0 > $DCC_PATH/config
	echo 0x250a00b8 > $DCC_PATH/config
	echo 0x250a00c0 > $DCC_PATH/config
	echo 0x250a00c4 > $DCC_PATH/config
	echo 0x250a00cc > $DCC_PATH/config
	echo 0x250a00d0 > $DCC_PATH/config
	echo 0x250a00d4 > $DCC_PATH/config
	echo 0x250a00d8 > $DCC_PATH/config
	echo 0x250a00e0 > $DCC_PATH/config
	echo 0x250a00e8 > $DCC_PATH/config
	echo 0x250a00f0 > $DCC_PATH/config
	echo 0x250a00f0 > $DCC_PATH/config
	echo 0x250a0100 > $DCC_PATH/config
	echo 0x250a0108 > $DCC_PATH/config
	echo 0x250a0110 > $DCC_PATH/config
	echo 0x250a0118 > $DCC_PATH/config
	echo 0x250a0120 > $DCC_PATH/config
	echo 0x250a0128 > $DCC_PATH/config
	echo 0x250a1010 > $DCC_PATH/config
	echo 0x250a1070 > $DCC_PATH/config
	echo 0x250a3004 > $DCC_PATH/config
	echo 0x254a002c > $DCC_PATH/config
	echo 0x254a009c > $DCC_PATH/config
	echo 0x254a00a0 > $DCC_PATH/config
	echo 0x254a00a8 > $DCC_PATH/config
	echo 0x254a00ac > $DCC_PATH/config
	echo 0x254a00b0 > $DCC_PATH/config
	echo 0x254a00b8 > $DCC_PATH/config
	echo 0x254a00c0 > $DCC_PATH/config
	echo 0x254a00c4 > $DCC_PATH/config
	echo 0x254a00cc > $DCC_PATH/config
	echo 0x254a00d0 > $DCC_PATH/config
	echo 0x254a00d4 > $DCC_PATH/config
	echo 0x254a00d8 > $DCC_PATH/config
	echo 0x254a00e0 > $DCC_PATH/config
	echo 0x254a00e8 > $DCC_PATH/config
	echo 0x254a00f0 > $DCC_PATH/config
	echo 0x254a00f0 > $DCC_PATH/config
	echo 0x254a0100 > $DCC_PATH/config
	echo 0x254a0108 > $DCC_PATH/config
	echo 0x254a0110 > $DCC_PATH/config
	echo 0x254a0118 > $DCC_PATH/config
	echo 0x254a0120 > $DCC_PATH/config
	echo 0x254a0128 > $DCC_PATH/config
	echo 0x254a1010 > $DCC_PATH/config
	echo 0x254a1070 > $DCC_PATH/config
	echo 0x254a3004 > $DCC_PATH/config
	echo 0x252a002c > $DCC_PATH/config
	echo 0x252a009c > $DCC_PATH/config
	echo 0x252a00a0 > $DCC_PATH/config
	echo 0x252a00a8 > $DCC_PATH/config
	echo 0x252a00ac > $DCC_PATH/config
	echo 0x252a00b0 > $DCC_PATH/config
	echo 0x252a00b8 > $DCC_PATH/config
	echo 0x252a00c0 > $DCC_PATH/config
	echo 0x252a00c4 > $DCC_PATH/config
	echo 0x252a00cc > $DCC_PATH/config
	echo 0x252a00d0 > $DCC_PATH/config
	echo 0x252a00d4 > $DCC_PATH/config
	echo 0x252a00d8 > $DCC_PATH/config
	echo 0x252a00e0 > $DCC_PATH/config
	echo 0x252a00e8 > $DCC_PATH/config
	echo 0x252a00f0 > $DCC_PATH/config
	echo 0x252a00f0 > $DCC_PATH/config
	echo 0x252a0100 > $DCC_PATH/config
	echo 0x252a0108 > $DCC_PATH/config
	echo 0x252a0110 > $DCC_PATH/config
	echo 0x252a0118 > $DCC_PATH/config
	echo 0x252a0120 > $DCC_PATH/config
	echo 0x252a0128 > $DCC_PATH/config
	echo 0x252a1010 > $DCC_PATH/config
	echo 0x252a1070 > $DCC_PATH/config
	echo 0x252a3004 > $DCC_PATH/config
	echo 0x256a002c > $DCC_PATH/config
	echo 0x256a009c > $DCC_PATH/config
	echo 0x256a00a0 > $DCC_PATH/config
	echo 0x256a00a8 > $DCC_PATH/config
	echo 0x256a00ac > $DCC_PATH/config
	echo 0x256a00b0 > $DCC_PATH/config
	echo 0x256a00b8 > $DCC_PATH/config
	echo 0x256a00c0 > $DCC_PATH/config
	echo 0x256a00c4 > $DCC_PATH/config
	echo 0x256a00cc > $DCC_PATH/config
	echo 0x256a00d0 > $DCC_PATH/config
	echo 0x256a00d4 > $DCC_PATH/config
	echo 0x256a00d8 > $DCC_PATH/config
	echo 0x256a00e0 > $DCC_PATH/config
	echo 0x256a00e8 > $DCC_PATH/config
	echo 0x256a00f0 > $DCC_PATH/config
	echo 0x256a00f0 > $DCC_PATH/config
	echo 0x256a0100 > $DCC_PATH/config
	echo 0x256a0108 > $DCC_PATH/config
	echo 0x256a0110 > $DCC_PATH/config
	echo 0x256a0118 > $DCC_PATH/config
	echo 0x256a0120 > $DCC_PATH/config
	echo 0x256a0128 > $DCC_PATH/config
	echo 0x256a1010 > $DCC_PATH/config
	echo 0x256a1070 > $DCC_PATH/config
	echo 0x256a3004 > $DCC_PATH/config
	echo 0x25076020 > $DCC_PATH/config
	echo 0x25076024 > $DCC_PATH/config
	echo 0x25076028 > $DCC_PATH/config
	echo 0x25076034 > $DCC_PATH/config
	echo 0x25076038 > $DCC_PATH/config
	echo 0x25076040 > $DCC_PATH/config
	echo 0x25076058 > $DCC_PATH/config
	echo 0x25076060 > $DCC_PATH/config
	echo 0x25076064 > $DCC_PATH/config
	echo 0x25076200 > $DCC_PATH/config
	echo 0x25077020 > $DCC_PATH/config
	echo 0x25077030 > $DCC_PATH/config
	echo 0x25077034 > $DCC_PATH/config
	echo 0x25077038 > $DCC_PATH/config
	echo 0x2507703c > $DCC_PATH/config
	echo 0x25077040 > $DCC_PATH/config
	echo 0x25077044 > $DCC_PATH/config
	echo 0x25077048 > $DCC_PATH/config
	echo 0x2507704c > $DCC_PATH/config
	echo 0x25077050 > $DCC_PATH/config
	echo 0x25077054 > $DCC_PATH/config
	echo 0x25077058 > $DCC_PATH/config
	echo 0x2507705c > $DCC_PATH/config
	echo 0x25077060 > $DCC_PATH/config
	echo 0x25077064 > $DCC_PATH/config
	echo 0x25077068 > $DCC_PATH/config
	echo 0x2507706c > $DCC_PATH/config
	echo 0x25077070 > $DCC_PATH/config
	echo 0x25077074 > $DCC_PATH/config
	echo 0x25077078 > $DCC_PATH/config
	echo 0x2507707c > $DCC_PATH/config
	echo 0x25077084 > $DCC_PATH/config
	echo 0x25077090 > $DCC_PATH/config
	echo 0x25077094 > $DCC_PATH/config
	echo 0x25077098 > $DCC_PATH/config
	echo 0x2507709C > $DCC_PATH/config
	echo 0x250770a0 > $DCC_PATH/config
	echo 0x25077218 > $DCC_PATH/config
	echo 0x2507721c > $DCC_PATH/config
	echo 0x25077220 > $DCC_PATH/config
	echo 0x25077224 > $DCC_PATH/config
	echo 0x25077228 > $DCC_PATH/config
	echo 0x2507722c > $DCC_PATH/config
	echo 0x25077230 > $DCC_PATH/config
	echo 0x25077234 > $DCC_PATH/config
	echo 0x25476020 > $DCC_PATH/config
	echo 0x25476024 > $DCC_PATH/config
	echo 0x25476028 > $DCC_PATH/config
	echo 0x25476034 > $DCC_PATH/config
	echo 0x25476038 > $DCC_PATH/config
	echo 0x25476040 > $DCC_PATH/config
	echo 0x25476058 > $DCC_PATH/config
	echo 0x25476060 > $DCC_PATH/config
	echo 0x25476064 > $DCC_PATH/config
	echo 0x25476200 > $DCC_PATH/config
	echo 0x25477020 > $DCC_PATH/config
	echo 0x25477030 > $DCC_PATH/config
	echo 0x25477034 > $DCC_PATH/config
	echo 0x25477038 > $DCC_PATH/config
	echo 0x2547703c > $DCC_PATH/config
	echo 0x25477040 > $DCC_PATH/config
	echo 0x25477044 > $DCC_PATH/config
	echo 0x25477048 > $DCC_PATH/config
	echo 0x2547704c > $DCC_PATH/config
	echo 0x25477050 > $DCC_PATH/config
	echo 0x25477054 > $DCC_PATH/config
	echo 0x25477058 > $DCC_PATH/config
	echo 0x2547705c > $DCC_PATH/config
	echo 0x25477060 > $DCC_PATH/config
	echo 0x25477064 > $DCC_PATH/config
	echo 0x25477068 > $DCC_PATH/config
	echo 0x2547706c > $DCC_PATH/config
	echo 0x25477070 > $DCC_PATH/config
	echo 0x25477074 > $DCC_PATH/config
	echo 0x25477078 > $DCC_PATH/config
	echo 0x2547707c > $DCC_PATH/config
	echo 0x25477084 > $DCC_PATH/config
	echo 0x25477090 > $DCC_PATH/config
	echo 0x25477094 > $DCC_PATH/config
	echo 0x25477098 > $DCC_PATH/config
	echo 0x2547709C > $DCC_PATH/config
	echo 0x254770a0 > $DCC_PATH/config
	echo 0x25477218 > $DCC_PATH/config
	echo 0x2547721c > $DCC_PATH/config
	echo 0x25477220 > $DCC_PATH/config
	echo 0x25477224 > $DCC_PATH/config
	echo 0x25477228 > $DCC_PATH/config
	echo 0x2547722c > $DCC_PATH/config
	echo 0x25477230 > $DCC_PATH/config
	echo 0x25477234 > $DCC_PATH/config
	echo 0x25276020 > $DCC_PATH/config
	echo 0x25276024 > $DCC_PATH/config
	echo 0x25276028 > $DCC_PATH/config
	echo 0x25276034 > $DCC_PATH/config
	echo 0x25276038 > $DCC_PATH/config
	echo 0x25276040 > $DCC_PATH/config
	echo 0x25276058 > $DCC_PATH/config
	echo 0x25276060 > $DCC_PATH/config
	echo 0x25276064 > $DCC_PATH/config
	echo 0x25276200 > $DCC_PATH/config
	echo 0x25277020 > $DCC_PATH/config
	echo 0x25277030 > $DCC_PATH/config
	echo 0x25277034 > $DCC_PATH/config
	echo 0x25277038 > $DCC_PATH/config
	echo 0x2527703c > $DCC_PATH/config
	echo 0x25277040 > $DCC_PATH/config
	echo 0x25277044 > $DCC_PATH/config
	echo 0x25277048 > $DCC_PATH/config
	echo 0x2527704c > $DCC_PATH/config
	echo 0x25277050 > $DCC_PATH/config
	echo 0x25277054 > $DCC_PATH/config
	echo 0x25277058 > $DCC_PATH/config
	echo 0x2527705c > $DCC_PATH/config
	echo 0x25277060 > $DCC_PATH/config
	echo 0x25277064 > $DCC_PATH/config
	echo 0x25277068 > $DCC_PATH/config
	echo 0x2527706c > $DCC_PATH/config
	echo 0x25277070 > $DCC_PATH/config
	echo 0x25277074 > $DCC_PATH/config
	echo 0x25277078 > $DCC_PATH/config
	echo 0x2527707c > $DCC_PATH/config
	echo 0x25277084 > $DCC_PATH/config
	echo 0x25277090 > $DCC_PATH/config
	echo 0x25277094 > $DCC_PATH/config
	echo 0x25277098 > $DCC_PATH/config
	echo 0x2527709C > $DCC_PATH/config
	echo 0x252770a0 > $DCC_PATH/config
	echo 0x25277218 > $DCC_PATH/config
	echo 0x2527721c > $DCC_PATH/config
	echo 0x25277220 > $DCC_PATH/config
	echo 0x25277224 > $DCC_PATH/config
	echo 0x25277228 > $DCC_PATH/config
	echo 0x2527722c > $DCC_PATH/config
	echo 0x25277230 > $DCC_PATH/config
	echo 0x25277234 > $DCC_PATH/config
	echo 0x25676020 > $DCC_PATH/config
	echo 0x25676024 > $DCC_PATH/config
	echo 0x25676028 > $DCC_PATH/config
	echo 0x25676034 > $DCC_PATH/config
	echo 0x25676038 > $DCC_PATH/config
	echo 0x25676040 > $DCC_PATH/config
	echo 0x25676058 > $DCC_PATH/config
	echo 0x25676060 > $DCC_PATH/config
	echo 0x25676064 > $DCC_PATH/config
	echo 0x25676200 > $DCC_PATH/config
	echo 0x25677020 > $DCC_PATH/config
	echo 0x25677030 > $DCC_PATH/config
	echo 0x25677034 > $DCC_PATH/config
	echo 0x25677038 > $DCC_PATH/config
	echo 0x2567703c > $DCC_PATH/config
	echo 0x25677040 > $DCC_PATH/config
	echo 0x25677044 > $DCC_PATH/config
	echo 0x25677048 > $DCC_PATH/config
	echo 0x2567704c > $DCC_PATH/config
	echo 0x25677050 > $DCC_PATH/config
	echo 0x25677054 > $DCC_PATH/config
	echo 0x25677058 > $DCC_PATH/config
	echo 0x2567705c > $DCC_PATH/config
	echo 0x25677060 > $DCC_PATH/config
	echo 0x25677064 > $DCC_PATH/config
	echo 0x25677068 > $DCC_PATH/config
	echo 0x2567706c > $DCC_PATH/config
	echo 0x25677070 > $DCC_PATH/config
	echo 0x25677074 > $DCC_PATH/config
	echo 0x25677078 > $DCC_PATH/config
	echo 0x2567707c > $DCC_PATH/config
	echo 0x25677084 > $DCC_PATH/config
	echo 0x25677090 > $DCC_PATH/config
	echo 0x25677094 > $DCC_PATH/config
	echo 0x25677098 > $DCC_PATH/config
	echo 0x2567709C > $DCC_PATH/config
	echo 0x256770a0 > $DCC_PATH/config
	echo 0x25677218 > $DCC_PATH/config
	echo 0x2567721c > $DCC_PATH/config
	echo 0x25677220 > $DCC_PATH/config
	echo 0x25677224 > $DCC_PATH/config
	echo 0x25677228 > $DCC_PATH/config
	echo 0x2567722c > $DCC_PATH/config
	echo 0x25677230 > $DCC_PATH/config
	echo 0x25677234 > $DCC_PATH/config
	########## > $DCC_PATH/config ###LPI#
	echo 0x250a6008 > $DCC_PATH/config
	echo 0x250a600c > $DCC_PATH/config
	echo 0x250a6010 > $DCC_PATH/config
	echo 0x250a7008 > $DCC_PATH/config
	echo 0x250a700c > $DCC_PATH/config
	echo 0x250a7010 > $DCC_PATH/config
	echo 0x254a6008 > $DCC_PATH/config
	echo 0x254a600c > $DCC_PATH/config
	echo 0x254a6010 > $DCC_PATH/config
	echo 0x254a7008 > $DCC_PATH/config
	echo 0x254a700c > $DCC_PATH/config
	echo 0x254a7010 > $DCC_PATH/config
	echo 0x252a6008 > $DCC_PATH/config
	echo 0x252a600c > $DCC_PATH/config
	echo 0x252a6010 > $DCC_PATH/config
	echo 0x252a7008 > $DCC_PATH/config
	echo 0x252a700c > $DCC_PATH/config
	echo 0x252a7010 > $DCC_PATH/config
	echo 0x256a6008 > $DCC_PATH/config
	echo 0x256a600c > $DCC_PATH/config
	echo 0x256a6010 > $DCC_PATH/config
	echo 0x256a7008 > $DCC_PATH/config
	echo 0x256a700c > $DCC_PATH/config
	echo 0x256a7010 > $DCC_PATH/config
	echo 0x2507718c > $DCC_PATH/config
	echo 0x250771b0 > $DCC_PATH/config
	echo 0x25077204 > $DCC_PATH/config
	echo 0x25077208 > $DCC_PATH/config
	echo 0x2507720c > $DCC_PATH/config
	echo 0x25077210 > $DCC_PATH/config
	echo 0x25077214 > $DCC_PATH/config
	echo 0x25023210 > $DCC_PATH/config
	echo 0x25025010 > $DCC_PATH/config
	echo 0x25025000 > $DCC_PATH/config
	echo 0x25040064 > $DCC_PATH/config
	echo 0x25040070 > $DCC_PATH/config
	echo 0x25040074 > $DCC_PATH/config
	echo 0x25040078 > $DCC_PATH/config
	echo 0x2504007c > $DCC_PATH/config
	echo 0x25040080 > $DCC_PATH/config
	echo 0x2504002c > $DCC_PATH/config
	echo 0x25040030 > $DCC_PATH/config
	echo 0x25040034 > $DCC_PATH/config
	echo 0x25040038 > $DCC_PATH/config
	echo 0x25040048 > $DCC_PATH/config
	echo 0x2504004c > $DCC_PATH/config
	echo 0x25040050 > $DCC_PATH/config
	echo 0x25040054 > $DCC_PATH/config
	echo 0x25040058 > $DCC_PATH/config
	echo 0x25040060 > $DCC_PATH/config
	echo 0x2547718c > $DCC_PATH/config
	echo 0x254771b0 > $DCC_PATH/config
	echo 0x25477204 > $DCC_PATH/config
	echo 0x25477208 > $DCC_PATH/config
	echo 0x2547720c > $DCC_PATH/config
	echo 0x25477210 > $DCC_PATH/config
	echo 0x25477214 > $DCC_PATH/config
	echo 0x25423210 > $DCC_PATH/config
	echo 0x25425010 > $DCC_PATH/config
	echo 0x25425000 > $DCC_PATH/config
	echo 0x25440064 > $DCC_PATH/config
	echo 0x25440070 > $DCC_PATH/config
	echo 0x25440074 > $DCC_PATH/config
	echo 0x25440078 > $DCC_PATH/config
	echo 0x2544007c > $DCC_PATH/config
	echo 0x25440080 > $DCC_PATH/config
	echo 0x2544002c > $DCC_PATH/config
	echo 0x25440030 > $DCC_PATH/config
	echo 0x25440034 > $DCC_PATH/config
	echo 0x25440038 > $DCC_PATH/config
	echo 0x25440048 > $DCC_PATH/config
	echo 0x2544004c > $DCC_PATH/config
	echo 0x25440050 > $DCC_PATH/config
	echo 0x25440054 > $DCC_PATH/config
	echo 0x25440058 > $DCC_PATH/config
	echo 0x25440060 > $DCC_PATH/config
	echo 0x2527718c > $DCC_PATH/config
	echo 0x252771b0 > $DCC_PATH/config
	echo 0x25277204 > $DCC_PATH/config
	echo 0x25277208 > $DCC_PATH/config
	echo 0x2527720c > $DCC_PATH/config
	echo 0x25277210 > $DCC_PATH/config
	echo 0x25277214 > $DCC_PATH/config
	echo 0x25223210 > $DCC_PATH/config
	echo 0x25225010 > $DCC_PATH/config
	echo 0x25225000 > $DCC_PATH/config
	echo 0x25240064 > $DCC_PATH/config
	echo 0x25240070 > $DCC_PATH/config
	echo 0x25240074 > $DCC_PATH/config
	echo 0x25240078 > $DCC_PATH/config
	echo 0x2524007c > $DCC_PATH/config
	echo 0x25240080 > $DCC_PATH/config
	echo 0x2524002c > $DCC_PATH/config
	echo 0x25240030 > $DCC_PATH/config
	echo 0x25240034 > $DCC_PATH/config
	echo 0x25240038 > $DCC_PATH/config
	echo 0x25240048 > $DCC_PATH/config
	echo 0x2524004c > $DCC_PATH/config
	echo 0x25240050 > $DCC_PATH/config
	echo 0x25240054 > $DCC_PATH/config
	echo 0x25240058 > $DCC_PATH/config
	echo 0x25240060 > $DCC_PATH/config
	echo 0x2567718c > $DCC_PATH/config
	echo 0x256771b0 > $DCC_PATH/config
	echo 0x25677204 > $DCC_PATH/config
	echo 0x25677208 > $DCC_PATH/config
	echo 0x2567720c > $DCC_PATH/config
	echo 0x25677210 > $DCC_PATH/config
	echo 0x25677214 > $DCC_PATH/config
	echo 0x25623210 > $DCC_PATH/config
	echo 0x25625010 > $DCC_PATH/config
	echo 0x25625000 > $DCC_PATH/config
	echo 0x25640064 > $DCC_PATH/config
	echo 0x25640070 > $DCC_PATH/config
	echo 0x25640074 > $DCC_PATH/config
	echo 0x25640078 > $DCC_PATH/config
	echo 0x2564007c > $DCC_PATH/config
	echo 0x25640080 > $DCC_PATH/config
	echo 0x2564002c > $DCC_PATH/config
	echo 0x25640030 > $DCC_PATH/config
	echo 0x25640034 > $DCC_PATH/config
	echo 0x25640038 > $DCC_PATH/config
	echo 0x25640048 > $DCC_PATH/config
	echo 0x2564004c > $DCC_PATH/config
	echo 0x25640050 > $DCC_PATH/config
	echo 0x25640054 > $DCC_PATH/config
	echo 0x25640058 > $DCC_PATH/config
	echo 0x25640060 > $DCC_PATH/config
		########## > $DCC_PATH/config ####DARE######################
	echo 0x250a9004 > $DCC_PATH/config
	echo 0x250a9010 > $DCC_PATH/config
	echo 0x250a9014 > $DCC_PATH/config
	echo 0x250a9018 > $DCC_PATH/config
	echo 0x250a9020 > $DCC_PATH/config
	echo 0x250a9024 > $DCC_PATH/config
	echo 0x250a9028 > $DCC_PATH/config
	echo 0x250a9030 > $DCC_PATH/config
	echo 0x250a9034 > $DCC_PATH/config
	echo 0x250a9038 > $DCC_PATH/config
	echo 0x250a9040 > $DCC_PATH/config
	echo 0x250a9044 > $DCC_PATH/config
	echo 0x250a9048 > $DCC_PATH/config
	echo 0x250a9050 > $DCC_PATH/config
	echo 0x250a9054 > $DCC_PATH/config
	echo 0x250a9058 > $DCC_PATH/config
	echo 0x250aa004 > $DCC_PATH/config
	echo 0x250aa010 > $DCC_PATH/config
	echo 0x250aa014 > $DCC_PATH/config
	echo 0x250aa018 > $DCC_PATH/config
	echo 0x250aa020 > $DCC_PATH/config
	echo 0x250aa024 > $DCC_PATH/config
	echo 0x250aa028 > $DCC_PATH/config
	echo 0x250aa030 > $DCC_PATH/config
	echo 0x250aa034 > $DCC_PATH/config
	echo 0x250aa038 > $DCC_PATH/config
	echo 0x250aa040 > $DCC_PATH/config
	echo 0x250aa044 > $DCC_PATH/config
	echo 0x250aa048 > $DCC_PATH/config
	echo 0x250aa050 > $DCC_PATH/config
	echo 0x250aa054 > $DCC_PATH/config
	echo 0x250aa058 > $DCC_PATH/config
	echo 0x250b001c > $DCC_PATH/config
	echo 0x250b101c > $DCC_PATH/config
	echo 0x250b201c > $DCC_PATH/config
	echo 0x250b301c > $DCC_PATH/config
	echo 0x250b401c > $DCC_PATH/config
	echo 0x250b501c > $DCC_PATH/config
	echo 0x250b601c > $DCC_PATH/config
	echo 0x250b701c > $DCC_PATH/config
	echo 0x250b801c > $DCC_PATH/config
	echo 0x250b901c > $DCC_PATH/config
	echo 0x250ba01c > $DCC_PATH/config
	echo 0x250bb01c > $DCC_PATH/config
	echo 0x250bc01c > $DCC_PATH/config
	echo 0x250bd01c > $DCC_PATH/config
	echo 0x250be01c > $DCC_PATH/config
	echo 0x250bf01c > $DCC_PATH/config
	echo 0x254a9004 > $DCC_PATH/config
	echo 0x254a9010 > $DCC_PATH/config
	echo 0x254a9014 > $DCC_PATH/config
	echo 0x254a9018 > $DCC_PATH/config
	echo 0x254a9020 > $DCC_PATH/config
	echo 0x254a9024 > $DCC_PATH/config
	echo 0x254a9028 > $DCC_PATH/config
	echo 0x254a9030 > $DCC_PATH/config
	echo 0x254a9034 > $DCC_PATH/config
	echo 0x254a9038 > $DCC_PATH/config
	echo 0x254a9040 > $DCC_PATH/config
	echo 0x254a9044 > $DCC_PATH/config
	echo 0x254a9048 > $DCC_PATH/config
	echo 0x254a9050 > $DCC_PATH/config
	echo 0x254a9054 > $DCC_PATH/config
	echo 0x254a9058 > $DCC_PATH/config
	echo 0x254aa004 > $DCC_PATH/config
	echo 0x254aa010 > $DCC_PATH/config
	echo 0x254aa014 > $DCC_PATH/config
	echo 0x254aa018 > $DCC_PATH/config
	echo 0x254aa020 > $DCC_PATH/config
	echo 0x254aa024 > $DCC_PATH/config
	echo 0x254aa028 > $DCC_PATH/config
	echo 0x254aa030 > $DCC_PATH/config
	echo 0x254aa034 > $DCC_PATH/config
	echo 0x254aa038 > $DCC_PATH/config
	echo 0x254aa040 > $DCC_PATH/config
	echo 0x254aa044 > $DCC_PATH/config
	echo 0x254aa048 > $DCC_PATH/config
	echo 0x254aa050 > $DCC_PATH/config
	echo 0x254aa054 > $DCC_PATH/config
	echo 0x254aa058 > $DCC_PATH/config
	echo 0x254b001c > $DCC_PATH/config
	echo 0x254b101c > $DCC_PATH/config
	echo 0x254b201c > $DCC_PATH/config
	echo 0x254b301c > $DCC_PATH/config
	echo 0x254b401c > $DCC_PATH/config
	echo 0x254b501c > $DCC_PATH/config
	echo 0x254b601c > $DCC_PATH/config
	echo 0x254b701c > $DCC_PATH/config
	echo 0x254b801c > $DCC_PATH/config
	echo 0x254b901c > $DCC_PATH/config
	echo 0x254ba01c > $DCC_PATH/config
	echo 0x254bb01c > $DCC_PATH/config
	echo 0x254bc01c > $DCC_PATH/config
	echo 0x254bd01c > $DCC_PATH/config
	echo 0x254be01c > $DCC_PATH/config
	echo 0x254bf01c > $DCC_PATH/config
	echo 0x252a9004 > $DCC_PATH/config
	echo 0x252a9010 > $DCC_PATH/config
	echo 0x252a9014 > $DCC_PATH/config
	echo 0x252a9018 > $DCC_PATH/config
	echo 0x252a9020 > $DCC_PATH/config
	echo 0x252a9024 > $DCC_PATH/config
	echo 0x252a9028 > $DCC_PATH/config
	echo 0x252a9030 > $DCC_PATH/config
	echo 0x252a9034 > $DCC_PATH/config
	echo 0x252a9038 > $DCC_PATH/config
	echo 0x252a9040 > $DCC_PATH/config
	echo 0x252a9044 > $DCC_PATH/config
	echo 0x252a9048 > $DCC_PATH/config
	echo 0x252a9050 > $DCC_PATH/config
	echo 0x252a9054 > $DCC_PATH/config
	echo 0x252a9058 > $DCC_PATH/config
	echo 0x252aa004 > $DCC_PATH/config
	echo 0x252aa010 > $DCC_PATH/config
	echo 0x252aa014 > $DCC_PATH/config
	echo 0x252aa018 > $DCC_PATH/config
	echo 0x252aa020 > $DCC_PATH/config
	echo 0x252aa024 > $DCC_PATH/config
	echo 0x252aa028 > $DCC_PATH/config
	echo 0x252aa030 > $DCC_PATH/config
	echo 0x252aa034 > $DCC_PATH/config
	echo 0x252aa038 > $DCC_PATH/config
	echo 0x252aa040 > $DCC_PATH/config
	echo 0x252aa044 > $DCC_PATH/config
	echo 0x252aa048 > $DCC_PATH/config
	echo 0x252aa050 > $DCC_PATH/config
	echo 0x252aa054 > $DCC_PATH/config
	echo 0x252aa058 > $DCC_PATH/config
	echo 0x252b001c > $DCC_PATH/config
	echo 0x252b101c > $DCC_PATH/config
	echo 0x252b201c > $DCC_PATH/config
	echo 0x252b301c > $DCC_PATH/config
	echo 0x252b401c > $DCC_PATH/config
	echo 0x252b501c > $DCC_PATH/config
	echo 0x252b601c > $DCC_PATH/config
	echo 0x252b701c > $DCC_PATH/config
	echo 0x252b801c > $DCC_PATH/config
	echo 0x252b901c > $DCC_PATH/config
	echo 0x252ba01c > $DCC_PATH/config
	echo 0x252bb01c > $DCC_PATH/config
	echo 0x252bc01c > $DCC_PATH/config
	echo 0x252bd01c > $DCC_PATH/config
	echo 0x252be01c > $DCC_PATH/config
	echo 0x252bf01c > $DCC_PATH/config
	echo 0x256a9004 > $DCC_PATH/config
	echo 0x256a9010 > $DCC_PATH/config
	echo 0x256a9014 > $DCC_PATH/config
	echo 0x256a9018 > $DCC_PATH/config
	echo 0x256a9020 > $DCC_PATH/config
	echo 0x256a9024 > $DCC_PATH/config
	echo 0x256a9028 > $DCC_PATH/config
	echo 0x256a9030 > $DCC_PATH/config
	echo 0x256a9034 > $DCC_PATH/config
	echo 0x256a9038 > $DCC_PATH/config
	echo 0x256a9040 > $DCC_PATH/config
	echo 0x256a9044 > $DCC_PATH/config
	echo 0x256a9048 > $DCC_PATH/config
	echo 0x256a9050 > $DCC_PATH/config
	echo 0x256a9054 > $DCC_PATH/config
	echo 0x256a9058 > $DCC_PATH/config
	echo 0x256aa004 > $DCC_PATH/config
	echo 0x256aa010 > $DCC_PATH/config
	echo 0x256aa014 > $DCC_PATH/config
	echo 0x256aa018 > $DCC_PATH/config
	echo 0x256aa020 > $DCC_PATH/config
	echo 0x256aa024 > $DCC_PATH/config
	echo 0x256aa028 > $DCC_PATH/config
	echo 0x256aa030 > $DCC_PATH/config
	echo 0x256aa034 > $DCC_PATH/config
	echo 0x256aa038 > $DCC_PATH/config
	echo 0x256aa040 > $DCC_PATH/config
	echo 0x256aa044 > $DCC_PATH/config
	echo 0x256aa048 > $DCC_PATH/config
	echo 0x256aa050 > $DCC_PATH/config
	echo 0x256aa054 > $DCC_PATH/config
	echo 0x256aa058 > $DCC_PATH/config
	echo 0x256b001c > $DCC_PATH/config
	echo 0x256b101c > $DCC_PATH/config
	echo 0x256b201c > $DCC_PATH/config
	echo 0x256b301c > $DCC_PATH/config
	echo 0x256b401c > $DCC_PATH/config
	echo 0x256b501c > $DCC_PATH/config
	echo 0x256b601c > $DCC_PATH/config
	echo 0x256b701c > $DCC_PATH/config
	echo 0x256b801c > $DCC_PATH/config
	echo 0x256b901c > $DCC_PATH/config
	echo 0x256ba01c > $DCC_PATH/config
	echo 0x256bb01c > $DCC_PATH/config
	echo 0x256bc01c > $DCC_PATH/config
	echo 0x256bd01c > $DCC_PATH/config
	echo 0x256be01c > $DCC_PATH/config
	echo 0x256bf01c > $DCC_PATH/config
	#LLCC_BROADCAST_ORLLCC_LCP_REGION
	echo 0x258a4040 > $DCC_PATH/config
	echo 0x258a4044 > $DCC_PATH/config
	echo 0x258a4048 > $DCC_PATH/config
	echo 0x258a404c > $DCC_PATH/config
	echo 0x258a4050 > $DCC_PATH/config
	echo 0x258a4054 > $DCC_PATH/config
	echo 0x258a4058 > $DCC_PATH/config
	echo 0x258a405c > $DCC_PATH/config
	echo 0x258a4060 > $DCC_PATH/config
	echo 0x258a4064 > $DCC_PATH/config
	echo 0x258a4068 > $DCC_PATH/config
	echo 0x258a406c > $DCC_PATH/config
	echo 0x258a4070 > $DCC_PATH/config
	echo 0x258a4074 > $DCC_PATH/config
	echo 0x258a4078 > $DCC_PATH/config
	echo 0x258a407c > $DCC_PATH/config
	echo 0x258a4080 > $DCC_PATH/config
	echo 0x258a4084 > $DCC_PATH/config
	echo 0x258a4088 > $DCC_PATH/config
	echo 0x258a408c > $DCC_PATH/config
	echo 0x258a4090 > $DCC_PATH/config
	echo 0x258a4094 > $DCC_PATH/config
	echo 0x258a4098 > $DCC_PATH/config
	echo 0x258a409c > $DCC_PATH/config
	echo 0x258a40a0 > $DCC_PATH/config
	echo 0x258a40a4 > $DCC_PATH/config
	echo 0x258a40a8 > $DCC_PATH/config
	echo 0x258a40ac > $DCC_PATH/config
	echo 0x258a40b0 > $DCC_PATH/config
	echo 0x258a40b4 > $DCC_PATH/config
	echo 0x258a40b8 > $DCC_PATH/config
	echo 0x258a40bc > $DCC_PATH/config
	echo 0x258a40c0 > $DCC_PATH/config
	echo 0x258a40c4 > $DCC_PATH/config
	echo 0x258a40c8 > $DCC_PATH/config
	echo 0x258a40cc > $DCC_PATH/config
	echo 0x258a40d0 > $DCC_PATH/config
	echo 0x258a40d4 > $DCC_PATH/config
	echo 0x258a40d8 > $DCC_PATH/config
	echo 0x258a40dc > $DCC_PATH/config
	echo 0x258a40e0 > $DCC_PATH/config
	echo 0x258a40e4 > $DCC_PATH/config
	echo 0x258a40e8 > $DCC_PATH/config
	echo 0x258a40ec > $DCC_PATH/config
	echo 0x258a40f0 > $DCC_PATH/config
	echo 0x258a40f4 > $DCC_PATH/config
	echo 0x258a40f8 > $DCC_PATH/config
	echo 0x258a40fc > $DCC_PATH/config
	echo 0x258b0000 > $DCC_PATH/config
	echo 0x258b1000 > $DCC_PATH/config
	echo 0x258b2000 > $DCC_PATH/config
	echo 0x258b3000 > $DCC_PATH/config
	echo 0x258b4000 > $DCC_PATH/config
	echo 0x258b5000 > $DCC_PATH/config
	echo 0x258b6000 > $DCC_PATH/config
	echo 0x258b7000 > $DCC_PATH/config
	echo 0x258b8000 > $DCC_PATH/config
	echo 0x258b9000 > $DCC_PATH/config
	echo 0x258ba000 > $DCC_PATH/config
	echo 0x258bb000 > $DCC_PATH/config
	echo 0x258bc000 > $DCC_PATH/config
	echo 0x258bd000 > $DCC_PATH/config
	echo 0x258be000 > $DCC_PATH/config
	echo 0x258bf000 > $DCC_PATH/config
	echo 0x258b005c > $DCC_PATH/config
	echo 0x258b105c > $DCC_PATH/config
	echo 0x258b205c > $DCC_PATH/config
	echo 0x258b305c > $DCC_PATH/config
	echo 0x258b405c > $DCC_PATH/config
	echo 0x258b505c > $DCC_PATH/config
	echo 0x258b605c > $DCC_PATH/config
	echo 0x258b705c > $DCC_PATH/config
	echo 0x258b805c > $DCC_PATH/config
	echo 0x258b905c > $DCC_PATH/config
	echo 0x258ba05c > $DCC_PATH/config
	echo 0x258bb05c > $DCC_PATH/config
	echo 0x258bc05c > $DCC_PATH/config
	echo 0x258bd05c > $DCC_PATH/config
	echo 0x258be05c > $DCC_PATH/config
	echo 0x258bf05c > $DCC_PATH/config

    #End Link list #6


}

config_dcc_rpmh()
{
    echo 0xB281024 > $DCC_PATH/config
    echo 0xBDE1034 > $DCC_PATH/config

    #RPMH_PDC_APSS
    echo 0xB201020 2 > $DCC_PATH/config
    echo 0xB211020 2 > $DCC_PATH/config
    echo 0xB221020 2 > $DCC_PATH/config
    echo 0xB231020 2 > $DCC_PATH/config
    echo 0xB204520 > $DCC_PATH/config
}

config_dcc_apss_rscc()
{
    #APSS_RSCC_RSC register
    echo 0x17A00010 > $DCC_PATH/config
    echo 0x17A10010 > $DCC_PATH/config
    echo 0x17A20010 > $DCC_PATH/config
    echo 0x17A30010 > $DCC_PATH/config
    echo 0x17A00030 > $DCC_PATH/config
    echo 0x17A10030 > $DCC_PATH/config
    echo 0x17A20030 > $DCC_PATH/config
    echo 0x17A30030 > $DCC_PATH/config
    echo 0x17A00038 > $DCC_PATH/config
    echo 0x17A10038 > $DCC_PATH/config
    echo 0x17A20038 > $DCC_PATH/config
    echo 0x17A30038 > $DCC_PATH/config
    echo 0x17A00040 > $DCC_PATH/config
    echo 0x17A10040 > $DCC_PATH/config
    echo 0x17A20040 > $DCC_PATH/config
    echo 0x17A30040 > $DCC_PATH/config
    echo 0x17A00048 > $DCC_PATH/config
    echo 0x17A00400 3 > $DCC_PATH/config
    echo 0x17A10400 3 > $DCC_PATH/config
    echo 0x17A20400 3 > $DCC_PATH/config
    echo 0x17A30400 3 > $DCC_PATH/config
}

config_dcc_misc()
{
    #secure WDOG register
    echo 0xC230000 6 > $DCC_PATH/config
    #Register: QFPROM_RAW_PTE_ROW0_LSB
    echo 0x221C0098 > $DCC_PATH/config
}

config_dcc_epss()
{
    #EPSSFAST_SEQ_MEM_r register
    echo 0x17D10200 256 > $DCC_PATH/config
}

config_dcc_gict()
{
    echo 0x17120000  > $DCC_PATH/config
    echo 0x17120008  > $DCC_PATH/config
    echo 0x17120010  > $DCC_PATH/config
    echo 0x17120018  > $DCC_PATH/config
    echo 0x17120020  > $DCC_PATH/config
    echo 0x17120028  > $DCC_PATH/config
    echo 0x17120040  > $DCC_PATH/config
    echo 0x17120048  > $DCC_PATH/config
    echo 0x17120050  > $DCC_PATH/config
    echo 0x17120058  > $DCC_PATH/config
    echo 0x17120060  > $DCC_PATH/config
    echo 0x17120068  > $DCC_PATH/config
    echo 0x17120080  > $DCC_PATH/config
    echo 0x17120088  > $DCC_PATH/config
    echo 0x17120090  > $DCC_PATH/config
    echo 0x17120098  > $DCC_PATH/config
    echo 0x171200a0  > $DCC_PATH/config
    echo 0x171200a8  > $DCC_PATH/config
    echo 0x171200c0  > $DCC_PATH/config
    echo 0x171200c8  > $DCC_PATH/config
    echo 0x171200d0  > $DCC_PATH/config
    echo 0x171200d8  > $DCC_PATH/config
    echo 0x171200e0  > $DCC_PATH/config
    echo 0x171200e8  > $DCC_PATH/config
    echo 0x17120100  > $DCC_PATH/config
    echo 0x17120108  > $DCC_PATH/config
    echo 0x17120110  > $DCC_PATH/config
    echo 0x17120118  > $DCC_PATH/config
    echo 0x17120120  > $DCC_PATH/config
    echo 0x17120128  > $DCC_PATH/config
    echo 0x17120140  > $DCC_PATH/config
    echo 0x17120148  > $DCC_PATH/config
    echo 0x17120150  > $DCC_PATH/config
    echo 0x17120158  > $DCC_PATH/config
    echo 0x17120160  > $DCC_PATH/config
    echo 0x17120168  > $DCC_PATH/config
    echo 0x17120180  > $DCC_PATH/config
    echo 0x17120188  > $DCC_PATH/config
    echo 0x17120190  > $DCC_PATH/config
    echo 0x17120198  > $DCC_PATH/config
    echo 0x171201a0  > $DCC_PATH/config
    echo 0x171201a8  > $DCC_PATH/config
    echo 0x171201c0  > $DCC_PATH/config
    echo 0x171201c8  > $DCC_PATH/config
    echo 0x171201d0  > $DCC_PATH/config
    echo 0x171201d8  > $DCC_PATH/config
    echo 0x171201e0  > $DCC_PATH/config
    echo 0x171201e8  > $DCC_PATH/config
    echo 0x17120200  > $DCC_PATH/config
    echo 0x17120208  > $DCC_PATH/config
    echo 0x17120210  > $DCC_PATH/config
    echo 0x17120218  > $DCC_PATH/config
    echo 0x17120220  > $DCC_PATH/config
    echo 0x17120228  > $DCC_PATH/config
    echo 0x17120240  > $DCC_PATH/config
    echo 0x17120248  > $DCC_PATH/config
    echo 0x17120250  > $DCC_PATH/config
    echo 0x17120258  > $DCC_PATH/config
    echo 0x17120260  > $DCC_PATH/config
    echo 0x17120268  > $DCC_PATH/config
    echo 0x17120280  > $DCC_PATH/config
    echo 0x17120288  > $DCC_PATH/config
    echo 0x17120290  > $DCC_PATH/config
    echo 0x17120298  > $DCC_PATH/config
    echo 0x171202a0  > $DCC_PATH/config
    echo 0x171202a8  > $DCC_PATH/config
    echo 0x171202c0  > $DCC_PATH/config
    echo 0x171202c8  > $DCC_PATH/config
    echo 0x171202d0  > $DCC_PATH/config
    echo 0x171202d8  > $DCC_PATH/config
    echo 0x171202e0  > $DCC_PATH/config
    echo 0x171202e8  > $DCC_PATH/config
    echo 0x17120300  > $DCC_PATH/config
    echo 0x17120308  > $DCC_PATH/config
    echo 0x17120310  > $DCC_PATH/config
    echo 0x17120318  > $DCC_PATH/config
    echo 0x17120320  > $DCC_PATH/config
    echo 0x17120328  > $DCC_PATH/config
    echo 0x17120340  > $DCC_PATH/config
    echo 0x17120348  > $DCC_PATH/config
    echo 0x17120350  > $DCC_PATH/config
    echo 0x17120358  > $DCC_PATH/config
    echo 0x17120360  > $DCC_PATH/config
    echo 0x17120368  > $DCC_PATH/config
    echo 0x17120380  > $DCC_PATH/config
    echo 0x17120388  > $DCC_PATH/config
    echo 0x17120390  > $DCC_PATH/config
    echo 0x17120398  > $DCC_PATH/config
    echo 0x171203a0  > $DCC_PATH/config
    echo 0x171203a8  > $DCC_PATH/config
    echo 0x171203c0  > $DCC_PATH/config
    echo 0x171203c8  > $DCC_PATH/config
    echo 0x171203d0  > $DCC_PATH/config
    echo 0x171203d8  > $DCC_PATH/config
    echo 0x171203e0  > $DCC_PATH/config
    echo 0x171203e8  > $DCC_PATH/config
    echo 0x17120400  > $DCC_PATH/config
    echo 0x17120408  > $DCC_PATH/config
    echo 0x17120410  > $DCC_PATH/config
    echo 0x17120418  > $DCC_PATH/config
    echo 0x17120420  > $DCC_PATH/config
    echo 0x17120428  > $DCC_PATH/config
    echo 0x17120440  > $DCC_PATH/config
    echo 0x17120448  > $DCC_PATH/config
    echo 0x17120450  > $DCC_PATH/config
    echo 0x17120458  > $DCC_PATH/config
    echo 0x17120460  > $DCC_PATH/config
    echo 0x17120468  > $DCC_PATH/config
    echo 0x17120480  > $DCC_PATH/config
    echo 0x17120488  > $DCC_PATH/config
    echo 0x17120490  > $DCC_PATH/config
    echo 0x17120498  > $DCC_PATH/config
    echo 0x171204a0  > $DCC_PATH/config
    echo 0x171204a8  > $DCC_PATH/config
    echo 0x171204c0  > $DCC_PATH/config
    echo 0x171204c8  > $DCC_PATH/config
    echo 0x171204d0  > $DCC_PATH/config
    echo 0x171204d8  > $DCC_PATH/config
    echo 0x171204e0  > $DCC_PATH/config
    echo 0x171204e8  > $DCC_PATH/config
    echo 0x17120500  > $DCC_PATH/config
    echo 0x17120508  > $DCC_PATH/config
    echo 0x17120510  > $DCC_PATH/config
    echo 0x17120518  > $DCC_PATH/config
    echo 0x17120520  > $DCC_PATH/config
    echo 0x17120528  > $DCC_PATH/config
    echo 0x17120540  > $DCC_PATH/config
    echo 0x17120548  > $DCC_PATH/config
    echo 0x17120550  > $DCC_PATH/config
    echo 0x17120558  > $DCC_PATH/config
    echo 0x17120560  > $DCC_PATH/config
    echo 0x17120568  > $DCC_PATH/config
    echo 0x17120580  > $DCC_PATH/config
    echo 0x17120588  > $DCC_PATH/config
    echo 0x17120590  > $DCC_PATH/config
    echo 0x17120598  > $DCC_PATH/config
    echo 0x171205a0  > $DCC_PATH/config
    echo 0x171205a8  > $DCC_PATH/config
    echo 0x171205c0  > $DCC_PATH/config
    echo 0x171205c8  > $DCC_PATH/config
    echo 0x171205d0  > $DCC_PATH/config
    echo 0x171205d8  > $DCC_PATH/config
    echo 0x171205e0  > $DCC_PATH/config
    echo 0x171205e8  > $DCC_PATH/config
    echo 0x17120600  > $DCC_PATH/config
    echo 0x17120608  > $DCC_PATH/config
    echo 0x17120610  > $DCC_PATH/config
    echo 0x17120618  > $DCC_PATH/config
    echo 0x17120620  > $DCC_PATH/config
    echo 0x17120628  > $DCC_PATH/config
    echo 0x17120640  > $DCC_PATH/config
    echo 0x17120648  > $DCC_PATH/config
    echo 0x17120650  > $DCC_PATH/config
    echo 0x17120658  > $DCC_PATH/config
    echo 0x17120660  > $DCC_PATH/config
    echo 0x17120668  > $DCC_PATH/config
    echo 0x17120680  > $DCC_PATH/config
    echo 0x17120688  > $DCC_PATH/config
    echo 0x17120690  > $DCC_PATH/config
    echo 0x17120698  > $DCC_PATH/config
    echo 0x171206a0  > $DCC_PATH/config
    echo 0x171206a8  > $DCC_PATH/config
    echo 0x171206c0  > $DCC_PATH/config
    echo 0x171206c8  > $DCC_PATH/config
    echo 0x171206d0  > $DCC_PATH/config
    echo 0x171206d8  > $DCC_PATH/config
    echo 0x171206e0  > $DCC_PATH/config
    echo 0x171206e8  > $DCC_PATH/config
    echo 0x1712e000  > $DCC_PATH/config
}

config_dcc_lpm_pcu()
{
    #PCU -DCC for LPM path
    #  Read only registers
    echo 0x17800010 1 > $DCC_PATH/config
    echo 0x17800024 1 > $DCC_PATH/config
    echo 0x17800038 1 > $DCC_PATH/config
    echo 0x1780003C 1 > $DCC_PATH/config
    echo 0x17800040 1 > $DCC_PATH/config
    echo 0x17800044 1 > $DCC_PATH/config
    echo 0x17800048 1 > $DCC_PATH/config
    echo 0x1780004C 1 > $DCC_PATH/config
    echo 0x17800058 1 > $DCC_PATH/config
    echo 0x1780005C 1 > $DCC_PATH/config
    echo 0x17800060 1 > $DCC_PATH/config
    echo 0x17800064 1 > $DCC_PATH/config
    echo 0x1780006C 1 > $DCC_PATH/config
    echo 0x178000F0 1 > $DCC_PATH/config
    echo 0x178000F4 1 > $DCC_PATH/config

    echo 0x17810010 1 > $DCC_PATH/config
    echo 0x17810024 1 > $DCC_PATH/config
    echo 0x17810038 1 > $DCC_PATH/config
    echo 0x1781003C 1 > $DCC_PATH/config
    echo 0x17810040 1 > $DCC_PATH/config
    echo 0x17810044 1 > $DCC_PATH/config
    echo 0x17810048 1 > $DCC_PATH/config
    echo 0x1781004C 1 > $DCC_PATH/config
    echo 0x17810058 1 > $DCC_PATH/config
    echo 0x1781005C 1 > $DCC_PATH/config
    echo 0x17810060 1 > $DCC_PATH/config
    echo 0x17810064 1 > $DCC_PATH/config
    echo 0x1781006C 1 > $DCC_PATH/config
    echo 0x178100F0 1 > $DCC_PATH/config
    echo 0x178100F4 1 > $DCC_PATH/config

    echo 0x17820010 1 > $DCC_PATH/config
    echo 0x17820024 1 > $DCC_PATH/config
    echo 0x17820038 1 > $DCC_PATH/config
    echo 0x1782003C 1 > $DCC_PATH/config
    echo 0x17820040 1 > $DCC_PATH/config
    echo 0x17820044 1 > $DCC_PATH/config
    echo 0x17820048 1 > $DCC_PATH/config
    echo 0x1782004C 1 > $DCC_PATH/config
    echo 0x17820058 1 > $DCC_PATH/config
    echo 0x1782005C 1 > $DCC_PATH/config
    echo 0x17820060 1 > $DCC_PATH/config
    echo 0x17820064 1 > $DCC_PATH/config
    echo 0x178200F0 1 > $DCC_PATH/config
    echo 0x178200F4 1 > $DCC_PATH/config

    echo 0x17830010 1 > $DCC_PATH/config
    echo 0x17830024 1 > $DCC_PATH/config
    echo 0x17830038 1 > $DCC_PATH/config
    echo 0x1783003C 1 > $DCC_PATH/config
    echo 0x17830040 1 > $DCC_PATH/config
    echo 0x17830044 1 > $DCC_PATH/config
    echo 0x17830048 1 > $DCC_PATH/config
    echo 0x1783004C 1 > $DCC_PATH/config
    echo 0x17830058 1 > $DCC_PATH/config
    echo 0x1783005C 1 > $DCC_PATH/config
    echo 0x17830060 1 > $DCC_PATH/config
    echo 0x17830064 1 > $DCC_PATH/config
    echo 0x178300F0 1 > $DCC_PATH/config
    echo 0x178300F4 1 > $DCC_PATH/config

    echo 0x17840010 1 > $DCC_PATH/config
    echo 0x17840024 1 > $DCC_PATH/config
    echo 0x17840038 1 > $DCC_PATH/config
    echo 0x1784003C 1 > $DCC_PATH/config
    echo 0x17840040 1 > $DCC_PATH/config
    echo 0x17840044 1 > $DCC_PATH/config
    echo 0x17840048 1 > $DCC_PATH/config
    echo 0x1784004C 1 > $DCC_PATH/config
    echo 0x17840058 1 > $DCC_PATH/config
    echo 0x1784005C 1 > $DCC_PATH/config
    echo 0x17840060 1 > $DCC_PATH/config
    echo 0x17840064 1 > $DCC_PATH/config
    echo 0x178400F0 1 > $DCC_PATH/config
    echo 0x178400F4 1 > $DCC_PATH/config

    echo 0x17850010 1 > $DCC_PATH/config
    echo 0x17850024 1 > $DCC_PATH/config
    echo 0x17850038 1 > $DCC_PATH/config
    echo 0x1785003C 1 > $DCC_PATH/config
    echo 0x17850040 1 > $DCC_PATH/config
    echo 0x17850044 1 > $DCC_PATH/config
    echo 0x17850048 1 > $DCC_PATH/config
    echo 0x1785004C 1 > $DCC_PATH/config
    echo 0x17850058 1 > $DCC_PATH/config
    echo 0x1785005C 1 > $DCC_PATH/config
    echo 0x17850060 1 > $DCC_PATH/config
    echo 0x17850064 1 > $DCC_PATH/config
    echo 0x178500F0 1 > $DCC_PATH/config
    echo 0x178500F4 1 > $DCC_PATH/config

    echo 0x17860010 1 > $DCC_PATH/config
    echo 0x17860024 1 > $DCC_PATH/config
    echo 0x17860038 1 > $DCC_PATH/config
    echo 0x1786003C 1 > $DCC_PATH/config
    echo 0x17860040 1 > $DCC_PATH/config
    echo 0x17860044 1 > $DCC_PATH/config
    echo 0x17860048 1 > $DCC_PATH/config
    echo 0x1786004C 1 > $DCC_PATH/config
    echo 0x17860058 1 > $DCC_PATH/config
    echo 0x1786005C 1 > $DCC_PATH/config
    echo 0x17860060 1 > $DCC_PATH/config
    echo 0x17860064 1 > $DCC_PATH/config
    echo 0x178600F0 1 > $DCC_PATH/config
    echo 0x178600F4 1 > $DCC_PATH/config

    echo 0x17870010 1 > $DCC_PATH/config
    echo 0x17870024 1 > $DCC_PATH/config
    echo 0x17870038 1 > $DCC_PATH/config
    echo 0x1787003C 1 > $DCC_PATH/config
    echo 0x17870040 1 > $DCC_PATH/config
    echo 0x17870044 1 > $DCC_PATH/config
    echo 0x17870048 1 > $DCC_PATH/config
    echo 0x1787004C 1 > $DCC_PATH/config
    echo 0x17870058 1 > $DCC_PATH/config
    echo 0x1787005C 1 > $DCC_PATH/config
    echo 0x17870060 1 > $DCC_PATH/config
    echo 0x17870064 1 > $DCC_PATH/config
    echo 0x178700F0 1 > $DCC_PATH/config
    echo 0x178700F4 1 > $DCC_PATH/config

    echo 0x178A0010 1 > $DCC_PATH/config
    echo 0x178A0024 1 > $DCC_PATH/config
    echo 0x178A0038 1 > $DCC_PATH/config
    echo 0x178A003C 1 > $DCC_PATH/config
    echo 0x178A0040 1 > $DCC_PATH/config
    echo 0x178A0044 1 > $DCC_PATH/config
    echo 0x178A0048 1 > $DCC_PATH/config
    echo 0x178A004C 1 > $DCC_PATH/config
    echo 0x178A006C 1 > $DCC_PATH/config
    echo 0x178A0070 1 > $DCC_PATH/config
    echo 0x178A0074 1 > $DCC_PATH/config
    echo 0x178A0078 1 > $DCC_PATH/config
    echo 0x178A007C 1 > $DCC_PATH/config
    echo 0x178A0084 1 > $DCC_PATH/config
    echo 0x178A00F4 1 > $DCC_PATH/config
    echo 0x178A00F8 1 > $DCC_PATH/config
    echo 0x178A00FC 1 > $DCC_PATH/config
    echo 0x178A0100 1 > $DCC_PATH/config
    echo 0x178A0104 1 > $DCC_PATH/config
    echo 0x178A0118 1 > $DCC_PATH/config
    echo 0x178A011C 1 > $DCC_PATH/config
    echo 0x178A0120 1 > $DCC_PATH/config
    echo 0x178A0124 1 > $DCC_PATH/config
    echo 0x178A0128 1 > $DCC_PATH/config
    echo 0x178A012C 1 > $DCC_PATH/config
    echo 0x178A0130 1 > $DCC_PATH/config
    echo 0x178A0134 1 > $DCC_PATH/config
    echo 0x178A0138 1 > $DCC_PATH/config
    echo 0x178A0158 1 > $DCC_PATH/config
    echo 0x178A015C 1 > $DCC_PATH/config
    echo 0x178A0160 1 > $DCC_PATH/config
    echo 0x178A0164 1 > $DCC_PATH/config
    echo 0x178A0168 1 > $DCC_PATH/config
    echo 0x178A0170 1 > $DCC_PATH/config
    echo 0x178A0174 1 > $DCC_PATH/config
    echo 0x178A0188 1 > $DCC_PATH/config
    echo 0x178A018C 1 > $DCC_PATH/config
    echo 0x178A0190 1 > $DCC_PATH/config
    echo 0x178A0194 1 > $DCC_PATH/config
    echo 0x178A0198 1 > $DCC_PATH/config
    echo 0x178A01AC 1 > $DCC_PATH/config
    echo 0x178A01B0 1 > $DCC_PATH/config
    echo 0x178A01B4 1 > $DCC_PATH/config
    echo 0x178A01B8 1 > $DCC_PATH/config
    echo 0x178A01BC 1 > $DCC_PATH/config
    echo 0x178A01C0 1 > $DCC_PATH/config
    echo 0x178A01C8 1 > $DCC_PATH/config

    echo 0x17880010 1 > $DCC_PATH/config
    echo 0x17880024 1 > $DCC_PATH/config
    echo 0x17880038 1 > $DCC_PATH/config
    echo 0x1788003C 1 > $DCC_PATH/config
    echo 0x17880040 1 > $DCC_PATH/config
    echo 0x17880044 1 > $DCC_PATH/config
    echo 0x17880048 1 > $DCC_PATH/config
    echo 0x1788004C 1 > $DCC_PATH/config

    echo 0x17890010 1 > $DCC_PATH/config
    echo 0x17890024 1 > $DCC_PATH/config
    echo 0x17890038 1 > $DCC_PATH/config
    echo 0x1789003C 1 > $DCC_PATH/config
    echo 0x17890040 1 > $DCC_PATH/config
    echo 0x17890044 1 > $DCC_PATH/config
    echo 0x17890048 1 > $DCC_PATH/config
    echo 0x1789004C 1 > $DCC_PATH/config

    # echo 0x18598020 1 > $DCC_PATH/config

    # echo 0x1859001C 1 > $DCC_PATH/config
    # echo 0x18590020 1 > $DCC_PATH/config
    # echo 0x18590064 1 > $DCC_PATH/config
    # echo 0x18590068 1 > $DCC_PATH/config
    # echo 0x1859006C 1 > $DCC_PATH/config
    # echo 0x18590070 1 > $DCC_PATH/config
    # echo 0x18590074 1 > $DCC_PATH/config
    # echo 0x18590078 1 > $DCC_PATH/config
    # echo 0x1859008C 1 > $DCC_PATH/config
    # echo 0x185900DC 1 > $DCC_PATH/config
    # echo 0x185900E8 1 > $DCC_PATH/config
    # echo 0x185900EC 1 > $DCC_PATH/config
    # echo 0x185900F0 1 > $DCC_PATH/config
    # echo 0x18590300 1 > $DCC_PATH/config
    # echo 0x1859030C 1 > $DCC_PATH/config
    # echo 0x18590320 1 > $DCC_PATH/config
    # echo 0x1859034C 1 > $DCC_PATH/config
    # echo 0x185903BC 1 > $DCC_PATH/config
    # echo 0x185903C0 1 > $DCC_PATH/config

    # echo 0x1859101C 1 > $DCC_PATH/config
    # echo 0x18591020 1 > $DCC_PATH/config
    # echo 0x18591064 1 > $DCC_PATH/config
    # echo 0x18591068 1 > $DCC_PATH/config
    # echo 0x1859106C 1 > $DCC_PATH/config
    # echo 0x18591070 1 > $DCC_PATH/config
    # echo 0x18591074 1 > $DCC_PATH/config
    # echo 0x18591078 1 > $DCC_PATH/config
    # echo 0x1859108C 1 > $DCC_PATH/config
    # echo 0x185910DC 1 > $DCC_PATH/config
    # echo 0x185910E8 1 > $DCC_PATH/config
    # echo 0x185910EC 1 > $DCC_PATH/config
    # echo 0x185910F0 1 > $DCC_PATH/config
    # echo 0x18591300 1 > $DCC_PATH/config
    # echo 0x1859130C 1 > $DCC_PATH/config
    # echo 0x18591320 1 > $DCC_PATH/config
    # echo 0x1859134C 1 > $DCC_PATH/config
    # echo 0x185913BC 1 > $DCC_PATH/config
    # echo 0x185913C0 1 > $DCC_PATH/config

    # echo 0x1859201C 1 > $DCC_PATH/config
    # echo 0x18592020 1 > $DCC_PATH/config
    # echo 0x18592064 1 > $DCC_PATH/config
    # echo 0x18592068 1 > $DCC_PATH/config
    # echo 0x1859206C 1 > $DCC_PATH/config
    # echo 0x18592070 1 > $DCC_PATH/config
    # echo 0x18592074 1 > $DCC_PATH/config
    # echo 0x18592078 1 > $DCC_PATH/config
    # echo 0x1859208C 1 > $DCC_PATH/config
    # echo 0x185920DC 1 > $DCC_PATH/config
    # echo 0x185920E8 1 > $DCC_PATH/config
    # echo 0x185920EC 1 > $DCC_PATH/config
    # echo 0x185920F0 1 > $DCC_PATH/config
    # echo 0x18592300 1 > $DCC_PATH/config
    # echo 0x1859230C 1 > $DCC_PATH/config
    # echo 0x18592320 1 > $DCC_PATH/config
    # echo 0x1859234C 1 > $DCC_PATH/config
    # echo 0x185923BC 1 > $DCC_PATH/config
    # echo 0x185923C0 1 > $DCC_PATH/config

    # echo 0x1859301C 1 > $DCC_PATH/config
    # echo 0x18593020 1 > $DCC_PATH/config
    # echo 0x18593064 1 > $DCC_PATH/config
    # echo 0x18593068 1 > $DCC_PATH/config
    # echo 0x1859306C 1 > $DCC_PATH/config
    # echo 0x18593070 1 > $DCC_PATH/config
    # echo 0x18593074 1 > $DCC_PATH/config
    # echo 0x18593078 1 > $DCC_PATH/config
    # echo 0x1859308C 1 > $DCC_PATH/config
    # echo 0x185930DC 1 > $DCC_PATH/config
    # echo 0x185930E8 1 > $DCC_PATH/config
    # echo 0x185930EC 1 > $DCC_PATH/config
    # echo 0x185930F0 1 > $DCC_PATH/config
    # echo 0x18593300 1 > $DCC_PATH/config
    # echo 0x1859330C 1 > $DCC_PATH/config
    # echo 0x18593320 1 > $DCC_PATH/config
    # echo 0x1859334C 1 > $DCC_PATH/config
    # echo 0x185933BC 1 > $DCC_PATH/config
    # echo 0x185933C0 1 > $DCC_PATH/config

    # echo 0x18300000 1 > $DCC_PATH/config
    # echo 0x1830000C 1 > $DCC_PATH/config
    # echo 0x18300018 1 > $DCC_PATH/config

    # echo 0x17C21000 1 > $DCC_PATH/config
    # echo 0x17C21004 1 > $DCC_PATH/config

    # echo 0x18393A84 1 > $DCC_PATH/config
    # echo 0x18393A88 1 > $DCC_PATH/config

    # echo 0x183A3A84 1 > $DCC_PATH/config
    # echo 0x183A3A88 1 > $DCC_PATH/config
}
config_dcc_lpm()
{
    #PPU PWPR/PWSR/DISR register
    echo 0x178A0204  > $DCC_PATH/config
    echo 0x178A0244  > $DCC_PATH/config
    echo 0x17E30000  > $DCC_PATH/config
    echo 0x17E30008  > $DCC_PATH/config
    echo 0x17E30010  > $DCC_PATH/config
    echo 0x17E80000  > $DCC_PATH/config
    echo 0x17E80008  > $DCC_PATH/config
    echo 0x17E80010  > $DCC_PATH/config
    echo 0x17F80000  > $DCC_PATH/config
    echo 0x17F80008  > $DCC_PATH/config
    echo 0x17F80010  > $DCC_PATH/config
    echo 0x18080000  > $DCC_PATH/config
    echo 0x18080008  > $DCC_PATH/config
    echo 0x18080010  > $DCC_PATH/config
    echo 0x18180000  > $DCC_PATH/config
    echo 0x18180008  > $DCC_PATH/config
    echo 0x18180010  > $DCC_PATH/config
    echo 0x18280000  > $DCC_PATH/config
    echo 0x18280008  > $DCC_PATH/config
    echo 0x18280010  > $DCC_PATH/config
    echo 0x18380000  > $DCC_PATH/config
    echo 0x18380008  > $DCC_PATH/config
    echo 0x18380010  > $DCC_PATH/config
    echo 0x18480000  > $DCC_PATH/config
    echo 0x18480008  > $DCC_PATH/config
    echo 0x18480010  > $DCC_PATH/config
    echo 0x18580000  > $DCC_PATH/config
    echo 0x18580008  > $DCC_PATH/config
    echo 0x18580010  > $DCC_PATH/config
}
config_dcc_core()
{
    # core hang
    echo 0x1780005C 1 > $DCC_PATH/config
    echo 0x1781005C 1 > $DCC_PATH/config
    echo 0x1782005C 1 > $DCC_PATH/config
    echo 0x1783005C 1 > $DCC_PATH/config
    echo 0x1784005C 1 > $DCC_PATH/config
    echo 0x1785005C 1 > $DCC_PATH/config
    echo 0x1786005C 1 > $DCC_PATH/config
    echo 0x1787005C 1 > $DCC_PATH/config
    echo 0x1740003C 1 > $DCC_PATH/config

    #MIBU Debug registers
    echo 0x17600238 1 > $DCC_PATH/config
    echo 0x17600240 11 > $DCC_PATH/config
    echo 0x17600530 > $DCC_PATH/config
    echo 0x1760051C > $DCC_PATH/config
    echo 0x17600524 > $DCC_PATH/config
    echo 0x1760052C > $DCC_PATH/config
    echo 0x17600518 > $DCC_PATH/config
    echo 0x17600520 > $DCC_PATH/config
    echo 0x17600528 > $DCC_PATH/config

    #CHI (GNOC) Hang counters
    echo 0x17600404 3 > $DCC_PATH/config
    echo 0x1760041C 3 > $DCC_PATH/config
    echo 0x17600434 1 > $DCC_PATH/config
    echo 0x1760043C 1 > $DCC_PATH/config
    echo 0x17600440 1 > $DCC_PATH/config

    #SYSCO and other misc debug
    echo 0x17400438 1 > $DCC_PATH/config
    echo 0x17600044 1 > $DCC_PATH/config
    echo 0x17600500 1 > $DCC_PATH/config

    #PPUHWSTAT_STS
    echo 0x17600504 5 > $DCC_PATH/config

    #CPRh
    echo 0x17900908 1 > $DCC_PATH/config
    echo 0x17900C18 1 > $DCC_PATH/config
    echo 0x17901908 1 > $DCC_PATH/config
    echo 0x17901C18 1 > $DCC_PATH/config

    echo 0x17B90810 1 > $DCC_PATH/config
    echo 0x17B90C50 1 > $DCC_PATH/config
    echo 0x17B90814 1 > $DCC_PATH/config
    echo 0x17B90C54 1 > $DCC_PATH/config
    echo 0x17B90818 1 > $DCC_PATH/config
    echo 0x17B90C58 1 > $DCC_PATH/config
    echo 0x17B93A04 2 > $DCC_PATH/config
    echo 0x17BA0810 1 > $DCC_PATH/config
    echo 0x17BA0C50 1 > $DCC_PATH/config
    echo 0x17BA0814 1 > $DCC_PATH/config
    echo 0x17BA0C54 1 > $DCC_PATH/config
    echo 0x17BA0818 1 > $DCC_PATH/config
    echo 0x17BA0C58 1 > $DCC_PATH/config
    echo 0x17BA3A04 2 > $DCC_PATH/config

    echo 0x17B93000 80 > $DCC_PATH/config
    echo 0x17BA3000 80 > $DCC_PATH/config

    #rpmh
    echo 0x0C201244 1 > $DCC_PATH/config
    echo 0x0C202244 1 > $DCC_PATH/config
    echo 0x17B00000 1 > $DCC_PATH/config

    #L3-ACD
    echo 0x17A94030 1 > $DCC_PATH/config
    echo 0x17A9408C 1 > $DCC_PATH/config
    echo 0x17A9409C 0x78 > $DCC_PATH/config_write
    echo 0x17A9409C 0x0  > $DCC_PATH/config_write
    echo 0x17A94048 0x1  > $DCC_PATH/config_write
    echo 0x17A94090 0x0  > $DCC_PATH/config_write
    echo 0x17A94090 0x25 > $DCC_PATH/config_write
    echo 0x17A94098 1 > $DCC_PATH/config
    echo 0x17A94048 0x1D > $DCC_PATH/config_write
    echo 0x17A94090 0x0  > $DCC_PATH/config_write
    echo 0x17A94090 0x25 > $DCC_PATH/config_write
    echo 0x17A94098 1 > $DCC_PATH/config

    #SILVER-ACD
    echo 0x17A90030 1 > $DCC_PATH/config
    echo 0x17A9008C 1 > $DCC_PATH/config
    echo 0x17A9009C 0x78 > $DCC_PATH/config_write
    echo 0x17A9009C 0x0  > $DCC_PATH/config_write
    echo 0x17A90048 0x1  > $DCC_PATH/config_write
    echo 0x17A90090 0x0  > $DCC_PATH/config_write
    echo 0x17A90090 0x25 > $DCC_PATH/config_write
    echo 0x17A90098 1 > $DCC_PATH/config
    echo 0x17A90048 0x1D > $DCC_PATH/config_write
    echo 0x17A90090 0x0  > $DCC_PATH/config_write
    echo 0x17A90090 0x25 > $DCC_PATH/config_write
    echo 0x17A90098 1 > $DCC_PATH/config


    #GOLD-ACD
    echo 0x17A92030 1 > $DCC_PATH/config
    echo 0x17A9208C 1 > $DCC_PATH/config
    echo 0x17A9209C 0x78 > $DCC_PATH/config_write
    echo 0x17A9209C 0x0  > $DCC_PATH/config_write
    echo 0x17A92048 0x1  > $DCC_PATH/config_write
    echo 0x17A92090 0x0  > $DCC_PATH/config_write
    echo 0x17A92090 0x25 > $DCC_PATH/config_write
    echo 0x17A92098 1 > $DCC_PATH/config
    echo 0x17A92048 0x1D > $DCC_PATH/config_write
    echo 0x17A92090 0x0  > $DCC_PATH/config_write
    echo 0x17A92090 0x25 > $DCC_PATH/config_write
    echo 0x17A92098 1 > $DCC_PATH/config

    #GOLDPLUS-ACD
    echo 0x17A96030 1 > $DCC_PATH/config
    echo 0x17A9608C 1 > $DCC_PATH/config
    echo 0x17A9609C 0x78 > $DCC_PATH/config_write
    echo 0x17A9609C 0x0  > $DCC_PATH/config_write
    echo 0x17A96048 0x1  > $DCC_PATH/config_write
    echo 0x17A96090 0x0  > $DCC_PATH/config_write
    echo 0x17A96090 0x25 > $DCC_PATH/config_write
    echo 0x17A96098 1 > $DCC_PATH/config
    echo 0x17A96048 0x1D > $DCC_PATH/config_write
    echo 0x17A96090 0x0  > $DCC_PATH/config_write
    echo 0x17A96090 0x25 > $DCC_PATH/config_write
    echo 0x17A96098 1 > $DCC_PATH/config

    echo 0x17D98024 1 > $DCC_PATH/config
    echo 0x13822000 1 > $DCC_PATH/config

    #Security Control Core for Binning info
    echo 0x221C20A4 1 > $DCC_PATH/config

    #SoC version
    echo 0x01FC8000 1 > $DCC_PATH/config

    #WDOG BIT Config
    echo 0x17400038 1 > $DCC_PATH/config

    #Curr Freq
    echo 0x17D91020 > $DCC_PATH/config
    echo 0x17D92020 > $DCC_PATH/config
    echo 0x17D93020 > $DCC_PATH/config
    echo 0x17D90020 > $DCC_PATH/config

    #OSM Seq curr addr
    echo 0x17D9134C > $DCC_PATH/config
    echo 0x17D9234C > $DCC_PATH/config
    echo 0x17D9334C > $DCC_PATH/config
    echo 0x17D9034C > $DCC_PATH/config

    #DCVS_IN_PROGRESS
    echo 0x17D91300 > $DCC_PATH/config
    echo 0x17D92300 > $DCC_PATH/config
    echo 0x17D93300 > $DCC_PATH/config
    echo 0x17D90300 > $DCC_PATH/config
}

config_dcc_gic()
{
    echo 0x17100104 29 > $DCC_PATH/config
    echo 0x17100204 29 > $DCC_PATH/config
    echo 0x17100384 29 > $DCC_PATH/config
    echo 0x178A0250 > $DCC_PATH/config
    echo 0x178A0254 > $DCC_PATH/config
    echo 0x178A025C > $DCC_PATH/config
}

config_adsp()
{
    echo 0x32302028 1 > $DCC_PATH/config
    echo 0x320A4404 1 > $DCC_PATH/config
    echo 0x320A4408 1 > $DCC_PATH/config
    echo 0x323B0404 1 > $DCC_PATH/config
    echo 0x323B0408 1 > $DCC_PATH/config
    #echo 0xB2B1020 1 > $DCC_PATH/config
    #echo 0xB2B1024 1 > $DCC_PATH/config
}

enable_dcc_pll_status()
{
   #TODO: need to be updated

}

config_dcc_tsens()
{
    echo 0x0C222004 1 > $DCC_PATH/config
    echo 0x0C263014 1 > $DCC_PATH/config
    echo 0x0C2630E0 1 > $DCC_PATH/config
    echo 0x0C2630EC 1 > $DCC_PATH/config
    echo 0x0C2630A0 16 > $DCC_PATH/config
    echo 0x0C2630E8 1 > $DCC_PATH/config
    echo 0x0C26313C 1 > $DCC_PATH/config
    echo 0x0C223004 1 > $DCC_PATH/config
    echo 0x0C265014 1 > $DCC_PATH/config
    echo 0x0C2650E0 1 > $DCC_PATH/config
    echo 0x0C2650EC 1 > $DCC_PATH/config
    echo 0x0C2650A0 16 > $DCC_PATH/config
    echo 0x0C2650E8 1 > $DCC_PATH/config
    echo 0x0C26513C 1 > $DCC_PATH/config
}

config_smmu()
{
    echo 0x15002204 1 > $DCC_PATH/config  #APPS_SMMU_TBU_PWR_STATUS
    #SMMU_500_APPS_REG_WRAPPER_BASE=0x151CC000
    #ANOC_1

    echo 0x1A000C 1 > $DCC_PATH/config #GCC_AGGRE_NOC_TBU1_CBCR
    echo 0x1A0010 1 > $DCC_PATH/config # GCC_AGGRE_NOC_TBU1_SREGR

    #let "APPS_SMMU_DEBUG_TESTBUS_SEL_ANOC_1_SEC = $SMMU_500_APPS_REG_WRAPPER_BASE+0x4050 = 0x151D0050"
    #let "APPS_SMMU_DEBUG_TESTBUS_ANOC_1_SEC = $SMMU_500_APPS_REG_WRAPPER_BASE+0x4058 = 0x151D0058"

    echo 0x151D0050 0x40 > $DCC_PATH/config_write #APPS_SMMU_DEBUG_TESTBUS_SEL_ANOC_1_SEC
    echo 0x151D0058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_ANOC_1_SEC

    echo 0x151D0050 0x80 > $DCC_PATH/config_write #APPS_SMMU_DEBUG_TESTBUS_SEL_ANOC_1_SEC
    echo 0x151D0058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_ANOC_1_SEC

    echo 0x151D0050 0xC0 > $DCC_PATH/config_write #APPS_SMMU_DEBUG_TESTBUS_SEL_ANOC_1_SEC
    echo 0x151D0058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_ANOC_1_SEC

    echo 0x151D0050 0x87 > $DCC_PATH/config_write #APPS_SMMU_DEBUG_TESTBUS_SEL_ANOC_1_SEC
    echo 0x151D0058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_ANOC_1_SEC

    echo 0x151D0050 0xAF > $DCC_PATH/config_write #APPS_SMMU_DEBUG_TESTBUS_SEL_ANOC_1_SEC
    echo 0x151D0058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_ANOC_1_SEC

    echo 0x151D0050 0xBC > $DCC_PATH/config_write #APPS_SMMU_DEBUG_TESTBUS_SEL_ANOC_1_SEC
    echo 0x151D0058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_ANOC_1_SEC

    #ANOC_2
    #echo 0x19001c 0x1 > $DCC_PATH/config_write
    echo 0x1A0014 1 > $DCC_PATH/config #GCC_AGGRE_NOC_TBU2_CBCR
    echo 0x1A0018 1 > $DCC_PATH/config #GCC_AGGRE_NOC_TBU2_SREGR

    #let "APPS_SMMU_DEBUG_TESTBUS_SEL_ANOC_2_HLOS1_NS = $SMMU_500_APPS_REG_WRAPPER_BASE+0x9050 = 0x151D5050"
    #let "APPS_SMMU_DEBUG_TESTBUS_ANOC_2_HLOS1_NS = $SMMU_500_APPS_REG_WRAPPER_BASE+0x9058 = 0x151D5058"

    echo 0x151D5050 0x40 > $DCC_PATH/config_write
    echo 0x151D5058 1 > $DCC_PATH/config

    echo 0x151D5050 0x80 > $DCC_PATH/config_write
    echo 0x151D5058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_ANOC_2_HLOS1_NS
    #echo 0x1518905C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_ANOC_2_HLOS1_NS

    echo 0x151D5050 0xC0 > $DCC_PATH/config_write
    echo 0x151D5058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_ANOC_2_HLOS1_NS
    #echo 0x1518905C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_ANOC_2_HLOS1_NS

    echo 0x151D5050 0x87 > $DCC_PATH/config_write
    echo 0x151D5058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_ANOC_2_HLOS1_NS
    #echo 0x1518905C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_ANOC_2_HLOS1_NS

    echo 0x151D5050 0xAF > $DCC_PATH/config_write
    echo 0x151D5058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_ANOC_2_HLOS1_NS
    #echo 0x1518905C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_ANOC_2_HLOS1_NS

    echo 0x151D5050 0xBC > $DCC_PATH/config_write
    echo 0x151D5058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_ANOC_2_HLOS1_NS
    #echo 0x1518905C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_ANOC_2_HLOS1_NS

    #MNOC_SF_0
    #echo 0x109010 0x1 > $DCC_PATH/config_write
    echo 0x12C018 1 > $DCC_PATH/config #GCC_MMNOC_TBU_SF0_CBCR
    echo 0x12C01C 1 > $DCC_PATH/config #GCC_MMNOC_TBU_SF0_SREGR

    #let "APPS_SMMU_DEBUG_TESTBUS_SEL_MNOC_SF_0_HLOS1_NS = $SMMU_500_APPS_REG_WRAPPER_BASE+0x25050 = 0x151F1050"
    #let "APPS_SMMU_DEBUG_TESTBUS_MNOC_SF_0_HLOS1_NS = $SMMU_500_APPS_REG_WRAPPER_BASE+0x25058 = 0x151F1058"

    echo 0x151F1050 0x40 > $DCC_PATH/config_write #APPS_SMMU_DEBUG_TESTBUS_SEL_MNOC_SF_0_HLOS1_NS(0x151F1050)
    echo 0x151F1058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_SF_0_HLOS1_NS(0x151F1058)
    #echo 0x151A505C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_SF_0_HLOS1_NS

    echo 0x151F1050 0x80 > $DCC_PATH/config_write
    echo 0x151F1058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_SF_0_HLOS1_NS
    #echo 0x151A505C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_SF_0_HLOS1_NS
    #okay till here

    echo 0x151F1050 0xC0 > $DCC_PATH/config_write
    echo 0x151F1058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_SF_0_HLOS1_NS
    #echo 0x151A505C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_SF_0_HLOS1_NS

    echo 0x151F1050 0x87 > $DCC_PATH/config_write
    echo 0x151F1058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_SF_0_HLOS1_NS
    #echo 0x151A505C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_SF_0_HLOS1_NS

    echo 0x151F1050 0xAF > $DCC_PATH/config_write
    echo 0x151F1058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_SF_0_HLOS1_NS
    #echo 0x151A505C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_SF_0_HLOS1_NS

    echo 0x151F1050 0xBC > $DCC_PATH/config_write
    echo 0x151F1058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_SF_0_HLOS1_NS
    #echo 0x151A505C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_SF_0_HLOS1_NS



    #MNOC_SF_1
    #echo 0x109018 0x1 > $DCC_PATH/config_write
    echo 0x12C024 1 > $DCC_PATH/config #GCC_MMNOC_TBU_SF1_SREGR
    echo 0x12C020 1 > $DCC_PATH/config #GCC_MMNOC_TBU_SF1_CBCR

    #let "APPS_SMMU_DEBUG_TESTBUS_SEL_MNOC_SF_1_HLOS1_NS = $SMMU_500_APPS_REG_WRAPPER_BASE+0x29050 = 0x151F5050"
    #let "APPS_SMMU_DEBUG_TESTBUS_MNOC_SF_1_HLOS1_NS = $SMMU_500_APPS_REG_WRAPPER_BASE+0x29058 = 0x151F5058"

    echo 0x151F5050 0x40 > $DCC_PATH/config_write #APPS_SMMU_DEBUG_TESTBUS_SEL_MNOC_SF_1_HLOS1_NS(0x151F5050)
    #echo $APPS_SMMU_DEBUG_TESTBUS_SEL_MNOC_SF_1_HLOS1_NS 1 > $DCC_PATH/config #XPU violation issue while config it as read
    echo 0x151F5058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_SF_1_HLOS1_NS(0x151F5058)
    ##echo 0x151A905C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_SF_1_HLOS1_NS
    #
    echo 0x151F5050 0x80 > $DCC_PATH/config_write
    echo 0x151F5058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_SF_1_HLOS1_NS

    echo 0x151F5050 0xC0 > $DCC_PATH/config_write
    echo 0x151F5058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_SF_1_HLOS1_NS
    ##echo 0x151A905C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_SF_1_HLOS1_NS
    #
    echo 0x151F5050 0x87 > $DCC_PATH/config_write
    echo 0x151F5058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_SF_1_HLOS1_NS
    ##echo 0x151A905C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_SF_1_HLOS1_NS
    #
    echo 0x151F5050 0xAF > $DCC_PATH/config_write
    echo 0x151F5058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_SF_1_HLOS1_NS
    ##echo 0x151A905C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_SF_1_HLOS1_NS
    #
    echo 0x151F5050 0xBC > $DCC_PATH/config_write
    echo 0x151F5058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_SF_1_HLOS1_NS
    #echo 0x151A905C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_SF_1_HLOS1_NS

    ##MNOC_HF_0
    #echo 0x109020 0x1 > $DCC_PATH/config_write
    echo 0x12C02C 1 > $DCC_PATH/config #GCC_MMNOC_TBU_HF0_SREGR
    echo 0x12C028 1 > $DCC_PATH/config #GCC_MMNOC_TBU_HF0_CBCR
    #echo 0x1518C010 0x10000 > $DCC_PATH/config_write #APPS_SMMU_CLIENT_DEBUG_SSD_INDEX_HYP_HLOS_EN_mnoc_hf_0_SEC__CLIENT_DEBUG_HYP_HLOS_EN = 1

    #let "APPS_SMMU_DEBUG_TESTBUS_SEL_MNOC_HF_0_HLOS1_NS = $SMMU_500_APPS_REG_WRAPPER_BASE+0xD050 = 0x151D9050"
    #let "APPS_SMMU_DEBUG_TESTBUS_MNOC_HF_0_HLOS1_NS = $SMMU_500_APPS_REG_WRAPPER_BASE+0xD058 = 0x151D9058"

    echo 0x151D9050 0x40 > $DCC_PATH/config_write #APPS_SMMU_DEBUG_TESTBUS_SEL_MNOC_HF_0_HLOS1_NS(0x151D9050)
    echo 0x151D9058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_HF_0_HLOS1_NS(0x151D9058)
    #echo 0x1518D05C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_HF_0_HLOS1_NS

    echo 0x151D9050 0x80 > $DCC_PATH/config_write
    echo 0x151D9058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_HF_0_HLOS1_NS
    #echo 0x1518D05C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_HF_0_HLOS1_NS

    echo 0x151D9050 0xC0 > $DCC_PATH/config_write
    echo 0x151D9058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_HF_0_HLOS1_NS
    #echo 0x1518D05C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_HF_0_HLOS1_NS

    echo 0x151D9050 0x87 > $DCC_PATH/config_write
    echo 0x151D9058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_HF_0_HLOS1_NS
    #echo 0x1518D05C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_HF_0_HLOS1_NS

    echo 0x151D9050 0xAF > $DCC_PATH/config_write
    echo 0x151D9058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_HF_0_HLOS1_NS
    #echo 0x1518D05C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_HF_0_HLOS1_NS

    echo 0x151D9050 0xBC > $DCC_PATH/config_write
    echo 0x151D9058 1 > $DCC_PATH/config #0x151D9058
    #echo 0x1518D05C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_HF_0_HLOS1_NS

    #MNOC_HF_1
    #echo 0x109028 0x1 > $DCC_PATH/config_write
    echo 0x12C034 1 > $DCC_PATH/config #GCC_MMNOC_TBU_HF1_SREGR
    echo 0x12C030 1 > $DCC_PATH/config #GCC_MMNOC_TBU_HF1_CBCR
    #echo 0x1518C010 0x10000 > $DCC_PATH/config_write #APPS_SMMU_CLIENT_DEBUG_SSD_INDEX_HYP_HLOS_EN_mnoc_hf_0_SEC__CLIENT_DEBUG_HYP_HLOS_EN = 1

    #let "APPS_SMMU_DEBUG_TESTBUS_SEL_MNOC_HF_1_HLOS1_NS = $SMMU_500_APPS_REG_WRAPPER_BASE+0x11050 = 0x151DD050"
    #let "APPS_SMMU_DEBUG_TESTBUS_MNOC_HF_1_HLOS1_NS = $SMMU_500_APPS_REG_WRAPPER_BASE+0x11058 = 0x151DD058"

    echo 0x151DD050 0x40 > $DCC_PATH/config_write #APPS_SMMU_DEBUG_TESTBUS_SEL_MNOC_HF_1_HLOS1_NS(0x151DD050)
    echo 0x151DD058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_HF_1_HLOS1_NS(0x151DD058)
    #echo 0x1519105C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_HF_1_HLOS1_NS

    echo 0x151DD050 0x80 > $DCC_PATH/config_write
    echo 0x151DD058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_HF_1_HLOS1_NS
    #echo 0x1519105C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_HF_1_HLOS1_NS

    echo 0x151DD050 0xC0 > $DCC_PATH/config_write
    echo 0x151DD058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_HF_1_HLOS1_NS
    #echo 0x1519105C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_HF_1_HLOS1_NS

    echo 0x151DD050 0x87 > $DCC_PATH/config_write
    echo 0x151DD058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_HF_1_HLOS1_NS
    #echo 0x1519105C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_HF_1_HLOS1_NS

    echo 0x151DD050 0xAF > $DCC_PATH/config_write
    echo 0x151DD058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_HF_1_HLOS1_NS
    #echo 0x1519105C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_HF_1_HLOS1_NS

    echo 0x151DD050 0xBC > $DCC_PATH/config_write
    echo 0x151DD058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_HF_1_HLOS1_NS
    ##echo 0x1519105C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_HF_1_HLOS1_NS


    #COMPUTE_DSP_0
    #echo 0x145004 0x1 > $DCC_PATH/config_write
    echo 0x1A9018 1 > $DCC_PATH/config #GCC_TURING_Q6_TBU0_SREGR
    echo 0x1A9014 1 > $DCC_PATH/config #GCC_TURING_Q6_TBU0_CBCR

    #let "APPS_SMMU_DEBUG_TESTBUS_SEL_COMPUTE_DSP_0_HLOS1_NS = $SMMU_500_APPS_REG_WRAPPER_BASE+0x19050 = 0x151E5050"
    #let "APPS_SMMU_DEBUG_TESTBUS_COMPUTE_DSP_0_HLOS1_NS = $SMMU_500_APPS_REG_WRAPPER_BASE+0x19058 = 0x151E5058"

    echo 0x151E5050 0x40 > $DCC_PATH/config_write #APPS_SMMU_DEBUG_TESTBUS_SEL_COMPUTE_DSP_0_HLOS1_NS(0x151E5050)
    echo 0x151E5058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_COMPUTE_DSP_0_HLOS1_NS(0x151E5058)
    #echo 0x1519905C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_COMPUTE_DSP_0_HLOS1_NS

    echo 0x151E5050 0x80 > $DCC_PATH/config_write
    echo 0x151E5058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_COMPUTE_DSP_0_HLOS1_NS
    #echo 0x1519905C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_COMPUTE_DSP_0_HLOS1_NS

    echo 0x151E5050 0xC0 > $DCC_PATH/config_write
    echo 0x151E5058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_COMPUTE_DSP_0_HLOS1_NS
    #echo 0x1519905C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_COMPUTE_DSP_0_HLOS1_NS

    echo 0x151E5050 0x87 > $DCC_PATH/config_write
    echo 0x151E5058 1 > $DCC_PATH/config #0x151E5058
    #echo 0x1519905C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_COMPUTE_DSP_0_HLOS1_NS

    echo 0x151E5050 0xAF > $DCC_PATH/config_write
    echo 0x151E5058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_COMPUTE_DSP_0_HLOS1_NS
    #echo 0x1519905C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_COMPUTE_DSP_0_HLOS1_NS

    echo 0x151E5050 0xBC > $DCC_PATH/config_write
    echo 0x151E5058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_COMPUTE_DSP_0_HLOS1_NS
    #echo 0x1519905C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_COMPUTE_DSP_0_HLOS1_NS

    ##COMPUTE_DSP_1
    #echo 0x14500C 0x1 > $DCC_PATH/config_write
    echo 0x1A9020 1 > $DCC_PATH/config #GCC_TURING_Q6_TBU1_SREGR
    echo 0x1A901C 1 > $DCC_PATH/config #GCC_TURING_Q6_TBU1_CBCR

    #let "APPS_SMMU_DEBUG_TESTBUS_SEL_COMPUTE_DSP_1_HLOS1_NS = $SMMU_500_APPS_REG_WRAPPER_BASE+0x15050 = 0x151E1050"
    #let "APPS_SMMU_DEBUG_TESTBUS_COMPUTE_DSP_1_HLOS1_NS = $SMMU_500_APPS_REG_WRAPPER_BASE+0x15058 = 0x151E1058"

    echo 0x151E1050 0x40 > $DCC_PATH/config_write #APPS_SMMU_DEBUG_TESTBUS_SEL_COMPUTE_DSP_1_HLOS1_NS(0x151E1050)
    echo 0x151E1058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_COMPUTE_DSP_1_HLOS1_NS(0x151E1058)
    #echo 0x1519505C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_COMPUTE_DSP_1_HLOS1_NS

    echo 0x151E1050 0x80 > $DCC_PATH/config_write
    echo 0x151E1058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_COMPUTE_DSP_1_HLOS1_NS
    #echo 0x1519505C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_COMPUTE_DSP_1_HLOS1_NS

    echo 0x151E1050 0xC0 > $DCC_PATH/config_write
    echo 0x151E1058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_COMPUTE_DSP_1_HLOS1_NS
    #echo 0x1519505C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_COMPUTE_DSP_1_HLOS1_NS

    echo 0x151E1050 0x87 > $DCC_PATH/config_write
    echo 0x151E1058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_COMPUTE_DSP_1_HLOS1_NS
    #echo 0x1519505C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_COMPUTE_DSP_1_HLOS1_NS

    echo 0x151E1050 0xAF > $DCC_PATH/config_write
    echo 0x151E1058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_COMPUTE_DSP_1_HLOS1_NS
    #echo 0x1519505C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_COMPUTE_DSP_1_HLOS1_NS

    echo 0x151E1050 0xBC > $DCC_PATH/config_write
    echo 0x151E1058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_COMPUTE_DSP_1_HLOS1_NS
    #echo 0x1519505C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_COMPUTE_DSP_1_HLOS1_NS

    ##LPASS
    #echo 0x190004 0x1 > $DCC_PATH/config_write
    echo 0x1A0008 1 > $DCC_PATH/config #GCC_AGGRE_NOC_AUDIO_TBU_SREGR
    echo 0x1A0004 1 > $DCC_PATH/config #GCC_AGGRE_NOC_AUDIO_TBU_CBCR

    #let "APPS_SMMU_DEBUG_TESTBUS_SEL_LPASS_HLOS1_NS = $SMMU_500_APPS_REG_WRAPPER_BASE+0x1D050 = 0x151E9050"
    #let "APPS_SMMU_DEBUG_TESTBUS_LPASS_HLOS1_NS = $SMMU_500_APPS_REG_WRAPPER_BASE+0x1D058 = 0x151E9058"

    echo 0x151E9050 0x40 > $DCC_PATH/config_write #APPS_SMMU_DEBUG_TESTBUS_SEL_LPASS_HLOS1_NS(0x151E9050)
    echo 0x151E9058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_LPASS_HLOS1_NS(0x151E9058)
    #echo 0x1519D05C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_LPASS_HLOS1_NS

    echo 0x151E9050 0x80 > $DCC_PATH/config_write
    echo 0x151E9058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_LPASS_HLOS1_NS
    #echo 0x1519D05C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_LPASS_HLOS1_NS

    echo 0x151E9050 0xC0 > $DCC_PATH/config_write
    echo 0x151E9058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_LPASS_HLOS1_NS
    #echo 0x1519D05C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_LPASS_HLOS1_NS

    echo 0x151E9050 0x87 > $DCC_PATH/config_write
    echo 0x151E9058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_LPASS_HLOS1_NS
    #echo 0x1519D05C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_LPASS_HLOS1_NS

    echo 0x151E9050 0xAF > $DCC_PATH/config_write
    echo 0x151E9058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_LPASS_HLOS1_NS
    #echo 0x1519D05C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_LPASS_HLOS1_NS

    echo 0x151E9050 0xBC > $DCC_PATH/config_write
    echo 0x151E9058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_LPASS_HLOS1_NS
    ##echo 0x1519D05C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_LPASS_HLOS1_NS

    ##ANOC_PCIE
    #echo 0x19000C 0x1 > $DCC_PATH/config_write
    echo 0x120028 1 > $DCC_PATH/config #GCC_AGGRE_NOC_PCIE_TBU_SREGR
    echo 0x120024 1 > $DCC_PATH/config #GCC_AGGRE_NOC_PCIE_TBU_CBCR

    #let "APPS_SMMU_DEBUG_TESTBUS_SEL_ANOC_PCIE_HLOS1_NS = $SMMU_500_APPS_REG_WRAPPER_BASE+0x21050 = 0x151ED050"
    #let "APPS_SMMU_DEBUG_TESTBUS_ANOC_PCIE_HLOS1_NS = $SMMU_500_APPS_REG_WRAPPER_BASE+0x21058 = 0x151ED058"

    echo 0x151ED050 0x40 > $DCC_PATH/config_write #APPS_SMMU_DEBUG_TESTBUS_SEL_ANOC_PCIE_HLOS1_NS(0x151ED050)
    echo 0x151ED058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_ANOC_PCIE_HLOS1_NS(0x151ED058)
    #echo 0x151A105C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_ANOC_PCIE_HLOS1_NS

    echo 0x151ED050 0x80 > $DCC_PATH/config_write
    echo 0x151ED058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_ANOC_PCIE_HLOS1_NS
    #echo 0x151A105C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_ANOC_PCIE_HLOS1_NS

    echo 0x151ED050 0xC0 > $DCC_PATH/config_write
    echo 0x151ED058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_ANOC_PCIE_HLOS1_NS
    #echo 0x151A105C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_ANOC_PCIE_HLOS1_NS

    echo 0x151ED050 0x87 > $DCC_PATH/config_write
    echo 0x151ED058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_ANOC_PCIE_HLOS1_NS
    #echo 0x151A105C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_ANOC_PCIE_HLOS1_NS

    echo 0x151ED050 0xAF > $DCC_PATH/config_write
    echo 0x151ED058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_ANOC_PCIE_HLOS1_NS
    #echo 0x151A105C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_ANOC_PCIE_HLOS1_NS

    echo 0x151ED050 0xBC > $DCC_PATH/config_write
    echo 0x151ED058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_ANOC_PCIE_HLOS1_NS
    ##echo 0x151A105C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_ANOC_PCIE_HLOS1_NS

    #TCU change
    #echo 0x183008 0x1 > $DCC_PATH/config_write
    echo 0x193008 1 > $DCC_PATH/config #GCC_MMU_TCU_CBCR
    echo 0x19300C 1 > $DCC_PATH/config #GCC_MMU_TCU_SREGR
    #echo 0x15002300 0x40000000 > $DCC_PATH/config_write
    #
    echo 0x15002670 1 > $DCC_PATH/config #0x0, APPS_SMMU_MMU2QSS_AND_SAFE_WAIT_CNTR
    echo 0x15002204 1 > $DCC_PATH/config #0x3ff, APPS_SMMU_TBU_PWR_STATUS
    echo 0x150025DC 1 > $DCC_PATH/config #0x0, #APPS_SMMU_STATS_SYNC_INV_TBU_ACK
    echo 0x150075DC 1 > $DCC_PATH/config #0x0, #APPS_SMMU_STATS_SYNC_INV_TBU_ACK_NS
    echo 0x15002300 1 > $DCC_PATH/config #0x10, #APPS_SMMU_CUSTOM_CFG
    echo 0x150022FC 1 > $DCC_PATH/config #0x0, #APPS_SMMU_CUSTOM_CFG_SEC
    echo 0x15002648 1 > $DCC_PATH/config #0x0, #APPS_SMMU_SAFE_SEC_CFG

}

config_gpu()
{
    echo 0x03D02000 1 > $DCC_PATH/config
    echo 0x03D02004 1 > $DCC_PATH/config
    echo 0x03D02008 1 > $DCC_PATH/config
    echo 0x03D0200C 1 > $DCC_PATH/config
    echo 0x03D02010 1 > $DCC_PATH/config
    echo 0x03D02014 1 > $DCC_PATH/config
    echo 0x03D02018 1 > $DCC_PATH/config
    echo 0x03D0201C 1 > $DCC_PATH/config
    echo 0x03D02020 1 > $DCC_PATH/config
    echo 0x03D02040 1 > $DCC_PATH/config
    echo 0x03D02044 1 > $DCC_PATH/config
    echo 0x03D02048 1 > $DCC_PATH/config
    echo 0x03D0204C 1 > $DCC_PATH/config
    echo 0x03D02080 1 > $DCC_PATH/config
    echo 0x03D02084 1 > $DCC_PATH/config
    echo 0x03D0208C 1 > $DCC_PATH/config
    echo 0x03D02090 1 > $DCC_PATH/config
    echo 0x03D02094 1 > $DCC_PATH/config
    echo 0x03D02098 1 > $DCC_PATH/config
    echo 0x03D0209C 1 > $DCC_PATH/config
    echo 0x03D020C0 1 > $DCC_PATH/config
    echo 0x03D020C4 1 > $DCC_PATH/config
    echo 0x03D020C8 1 > $DCC_PATH/config
    echo 0x03D020CC 1 > $DCC_PATH/config
    echo 0x03D020D0 1 > $DCC_PATH/config
    echo 0x03D020FC 1 > $DCC_PATH/config
    echo 0x03D02100 1 > $DCC_PATH/config
    echo 0x03D02104 1 > $DCC_PATH/config
    echo 0x03D0210C 1 > $DCC_PATH/config
    echo 0x03D02110 1 > $DCC_PATH/config
    echo 0x03D02114 1 > $DCC_PATH/config
    echo 0x03D02118 1 > $DCC_PATH/config
    echo 0x03D0211C 1 > $DCC_PATH/config
    echo 0x03D0213C 1 > $DCC_PATH/config
    echo 0x03D02140 1 > $DCC_PATH/config
    echo 0x03D02144 1 > $DCC_PATH/config
    echo 0x03D02148 1 > $DCC_PATH/config
    echo 0x03D0214C 1 > $DCC_PATH/config
    echo 0x03D02150 1 > $DCC_PATH/config
    echo 0x03D02154 1 > $DCC_PATH/config
    echo 0x03D02158 1 > $DCC_PATH/config
    echo 0x03D0215C 1 > $DCC_PATH/config
    echo 0x03D02160 1 > $DCC_PATH/config
    echo 0x03D02164 1 > $DCC_PATH/config
    echo 0x03D02168 1 > $DCC_PATH/config
    echo 0x03D0216C 1 > $DCC_PATH/config
    echo 0x03D02170 1 > $DCC_PATH/config
    echo 0x03D02174 1 > $DCC_PATH/config
    echo 0x03D02178 1 > $DCC_PATH/config
    echo 0x03D0217C 1 > $DCC_PATH/config
    echo 0x03D02180 1 > $DCC_PATH/config
    echo 0x03D02184 1 > $DCC_PATH/config
    echo 0x03D02188 1 > $DCC_PATH/config
    echo 0x03D0218C 1 > $DCC_PATH/config
    echo 0x03D02190 1 > $DCC_PATH/config
    echo 0x03D02194 1 > $DCC_PATH/config
    echo 0x03D02198 1 > $DCC_PATH/config
    echo 0x03D0219C 1 > $DCC_PATH/config
    echo 0x03D021A0 1 > $DCC_PATH/config
    echo 0x03D021A4 1 > $DCC_PATH/config
    echo 0x03D021A8 1 > $DCC_PATH/config
    echo 0x03D021AC 1 > $DCC_PATH/config
    echo 0x03D021B0 1 > $DCC_PATH/config
    echo 0x03D021B4 1 > $DCC_PATH/config
    echo 0x03D021B8 1 > $DCC_PATH/config
    echo 0x03D021BC 1 > $DCC_PATH/config
    echo 0x03D021C0 1 > $DCC_PATH/config
    echo 0x03D021C4 1 > $DCC_PATH/config
    echo 0x03D021C8 1 > $DCC_PATH/config
    echo 0x03D021CC 1 > $DCC_PATH/config
    echo 0x03D021D0 1 > $DCC_PATH/config
    echo 0x03D021D4 1 > $DCC_PATH/config
    echo 0x03D021D8 1 > $DCC_PATH/config
    echo 0x03D021DC 1 > $DCC_PATH/config
    echo 0x03D021E0 1 > $DCC_PATH/config
    echo 0x03D021E4 1 > $DCC_PATH/config
    echo 0x03D021E8 1 > $DCC_PATH/config
    echo 0x03D021EC 1 > $DCC_PATH/config
    echo 0x03D021F0 1 > $DCC_PATH/config
    echo 0x03D021F4 1 > $DCC_PATH/config
    echo 0x03D021F8 1 > $DCC_PATH/config
    echo 0x03D021FC 1 > $DCC_PATH/config
    echo 0x03D02200 1 > $DCC_PATH/config
    echo 0x03D02204 1 > $DCC_PATH/config
    echo 0x03D02208 1 > $DCC_PATH/config
    echo 0x03D0220C 1 > $DCC_PATH/config
    echo 0x03D02210 1 > $DCC_PATH/config
    echo 0x03D02214 1 > $DCC_PATH/config
    echo 0x03D02218 1 > $DCC_PATH/config
    echo 0x03D0221C 1 > $DCC_PATH/config
    echo 0x03D02220 1 > $DCC_PATH/config
    echo 0x03D02224 1 > $DCC_PATH/config
    echo 0x03D02228 1 > $DCC_PATH/config
    echo 0x03D0222C 1 > $DCC_PATH/config
    echo 0x03D02230 1 > $DCC_PATH/config
    echo 0x03D02280 1 > $DCC_PATH/config
    echo 0x03D02284 1 > $DCC_PATH/config
    echo 0x03D02288 1 > $DCC_PATH/config
    echo 0x03D0228C 1 > $DCC_PATH/config
    echo 0x03D02290 1 > $DCC_PATH/config
    echo 0x03D02294 1 > $DCC_PATH/config
    echo 0x03D02298 1 > $DCC_PATH/config
    echo 0x03D0229C 1 > $DCC_PATH/config
    echo 0x03D022A0 1 > $DCC_PATH/config
    echo 0x03D022A4 1 > $DCC_PATH/config
    echo 0x03D022A8 1 > $DCC_PATH/config
    echo 0x03D022AC 1 > $DCC_PATH/config
    echo 0x03D02300 1 > $DCC_PATH/config
    echo 0x03D02310 1 > $DCC_PATH/config
    echo 0x03D02314 1 > $DCC_PATH/config
    echo 0x03D02318 1 > $DCC_PATH/config
    echo 0x03D02340 1 > $DCC_PATH/config
    echo 0x03D02344 1 > $DCC_PATH/config
    echo 0x03D02348 1 > $DCC_PATH/config
    echo 0x03D0234C 1 > $DCC_PATH/config
    echo 0x03D02350 1 > $DCC_PATH/config
    echo 0x03D02354 1 > $DCC_PATH/config
    echo 0x03D02358 1 > $DCC_PATH/config
    echo 0x03D0235C 1 > $DCC_PATH/config
    echo 0x03D02360 1 > $DCC_PATH/config
    echo 0x03D02364 1 > $DCC_PATH/config
    echo 0x03D02368 1 > $DCC_PATH/config
    echo 0x03D0236C 1 > $DCC_PATH/config
    echo 0x03D02370 1 > $DCC_PATH/config
    echo 0x03D02374 1 > $DCC_PATH/config
    echo 0x03D02380 1 > $DCC_PATH/config
    echo 0x03D02384 1 > $DCC_PATH/config
    echo 0x03D02388 1 > $DCC_PATH/config
    echo 0x03D0238C 1 > $DCC_PATH/config
    echo 0x03D02390 1 > $DCC_PATH/config
    echo 0x03D02394 1 > $DCC_PATH/config
    echo 0x03D02398 1 > $DCC_PATH/config
    echo 0x03D023C0 1 > $DCC_PATH/config
    echo 0x03D023C4 1 > $DCC_PATH/config
    echo 0x03D023C8 1 > $DCC_PATH/config
    echo 0x03D023CC 1 > $DCC_PATH/config
    echo 0x03D02400 1 > $DCC_PATH/config
    echo 0x03D02404 1 > $DCC_PATH/config
    echo 0x03D02408 1 > $DCC_PATH/config
    echo 0x03D0240C 1 > $DCC_PATH/config
    echo 0x03D02420 1 > $DCC_PATH/config
    echo 0x03D02424 1 > $DCC_PATH/config
    echo 0x03D02428 1 > $DCC_PATH/config
    echo 0x03D0242C 1 > $DCC_PATH/config
    echo 0x03D02430 1 > $DCC_PATH/config
    echo 0x03D02434 1 > $DCC_PATH/config
    echo 0x03D02438 1 > $DCC_PATH/config
    echo 0x03D0243C 1 > $DCC_PATH/config
    echo 0x03D02440 1 > $DCC_PATH/config
    echo 0x03D02444 1 > $DCC_PATH/config
    echo 0x03D024A0 1 > $DCC_PATH/config
    echo 0x03D024A4 1 > $DCC_PATH/config
    echo 0x03D024A8 1 > $DCC_PATH/config
    echo 0x03D024AC 1 > $DCC_PATH/config
    echo 0x03D024B0 1 > $DCC_PATH/config
    echo 0x03D024B4 1 > $DCC_PATH/config
    echo 0x03D024B8 1 > $DCC_PATH/config
    echo 0x03D024BC 1 > $DCC_PATH/config
    echo 0x03D024C0 1 > $DCC_PATH/config
    echo 0x03D024C4 1 > $DCC_PATH/config
    echo 0x03D024C8 1 > $DCC_PATH/config
    echo 0x03D024CC 1 > $DCC_PATH/config
    echo 0x03D024D0 1 > $DCC_PATH/config
    echo 0x03D024D4 1 > $DCC_PATH/config
    echo 0x03D024D8 1 > $DCC_PATH/config
    echo 0x03D024DC 1 > $DCC_PATH/config
    echo 0x03D024E0 1 > $DCC_PATH/config
    echo 0x03D024E4 1 > $DCC_PATH/config
    echo 0x03D024E8 1 > $DCC_PATH/config
    echo 0x03D024EC 1 > $DCC_PATH/config
    echo 0x03D024F0 1 > $DCC_PATH/config
    echo 0x03D024F4 1 > $DCC_PATH/config
    echo 0x03D024F8 1 > $DCC_PATH/config
    echo 0x03D02508 1 > $DCC_PATH/config
    echo 0x03D0250C 1 > $DCC_PATH/config
    echo 0x03D02510 1 > $DCC_PATH/config
    echo 0x03D02514 1 > $DCC_PATH/config
    echo 0x03D02518 1 > $DCC_PATH/config
    echo 0x03D0251C 1 > $DCC_PATH/config
    echo 0x03D02520 1 > $DCC_PATH/config
    echo 0x03D02524 1 > $DCC_PATH/config
    echo 0x03D02528 1 > $DCC_PATH/config
    echo 0x03D0252C 1 > $DCC_PATH/config
    echo 0x03D02530 1 > $DCC_PATH/config
    echo 0x03D02534 1 > $DCC_PATH/config
    echo 0x03D02600 1 > $DCC_PATH/config
    echo 0x03D02604 1 > $DCC_PATH/config
    echo 0x03D02608 1 > $DCC_PATH/config
    echo 0x03D0260C 1 > $DCC_PATH/config
    echo 0x03D02610 1 > $DCC_PATH/config
    echo 0x03D02634 1 > $DCC_PATH/config
    echo 0x03D02638 1 > $DCC_PATH/config
    echo 0x03D0263C 1 > $DCC_PATH/config
    echo 0x03D026C0 1 > $DCC_PATH/config
    echo 0x03D026C4 1 > $DCC_PATH/config
    echo 0x03D026C8 1 > $DCC_PATH/config
    echo 0x03D026CC 1 > $DCC_PATH/config
    echo 0x03D026D0 1 > $DCC_PATH/config
    echo 0x03D02708 1 > $DCC_PATH/config
    echo 0x03D0270C 1 > $DCC_PATH/config
    echo 0x03D02710 1 > $DCC_PATH/config
    echo 0x03D02714 1 > $DCC_PATH/config
    echo 0x03D02718 1 > $DCC_PATH/config
    echo 0x03D0271C 1 > $DCC_PATH/config
    echo 0x03D02720 1 > $DCC_PATH/config
    echo 0x03D02724 1 > $DCC_PATH/config
    echo 0x03D02738 1 > $DCC_PATH/config
    echo 0x03D0273C 1 > $DCC_PATH/config
    echo 0x03D02740 1 > $DCC_PATH/config
    echo 0x03D02744 1 > $DCC_PATH/config
    echo 0x03D02748 1 > $DCC_PATH/config
    echo 0x03D0274C 1 > $DCC_PATH/config
    echo 0x03D02750 1 > $DCC_PATH/config
    echo 0x03D02754 1 > $DCC_PATH/config
    echo 0x03D02758 1 > $DCC_PATH/config
    echo 0x03D0275C 1 > $DCC_PATH/config
    echo 0x03D02780 1 > $DCC_PATH/config
    echo 0x03D02784 1 > $DCC_PATH/config
    echo 0x03D02788 1 > $DCC_PATH/config
    echo 0x03D0278C 1 > $DCC_PATH/config
    echo 0x03D02790 1 > $DCC_PATH/config
    echo 0x03D02794 1 > $DCC_PATH/config
    echo 0x03D02798 1 > $DCC_PATH/config
    echo 0x03D0279C 1 > $DCC_PATH/config
    echo 0x03D02800 1 > $DCC_PATH/config
    echo 0x03D02808 1 > $DCC_PATH/config
    echo 0x03D0280C 1 > $DCC_PATH/config
    echo 0x03D02840 1 > $DCC_PATH/config
    echo 0x03D02844 1 > $DCC_PATH/config
    echo 0x03D02848 1 > $DCC_PATH/config
    echo 0x03D0284C 1 > $DCC_PATH/config
    echo 0x03D02850 1 > $DCC_PATH/config
    echo 0x03D02854 1 > $DCC_PATH/config
    echo 0x03D02858 1 > $DCC_PATH/config
    echo 0x03D0285C 1 > $DCC_PATH/config
    echo 0x03D02860 1 > $DCC_PATH/config
    echo 0x03D02864 1 > $DCC_PATH/config
    echo 0x03D02868 1 > $DCC_PATH/config
    echo 0x03D0286C 1 > $DCC_PATH/config
    echo 0x03D02870 1 > $DCC_PATH/config
    echo 0x03D02874 1 > $DCC_PATH/config
    echo 0x03D02878 1 > $DCC_PATH/config
    echo 0x03D0287C 1 > $DCC_PATH/config
    echo 0x03D02880 1 > $DCC_PATH/config
    echo 0x03D02884 1 > $DCC_PATH/config
    echo 0x03D02888 1 > $DCC_PATH/config
    echo 0x03D0288C 1 > $DCC_PATH/config
    echo 0x03D02890 1 > $DCC_PATH/config
    echo 0x03D02894 1 > $DCC_PATH/config
    echo 0x03D02898 1 > $DCC_PATH/config
    echo 0x03D0289C 1 > $DCC_PATH/config
    echo 0x03D028A0 1 > $DCC_PATH/config
    echo 0x03D028A4 1 > $DCC_PATH/config
    echo 0x03D028A8 1 > $DCC_PATH/config
    echo 0x03D028AC 1 > $DCC_PATH/config
    echo 0x03D028B0 1 > $DCC_PATH/config
    echo 0x03D028B4 1 > $DCC_PATH/config
    echo 0x03D028B8 1 > $DCC_PATH/config
    echo 0x03D028BC 1 > $DCC_PATH/config
    echo 0x03D028C0 1 > $DCC_PATH/config
    echo 0x03D028C4 1 > $DCC_PATH/config
    echo 0x03D028C8 1 > $DCC_PATH/config
    echo 0x03D028CC 1 > $DCC_PATH/config
    echo 0x03D028D0 1 > $DCC_PATH/config
    echo 0x03D028D4 1 > $DCC_PATH/config
    echo 0x03D028D8 1 > $DCC_PATH/config
    echo 0x03D028DC 1 > $DCC_PATH/config
    echo 0x03D028E0 1 > $DCC_PATH/config
    echo 0x03D028E4 1 > $DCC_PATH/config
    echo 0x03D028E8 1 > $DCC_PATH/config
    echo 0x03D028EC 1 > $DCC_PATH/config
    echo 0x03D028F0 1 > $DCC_PATH/config
    echo 0x03D028F4 1 > $DCC_PATH/config
    echo 0x03D028F8 1 > $DCC_PATH/config
    echo 0x03D028FC 1 > $DCC_PATH/config
    echo 0x03D02900 1 > $DCC_PATH/config
    echo 0x03D02904 1 > $DCC_PATH/config
    echo 0x03D02908 1 > $DCC_PATH/config
    echo 0x03D0290C 1 > $DCC_PATH/config
    echo 0x03D02910 1 > $DCC_PATH/config
    echo 0x03D02914 1 > $DCC_PATH/config
    echo 0x03D02918 1 > $DCC_PATH/config
    echo 0x03D0291C 1 > $DCC_PATH/config
    echo 0x03D02920 1 > $DCC_PATH/config
    echo 0x03D02924 1 > $DCC_PATH/config
    echo 0x03D02928 1 > $DCC_PATH/config
    echo 0x03D0292C 1 > $DCC_PATH/config
    echo 0x03D02930 1 > $DCC_PATH/config
    echo 0x03D02934 1 > $DCC_PATH/config
    echo 0x03D02938 1 > $DCC_PATH/config
    echo 0x03D0293C 1 > $DCC_PATH/config
    echo 0x03D02984 1 > $DCC_PATH/config
    echo 0x03D02988 1 > $DCC_PATH/config
    echo 0x03D0298C 1 > $DCC_PATH/config
    echo 0x03D02990 1 > $DCC_PATH/config
    echo 0x03D02994 1 > $DCC_PATH/config
    echo 0x03D02998 1 > $DCC_PATH/config
    echo 0x03D0299C 1 > $DCC_PATH/config
    echo 0x03D029A0 1 > $DCC_PATH/config
    echo 0x03D029A4 1 > $DCC_PATH/config
    echo 0x03D029A8 1 > $DCC_PATH/config
    echo 0x03D029AC 1 > $DCC_PATH/config
    echo 0x03D029B0 1 > $DCC_PATH/config
    echo 0x03D029B4 1 > $DCC_PATH/config
    echo 0x03D029B8 1 > $DCC_PATH/config
    echo 0x03D029BC 1 > $DCC_PATH/config
    echo 0x03D029C0 1 > $DCC_PATH/config
    echo 0x03D029C4 1 > $DCC_PATH/config
    echo 0x03D029C8 1 > $DCC_PATH/config
    echo 0x03D029CC 1 > $DCC_PATH/config
    echo 0x03D029D0 1 > $DCC_PATH/config
    echo 0x03D029D4 1 > $DCC_PATH/config
    echo 0x03D029D8 1 > $DCC_PATH/config
    echo 0x03D029DC 1 > $DCC_PATH/config
    echo 0x03D029E0 1 > $DCC_PATH/config
    echo 0x03D029E4 1 > $DCC_PATH/config
    echo 0x03D029E8 1 > $DCC_PATH/config
    echo 0x03D029EC 1 > $DCC_PATH/config
    echo 0x03D029F0 1 > $DCC_PATH/config
    echo 0x03D029F4 1 > $DCC_PATH/config
    echo 0x03D029F8 1 > $DCC_PATH/config
    echo 0x03D029FC 1 > $DCC_PATH/config
    echo 0x03D02A00 1 > $DCC_PATH/config
    echo 0x03D02A04 1 > $DCC_PATH/config
    echo 0x03D02A08 1 > $DCC_PATH/config
    echo 0x03D02A0C 1 > $DCC_PATH/config
    echo 0x03D02A10 1 > $DCC_PATH/config
    echo 0x03D02A14 1 > $DCC_PATH/config
    echo 0x03D02A18 1 > $DCC_PATH/config
    echo 0x03D02A1C 1 > $DCC_PATH/config
    echo 0x03D02A20 1 > $DCC_PATH/config
    echo 0x03D02A24 1 > $DCC_PATH/config
    echo 0x03D02A28 1 > $DCC_PATH/config
    echo 0x03D02A2C 1 > $DCC_PATH/config
    echo 0x03D02A30 1 > $DCC_PATH/config
    echo 0x03D02A34 1 > $DCC_PATH/config
    echo 0x03D02A38 1 > $DCC_PATH/config
    echo 0x03D02A3C 1 > $DCC_PATH/config
    echo 0x03D02A40 1 > $DCC_PATH/config
    echo 0x03D02A44 1 > $DCC_PATH/config
    echo 0x03D02A48 1 > $DCC_PATH/config
    echo 0x03D02A4C 1 > $DCC_PATH/config
    echo 0x03D02A50 1 > $DCC_PATH/config
    echo 0x03D02A54 1 > $DCC_PATH/config
    echo 0x03D02A58 1 > $DCC_PATH/config
    echo 0x03D02A5C 1 > $DCC_PATH/config
    echo 0x03D02A60 1 > $DCC_PATH/config
    echo 0x03D02A64 1 > $DCC_PATH/config
    echo 0x03D02A68 1 > $DCC_PATH/config
    echo 0x03D02A6C 1 > $DCC_PATH/config
    echo 0x03D02A70 1 > $DCC_PATH/config
    echo 0x03D02A74 1 > $DCC_PATH/config
    echo 0x03D02A78 1 > $DCC_PATH/config
    echo 0x03D02A7C 1 > $DCC_PATH/config
    echo 0x03D02B40 1 > $DCC_PATH/config
    echo 0x03D02B44 1 > $DCC_PATH/config
    echo 0x03D02B48 1 > $DCC_PATH/config
    echo 0x03D02B4C 1 > $DCC_PATH/config
    echo 0x03D02B50 1 > $DCC_PATH/config
    echo 0x03D02B54 1 > $DCC_PATH/config
    echo 0x03D02B58 1 > $DCC_PATH/config
    echo 0x03D02B5C 1 > $DCC_PATH/config
    echo 0x03D02B60 1 > $DCC_PATH/config
    echo 0x03D02B64 1 > $DCC_PATH/config
    echo 0x03D02B68 1 > $DCC_PATH/config
    echo 0x03D02B6C 1 > $DCC_PATH/config
    echo 0x03D02C00 1 > $DCC_PATH/config
    echo 0x03D02C04 1 > $DCC_PATH/config
    echo 0x03D02C08 1 > $DCC_PATH/config
    echo 0x03D02C0C 1 > $DCC_PATH/config
    echo 0x03D02C10 1 > $DCC_PATH/config
    echo 0x03D02C14 1 > $DCC_PATH/config
    echo 0x03D02C18 1 > $DCC_PATH/config
    echo 0x03D02C1C 1 > $DCC_PATH/config
    echo 0x03D02C20 1 > $DCC_PATH/config
    echo 0x03D02C24 1 > $DCC_PATH/config
    echo 0x03D02C28 1 > $DCC_PATH/config
    echo 0x03D02C2C 1 > $DCC_PATH/config
    echo 0x03D02C30 1 > $DCC_PATH/config
    echo 0x03D02C34 1 > $DCC_PATH/config
    echo 0x03D02C38 1 > $DCC_PATH/config
    echo 0x03D02C3C 1 > $DCC_PATH/config
    echo 0x03D02C40 1 > $DCC_PATH/config
    echo 0x03D02C44 1 > $DCC_PATH/config
    echo 0x03D02C48 1 > $DCC_PATH/config
    echo 0x03D02C4C 1 > $DCC_PATH/config
    echo 0x03D02C50 1 > $DCC_PATH/config
    echo 0x03D02C54 1 > $DCC_PATH/config
    echo 0x03D02C58 1 > $DCC_PATH/config
    echo 0x03D02C5C 1 > $DCC_PATH/config
    echo 0x03D02C60 1 > $DCC_PATH/config
    echo 0x03D02C64 1 > $DCC_PATH/config
    echo 0x03D02C68 1 > $DCC_PATH/config
    echo 0x03D02C6C 1 > $DCC_PATH/config
    echo 0x03D02C70 1 > $DCC_PATH/config
    echo 0x03D02C74 1 > $DCC_PATH/config
    echo 0x03D02C78 1 > $DCC_PATH/config
    echo 0x03D02C7C 1 > $DCC_PATH/config
    echo 0x03D02C80 1 > $DCC_PATH/config
    echo 0x03D02C84 1 > $DCC_PATH/config
    echo 0x03D02C88 1 > $DCC_PATH/config
    echo 0x03D02C8C 1 > $DCC_PATH/config
    echo 0x03D02C90 1 > $DCC_PATH/config
    echo 0x03D02C94 1 > $DCC_PATH/config
    echo 0x03D02C98 1 > $DCC_PATH/config
    echo 0x03D02C9C 1 > $DCC_PATH/config
    echo 0x03D02CA0 1 > $DCC_PATH/config
    echo 0x03D02CA4 1 > $DCC_PATH/config
    echo 0x03D02CA8 1 > $DCC_PATH/config
    echo 0x03D02CAC 1 > $DCC_PATH/config
    echo 0x03D02CB0 1 > $DCC_PATH/config
    echo 0x03D02CB4 1 > $DCC_PATH/config
    echo 0x03D02CB8 1 > $DCC_PATH/config
    echo 0x03D02CBC 1 > $DCC_PATH/config
    echo 0x03D02CC0 1 > $DCC_PATH/config
    echo 0x03D02CC4 1 > $DCC_PATH/config
    echo 0x03D02CD4 1 > $DCC_PATH/config
    echo 0x03D02CD8 1 > $DCC_PATH/config
    echo 0x03D02CDC 1 > $DCC_PATH/config
    echo 0x03D02CE0 1 > $DCC_PATH/config
    echo 0x03D02CE4 1 > $DCC_PATH/config
    echo 0x03D02CE8 1 > $DCC_PATH/config
    echo 0x03D02CEC 1 > $DCC_PATH/config
    echo 0x03D02CF0 1 > $DCC_PATH/config
    echo 0x03D02D00 1 > $DCC_PATH/config
    echo 0x03D3C000 1 > $DCC_PATH/config
    echo 0x03D3C004 1 > $DCC_PATH/config
    echo 0x03D3C008 1 > $DCC_PATH/config
    echo 0x03D00000 1 > $DCC_PATH/config
    echo 0x03D00008 1 > $DCC_PATH/config
    echo 0x03D00044 1 > $DCC_PATH/config
    echo 0x03D00048 1 > $DCC_PATH/config
    echo 0x03D00058 1 > $DCC_PATH/config
    echo 0x03D0005C 1 > $DCC_PATH/config
    echo 0x03D00060 1 > $DCC_PATH/config
    echo 0x03D00064 1 > $DCC_PATH/config
    echo 0x03D00068 1 > $DCC_PATH/config
    echo 0x03D0006C 1 > $DCC_PATH/config
    echo 0x03D0007C 1 > $DCC_PATH/config
    echo 0x03D00080 1 > $DCC_PATH/config
    echo 0x03D00084 1 > $DCC_PATH/config
    echo 0x03D00088 1 > $DCC_PATH/config
    echo 0x03D0008C 1 > $DCC_PATH/config
    echo 0x03D00090 1 > $DCC_PATH/config
    echo 0x03D00094 1 > $DCC_PATH/config
    echo 0x03D00098 1 > $DCC_PATH/config
    echo 0x03D0009C 1 > $DCC_PATH/config
    echo 0x03D000A0 1 > $DCC_PATH/config
    echo 0x03D000A4 1 > $DCC_PATH/config
    echo 0x03D000A8 1 > $DCC_PATH/config
    echo 0x03D000AC 1 > $DCC_PATH/config
    echo 0x03D000B0 1 > $DCC_PATH/config
    echo 0x03D000B4 1 > $DCC_PATH/config
    echo 0x03D000B8 1 > $DCC_PATH/config
    echo 0x03D000BC 1 > $DCC_PATH/config
    echo 0x03D000C0 1 > $DCC_PATH/config
    echo 0x03D000C4 1 > $DCC_PATH/config
    echo 0x03D000C8 1 > $DCC_PATH/config
    echo 0x03D000D8 1 > $DCC_PATH/config
    echo 0x03D000DC 1 > $DCC_PATH/config
    echo 0x03D000E0 1 > $DCC_PATH/config
    echo 0x03D000E4 1 > $DCC_PATH/config
    echo 0x03D000E8 1 > $DCC_PATH/config
    echo 0x03D000EC 1 > $DCC_PATH/config
    echo 0x03D000F0 1 > $DCC_PATH/config
    echo 0x03D00108 1 > $DCC_PATH/config
    echo 0x03D0010C 1 > $DCC_PATH/config
    echo 0x03D00110 1 > $DCC_PATH/config
    echo 0x03D0011C 1 > $DCC_PATH/config
    echo 0x03D00120 1 > $DCC_PATH/config
    echo 0x03D00124 1 > $DCC_PATH/config
    echo 0x03D00128 1 > $DCC_PATH/config
    echo 0x03D00130 1 > $DCC_PATH/config
    echo 0x03D00140 1 > $DCC_PATH/config
    echo 0x03D00158 1 > $DCC_PATH/config
    echo 0x03D001CC 1 > $DCC_PATH/config
    echo 0x03D001D0 1 > $DCC_PATH/config
    echo 0x03D001D4 1 > $DCC_PATH/config
    echo 0x03D001D8 1 > $DCC_PATH/config
    echo 0x03D001DC 1 > $DCC_PATH/config
    echo 0x03D001E0 1 > $DCC_PATH/config
    echo 0x03D001E4 1 > $DCC_PATH/config
    echo 0x03D001E8 1 > $DCC_PATH/config
    echo 0x03D001EC 1 > $DCC_PATH/config
    echo 0x03D001F0 1 > $DCC_PATH/config
    echo 0x03D001F4 1 > $DCC_PATH/config
    echo 0x03D002B4 1 > $DCC_PATH/config
    echo 0x03D002B8 1 > $DCC_PATH/config
    echo 0x03D002C0 1 > $DCC_PATH/config
    echo 0x03D002D0 1 > $DCC_PATH/config
    echo 0x03D002E0 1 > $DCC_PATH/config
    echo 0x03D002F0 1 > $DCC_PATH/config
    echo 0x03D00300 1 > $DCC_PATH/config
    echo 0x03D00310 1 > $DCC_PATH/config
    echo 0x03D00320 1 > $DCC_PATH/config
    echo 0x03D00330 1 > $DCC_PATH/config
    echo 0x03D00340 1 > $DCC_PATH/config
    echo 0x03D00350 1 > $DCC_PATH/config
    echo 0x03D00360 1 > $DCC_PATH/config
    echo 0x03D00370 1 > $DCC_PATH/config
    echo 0x03D00380 1 > $DCC_PATH/config
    echo 0x03D00390 1 > $DCC_PATH/config
    echo 0x03D003A0 1 > $DCC_PATH/config
    echo 0x03D003B0 1 > $DCC_PATH/config
    echo 0x03D003C0 1 > $DCC_PATH/config
    echo 0x03D003D0 1 > $DCC_PATH/config
    echo 0x03D003E0 1 > $DCC_PATH/config
    echo 0x03D00400 1 > $DCC_PATH/config
    echo 0x03D00410 1 > $DCC_PATH/config
    echo 0x03D00414 1 > $DCC_PATH/config
    echo 0x03D00418 1 > $DCC_PATH/config
    echo 0x03D0041C 1 > $DCC_PATH/config
    echo 0x03D00420 1 > $DCC_PATH/config
    echo 0x03D00424 1 > $DCC_PATH/config
    echo 0x03D00428 1 > $DCC_PATH/config
    echo 0x03D0042C 1 > $DCC_PATH/config
    echo 0x03D00430 1 > $DCC_PATH/config
    echo 0x03D0043C 1 > $DCC_PATH/config
    echo 0x03D00440 1 > $DCC_PATH/config
    echo 0x03D00444 1 > $DCC_PATH/config
    echo 0x03D00448 1 > $DCC_PATH/config
    echo 0x03D0044C 1 > $DCC_PATH/config
    echo 0x03D00450 1 > $DCC_PATH/config
    echo 0x03D00454 1 > $DCC_PATH/config
    echo 0x03D00458 1 > $DCC_PATH/config
    echo 0x03D0045C 1 > $DCC_PATH/config
    echo 0x03D00460 1 > $DCC_PATH/config
    echo 0x03D00464 1 > $DCC_PATH/config
    echo 0x03D00468 1 > $DCC_PATH/config
    echo 0x03D0046C 1 > $DCC_PATH/config
    echo 0x03D00470 1 > $DCC_PATH/config
    echo 0x03D00474 1 > $DCC_PATH/config
    echo 0x03D004BC 1 > $DCC_PATH/config
    echo 0x03D00800 1 > $DCC_PATH/config
    echo 0x03D00804 1 > $DCC_PATH/config
    echo 0x03D00808 1 > $DCC_PATH/config
    echo 0x03D0080C 1 > $DCC_PATH/config
    echo 0x03D00810 1 > $DCC_PATH/config
    echo 0x03D00814 1 > $DCC_PATH/config
    echo 0x03D00818 1 > $DCC_PATH/config
    echo 0x03D0081C 1 > $DCC_PATH/config
    echo 0x03D00820 1 > $DCC_PATH/config
    echo 0x03D00824 1 > $DCC_PATH/config
    echo 0x03D00828 1 > $DCC_PATH/config
    echo 0x03D0082C 1 > $DCC_PATH/config
    echo 0x03D00830 1 > $DCC_PATH/config
    echo 0x03D00834 1 > $DCC_PATH/config
    echo 0x03D00840 1 > $DCC_PATH/config
    echo 0x03D00844 1 > $DCC_PATH/config
    echo 0x03D00848 1 > $DCC_PATH/config
    echo 0x03D0084C 1 > $DCC_PATH/config
    echo 0x03D00854 1 > $DCC_PATH/config
    echo 0x03D00858 1 > $DCC_PATH/config
    echo 0x03D0085C 1 > $DCC_PATH/config
    echo 0x03D00860 1 > $DCC_PATH/config
    echo 0x03D00864 1 > $DCC_PATH/config
    echo 0x03D00868 1 > $DCC_PATH/config
    echo 0x03D0086C 1 > $DCC_PATH/config
    echo 0x03D00870 1 > $DCC_PATH/config
    echo 0x03D00874 1 > $DCC_PATH/config
    echo 0x03D00878 1 > $DCC_PATH/config
    echo 0x03D0087C 1 > $DCC_PATH/config
    echo 0x03D00880 1 > $DCC_PATH/config
    echo 0x03D00884 1 > $DCC_PATH/config
    echo 0x03D00888 1 > $DCC_PATH/config
    echo 0x03D0088C 1 > $DCC_PATH/config
    echo 0x03D00890 1 > $DCC_PATH/config
    echo 0x03D00894 1 > $DCC_PATH/config
    echo 0x03D00898 1 > $DCC_PATH/config
    echo 0x03D0089C 1 > $DCC_PATH/config
    echo 0x03D008A0 1 > $DCC_PATH/config
    echo 0x03D008A4 1 > $DCC_PATH/config
    echo 0x03D008A8 1 > $DCC_PATH/config
    echo 0x03D008AC 1 > $DCC_PATH/config
    echo 0x03D008B0 1 > $DCC_PATH/config
    echo 0x03D008B4 1 > $DCC_PATH/config
    echo 0x03D008B8 1 > $DCC_PATH/config
    echo 0x03D008BC 1 > $DCC_PATH/config
    echo 0x03D008C0 1 > $DCC_PATH/config
    echo 0x03D008C4 1 > $DCC_PATH/config
    echo 0x03D008C8 1 > $DCC_PATH/config
    echo 0x03D008CC 1 > $DCC_PATH/config
    echo 0x03D008D0 1 > $DCC_PATH/config
    echo 0x03D008D4 1 > $DCC_PATH/config
    echo 0x03D008D8 1 > $DCC_PATH/config
    echo 0x03D008DC 1 > $DCC_PATH/config
    echo 0x03D008E0 1 > $DCC_PATH/config
    echo 0x03D008E4 1 > $DCC_PATH/config
    echo 0x03D008E8 1 > $DCC_PATH/config
    echo 0x03D008EC 1 > $DCC_PATH/config
    echo 0x03D008F0 1 > $DCC_PATH/config
    echo 0x03D008F4 1 > $DCC_PATH/config
    echo 0x03D008F8 1 > $DCC_PATH/config
    echo 0x03D008FC 1 > $DCC_PATH/config
    echo 0x03D00900 1 > $DCC_PATH/config
    echo 0x03D00904 1 > $DCC_PATH/config
    echo 0x03D00908 1 > $DCC_PATH/config
    echo 0x03D0090C 1 > $DCC_PATH/config
    echo 0x03D00910 1 > $DCC_PATH/config
    echo 0x03D00914 1 > $DCC_PATH/config
    echo 0x03D00918 1 > $DCC_PATH/config
    echo 0x03D0091C 1 > $DCC_PATH/config
    echo 0x03D00920 1 > $DCC_PATH/config
    echo 0x03D00924 1 > $DCC_PATH/config
    echo 0x03D00928 1 > $DCC_PATH/config
    echo 0x03D0092C 1 > $DCC_PATH/config
    echo 0x03D00930 1 > $DCC_PATH/config
    echo 0x03D00934 1 > $DCC_PATH/config
    echo 0x03D00938 1 > $DCC_PATH/config
    echo 0x03D0093C 1 > $DCC_PATH/config
    echo 0x03D00940 1 > $DCC_PATH/config
    echo 0x03D00944 1 > $DCC_PATH/config
    echo 0x03D00948 1 > $DCC_PATH/config
    echo 0x03D0094C 1 > $DCC_PATH/config
    echo 0x03D00980 1 > $DCC_PATH/config
    echo 0x03D00984 1 > $DCC_PATH/config
    echo 0x03D00988 1 > $DCC_PATH/config
    echo 0x03D0098C 1 > $DCC_PATH/config
    echo 0x03D00990 1 > $DCC_PATH/config
    echo 0x03D00994 1 > $DCC_PATH/config
    echo 0x03D00998 1 > $DCC_PATH/config
    echo 0x03D0099C 1 > $DCC_PATH/config
    echo 0x03D009A0 1 > $DCC_PATH/config
    echo 0x03D009A4 1 > $DCC_PATH/config
    echo 0x03D009A8 1 > $DCC_PATH/config
    echo 0x03D009AC 1 > $DCC_PATH/config
    echo 0x03D009B0 1 > $DCC_PATH/config
    echo 0x03D009B4 1 > $DCC_PATH/config
    echo 0x03D009B8 1 > $DCC_PATH/config
    echo 0x03D009BC 1 > $DCC_PATH/config
    echo 0x03D009C0 1 > $DCC_PATH/config
    echo 0x03D009C8 1 > $DCC_PATH/config
    echo 0x03D009CC 1 > $DCC_PATH/config
    echo 0x03D009D0 1 > $DCC_PATH/config
    echo 0x03D00A04 1 > $DCC_PATH/config
    echo 0x03D00A08 1 > $DCC_PATH/config
    echo 0x03D00A0C 1 > $DCC_PATH/config
    echo 0x03D00A10 1 > $DCC_PATH/config
    echo 0x03D00A14 1 > $DCC_PATH/config
    echo 0x03D00A18 1 > $DCC_PATH/config
    echo 0x03D00A1C 1 > $DCC_PATH/config
    echo 0x03D00A20 1 > $DCC_PATH/config
    echo 0x03D00A24 1 > $DCC_PATH/config
    echo 0x03D00A28 1 > $DCC_PATH/config
    echo 0x03D00A2C 1 > $DCC_PATH/config
    echo 0x03D00A30 1 > $DCC_PATH/config
    echo 0x03D00A34 1 > $DCC_PATH/config
    echo 0x03D00C00 1 > $DCC_PATH/config
    echo 0x03D00C04 1 > $DCC_PATH/config
    echo 0x03D00C08 1 > $DCC_PATH/config
    echo 0x03D00C0C 1 > $DCC_PATH/config
    echo 0x03D00C10 1 > $DCC_PATH/config
    echo 0x03D00C14 1 > $DCC_PATH/config
    echo 0x03D00C18 1 > $DCC_PATH/config
    echo 0x03D00C1C 1 > $DCC_PATH/config
    echo 0x03D00C20 1 > $DCC_PATH/config
    echo 0x03D00C24 1 > $DCC_PATH/config
    echo 0x03D00C28 1 > $DCC_PATH/config
    echo 0x03D00C2C 1 > $DCC_PATH/config
    echo 0x03D00C30 1 > $DCC_PATH/config
    echo 0x03D00C34 1 > $DCC_PATH/config
    echo 0x03D00C38 1 > $DCC_PATH/config
    echo 0x03D00C3C 1 > $DCC_PATH/config
    echo 0x03D00C40 1 > $DCC_PATH/config
    echo 0x03D00C44 1 > $DCC_PATH/config
    echo 0x03D00C48 1 > $DCC_PATH/config
    echo 0x03D00C4C 1 > $DCC_PATH/config
    echo 0x03D00C50 1 > $DCC_PATH/config
    echo 0x03D00C54 1 > $DCC_PATH/config
    echo 0x03D00C58 1 > $DCC_PATH/config
    echo 0x03D00C5C 1 > $DCC_PATH/config
    echo 0x03D00C60 1 > $DCC_PATH/config
    echo 0x03D00C64 1 > $DCC_PATH/config
    echo 0x03D00C68 1 > $DCC_PATH/config
    echo 0x03D00C6C 1 > $DCC_PATH/config
    echo 0x03D00C70 1 > $DCC_PATH/config
    echo 0x03D00C74 1 > $DCC_PATH/config
    echo 0x03D00C78 1 > $DCC_PATH/config
    echo 0x03D00C7C 1 > $DCC_PATH/config
    echo 0x03D00C80 1 > $DCC_PATH/config
    echo 0x03D00C84 1 > $DCC_PATH/config
    echo 0x03D00C88 1 > $DCC_PATH/config
    echo 0x03D00C8C 1 > $DCC_PATH/config
    echo 0x03D00C90 1 > $DCC_PATH/config
    echo 0x03D00C94 1 > $DCC_PATH/config
    echo 0x03D00C98 1 > $DCC_PATH/config
    echo 0x03D00C9C 1 > $DCC_PATH/config
    echo 0x03D00CA0 1 > $DCC_PATH/config
    echo 0x03D00CA4 1 > $DCC_PATH/config
    echo 0x03D00CA8 1 > $DCC_PATH/config
    echo 0x03D00CAC 1 > $DCC_PATH/config
    echo 0x03D00CB0 1 > $DCC_PATH/config
    echo 0x03D00CB4 1 > $DCC_PATH/config
    echo 0x03D00CB8 1 > $DCC_PATH/config
    echo 0x03D00CBC 1 > $DCC_PATH/config
    echo 0x03D00CC0 1 > $DCC_PATH/config
    echo 0x03D00CC4 1 > $DCC_PATH/config
    echo 0x03D00CC8 1 > $DCC_PATH/config
    echo 0x03D00CCC 1 > $DCC_PATH/config
    echo 0x03D00CD0 1 > $DCC_PATH/config
    echo 0x03D00CD4 1 > $DCC_PATH/config
    echo 0x03D00CD8 1 > $DCC_PATH/config
    echo 0x03D00CDC 1 > $DCC_PATH/config
    echo 0x03D00CE0 1 > $DCC_PATH/config
    echo 0x03D00CE4 1 > $DCC_PATH/config
    echo 0x03D00CE8 1 > $DCC_PATH/config
    echo 0x03D00CEC 1 > $DCC_PATH/config
    echo 0x03D00CF0 1 > $DCC_PATH/config
    echo 0x03D00CF4 1 > $DCC_PATH/config
    echo 0x03D00CF8 1 > $DCC_PATH/config
    echo 0x03D00CFC 1 > $DCC_PATH/config
    echo 0x03D00D00 1 > $DCC_PATH/config
    echo 0x03D00D04 1 > $DCC_PATH/config
    echo 0x03D00D08 1 > $DCC_PATH/config
    echo 0x03D00D0C 1 > $DCC_PATH/config
    echo 0x03D00D10 1 > $DCC_PATH/config
    echo 0x03D00D14 1 > $DCC_PATH/config
    echo 0x03D00D18 1 > $DCC_PATH/config
    echo 0x03D00D1C 1 > $DCC_PATH/config
    echo 0x03D00D20 1 > $DCC_PATH/config
    echo 0x03D00D24 1 > $DCC_PATH/config
    echo 0x03D00D28 1 > $DCC_PATH/config
    echo 0x03D00D2C 1 > $DCC_PATH/config
    echo 0x03D00D30 1 > $DCC_PATH/config
    echo 0x03D00D34 1 > $DCC_PATH/config
    echo 0x03D00D38 1 > $DCC_PATH/config
    echo 0x03D00D3C 1 > $DCC_PATH/config
    echo 0x03D00D40 1 > $DCC_PATH/config
    echo 0x03D00D44 1 > $DCC_PATH/config
    echo 0x03D00D48 1 > $DCC_PATH/config
    echo 0x03D00D4C 1 > $DCC_PATH/config
    echo 0x03D00D50 1 > $DCC_PATH/config
    echo 0x03D00D54 1 > $DCC_PATH/config
    echo 0x03D00D58 1 > $DCC_PATH/config
    echo 0x03D00D5C 1 > $DCC_PATH/config
    echo 0x03D00D60 1 > $DCC_PATH/config
    echo 0x03D00D64 1 > $DCC_PATH/config
    echo 0x03D00D68 1 > $DCC_PATH/config
    echo 0x03D00D6C 1 > $DCC_PATH/config
    echo 0x03D00D70 1 > $DCC_PATH/config
    echo 0x03D00D74 1 > $DCC_PATH/config
    echo 0x03D00D78 1 > $DCC_PATH/config
    echo 0x03D00D7C 1 > $DCC_PATH/config
    echo 0x03D00D80 1 > $DCC_PATH/config
    echo 0x03D00D84 1 > $DCC_PATH/config
    echo 0x03D00D88 1 > $DCC_PATH/config
    echo 0x03D00D8C 1 > $DCC_PATH/config
    echo 0x03D00D90 1 > $DCC_PATH/config
    echo 0x03D00D94 1 > $DCC_PATH/config
    echo 0x03D00D98 1 > $DCC_PATH/config
    echo 0x03D00D9C 1 > $DCC_PATH/config
    echo 0x03D00DA0 1 > $DCC_PATH/config
    echo 0x03D00DA4 1 > $DCC_PATH/config
    echo 0x03D00DA8 1 > $DCC_PATH/config
    echo 0x03D00DAC 1 > $DCC_PATH/config
    echo 0x03D00DB0 1 > $DCC_PATH/config
    echo 0x03D00DB4 1 > $DCC_PATH/config
    echo 0x03D00DB8 1 > $DCC_PATH/config
    echo 0x03D00DBC 1 > $DCC_PATH/config
    echo 0x03D00DC0 1 > $DCC_PATH/config
    echo 0x03D00DC4 1 > $DCC_PATH/config
    echo 0x03D00DC8 1 > $DCC_PATH/config
    echo 0x03D00DCC 1 > $DCC_PATH/config
    echo 0x03D00DD0 1 > $DCC_PATH/config
    echo 0x03D00DD4 1 > $DCC_PATH/config
    echo 0x03D00DD8 1 > $DCC_PATH/config
    echo 0x03D00DDC 1 > $DCC_PATH/config
    echo 0x03D00DE0 1 > $DCC_PATH/config
    echo 0x03D00DE4 1 > $DCC_PATH/config
    echo 0x03D00DE8 1 > $DCC_PATH/config
    echo 0x03D00DEC 1 > $DCC_PATH/config
    echo 0x03D00DF0 1 > $DCC_PATH/config
    echo 0x03D00DF4 1 > $DCC_PATH/config
    echo 0x03D00DF8 1 > $DCC_PATH/config
    echo 0x03D00DFC 1 > $DCC_PATH/config
    echo 0x03D00E00 1 > $DCC_PATH/config
    echo 0x03D00E04 1 > $DCC_PATH/config
    echo 0x03D00E08 1 > $DCC_PATH/config
    echo 0x03D00E0C 1 > $DCC_PATH/config
    echo 0x03D00E10 1 > $DCC_PATH/config
    echo 0x03D00E14 1 > $DCC_PATH/config
    echo 0x03D00E18 1 > $DCC_PATH/config
    echo 0x03D00E1C 1 > $DCC_PATH/config
    echo 0x03D00E20 1 > $DCC_PATH/config
    echo 0x03D00E24 1 > $DCC_PATH/config
    echo 0x03D00E28 1 > $DCC_PATH/config
    echo 0x03D00E2C 1 > $DCC_PATH/config
    echo 0x03D00E30 1 > $DCC_PATH/config
    echo 0x03D00E34 1 > $DCC_PATH/config
    echo 0x03D00E38 1 > $DCC_PATH/config
    echo 0x03D00E3C 1 > $DCC_PATH/config
    echo 0x03D00E40 1 > $DCC_PATH/config
    echo 0x03D00E44 1 > $DCC_PATH/config
    echo 0x03D00E48 1 > $DCC_PATH/config
    echo 0x03D00E4C 1 > $DCC_PATH/config
    echo 0x03D00E50 1 > $DCC_PATH/config
    echo 0x03D00E54 1 > $DCC_PATH/config
    echo 0x03D00E58 1 > $DCC_PATH/config
    echo 0x03D00E5C 1 > $DCC_PATH/config
    echo 0x03D00E60 1 > $DCC_PATH/config
    echo 0x03D00E64 1 > $DCC_PATH/config
    echo 0x03D00E68 1 > $DCC_PATH/config
    echo 0x03D00E6C 1 > $DCC_PATH/config
    echo 0x03D00E70 1 > $DCC_PATH/config
    echo 0x03D00E74 1 > $DCC_PATH/config
    echo 0x03D00E78 1 > $DCC_PATH/config
    echo 0x03D00E7C 1 > $DCC_PATH/config
    echo 0x03D00E80 1 > $DCC_PATH/config
    echo 0x03D00E84 1 > $DCC_PATH/config
    echo 0x03D00E88 1 > $DCC_PATH/config
    echo 0x03D00E8C 1 > $DCC_PATH/config
    echo 0x03D00E90 1 > $DCC_PATH/config
    echo 0x03D00E94 1 > $DCC_PATH/config
    echo 0x03D00E98 1 > $DCC_PATH/config
    echo 0x03D00E9C 1 > $DCC_PATH/config
    echo 0x03D00EA0 1 > $DCC_PATH/config
    echo 0x03D00EA4 1 > $DCC_PATH/config
    echo 0x03D00EA8 1 > $DCC_PATH/config
    echo 0x03D00EAC 1 > $DCC_PATH/config
    echo 0x03D00EB0 1 > $DCC_PATH/config
    echo 0x03D00EB4 1 > $DCC_PATH/config
    echo 0x03D00EB8 1 > $DCC_PATH/config
    echo 0x03D00EBC 1 > $DCC_PATH/config
    echo 0x03D00EC0 1 > $DCC_PATH/config
    echo 0x03D00EC4 1 > $DCC_PATH/config
    echo 0x03D00EC8 1 > $DCC_PATH/config
    echo 0x03D00ECC 1 > $DCC_PATH/config
    echo 0x03D00ED0 1 > $DCC_PATH/config
    echo 0x03D00ED4 1 > $DCC_PATH/config
    echo 0x03D00ED8 1 > $DCC_PATH/config
    echo 0x03D00EDC 1 > $DCC_PATH/config
    echo 0x03D00EE0 1 > $DCC_PATH/config
    echo 0x03D00EE4 1 > $DCC_PATH/config
    echo 0x03D00EE8 1 > $DCC_PATH/config
    echo 0x03D00EEC 1 > $DCC_PATH/config
    echo 0x03D00EF0 1 > $DCC_PATH/config
    echo 0x03D00EF4 1 > $DCC_PATH/config
    echo 0x03D00EF8 1 > $DCC_PATH/config
    echo 0x03D00EFC 1 > $DCC_PATH/config
    echo 0x03D00F00 1 > $DCC_PATH/config
    echo 0x03D00F04 1 > $DCC_PATH/config
    echo 0x03D00F08 1 > $DCC_PATH/config
    echo 0x03D00F0C 1 > $DCC_PATH/config
    echo 0x03D00F10 1 > $DCC_PATH/config
    echo 0x03D00F14 1 > $DCC_PATH/config
    echo 0x03D00F18 1 > $DCC_PATH/config
    echo 0x03D00F1C 1 > $DCC_PATH/config
    echo 0x03D00F20 1 > $DCC_PATH/config
    echo 0x03D00F24 1 > $DCC_PATH/config
    echo 0x03D00F28 1 > $DCC_PATH/config
    echo 0x03D00F2C 1 > $DCC_PATH/config
    echo 0x03D00F30 1 > $DCC_PATH/config
    echo 0x03D00F34 1 > $DCC_PATH/config
    echo 0x03D00F38 1 > $DCC_PATH/config
    echo 0x03D00F3C 1 > $DCC_PATH/config
    echo 0x03D00F40 1 > $DCC_PATH/config
    echo 0x03D00F44 1 > $DCC_PATH/config
    echo 0x03D00F48 1 > $DCC_PATH/config
    echo 0x03D00F4C 1 > $DCC_PATH/config
    echo 0x03D00F50 1 > $DCC_PATH/config
    echo 0x03D00F54 1 > $DCC_PATH/config
    echo 0x03D00F58 1 > $DCC_PATH/config
    echo 0x03D00F5C 1 > $DCC_PATH/config
    echo 0x03D00F60 1 > $DCC_PATH/config
    echo 0x03D00F64 1 > $DCC_PATH/config
    echo 0x03D00F68 1 > $DCC_PATH/config
    echo 0x03D00F6C 1 > $DCC_PATH/config
    echo 0x03D00F70 1 > $DCC_PATH/config
    echo 0x03D00F74 1 > $DCC_PATH/config
    echo 0x03D00F78 1 > $DCC_PATH/config
    echo 0x03D00F7C 1 > $DCC_PATH/config
    echo 0x03D00F80 1 > $DCC_PATH/config
    echo 0x03D00F84 1 > $DCC_PATH/config
    echo 0x03D00F88 1 > $DCC_PATH/config
    echo 0x03D00F8C 1 > $DCC_PATH/config
    echo 0x03D00F90 1 > $DCC_PATH/config
    echo 0x03D00F94 1 > $DCC_PATH/config
    echo 0x03D00F98 1 > $DCC_PATH/config
    echo 0x03D00F9C 1 > $DCC_PATH/config
    echo 0x03D00FA0 1 > $DCC_PATH/config
    echo 0x03D00FA4 1 > $DCC_PATH/config
    echo 0x03D00FA8 1 > $DCC_PATH/config
    echo 0x03D00FAC 1 > $DCC_PATH/config
    echo 0x03D00FB0 1 > $DCC_PATH/config
    echo 0x03D00FB4 1 > $DCC_PATH/config
    echo 0x03D00FB8 1 > $DCC_PATH/config
    echo 0x03D00FBC 1 > $DCC_PATH/config
    echo 0x03D00FC0 1 > $DCC_PATH/config
    echo 0x03D00FC4 1 > $DCC_PATH/config
    echo 0x03D00FC8 1 > $DCC_PATH/config
    echo 0x03D00FCC 1 > $DCC_PATH/config
    echo 0x03D00FD0 1 > $DCC_PATH/config
    echo 0x03D00FD4 1 > $DCC_PATH/config
    echo 0x03D00FD8 1 > $DCC_PATH/config
    echo 0x03D00FDC 1 > $DCC_PATH/config
    echo 0x03D00FE0 1 > $DCC_PATH/config
    echo 0x03D00FE4 1 > $DCC_PATH/config
    echo 0x03D00FE8 1 > $DCC_PATH/config
    echo 0x03D00FEC 1 > $DCC_PATH/config
    echo 0x03D00FF0 1 > $DCC_PATH/config
    echo 0x03D00FF4 1 > $DCC_PATH/config
    echo 0x03D00FF8 1 > $DCC_PATH/config
    echo 0x03D00FFC 1 > $DCC_PATH/config
    echo 0x03D01000 1 > $DCC_PATH/config
    echo 0x03D01004 1 > $DCC_PATH/config
    echo 0x03D01040 1 > $DCC_PATH/config
    echo 0x03D01044 1 > $DCC_PATH/config
    echo 0x03D01048 1 > $DCC_PATH/config
    echo 0x03D0104C 1 > $DCC_PATH/config
    echo 0x03D01050 1 > $DCC_PATH/config
    echo 0x03D01054 1 > $DCC_PATH/config
    echo 0x03D01058 1 > $DCC_PATH/config
    echo 0x03D0105C 1 > $DCC_PATH/config
    echo 0x03D01060 1 > $DCC_PATH/config
    echo 0x03D01064 1 > $DCC_PATH/config
    echo 0x03D01068 1 > $DCC_PATH/config
    echo 0x03D0106C 1 > $DCC_PATH/config
    echo 0x03D01070 1 > $DCC_PATH/config
    echo 0x03D01074 1 > $DCC_PATH/config
    echo 0x03D01078 1 > $DCC_PATH/config
    echo 0x03D0107C 1 > $DCC_PATH/config
    echo 0x03D01080 1 > $DCC_PATH/config
    echo 0x03D01084 1 > $DCC_PATH/config
    echo 0x03D01088 1 > $DCC_PATH/config
    echo 0x03D0108C 1 > $DCC_PATH/config
    echo 0x03D01090 1 > $DCC_PATH/config
    echo 0x03D01094 1 > $DCC_PATH/config
    echo 0x03D01098 1 > $DCC_PATH/config
    echo 0x03D0109C 1 > $DCC_PATH/config
    echo 0x03D010A0 1 > $DCC_PATH/config
    echo 0x03D010A4 1 > $DCC_PATH/config
    echo 0x03D010A8 1 > $DCC_PATH/config
    echo 0x03D010AC 1 > $DCC_PATH/config
    echo 0x03D010B0 1 > $DCC_PATH/config
    echo 0x03D010B4 1 > $DCC_PATH/config
    echo 0x03D010B8 1 > $DCC_PATH/config
    echo 0x03D010BC 1 > $DCC_PATH/config
    echo 0x03D010C0 1 > $DCC_PATH/config
    echo 0x03D010C4 1 > $DCC_PATH/config
    echo 0x03D010C8 1 > $DCC_PATH/config
    echo 0x03D010CC 1 > $DCC_PATH/config
    echo 0x03D010D0 1 > $DCC_PATH/config
    echo 0x03D010D4 1 > $DCC_PATH/config
    echo 0x03D010D8 1 > $DCC_PATH/config
    echo 0x03D010DC 1 > $DCC_PATH/config
    echo 0x03D010E0 1 > $DCC_PATH/config
    echo 0x03D010E4 1 > $DCC_PATH/config
    echo 0x03D010E8 1 > $DCC_PATH/config
    echo 0x03D010EC 1 > $DCC_PATH/config
    echo 0x03D010F0 1 > $DCC_PATH/config
    echo 0x03D010F4 1 > $DCC_PATH/config
    echo 0x03D010F8 1 > $DCC_PATH/config
    echo 0x03D010FC 1 > $DCC_PATH/config
    echo 0x03D01100 1 > $DCC_PATH/config
    echo 0x03D01104 1 > $DCC_PATH/config
    echo 0x03D01108 1 > $DCC_PATH/config
    echo 0x03D0110C 1 > $DCC_PATH/config
    echo 0x03D01110 1 > $DCC_PATH/config
    echo 0x03D01114 1 > $DCC_PATH/config
    echo 0x03D01118 1 > $DCC_PATH/config
    echo 0x03D0111C 1 > $DCC_PATH/config
    echo 0x03D01120 1 > $DCC_PATH/config
    echo 0x03D01124 1 > $DCC_PATH/config
    echo 0x03D01128 1 > $DCC_PATH/config
    echo 0x03D0112C 1 > $DCC_PATH/config
    echo 0x03D01130 1 > $DCC_PATH/config
    echo 0x03D01134 1 > $DCC_PATH/config
    echo 0x03D01138 1 > $DCC_PATH/config
    echo 0x03D0113C 1 > $DCC_PATH/config
    echo 0x03D01140 1 > $DCC_PATH/config
    echo 0x03D01144 1 > $DCC_PATH/config
    echo 0x03D01180 1 > $DCC_PATH/config
    echo 0x03D01184 1 > $DCC_PATH/config
    echo 0x03D01188 1 > $DCC_PATH/config
    echo 0x03D0118C 1 > $DCC_PATH/config
    echo 0x03D01190 1 > $DCC_PATH/config
    echo 0x03D01194 1 > $DCC_PATH/config
    echo 0x03D01198 1 > $DCC_PATH/config
    echo 0x03D0119C 1 > $DCC_PATH/config
    echo 0x03D011A0 1 > $DCC_PATH/config
    echo 0x03D011A4 1 > $DCC_PATH/config
    echo 0x03D011A8 1 > $DCC_PATH/config
    echo 0x03D011AC 1 > $DCC_PATH/config
    echo 0x03D011B0 1 > $DCC_PATH/config
    echo 0x03D011B4 1 > $DCC_PATH/config
    echo 0x03D011B8 1 > $DCC_PATH/config
    echo 0x03D011BC 1 > $DCC_PATH/config
    echo 0x03D011C0 1 > $DCC_PATH/config
    echo 0x03D011C4 1 > $DCC_PATH/config
    echo 0x03D011C8 1 > $DCC_PATH/config
    echo 0x03D011CC 1 > $DCC_PATH/config
    echo 0x03D011D0 1 > $DCC_PATH/config
    echo 0x03D011D4 1 > $DCC_PATH/config
    echo 0x03D011D8 1 > $DCC_PATH/config
    echo 0x03D011DC 1 > $DCC_PATH/config
    echo 0x03D011E0 1 > $DCC_PATH/config
    echo 0x03D011E4 1 > $DCC_PATH/config
    echo 0x03D011E8 1 > $DCC_PATH/config
    echo 0x03D011EC 1 > $DCC_PATH/config
    echo 0x03D011F0 1 > $DCC_PATH/config
    echo 0x03D011F4 1 > $DCC_PATH/config
    echo 0x03D011F8 1 > $DCC_PATH/config
    echo 0x03D011FC 1 > $DCC_PATH/config
    echo 0x03D01200 1 > $DCC_PATH/config
    echo 0x03D01204 1 > $DCC_PATH/config
    echo 0x03D01208 1 > $DCC_PATH/config
    echo 0x03D0120C 1 > $DCC_PATH/config
    echo 0x03D01210 1 > $DCC_PATH/config
    echo 0x03D01214 1 > $DCC_PATH/config
    echo 0x03D01218 1 > $DCC_PATH/config
    echo 0x03D0121C 1 > $DCC_PATH/config
    echo 0x03D01220 1 > $DCC_PATH/config
    echo 0x03D01224 1 > $DCC_PATH/config
    echo 0x03D01228 1 > $DCC_PATH/config
    echo 0x03D0122C 1 > $DCC_PATH/config
    echo 0x03D01230 1 > $DCC_PATH/config
    echo 0x03D01234 1 > $DCC_PATH/config
    echo 0x03D01238 1 > $DCC_PATH/config
    echo 0x03D0123C 1 > $DCC_PATH/config
    echo 0x03D01240 1 > $DCC_PATH/config
    echo 0x03D01244 1 > $DCC_PATH/config
    echo 0x03D01248 1 > $DCC_PATH/config
    echo 0x03D0124C 1 > $DCC_PATH/config
    echo 0x03D01250 1 > $DCC_PATH/config
    echo 0x03D01254 1 > $DCC_PATH/config
    echo 0x03D01258 1 > $DCC_PATH/config
    echo 0x03D0125C 1 > $DCC_PATH/config
    echo 0x03D01260 1 > $DCC_PATH/config
    echo 0x03D01264 1 > $DCC_PATH/config
    echo 0x03D01268 1 > $DCC_PATH/config
    echo 0x03D0126C 1 > $DCC_PATH/config
    echo 0x03D01270 1 > $DCC_PATH/config
    echo 0x03D01274 1 > $DCC_PATH/config
    echo 0x03D01278 1 > $DCC_PATH/config
    echo 0x03D0127C 1 > $DCC_PATH/config
    echo 0x03D01280 1 > $DCC_PATH/config
    echo 0x03D01284 1 > $DCC_PATH/config
    echo 0x03D01288 1 > $DCC_PATH/config
    echo 0x03D0128C 1 > $DCC_PATH/config
    echo 0x03D01300 1 > $DCC_PATH/config
    echo 0x03D01304 1 > $DCC_PATH/config
    echo 0x03D01308 1 > $DCC_PATH/config
    echo 0x03D0130C 1 > $DCC_PATH/config
    echo 0x03D01310 1 > $DCC_PATH/config
    echo 0x03D01314 1 > $DCC_PATH/config
    echo 0x03D01318 1 > $DCC_PATH/config
    echo 0x03D0131C 1 > $DCC_PATH/config
    echo 0x03D01320 1 > $DCC_PATH/config
    echo 0x03D01324 1 > $DCC_PATH/config
    echo 0x03D01328 1 > $DCC_PATH/config
    echo 0x03D0132C 1 > $DCC_PATH/config
    echo 0x03D01330 1 > $DCC_PATH/config
    echo 0x03D01334 1 > $DCC_PATH/config
    echo 0x03D01338 1 > $DCC_PATH/config
    echo 0x03D0133C 1 > $DCC_PATH/config
    echo 0x03D01340 1 > $DCC_PATH/config
    echo 0x03D01344 1 > $DCC_PATH/config
    echo 0x03D01400 1 > $DCC_PATH/config
    echo 0x03D0141C 1 > $DCC_PATH/config
    echo 0x03D01420 1 > $DCC_PATH/config
    echo 0x03D01424 1 > $DCC_PATH/config
    echo 0x03D01428 1 > $DCC_PATH/config
    echo 0x03D0142C 1 > $DCC_PATH/config
    echo 0x03D01438 1 > $DCC_PATH/config
    echo 0x03D0143C 1 > $DCC_PATH/config
    echo 0x03D01440 1 > $DCC_PATH/config
    echo 0x03D01444 1 > $DCC_PATH/config
    echo 0x03D014CC 1 > $DCC_PATH/config
    echo 0x03D014D0 1 > $DCC_PATH/config
    echo 0x03D014D4 1 > $DCC_PATH/config
    echo 0x03D014D8 1 > $DCC_PATH/config
    echo 0x03D01500 1 > $DCC_PATH/config
    echo 0x03D01504 1 > $DCC_PATH/config
    echo 0x03D01508 1 > $DCC_PATH/config
    echo 0x03D0150C 1 > $DCC_PATH/config
    echo 0x03D01510 1 > $DCC_PATH/config
    echo 0x03D01514 1 > $DCC_PATH/config
    echo 0x03D01518 1 > $DCC_PATH/config
    echo 0x03D0151C 1 > $DCC_PATH/config
    echo 0x03D01520 1 > $DCC_PATH/config
    echo 0x03D01524 1 > $DCC_PATH/config
    echo 0x03D01528 1 > $DCC_PATH/config
    echo 0x03D0152C 1 > $DCC_PATH/config
    echo 0x03D01530 1 > $DCC_PATH/config
    echo 0x03D01534 1 > $DCC_PATH/config
    echo 0x03D01538 1 > $DCC_PATH/config
    echo 0x03D0153C 1 > $DCC_PATH/config
    echo 0x03D01540 1 > $DCC_PATH/config
    echo 0x03D01544 1 > $DCC_PATH/config
    echo 0x03D01548 1 > $DCC_PATH/config
    echo 0x03D0154C 1 > $DCC_PATH/config
    echo 0x03D01550 1 > $DCC_PATH/config
    echo 0x03D01554 1 > $DCC_PATH/config
    echo 0x03D01590 1 > $DCC_PATH/config
    echo 0x03D01594 1 > $DCC_PATH/config
    echo 0x03D01598 1 > $DCC_PATH/config
    echo 0x03D0159C 1 > $DCC_PATH/config
    echo 0x03D015D0 1 > $DCC_PATH/config
    echo 0x03D015D4 1 > $DCC_PATH/config
    echo 0x03D015D8 1 > $DCC_PATH/config
    echo 0x03D015DC 1 > $DCC_PATH/config
    echo 0x03D01610 1 > $DCC_PATH/config
    echo 0x03D01614 1 > $DCC_PATH/config
    echo 0x03D01618 1 > $DCC_PATH/config
    echo 0x03D0161C 1 > $DCC_PATH/config
    echo 0x03D01620 1 > $DCC_PATH/config
    echo 0x03D01624 1 > $DCC_PATH/config
    echo 0x03D01628 1 > $DCC_PATH/config
    echo 0x03D0162C 1 > $DCC_PATH/config
    echo 0x03D01630 1 > $DCC_PATH/config
    echo 0x03D01634 1 > $DCC_PATH/config
    echo 0x03D01638 1 > $DCC_PATH/config
    echo 0x03D0163C 1 > $DCC_PATH/config
    echo 0x03D01640 1 > $DCC_PATH/config
    echo 0x03D01644 1 > $DCC_PATH/config
    echo 0x03D01648 1 > $DCC_PATH/config
    echo 0x03D0164C 1 > $DCC_PATH/config
    echo 0x03D01650 1 > $DCC_PATH/config
    echo 0x03D01654 1 > $DCC_PATH/config
    echo 0x03D01658 1 > $DCC_PATH/config
    echo 0x03D0165C 1 > $DCC_PATH/config
    echo 0x03D01660 1 > $DCC_PATH/config
    echo 0x03D01664 1 > $DCC_PATH/config
    echo 0x03D01668 1 > $DCC_PATH/config
    echo 0x03D0166C 1 > $DCC_PATH/config
    echo 0x03D017EC 1 > $DCC_PATH/config
    echo 0x03D017F0 1 > $DCC_PATH/config
    echo 0x03D017F4 1 > $DCC_PATH/config
    echo 0x03D017F8 1 > $DCC_PATH/config
    echo 0x03D017FC 1 > $DCC_PATH/config
    echo 0x03D3D000 1 > $DCC_PATH/config
    echo 0x03D3E000 1 > $DCC_PATH/config
    echo 0x03D3E004 1 > $DCC_PATH/config
    echo 0x03D3E008 1 > $DCC_PATH/config
    echo 0x03D3E00C 1 > $DCC_PATH/config
    echo 0x03D3F000 1 > $DCC_PATH/config
    echo 0x03D3F004 1 > $DCC_PATH/config
    echo 0x03D99800 1 > $DCC_PATH/config
    echo 0x03D99804 1 > $DCC_PATH/config
    echo 0x03D99808 1 > $DCC_PATH/config
    echo 0x03D9980C 1 > $DCC_PATH/config
    echo 0x03D99810 1 > $DCC_PATH/config
    echo 0x03D99814 1 > $DCC_PATH/config
    echo 0x03D99818 1 > $DCC_PATH/config
    echo 0x03D9981C 1 > $DCC_PATH/config
    echo 0x03D99820 1 > $DCC_PATH/config
    echo 0x03D99824 1 > $DCC_PATH/config
    echo 0x03D99828 1 > $DCC_PATH/config
    echo 0x03D9982C 1 > $DCC_PATH/config
    echo 0x03D99830 1 > $DCC_PATH/config
    echo 0x03D99834 1 > $DCC_PATH/config
    echo 0x03D99838 1 > $DCC_PATH/config
    echo 0x03D9983C 1 > $DCC_PATH/config
    echo 0x03D99840 1 > $DCC_PATH/config
    echo 0x03D99844 1 > $DCC_PATH/config
    echo 0x03D99848 1 > $DCC_PATH/config
    echo 0x03D9984C 1 > $DCC_PATH/config
    echo 0x03D99850 1 > $DCC_PATH/config
    echo 0x03D99854 1 > $DCC_PATH/config
    echo 0x03D99858 1 > $DCC_PATH/config
    echo 0x03D99880 1 > $DCC_PATH/config
    echo 0x03D99884 1 > $DCC_PATH/config
    echo 0x03D99888 1 > $DCC_PATH/config
    echo 0x03D9988C 1 > $DCC_PATH/config
    echo 0x03D99890 1 > $DCC_PATH/config
    echo 0x03D99894 1 > $DCC_PATH/config
    echo 0x03D99898 1 > $DCC_PATH/config
    echo 0x03D9989C 1 > $DCC_PATH/config
    echo 0x03D998A0 1 > $DCC_PATH/config
    echo 0x03D998A4 1 > $DCC_PATH/config
    echo 0x03D998A8 1 > $DCC_PATH/config
    echo 0x03D998AC 1 > $DCC_PATH/config
    echo 0x03D998B0 1 > $DCC_PATH/config
    echo 0x03D998B4 1 > $DCC_PATH/config
    echo 0x03D998C0 1 > $DCC_PATH/config
    echo 0x03D998C4 1 > $DCC_PATH/config
    echo 0x03D998D4 1 > $DCC_PATH/config
    echo 0x03D998DC 1 > $DCC_PATH/config
    echo 0x03D998E8 1 > $DCC_PATH/config
    echo 0x03D99908 1 > $DCC_PATH/config
    echo 0x03D99958 1 > $DCC_PATH/config
    echo 0x03D9995C 1 > $DCC_PATH/config
    echo 0x03D99960 1 > $DCC_PATH/config
    echo 0x03D9996C 1 > $DCC_PATH/config
    echo 0x03D99970 1 > $DCC_PATH/config
    echo 0x03D99974 1 > $DCC_PATH/config
    echo 0x03D9997C 1 > $DCC_PATH/config
    echo 0x03D99980 1 > $DCC_PATH/config
    echo 0x03D99984 1 > $DCC_PATH/config
    echo 0x03D99988 1 > $DCC_PATH/config
    echo 0x03D94000 1 > $DCC_PATH/config
    echo 0x03D94004 1 > $DCC_PATH/config
    echo 0x03D94008 1 > $DCC_PATH/config
    echo 0x03D95000 1 > $DCC_PATH/config
    echo 0x03D95004 1 > $DCC_PATH/config
    echo 0x03D95008 1 > $DCC_PATH/config
    echo 0x03D9500C 1 > $DCC_PATH/config
    echo 0x03D95010 1 > $DCC_PATH/config
    echo 0x03D96000 1 > $DCC_PATH/config
    echo 0x03D96004 1 > $DCC_PATH/config
    echo 0x03D96008 1 > $DCC_PATH/config
    echo 0x03D9600C 1 > $DCC_PATH/config
    echo 0x03D96010 1 > $DCC_PATH/config
    echo 0x03D97000 1 > $DCC_PATH/config
    echo 0x03D97004 1 > $DCC_PATH/config
    echo 0x03D97008 1 > $DCC_PATH/config
    echo 0x03D9700C 1 > $DCC_PATH/config
    echo 0x03D97010 1 > $DCC_PATH/config
    echo 0x03D98000 1 > $DCC_PATH/config
    echo 0x03D98004 1 > $DCC_PATH/config
    echo 0x03D98008 1 > $DCC_PATH/config
    echo 0x03D9800C 1 > $DCC_PATH/config
    echo 0x03D98010 1 > $DCC_PATH/config
    echo 0x03D99000 1 > $DCC_PATH/config
    echo 0x03D99004 1 > $DCC_PATH/config
    echo 0x03D99008 1 > $DCC_PATH/config
    echo 0x03D9900C 1 > $DCC_PATH/config
    echo 0x03D99010 1 > $DCC_PATH/config
    echo 0x03D99014 1 > $DCC_PATH/config
    echo 0x03D99050 1 > $DCC_PATH/config
    echo 0x03D99054 1 > $DCC_PATH/config
    echo 0x03D99058 1 > $DCC_PATH/config
    echo 0x03D9905C 1 > $DCC_PATH/config
    echo 0x03D99060 1 > $DCC_PATH/config
    echo 0x03D99064 1 > $DCC_PATH/config
    echo 0x03D99068 1 > $DCC_PATH/config
    echo 0x03D9906C 1 > $DCC_PATH/config
    echo 0x03D99070 1 > $DCC_PATH/config
    echo 0x03D99074 1 > $DCC_PATH/config
    echo 0x03D990A8 1 > $DCC_PATH/config
    echo 0x03D990AC 1 > $DCC_PATH/config
    echo 0x03D990B0 1 > $DCC_PATH/config
    echo 0x03D990B8 1 > $DCC_PATH/config
    echo 0x03D990BC 1 > $DCC_PATH/config
    echo 0x03D990C0 1 > $DCC_PATH/config
    echo 0x03D990C8 1 > $DCC_PATH/config
    echo 0x03D990CC 1 > $DCC_PATH/config
    echo 0x03D99104 1 > $DCC_PATH/config
    echo 0x03D99108 1 > $DCC_PATH/config
    echo 0x03D9910C 1 > $DCC_PATH/config
    echo 0x03D99110 1 > $DCC_PATH/config
    echo 0x03D99114 1 > $DCC_PATH/config
    echo 0x03D99118 1 > $DCC_PATH/config
    echo 0x03D9911C 1 > $DCC_PATH/config
    echo 0x03D99120 1 > $DCC_PATH/config
    echo 0x03D9912C 1 > $DCC_PATH/config
    echo 0x03D99134 1 > $DCC_PATH/config
    echo 0x03D9913C 1 > $DCC_PATH/config
    echo 0x03D99140 1 > $DCC_PATH/config
    echo 0x03D99144 1 > $DCC_PATH/config
    echo 0x03D99148 1 > $DCC_PATH/config
    echo 0x03D9914C 1 > $DCC_PATH/config
    echo 0x03D99150 1 > $DCC_PATH/config
    echo 0x03D99154 1 > $DCC_PATH/config
    echo 0x03D99158 1 > $DCC_PATH/config
    echo 0x03D9915C 1 > $DCC_PATH/config
    echo 0x03D99198 1 > $DCC_PATH/config
    echo 0x03D9919C 1 > $DCC_PATH/config
    echo 0x03D991A0 1 > $DCC_PATH/config
    echo 0x03D991E0 1 > $DCC_PATH/config
    echo 0x03D991E4 1 > $DCC_PATH/config
    echo 0x03D991E8 1 > $DCC_PATH/config
    echo 0x03D99224 1 > $DCC_PATH/config
    echo 0x03D99228 1 > $DCC_PATH/config
    echo 0x03D99270 1 > $DCC_PATH/config
    echo 0x03D99274 1 > $DCC_PATH/config
    echo 0x03D99278 1 > $DCC_PATH/config
    echo 0x03D99280 1 > $DCC_PATH/config
    echo 0x03D99284 1 > $DCC_PATH/config
    echo 0x03D99288 1 > $DCC_PATH/config
    echo 0x03D9928C 1 > $DCC_PATH/config
    echo 0x03D99290 1 > $DCC_PATH/config
    echo 0x03D99314 1 > $DCC_PATH/config
    echo 0x03D99318 1 > $DCC_PATH/config
    echo 0x03D9931C 1 > $DCC_PATH/config
    echo 0x03D99358 1 > $DCC_PATH/config
    echo 0x03D9935C 1 > $DCC_PATH/config
    echo 0x03D99360 1 > $DCC_PATH/config
    echo 0x03D993A0 1 > $DCC_PATH/config
    echo 0x03D993A4 1 > $DCC_PATH/config
    echo 0x03D993E4 1 > $DCC_PATH/config
    echo 0x03D993E8 1 > $DCC_PATH/config
    echo 0x03D993EC 1 > $DCC_PATH/config
    echo 0x03D993F0 1 > $DCC_PATH/config
    echo 0x03D99470 1 > $DCC_PATH/config
    echo 0x03D99474 1 > $DCC_PATH/config
    echo 0x03D99478 1 > $DCC_PATH/config
    echo 0x03D99500 1 > $DCC_PATH/config
    echo 0x03D99504 1 > $DCC_PATH/config
    echo 0x03D99508 1 > $DCC_PATH/config
    echo 0x03D9950C 1 > $DCC_PATH/config
    echo 0x03D99510 1 > $DCC_PATH/config
    echo 0x03D99514 1 > $DCC_PATH/config
    echo 0x03D99518 1 > $DCC_PATH/config
    echo 0x03D9951C 1 > $DCC_PATH/config
    echo 0x03D99520 1 > $DCC_PATH/config
    echo 0x03D99524 1 > $DCC_PATH/config
    echo 0x03D99528 1 > $DCC_PATH/config
    echo 0x03D9952C 1 > $DCC_PATH/config
    echo 0x03D99530 1 > $DCC_PATH/config
    echo 0x03D99534 1 > $DCC_PATH/config
    echo 0x03D99538 1 > $DCC_PATH/config
    echo 0x03D9953C 1 > $DCC_PATH/config
    echo 0x03D99540 1 > $DCC_PATH/config
    echo 0x03D99544 1 > $DCC_PATH/config
    echo 0x03D99548 1 > $DCC_PATH/config
    echo 0x03D9954C 1 > $DCC_PATH/config
    echo 0x03D99550 1 > $DCC_PATH/config
    echo 0x03D99554 1 > $DCC_PATH/config
    echo 0x03D99558 1 > $DCC_PATH/config
    echo 0x03D9955C 1 > $DCC_PATH/config
    echo 0x03D99560 1 > $DCC_PATH/config
    echo 0x03D99564 1 > $DCC_PATH/config
    echo 0x03D99568 1 > $DCC_PATH/config
    echo 0x03D9956C 1 > $DCC_PATH/config
    echo 0x03D99570 1 > $DCC_PATH/config
    echo 0x03D99574 1 > $DCC_PATH/config
    echo 0x03D99578 1 > $DCC_PATH/config
    echo 0x03D9957C 1 > $DCC_PATH/config
    echo 0x03D99580 1 > $DCC_PATH/config
    echo 0x03D99584 1 > $DCC_PATH/config
    echo 0x03D99588 1 > $DCC_PATH/config
    echo 0x03D9958C 1 > $DCC_PATH/config
    echo 0x03D99590 1 > $DCC_PATH/config
    echo 0x03D99594 1 > $DCC_PATH/config
    echo 0x03D99598 1 > $DCC_PATH/config
    echo 0x03D9959C 1 > $DCC_PATH/config
    echo 0x03D995A0 1 > $DCC_PATH/config
    echo 0x03D995A4 1 > $DCC_PATH/config
    echo 0x03D995A8 1 > $DCC_PATH/config
    echo 0x03D995AC 1 > $DCC_PATH/config
    echo 0x03D995B0 1 > $DCC_PATH/config
    echo 0x03D995B4 1 > $DCC_PATH/config
    echo 0x03D995B8 1 > $DCC_PATH/config
    echo 0x03D995BC 1 > $DCC_PATH/config
    echo 0x03D995C0 1 > $DCC_PATH/config
    echo 0x03D995C4 1 > $DCC_PATH/config
    echo 0x03D995C8 1 > $DCC_PATH/config
    echo 0x03D995CC 1 > $DCC_PATH/config
    echo 0x03D995D0 1 > $DCC_PATH/config
    echo 0x03D995D4 1 > $DCC_PATH/config
    echo 0x03D995D8 1 > $DCC_PATH/config
    echo 0x03D90000 1 > $DCC_PATH/config
    echo 0x03D90004 1 > $DCC_PATH/config
    echo 0x03D90008 1 > $DCC_PATH/config
    echo 0x03D9000C 1 > $DCC_PATH/config
    echo 0x03D90010 1 > $DCC_PATH/config
    echo 0x03D90014 1 > $DCC_PATH/config
    echo 0x03D90018 1 > $DCC_PATH/config
    echo 0x03D9001C 1 > $DCC_PATH/config
    echo 0x03D90020 1 > $DCC_PATH/config
    echo 0x03D90024 1 > $DCC_PATH/config
    echo 0x03D90028 1 > $DCC_PATH/config
    echo 0x03D9002C 1 > $DCC_PATH/config
    echo 0x03D90030 1 > $DCC_PATH/config
    echo 0x03D90034 1 > $DCC_PATH/config
    echo 0x03D90038 1 > $DCC_PATH/config
    echo 0x03D9003C 1 > $DCC_PATH/config
    echo 0x03D91000 1 > $DCC_PATH/config
    echo 0x03D91004 1 > $DCC_PATH/config
    echo 0x03D91008 1 > $DCC_PATH/config
    echo 0x03D9100C 1 > $DCC_PATH/config
    echo 0x03D91010 1 > $DCC_PATH/config
    echo 0x03D91014 1 > $DCC_PATH/config
    echo 0x03D91018 1 > $DCC_PATH/config
    echo 0x03D9101C 1 > $DCC_PATH/config
    echo 0x03D91020 1 > $DCC_PATH/config
    echo 0x03D91024 1 > $DCC_PATH/config
    echo 0x03D91028 1 > $DCC_PATH/config
    echo 0x03D9102C 1 > $DCC_PATH/config
    echo 0x03D91030 1 > $DCC_PATH/config
    echo 0x03D91034 1 > $DCC_PATH/config
    echo 0x03D91038 1 > $DCC_PATH/config
    echo 0x03D9103C 1 > $DCC_PATH/config
    echo 0x03D3B000 1 > $DCC_PATH/config
    echo 0x03D3B004 1 > $DCC_PATH/config
    echo 0x03D3B014 1 > $DCC_PATH/config
    echo 0x03D3B01C 1 > $DCC_PATH/config
    echo 0x03D3B028 1 > $DCC_PATH/config
    echo 0x03D3B048 1 > $DCC_PATH/config
    echo 0x03D3B098 1 > $DCC_PATH/config
    echo 0x03D3B09C 1 > $DCC_PATH/config
    echo 0x03D3B0A0 1 > $DCC_PATH/config
    echo 0x03D3B0AC 1 > $DCC_PATH/config
    echo 0x03D3B0B0 1 > $DCC_PATH/config
    echo 0x03D3B0B4 1 > $DCC_PATH/config
    echo 0x03D3B0BC 1 > $DCC_PATH/config
    echo 0x03D3B100 1 > $DCC_PATH/config
    echo 0x03D3B104 1 > $DCC_PATH/config
    echo 0x03D3B114 1 > $DCC_PATH/config
    echo 0x03D3B11C 1 > $DCC_PATH/config
    echo 0x03D3B128 1 > $DCC_PATH/config
    echo 0x03D3B148 1 > $DCC_PATH/config
    echo 0x03D3B198 1 > $DCC_PATH/config
    echo 0x03D3B19C 1 > $DCC_PATH/config
    echo 0x03D3B1A0 1 > $DCC_PATH/config
    echo 0x03D3B1AC 1 > $DCC_PATH/config
    echo 0x03D3B1B0 1 > $DCC_PATH/config
    echo 0x03D3B1B4 1 > $DCC_PATH/config
    echo 0x03D3B1BC 1 > $DCC_PATH/config
    echo 0x03D3B200 1 > $DCC_PATH/config
    echo 0x03D3B204 1 > $DCC_PATH/config
    echo 0x03D3B214 1 > $DCC_PATH/config
    echo 0x03D3B21C 1 > $DCC_PATH/config
    echo 0x03D3B228 1 > $DCC_PATH/config
    echo 0x03D3B248 1 > $DCC_PATH/config
    echo 0x03D3B298 1 > $DCC_PATH/config
    echo 0x03D3B29C 1 > $DCC_PATH/config
    echo 0x03D3B2A0 1 > $DCC_PATH/config
    echo 0x03D3B2AC 1 > $DCC_PATH/config
    echo 0x03D3B2B0 1 > $DCC_PATH/config
    echo 0x03D3B2B4 1 > $DCC_PATH/config
    echo 0x03D3B2BC 1 > $DCC_PATH/config
    echo 0x03D3B300 1 > $DCC_PATH/config
    echo 0x03D3B304 1 > $DCC_PATH/config
    echo 0x03D3B314 1 > $DCC_PATH/config
    echo 0x03D3B31C 1 > $DCC_PATH/config
    echo 0x03D3B328 1 > $DCC_PATH/config
    echo 0x03D3B348 1 > $DCC_PATH/config
    echo 0x03D3B398 1 > $DCC_PATH/config
    echo 0x03D3B39C 1 > $DCC_PATH/config
    echo 0x03D3B3A0 1 > $DCC_PATH/config
    echo 0x03D3B3AC 1 > $DCC_PATH/config
    echo 0x03D3B3B0 1 > $DCC_PATH/config
    echo 0x03D3B3B4 1 > $DCC_PATH/config
    echo 0x03D3B3BC 1 > $DCC_PATH/config
    echo 0x03D3B400 1 > $DCC_PATH/config
    echo 0x03D3B404 1 > $DCC_PATH/config
    echo 0x03D3B414 1 > $DCC_PATH/config
    echo 0x03D3B41C 1 > $DCC_PATH/config
    echo 0x03D3B428 1 > $DCC_PATH/config
    echo 0x03D3B448 1 > $DCC_PATH/config
    echo 0x03D3B498 1 > $DCC_PATH/config
    echo 0x03D3B49C 1 > $DCC_PATH/config
    echo 0x03D3B4A0 1 > $DCC_PATH/config
    echo 0x03D3B4AC 1 > $DCC_PATH/config
    echo 0x03D3B4B0 1 > $DCC_PATH/config
    echo 0x03D3B4B4 1 > $DCC_PATH/config
    echo 0x03D3B4BC 1 > $DCC_PATH/config
    echo 0x03D3B500 1 > $DCC_PATH/config
    echo 0x03D3B504 1 > $DCC_PATH/config
    echo 0x03D3B514 1 > $DCC_PATH/config
    echo 0x03D3B51C 1 > $DCC_PATH/config
    echo 0x03D3B528 1 > $DCC_PATH/config
    echo 0x03D3B548 1 > $DCC_PATH/config
    echo 0x03D3B598 1 > $DCC_PATH/config
    echo 0x03D3B59C 1 > $DCC_PATH/config
    echo 0x03D3B5A0 1 > $DCC_PATH/config
    echo 0x03D3B5AC 1 > $DCC_PATH/config
    echo 0x03D3B5B0 1 > $DCC_PATH/config
    echo 0x03D3B5B4 1 > $DCC_PATH/config
    echo 0x03D3B5BC 1 > $DCC_PATH/config
    echo 0x03D3B600 1 > $DCC_PATH/config
    echo 0x03D3B604 1 > $DCC_PATH/config
    echo 0x03D3B614 1 > $DCC_PATH/config
    echo 0x03D3B61C 1 > $DCC_PATH/config
    echo 0x03D3B628 1 > $DCC_PATH/config
    echo 0x03D3B648 1 > $DCC_PATH/config
    echo 0x03D3B698 1 > $DCC_PATH/config
    echo 0x03D3B69C 1 > $DCC_PATH/config
    echo 0x03D3B6A0 1 > $DCC_PATH/config
    echo 0x03D3B6AC 1 > $DCC_PATH/config
    echo 0x03D3B6B0 1 > $DCC_PATH/config
    echo 0x03D3B6B4 1 > $DCC_PATH/config
    echo 0x03D3B6BC 1 > $DCC_PATH/config
    echo 0x03D40000 1 > $DCC_PATH/config
    echo 0x03D40004 1 > $DCC_PATH/config
    echo 0x03D40008 1 > $DCC_PATH/config
    echo 0x03D4000C 1 > $DCC_PATH/config
    echo 0x03D41000 1 > $DCC_PATH/config
    echo 0x03D41004 1 > $DCC_PATH/config
    echo 0x03D41008 1 > $DCC_PATH/config
    echo 0x03D4100C 1 > $DCC_PATH/config
    echo 0x03D42000 1 > $DCC_PATH/config
    echo 0x03D42004 1 > $DCC_PATH/config
    echo 0x03D42008 1 > $DCC_PATH/config
    echo 0x03D4200C 1 > $DCC_PATH/config
    echo 0x03D43000 1 > $DCC_PATH/config
    echo 0x03D43004 1 > $DCC_PATH/config
    echo 0x03D43008 1 > $DCC_PATH/config
    echo 0x03D4300C 1 > $DCC_PATH/config
    echo 0x03D44000 1 > $DCC_PATH/config
    echo 0x03D44004 1 > $DCC_PATH/config
    echo 0x03D44008 1 > $DCC_PATH/config
    echo 0x03D4400C 1 > $DCC_PATH/config
    echo 0x03D45000 1 > $DCC_PATH/config
    echo 0x03D45004 1 > $DCC_PATH/config
    echo 0x03D45008 1 > $DCC_PATH/config
    echo 0x03D4500C 1 > $DCC_PATH/config
    echo 0x03D46000 1 > $DCC_PATH/config
    echo 0x03D46004 1 > $DCC_PATH/config
    echo 0x03D46008 1 > $DCC_PATH/config
    echo 0x03D4600C 1 > $DCC_PATH/config
    echo 0x03D47000 1 > $DCC_PATH/config
    echo 0x03D47004 1 > $DCC_PATH/config
    echo 0x03D47008 1 > $DCC_PATH/config
    echo 0x03D4700C 1 > $DCC_PATH/config
    echo 0x03D48000 1 > $DCC_PATH/config
    echo 0x03D49000 1 > $DCC_PATH/config
    echo 0x03D4A000 1 > $DCC_PATH/config
    echo 0x03D4B000 1 > $DCC_PATH/config
    echo 0x03D4C000 1 > $DCC_PATH/config
    echo 0x03D4D000 1 > $DCC_PATH/config
    echo 0x03D4E000 1 > $DCC_PATH/config
    echo 0x03D4F000 1 > $DCC_PATH/config
    echo 0x03D8E000 1 > $DCC_PATH/config
    echo 0x03D8E004 1 > $DCC_PATH/config
    echo 0x03D8E008 1 > $DCC_PATH/config
    echo 0x03D8E00C 1 > $DCC_PATH/config
    echo 0x03D8E010 1 > $DCC_PATH/config
    echo 0x03D8E014 1 > $DCC_PATH/config
    echo 0x03D8E018 1 > $DCC_PATH/config
    echo 0x03D8E01C 1 > $DCC_PATH/config
    echo 0x03D8E020 1 > $DCC_PATH/config
    echo 0x03D8E024 1 > $DCC_PATH/config
    echo 0x03D8E028 1 > $DCC_PATH/config
    echo 0x03D8E02C 1 > $DCC_PATH/config
    echo 0x03D8E030 1 > $DCC_PATH/config
    echo 0x03D8E034 1 > $DCC_PATH/config
    echo 0x03D8E038 1 > $DCC_PATH/config
    echo 0x03D8E03C 1 > $DCC_PATH/config
    echo 0x03D8E040 1 > $DCC_PATH/config
    echo 0x03D8E044 1 > $DCC_PATH/config
    echo 0x03D8E048 1 > $DCC_PATH/config
    echo 0x03D8E04C 1 > $DCC_PATH/config
    echo 0x03D8E050 1 > $DCC_PATH/config
    echo 0x03D8E054 1 > $DCC_PATH/config
    echo 0x03D8E058 1 > $DCC_PATH/config
    echo 0x03D8E05C 1 > $DCC_PATH/config
    echo 0x03D8E060 1 > $DCC_PATH/config
    echo 0x03D8E064 1 > $DCC_PATH/config
    echo 0x03D8E068 1 > $DCC_PATH/config
    echo 0x03D8E06C 1 > $DCC_PATH/config
    echo 0x03D8E070 1 > $DCC_PATH/config
    echo 0x03D8E074 1 > $DCC_PATH/config
    echo 0x03D8E078 1 > $DCC_PATH/config
    echo 0x03D8E07C 1 > $DCC_PATH/config
    echo 0x03D8E080 1 > $DCC_PATH/config
    echo 0x03D8E084 1 > $DCC_PATH/config
    echo 0x03D8E088 1 > $DCC_PATH/config
    echo 0x03D8E090 1 > $DCC_PATH/config
    echo 0x03D8E094 1 > $DCC_PATH/config
    echo 0x03D8E098 1 > $DCC_PATH/config
    echo 0x03D8E0A0 1 > $DCC_PATH/config
    echo 0x03D8E0A4 1 > $DCC_PATH/config
    echo 0x03D8E0A8 1 > $DCC_PATH/config
    echo 0x03D8E0B0 1 > $DCC_PATH/config
    echo 0x03D8E0B4 1 > $DCC_PATH/config
    echo 0x03D8E0B8 1 > $DCC_PATH/config
    echo 0x03D8E0C0 1 > $DCC_PATH/config
    echo 0x03D8E0C4 1 > $DCC_PATH/config
    echo 0x03D8E0C8 1 > $DCC_PATH/config
    echo 0x03D8E0D0 1 > $DCC_PATH/config
    echo 0x03D8E0D4 1 > $DCC_PATH/config
    echo 0x03D8E0D8 1 > $DCC_PATH/config
    echo 0x03D8E0E0 1 > $DCC_PATH/config
    echo 0x03D8E0E4 1 > $DCC_PATH/config
    echo 0x03D8E0E8 1 > $DCC_PATH/config
    echo 0x03D8E0F0 1 > $DCC_PATH/config
    echo 0x03D8E0F4 1 > $DCC_PATH/config
    echo 0x03D8E0F8 1 > $DCC_PATH/config
    echo 0x03D8E100 1 > $DCC_PATH/config
    echo 0x03D8E104 1 > $DCC_PATH/config
    echo 0x03D8E108 1 > $DCC_PATH/config
    echo 0x03D8E10C 1 > $DCC_PATH/config
    echo 0x03D8E110 1 > $DCC_PATH/config
    echo 0x03D8E114 1 > $DCC_PATH/config
    echo 0x03D8E118 1 > $DCC_PATH/config
    echo 0x03D8E11C 1 > $DCC_PATH/config
    echo 0x03D8EC00 1 > $DCC_PATH/config
    echo 0x03D8EC04 1 > $DCC_PATH/config
    echo 0x03D8EC08 1 > $DCC_PATH/config
    echo 0x03D8EC0C 1 > $DCC_PATH/config
    echo 0x03D8EC10 1 > $DCC_PATH/config
    echo 0x03D8EC14 1 > $DCC_PATH/config
    echo 0x03D8EC18 1 > $DCC_PATH/config
    echo 0x03D8EC1C 1 > $DCC_PATH/config
    echo 0x03D8EC20 1 > $DCC_PATH/config
    echo 0x03D8EC24 1 > $DCC_PATH/config
    echo 0x03D8EC28 1 > $DCC_PATH/config
    echo 0x03D8EC2C 1 > $DCC_PATH/config
    echo 0x03D8EC30 1 > $DCC_PATH/config
    echo 0x03D8EC34 1 > $DCC_PATH/config
    echo 0x03D8EC38 1 > $DCC_PATH/config
    echo 0x03D8EC40 1 > $DCC_PATH/config
    echo 0x03D8EC44 1 > $DCC_PATH/config
    echo 0x03D8EC48 1 > $DCC_PATH/config
    echo 0x03D8EC4C 1 > $DCC_PATH/config
    echo 0x03D8EC50 1 > $DCC_PATH/config
    echo 0x03D8EC54 1 > $DCC_PATH/config
    echo 0x03D8EC58 1 > $DCC_PATH/config
    echo 0x03D8EC80 1 > $DCC_PATH/config
    echo 0x03D8EC84 1 > $DCC_PATH/config
    echo 0x03D8ECA0 1 > $DCC_PATH/config
    echo 0x03D8ECC0 1 > $DCC_PATH/config
    echo 0x03D8EFF0 1 > $DCC_PATH/config
    echo 0x03D8EFF4 1 > $DCC_PATH/config
    echo 0x03D8F000 1 > $DCC_PATH/config
    echo 0x03D7D000 1 > $DCC_PATH/config
    echo 0x03D7D004 1 > $DCC_PATH/config
    echo 0x03D7D008 1 > $DCC_PATH/config
    echo 0x03D7D00C 1 > $DCC_PATH/config
    echo 0x03D7D010 1 > $DCC_PATH/config
    echo 0x03D7D014 1 > $DCC_PATH/config
    echo 0x03D7D018 1 > $DCC_PATH/config
    echo 0x03D7D01C 1 > $DCC_PATH/config
    echo 0x03D7D020 1 > $DCC_PATH/config
    echo 0x03D7D024 1 > $DCC_PATH/config
    echo 0x03D7D028 1 > $DCC_PATH/config
    echo 0x03D7D02C 1 > $DCC_PATH/config
    echo 0x03D7D03C 1 > $DCC_PATH/config
    echo 0x03D7D040 1 > $DCC_PATH/config
    echo 0x03D7D044 1 > $DCC_PATH/config
    echo 0x03D7D048 1 > $DCC_PATH/config
    echo 0x03D7D400 1 > $DCC_PATH/config
    echo 0x03D7D41C 1 > $DCC_PATH/config
    echo 0x03D7D420 1 > $DCC_PATH/config
    echo 0x03D7D424 1 > $DCC_PATH/config
    echo 0x03D7D428 1 > $DCC_PATH/config
    echo 0x03D7D42C 1 > $DCC_PATH/config
    echo 0x03D7DC00 1 > $DCC_PATH/config
    echo 0x03D7DC04 1 > $DCC_PATH/config
    echo 0x03D7DC10 1 > $DCC_PATH/config
    echo 0x03D7DC14 1 > $DCC_PATH/config
    echo 0x03D7DC18 1 > $DCC_PATH/config
    echo 0x03D7DC20 1 > $DCC_PATH/config
    echo 0x03D7DC24 1 > $DCC_PATH/config
    echo 0x03D7DC30 1 > $DCC_PATH/config
    echo 0x03D7DC34 1 > $DCC_PATH/config
    echo 0x03D7DC40 1 > $DCC_PATH/config
    echo 0x03D7DC44 1 > $DCC_PATH/config
    echo 0x03D7DC4C 1 > $DCC_PATH/config
    echo 0x03D7DC50 1 > $DCC_PATH/config
    echo 0x03D7DC54 1 > $DCC_PATH/config
    echo 0x03D7DC58 1 > $DCC_PATH/config
    echo 0x03D7DC80 1 > $DCC_PATH/config
    echo 0x03D7DC84 1 > $DCC_PATH/config
    echo 0x03D7DC88 1 > $DCC_PATH/config
    echo 0x03D7DC8C 1 > $DCC_PATH/config
    echo 0x03D7DC90 1 > $DCC_PATH/config
    echo 0x03D7DCA4 1 > $DCC_PATH/config
    echo 0x03D7DCC0 1 > $DCC_PATH/config
    echo 0x03D7DCC4 1 > $DCC_PATH/config
    echo 0x03D7DCC8 1 > $DCC_PATH/config
    echo 0x03D7DCCC 1 > $DCC_PATH/config
    echo 0x03D7DCD0 1 > $DCC_PATH/config
    echo 0x03D7DCD4 1 > $DCC_PATH/config
    echo 0x03D7DCD8 1 > $DCC_PATH/config
    echo 0x03D7DCDC 1 > $DCC_PATH/config
    echo 0x03D7DCE0 1 > $DCC_PATH/config
    echo 0x03D7DCE4 1 > $DCC_PATH/config
    echo 0x03D7DCE8 1 > $DCC_PATH/config
    echo 0x03D7DCEC 1 > $DCC_PATH/config
    echo 0x03D7DCF0 1 > $DCC_PATH/config
    echo 0x03D7DCF4 1 > $DCC_PATH/config
    echo 0x03D7DCF8 1 > $DCC_PATH/config
    echo 0x03D7DCFC 1 > $DCC_PATH/config
    echo 0x03D7DD00 1 > $DCC_PATH/config
    echo 0x03D7DD04 1 > $DCC_PATH/config
    echo 0x03D7DD08 1 > $DCC_PATH/config
    echo 0x03D7DD0C 1 > $DCC_PATH/config
    echo 0x03D7DD10 1 > $DCC_PATH/config
    echo 0x03D7DD14 1 > $DCC_PATH/config
    echo 0x03D7DD18 1 > $DCC_PATH/config
    echo 0x03D7DD1C 1 > $DCC_PATH/config
    echo 0x03D7DD80 1 > $DCC_PATH/config
    echo 0x03D7DD84 1 > $DCC_PATH/config
    echo 0x03D7DD90 1 > $DCC_PATH/config
    echo 0x03D7DD94 1 > $DCC_PATH/config
    echo 0x03D7DD98 1 > $DCC_PATH/config
    echo 0x03D7DD9C 1 > $DCC_PATH/config
    echo 0x03D7DDA0 1 > $DCC_PATH/config
    echo 0x03D7DDA4 1 > $DCC_PATH/config
    echo 0x03D7DDA8 1 > $DCC_PATH/config
    echo 0x03D7DDAC 1 > $DCC_PATH/config
    echo 0x03D7E000 1 > $DCC_PATH/config
    echo 0x03D7E004 1 > $DCC_PATH/config
    echo 0x03D7E008 1 > $DCC_PATH/config
    echo 0x03D7E00C 1 > $DCC_PATH/config
    echo 0x03D7E010 1 > $DCC_PATH/config
    echo 0x03D7E01C 1 > $DCC_PATH/config
    echo 0x03D7E020 1 > $DCC_PATH/config
    echo 0x03D7E02C 1 > $DCC_PATH/config
    echo 0x03D7E030 1 > $DCC_PATH/config
    echo 0x03D7E03C 1 > $DCC_PATH/config
    echo 0x03D7E040 1 > $DCC_PATH/config
    echo 0x03D7E044 1 > $DCC_PATH/config
    echo 0x03D7E048 1 > $DCC_PATH/config
    echo 0x03D7E04C 1 > $DCC_PATH/config
    echo 0x03D7E050 1 > $DCC_PATH/config
    echo 0x03D7E054 1 > $DCC_PATH/config
    echo 0x03D7E058 1 > $DCC_PATH/config
    echo 0x03D7E05C 1 > $DCC_PATH/config
    echo 0x03D7E060 1 > $DCC_PATH/config
    echo 0x03D7E064 1 > $DCC_PATH/config
    echo 0x03D7E068 1 > $DCC_PATH/config
    echo 0x03D7E06C 1 > $DCC_PATH/config
    echo 0x03D7E070 1 > $DCC_PATH/config
    echo 0x03D7E090 1 > $DCC_PATH/config
    echo 0x03D7E094 1 > $DCC_PATH/config
    echo 0x03D7E098 1 > $DCC_PATH/config
    echo 0x03D7E09C 1 > $DCC_PATH/config
    echo 0x03D7E0A0 1 > $DCC_PATH/config
    echo 0x03D7E0A4 1 > $DCC_PATH/config
    echo 0x03D7E0A8 1 > $DCC_PATH/config
    echo 0x03D7E0B4 1 > $DCC_PATH/config
    echo 0x03D7E0B8 1 > $DCC_PATH/config
    echo 0x03D7E0BC 1 > $DCC_PATH/config
    echo 0x03D7E0C0 1 > $DCC_PATH/config
    echo 0x03D7E100 1 > $DCC_PATH/config
    echo 0x03D7E104 1 > $DCC_PATH/config
    echo 0x03D7E108 1 > $DCC_PATH/config
    echo 0x03D7E10C 1 > $DCC_PATH/config
    echo 0x03D7E110 1 > $DCC_PATH/config
    echo 0x03D7E114 1 > $DCC_PATH/config
    echo 0x03D7E118 1 > $DCC_PATH/config
    echo 0x03D7E11C 1 > $DCC_PATH/config
    echo 0x03D7E120 1 > $DCC_PATH/config
    echo 0x03D7E124 1 > $DCC_PATH/config
    echo 0x03D7E128 1 > $DCC_PATH/config
    echo 0x03D7E12C 1 > $DCC_PATH/config
    echo 0x03D7E130 1 > $DCC_PATH/config
    echo 0x03D7E134 1 > $DCC_PATH/config
    echo 0x03D7E138 1 > $DCC_PATH/config
    echo 0x03D7E13C 1 > $DCC_PATH/config
    echo 0x03D7E140 1 > $DCC_PATH/config
    echo 0x03D7E144 1 > $DCC_PATH/config
    echo 0x03D7E148 1 > $DCC_PATH/config
    echo 0x03D7E14C 1 > $DCC_PATH/config
    echo 0x03D7E180 1 > $DCC_PATH/config
    echo 0x03D7E188 1 > $DCC_PATH/config
    echo 0x03D7E18C 1 > $DCC_PATH/config
    echo 0x03D7E190 1 > $DCC_PATH/config
    echo 0x03D7E1A0 1 > $DCC_PATH/config
    echo 0x03D7E1C0 1 > $DCC_PATH/config
    echo 0x03D7E1C4 1 > $DCC_PATH/config
    echo 0x03D7E1C8 1 > $DCC_PATH/config
    echo 0x03D7E1CC 1 > $DCC_PATH/config
    echo 0x03D7E1D0 1 > $DCC_PATH/config
    echo 0x03D7E1D4 1 > $DCC_PATH/config
    echo 0x03D7E1D8 1 > $DCC_PATH/config
    echo 0x03D7E1DC 1 > $DCC_PATH/config
    echo 0x03D7E1E0 1 > $DCC_PATH/config
    echo 0x03D7E1E4 1 > $DCC_PATH/config
    echo 0x03D7E1FC 1 > $DCC_PATH/config
    echo 0x03D7E21C 1 > $DCC_PATH/config
    echo 0x03D7E220 1 > $DCC_PATH/config
    echo 0x03D7E224 1 > $DCC_PATH/config
    echo 0x03D7E240 1 > $DCC_PATH/config
    echo 0x03D7E244 1 > $DCC_PATH/config
    echo 0x03D7E248 1 > $DCC_PATH/config
    echo 0x03D7E250 1 > $DCC_PATH/config
    echo 0x03D7E254 1 > $DCC_PATH/config
    echo 0x03D7E258 1 > $DCC_PATH/config
    echo 0x03D7E280 1 > $DCC_PATH/config
    echo 0x03D7E284 1 > $DCC_PATH/config
    echo 0x03D7E288 1 > $DCC_PATH/config
    echo 0x03D7E290 1 > $DCC_PATH/config
    echo 0x03D7E294 1 > $DCC_PATH/config
    echo 0x03D7E298 1 > $DCC_PATH/config
    echo 0x03D7E29C 1 > $DCC_PATH/config
    echo 0x03D7E2A0 1 > $DCC_PATH/config
    echo 0x03D7E2A4 1 > $DCC_PATH/config
    echo 0x03D7E2A8 1 > $DCC_PATH/config
    echo 0x03D7E2AC 1 > $DCC_PATH/config
    echo 0x03D7E2B0 1 > $DCC_PATH/config
    echo 0x03D7E2B4 1 > $DCC_PATH/config
    echo 0x03D7E2B8 1 > $DCC_PATH/config
    echo 0x03D7E2BC 1 > $DCC_PATH/config
    echo 0x03D7E2E0 1 > $DCC_PATH/config
    echo 0x03D7E2E4 1 > $DCC_PATH/config
    echo 0x03D7E300 1 > $DCC_PATH/config
    echo 0x03D7E304 1 > $DCC_PATH/config
    echo 0x03D7E30C 1 > $DCC_PATH/config
    echo 0x03D7E310 1 > $DCC_PATH/config
    echo 0x03D7E340 1 > $DCC_PATH/config
    echo 0x03D7E3B0 1 > $DCC_PATH/config
    echo 0x03D7E3C0 1 > $DCC_PATH/config
    echo 0x03D7E3C4 1 > $DCC_PATH/config
    echo 0x03D7E440 1 > $DCC_PATH/config
    echo 0x03D7E444 1 > $DCC_PATH/config
    echo 0x03D7E448 1 > $DCC_PATH/config
    echo 0x03D7E44C 1 > $DCC_PATH/config
    echo 0x03D7E450 1 > $DCC_PATH/config
    echo 0x03D7E454 1 > $DCC_PATH/config
    echo 0x03D7E458 1 > $DCC_PATH/config
    echo 0x03D7E45C 1 > $DCC_PATH/config
    echo 0x03D7E480 1 > $DCC_PATH/config
    echo 0x03D7E484 1 > $DCC_PATH/config
    echo 0x03D7E488 1 > $DCC_PATH/config
    echo 0x03D7E490 1 > $DCC_PATH/config
    echo 0x03D7E494 1 > $DCC_PATH/config
    echo 0x03D7E498 1 > $DCC_PATH/config
    echo 0x03D7E4A0 1 > $DCC_PATH/config
    echo 0x03D7E4A4 1 > $DCC_PATH/config
    echo 0x03D7E4A8 1 > $DCC_PATH/config
    echo 0x03D7E4B0 1 > $DCC_PATH/config
    echo 0x03D7E4B4 1 > $DCC_PATH/config
    echo 0x03D7E4B8 1 > $DCC_PATH/config
    echo 0x03D7E500 1 > $DCC_PATH/config
    echo 0x03D7E508 1 > $DCC_PATH/config
    echo 0x03D7E50C 1 > $DCC_PATH/config
    echo 0x03D7E510 1 > $DCC_PATH/config
    echo 0x03D7E520 1 > $DCC_PATH/config
    echo 0x03D7E524 1 > $DCC_PATH/config
    echo 0x03D7E528 1 > $DCC_PATH/config
    echo 0x03D7E53C 1 > $DCC_PATH/config
    echo 0x03D7E540 1 > $DCC_PATH/config
    echo 0x03D7E544 1 > $DCC_PATH/config
    echo 0x03D7E550 1 > $DCC_PATH/config
    echo 0x03D7E554 1 > $DCC_PATH/config
    echo 0x03D7E560 1 > $DCC_PATH/config
    echo 0x03D7E564 1 > $DCC_PATH/config
    echo 0x03D7E568 1 > $DCC_PATH/config
    echo 0x03D7E56C 1 > $DCC_PATH/config
    echo 0x03D7E574 1 > $DCC_PATH/config
    echo 0x03D7E588 1 > $DCC_PATH/config
    echo 0x03D7E58C 1 > $DCC_PATH/config
    echo 0x03D7E590 1 > $DCC_PATH/config
    echo 0x03D7E594 1 > $DCC_PATH/config
    echo 0x03D7E598 1 > $DCC_PATH/config
    echo 0x03D7E59C 1 > $DCC_PATH/config
    echo 0x03D7E5A0 1 > $DCC_PATH/config
    echo 0x03D7E5A4 1 > $DCC_PATH/config
    echo 0x03D7E5A8 1 > $DCC_PATH/config
    echo 0x03D7E5AC 1 > $DCC_PATH/config
    echo 0x03D7E5C0 1 > $DCC_PATH/config
    echo 0x03D7E5C4 1 > $DCC_PATH/config
    echo 0x03D7E5C8 1 > $DCC_PATH/config
    echo 0x03D7E5CC 1 > $DCC_PATH/config
    echo 0x03D7E5D0 1 > $DCC_PATH/config
    echo 0x03D7E5D4 1 > $DCC_PATH/config
    echo 0x03D7E5D8 1 > $DCC_PATH/config
    echo 0x03D7E5DC 1 > $DCC_PATH/config
    echo 0x03D7E5E0 1 > $DCC_PATH/config
    echo 0x03D7E5E4 1 > $DCC_PATH/config
    echo 0x03D7E5F0 1 > $DCC_PATH/config
    echo 0x03D7E600 1 > $DCC_PATH/config
    echo 0x03D7E604 1 > $DCC_PATH/config
    echo 0x03D7E610 1 > $DCC_PATH/config
    echo 0x03D7E614 1 > $DCC_PATH/config
    echo 0x03D7E618 1 > $DCC_PATH/config
    echo 0x03D7E640 1 > $DCC_PATH/config
    echo 0x03D7E644 1 > $DCC_PATH/config
    echo 0x03D7E648 1 > $DCC_PATH/config
    echo 0x03D7E64C 1 > $DCC_PATH/config
    echo 0x03D7E650 1 > $DCC_PATH/config
    echo 0x03D7E654 1 > $DCC_PATH/config
    echo 0x03D7E658 1 > $DCC_PATH/config
    echo 0x03D7E65C 1 > $DCC_PATH/config
    echo 0x03D7E660 1 > $DCC_PATH/config
    echo 0x03D7E664 1 > $DCC_PATH/config
    echo 0x03D7E668 1 > $DCC_PATH/config
    echo 0x03D7E66C 1 > $DCC_PATH/config
    echo 0x03D7E670 1 > $DCC_PATH/config
    echo 0x03D7E674 1 > $DCC_PATH/config
    echo 0x03D7E678 1 > $DCC_PATH/config
    echo 0x03D7E700 1 > $DCC_PATH/config
    echo 0x03D7E714 1 > $DCC_PATH/config
    echo 0x03D7E718 1 > $DCC_PATH/config
    echo 0x03D7E71C 1 > $DCC_PATH/config
    echo 0x03D7E720 1 > $DCC_PATH/config
    echo 0x03D7E724 1 > $DCC_PATH/config
    echo 0x03D7E728 1 > $DCC_PATH/config
    echo 0x03D7E72C 1 > $DCC_PATH/config
    echo 0x03D7E730 1 > $DCC_PATH/config
    echo 0x03D7E734 1 > $DCC_PATH/config
    echo 0x03D7E738 1 > $DCC_PATH/config
    echo 0x03D7E73C 1 > $DCC_PATH/config
    echo 0x03D7E740 1 > $DCC_PATH/config
    echo 0x03D7E744 1 > $DCC_PATH/config
    echo 0x03D7E748 1 > $DCC_PATH/config
    echo 0x03D7E74C 1 > $DCC_PATH/config
    echo 0x03D7E750 1 > $DCC_PATH/config
    echo 0x03D7E7C0 1 > $DCC_PATH/config
    echo 0x03D7E7C4 1 > $DCC_PATH/config
    echo 0x03D7E7E0 1 > $DCC_PATH/config
    echo 0x03D7E7E4 1 > $DCC_PATH/config
    echo 0x03D7E7E8 1 > $DCC_PATH/config
    echo 0x03D7E7F0 1 > $DCC_PATH/config
    echo 0x03D7E800 1 > $DCC_PATH/config
    echo 0x03D7E804 1 > $DCC_PATH/config
    echo 0x03D7E808 1 > $DCC_PATH/config
    echo 0x03D7E80C 1 > $DCC_PATH/config
    echo 0x03D80000 1 > $DCC_PATH/config
    echo 0x03D80004 1 > $DCC_PATH/config
    echo 0x03D80008 1 > $DCC_PATH/config
    echo 0x03D8000C 1 > $DCC_PATH/config
    echo 0x03D80010 1 > $DCC_PATH/config
    echo 0x03D80014 1 > $DCC_PATH/config
    echo 0x03D80018 1 > $DCC_PATH/config
    echo 0x03D8001C 1 > $DCC_PATH/config
    echo 0x03D80020 1 > $DCC_PATH/config
    echo 0x03D80024 1 > $DCC_PATH/config
    echo 0x03D80028 1 > $DCC_PATH/config
    echo 0x03D8002C 1 > $DCC_PATH/config
    echo 0x03D80030 1 > $DCC_PATH/config
    echo 0x03D80034 1 > $DCC_PATH/config
    echo 0x03D80038 1 > $DCC_PATH/config
    echo 0x03D8003C 1 > $DCC_PATH/config
    echo 0x03D80040 1 > $DCC_PATH/config
    echo 0x03D80044 1 > $DCC_PATH/config
    echo 0x03D80048 1 > $DCC_PATH/config
    echo 0x03D80060 1 > $DCC_PATH/config
    echo 0x03D80068 1 > $DCC_PATH/config
    echo 0x03D80080 1 > $DCC_PATH/config
    echo 0x03D80084 1 > $DCC_PATH/config
    echo 0x03D80090 1 > $DCC_PATH/config
    echo 0x03D800C0 1 > $DCC_PATH/config
    echo 0x03D800C4 1 > $DCC_PATH/config
    echo 0x03D800D0 1 > $DCC_PATH/config
    echo 0x03D800D4 1 > $DCC_PATH/config
    echo 0x03D800D8 1 > $DCC_PATH/config
    echo 0x03D81000 1 > $DCC_PATH/config
    echo 0x03D81010 1 > $DCC_PATH/config
    echo 0x03D81020 1 > $DCC_PATH/config
    echo 0x03D81024 1 > $DCC_PATH/config
    echo 0x03D81028 1 > $DCC_PATH/config
    echo 0x03D8102C 1 > $DCC_PATH/config
    echo 0x03D81030 1 > $DCC_PATH/config
    echo 0x03D81034 1 > $DCC_PATH/config
    echo 0x03D81038 1 > $DCC_PATH/config
    echo 0x03D8103C 1 > $DCC_PATH/config
    echo 0x03D81040 1 > $DCC_PATH/config
    echo 0x03D81044 1 > $DCC_PATH/config
    echo 0x03D81048 1 > $DCC_PATH/config
    echo 0x03D69000 1 > $DCC_PATH/config
    echo 0x03D69004 1 > $DCC_PATH/config
    echo 0x03D69008 1 > $DCC_PATH/config
    echo 0x03D6900C 1 > $DCC_PATH/config
    echo 0x03D69010 1 > $DCC_PATH/config
    echo 0x03D69014 1 > $DCC_PATH/config
    echo 0x03D69018 1 > $DCC_PATH/config
    echo 0x03D6901C 1 > $DCC_PATH/config
    echo 0x03D69020 1 > $DCC_PATH/config
    echo 0x03D69024 1 > $DCC_PATH/config
    echo 0x03D69028 1 > $DCC_PATH/config
    echo 0x03D6902C 1 > $DCC_PATH/config
    echo 0x03D69030 1 > $DCC_PATH/config
    echo 0x03D69034 1 > $DCC_PATH/config
    echo 0x03D69038 1 > $DCC_PATH/config
    echo 0x03D6903C 1 > $DCC_PATH/config
    echo 0x03D69040 1 > $DCC_PATH/config
    echo 0x03D69044 1 > $DCC_PATH/config
    echo 0x03D69048 1 > $DCC_PATH/config
    echo 0x03D6904C 1 > $DCC_PATH/config
    echo 0x03D69050 1 > $DCC_PATH/config
    echo 0x03D69054 1 > $DCC_PATH/config
    echo 0x03D69058 1 > $DCC_PATH/config
    echo 0x03D6905C 1 > $DCC_PATH/config
    echo 0x03D69060 1 > $DCC_PATH/config
    echo 0x03D69064 1 > $DCC_PATH/config
    echo 0x03D69068 1 > $DCC_PATH/config
    echo 0x03D6906C 1 > $DCC_PATH/config
    echo 0x03D69070 1 > $DCC_PATH/config
    echo 0x03D69074 1 > $DCC_PATH/config
    echo 0x03D69078 1 > $DCC_PATH/config
    echo 0x03D6907C 1 > $DCC_PATH/config
    echo 0x03D69100 1 > $DCC_PATH/config
    echo 0x03D69104 1 > $DCC_PATH/config
    echo 0x03D69108 1 > $DCC_PATH/config
    echo 0x03D6910C 1 > $DCC_PATH/config
    echo 0x03D69110 1 > $DCC_PATH/config
    echo 0x03D69114 1 > $DCC_PATH/config
    echo 0x03D69118 1 > $DCC_PATH/config
    echo 0x03D6911C 1 > $DCC_PATH/config
    echo 0x03D69120 1 > $DCC_PATH/config
    echo 0x03D69124 1 > $DCC_PATH/config
    echo 0x03D69128 1 > $DCC_PATH/config
    echo 0x03D6912C 1 > $DCC_PATH/config
    echo 0x03D69130 1 > $DCC_PATH/config
    echo 0x03D69134 1 > $DCC_PATH/config
    echo 0x03D69138 1 > $DCC_PATH/config
    echo 0x03D6913C 1 > $DCC_PATH/config
    echo 0x03D69140 1 > $DCC_PATH/config
    echo 0x03D69144 1 > $DCC_PATH/config
    echo 0x03D69148 1 > $DCC_PATH/config
    echo 0x03D6914C 1 > $DCC_PATH/config
    echo 0x03D69150 1 > $DCC_PATH/config
    echo 0x03D69154 1 > $DCC_PATH/config
    echo 0x03D69158 1 > $DCC_PATH/config
    echo 0x03D6915C 1 > $DCC_PATH/config
    echo 0x03D69160 1 > $DCC_PATH/config
    echo 0x03D69164 1 > $DCC_PATH/config
    echo 0x03D69168 1 > $DCC_PATH/config
    echo 0x03D6916C 1 > $DCC_PATH/config
    echo 0x03D69170 1 > $DCC_PATH/config
    echo 0x03D69174 1 > $DCC_PATH/config
    echo 0x03D69178 1 > $DCC_PATH/config
    echo 0x03D6917C 1 > $DCC_PATH/config
    echo 0x03D69200 1 > $DCC_PATH/config
    echo 0x03D69204 1 > $DCC_PATH/config
    echo 0x03D69208 1 > $DCC_PATH/config
    echo 0x03D6920C 1 > $DCC_PATH/config
    echo 0x03D69210 1 > $DCC_PATH/config
    echo 0x03D69214 1 > $DCC_PATH/config
    echo 0x03D69218 1 > $DCC_PATH/config
    echo 0x03D6921C 1 > $DCC_PATH/config
    echo 0x03D69220 1 > $DCC_PATH/config
    echo 0x03D69224 1 > $DCC_PATH/config
    echo 0x03D69228 1 > $DCC_PATH/config
    echo 0x03D6922C 1 > $DCC_PATH/config
    echo 0x03D69230 1 > $DCC_PATH/config
    echo 0x03D69234 1 > $DCC_PATH/config
    echo 0x03D69238 1 > $DCC_PATH/config
    echo 0x03D6923C 1 > $DCC_PATH/config
    echo 0x03D69240 1 > $DCC_PATH/config
    echo 0x03D69244 1 > $DCC_PATH/config
    echo 0x03D69248 1 > $DCC_PATH/config
    echo 0x03D6924C 1 > $DCC_PATH/config
    echo 0x03D69250 1 > $DCC_PATH/config
    echo 0x03D69254 1 > $DCC_PATH/config
    echo 0x03D69258 1 > $DCC_PATH/config
    echo 0x03D6925C 1 > $DCC_PATH/config
    echo 0x03D69260 1 > $DCC_PATH/config
    echo 0x03D69264 1 > $DCC_PATH/config
    echo 0x03D69268 1 > $DCC_PATH/config
    echo 0x03D6926C 1 > $DCC_PATH/config
    echo 0x03D69270 1 > $DCC_PATH/config
    echo 0x03D69274 1 > $DCC_PATH/config
    echo 0x03D69278 1 > $DCC_PATH/config
    echo 0x03D6927C 1 > $DCC_PATH/config
    echo 0x03D69300 1 > $DCC_PATH/config
    echo 0x03D69304 1 > $DCC_PATH/config
    echo 0x03D69308 1 > $DCC_PATH/config
    echo 0x03D6930C 1 > $DCC_PATH/config
    echo 0x03D69310 1 > $DCC_PATH/config
    echo 0x03D69314 1 > $DCC_PATH/config
    echo 0x03D69318 1 > $DCC_PATH/config
    echo 0x03D6931C 1 > $DCC_PATH/config
    echo 0x03D69320 1 > $DCC_PATH/config
    echo 0x03D69324 1 > $DCC_PATH/config
    echo 0x03D69328 1 > $DCC_PATH/config
    echo 0x03D6932C 1 > $DCC_PATH/config
    echo 0x03D69330 1 > $DCC_PATH/config
    echo 0x03D69334 1 > $DCC_PATH/config
    echo 0x03D69338 1 > $DCC_PATH/config
    echo 0x03D6933C 1 > $DCC_PATH/config
    echo 0x03D69340 1 > $DCC_PATH/config
    echo 0x03D69344 1 > $DCC_PATH/config
    echo 0x03D69348 1 > $DCC_PATH/config
    echo 0x03D6934C 1 > $DCC_PATH/config
    echo 0x03D69350 1 > $DCC_PATH/config
    echo 0x03D69354 1 > $DCC_PATH/config
    echo 0x03D69358 1 > $DCC_PATH/config
    echo 0x03D6935C 1 > $DCC_PATH/config
    echo 0x03D69360 1 > $DCC_PATH/config
    echo 0x03D69364 1 > $DCC_PATH/config
    echo 0x03D69368 1 > $DCC_PATH/config
    echo 0x03D6936C 1 > $DCC_PATH/config
    echo 0x03D69370 1 > $DCC_PATH/config
    echo 0x03D69374 1 > $DCC_PATH/config
    echo 0x03D69378 1 > $DCC_PATH/config
    echo 0x03D6937C 1 > $DCC_PATH/config
    echo 0x03D69400 1 > $DCC_PATH/config
    echo 0x03D69404 1 > $DCC_PATH/config
    echo 0x03D69408 1 > $DCC_PATH/config
    echo 0x03D6940C 1 > $DCC_PATH/config
    echo 0x03D69410 1 > $DCC_PATH/config
    echo 0x03D69414 1 > $DCC_PATH/config
    echo 0x03D69418 1 > $DCC_PATH/config
    echo 0x03D6941C 1 > $DCC_PATH/config
    echo 0x03D69420 1 > $DCC_PATH/config
    echo 0x03D69424 1 > $DCC_PATH/config
    echo 0x03D69428 1 > $DCC_PATH/config
    echo 0x03D6942C 1 > $DCC_PATH/config
    echo 0x03D69430 1 > $DCC_PATH/config
    echo 0x03D69434 1 > $DCC_PATH/config
    echo 0x03D69438 1 > $DCC_PATH/config
    echo 0x03D6943C 1 > $DCC_PATH/config
    echo 0x03D69440 1 > $DCC_PATH/config
    echo 0x03D69444 1 > $DCC_PATH/config
    echo 0x03D69448 1 > $DCC_PATH/config
    echo 0x03D6944C 1 > $DCC_PATH/config
    echo 0x03D69450 1 > $DCC_PATH/config
    echo 0x03D69454 1 > $DCC_PATH/config
    echo 0x03D69458 1 > $DCC_PATH/config
    echo 0x03D6945C 1 > $DCC_PATH/config
    echo 0x03D69460 1 > $DCC_PATH/config
    echo 0x03D69464 1 > $DCC_PATH/config
    echo 0x03D69468 1 > $DCC_PATH/config
    echo 0x03D6946C 1 > $DCC_PATH/config
    echo 0x03D69470 1 > $DCC_PATH/config
    echo 0x03D69474 1 > $DCC_PATH/config
    echo 0x03D69478 1 > $DCC_PATH/config
    echo 0x03D6947C 1 > $DCC_PATH/config
    echo 0x03D69500 1 > $DCC_PATH/config
    echo 0x03D69504 1 > $DCC_PATH/config
    echo 0x03D69508 1 > $DCC_PATH/config
    echo 0x03D6950C 1 > $DCC_PATH/config
    echo 0x03D69510 1 > $DCC_PATH/config
    echo 0x03D69514 1 > $DCC_PATH/config
    echo 0x03D69518 1 > $DCC_PATH/config
    echo 0x03D6951C 1 > $DCC_PATH/config
    echo 0x03D69520 1 > $DCC_PATH/config
    echo 0x03D69524 1 > $DCC_PATH/config
    echo 0x03D69528 1 > $DCC_PATH/config
    echo 0x03D6952C 1 > $DCC_PATH/config
    echo 0x03D69530 1 > $DCC_PATH/config
    echo 0x03D69534 1 > $DCC_PATH/config
    echo 0x03D69538 1 > $DCC_PATH/config
    echo 0x03D6953C 1 > $DCC_PATH/config
    echo 0x03D69540 1 > $DCC_PATH/config
    echo 0x03D69544 1 > $DCC_PATH/config
    echo 0x03D69548 1 > $DCC_PATH/config
    echo 0x03D6954C 1 > $DCC_PATH/config
    echo 0x03D69550 1 > $DCC_PATH/config
    echo 0x03D69554 1 > $DCC_PATH/config
    echo 0x03D69558 1 > $DCC_PATH/config
    echo 0x03D6955C 1 > $DCC_PATH/config
    echo 0x03D69560 1 > $DCC_PATH/config
    echo 0x03D69564 1 > $DCC_PATH/config
    echo 0x03D69568 1 > $DCC_PATH/config
    echo 0x03D6956C 1 > $DCC_PATH/config
    echo 0x03D69570 1 > $DCC_PATH/config
    echo 0x03D69574 1 > $DCC_PATH/config
    echo 0x03D69578 1 > $DCC_PATH/config
    echo 0x03D6957C 1 > $DCC_PATH/config
    echo 0x03D69600 1 > $DCC_PATH/config
    echo 0x03D69604 1 > $DCC_PATH/config
    echo 0x03D69608 1 > $DCC_PATH/config
    echo 0x03D6960C 1 > $DCC_PATH/config
    echo 0x03D69610 1 > $DCC_PATH/config
    echo 0x03D69614 1 > $DCC_PATH/config
    echo 0x03D69618 1 > $DCC_PATH/config
    echo 0x03D6961C 1 > $DCC_PATH/config
    echo 0x03D69620 1 > $DCC_PATH/config
    echo 0x03D69624 1 > $DCC_PATH/config
    echo 0x03D69628 1 > $DCC_PATH/config
    echo 0x03D6962C 1 > $DCC_PATH/config
    echo 0x03D69630 1 > $DCC_PATH/config
    echo 0x03D69634 1 > $DCC_PATH/config
    echo 0x03D69638 1 > $DCC_PATH/config
    echo 0x03D6963C 1 > $DCC_PATH/config
    echo 0x03D69640 1 > $DCC_PATH/config
    echo 0x03D69644 1 > $DCC_PATH/config
    echo 0x03D69648 1 > $DCC_PATH/config
    echo 0x03D6964C 1 > $DCC_PATH/config
    echo 0x03D69650 1 > $DCC_PATH/config
    echo 0x03D69654 1 > $DCC_PATH/config
    echo 0x03D69658 1 > $DCC_PATH/config
    echo 0x03D6965C 1 > $DCC_PATH/config
    echo 0x03D69660 1 > $DCC_PATH/config
    echo 0x03D69664 1 > $DCC_PATH/config
    echo 0x03D69668 1 > $DCC_PATH/config
    echo 0x03D6966C 1 > $DCC_PATH/config
    echo 0x03D69670 1 > $DCC_PATH/config
    echo 0x03D69674 1 > $DCC_PATH/config
    echo 0x03D69678 1 > $DCC_PATH/config
    echo 0x03D6967C 1 > $DCC_PATH/config
    echo 0x03D69700 1 > $DCC_PATH/config
    echo 0x03D69704 1 > $DCC_PATH/config
    echo 0x03D69708 1 > $DCC_PATH/config
    echo 0x03D6970C 1 > $DCC_PATH/config
    echo 0x03D69710 1 > $DCC_PATH/config
    echo 0x03D69714 1 > $DCC_PATH/config
    echo 0x03D69718 1 > $DCC_PATH/config
    echo 0x03D6971C 1 > $DCC_PATH/config
    echo 0x03D69720 1 > $DCC_PATH/config
    echo 0x03D69724 1 > $DCC_PATH/config
    echo 0x03D69728 1 > $DCC_PATH/config
    echo 0x03D6972C 1 > $DCC_PATH/config
    echo 0x03D69730 1 > $DCC_PATH/config
    echo 0x03D69734 1 > $DCC_PATH/config
    echo 0x03D69738 1 > $DCC_PATH/config
    echo 0x03D6973C 1 > $DCC_PATH/config
    echo 0x03D69740 1 > $DCC_PATH/config
    echo 0x03D69744 1 > $DCC_PATH/config
    echo 0x03D69748 1 > $DCC_PATH/config
    echo 0x03D6974C 1 > $DCC_PATH/config
    echo 0x03D69750 1 > $DCC_PATH/config
    echo 0x03D69754 1 > $DCC_PATH/config
    echo 0x03D69758 1 > $DCC_PATH/config
    echo 0x03D6975C 1 > $DCC_PATH/config
    echo 0x03D69760 1 > $DCC_PATH/config
    echo 0x03D69764 1 > $DCC_PATH/config
    echo 0x03D69768 1 > $DCC_PATH/config
    echo 0x03D6976C 1 > $DCC_PATH/config
    echo 0x03D69770 1 > $DCC_PATH/config
    echo 0x03D69774 1 > $DCC_PATH/config
    echo 0x03D69778 1 > $DCC_PATH/config
    echo 0x03D6977C 1 > $DCC_PATH/config
    echo 0x03D69800 1 > $DCC_PATH/config
    echo 0x03D69804 1 > $DCC_PATH/config
    echo 0x03D69808 1 > $DCC_PATH/config
    echo 0x03D6980C 1 > $DCC_PATH/config
    echo 0x03D69810 1 > $DCC_PATH/config
    echo 0x03D69814 1 > $DCC_PATH/config
    echo 0x03D69818 1 > $DCC_PATH/config
    echo 0x03D6981C 1 > $DCC_PATH/config
    echo 0x03D69820 1 > $DCC_PATH/config
    echo 0x03D69824 1 > $DCC_PATH/config
    echo 0x03D69828 1 > $DCC_PATH/config
    echo 0x03D6982C 1 > $DCC_PATH/config
    echo 0x03D69830 1 > $DCC_PATH/config
    echo 0x03D69834 1 > $DCC_PATH/config
    echo 0x03D69838 1 > $DCC_PATH/config
    echo 0x03D6983C 1 > $DCC_PATH/config
    echo 0x03D69840 1 > $DCC_PATH/config
    echo 0x03D69844 1 > $DCC_PATH/config
    echo 0x03D69848 1 > $DCC_PATH/config
    echo 0x03D6984C 1 > $DCC_PATH/config
    echo 0x03D69850 1 > $DCC_PATH/config
    echo 0x03D69854 1 > $DCC_PATH/config
    echo 0x03D69858 1 > $DCC_PATH/config
    echo 0x03D6985C 1 > $DCC_PATH/config
    echo 0x03D69860 1 > $DCC_PATH/config
    echo 0x03D69864 1 > $DCC_PATH/config
    echo 0x03D69868 1 > $DCC_PATH/config
    echo 0x03D6986C 1 > $DCC_PATH/config
    echo 0x03D69870 1 > $DCC_PATH/config
    echo 0x03D69874 1 > $DCC_PATH/config
    echo 0x03D69878 1 > $DCC_PATH/config
    echo 0x03D6987C 1 > $DCC_PATH/config
    echo 0x03D69900 1 > $DCC_PATH/config
    echo 0x03D69904 1 > $DCC_PATH/config
    echo 0x03D69908 1 > $DCC_PATH/config
    echo 0x03D6990C 1 > $DCC_PATH/config
    echo 0x03D69910 1 > $DCC_PATH/config
    echo 0x03D69914 1 > $DCC_PATH/config
    echo 0x03D69918 1 > $DCC_PATH/config
    echo 0x03D6991C 1 > $DCC_PATH/config
    echo 0x03D69920 1 > $DCC_PATH/config
    echo 0x03D69924 1 > $DCC_PATH/config
    echo 0x03D69928 1 > $DCC_PATH/config
    echo 0x03D6992C 1 > $DCC_PATH/config
    echo 0x03D69930 1 > $DCC_PATH/config
    echo 0x03D69934 1 > $DCC_PATH/config
    echo 0x03D69938 1 > $DCC_PATH/config
    echo 0x03D6993C 1 > $DCC_PATH/config
    echo 0x03D69940 1 > $DCC_PATH/config
    echo 0x03D69944 1 > $DCC_PATH/config
    echo 0x03D69948 1 > $DCC_PATH/config
    echo 0x03D6994C 1 > $DCC_PATH/config
    echo 0x03D69950 1 > $DCC_PATH/config
    echo 0x03D69954 1 > $DCC_PATH/config
    echo 0x03D69958 1 > $DCC_PATH/config
    echo 0x03D6995C 1 > $DCC_PATH/config
    echo 0x03D69960 1 > $DCC_PATH/config
    echo 0x03D69964 1 > $DCC_PATH/config
    echo 0x03D69968 1 > $DCC_PATH/config
    echo 0x03D6996C 1 > $DCC_PATH/config
    echo 0x03D69970 1 > $DCC_PATH/config
    echo 0x03D69974 1 > $DCC_PATH/config
    echo 0x03D69978 1 > $DCC_PATH/config
    echo 0x03D6997C 1 > $DCC_PATH/config
    echo 0x03D69E00 1 > $DCC_PATH/config
    echo 0x03D69E04 1 > $DCC_PATH/config
    echo 0x03D69E0C 1 > $DCC_PATH/config
    echo 0x03D69E10 1 > $DCC_PATH/config
    echo 0x03D69E14 1 > $DCC_PATH/config
    echo 0x03D69E1C 1 > $DCC_PATH/config
    echo 0x03D69E20 1 > $DCC_PATH/config
    echo 0x03D69E24 1 > $DCC_PATH/config
    echo 0x03D69E2C 1 > $DCC_PATH/config
    echo 0x03D69E30 1 > $DCC_PATH/config
    echo 0x03D69E34 1 > $DCC_PATH/config
    echo 0x03D69E3C 1 > $DCC_PATH/config
    echo 0x03D69E40 1 > $DCC_PATH/config
    echo 0x03D69E44 1 > $DCC_PATH/config
    echo 0x03D69E4C 1 > $DCC_PATH/config
    echo 0x03D69E50 1 > $DCC_PATH/config
    echo 0x03D69E54 1 > $DCC_PATH/config
    echo 0x03D69E5C 1 > $DCC_PATH/config
    echo 0x03D69E60 1 > $DCC_PATH/config
    echo 0x03D69E64 1 > $DCC_PATH/config
    echo 0x03D69E6C 1 > $DCC_PATH/config
    echo 0x03D69E70 1 > $DCC_PATH/config
    echo 0x03D69E74 1 > $DCC_PATH/config
    echo 0x03D69E7C 1 > $DCC_PATH/config
    echo 0x03D69E80 1 > $DCC_PATH/config
    echo 0x03D69E84 1 > $DCC_PATH/config
    echo 0x03D69E8C 1 > $DCC_PATH/config
    echo 0x03D69EA0 1 > $DCC_PATH/config
    echo 0x03D69EA4 1 > $DCC_PATH/config
    echo 0x03D69EA8 1 > $DCC_PATH/config
    echo 0x03D69EAC 1 > $DCC_PATH/config
    echo 0x03D69EB0 1 > $DCC_PATH/config
    echo 0x03D69EB4 1 > $DCC_PATH/config
    echo 0x03D69EB8 1 > $DCC_PATH/config
    echo 0x03D69EBC 1 > $DCC_PATH/config
    echo 0x03D69EC0 1 > $DCC_PATH/config
    echo 0x03D69EC4 1 > $DCC_PATH/config
    echo 0x03D69EC8 1 > $DCC_PATH/config
    echo 0x03D69ECC 1 > $DCC_PATH/config
    echo 0x03D69ED0 1 > $DCC_PATH/config
    echo 0x03D69ED4 1 > $DCC_PATH/config
    echo 0x03D69ED8 1 > $DCC_PATH/config
    echo 0x03D69EDC 1 > $DCC_PATH/config
    echo 0x03D69EE0 1 > $DCC_PATH/config
    echo 0x03D69EE4 1 > $DCC_PATH/config
    echo 0x03D69F00 1 > $DCC_PATH/config
    echo 0x03D69F04 1 > $DCC_PATH/config
    echo 0x03D69F10 1 > $DCC_PATH/config
    echo 0x03D69F14 1 > $DCC_PATH/config
    echo 0x03D69F20 1 > $DCC_PATH/config
    echo 0x03D69F24 1 > $DCC_PATH/config
    echo 0x03D69F30 1 > $DCC_PATH/config
    echo 0x03D69F34 1 > $DCC_PATH/config
    echo 0x03D69F40 1 > $DCC_PATH/config
    echo 0x03D69F44 1 > $DCC_PATH/config
    echo 0x03D69F50 1 > $DCC_PATH/config
    echo 0x03D69F54 1 > $DCC_PATH/config
    echo 0x03D69F60 1 > $DCC_PATH/config
    echo 0x03D69F64 1 > $DCC_PATH/config
    echo 0x03D69F70 1 > $DCC_PATH/config
    echo 0x03D69F74 1 > $DCC_PATH/config
    echo 0x03D69F80 1 > $DCC_PATH/config
    echo 0x03D69F84 1 > $DCC_PATH/config
    echo 0x03D69FF0 1 > $DCC_PATH/config
    echo 0x03D69FF4 1 > $DCC_PATH/config
    echo 0x03D6A000 1 > $DCC_PATH/config
    echo 0x03D6A004 1 > $DCC_PATH/config
    echo 0x03D6A008 1 > $DCC_PATH/config
    echo 0x03D6A00C 1 > $DCC_PATH/config
    echo 0x03D6A010 1 > $DCC_PATH/config
    echo 0x03D6A014 1 > $DCC_PATH/config
    echo 0x03D6A018 1 > $DCC_PATH/config
    echo 0x03D6A058 1 > $DCC_PATH/config
    echo 0x03D6A078 1 > $DCC_PATH/config
    echo 0x03D6A098 1 > $DCC_PATH/config
    echo 0x03D6A0B8 1 > $DCC_PATH/config
    echo 0x03D6A0D8 1 > $DCC_PATH/config
    echo 0x03D6A0F8 1 > $DCC_PATH/config
    echo 0x03D6A118 1 > $DCC_PATH/config
    echo 0x03D6A138 1 > $DCC_PATH/config
    echo 0x03D6A158 1 > $DCC_PATH/config
    echo 0x03D6A20C 1 > $DCC_PATH/config
    echo 0x03D6A210 1 > $DCC_PATH/config
    echo 0x03D6A300 1 > $DCC_PATH/config
    echo 0x03D6A304 1 > $DCC_PATH/config
    echo 0x03D6A308 1 > $DCC_PATH/config
    echo 0x03D6A30C 1 > $DCC_PATH/config
    echo 0x03D6A350 1 > $DCC_PATH/config
    echo 0x03D6A354 1 > $DCC_PATH/config
    echo 0x03D6A358 1 > $DCC_PATH/config
    echo 0x03D6A360 1 > $DCC_PATH/config
    echo 0x03D6A364 1 > $DCC_PATH/config
    echo 0x03D6A368 1 > $DCC_PATH/config
    echo 0x03D6A380 1 > $DCC_PATH/config
    echo 0x03D6A384 1 > $DCC_PATH/config
    echo 0x03D6A388 1 > $DCC_PATH/config
    echo 0x03D6A38C 1 > $DCC_PATH/config
    echo 0x03D6A390 1 > $DCC_PATH/config
    echo 0x03D6A394 1 > $DCC_PATH/config
    echo 0x03D6A400 1 > $DCC_PATH/config
    echo 0x03D6A404 1 > $DCC_PATH/config
    echo 0x03D6A408 1 > $DCC_PATH/config
    echo 0x03D6A40C 1 > $DCC_PATH/config
    echo 0x03D6A410 1 > $DCC_PATH/config
    echo 0x03D6A414 1 > $DCC_PATH/config
    echo 0x03D6A418 1 > $DCC_PATH/config
    echo 0x03D6A41C 1 > $DCC_PATH/config
    echo 0x03D6A420 1 > $DCC_PATH/config
    echo 0x03D6A424 1 > $DCC_PATH/config
    echo 0x03D6A428 1 > $DCC_PATH/config
    echo 0x03D6A42C 1 > $DCC_PATH/config
    echo 0x03D6A430 1 > $DCC_PATH/config
    echo 0x03D6A434 1 > $DCC_PATH/config
    echo 0x03D6A438 1 > $DCC_PATH/config
    echo 0x03D6A43C 1 > $DCC_PATH/config
    echo 0x03D6A440 1 > $DCC_PATH/config
    echo 0x03D6A444 1 > $DCC_PATH/config
    echo 0x03D6A448 1 > $DCC_PATH/config
    echo 0x03D6A44C 1 > $DCC_PATH/config
    echo 0x03D6A450 1 > $DCC_PATH/config
    echo 0x03D6A454 1 > $DCC_PATH/config
    echo 0x03D6A458 1 > $DCC_PATH/config
    echo 0x03D6A45C 1 > $DCC_PATH/config
    echo 0x03D6A460 1 > $DCC_PATH/config
    echo 0x03D6A464 1 > $DCC_PATH/config
    echo 0x03D6A468 1 > $DCC_PATH/config
    echo 0x03D6A46C 1 > $DCC_PATH/config
    echo 0x03D6A470 1 > $DCC_PATH/config
    echo 0x03D6A474 1 > $DCC_PATH/config
    echo 0x03D6A478 1 > $DCC_PATH/config
    echo 0x03D6A47C 1 > $DCC_PATH/config
    echo 0x03D6A480 1 > $DCC_PATH/config
    echo 0x03D6A484 1 > $DCC_PATH/config
    echo 0x03D6A488 1 > $DCC_PATH/config
    echo 0x03D6A48C 1 > $DCC_PATH/config
    echo 0x03D6A490 1 > $DCC_PATH/config
    echo 0x03D6A494 1 > $DCC_PATH/config
    echo 0x03D6A498 1 > $DCC_PATH/config
    echo 0x03D6A49C 1 > $DCC_PATH/config
    echo 0x03D6A4A0 1 > $DCC_PATH/config
    echo 0x03D6A4A4 1 > $DCC_PATH/config
    echo 0x03D6A4A8 1 > $DCC_PATH/config
    echo 0x03D6A4AC 1 > $DCC_PATH/config
    echo 0x03D6A500 1 > $DCC_PATH/config
    echo 0x03D50000 1 > $DCC_PATH/config
    echo 0x03D50004 1 > $DCC_PATH/config
    echo 0x03D50008 1 > $DCC_PATH/config
    echo 0x03D5000C 1 > $DCC_PATH/config
    echo 0x03D50010 1 > $DCC_PATH/config
    echo 0x03D50014 1 > $DCC_PATH/config
    echo 0x03D50018 1 > $DCC_PATH/config
    echo 0x03D5001C 1 > $DCC_PATH/config
    echo 0x03D50020 1 > $DCC_PATH/config
    echo 0x03D50024 1 > $DCC_PATH/config
    echo 0x03D50028 1 > $DCC_PATH/config
    echo 0x03D5002C 1 > $DCC_PATH/config
    echo 0x03D50030 1 > $DCC_PATH/config
    echo 0x03D50034 1 > $DCC_PATH/config
    echo 0x03D50038 1 > $DCC_PATH/config
    echo 0x03D5003C 1 > $DCC_PATH/config
    echo 0x03D50040 1 > $DCC_PATH/config
    echo 0x03D50044 1 > $DCC_PATH/config
    echo 0x03D50048 1 > $DCC_PATH/config
    echo 0x03D5004C 1 > $DCC_PATH/config
    echo 0x03D50050 1 > $DCC_PATH/config
    echo 0x03D500D0 1 > $DCC_PATH/config
    echo 0x03D500D4 1 > $DCC_PATH/config
    echo 0x03D500D8 1 > $DCC_PATH/config
    echo 0x03D50100 1 > $DCC_PATH/config
    echo 0x03D50104 1 > $DCC_PATH/config
    echo 0x03D50108 1 > $DCC_PATH/config
    echo 0x03D5010C 1 > $DCC_PATH/config
    echo 0x03D50110 1 > $DCC_PATH/config
    echo 0x03D50114 1 > $DCC_PATH/config
    echo 0x03D50118 1 > $DCC_PATH/config
    echo 0x03D5011C 1 > $DCC_PATH/config
    echo 0x03D50200 1 > $DCC_PATH/config
    echo 0x03D50204 1 > $DCC_PATH/config
    echo 0x03D50208 1 > $DCC_PATH/config
    echo 0x03D5020C 1 > $DCC_PATH/config
    echo 0x03D50210 1 > $DCC_PATH/config
    echo 0x03D50400 1 > $DCC_PATH/config
    echo 0x03D50404 1 > $DCC_PATH/config
    echo 0x03D50408 1 > $DCC_PATH/config
    echo 0x03D5040C 1 > $DCC_PATH/config
    echo 0x03D50410 1 > $DCC_PATH/config
    echo 0x03D50450 1 > $DCC_PATH/config
    echo 0x03D50460 1 > $DCC_PATH/config
    echo 0x03D50464 1 > $DCC_PATH/config
    echo 0x03D50490 1 > $DCC_PATH/config
    echo 0x03D50494 1 > $DCC_PATH/config
    echo 0x03D50498 1 > $DCC_PATH/config
    echo 0x03D5049C 1 > $DCC_PATH/config
    echo 0x03D504A0 1 > $DCC_PATH/config
    echo 0x03D504A4 1 > $DCC_PATH/config
    echo 0x03D504A8 1 > $DCC_PATH/config
    echo 0x03D504AC 1 > $DCC_PATH/config
    echo 0x03D504B0 1 > $DCC_PATH/config
    echo 0x03D504B4 1 > $DCC_PATH/config
    echo 0x03D504B8 1 > $DCC_PATH/config
    echo 0x03D504BC 1 > $DCC_PATH/config
    echo 0x03D50550 1 > $DCC_PATH/config
    echo 0x03D50D00 1 > $DCC_PATH/config
    echo 0x03D50D04 1 > $DCC_PATH/config
    echo 0x03D50D08 1 > $DCC_PATH/config
    echo 0x03D50D10 1 > $DCC_PATH/config
    echo 0x03D50D14 1 > $DCC_PATH/config
    echo 0x03D50D18 1 > $DCC_PATH/config
    echo 0x03D50D1C 1 > $DCC_PATH/config
    echo 0x03D50D20 1 > $DCC_PATH/config
    echo 0x03D50D24 1 > $DCC_PATH/config
    echo 0x03D50D28 1 > $DCC_PATH/config
    echo 0x03D50D2C 1 > $DCC_PATH/config
    echo 0x03D50D30 1 > $DCC_PATH/config
    echo 0x03D50D34 1 > $DCC_PATH/config
    echo 0x03D50D38 1 > $DCC_PATH/config
    echo 0x03D50D3C 1 > $DCC_PATH/config
    echo 0x03D50D40 1 > $DCC_PATH/config
    echo 0x03D50D44 1 > $DCC_PATH/config
    echo 0x03D50D48 1 > $DCC_PATH/config
    echo 0x00112000 1 > $DCC_PATH/config
    echo 0x00112004 1 > $DCC_PATH/config
    echo 0x00113000 1 > $DCC_PATH/config
    echo 0x0011A000 1 > $DCC_PATH/config
    echo 0x0011A004 1 > $DCC_PATH/config
    echo 0x0011B000 1 > $DCC_PATH/config
    echo 0x0011B004 1 > $DCC_PATH/config
    echo 0x0011B008 1 > $DCC_PATH/config
    echo 0x0011B00C 1 > $DCC_PATH/config
    echo 0x0011B010 1 > $DCC_PATH/config
    echo 0x0011C000 1 > $DCC_PATH/config
    echo 0x0011C004 1 > $DCC_PATH/config
    echo 0x0011C008 1 > $DCC_PATH/config
    echo 0x0011C00C 1 > $DCC_PATH/config
    echo 0x0011C010 1 > $DCC_PATH/config
    echo 0x0011C014 1 > $DCC_PATH/config
    echo 0x0011C018 1 > $DCC_PATH/config
    echo 0x0011C01C 1 > $DCC_PATH/config
    echo 0x0011C020 1 > $DCC_PATH/config
    echo 0x0011C024 1 > $DCC_PATH/config
    echo 0x0011C028 1 > $DCC_PATH/config
    echo 0x0011C02C 1 > $DCC_PATH/config
    echo 0x0011C030 1 > $DCC_PATH/config
    echo 0x0011C034 1 > $DCC_PATH/config
    echo 0x0011C038 1 > $DCC_PATH/config
    echo 0x0011C03C 1 > $DCC_PATH/config
    echo 0x0011C040 1 > $DCC_PATH/config
    echo 0x0011C044 1 > $DCC_PATH/config
    echo 0x0011C048 1 > $DCC_PATH/config
    echo 0x0011C04C 1 > $DCC_PATH/config
    echo 0x0011C480 1 > $DCC_PATH/config
    echo 0x0011C484 1 > $DCC_PATH/config
    echo 0x0011C488 1 > $DCC_PATH/config
    echo 0x0011C48C 1 > $DCC_PATH/config
    echo 0x0011C490 1 > $DCC_PATH/config
    echo 0x0011C494 1 > $DCC_PATH/config
    echo 0x0011C498 1 > $DCC_PATH/config
    echo 0x0011C49C 1 > $DCC_PATH/config
    echo 0x0011D000 1 > $DCC_PATH/config
    echo 0x0011D004 1 > $DCC_PATH/config
    echo 0x0011D008 1 > $DCC_PATH/config
    echo 0x0011D00C 1 > $DCC_PATH/config
    echo 0x0011D010 1 > $DCC_PATH/config
    echo 0x0011F018 1 > $DCC_PATH/config
    echo 0x0011F01C 1 > $DCC_PATH/config
    echo 0x0011F020 1 > $DCC_PATH/config
    echo 0x0011F024 1 > $DCC_PATH/config
    echo 0x0011F040 1 > $DCC_PATH/config
    echo 0x0011F044 1 > $DCC_PATH/config
    echo 0x0011F048 1 > $DCC_PATH/config
    echo 0x0011F04C 1 > $DCC_PATH/config
    echo 0x0011F050 1 > $DCC_PATH/config
    echo 0x0011F054 1 > $DCC_PATH/config
    echo 0x00120000 1 > $DCC_PATH/config
    echo 0x00120004 1 > $DCC_PATH/config
    echo 0x00120008 1 > $DCC_PATH/config
    echo 0x0012000C 1 > $DCC_PATH/config
    echo 0x00120010 1 > $DCC_PATH/config
    echo 0x00121000 1 > $DCC_PATH/config
    echo 0x00121004 1 > $DCC_PATH/config
    echo 0x00121008 1 > $DCC_PATH/config
    echo 0x0012100C 1 > $DCC_PATH/config
    echo 0x00121104 1 > $DCC_PATH/config
    echo 0x00122000 1 > $DCC_PATH/config
    echo 0x00122004 1 > $DCC_PATH/config
    echo 0x00124000 1 > $DCC_PATH/config
    echo 0x00124004 1 > $DCC_PATH/config
    echo 0x00125000 1 > $DCC_PATH/config
    echo 0x00125004 1 > $DCC_PATH/config
    echo 0x00125008 1 > $DCC_PATH/config
    echo 0x0012500C 1 > $DCC_PATH/config
    echo 0x00125010 1 > $DCC_PATH/config
    echo 0x00126000 1 > $DCC_PATH/config
    echo 0x00126004 1 > $DCC_PATH/config
    echo 0x00126008 1 > $DCC_PATH/config
    echo 0x0012600C 1 > $DCC_PATH/config
    echo 0x00126010 1 > $DCC_PATH/config
    echo 0x00126014 1 > $DCC_PATH/config
    echo 0x00126018 1 > $DCC_PATH/config
    echo 0x0012601C 1 > $DCC_PATH/config
    echo 0x00126020 1 > $DCC_PATH/config
    echo 0x00126024 1 > $DCC_PATH/config
    echo 0x00126028 1 > $DCC_PATH/config
    echo 0x00126100 1 > $DCC_PATH/config
    echo 0x00126480 1 > $DCC_PATH/config
    echo 0x00127000 1 > $DCC_PATH/config
    echo 0x00127004 1 > $DCC_PATH/config
    echo 0x00127008 1 > $DCC_PATH/config
    echo 0x0012700C 1 > $DCC_PATH/config
    echo 0x00127010 1 > $DCC_PATH/config
    echo 0x00127014 1 > $DCC_PATH/config
    echo 0x00127018 1 > $DCC_PATH/config
    echo 0x00127480 1 > $DCC_PATH/config
    echo 0x00128004 1 > $DCC_PATH/config
    echo 0x00128008 1 > $DCC_PATH/config
    echo 0x0012800C 1 > $DCC_PATH/config
    echo 0x00128010 1 > $DCC_PATH/config
    echo 0x00128014 1 > $DCC_PATH/config
    echo 0x00128018 1 > $DCC_PATH/config
    echo 0x0012801C 1 > $DCC_PATH/config
    echo 0x00128020 1 > $DCC_PATH/config
    echo 0x00128024 1 > $DCC_PATH/config
    echo 0x00128028 1 > $DCC_PATH/config
    echo 0x0012802C 1 > $DCC_PATH/config
    echo 0x00128030 1 > $DCC_PATH/config
    echo 0x00128034 1 > $DCC_PATH/config
    echo 0x00128038 1 > $DCC_PATH/config
    echo 0x0012803C 1 > $DCC_PATH/config
    echo 0x00128040 1 > $DCC_PATH/config
    echo 0x00128044 1 > $DCC_PATH/config
    echo 0x00128048 1 > $DCC_PATH/config
    echo 0x0012804C 1 > $DCC_PATH/config
    echo 0x00128050 1 > $DCC_PATH/config
    echo 0x00128054 1 > $DCC_PATH/config
    echo 0x00128058 1 > $DCC_PATH/config
    echo 0x0012805C 1 > $DCC_PATH/config
    echo 0x00128060 1 > $DCC_PATH/config
    echo 0x00128064 1 > $DCC_PATH/config
    echo 0x00128068 1 > $DCC_PATH/config
    echo 0x00132000 1 > $DCC_PATH/config
    echo 0x00132004 1 > $DCC_PATH/config
    echo 0x00132008 1 > $DCC_PATH/config
    echo 0x0013200C 1 > $DCC_PATH/config
    echo 0x00132010 1 > $DCC_PATH/config
    echo 0x00132014 1 > $DCC_PATH/config
    echo 0x00132018 1 > $DCC_PATH/config
    echo 0x0013201C 1 > $DCC_PATH/config
    echo 0x00132020 1 > $DCC_PATH/config
    echo 0x00132024 1 > $DCC_PATH/config
    echo 0x00132028 1 > $DCC_PATH/config
    echo 0x0013202C 1 > $DCC_PATH/config
    echo 0x00132030 1 > $DCC_PATH/config
    echo 0x00132480 1 > $DCC_PATH/config
    echo 0x00133000 1 > $DCC_PATH/config
    echo 0x00133004 1 > $DCC_PATH/config
    echo 0x00133008 1 > $DCC_PATH/config
    echo 0x0013300C 1 > $DCC_PATH/config
    echo 0x00133010 1 > $DCC_PATH/config
    echo 0x00133014 1 > $DCC_PATH/config
    echo 0x00133028 1 > $DCC_PATH/config
    echo 0x00134000 1 > $DCC_PATH/config
    echo 0x00134004 1 > $DCC_PATH/config
    echo 0x00134008 1 > $DCC_PATH/config
    echo 0x0013400C 1 > $DCC_PATH/config
    echo 0x00134010 1 > $DCC_PATH/config
    echo 0x00134014 1 > $DCC_PATH/config
    echo 0x00134114 1 > $DCC_PATH/config
    echo 0x00137000 1 > $DCC_PATH/config
    echo 0x00137004 1 > $DCC_PATH/config
    echo 0x00137008 1 > $DCC_PATH/config
    echo 0x00138000 1 > $DCC_PATH/config
    echo 0x00138004 1 > $DCC_PATH/config
    echo 0x00138008 1 > $DCC_PATH/config
    echo 0x0013800C 1 > $DCC_PATH/config
    echo 0x00139000 1 > $DCC_PATH/config
    echo 0x00139004 1 > $DCC_PATH/config
    echo 0x00139008 1 > $DCC_PATH/config
    echo 0x0013900C 1 > $DCC_PATH/config
    echo 0x00139010 1 > $DCC_PATH/config
    echo 0x00139014 1 > $DCC_PATH/config
    echo 0x00139018 1 > $DCC_PATH/config
    echo 0x0013901C 1 > $DCC_PATH/config
    echo 0x00139020 1 > $DCC_PATH/config
    echo 0x00139024 1 > $DCC_PATH/config
    echo 0x00139028 1 > $DCC_PATH/config
    echo 0x0013902C 1 > $DCC_PATH/config
    echo 0x00139030 1 > $DCC_PATH/config
    echo 0x00139034 1 > $DCC_PATH/config
    echo 0x00139038 1 > $DCC_PATH/config
    echo 0x0013903C 1 > $DCC_PATH/config
    echo 0x00139044 1 > $DCC_PATH/config
    echo 0x00139048 1 > $DCC_PATH/config
    echo 0x0013905C 1 > $DCC_PATH/config
    echo 0x00139060 1 > $DCC_PATH/config
    echo 0x00139064 1 > $DCC_PATH/config
    echo 0x00139068 1 > $DCC_PATH/config
    echo 0x0013906C 1 > $DCC_PATH/config
    echo 0x00139070 1 > $DCC_PATH/config
    echo 0x00139074 1 > $DCC_PATH/config
    echo 0x00139088 1 > $DCC_PATH/config
    echo 0x0013A000 1 > $DCC_PATH/config
    echo 0x0013A004 1 > $DCC_PATH/config
    echo 0x0013A008 1 > $DCC_PATH/config
    echo 0x0013B000 1 > $DCC_PATH/config
    echo 0x0013B004 1 > $DCC_PATH/config
    echo 0x0013B008 1 > $DCC_PATH/config
    echo 0x0013B00C 1 > $DCC_PATH/config
    echo 0x0013B010 1 > $DCC_PATH/config
    echo 0x0013B014 1 > $DCC_PATH/config
    echo 0x0013B028 1 > $DCC_PATH/config
    echo 0x0013C000 1 > $DCC_PATH/config
    echo 0x0013C004 1 > $DCC_PATH/config
    echo 0x0013C008 1 > $DCC_PATH/config
    echo 0x0013C00C 1 > $DCC_PATH/config
    echo 0x0013D000 1 > $DCC_PATH/config
    echo 0x0013D004 1 > $DCC_PATH/config
    echo 0x0013D008 1 > $DCC_PATH/config
    echo 0x0013E000 1 > $DCC_PATH/config
    echo 0x0013F000 1 > $DCC_PATH/config
    echo 0x0013F00C 1 > $DCC_PATH/config
    echo 0x0013F014 1 > $DCC_PATH/config
    echo 0x0013F018 1 > $DCC_PATH/config
    echo 0x0013F034 1 > $DCC_PATH/config
    echo 0x0013F038 1 > $DCC_PATH/config
    echo 0x0013F03C 1 > $DCC_PATH/config
    echo 0x0013F040 1 > $DCC_PATH/config
    echo 0x0013F044 1 > $DCC_PATH/config
    echo 0x0013F048 1 > $DCC_PATH/config
    echo 0x0013F04C 1 > $DCC_PATH/config
    echo 0x0013F050 1 > $DCC_PATH/config
    echo 0x0013F054 1 > $DCC_PATH/config
    echo 0x0013F058 1 > $DCC_PATH/config
    echo 0x0013F05C 1 > $DCC_PATH/config
    echo 0x00140000 1 > $DCC_PATH/config
    echo 0x00140004 1 > $DCC_PATH/config
    echo 0x00140008 1 > $DCC_PATH/config
    echo 0x0014000C 1 > $DCC_PATH/config
    echo 0x00140010 1 > $DCC_PATH/config
    echo 0x00140014 1 > $DCC_PATH/config
    echo 0x00140018 1 > $DCC_PATH/config
    echo 0x0014001C 1 > $DCC_PATH/config
    echo 0x00140020 1 > $DCC_PATH/config
    echo 0x00141000 1 > $DCC_PATH/config
    echo 0x00141004 1 > $DCC_PATH/config
    echo 0x00141008 1 > $DCC_PATH/config
    echo 0x0014100C 1 > $DCC_PATH/config
    echo 0x00141010 1 > $DCC_PATH/config
    echo 0x00141014 1 > $DCC_PATH/config
    echo 0x00141018 1 > $DCC_PATH/config
    echo 0x0014101C 1 > $DCC_PATH/config
    echo 0x0014102C 1 > $DCC_PATH/config
    echo 0x00141034 1 > $DCC_PATH/config
    echo 0x00141038 1 > $DCC_PATH/config
    echo 0x0014103C 1 > $DCC_PATH/config
    echo 0x00141040 1 > $DCC_PATH/config
    echo 0x00141044 1 > $DCC_PATH/config
    echo 0x00141048 1 > $DCC_PATH/config
    echo 0x0014104C 1 > $DCC_PATH/config
    echo 0x00141050 1 > $DCC_PATH/config
    echo 0x00141054 1 > $DCC_PATH/config
    echo 0x00141058 1 > $DCC_PATH/config
    echo 0x0014105C 1 > $DCC_PATH/config
    echo 0x00141060 1 > $DCC_PATH/config
    echo 0x00141064 1 > $DCC_PATH/config
    echo 0x00141068 1 > $DCC_PATH/config
    echo 0x0014106C 1 > $DCC_PATH/config
    echo 0x00141070 1 > $DCC_PATH/config
    echo 0x00142000 1 > $DCC_PATH/config
    echo 0x00143000 1 > $DCC_PATH/config
    echo 0x00143004 1 > $DCC_PATH/config
    echo 0x00143008 1 > $DCC_PATH/config
    echo 0x0014300C 1 > $DCC_PATH/config
    echo 0x00143010 1 > $DCC_PATH/config
    echo 0x00143014 1 > $DCC_PATH/config
    echo 0x00143018 1 > $DCC_PATH/config
    echo 0x0014301C 1 > $DCC_PATH/config
    echo 0x00143020 1 > $DCC_PATH/config
    echo 0x00143024 1 > $DCC_PATH/config
    echo 0x00143038 1 > $DCC_PATH/config
    echo 0x0014303C 1 > $DCC_PATH/config
    echo 0x00144000 1 > $DCC_PATH/config
    echo 0x00144008 1 > $DCC_PATH/config
    echo 0x0014400C 1 > $DCC_PATH/config
    echo 0x00144010 1 > $DCC_PATH/config
    echo 0x00144014 1 > $DCC_PATH/config
    echo 0x00144018 1 > $DCC_PATH/config
    echo 0x0014401C 1 > $DCC_PATH/config
    echo 0x00144020 1 > $DCC_PATH/config
    echo 0x00144024 1 > $DCC_PATH/config
    echo 0x00144028 1 > $DCC_PATH/config
    echo 0x0014402C 1 > $DCC_PATH/config
    echo 0x00144044 1 > $DCC_PATH/config
    echo 0x00144048 1 > $DCC_PATH/config
    echo 0x0014404C 1 > $DCC_PATH/config
    echo 0x00144050 1 > $DCC_PATH/config
    echo 0x00144054 1 > $DCC_PATH/config
    echo 0x00144058 1 > $DCC_PATH/config
    echo 0x0014405C 1 > $DCC_PATH/config
    echo 0x00144060 1 > $DCC_PATH/config
    echo 0x00144064 1 > $DCC_PATH/config
    echo 0x00144068 1 > $DCC_PATH/config
    echo 0x0014406C 1 > $DCC_PATH/config
    echo 0x00144070 1 > $DCC_PATH/config
    echo 0x00144074 1 > $DCC_PATH/config
    echo 0x00144078 1 > $DCC_PATH/config
    echo 0x0014407C 1 > $DCC_PATH/config
    echo 0x00144080 1 > $DCC_PATH/config
    echo 0x00144154 1 > $DCC_PATH/config
    echo 0x00144158 1 > $DCC_PATH/config
    echo 0x00144168 1 > $DCC_PATH/config
    echo 0x00144170 1 > $DCC_PATH/config
    echo 0x00144174 1 > $DCC_PATH/config
    echo 0x00144178 1 > $DCC_PATH/config
    echo 0x0014417C 1 > $DCC_PATH/config
    echo 0x00144180 1 > $DCC_PATH/config
    echo 0x00144184 1 > $DCC_PATH/config
    echo 0x00144188 1 > $DCC_PATH/config
    echo 0x0014418C 1 > $DCC_PATH/config
    echo 0x00144190 1 > $DCC_PATH/config
    echo 0x00144194 1 > $DCC_PATH/config
    echo 0x00144198 1 > $DCC_PATH/config
    echo 0x0014419C 1 > $DCC_PATH/config
    echo 0x001441A0 1 > $DCC_PATH/config
    echo 0x001441A4 1 > $DCC_PATH/config
    echo 0x001441A8 1 > $DCC_PATH/config
    echo 0x001441AC 1 > $DCC_PATH/config
    echo 0x00144280 1 > $DCC_PATH/config
    echo 0x00144284 1 > $DCC_PATH/config
    echo 0x00144288 1 > $DCC_PATH/config
    echo 0x00144428 1 > $DCC_PATH/config
    echo 0x0014442C 1 > $DCC_PATH/config
    echo 0x00146000 1 > $DCC_PATH/config
    echo 0x00146004 1 > $DCC_PATH/config
    echo 0x00146008 1 > $DCC_PATH/config
    echo 0x0014600C 1 > $DCC_PATH/config
    echo 0x00146010 1 > $DCC_PATH/config
    echo 0x00146014 1 > $DCC_PATH/config
    echo 0x00146018 1 > $DCC_PATH/config
    echo 0x00148000 1 > $DCC_PATH/config
    echo 0x00148004 1 > $DCC_PATH/config
    echo 0x00148008 1 > $DCC_PATH/config
    echo 0x0014800C 1 > $DCC_PATH/config
    echo 0x00148010 1 > $DCC_PATH/config
    echo 0x00148014 1 > $DCC_PATH/config
    echo 0x00148020 1 > $DCC_PATH/config
    echo 0x00148028 1 > $DCC_PATH/config
    echo 0x0014802C 1 > $DCC_PATH/config
    echo 0x00148030 1 > $DCC_PATH/config
    echo 0x00148048 1 > $DCC_PATH/config
    echo 0x0014804C 1 > $DCC_PATH/config
    echo 0x00148050 1 > $DCC_PATH/config
    echo 0x00148054 1 > $DCC_PATH/config
    echo 0x00148058 1 > $DCC_PATH/config
    echo 0x0014805C 1 > $DCC_PATH/config
    echo 0x00148060 1 > $DCC_PATH/config
    echo 0x00148064 1 > $DCC_PATH/config
    echo 0x00148068 1 > $DCC_PATH/config
    echo 0x0014806C 1 > $DCC_PATH/config
    echo 0x00148070 1 > $DCC_PATH/config
    echo 0x00148074 1 > $DCC_PATH/config
    echo 0x00148078 1 > $DCC_PATH/config
    echo 0x0014807C 1 > $DCC_PATH/config
    echo 0x00148080 1 > $DCC_PATH/config
    echo 0x00148084 1 > $DCC_PATH/config
    echo 0x00148158 1 > $DCC_PATH/config
    echo 0x0014815C 1 > $DCC_PATH/config
    echo 0x00148170 1 > $DCC_PATH/config
    echo 0x00148180 1 > $DCC_PATH/config
    echo 0x00149000 1 > $DCC_PATH/config
    echo 0x00149004 1 > $DCC_PATH/config
    echo 0x00149008 1 > $DCC_PATH/config
    echo 0x0014900C 1 > $DCC_PATH/config
    echo 0x00149010 1 > $DCC_PATH/config
    echo 0x0014A000 1 > $DCC_PATH/config
    echo 0x0014B000 1 > $DCC_PATH/config
    echo 0x0014B004 1 > $DCC_PATH/config
    echo 0x0014B008 1 > $DCC_PATH/config
    echo 0x0014B00C 1 > $DCC_PATH/config
    echo 0x0014B010 1 > $DCC_PATH/config
    echo 0x0014C000 1 > $DCC_PATH/config
    echo 0x0014E000 1 > $DCC_PATH/config
    echo 0x0014E004 1 > $DCC_PATH/config
    echo 0x0014E008 1 > $DCC_PATH/config
    echo 0x0014E00C 1 > $DCC_PATH/config
    echo 0x0014E010 1 > $DCC_PATH/config
    echo 0x0014E030 1 > $DCC_PATH/config
    echo 0x0014F000 1 > $DCC_PATH/config
    echo 0x0014F004 1 > $DCC_PATH/config
    echo 0x0014F008 1 > $DCC_PATH/config
    echo 0x0014F00C 1 > $DCC_PATH/config
    echo 0x0014F010 1 > $DCC_PATH/config
    echo 0x00150000 1 > $DCC_PATH/config
    echo 0x00150004 1 > $DCC_PATH/config
    echo 0x00150008 1 > $DCC_PATH/config
    echo 0x0015000C 1 > $DCC_PATH/config
    echo 0x00150010 1 > $DCC_PATH/config
    echo 0x00150014 1 > $DCC_PATH/config
    echo 0x00150018 1 > $DCC_PATH/config
    echo 0x0015001C 1 > $DCC_PATH/config
    echo 0x00150020 1 > $DCC_PATH/config
    echo 0x00150024 1 > $DCC_PATH/config
    echo 0x00150028 1 > $DCC_PATH/config
    echo 0x00151000 1 > $DCC_PATH/config
    echo 0x00151004 1 > $DCC_PATH/config
    echo 0x00151008 1 > $DCC_PATH/config
    echo 0x0015100C 1 > $DCC_PATH/config
    echo 0x00151010 1 > $DCC_PATH/config
    echo 0x00151014 1 > $DCC_PATH/config
    echo 0x00151018 1 > $DCC_PATH/config
    echo 0x0015101C 1 > $DCC_PATH/config
    echo 0x00151020 1 > $DCC_PATH/config
    echo 0x00151024 1 > $DCC_PATH/config
    echo 0x00152000 1 > $DCC_PATH/config
    echo 0x00152004 1 > $DCC_PATH/config
    echo 0x00152008 1 > $DCC_PATH/config
    echo 0x0015200C 1 > $DCC_PATH/config
    echo 0x00152010 1 > $DCC_PATH/config
    echo 0x00152014 1 > $DCC_PATH/config
    echo 0x00152018 1 > $DCC_PATH/config
    echo 0x0015201C 1 > $DCC_PATH/config
    echo 0x00152020 1 > $DCC_PATH/config
    echo 0x00152024 1 > $DCC_PATH/config
    echo 0x00153000 1 > $DCC_PATH/config
    echo 0x0015300C 1 > $DCC_PATH/config
    echo 0x00153014 1 > $DCC_PATH/config
    echo 0x00153018 1 > $DCC_PATH/config
    echo 0x00153034 1 > $DCC_PATH/config
    echo 0x00153038 1 > $DCC_PATH/config
    echo 0x0015303C 1 > $DCC_PATH/config
    echo 0x00153040 1 > $DCC_PATH/config
    echo 0x00153044 1 > $DCC_PATH/config
    echo 0x00153048 1 > $DCC_PATH/config
    echo 0x0015304C 1 > $DCC_PATH/config
    echo 0x00153050 1 > $DCC_PATH/config
    echo 0x00153054 1 > $DCC_PATH/config
    echo 0x00153058 1 > $DCC_PATH/config
    echo 0x0015305C 1 > $DCC_PATH/config
    echo 0x00156000 1 > $DCC_PATH/config
    echo 0x00156004 1 > $DCC_PATH/config
    echo 0x00156008 1 > $DCC_PATH/config
    echo 0x0015600C 1 > $DCC_PATH/config
    echo 0x00156010 1 > $DCC_PATH/config
    echo 0x00156014 1 > $DCC_PATH/config
    echo 0x00156018 1 > $DCC_PATH/config
    echo 0x0015601C 1 > $DCC_PATH/config
    echo 0x00156020 1 > $DCC_PATH/config
    echo 0x00156024 1 > $DCC_PATH/config
    echo 0x00157000 1 > $DCC_PATH/config
    echo 0x00157004 1 > $DCC_PATH/config
    echo 0x00157008 1 > $DCC_PATH/config
    echo 0x0015700C 1 > $DCC_PATH/config
    echo 0x00157010 1 > $DCC_PATH/config
    echo 0x00157014 1 > $DCC_PATH/config
    echo 0x00157018 1 > $DCC_PATH/config
    echo 0x0015701C 1 > $DCC_PATH/config
    echo 0x00157020 1 > $DCC_PATH/config
    echo 0x00157024 1 > $DCC_PATH/config
    echo 0x00158000 1 > $DCC_PATH/config
    echo 0x00158004 1 > $DCC_PATH/config
    echo 0x00158008 1 > $DCC_PATH/config
    echo 0x0015800C 1 > $DCC_PATH/config
    echo 0x0015A000 1 > $DCC_PATH/config
    echo 0x0015A004 1 > $DCC_PATH/config
    echo 0x0015A008 1 > $DCC_PATH/config
    echo 0x0015A00C 1 > $DCC_PATH/config
    echo 0x0015A010 1 > $DCC_PATH/config
    echo 0x0015A014 1 > $DCC_PATH/config
    echo 0x0015A018 1 > $DCC_PATH/config
    echo 0x0015A01C 1 > $DCC_PATH/config
    echo 0x0015A020 1 > $DCC_PATH/config
    echo 0x0015A024 1 > $DCC_PATH/config
    echo 0x00162000 1 > $DCC_PATH/config
    echo 0x00162004 1 > $DCC_PATH/config
    echo 0x00162008 1 > $DCC_PATH/config
    echo 0x00162010 1 > $DCC_PATH/config
    echo 0x00162014 1 > $DCC_PATH/config
    echo 0x00162024 1 > $DCC_PATH/config
    echo 0x00162034 1 > $DCC_PATH/config
    echo 0x0016203C 1 > $DCC_PATH/config
    echo 0x00162040 1 > $DCC_PATH/config
    echo 0x00162044 1 > $DCC_PATH/config
    echo 0x00162048 1 > $DCC_PATH/config
    echo 0x0016204C 1 > $DCC_PATH/config
    echo 0x00164000 1 > $DCC_PATH/config
    echo 0x00164004 1 > $DCC_PATH/config
    echo 0x00164008 1 > $DCC_PATH/config
    echo 0x0016400C 1 > $DCC_PATH/config
    echo 0x00164010 1 > $DCC_PATH/config
    echo 0x00164014 1 > $DCC_PATH/config
    echo 0x00165000 1 > $DCC_PATH/config
    echo 0x00165004 1 > $DCC_PATH/config
    echo 0x00165008 1 > $DCC_PATH/config
    echo 0x0016500C 1 > $DCC_PATH/config
    echo 0x00165010 1 > $DCC_PATH/config
    echo 0x00165014 1 > $DCC_PATH/config
    echo 0x00166000 1 > $DCC_PATH/config
    echo 0x00166004 1 > $DCC_PATH/config
    echo 0x00166008 1 > $DCC_PATH/config
    echo 0x0016600C 1 > $DCC_PATH/config
    echo 0x00166010 1 > $DCC_PATH/config
    echo 0x00166014 1 > $DCC_PATH/config
    echo 0x00169000 1 > $DCC_PATH/config
    echo 0x0016900C 1 > $DCC_PATH/config
    echo 0x00169014 1 > $DCC_PATH/config
    echo 0x00169018 1 > $DCC_PATH/config
    echo 0x00169034 1 > $DCC_PATH/config
    echo 0x00169038 1 > $DCC_PATH/config
    echo 0x0016903C 1 > $DCC_PATH/config
    echo 0x00169040 1 > $DCC_PATH/config
    echo 0x00169044 1 > $DCC_PATH/config
    echo 0x00169048 1 > $DCC_PATH/config
    echo 0x0016904C 1 > $DCC_PATH/config
    echo 0x00169050 1 > $DCC_PATH/config
    echo 0x00169054 1 > $DCC_PATH/config
    echo 0x00169058 1 > $DCC_PATH/config
    echo 0x0016905C 1 > $DCC_PATH/config
    echo 0x0016A000 1 > $DCC_PATH/config
    echo 0x0016A004 1 > $DCC_PATH/config
    echo 0x0016D000 1 > $DCC_PATH/config
    echo 0x0016E000 1 > $DCC_PATH/config
    echo 0x00171000 1 > $DCC_PATH/config
    echo 0x00171004 1 > $DCC_PATH/config
    echo 0x00171008 1 > $DCC_PATH/config
    echo 0x0017100C 1 > $DCC_PATH/config
    echo 0x00171010 1 > $DCC_PATH/config
    echo 0x00171014 1 > $DCC_PATH/config
    echo 0x00171018 1 > $DCC_PATH/config
    echo 0x0017101C 1 > $DCC_PATH/config
    echo 0x00171020 1 > $DCC_PATH/config
    echo 0x00171028 1 > $DCC_PATH/config
    echo 0x00171038 1 > $DCC_PATH/config
    echo 0x0017103C 1 > $DCC_PATH/config
    echo 0x00171040 1 > $DCC_PATH/config
    echo 0x00171044 1 > $DCC_PATH/config
    echo 0x00171048 1 > $DCC_PATH/config
    echo 0x0017104C 1 > $DCC_PATH/config
    echo 0x00171050 1 > $DCC_PATH/config
    echo 0x00171054 1 > $DCC_PATH/config
    echo 0x00171058 1 > $DCC_PATH/config
    echo 0x0017105C 1 > $DCC_PATH/config
    echo 0x00171060 1 > $DCC_PATH/config
    echo 0x00171064 1 > $DCC_PATH/config
    echo 0x00171068 1 > $DCC_PATH/config
    echo 0x0017106C 1 > $DCC_PATH/config
    echo 0x00171070 1 > $DCC_PATH/config
    echo 0x00171074 1 > $DCC_PATH/config
    echo 0x00171148 1 > $DCC_PATH/config
    echo 0x0017114C 1 > $DCC_PATH/config
    echo 0x00171150 1 > $DCC_PATH/config
    echo 0x00171154 1 > $DCC_PATH/config
    echo 0x00171250 1 > $DCC_PATH/config
    echo 0x00172000 1 > $DCC_PATH/config
    echo 0x00172004 1 > $DCC_PATH/config
    echo 0x00172008 1 > $DCC_PATH/config
    echo 0x0017200C 1 > $DCC_PATH/config
    echo 0x00172010 1 > $DCC_PATH/config
    echo 0x00172014 1 > $DCC_PATH/config
    echo 0x00172018 1 > $DCC_PATH/config
    echo 0x0017300C 1 > $DCC_PATH/config
    echo 0x00173010 1 > $DCC_PATH/config
    echo 0x00173018 1 > $DCC_PATH/config
    echo 0x00174000 1 > $DCC_PATH/config
    echo 0x00174004 1 > $DCC_PATH/config
    echo 0x00174008 1 > $DCC_PATH/config
    echo 0x0017400C 1 > $DCC_PATH/config
    echo 0x00174010 1 > $DCC_PATH/config
    echo 0x00174014 1 > $DCC_PATH/config
    echo 0x00174018 1 > $DCC_PATH/config
    echo 0x0017401C 1 > $DCC_PATH/config
    echo 0x00174020 1 > $DCC_PATH/config
    echo 0x00174024 1 > $DCC_PATH/config
    echo 0x00174028 1 > $DCC_PATH/config
    echo 0x0017402C 1 > $DCC_PATH/config
    echo 0x00174034 1 > $DCC_PATH/config
    echo 0x00174038 1 > $DCC_PATH/config
    echo 0x0017403C 1 > $DCC_PATH/config
    echo 0x00174040 1 > $DCC_PATH/config
    echo 0x00174044 1 > $DCC_PATH/config
    echo 0x00174048 1 > $DCC_PATH/config
    echo 0x0017404C 1 > $DCC_PATH/config
    echo 0x00174050 1 > $DCC_PATH/config
    echo 0x00174054 1 > $DCC_PATH/config
    echo 0x00174058 1 > $DCC_PATH/config
    echo 0x0017405C 1 > $DCC_PATH/config
    echo 0x0017406C 1 > $DCC_PATH/config
    echo 0x00174074 1 > $DCC_PATH/config
    echo 0x00174078 1 > $DCC_PATH/config
    echo 0x0017407C 1 > $DCC_PATH/config
    echo 0x00174080 1 > $DCC_PATH/config
    echo 0x00174084 1 > $DCC_PATH/config
    echo 0x00174088 1 > $DCC_PATH/config
    echo 0x0017408C 1 > $DCC_PATH/config
    echo 0x00174090 1 > $DCC_PATH/config
    echo 0x00174094 1 > $DCC_PATH/config
    echo 0x00174098 1 > $DCC_PATH/config
    echo 0x0017409C 1 > $DCC_PATH/config
    echo 0x001740A0 1 > $DCC_PATH/config
    echo 0x001740A4 1 > $DCC_PATH/config
    echo 0x001740A8 1 > $DCC_PATH/config
    echo 0x001740AC 1 > $DCC_PATH/config
    echo 0x001740B0 1 > $DCC_PATH/config
    echo 0x00174184 1 > $DCC_PATH/config
    echo 0x00174188 1 > $DCC_PATH/config
    echo 0x001741A0 1 > $DCC_PATH/config
    echo 0x001741A4 1 > $DCC_PATH/config
    echo 0x001741A8 1 > $DCC_PATH/config
    echo 0x001741AC 1 > $DCC_PATH/config
    echo 0x001741B0 1 > $DCC_PATH/config
    echo 0x001741B4 1 > $DCC_PATH/config
    echo 0x001741B8 1 > $DCC_PATH/config
    echo 0x001741BC 1 > $DCC_PATH/config
    echo 0x001741C0 1 > $DCC_PATH/config
    echo 0x001741C4 1 > $DCC_PATH/config
    echo 0x001741C8 1 > $DCC_PATH/config
    echo 0x001741CC 1 > $DCC_PATH/config
    echo 0x001741D0 1 > $DCC_PATH/config
    echo 0x001741D4 1 > $DCC_PATH/config
    echo 0x001741D8 1 > $DCC_PATH/config
    echo 0x001741DC 1 > $DCC_PATH/config
    echo 0x001742B0 1 > $DCC_PATH/config
    echo 0x001742B4 1 > $DCC_PATH/config
    echo 0x001742CC 1 > $DCC_PATH/config
    echo 0x001742D0 1 > $DCC_PATH/config
    echo 0x001742D4 1 > $DCC_PATH/config
    echo 0x001742D8 1 > $DCC_PATH/config
    echo 0x001742DC 1 > $DCC_PATH/config
    echo 0x001742E0 1 > $DCC_PATH/config
    echo 0x001742E4 1 > $DCC_PATH/config
    echo 0x001742E8 1 > $DCC_PATH/config
    echo 0x001742EC 1 > $DCC_PATH/config
    echo 0x001742F0 1 > $DCC_PATH/config
    echo 0x001742F4 1 > $DCC_PATH/config
    echo 0x001742F8 1 > $DCC_PATH/config
    echo 0x001742FC 1 > $DCC_PATH/config
    echo 0x00174300 1 > $DCC_PATH/config
    echo 0x00174304 1 > $DCC_PATH/config
    echo 0x00174308 1 > $DCC_PATH/config
    echo 0x001743DC 1 > $DCC_PATH/config
    echo 0x001743E0 1 > $DCC_PATH/config
    echo 0x001743F8 1 > $DCC_PATH/config
    echo 0x001743FC 1 > $DCC_PATH/config
    echo 0x00174400 1 > $DCC_PATH/config
    echo 0x00174404 1 > $DCC_PATH/config
    echo 0x00174408 1 > $DCC_PATH/config
    echo 0x0017440C 1 > $DCC_PATH/config
    echo 0x00174410 1 > $DCC_PATH/config
    echo 0x00174414 1 > $DCC_PATH/config
    echo 0x00174418 1 > $DCC_PATH/config
    echo 0x0017441C 1 > $DCC_PATH/config
    echo 0x00174420 1 > $DCC_PATH/config
    echo 0x00174424 1 > $DCC_PATH/config
    echo 0x00174428 1 > $DCC_PATH/config
    echo 0x0017442C 1 > $DCC_PATH/config
    echo 0x00174430 1 > $DCC_PATH/config
    echo 0x00174434 1 > $DCC_PATH/config
    echo 0x00174508 1 > $DCC_PATH/config
    echo 0x0017450C 1 > $DCC_PATH/config
    echo 0x00174524 1 > $DCC_PATH/config
    echo 0x00174528 1 > $DCC_PATH/config
    echo 0x0017452C 1 > $DCC_PATH/config
    echo 0x00174530 1 > $DCC_PATH/config
    echo 0x00174534 1 > $DCC_PATH/config
    echo 0x00174538 1 > $DCC_PATH/config
    echo 0x0017453C 1 > $DCC_PATH/config
    echo 0x00174540 1 > $DCC_PATH/config
    echo 0x00174544 1 > $DCC_PATH/config
    echo 0x00174548 1 > $DCC_PATH/config
    echo 0x0017454C 1 > $DCC_PATH/config
    echo 0x00174550 1 > $DCC_PATH/config
    echo 0x00174554 1 > $DCC_PATH/config
    echo 0x00174558 1 > $DCC_PATH/config
    echo 0x0017455C 1 > $DCC_PATH/config
    echo 0x00174560 1 > $DCC_PATH/config
    echo 0x00174760 1 > $DCC_PATH/config
    echo 0x00174764 1 > $DCC_PATH/config
    echo 0x00174768 1 > $DCC_PATH/config
    echo 0x00174770 1 > $DCC_PATH/config
    echo 0x00174774 1 > $DCC_PATH/config
    echo 0x00174778 1 > $DCC_PATH/config
    echo 0x0017477C 1 > $DCC_PATH/config
    echo 0x00174780 1 > $DCC_PATH/config
    echo 0x00174784 1 > $DCC_PATH/config
    echo 0x00174788 1 > $DCC_PATH/config
    echo 0x0017478C 1 > $DCC_PATH/config
    echo 0x00174790 1 > $DCC_PATH/config
    echo 0x00176000 1 > $DCC_PATH/config
    echo 0x00178030 1 > $DCC_PATH/config
    echo 0x00178040 1 > $DCC_PATH/config
    echo 0x0017A000 1 > $DCC_PATH/config
    echo 0x0017A004 1 > $DCC_PATH/config
    echo 0x0017A008 1 > $DCC_PATH/config
    echo 0x0017A00C 1 > $DCC_PATH/config
    echo 0x0017A010 1 > $DCC_PATH/config
    echo 0x0017A014 1 > $DCC_PATH/config
    echo 0x0017A018 1 > $DCC_PATH/config
    echo 0x0017A01C 1 > $DCC_PATH/config
    echo 0x0017A020 1 > $DCC_PATH/config
    echo 0x0017A034 1 > $DCC_PATH/config
    echo 0x0017A038 1 > $DCC_PATH/config
    echo 0x0017A050 1 > $DCC_PATH/config
    echo 0x0017A054 1 > $DCC_PATH/config
    echo 0x0017A058 1 > $DCC_PATH/config
    echo 0x0017A05C 1 > $DCC_PATH/config
    echo 0x0017B000 1 > $DCC_PATH/config
    echo 0x0017B008 1 > $DCC_PATH/config
    echo 0x0017B00C 1 > $DCC_PATH/config
    echo 0x0017B014 1 > $DCC_PATH/config
    echo 0x0017B018 1 > $DCC_PATH/config
    echo 0x0017B028 1 > $DCC_PATH/config
    echo 0x0017B02C 1 > $DCC_PATH/config
    echo 0x0017B03C 1 > $DCC_PATH/config
    echo 0x0017B044 1 > $DCC_PATH/config
    echo 0x0017B048 1 > $DCC_PATH/config
    echo 0x0017B050 1 > $DCC_PATH/config
    echo 0x0017B054 1 > $DCC_PATH/config
    echo 0x0017B064 1 > $DCC_PATH/config
    echo 0x0017B068 1 > $DCC_PATH/config
    echo 0x0017B070 1 > $DCC_PATH/config
    echo 0x0017B078 1 > $DCC_PATH/config
    echo 0x0017C000 1 > $DCC_PATH/config
    echo 0x0017C008 1 > $DCC_PATH/config
    echo 0x0017C00C 1 > $DCC_PATH/config
    echo 0x0017C014 1 > $DCC_PATH/config
    echo 0x0017C018 1 > $DCC_PATH/config
    echo 0x0017C028 1 > $DCC_PATH/config
    echo 0x0017C02C 1 > $DCC_PATH/config
    echo 0x0017C03C 1 > $DCC_PATH/config
    echo 0x0017C044 1 > $DCC_PATH/config
    echo 0x0017C048 1 > $DCC_PATH/config
    echo 0x0017C050 1 > $DCC_PATH/config
    echo 0x0017C054 1 > $DCC_PATH/config
    echo 0x0017C064 1 > $DCC_PATH/config
    echo 0x0017C068 1 > $DCC_PATH/config
    echo 0x0017C070 1 > $DCC_PATH/config
    echo 0x0017C078 1 > $DCC_PATH/config
    echo 0x0017D000 1 > $DCC_PATH/config
    echo 0x0017D008 1 > $DCC_PATH/config
    echo 0x0017D00C 1 > $DCC_PATH/config
    echo 0x0017D014 1 > $DCC_PATH/config
    echo 0x0017D018 1 > $DCC_PATH/config
    echo 0x0017D028 1 > $DCC_PATH/config
    echo 0x0017D02C 1 > $DCC_PATH/config
    echo 0x0017D03C 1 > $DCC_PATH/config
    echo 0x0017D044 1 > $DCC_PATH/config
    echo 0x0017D048 1 > $DCC_PATH/config
    echo 0x0017D050 1 > $DCC_PATH/config
    echo 0x0017D054 1 > $DCC_PATH/config
    echo 0x0017D064 1 > $DCC_PATH/config
    echo 0x0017D068 1 > $DCC_PATH/config
    echo 0x0017D070 1 > $DCC_PATH/config
    echo 0x0017D078 1 > $DCC_PATH/config
    echo 0x0017E000 1 > $DCC_PATH/config
    echo 0x0017E008 1 > $DCC_PATH/config
    echo 0x0017E00C 1 > $DCC_PATH/config
    echo 0x0017E014 1 > $DCC_PATH/config
    echo 0x0017E018 1 > $DCC_PATH/config
    echo 0x0017E028 1 > $DCC_PATH/config
    echo 0x0017E02C 1 > $DCC_PATH/config
    echo 0x0017E03C 1 > $DCC_PATH/config
    echo 0x0017E044 1 > $DCC_PATH/config
    echo 0x0017E048 1 > $DCC_PATH/config
    echo 0x0017E050 1 > $DCC_PATH/config
    echo 0x0017E054 1 > $DCC_PATH/config
    echo 0x0017E064 1 > $DCC_PATH/config
    echo 0x0017E068 1 > $DCC_PATH/config
    echo 0x0017E070 1 > $DCC_PATH/config
    echo 0x0017E078 1 > $DCC_PATH/config
    echo 0x00181000 1 > $DCC_PATH/config
    echo 0x0018200C 1 > $DCC_PATH/config
    echo 0x00183000 1 > $DCC_PATH/config
    echo 0x00183004 1 > $DCC_PATH/config
    echo 0x00183008 1 > $DCC_PATH/config
    echo 0x0018300C 1 > $DCC_PATH/config
    echo 0x00183010 1 > $DCC_PATH/config
    echo 0x00183014 1 > $DCC_PATH/config
    echo 0x00183018 1 > $DCC_PATH/config
    echo 0x0018301C 1 > $DCC_PATH/config
    echo 0x00183020 1 > $DCC_PATH/config
    echo 0x00183024 1 > $DCC_PATH/config
    echo 0x00183028 1 > $DCC_PATH/config
    echo 0x0018302C 1 > $DCC_PATH/config
    echo 0x0018303C 1 > $DCC_PATH/config
    echo 0x00183044 1 > $DCC_PATH/config
    echo 0x00183048 1 > $DCC_PATH/config
    echo 0x0018304C 1 > $DCC_PATH/config
    echo 0x00183050 1 > $DCC_PATH/config
    echo 0x00183054 1 > $DCC_PATH/config
    echo 0x00183058 1 > $DCC_PATH/config
    echo 0x0018305C 1 > $DCC_PATH/config
    echo 0x00183060 1 > $DCC_PATH/config
    echo 0x00183064 1 > $DCC_PATH/config
    echo 0x00183068 1 > $DCC_PATH/config
    echo 0x0018306C 1 > $DCC_PATH/config
    echo 0x00183070 1 > $DCC_PATH/config
    echo 0x00183074 1 > $DCC_PATH/config
    echo 0x00183078 1 > $DCC_PATH/config
    echo 0x0018307C 1 > $DCC_PATH/config
    echo 0x00183080 1 > $DCC_PATH/config
    echo 0x00183154 1 > $DCC_PATH/config
    echo 0x00183158 1 > $DCC_PATH/config
    echo 0x0018315C 1 > $DCC_PATH/config
    echo 0x00183160 1 > $DCC_PATH/config
    echo 0x00183164 1 > $DCC_PATH/config
    echo 0x00183168 1 > $DCC_PATH/config
    echo 0x0018316C 1 > $DCC_PATH/config
    echo 0x00183170 1 > $DCC_PATH/config
    echo 0x00183180 1 > $DCC_PATH/config
    echo 0x00183188 1 > $DCC_PATH/config
    echo 0x0018318C 1 > $DCC_PATH/config
    echo 0x00183190 1 > $DCC_PATH/config
    echo 0x00183194 1 > $DCC_PATH/config
    echo 0x00183198 1 > $DCC_PATH/config
    echo 0x0018319C 1 > $DCC_PATH/config
    echo 0x001831A0 1 > $DCC_PATH/config
    echo 0x001831A4 1 > $DCC_PATH/config
    echo 0x001831A8 1 > $DCC_PATH/config
    echo 0x001831AC 1 > $DCC_PATH/config
    echo 0x001831B0 1 > $DCC_PATH/config
    echo 0x001831B4 1 > $DCC_PATH/config
    echo 0x001831B8 1 > $DCC_PATH/config
    echo 0x001831BC 1 > $DCC_PATH/config
    echo 0x001831C0 1 > $DCC_PATH/config
    echo 0x001831C4 1 > $DCC_PATH/config
    echo 0x0018323C 1 > $DCC_PATH/config
    echo 0x0018324C 1 > $DCC_PATH/config
    echo 0x00183298 1 > $DCC_PATH/config
    echo 0x0018329C 1 > $DCC_PATH/config
    echo 0x001832A0 1 > $DCC_PATH/config
    echo 0x001832B8 1 > $DCC_PATH/config
    echo 0x001832BC 1 > $DCC_PATH/config
    echo 0x001832C0 1 > $DCC_PATH/config
    echo 0x001832C4 1 > $DCC_PATH/config
    echo 0x001832C8 1 > $DCC_PATH/config
    echo 0x001832CC 1 > $DCC_PATH/config
    echo 0x001832D0 1 > $DCC_PATH/config
    echo 0x001832D4 1 > $DCC_PATH/config
    echo 0x001832D8 1 > $DCC_PATH/config
    echo 0x001832DC 1 > $DCC_PATH/config
    echo 0x001832E0 1 > $DCC_PATH/config
    echo 0x001832E4 1 > $DCC_PATH/config
    echo 0x001832E8 1 > $DCC_PATH/config
    echo 0x001832EC 1 > $DCC_PATH/config
    echo 0x001832F0 1 > $DCC_PATH/config
    echo 0x001832F4 1 > $DCC_PATH/config
    echo 0x001833C8 1 > $DCC_PATH/config
    echo 0x001833CC 1 > $DCC_PATH/config
    echo 0x00184000 1 > $DCC_PATH/config
    echo 0x00184004 1 > $DCC_PATH/config
    echo 0x00184008 1 > $DCC_PATH/config
    echo 0x0018400C 1 > $DCC_PATH/config
    echo 0x00185000 1 > $DCC_PATH/config
    echo 0x00186000 1 > $DCC_PATH/config
    echo 0x00186008 1 > $DCC_PATH/config
    echo 0x0018600C 1 > $DCC_PATH/config
    echo 0x00186014 1 > $DCC_PATH/config
    echo 0x00186018 1 > $DCC_PATH/config
    echo 0x00186028 1 > $DCC_PATH/config
    echo 0x0018602C 1 > $DCC_PATH/config
    echo 0x0018603C 1 > $DCC_PATH/config
    echo 0x00186044 1 > $DCC_PATH/config
    echo 0x00186048 1 > $DCC_PATH/config
    echo 0x00186050 1 > $DCC_PATH/config
    echo 0x00186054 1 > $DCC_PATH/config
    echo 0x00186064 1 > $DCC_PATH/config
    echo 0x00186068 1 > $DCC_PATH/config
    echo 0x00186070 1 > $DCC_PATH/config
    echo 0x00186078 1 > $DCC_PATH/config
    echo 0x00189000 1 > $DCC_PATH/config
    echo 0x00189004 1 > $DCC_PATH/config
    echo 0x00189008 1 > $DCC_PATH/config
    echo 0x0018900C 1 > $DCC_PATH/config
    echo 0x00189010 1 > $DCC_PATH/config
    echo 0x00189014 1 > $DCC_PATH/config
    echo 0x00189018 1 > $DCC_PATH/config
    echo 0x0018901C 1 > $DCC_PATH/config
    echo 0x00189020 1 > $DCC_PATH/config
    echo 0x00189024 1 > $DCC_PATH/config
    echo 0x00189028 1 > $DCC_PATH/config
    echo 0x0018902C 1 > $DCC_PATH/config
    echo 0x00189030 1 > $DCC_PATH/config
    echo 0x00189034 1 > $DCC_PATH/config
    echo 0x00189038 1 > $DCC_PATH/config
    echo 0x0018903C 1 > $DCC_PATH/config
    echo 0x00189040 1 > $DCC_PATH/config
    echo 0x00189044 1 > $DCC_PATH/config
    echo 0x00189054 1 > $DCC_PATH/config
    echo 0x0018905C 1 > $DCC_PATH/config
    echo 0x00189060 1 > $DCC_PATH/config
    echo 0x00189064 1 > $DCC_PATH/config
    echo 0x00189068 1 > $DCC_PATH/config
    echo 0x0018906C 1 > $DCC_PATH/config
    echo 0x00189070 1 > $DCC_PATH/config
    echo 0x00189074 1 > $DCC_PATH/config
    echo 0x00189078 1 > $DCC_PATH/config
    echo 0x0018907C 1 > $DCC_PATH/config
    echo 0x00189080 1 > $DCC_PATH/config
    echo 0x00189084 1 > $DCC_PATH/config
    echo 0x00189088 1 > $DCC_PATH/config
    echo 0x0018908C 1 > $DCC_PATH/config
    echo 0x00189090 1 > $DCC_PATH/config
    echo 0x00189094 1 > $DCC_PATH/config
    echo 0x00189098 1 > $DCC_PATH/config
    echo 0x0018916C 1 > $DCC_PATH/config
    echo 0x00189170 1 > $DCC_PATH/config
    echo 0x0018A28C 1 > $DCC_PATH/config
    echo 0x0018B000 1 > $DCC_PATH/config
    echo 0x0018B004 1 > $DCC_PATH/config
    echo 0x0018B008 1 > $DCC_PATH/config
    echo 0x0018B00C 1 > $DCC_PATH/config
    echo 0x0018B010 1 > $DCC_PATH/config
    echo 0x0018B014 1 > $DCC_PATH/config
    echo 0x0018F000 1 > $DCC_PATH/config
    echo 0x00190480 1 > $DCC_PATH/config
    echo 0x00190890 1 > $DCC_PATH/config
    echo 0x00190894 1 > $DCC_PATH/config
    echo 0x0019089C 1 > $DCC_PATH/config
    echo 0x00192000 1 > $DCC_PATH/config
    echo 0x00192004 1 > $DCC_PATH/config
    echo 0x00192008 1 > $DCC_PATH/config
    echo 0x0019200C 1 > $DCC_PATH/config
    echo 0x00192010 1 > $DCC_PATH/config
    echo 0x00192014 1 > $DCC_PATH/config
    echo 0x00192018 1 > $DCC_PATH/config
    echo 0x0019201C 1 > $DCC_PATH/config
    echo 0x00192020 1 > $DCC_PATH/config
    echo 0x00192024 1 > $DCC_PATH/config
    echo 0x00192028 1 > $DCC_PATH/config
    echo 0x0019202C 1 > $DCC_PATH/config
    echo 0x00192030 1 > $DCC_PATH/config
    echo 0x00192034 1 > $DCC_PATH/config
    echo 0x00192038 1 > $DCC_PATH/config
    echo 0x0019203C 1 > $DCC_PATH/config
    echo 0x00192100 1 > $DCC_PATH/config
    echo 0x00193000 1 > $DCC_PATH/config
    echo 0x00193004 1 > $DCC_PATH/config
    echo 0x00193008 1 > $DCC_PATH/config
    echo 0x0019300C 1 > $DCC_PATH/config
    echo 0x00193010 1 > $DCC_PATH/config
    echo 0x00193014 1 > $DCC_PATH/config
    echo 0x00193018 1 > $DCC_PATH/config
    echo 0x0019301C 1 > $DCC_PATH/config
    echo 0x00193020 1 > $DCC_PATH/config
    echo 0x00193024 1 > $DCC_PATH/config
    echo 0x00193028 1 > $DCC_PATH/config
    echo 0x0019302C 1 > $DCC_PATH/config
    echo 0x00193030 1 > $DCC_PATH/config
    echo 0x00193034 1 > $DCC_PATH/config
    echo 0x00193038 1 > $DCC_PATH/config
    echo 0x0019303C 1 > $DCC_PATH/config
    echo 0x00193100 1 > $DCC_PATH/config
    echo 0x00193480 1 > $DCC_PATH/config
    echo 0x00194000 1 > $DCC_PATH/config
    echo 0x00194004 1 > $DCC_PATH/config
    echo 0x00194008 1 > $DCC_PATH/config
    echo 0x0019400C 1 > $DCC_PATH/config
    echo 0x00194010 1 > $DCC_PATH/config
    echo 0x00194014 1 > $DCC_PATH/config
    echo 0x00194018 1 > $DCC_PATH/config
    echo 0x0019401C 1 > $DCC_PATH/config
    echo 0x00194020 1 > $DCC_PATH/config
    echo 0x00194024 1 > $DCC_PATH/config
    echo 0x00194028 1 > $DCC_PATH/config
    echo 0x0019402C 1 > $DCC_PATH/config
    echo 0x00194030 1 > $DCC_PATH/config
    echo 0x00194034 1 > $DCC_PATH/config
    echo 0x00194038 1 > $DCC_PATH/config
    echo 0x0019403C 1 > $DCC_PATH/config
    echo 0x00194100 1 > $DCC_PATH/config
    echo 0x00195000 1 > $DCC_PATH/config
    echo 0x00195004 1 > $DCC_PATH/config
    echo 0x00195008 1 > $DCC_PATH/config
    echo 0x0019500C 1 > $DCC_PATH/config
    echo 0x00195010 1 > $DCC_PATH/config
    echo 0x00195014 1 > $DCC_PATH/config
    echo 0x00195018 1 > $DCC_PATH/config
    echo 0x0019501C 1 > $DCC_PATH/config
    echo 0x00195020 1 > $DCC_PATH/config
    echo 0x00195024 1 > $DCC_PATH/config
    echo 0x00195028 1 > $DCC_PATH/config
    echo 0x0019502C 1 > $DCC_PATH/config
    echo 0x00195030 1 > $DCC_PATH/config
    echo 0x00195034 1 > $DCC_PATH/config
    echo 0x00195038 1 > $DCC_PATH/config
    echo 0x0019503C 1 > $DCC_PATH/config
    echo 0x00195100 1 > $DCC_PATH/config
    echo 0x00196000 1 > $DCC_PATH/config
    echo 0x00196004 1 > $DCC_PATH/config
    echo 0x00196008 1 > $DCC_PATH/config
    echo 0x0019600C 1 > $DCC_PATH/config
    echo 0x00196010 1 > $DCC_PATH/config
    echo 0x00196014 1 > $DCC_PATH/config
    echo 0x00196018 1 > $DCC_PATH/config
    echo 0x0019601C 1 > $DCC_PATH/config
    echo 0x00196020 1 > $DCC_PATH/config
    echo 0x00196024 1 > $DCC_PATH/config
    echo 0x00196028 1 > $DCC_PATH/config
    echo 0x0019602C 1 > $DCC_PATH/config
    echo 0x00196030 1 > $DCC_PATH/config
    echo 0x00196034 1 > $DCC_PATH/config
    echo 0x00196038 1 > $DCC_PATH/config
    echo 0x0019603C 1 > $DCC_PATH/config
    echo 0x00196100 1 > $DCC_PATH/config
    echo 0x00197000 1 > $DCC_PATH/config
    echo 0x00197004 1 > $DCC_PATH/config
    echo 0x00197008 1 > $DCC_PATH/config
    echo 0x0019700C 1 > $DCC_PATH/config
    echo 0x00197010 1 > $DCC_PATH/config
    echo 0x00197014 1 > $DCC_PATH/config
    echo 0x00197018 1 > $DCC_PATH/config
    echo 0x0019701C 1 > $DCC_PATH/config
    echo 0x00197020 1 > $DCC_PATH/config
    echo 0x00197024 1 > $DCC_PATH/config
    echo 0x00197028 1 > $DCC_PATH/config
    echo 0x0019702C 1 > $DCC_PATH/config
    echo 0x00197030 1 > $DCC_PATH/config
    echo 0x00197034 1 > $DCC_PATH/config
    echo 0x00197038 1 > $DCC_PATH/config
    echo 0x0019703C 1 > $DCC_PATH/config
    echo 0x00197100 1 > $DCC_PATH/config
    echo 0x00198000 1 > $DCC_PATH/config
    echo 0x00198004 1 > $DCC_PATH/config
    echo 0x03D6D000 1 > $DCC_PATH/config # Dumping ITCM: 0x3d6d000, size: 0x4000 bytes
    echo 0x03D6D004 1 > $DCC_PATH/config
    echo 0x03D6D008 1 > $DCC_PATH/config
    echo 0x03D6D00C 1 > $DCC_PATH/config
    echo 0x03D6D010 1 > $DCC_PATH/config
    echo 0x03D6D014 1 > $DCC_PATH/config
    echo 0x03D6D018 1 > $DCC_PATH/config
    echo 0x03D6D01C 1 > $DCC_PATH/config
    echo 0x03D6D020 1 > $DCC_PATH/config
    echo 0x03D6D024 1 > $DCC_PATH/config
    echo 0x03D6D028 1 > $DCC_PATH/config
    echo 0x03D6D02C 1 > $DCC_PATH/config
    echo 0x03D6D030 1 > $DCC_PATH/config
    echo 0x03D6D034 1 > $DCC_PATH/config
    echo 0x03D6D038 1 > $DCC_PATH/config
    echo 0x03D6D03C 1 > $DCC_PATH/config
    echo 0x03D6D040 1 > $DCC_PATH/config
    echo 0x03D6D044 1 > $DCC_PATH/config
    echo 0x03D6D048 1 > $DCC_PATH/config
    echo 0x03D6D04C 1 > $DCC_PATH/config
    echo 0x03D6D050 1 > $DCC_PATH/config
    echo 0x03D6D054 1 > $DCC_PATH/config
    echo 0x03D6D058 1 > $DCC_PATH/config
    echo 0x03D6D05C 1 > $DCC_PATH/config
    echo 0x03D6D060 1 > $DCC_PATH/config
    echo 0x03D6D064 1 > $DCC_PATH/config
    echo 0x03D6D068 1 > $DCC_PATH/config
    echo 0x03D6D06C 1 > $DCC_PATH/config
    echo 0x03D6D070 1 > $DCC_PATH/config
    echo 0x03D6D074 1 > $DCC_PATH/config
    echo 0x03D6D078 1 > $DCC_PATH/config
    echo 0x03D6D07C 1 > $DCC_PATH/config
    echo 0x03D6D080 1 > $DCC_PATH/config
    echo 0x03D6D084 1 > $DCC_PATH/config
    echo 0x03D6D088 1 > $DCC_PATH/config
    echo 0x03D6D08C 1 > $DCC_PATH/config
    echo 0x03D6D090 1 > $DCC_PATH/config
    echo 0x03D6D094 1 > $DCC_PATH/config
    echo 0x03D6D098 1 > $DCC_PATH/config
    echo 0x03D6D09C 1 > $DCC_PATH/config
    echo 0x03D6D0A0 1 > $DCC_PATH/config
    echo 0x03D6D0A4 1 > $DCC_PATH/config
    echo 0x03D6D0A8 1 > $DCC_PATH/config
    echo 0x03D6D0AC 1 > $DCC_PATH/config
    echo 0x03D6D0B0 1 > $DCC_PATH/config
    echo 0x03D6D0B4 1 > $DCC_PATH/config
    echo 0x03D6D0B8 1 > $DCC_PATH/config
    echo 0x03D6D0BC 1 > $DCC_PATH/config
    echo 0x03D6D0C0 1 > $DCC_PATH/config
    echo 0x03D6D0C4 1 > $DCC_PATH/config
    echo 0x03D6D0C8 1 > $DCC_PATH/config
    echo 0x03D6D0CC 1 > $DCC_PATH/config
    echo 0x03D6D0D0 1 > $DCC_PATH/config
    echo 0x03D6D0D4 1 > $DCC_PATH/config
    echo 0x03D6D0D8 1 > $DCC_PATH/config
    echo 0x03D6D0DC 1 > $DCC_PATH/config
    echo 0x03D6D0E0 1 > $DCC_PATH/config
    echo 0x03D6D0E4 1 > $DCC_PATH/config
    echo 0x03D6D0E8 1 > $DCC_PATH/config
    echo 0x03D6D0EC 1 > $DCC_PATH/config
    echo 0x03D6D0F0 1 > $DCC_PATH/config
    echo 0x03D6D0F4 1 > $DCC_PATH/config
    echo 0x03D6D0F8 1 > $DCC_PATH/config
    echo 0x03D6D0FC 1 > $DCC_PATH/config
    echo 0x03D6D100 1 > $DCC_PATH/config
    echo 0x03D6D104 1 > $DCC_PATH/config
    echo 0x03D6D108 1 > $DCC_PATH/config
    echo 0x03D6D10C 1 > $DCC_PATH/config
    echo 0x03D6D110 1 > $DCC_PATH/config
    echo 0x03D6D114 1 > $DCC_PATH/config
    echo 0x03D6D118 1 > $DCC_PATH/config
    echo 0x03D6D11C 1 > $DCC_PATH/config
    echo 0x03D6D120 1 > $DCC_PATH/config
    echo 0x03D6D124 1 > $DCC_PATH/config
    echo 0x03D6D128 1 > $DCC_PATH/config
    echo 0x03D6D12C 1 > $DCC_PATH/config
    echo 0x03D6D130 1 > $DCC_PATH/config
    echo 0x03D6D134 1 > $DCC_PATH/config
    echo 0x03D6D138 1 > $DCC_PATH/config
    echo 0x03D6D13C 1 > $DCC_PATH/config
    echo 0x03D6D140 1 > $DCC_PATH/config
    echo 0x03D6D144 1 > $DCC_PATH/config
    echo 0x03D6D148 1 > $DCC_PATH/config
    echo 0x03D6D14C 1 > $DCC_PATH/config
    echo 0x03D6D150 1 > $DCC_PATH/config
    echo 0x03D6D154 1 > $DCC_PATH/config
    echo 0x03D6D158 1 > $DCC_PATH/config
    echo 0x03D6D15C 1 > $DCC_PATH/config
    echo 0x03D6D160 1 > $DCC_PATH/config
    echo 0x03D6D164 1 > $DCC_PATH/config
    echo 0x03D6D168 1 > $DCC_PATH/config
    echo 0x03D6D16C 1 > $DCC_PATH/config
    echo 0x03D6D170 1 > $DCC_PATH/config
    echo 0x03D6D174 1 > $DCC_PATH/config
    echo 0x03D6D178 1 > $DCC_PATH/config
    echo 0x03D6D17C 1 > $DCC_PATH/config
    echo 0x03D6D180 1 > $DCC_PATH/config
    echo 0x03D6D184 1 > $DCC_PATH/config
    echo 0x03D6D188 1 > $DCC_PATH/config
    echo 0x03D6D18C 1 > $DCC_PATH/config
    echo 0x03D6D190 1 > $DCC_PATH/config
    echo 0x03D6D194 1 > $DCC_PATH/config
    echo 0x03D6D198 1 > $DCC_PATH/config
    echo 0x03D6D19C 1 > $DCC_PATH/config
    echo 0x03D6D1A0 1 > $DCC_PATH/config
    echo 0x03D6D1A4 1 > $DCC_PATH/config
    echo 0x03D6D1A8 1 > $DCC_PATH/config
    echo 0x03D6D1AC 1 > $DCC_PATH/config
    echo 0x03D6D1B0 1 > $DCC_PATH/config
    echo 0x03D6D1B4 1 > $DCC_PATH/config
    echo 0x03D6D1B8 1 > $DCC_PATH/config
    echo 0x03D6D1BC 1 > $DCC_PATH/config
    echo 0x03D6D1C0 1 > $DCC_PATH/config
    echo 0x03D6D1C4 1 > $DCC_PATH/config
    echo 0x03D6D1C8 1 > $DCC_PATH/config
    echo 0x03D6D1CC 1 > $DCC_PATH/config
    echo 0x03D6D1D0 1 > $DCC_PATH/config
    echo 0x03D6D1D4 1 > $DCC_PATH/config
    echo 0x03D6D1D8 1 > $DCC_PATH/config
    echo 0x03D6D1DC 1 > $DCC_PATH/config
    echo 0x03D6D1E0 1 > $DCC_PATH/config
    echo 0x03D6D1E4 1 > $DCC_PATH/config
    echo 0x03D6D1E8 1 > $DCC_PATH/config
    echo 0x03D6D1EC 1 > $DCC_PATH/config
    echo 0x03D6D1F0 1 > $DCC_PATH/config
    echo 0x03D6D1F4 1 > $DCC_PATH/config
    echo 0x03D6D1F8 1 > $DCC_PATH/config
    echo 0x03D6D1FC 1 > $DCC_PATH/config
    echo 0x03D6D200 1 > $DCC_PATH/config
    echo 0x03D6D204 1 > $DCC_PATH/config
    echo 0x03D6D208 1 > $DCC_PATH/config
    echo 0x03D6D20C 1 > $DCC_PATH/config
    echo 0x03D6D210 1 > $DCC_PATH/config
    echo 0x03D6D214 1 > $DCC_PATH/config
    echo 0x03D6D218 1 > $DCC_PATH/config
    echo 0x03D6D21C 1 > $DCC_PATH/config
    echo 0x03D6D220 1 > $DCC_PATH/config
    echo 0x03D6D224 1 > $DCC_PATH/config
    echo 0x03D6D228 1 > $DCC_PATH/config
    echo 0x03D6D22C 1 > $DCC_PATH/config
    echo 0x03D6D230 1 > $DCC_PATH/config
    echo 0x03D6D234 1 > $DCC_PATH/config
    echo 0x03D6D238 1 > $DCC_PATH/config
    echo 0x03D6D23C 1 > $DCC_PATH/config
    echo 0x03D6D240 1 > $DCC_PATH/config
    echo 0x03D6D244 1 > $DCC_PATH/config
    echo 0x03D6D248 1 > $DCC_PATH/config
    echo 0x03D6D24C 1 > $DCC_PATH/config
    echo 0x03D6D250 1 > $DCC_PATH/config
    echo 0x03D6D254 1 > $DCC_PATH/config
    echo 0x03D6D258 1 > $DCC_PATH/config
    echo 0x03D6D25C 1 > $DCC_PATH/config
    echo 0x03D6D260 1 > $DCC_PATH/config
    echo 0x03D6D264 1 > $DCC_PATH/config
    echo 0x03D6D268 1 > $DCC_PATH/config
    echo 0x03D6D26C 1 > $DCC_PATH/config
    echo 0x03D6D270 1 > $DCC_PATH/config
    echo 0x03D6D274 1 > $DCC_PATH/config
    echo 0x03D6D278 1 > $DCC_PATH/config
    echo 0x03D6D27C 1 > $DCC_PATH/config
    echo 0x03D6D280 1 > $DCC_PATH/config
    echo 0x03D6D284 1 > $DCC_PATH/config
    echo 0x03D6D288 1 > $DCC_PATH/config
    echo 0x03D6D28C 1 > $DCC_PATH/config
    echo 0x03D6D290 1 > $DCC_PATH/config
    echo 0x03D6D294 1 > $DCC_PATH/config
    echo 0x03D6D298 1 > $DCC_PATH/config
    echo 0x03D6D29C 1 > $DCC_PATH/config
    echo 0x03D6D2A0 1 > $DCC_PATH/config
    echo 0x03D6D2A4 1 > $DCC_PATH/config
    echo 0x03D6D2A8 1 > $DCC_PATH/config
    echo 0x03D6D2AC 1 > $DCC_PATH/config
    echo 0x03D6D2B0 1 > $DCC_PATH/config
    echo 0x03D6D2B4 1 > $DCC_PATH/config
    echo 0x03D6D2B8 1 > $DCC_PATH/config
    echo 0x03D6D2BC 1 > $DCC_PATH/config
    echo 0x03D6D2C0 1 > $DCC_PATH/config
    echo 0x03D6D2C4 1 > $DCC_PATH/config
    echo 0x03D6D2C8 1 > $DCC_PATH/config
    echo 0x03D6D2CC 1 > $DCC_PATH/config
    echo 0x03D6D2D0 1 > $DCC_PATH/config
    echo 0x03D6D2D4 1 > $DCC_PATH/config
    echo 0x03D6D2D8 1 > $DCC_PATH/config
    echo 0x03D6D2DC 1 > $DCC_PATH/config
    echo 0x03D6D2E0 1 > $DCC_PATH/config
    echo 0x03D6D2E4 1 > $DCC_PATH/config
    echo 0x03D6D2E8 1 > $DCC_PATH/config
    echo 0x03D6D2EC 1 > $DCC_PATH/config
    echo 0x03D6D2F0 1 > $DCC_PATH/config
    echo 0x03D6D2F4 1 > $DCC_PATH/config
    echo 0x03D6D2F8 1 > $DCC_PATH/config
    echo 0x03D6D2FC 1 > $DCC_PATH/config
    echo 0x03D6D300 1 > $DCC_PATH/config
    echo 0x03D6D304 1 > $DCC_PATH/config
    echo 0x03D6D308 1 > $DCC_PATH/config
    echo 0x03D6D30C 1 > $DCC_PATH/config
    echo 0x03D6D310 1 > $DCC_PATH/config
    echo 0x03D6D314 1 > $DCC_PATH/config
    echo 0x03D6D318 1 > $DCC_PATH/config
    echo 0x03D6D31C 1 > $DCC_PATH/config
    echo 0x03D6D320 1 > $DCC_PATH/config
    echo 0x03D6D324 1 > $DCC_PATH/config
    echo 0x03D6D328 1 > $DCC_PATH/config
    echo 0x03D6D32C 1 > $DCC_PATH/config
    echo 0x03D6D330 1 > $DCC_PATH/config
    echo 0x03D6D334 1 > $DCC_PATH/config
    echo 0x03D6D338 1 > $DCC_PATH/config
    echo 0x03D6D33C 1 > $DCC_PATH/config
    echo 0x03D6D340 1 > $DCC_PATH/config
    echo 0x03D6D344 1 > $DCC_PATH/config
    echo 0x03D6D348 1 > $DCC_PATH/config
    echo 0x03D6D34C 1 > $DCC_PATH/config
    echo 0x03D6D350 1 > $DCC_PATH/config
    echo 0x03D6D354 1 > $DCC_PATH/config
    echo 0x03D6D358 1 > $DCC_PATH/config
    echo 0x03D6D35C 1 > $DCC_PATH/config
    echo 0x03D6D360 1 > $DCC_PATH/config
    echo 0x03D6D364 1 > $DCC_PATH/config
    echo 0x03D6D368 1 > $DCC_PATH/config
    echo 0x03D6D36C 1 > $DCC_PATH/config
    echo 0x03D6D370 1 > $DCC_PATH/config
    echo 0x03D6D374 1 > $DCC_PATH/config
    echo 0x03D6D378 1 > $DCC_PATH/config
    echo 0x03D6D37C 1 > $DCC_PATH/config
    echo 0x03D6D380 1 > $DCC_PATH/config
    echo 0x03D6D384 1 > $DCC_PATH/config
    echo 0x03D6D388 1 > $DCC_PATH/config
    echo 0x03D6D38C 1 > $DCC_PATH/config
    echo 0x03D6D390 1 > $DCC_PATH/config
    echo 0x03D6D394 1 > $DCC_PATH/config
    echo 0x03D6D398 1 > $DCC_PATH/config
    echo 0x03D6D39C 1 > $DCC_PATH/config
    echo 0x03D6D3A0 1 > $DCC_PATH/config
    echo 0x03D6D3A4 1 > $DCC_PATH/config
    echo 0x03D6D3A8 1 > $DCC_PATH/config
    echo 0x03D6D3AC 1 > $DCC_PATH/config
    echo 0x03D6D3B0 1 > $DCC_PATH/config
    echo 0x03D6D3B4 1 > $DCC_PATH/config
    echo 0x03D6D3B8 1 > $DCC_PATH/config
    echo 0x03D6D3BC 1 > $DCC_PATH/config
    echo 0x03D6D3C0 1 > $DCC_PATH/config
    echo 0x03D6D3C4 1 > $DCC_PATH/config
    echo 0x03D6D3C8 1 > $DCC_PATH/config
    echo 0x03D6D3CC 1 > $DCC_PATH/config
    echo 0x03D6D3D0 1 > $DCC_PATH/config
    echo 0x03D6D3D4 1 > $DCC_PATH/config
    echo 0x03D6D3D8 1 > $DCC_PATH/config
    echo 0x03D6D3DC 1 > $DCC_PATH/config
    echo 0x03D6D3E0 1 > $DCC_PATH/config
    echo 0x03D6D3E4 1 > $DCC_PATH/config
    echo 0x03D6D3E8 1 > $DCC_PATH/config
    echo 0x03D6D3EC 1 > $DCC_PATH/config
    echo 0x03D6D3F0 1 > $DCC_PATH/config
    echo 0x03D6D3F4 1 > $DCC_PATH/config
    echo 0x03D6D3F8 1 > $DCC_PATH/config
    echo 0x03D6D3FC 1 > $DCC_PATH/config
    echo 0x03D6D400 1 > $DCC_PATH/config
    echo 0x03D6D404 1 > $DCC_PATH/config
    echo 0x03D6D408 1 > $DCC_PATH/config
    echo 0x03D6D40C 1 > $DCC_PATH/config
    echo 0x03D6D410 1 > $DCC_PATH/config
    echo 0x03D6D414 1 > $DCC_PATH/config
    echo 0x03D6D418 1 > $DCC_PATH/config
    echo 0x03D6D41C 1 > $DCC_PATH/config
    echo 0x03D6D420 1 > $DCC_PATH/config
    echo 0x03D6D424 1 > $DCC_PATH/config
    echo 0x03D6D428 1 > $DCC_PATH/config
    echo 0x03D6D42C 1 > $DCC_PATH/config
    echo 0x03D6D430 1 > $DCC_PATH/config
    echo 0x03D6D434 1 > $DCC_PATH/config
    echo 0x03D6D438 1 > $DCC_PATH/config
    echo 0x03D6D43C 1 > $DCC_PATH/config
    echo 0x03D6D440 1 > $DCC_PATH/config
    echo 0x03D6D444 1 > $DCC_PATH/config
    echo 0x03D6D448 1 > $DCC_PATH/config
    echo 0x03D6D44C 1 > $DCC_PATH/config
    echo 0x03D6D450 1 > $DCC_PATH/config
    echo 0x03D6D454 1 > $DCC_PATH/config
    echo 0x03D6D458 1 > $DCC_PATH/config
    echo 0x03D6D45C 1 > $DCC_PATH/config
    echo 0x03D6D460 1 > $DCC_PATH/config
    echo 0x03D6D464 1 > $DCC_PATH/config
    echo 0x03D6D468 1 > $DCC_PATH/config
    echo 0x03D6D46C 1 > $DCC_PATH/config
    echo 0x03D6D470 1 > $DCC_PATH/config
    echo 0x03D6D474 1 > $DCC_PATH/config
    echo 0x03D6D478 1 > $DCC_PATH/config
    echo 0x03D6D47C 1 > $DCC_PATH/config
    echo 0x03D6D480 1 > $DCC_PATH/config
    echo 0x03D6D484 1 > $DCC_PATH/config
    echo 0x03D6D488 1 > $DCC_PATH/config
    echo 0x03D6D48C 1 > $DCC_PATH/config
    echo 0x03D6D490 1 > $DCC_PATH/config
    echo 0x03D6D494 1 > $DCC_PATH/config
    echo 0x03D6D498 1 > $DCC_PATH/config
    echo 0x03D6D49C 1 > $DCC_PATH/config
    echo 0x03D6D4A0 1 > $DCC_PATH/config
    echo 0x03D6D4A4 1 > $DCC_PATH/config
    echo 0x03D6D4A8 1 > $DCC_PATH/config
    echo 0x03D6D4AC 1 > $DCC_PATH/config
    echo 0x03D6D4B0 1 > $DCC_PATH/config
    echo 0x03D6D4B4 1 > $DCC_PATH/config
    echo 0x03D6D4B8 1 > $DCC_PATH/config
    echo 0x03D6D4BC 1 > $DCC_PATH/config
    echo 0x03D6D4C0 1 > $DCC_PATH/config
    echo 0x03D6D4C4 1 > $DCC_PATH/config
    echo 0x03D6D4C8 1 > $DCC_PATH/config
    echo 0x03D6D4CC 1 > $DCC_PATH/config
    echo 0x03D6D4D0 1 > $DCC_PATH/config
    echo 0x03D6D4D4 1 > $DCC_PATH/config
    echo 0x03D6D4D8 1 > $DCC_PATH/config
    echo 0x03D6D4DC 1 > $DCC_PATH/config
    echo 0x03D6D4E0 1 > $DCC_PATH/config
    echo 0x03D6D4E4 1 > $DCC_PATH/config
    echo 0x03D6D4E8 1 > $DCC_PATH/config
    echo 0x03D6D4EC 1 > $DCC_PATH/config
    echo 0x03D6D4F0 1 > $DCC_PATH/config
    echo 0x03D6D4F4 1 > $DCC_PATH/config
    echo 0x03D6D4F8 1 > $DCC_PATH/config
    echo 0x03D6D4FC 1 > $DCC_PATH/config
    echo 0x03D6D500 1 > $DCC_PATH/config
    echo 0x03D6D504 1 > $DCC_PATH/config
    echo 0x03D6D508 1 > $DCC_PATH/config
    echo 0x03D6D50C 1 > $DCC_PATH/config
    echo 0x03D6D510 1 > $DCC_PATH/config
    echo 0x03D6D514 1 > $DCC_PATH/config
    echo 0x03D6D518 1 > $DCC_PATH/config
    echo 0x03D6D51C 1 > $DCC_PATH/config
    echo 0x03D6D520 1 > $DCC_PATH/config
    echo 0x03D6D524 1 > $DCC_PATH/config
    echo 0x03D6D528 1 > $DCC_PATH/config
    echo 0x03D6D52C 1 > $DCC_PATH/config
    echo 0x03D6D530 1 > $DCC_PATH/config
    echo 0x03D6D534 1 > $DCC_PATH/config
    echo 0x03D6D538 1 > $DCC_PATH/config
    echo 0x03D6D53C 1 > $DCC_PATH/config
    echo 0x03D6D540 1 > $DCC_PATH/config
    echo 0x03D6D544 1 > $DCC_PATH/config
    echo 0x03D6D548 1 > $DCC_PATH/config
    echo 0x03D6D54C 1 > $DCC_PATH/config
    echo 0x03D6D550 1 > $DCC_PATH/config
    echo 0x03D6D554 1 > $DCC_PATH/config
    echo 0x03D6D558 1 > $DCC_PATH/config
    echo 0x03D6D55C 1 > $DCC_PATH/config
    echo 0x03D6D560 1 > $DCC_PATH/config
    echo 0x03D6D564 1 > $DCC_PATH/config
    echo 0x03D6D568 1 > $DCC_PATH/config
    echo 0x03D6D56C 1 > $DCC_PATH/config
    echo 0x03D6D570 1 > $DCC_PATH/config
    echo 0x03D6D574 1 > $DCC_PATH/config
    echo 0x03D6D578 1 > $DCC_PATH/config
    echo 0x03D6D57C 1 > $DCC_PATH/config
    echo 0x03D6D580 1 > $DCC_PATH/config
    echo 0x03D6D584 1 > $DCC_PATH/config
    echo 0x03D6D588 1 > $DCC_PATH/config
    echo 0x03D6D58C 1 > $DCC_PATH/config
    echo 0x03D6D590 1 > $DCC_PATH/config
    echo 0x03D6D594 1 > $DCC_PATH/config
    echo 0x03D6D598 1 > $DCC_PATH/config
    echo 0x03D6D59C 1 > $DCC_PATH/config
    echo 0x03D6D5A0 1 > $DCC_PATH/config
    echo 0x03D6D5A4 1 > $DCC_PATH/config
    echo 0x03D6D5A8 1 > $DCC_PATH/config
    echo 0x03D6D5AC 1 > $DCC_PATH/config
    echo 0x03D6D5B0 1 > $DCC_PATH/config
    echo 0x03D6D5B4 1 > $DCC_PATH/config
    echo 0x03D6D5B8 1 > $DCC_PATH/config
    echo 0x03D6D5BC 1 > $DCC_PATH/config
    echo 0x03D6D5C0 1 > $DCC_PATH/config
    echo 0x03D6D5C4 1 > $DCC_PATH/config
    echo 0x03D6D5C8 1 > $DCC_PATH/config
    echo 0x03D6D5CC 1 > $DCC_PATH/config
    echo 0x03D6D5D0 1 > $DCC_PATH/config
    echo 0x03D6D5D4 1 > $DCC_PATH/config
    echo 0x03D6D5D8 1 > $DCC_PATH/config
    echo 0x03D6D5DC 1 > $DCC_PATH/config
    echo 0x03D6D5E0 1 > $DCC_PATH/config
    echo 0x03D6D5E4 1 > $DCC_PATH/config
    echo 0x03D6D5E8 1 > $DCC_PATH/config
    echo 0x03D6D5EC 1 > $DCC_PATH/config
    echo 0x03D6D5F0 1 > $DCC_PATH/config
    echo 0x03D6D5F4 1 > $DCC_PATH/config
    echo 0x03D6D5F8 1 > $DCC_PATH/config
    echo 0x03D6D5FC 1 > $DCC_PATH/config
    echo 0x03D6D600 1 > $DCC_PATH/config
    echo 0x03D6D604 1 > $DCC_PATH/config
    echo 0x03D6D608 1 > $DCC_PATH/config
    echo 0x03D6D60C 1 > $DCC_PATH/config
    echo 0x03D6D610 1 > $DCC_PATH/config
    echo 0x03D6D614 1 > $DCC_PATH/config
    echo 0x03D6D618 1 > $DCC_PATH/config
    echo 0x03D6D61C 1 > $DCC_PATH/config
    echo 0x03D6D620 1 > $DCC_PATH/config
    echo 0x03D6D624 1 > $DCC_PATH/config
    echo 0x03D6D628 1 > $DCC_PATH/config
    echo 0x03D6D62C 1 > $DCC_PATH/config
    echo 0x03D6D630 1 > $DCC_PATH/config
    echo 0x03D6D634 1 > $DCC_PATH/config
    echo 0x03D6D638 1 > $DCC_PATH/config
    echo 0x03D6D63C 1 > $DCC_PATH/config
    echo 0x03D6D640 1 > $DCC_PATH/config
    echo 0x03D6D644 1 > $DCC_PATH/config
    echo 0x03D6D648 1 > $DCC_PATH/config
    echo 0x03D6D64C 1 > $DCC_PATH/config
    echo 0x03D6D650 1 > $DCC_PATH/config
    echo 0x03D6D654 1 > $DCC_PATH/config
    echo 0x03D6D658 1 > $DCC_PATH/config
    echo 0x03D6D65C 1 > $DCC_PATH/config
    echo 0x03D6D660 1 > $DCC_PATH/config
    echo 0x03D6D664 1 > $DCC_PATH/config
    echo 0x03D6D668 1 > $DCC_PATH/config
    echo 0x03D6D66C 1 > $DCC_PATH/config
    echo 0x03D6D670 1 > $DCC_PATH/config
    echo 0x03D6D674 1 > $DCC_PATH/config
    echo 0x03D6D678 1 > $DCC_PATH/config
    echo 0x03D6D67C 1 > $DCC_PATH/config
    echo 0x03D6D680 1 > $DCC_PATH/config
    echo 0x03D6D684 1 > $DCC_PATH/config
    echo 0x03D6D688 1 > $DCC_PATH/config
    echo 0x03D6D68C 1 > $DCC_PATH/config
    echo 0x03D6D690 1 > $DCC_PATH/config
    echo 0x03D6D694 1 > $DCC_PATH/config
    echo 0x03D6D698 1 > $DCC_PATH/config
    echo 0x03D6D69C 1 > $DCC_PATH/config
    echo 0x03D6D6A0 1 > $DCC_PATH/config
    echo 0x03D6D6A4 1 > $DCC_PATH/config
    echo 0x03D6D6A8 1 > $DCC_PATH/config
    echo 0x03D6D6AC 1 > $DCC_PATH/config
    echo 0x03D6D6B0 1 > $DCC_PATH/config
    echo 0x03D6D6B4 1 > $DCC_PATH/config
    echo 0x03D6D6B8 1 > $DCC_PATH/config
    echo 0x03D6D6BC 1 > $DCC_PATH/config
    echo 0x03D6D6C0 1 > $DCC_PATH/config
    echo 0x03D6D6C4 1 > $DCC_PATH/config
    echo 0x03D6D6C8 1 > $DCC_PATH/config
    echo 0x03D6D6CC 1 > $DCC_PATH/config
    echo 0x03D6D6D0 1 > $DCC_PATH/config
    echo 0x03D6D6D4 1 > $DCC_PATH/config
    echo 0x03D6D6D8 1 > $DCC_PATH/config
    echo 0x03D6D6DC 1 > $DCC_PATH/config
    echo 0x03D6D6E0 1 > $DCC_PATH/config
    echo 0x03D6D6E4 1 > $DCC_PATH/config
    echo 0x03D6D6E8 1 > $DCC_PATH/config
    echo 0x03D6D6EC 1 > $DCC_PATH/config
    echo 0x03D6D6F0 1 > $DCC_PATH/config
    echo 0x03D6D6F4 1 > $DCC_PATH/config
    echo 0x03D6D6F8 1 > $DCC_PATH/config
    echo 0x03D6D6FC 1 > $DCC_PATH/config
    echo 0x03D6D700 1 > $DCC_PATH/config
    echo 0x03D6D704 1 > $DCC_PATH/config
    echo 0x03D6D708 1 > $DCC_PATH/config
    echo 0x03D6D70C 1 > $DCC_PATH/config
    echo 0x03D6D710 1 > $DCC_PATH/config
    echo 0x03D6D714 1 > $DCC_PATH/config
    echo 0x03D6D718 1 > $DCC_PATH/config
    echo 0x03D6D71C 1 > $DCC_PATH/config
    echo 0x03D6D720 1 > $DCC_PATH/config
    echo 0x03D6D724 1 > $DCC_PATH/config
    echo 0x03D6D728 1 > $DCC_PATH/config
    echo 0x03D6D72C 1 > $DCC_PATH/config
    echo 0x03D6D730 1 > $DCC_PATH/config
    echo 0x03D6D734 1 > $DCC_PATH/config
    echo 0x03D6D738 1 > $DCC_PATH/config
    echo 0x03D6D73C 1 > $DCC_PATH/config
    echo 0x03D6D740 1 > $DCC_PATH/config
    echo 0x03D6D744 1 > $DCC_PATH/config
    echo 0x03D6D748 1 > $DCC_PATH/config
    echo 0x03D6D74C 1 > $DCC_PATH/config
    echo 0x03D6D750 1 > $DCC_PATH/config
    echo 0x03D6D754 1 > $DCC_PATH/config
    echo 0x03D6D758 1 > $DCC_PATH/config
    echo 0x03D6D75C 1 > $DCC_PATH/config
    echo 0x03D6D760 1 > $DCC_PATH/config
    echo 0x03D6D764 1 > $DCC_PATH/config
    echo 0x03D6D768 1 > $DCC_PATH/config
    echo 0x03D6D76C 1 > $DCC_PATH/config
    echo 0x03D6D770 1 > $DCC_PATH/config
    echo 0x03D6D774 1 > $DCC_PATH/config
    echo 0x03D6D778 1 > $DCC_PATH/config
    echo 0x03D6D77C 1 > $DCC_PATH/config
    echo 0x03D6D780 1 > $DCC_PATH/config
    echo 0x03D6D784 1 > $DCC_PATH/config
    echo 0x03D6D788 1 > $DCC_PATH/config
    echo 0x03D6D78C 1 > $DCC_PATH/config
    echo 0x03D6D790 1 > $DCC_PATH/config
    echo 0x03D6D794 1 > $DCC_PATH/config
    echo 0x03D6D798 1 > $DCC_PATH/config
    echo 0x03D6D79C 1 > $DCC_PATH/config
    echo 0x03D6D7A0 1 > $DCC_PATH/config
    echo 0x03D6D7A4 1 > $DCC_PATH/config
    echo 0x03D6D7A8 1 > $DCC_PATH/config
    echo 0x03D6D7AC 1 > $DCC_PATH/config
    echo 0x03D6D7B0 1 > $DCC_PATH/config
    echo 0x03D6D7B4 1 > $DCC_PATH/config
    echo 0x03D6D7B8 1 > $DCC_PATH/config
    echo 0x03D6D7BC 1 > $DCC_PATH/config
    echo 0x03D6D7C0 1 > $DCC_PATH/config
    echo 0x03D6D7C4 1 > $DCC_PATH/config
    echo 0x03D6D7C8 1 > $DCC_PATH/config
    echo 0x03D6D7CC 1 > $DCC_PATH/config
    echo 0x03D6D7D0 1 > $DCC_PATH/config
    echo 0x03D6D7D4 1 > $DCC_PATH/config
    echo 0x03D6D7D8 1 > $DCC_PATH/config
    echo 0x03D6D7DC 1 > $DCC_PATH/config
    echo 0x03D6D7E0 1 > $DCC_PATH/config
    echo 0x03D6D7E4 1 > $DCC_PATH/config
    echo 0x03D6D7E8 1 > $DCC_PATH/config
    echo 0x03D6D7EC 1 > $DCC_PATH/config
    echo 0x03D6D7F0 1 > $DCC_PATH/config
    echo 0x03D6D7F4 1 > $DCC_PATH/config
    echo 0x03D6D7F8 1 > $DCC_PATH/config
    echo 0x03D6D7FC 1 > $DCC_PATH/config
    echo 0x03D6D800 1 > $DCC_PATH/config
    echo 0x03D6D804 1 > $DCC_PATH/config
    echo 0x03D6D808 1 > $DCC_PATH/config
    echo 0x03D6D80C 1 > $DCC_PATH/config
    echo 0x03D6D810 1 > $DCC_PATH/config
    echo 0x03D6D814 1 > $DCC_PATH/config
    echo 0x03D6D818 1 > $DCC_PATH/config
    echo 0x03D6D81C 1 > $DCC_PATH/config
    echo 0x03D6D820 1 > $DCC_PATH/config
    echo 0x03D6D824 1 > $DCC_PATH/config
    echo 0x03D6D828 1 > $DCC_PATH/config
    echo 0x03D6D82C 1 > $DCC_PATH/config
    echo 0x03D6D830 1 > $DCC_PATH/config
    echo 0x03D6D834 1 > $DCC_PATH/config
    echo 0x03D6D838 1 > $DCC_PATH/config
    echo 0x03D6D83C 1 > $DCC_PATH/config
    echo 0x03D6D840 1 > $DCC_PATH/config
    echo 0x03D6D844 1 > $DCC_PATH/config
    echo 0x03D6D848 1 > $DCC_PATH/config
    echo 0x03D6D84C 1 > $DCC_PATH/config
    echo 0x03D6D850 1 > $DCC_PATH/config
    echo 0x03D6D854 1 > $DCC_PATH/config
    echo 0x03D6D858 1 > $DCC_PATH/config
    echo 0x03D6D85C 1 > $DCC_PATH/config
    echo 0x03D6D860 1 > $DCC_PATH/config
    echo 0x03D6D864 1 > $DCC_PATH/config
    echo 0x03D6D868 1 > $DCC_PATH/config
    echo 0x03D6D86C 1 > $DCC_PATH/config
    echo 0x03D6D870 1 > $DCC_PATH/config
    echo 0x03D6D874 1 > $DCC_PATH/config
    echo 0x03D6D878 1 > $DCC_PATH/config
    echo 0x03D6D87C 1 > $DCC_PATH/config
    echo 0x03D6D880 1 > $DCC_PATH/config
    echo 0x03D6D884 1 > $DCC_PATH/config
    echo 0x03D6D888 1 > $DCC_PATH/config
    echo 0x03D6D88C 1 > $DCC_PATH/config
    echo 0x03D6D890 1 > $DCC_PATH/config
    echo 0x03D6D894 1 > $DCC_PATH/config
    echo 0x03D6D898 1 > $DCC_PATH/config
    echo 0x03D6D89C 1 > $DCC_PATH/config
    echo 0x03D6D8A0 1 > $DCC_PATH/config
    echo 0x03D6D8A4 1 > $DCC_PATH/config
    echo 0x03D6D8A8 1 > $DCC_PATH/config
    echo 0x03D6D8AC 1 > $DCC_PATH/config
    echo 0x03D6D8B0 1 > $DCC_PATH/config
    echo 0x03D6D8B4 1 > $DCC_PATH/config
    echo 0x03D6D8B8 1 > $DCC_PATH/config
    echo 0x03D6D8BC 1 > $DCC_PATH/config
    echo 0x03D6D8C0 1 > $DCC_PATH/config
    echo 0x03D6D8C4 1 > $DCC_PATH/config
    echo 0x03D6D8C8 1 > $DCC_PATH/config
    echo 0x03D6D8CC 1 > $DCC_PATH/config
    echo 0x03D6D8D0 1 > $DCC_PATH/config
    echo 0x03D6D8D4 1 > $DCC_PATH/config
    echo 0x03D6D8D8 1 > $DCC_PATH/config
    echo 0x03D6D8DC 1 > $DCC_PATH/config
    echo 0x03D6D8E0 1 > $DCC_PATH/config
    echo 0x03D6D8E4 1 > $DCC_PATH/config
    echo 0x03D6D8E8 1 > $DCC_PATH/config
    echo 0x03D6D8EC 1 > $DCC_PATH/config
    echo 0x03D6D8F0 1 > $DCC_PATH/config
    echo 0x03D6D8F4 1 > $DCC_PATH/config
    echo 0x03D6D8F8 1 > $DCC_PATH/config
    echo 0x03D6D8FC 1 > $DCC_PATH/config
    echo 0x03D6D900 1 > $DCC_PATH/config
    echo 0x03D6D904 1 > $DCC_PATH/config
    echo 0x03D6D908 1 > $DCC_PATH/config
    echo 0x03D6D90C 1 > $DCC_PATH/config
    echo 0x03D6D910 1 > $DCC_PATH/config
    echo 0x03D6D914 1 > $DCC_PATH/config
    echo 0x03D6D918 1 > $DCC_PATH/config
    echo 0x03D6D91C 1 > $DCC_PATH/config
    echo 0x03D6D920 1 > $DCC_PATH/config
    echo 0x03D6D924 1 > $DCC_PATH/config
    echo 0x03D6D928 1 > $DCC_PATH/config
    echo 0x03D6D92C 1 > $DCC_PATH/config
    echo 0x03D6D930 1 > $DCC_PATH/config
    echo 0x03D6D934 1 > $DCC_PATH/config
    echo 0x03D6D938 1 > $DCC_PATH/config
    echo 0x03D6D93C 1 > $DCC_PATH/config
    echo 0x03D6D940 1 > $DCC_PATH/config
    echo 0x03D6D944 1 > $DCC_PATH/config
    echo 0x03D6D948 1 > $DCC_PATH/config
    echo 0x03D6D94C 1 > $DCC_PATH/config
    echo 0x03D6D950 1 > $DCC_PATH/config
    echo 0x03D6D954 1 > $DCC_PATH/config
    echo 0x03D6D958 1 > $DCC_PATH/config
    echo 0x03D6D95C 1 > $DCC_PATH/config
    echo 0x03D6D960 1 > $DCC_PATH/config
    echo 0x03D6D964 1 > $DCC_PATH/config
    echo 0x03D6D968 1 > $DCC_PATH/config
    echo 0x03D6D96C 1 > $DCC_PATH/config
    echo 0x03D6D970 1 > $DCC_PATH/config
    echo 0x03D6D974 1 > $DCC_PATH/config
    echo 0x03D6D978 1 > $DCC_PATH/config
    echo 0x03D6D97C 1 > $DCC_PATH/config
    echo 0x03D6D980 1 > $DCC_PATH/config
    echo 0x03D6D984 1 > $DCC_PATH/config
    echo 0x03D6D988 1 > $DCC_PATH/config
    echo 0x03D6D98C 1 > $DCC_PATH/config
    echo 0x03D6D990 1 > $DCC_PATH/config
    echo 0x03D6D994 1 > $DCC_PATH/config
    echo 0x03D6D998 1 > $DCC_PATH/config
    echo 0x03D6D99C 1 > $DCC_PATH/config
    echo 0x03D6D9A0 1 > $DCC_PATH/config
    echo 0x03D6D9A4 1 > $DCC_PATH/config
    echo 0x03D6D9A8 1 > $DCC_PATH/config
    echo 0x03D6D9AC 1 > $DCC_PATH/config
    echo 0x03D6D9B0 1 > $DCC_PATH/config
    echo 0x03D6D9B4 1 > $DCC_PATH/config
    echo 0x03D6D9B8 1 > $DCC_PATH/config
    echo 0x03D6D9BC 1 > $DCC_PATH/config
    echo 0x03D6D9C0 1 > $DCC_PATH/config
    echo 0x03D6D9C4 1 > $DCC_PATH/config
    echo 0x03D6D9C8 1 > $DCC_PATH/config
    echo 0x03D6D9CC 1 > $DCC_PATH/config
    echo 0x03D6D9D0 1 > $DCC_PATH/config
    echo 0x03D6D9D4 1 > $DCC_PATH/config
    echo 0x03D6D9D8 1 > $DCC_PATH/config
    echo 0x03D6D9DC 1 > $DCC_PATH/config
    echo 0x03D6D9E0 1 > $DCC_PATH/config
    echo 0x03D6D9E4 1 > $DCC_PATH/config
    echo 0x03D6D9E8 1 > $DCC_PATH/config
    echo 0x03D6D9EC 1 > $DCC_PATH/config
    echo 0x03D6D9F0 1 > $DCC_PATH/config
    echo 0x03D6D9F4 1 > $DCC_PATH/config
    echo 0x03D6D9F8 1 > $DCC_PATH/config
    echo 0x03D6D9FC 1 > $DCC_PATH/config
    echo 0x03D6DA00 1 > $DCC_PATH/config
    echo 0x03D6DA04 1 > $DCC_PATH/config
    echo 0x03D6DA08 1 > $DCC_PATH/config
    echo 0x03D6DA0C 1 > $DCC_PATH/config
    echo 0x03D6DA10 1 > $DCC_PATH/config
    echo 0x03D6DA14 1 > $DCC_PATH/config
    echo 0x03D6DA18 1 > $DCC_PATH/config
    echo 0x03D6DA1C 1 > $DCC_PATH/config
    echo 0x03D6DA20 1 > $DCC_PATH/config
    echo 0x03D6DA24 1 > $DCC_PATH/config
    echo 0x03D6DA28 1 > $DCC_PATH/config
    echo 0x03D6DA2C 1 > $DCC_PATH/config
    echo 0x03D6DA30 1 > $DCC_PATH/config
    echo 0x03D6DA34 1 > $DCC_PATH/config
    echo 0x03D6DA38 1 > $DCC_PATH/config
    echo 0x03D6DA3C 1 > $DCC_PATH/config
    echo 0x03D6DA40 1 > $DCC_PATH/config
    echo 0x03D6DA44 1 > $DCC_PATH/config
    echo 0x03D6DA48 1 > $DCC_PATH/config
    echo 0x03D6DA4C 1 > $DCC_PATH/config
    echo 0x03D6DA50 1 > $DCC_PATH/config
    echo 0x03D6DA54 1 > $DCC_PATH/config
    echo 0x03D6DA58 1 > $DCC_PATH/config
    echo 0x03D6DA5C 1 > $DCC_PATH/config
    echo 0x03D6DA60 1 > $DCC_PATH/config
    echo 0x03D6DA64 1 > $DCC_PATH/config
    echo 0x03D6DA68 1 > $DCC_PATH/config
    echo 0x03D6DA6C 1 > $DCC_PATH/config
    echo 0x03D6DA70 1 > $DCC_PATH/config
    echo 0x03D6DA74 1 > $DCC_PATH/config
    echo 0x03D6DA78 1 > $DCC_PATH/config
    echo 0x03D6DA7C 1 > $DCC_PATH/config
    echo 0x03D6DA80 1 > $DCC_PATH/config
    echo 0x03D6DA84 1 > $DCC_PATH/config
    echo 0x03D6DA88 1 > $DCC_PATH/config
    echo 0x03D6DA8C 1 > $DCC_PATH/config
    echo 0x03D6DA90 1 > $DCC_PATH/config
    echo 0x03D6DA94 1 > $DCC_PATH/config
    echo 0x03D6DA98 1 > $DCC_PATH/config
    echo 0x03D6DA9C 1 > $DCC_PATH/config
    echo 0x03D6DAA0 1 > $DCC_PATH/config
    echo 0x03D6DAA4 1 > $DCC_PATH/config
    echo 0x03D6DAA8 1 > $DCC_PATH/config
    echo 0x03D6DAAC 1 > $DCC_PATH/config
    echo 0x03D6DAB0 1 > $DCC_PATH/config
    echo 0x03D6DAB4 1 > $DCC_PATH/config
    echo 0x03D6DAB8 1 > $DCC_PATH/config
    echo 0x03D6DABC 1 > $DCC_PATH/config
    echo 0x03D6DAC0 1 > $DCC_PATH/config
    echo 0x03D6DAC4 1 > $DCC_PATH/config
    echo 0x03D6DAC8 1 > $DCC_PATH/config
    echo 0x03D6DACC 1 > $DCC_PATH/config
    echo 0x03D6DAD0 1 > $DCC_PATH/config
    echo 0x03D6DAD4 1 > $DCC_PATH/config
    echo 0x03D6DAD8 1 > $DCC_PATH/config
    echo 0x03D6DADC 1 > $DCC_PATH/config
    echo 0x03D6DAE0 1 > $DCC_PATH/config
    echo 0x03D6DAE4 1 > $DCC_PATH/config
    echo 0x03D6DAE8 1 > $DCC_PATH/config
    echo 0x03D6DAEC 1 > $DCC_PATH/config
    echo 0x03D6DAF0 1 > $DCC_PATH/config
    echo 0x03D6DAF4 1 > $DCC_PATH/config
    echo 0x03D6DAF8 1 > $DCC_PATH/config
    echo 0x03D6DAFC 1 > $DCC_PATH/config
    echo 0x03D6DB00 1 > $DCC_PATH/config
    echo 0x03D6DB04 1 > $DCC_PATH/config
    echo 0x03D6DB08 1 > $DCC_PATH/config
    echo 0x03D6DB0C 1 > $DCC_PATH/config
    echo 0x03D6DB10 1 > $DCC_PATH/config
    echo 0x03D6DB14 1 > $DCC_PATH/config
    echo 0x03D6DB18 1 > $DCC_PATH/config
    echo 0x03D6DB1C 1 > $DCC_PATH/config
    echo 0x03D6DB20 1 > $DCC_PATH/config
    echo 0x03D6DB24 1 > $DCC_PATH/config
    echo 0x03D6DB28 1 > $DCC_PATH/config
    echo 0x03D6DB2C 1 > $DCC_PATH/config
    echo 0x03D6DB30 1 > $DCC_PATH/config
    echo 0x03D6DB34 1 > $DCC_PATH/config
    echo 0x03D6DB38 1 > $DCC_PATH/config
    echo 0x03D6DB3C 1 > $DCC_PATH/config
    echo 0x03D6DB40 1 > $DCC_PATH/config
    echo 0x03D6DB44 1 > $DCC_PATH/config
    echo 0x03D6DB48 1 > $DCC_PATH/config
    echo 0x03D6DB4C 1 > $DCC_PATH/config
    echo 0x03D6DB50 1 > $DCC_PATH/config
    echo 0x03D6DB54 1 > $DCC_PATH/config
    echo 0x03D6DB58 1 > $DCC_PATH/config
    echo 0x03D6DB5C 1 > $DCC_PATH/config
    echo 0x03D6DB60 1 > $DCC_PATH/config
    echo 0x03D6DB64 1 > $DCC_PATH/config
    echo 0x03D6DB68 1 > $DCC_PATH/config
    echo 0x03D6DB6C 1 > $DCC_PATH/config
    echo 0x03D6DB70 1 > $DCC_PATH/config
    echo 0x03D6DB74 1 > $DCC_PATH/config
    echo 0x03D6DB78 1 > $DCC_PATH/config
    echo 0x03D6DB7C 1 > $DCC_PATH/config
    echo 0x03D6DB80 1 > $DCC_PATH/config
    echo 0x03D6DB84 1 > $DCC_PATH/config
    echo 0x03D6DB88 1 > $DCC_PATH/config
    echo 0x03D6DB8C 1 > $DCC_PATH/config
    echo 0x03D6DB90 1 > $DCC_PATH/config
    echo 0x03D6DB94 1 > $DCC_PATH/config
    echo 0x03D6DB98 1 > $DCC_PATH/config
    echo 0x03D6DB9C 1 > $DCC_PATH/config
    echo 0x03D6DBA0 1 > $DCC_PATH/config
    echo 0x03D6DBA4 1 > $DCC_PATH/config
    echo 0x03D6DBA8 1 > $DCC_PATH/config
    echo 0x03D6DBAC 1 > $DCC_PATH/config
    echo 0x03D6DBB0 1 > $DCC_PATH/config
    echo 0x03D6DBB4 1 > $DCC_PATH/config
    echo 0x03D6DBB8 1 > $DCC_PATH/config
    echo 0x03D6DBBC 1 > $DCC_PATH/config
    echo 0x03D6DBC0 1 > $DCC_PATH/config
    echo 0x03D6DBC4 1 > $DCC_PATH/config
    echo 0x03D6DBC8 1 > $DCC_PATH/config
    echo 0x03D6DBCC 1 > $DCC_PATH/config
    echo 0x03D6DBD0 1 > $DCC_PATH/config
    echo 0x03D6DBD4 1 > $DCC_PATH/config
    echo 0x03D6DBD8 1 > $DCC_PATH/config
    echo 0x03D6DBDC 1 > $DCC_PATH/config
    echo 0x03D6DBE0 1 > $DCC_PATH/config
    echo 0x03D6DBE4 1 > $DCC_PATH/config
    echo 0x03D6DBE8 1 > $DCC_PATH/config
    echo 0x03D6DBEC 1 > $DCC_PATH/config
    echo 0x03D6DBF0 1 > $DCC_PATH/config
    echo 0x03D6DBF4 1 > $DCC_PATH/config
    echo 0x03D6DBF8 1 > $DCC_PATH/config
    echo 0x03D6DBFC 1 > $DCC_PATH/config
    echo 0x03D6DC00 1 > $DCC_PATH/config
    echo 0x03D6DC04 1 > $DCC_PATH/config
    echo 0x03D6DC08 1 > $DCC_PATH/config
    echo 0x03D6DC0C 1 > $DCC_PATH/config
    echo 0x03D6DC10 1 > $DCC_PATH/config
    echo 0x03D6DC14 1 > $DCC_PATH/config
    echo 0x03D6DC18 1 > $DCC_PATH/config
    echo 0x03D6DC1C 1 > $DCC_PATH/config
    echo 0x03D6DC20 1 > $DCC_PATH/config
    echo 0x03D6DC24 1 > $DCC_PATH/config
    echo 0x03D6DC28 1 > $DCC_PATH/config
    echo 0x03D6DC2C 1 > $DCC_PATH/config
    echo 0x03D6DC30 1 > $DCC_PATH/config
    echo 0x03D6DC34 1 > $DCC_PATH/config
    echo 0x03D6DC38 1 > $DCC_PATH/config
    echo 0x03D6DC3C 1 > $DCC_PATH/config
    echo 0x03D6DC40 1 > $DCC_PATH/config
    echo 0x03D6DC44 1 > $DCC_PATH/config
    echo 0x03D6DC48 1 > $DCC_PATH/config
    echo 0x03D6DC4C 1 > $DCC_PATH/config
    echo 0x03D6DC50 1 > $DCC_PATH/config
    echo 0x03D6DC54 1 > $DCC_PATH/config
    echo 0x03D6DC58 1 > $DCC_PATH/config
    echo 0x03D6DC5C 1 > $DCC_PATH/config
    echo 0x03D6DC60 1 > $DCC_PATH/config
    echo 0x03D6DC64 1 > $DCC_PATH/config
    echo 0x03D6DC68 1 > $DCC_PATH/config
    echo 0x03D6DC6C 1 > $DCC_PATH/config
    echo 0x03D6DC70 1 > $DCC_PATH/config
    echo 0x03D6DC74 1 > $DCC_PATH/config
    echo 0x03D6DC78 1 > $DCC_PATH/config
    echo 0x03D6DC7C 1 > $DCC_PATH/config
    echo 0x03D6DC80 1 > $DCC_PATH/config
    echo 0x03D6DC84 1 > $DCC_PATH/config
    echo 0x03D6DC88 1 > $DCC_PATH/config
    echo 0x03D6DC8C 1 > $DCC_PATH/config
    echo 0x03D6DC90 1 > $DCC_PATH/config
    echo 0x03D6DC94 1 > $DCC_PATH/config
    echo 0x03D6DC98 1 > $DCC_PATH/config
    echo 0x03D6DC9C 1 > $DCC_PATH/config
    echo 0x03D6DCA0 1 > $DCC_PATH/config
    echo 0x03D6DCA4 1 > $DCC_PATH/config
    echo 0x03D6DCA8 1 > $DCC_PATH/config
    echo 0x03D6DCAC 1 > $DCC_PATH/config
    echo 0x03D6DCB0 1 > $DCC_PATH/config
    echo 0x03D6DCB4 1 > $DCC_PATH/config
    echo 0x03D6DCB8 1 > $DCC_PATH/config
    echo 0x03D6DCBC 1 > $DCC_PATH/config
    echo 0x03D6DCC0 1 > $DCC_PATH/config
    echo 0x03D6DCC4 1 > $DCC_PATH/config
    echo 0x03D6DCC8 1 > $DCC_PATH/config
    echo 0x03D6DCCC 1 > $DCC_PATH/config
    echo 0x03D6DCD0 1 > $DCC_PATH/config
    echo 0x03D6DCD4 1 > $DCC_PATH/config
    echo 0x03D6DCD8 1 > $DCC_PATH/config
    echo 0x03D6DCDC 1 > $DCC_PATH/config
    echo 0x03D6DCE0 1 > $DCC_PATH/config
    echo 0x03D6DCE4 1 > $DCC_PATH/config
    echo 0x03D6DCE8 1 > $DCC_PATH/config
    echo 0x03D6DCEC 1 > $DCC_PATH/config
    echo 0x03D6DCF0 1 > $DCC_PATH/config
    echo 0x03D6DCF4 1 > $DCC_PATH/config
    echo 0x03D6DCF8 1 > $DCC_PATH/config
    echo 0x03D6DCFC 1 > $DCC_PATH/config
    echo 0x03D6DD00 1 > $DCC_PATH/config
    echo 0x03D6DD04 1 > $DCC_PATH/config
    echo 0x03D6DD08 1 > $DCC_PATH/config
    echo 0x03D6DD0C 1 > $DCC_PATH/config
    echo 0x03D6DD10 1 > $DCC_PATH/config
    echo 0x03D6DD14 1 > $DCC_PATH/config
    echo 0x03D6DD18 1 > $DCC_PATH/config
    echo 0x03D6DD1C 1 > $DCC_PATH/config
    echo 0x03D6DD20 1 > $DCC_PATH/config
    echo 0x03D6DD24 1 > $DCC_PATH/config
    echo 0x03D6DD28 1 > $DCC_PATH/config
    echo 0x03D6DD2C 1 > $DCC_PATH/config
    echo 0x03D6DD30 1 > $DCC_PATH/config
    echo 0x03D6DD34 1 > $DCC_PATH/config
    echo 0x03D6DD38 1 > $DCC_PATH/config
    echo 0x03D6DD3C 1 > $DCC_PATH/config
    echo 0x03D6DD40 1 > $DCC_PATH/config
    echo 0x03D6DD44 1 > $DCC_PATH/config
    echo 0x03D6DD48 1 > $DCC_PATH/config
    echo 0x03D6DD4C 1 > $DCC_PATH/config
    echo 0x03D6DD50 1 > $DCC_PATH/config
    echo 0x03D6DD54 1 > $DCC_PATH/config
    echo 0x03D6DD58 1 > $DCC_PATH/config
    echo 0x03D6DD5C 1 > $DCC_PATH/config
    echo 0x03D6DD60 1 > $DCC_PATH/config
    echo 0x03D6DD64 1 > $DCC_PATH/config
    echo 0x03D6DD68 1 > $DCC_PATH/config
    echo 0x03D6DD6C 1 > $DCC_PATH/config
    echo 0x03D6DD70 1 > $DCC_PATH/config
    echo 0x03D6DD74 1 > $DCC_PATH/config
    echo 0x03D6DD78 1 > $DCC_PATH/config
    echo 0x03D6DD7C 1 > $DCC_PATH/config
    echo 0x03D6DD80 1 > $DCC_PATH/config
    echo 0x03D6DD84 1 > $DCC_PATH/config
    echo 0x03D6DD88 1 > $DCC_PATH/config
    echo 0x03D6DD8C 1 > $DCC_PATH/config
    echo 0x03D6DD90 1 > $DCC_PATH/config
    echo 0x03D6DD94 1 > $DCC_PATH/config
    echo 0x03D6DD98 1 > $DCC_PATH/config
    echo 0x03D6DD9C 1 > $DCC_PATH/config
    echo 0x03D6DDA0 1 > $DCC_PATH/config
    echo 0x03D6DDA4 1 > $DCC_PATH/config
    echo 0x03D6DDA8 1 > $DCC_PATH/config
    echo 0x03D6DDAC 1 > $DCC_PATH/config
    echo 0x03D6DDB0 1 > $DCC_PATH/config
    echo 0x03D6DDB4 1 > $DCC_PATH/config
    echo 0x03D6DDB8 1 > $DCC_PATH/config
    echo 0x03D6DDBC 1 > $DCC_PATH/config
    echo 0x03D6DDC0 1 > $DCC_PATH/config
    echo 0x03D6DDC4 1 > $DCC_PATH/config
    echo 0x03D6DDC8 1 > $DCC_PATH/config
    echo 0x03D6DDCC 1 > $DCC_PATH/config
    echo 0x03D6DDD0 1 > $DCC_PATH/config
    echo 0x03D6DDD4 1 > $DCC_PATH/config
    echo 0x03D6DDD8 1 > $DCC_PATH/config
    echo 0x03D6DDDC 1 > $DCC_PATH/config
    echo 0x03D6DDE0 1 > $DCC_PATH/config
    echo 0x03D6DDE4 1 > $DCC_PATH/config
    echo 0x03D6DDE8 1 > $DCC_PATH/config
    echo 0x03D6DDEC 1 > $DCC_PATH/config
    echo 0x03D6DDF0 1 > $DCC_PATH/config
    echo 0x03D6DDF4 1 > $DCC_PATH/config
    echo 0x03D6DDF8 1 > $DCC_PATH/config
    echo 0x03D6DDFC 1 > $DCC_PATH/config
    echo 0x03D6DE00 1 > $DCC_PATH/config
    echo 0x03D6DE04 1 > $DCC_PATH/config
    echo 0x03D6DE08 1 > $DCC_PATH/config
    echo 0x03D6DE0C 1 > $DCC_PATH/config
    echo 0x03D6DE10 1 > $DCC_PATH/config
    echo 0x03D6DE14 1 > $DCC_PATH/config
    echo 0x03D6DE18 1 > $DCC_PATH/config
    echo 0x03D6DE1C 1 > $DCC_PATH/config
    echo 0x03D6DE20 1 > $DCC_PATH/config
    echo 0x03D6DE24 1 > $DCC_PATH/config
    echo 0x03D6DE28 1 > $DCC_PATH/config
    echo 0x03D6DE2C 1 > $DCC_PATH/config
    echo 0x03D6DE30 1 > $DCC_PATH/config
    echo 0x03D6DE34 1 > $DCC_PATH/config
    echo 0x03D6DE38 1 > $DCC_PATH/config
    echo 0x03D6DE3C 1 > $DCC_PATH/config
    echo 0x03D6DE40 1 > $DCC_PATH/config
    echo 0x03D6DE44 1 > $DCC_PATH/config
    echo 0x03D6DE48 1 > $DCC_PATH/config
    echo 0x03D6DE4C 1 > $DCC_PATH/config
    echo 0x03D6DE50 1 > $DCC_PATH/config
    echo 0x03D6DE54 1 > $DCC_PATH/config
    echo 0x03D6DE58 1 > $DCC_PATH/config
    echo 0x03D6DE5C 1 > $DCC_PATH/config
    echo 0x03D6DE60 1 > $DCC_PATH/config
    echo 0x03D6DE64 1 > $DCC_PATH/config
    echo 0x03D6DE68 1 > $DCC_PATH/config
    echo 0x03D6DE6C 1 > $DCC_PATH/config
    echo 0x03D6DE70 1 > $DCC_PATH/config
    echo 0x03D6DE74 1 > $DCC_PATH/config
    echo 0x03D6DE78 1 > $DCC_PATH/config
    echo 0x03D6DE7C 1 > $DCC_PATH/config
    echo 0x03D6DE80 1 > $DCC_PATH/config
    echo 0x03D6DE84 1 > $DCC_PATH/config
    echo 0x03D6DE88 1 > $DCC_PATH/config
    echo 0x03D6DE8C 1 > $DCC_PATH/config
    echo 0x03D6DE90 1 > $DCC_PATH/config
    echo 0x03D6DE94 1 > $DCC_PATH/config
    echo 0x03D6DE98 1 > $DCC_PATH/config
    echo 0x03D6DE9C 1 > $DCC_PATH/config
    echo 0x03D6DEA0 1 > $DCC_PATH/config
    echo 0x03D6DEA4 1 > $DCC_PATH/config
    echo 0x03D6DEA8 1 > $DCC_PATH/config
    echo 0x03D6DEAC 1 > $DCC_PATH/config
    echo 0x03D6DEB0 1 > $DCC_PATH/config
    echo 0x03D6DEB4 1 > $DCC_PATH/config
    echo 0x03D6DEB8 1 > $DCC_PATH/config
    echo 0x03D6DEBC 1 > $DCC_PATH/config
    echo 0x03D6DEC0 1 > $DCC_PATH/config
    echo 0x03D6DEC4 1 > $DCC_PATH/config
    echo 0x03D6DEC8 1 > $DCC_PATH/config
    echo 0x03D6DECC 1 > $DCC_PATH/config
    echo 0x03D6DED0 1 > $DCC_PATH/config
    echo 0x03D6DED4 1 > $DCC_PATH/config
    echo 0x03D6DED8 1 > $DCC_PATH/config
    echo 0x03D6DEDC 1 > $DCC_PATH/config
    echo 0x03D6DEE0 1 > $DCC_PATH/config
    echo 0x03D6DEE4 1 > $DCC_PATH/config
    echo 0x03D6DEE8 1 > $DCC_PATH/config
    echo 0x03D6DEEC 1 > $DCC_PATH/config
    echo 0x03D6DEF0 1 > $DCC_PATH/config
    echo 0x03D6DEF4 1 > $DCC_PATH/config
    echo 0x03D6DEF8 1 > $DCC_PATH/config
    echo 0x03D6DEFC 1 > $DCC_PATH/config
    echo 0x03D6DF00 1 > $DCC_PATH/config
    echo 0x03D6DF04 1 > $DCC_PATH/config
    echo 0x03D6DF08 1 > $DCC_PATH/config
    echo 0x03D6DF0C 1 > $DCC_PATH/config
    echo 0x03D6DF10 1 > $DCC_PATH/config
    echo 0x03D6DF14 1 > $DCC_PATH/config
    echo 0x03D6DF18 1 > $DCC_PATH/config
    echo 0x03D6DF1C 1 > $DCC_PATH/config
    echo 0x03D6DF20 1 > $DCC_PATH/config
    echo 0x03D6DF24 1 > $DCC_PATH/config
    echo 0x03D6DF28 1 > $DCC_PATH/config
    echo 0x03D6DF2C 1 > $DCC_PATH/config
    echo 0x03D6DF30 1 > $DCC_PATH/config
    echo 0x03D6DF34 1 > $DCC_PATH/config
    echo 0x03D6DF38 1 > $DCC_PATH/config
    echo 0x03D6DF3C 1 > $DCC_PATH/config
    echo 0x03D6DF40 1 > $DCC_PATH/config
    echo 0x03D6DF44 1 > $DCC_PATH/config
    echo 0x03D6DF48 1 > $DCC_PATH/config
    echo 0x03D6DF4C 1 > $DCC_PATH/config
    echo 0x03D6DF50 1 > $DCC_PATH/config
    echo 0x03D6DF54 1 > $DCC_PATH/config
    echo 0x03D6DF58 1 > $DCC_PATH/config
    echo 0x03D6DF5C 1 > $DCC_PATH/config
    echo 0x03D6DF60 1 > $DCC_PATH/config
    echo 0x03D6DF64 1 > $DCC_PATH/config
    echo 0x03D6DF68 1 > $DCC_PATH/config
    echo 0x03D6DF6C 1 > $DCC_PATH/config
    echo 0x03D6DF70 1 > $DCC_PATH/config
    echo 0x03D6DF74 1 > $DCC_PATH/config
    echo 0x03D6DF78 1 > $DCC_PATH/config
    echo 0x03D6DF7C 1 > $DCC_PATH/config
    echo 0x03D6DF80 1 > $DCC_PATH/config
    echo 0x03D6DF84 1 > $DCC_PATH/config
    echo 0x03D6DF88 1 > $DCC_PATH/config
    echo 0x03D6DF8C 1 > $DCC_PATH/config
    echo 0x03D6DF90 1 > $DCC_PATH/config
    echo 0x03D6DF94 1 > $DCC_PATH/config
    echo 0x03D6DF98 1 > $DCC_PATH/config
    echo 0x03D6DF9C 1 > $DCC_PATH/config
    echo 0x03D6DFA0 1 > $DCC_PATH/config
    echo 0x03D6DFA4 1 > $DCC_PATH/config
    echo 0x03D6DFA8 1 > $DCC_PATH/config
    echo 0x03D6DFAC 1 > $DCC_PATH/config
    echo 0x03D6DFB0 1 > $DCC_PATH/config
    echo 0x03D6DFB4 1 > $DCC_PATH/config
    echo 0x03D6DFB8 1 > $DCC_PATH/config
    echo 0x03D6DFBC 1 > $DCC_PATH/config
    echo 0x03D6DFC0 1 > $DCC_PATH/config
    echo 0x03D6DFC4 1 > $DCC_PATH/config
    echo 0x03D6DFC8 1 > $DCC_PATH/config
    echo 0x03D6DFCC 1 > $DCC_PATH/config
    echo 0x03D6DFD0 1 > $DCC_PATH/config
    echo 0x03D6DFD4 1 > $DCC_PATH/config
    echo 0x03D6DFD8 1 > $DCC_PATH/config
    echo 0x03D6DFDC 1 > $DCC_PATH/config
    echo 0x03D6DFE0 1 > $DCC_PATH/config
    echo 0x03D6DFE4 1 > $DCC_PATH/config
    echo 0x03D6DFE8 1 > $DCC_PATH/config
    echo 0x03D6DFEC 1 > $DCC_PATH/config
    echo 0x03D6DFF0 1 > $DCC_PATH/config
    echo 0x03D6DFF4 1 > $DCC_PATH/config
    echo 0x03D6DFF8 1 > $DCC_PATH/config
    echo 0x03D6DFFC 1 > $DCC_PATH/config
    echo 0x03D6E000 1 > $DCC_PATH/config
    echo 0x03D6E004 1 > $DCC_PATH/config
    echo 0x03D6E008 1 > $DCC_PATH/config
    echo 0x03D6E00C 1 > $DCC_PATH/config
    echo 0x03D6E010 1 > $DCC_PATH/config
    echo 0x03D6E014 1 > $DCC_PATH/config
    echo 0x03D6E018 1 > $DCC_PATH/config
    echo 0x03D6E01C 1 > $DCC_PATH/config
    echo 0x03D6E020 1 > $DCC_PATH/config
    echo 0x03D6E024 1 > $DCC_PATH/config
    echo 0x03D6E028 1 > $DCC_PATH/config
    echo 0x03D6E02C 1 > $DCC_PATH/config
    echo 0x03D6E030 1 > $DCC_PATH/config
    echo 0x03D6E034 1 > $DCC_PATH/config
    echo 0x03D6E038 1 > $DCC_PATH/config
    echo 0x03D6E03C 1 > $DCC_PATH/config
    echo 0x03D6E040 1 > $DCC_PATH/config
    echo 0x03D6E044 1 > $DCC_PATH/config
    echo 0x03D6E048 1 > $DCC_PATH/config
    echo 0x03D6E04C 1 > $DCC_PATH/config
    echo 0x03D6E050 1 > $DCC_PATH/config
    echo 0x03D6E054 1 > $DCC_PATH/config
    echo 0x03D6E058 1 > $DCC_PATH/config
    echo 0x03D6E05C 1 > $DCC_PATH/config
    echo 0x03D6E060 1 > $DCC_PATH/config
    echo 0x03D6E064 1 > $DCC_PATH/config
    echo 0x03D6E068 1 > $DCC_PATH/config
    echo 0x03D6E06C 1 > $DCC_PATH/config
    echo 0x03D6E070 1 > $DCC_PATH/config
    echo 0x03D6E074 1 > $DCC_PATH/config
    echo 0x03D6E078 1 > $DCC_PATH/config
    echo 0x03D6E07C 1 > $DCC_PATH/config
    echo 0x03D6E080 1 > $DCC_PATH/config
    echo 0x03D6E084 1 > $DCC_PATH/config
    echo 0x03D6E088 1 > $DCC_PATH/config
    echo 0x03D6E08C 1 > $DCC_PATH/config
    echo 0x03D6E090 1 > $DCC_PATH/config
    echo 0x03D6E094 1 > $DCC_PATH/config
    echo 0x03D6E098 1 > $DCC_PATH/config
    echo 0x03D6E09C 1 > $DCC_PATH/config
    echo 0x03D6E0A0 1 > $DCC_PATH/config
    echo 0x03D6E0A4 1 > $DCC_PATH/config
    echo 0x03D6E0A8 1 > $DCC_PATH/config
    echo 0x03D6E0AC 1 > $DCC_PATH/config
    echo 0x03D6E0B0 1 > $DCC_PATH/config
    echo 0x03D6E0B4 1 > $DCC_PATH/config
    echo 0x03D6E0B8 1 > $DCC_PATH/config
    echo 0x03D6E0BC 1 > $DCC_PATH/config
    echo 0x03D6E0C0 1 > $DCC_PATH/config
    echo 0x03D6E0C4 1 > $DCC_PATH/config
    echo 0x03D6E0C8 1 > $DCC_PATH/config
    echo 0x03D6E0CC 1 > $DCC_PATH/config
    echo 0x03D6E0D0 1 > $DCC_PATH/config
    echo 0x03D6E0D4 1 > $DCC_PATH/config
    echo 0x03D6E0D8 1 > $DCC_PATH/config
    echo 0x03D6E0DC 1 > $DCC_PATH/config
    echo 0x03D6E0E0 1 > $DCC_PATH/config
    echo 0x03D6E0E4 1 > $DCC_PATH/config
    echo 0x03D6E0E8 1 > $DCC_PATH/config
    echo 0x03D6E0EC 1 > $DCC_PATH/config
    echo 0x03D6E0F0 1 > $DCC_PATH/config
    echo 0x03D6E0F4 1 > $DCC_PATH/config
    echo 0x03D6E0F8 1 > $DCC_PATH/config
    echo 0x03D6E0FC 1 > $DCC_PATH/config
    echo 0x03D6E100 1 > $DCC_PATH/config
    echo 0x03D6E104 1 > $DCC_PATH/config
    echo 0x03D6E108 1 > $DCC_PATH/config
    echo 0x03D6E10C 1 > $DCC_PATH/config
    echo 0x03D6E110 1 > $DCC_PATH/config
    echo 0x03D6E114 1 > $DCC_PATH/config
    echo 0x03D6E118 1 > $DCC_PATH/config
    echo 0x03D6E11C 1 > $DCC_PATH/config
    echo 0x03D6E120 1 > $DCC_PATH/config
    echo 0x03D6E124 1 > $DCC_PATH/config
    echo 0x03D6E128 1 > $DCC_PATH/config
    echo 0x03D6E12C 1 > $DCC_PATH/config
    echo 0x03D6E130 1 > $DCC_PATH/config
    echo 0x03D6E134 1 > $DCC_PATH/config
    echo 0x03D6E138 1 > $DCC_PATH/config
    echo 0x03D6E13C 1 > $DCC_PATH/config
    echo 0x03D6E140 1 > $DCC_PATH/config
    echo 0x03D6E144 1 > $DCC_PATH/config
    echo 0x03D6E148 1 > $DCC_PATH/config
    echo 0x03D6E14C 1 > $DCC_PATH/config
    echo 0x03D6E150 1 > $DCC_PATH/config
    echo 0x03D6E154 1 > $DCC_PATH/config
    echo 0x03D6E158 1 > $DCC_PATH/config
    echo 0x03D6E15C 1 > $DCC_PATH/config
    echo 0x03D6E160 1 > $DCC_PATH/config
    echo 0x03D6E164 1 > $DCC_PATH/config
    echo 0x03D6E168 1 > $DCC_PATH/config
    echo 0x03D6E16C 1 > $DCC_PATH/config
    echo 0x03D6E170 1 > $DCC_PATH/config
    echo 0x03D6E174 1 > $DCC_PATH/config
    echo 0x03D6E178 1 > $DCC_PATH/config
    echo 0x03D6E17C 1 > $DCC_PATH/config
    echo 0x03D6E180 1 > $DCC_PATH/config
    echo 0x03D6E184 1 > $DCC_PATH/config
    echo 0x03D6E188 1 > $DCC_PATH/config
    echo 0x03D6E18C 1 > $DCC_PATH/config
    echo 0x03D6E190 1 > $DCC_PATH/config
    echo 0x03D6E194 1 > $DCC_PATH/config
    echo 0x03D6E198 1 > $DCC_PATH/config
    echo 0x03D6E19C 1 > $DCC_PATH/config
    echo 0x03D6E1A0 1 > $DCC_PATH/config
    echo 0x03D6E1A4 1 > $DCC_PATH/config
    echo 0x03D6E1A8 1 > $DCC_PATH/config
    echo 0x03D6E1AC 1 > $DCC_PATH/config
    echo 0x03D6E1B0 1 > $DCC_PATH/config
    echo 0x03D6E1B4 1 > $DCC_PATH/config
    echo 0x03D6E1B8 1 > $DCC_PATH/config
    echo 0x03D6E1BC 1 > $DCC_PATH/config
    echo 0x03D6E1C0 1 > $DCC_PATH/config
    echo 0x03D6E1C4 1 > $DCC_PATH/config
    echo 0x03D6E1C8 1 > $DCC_PATH/config
    echo 0x03D6E1CC 1 > $DCC_PATH/config
    echo 0x03D6E1D0 1 > $DCC_PATH/config
    echo 0x03D6E1D4 1 > $DCC_PATH/config
    echo 0x03D6E1D8 1 > $DCC_PATH/config
    echo 0x03D6E1DC 1 > $DCC_PATH/config
    echo 0x03D6E1E0 1 > $DCC_PATH/config
    echo 0x03D6E1E4 1 > $DCC_PATH/config
    echo 0x03D6E1E8 1 > $DCC_PATH/config
    echo 0x03D6E1EC 1 > $DCC_PATH/config
    echo 0x03D6E1F0 1 > $DCC_PATH/config
    echo 0x03D6E1F4 1 > $DCC_PATH/config
    echo 0x03D6E1F8 1 > $DCC_PATH/config
    echo 0x03D6E1FC 1 > $DCC_PATH/config
    echo 0x03D6E200 1 > $DCC_PATH/config
    echo 0x03D6E204 1 > $DCC_PATH/config
    echo 0x03D6E208 1 > $DCC_PATH/config
    echo 0x03D6E20C 1 > $DCC_PATH/config
    echo 0x03D6E210 1 > $DCC_PATH/config
    echo 0x03D6E214 1 > $DCC_PATH/config
    echo 0x03D6E218 1 > $DCC_PATH/config
    echo 0x03D6E21C 1 > $DCC_PATH/config
    echo 0x03D6E220 1 > $DCC_PATH/config
    echo 0x03D6E224 1 > $DCC_PATH/config
    echo 0x03D6E228 1 > $DCC_PATH/config
    echo 0x03D6E22C 1 > $DCC_PATH/config
    echo 0x03D6E230 1 > $DCC_PATH/config
    echo 0x03D6E234 1 > $DCC_PATH/config
    echo 0x03D6E238 1 > $DCC_PATH/config
    echo 0x03D6E23C 1 > $DCC_PATH/config
    echo 0x03D6E240 1 > $DCC_PATH/config
    echo 0x03D6E244 1 > $DCC_PATH/config
    echo 0x03D6E248 1 > $DCC_PATH/config
    echo 0x03D6E24C 1 > $DCC_PATH/config
    echo 0x03D6E250 1 > $DCC_PATH/config
    echo 0x03D6E254 1 > $DCC_PATH/config
    echo 0x03D6E258 1 > $DCC_PATH/config
    echo 0x03D6E25C 1 > $DCC_PATH/config
    echo 0x03D6E260 1 > $DCC_PATH/config
    echo 0x03D6E264 1 > $DCC_PATH/config
    echo 0x03D6E268 1 > $DCC_PATH/config
    echo 0x03D6E26C 1 > $DCC_PATH/config
    echo 0x03D6E270 1 > $DCC_PATH/config
    echo 0x03D6E274 1 > $DCC_PATH/config
    echo 0x03D6E278 1 > $DCC_PATH/config
    echo 0x03D6E27C 1 > $DCC_PATH/config
    echo 0x03D6E280 1 > $DCC_PATH/config
    echo 0x03D6E284 1 > $DCC_PATH/config
    echo 0x03D6E288 1 > $DCC_PATH/config
    echo 0x03D6E28C 1 > $DCC_PATH/config
    echo 0x03D6E290 1 > $DCC_PATH/config
    echo 0x03D6E294 1 > $DCC_PATH/config
    echo 0x03D6E298 1 > $DCC_PATH/config
    echo 0x03D6E29C 1 > $DCC_PATH/config
    echo 0x03D6E2A0 1 > $DCC_PATH/config
    echo 0x03D6E2A4 1 > $DCC_PATH/config
    echo 0x03D6E2A8 1 > $DCC_PATH/config
    echo 0x03D6E2AC 1 > $DCC_PATH/config
    echo 0x03D6E2B0 1 > $DCC_PATH/config
    echo 0x03D6E2B4 1 > $DCC_PATH/config
    echo 0x03D6E2B8 1 > $DCC_PATH/config
    echo 0x03D6E2BC 1 > $DCC_PATH/config
    echo 0x03D6E2C0 1 > $DCC_PATH/config
    echo 0x03D6E2C4 1 > $DCC_PATH/config
    echo 0x03D6E2C8 1 > $DCC_PATH/config
    echo 0x03D6E2CC 1 > $DCC_PATH/config
    echo 0x03D6E2D0 1 > $DCC_PATH/config
    echo 0x03D6E2D4 1 > $DCC_PATH/config
    echo 0x03D6E2D8 1 > $DCC_PATH/config
    echo 0x03D6E2DC 1 > $DCC_PATH/config
    echo 0x03D6E2E0 1 > $DCC_PATH/config
    echo 0x03D6E2E4 1 > $DCC_PATH/config
    echo 0x03D6E2E8 1 > $DCC_PATH/config
    echo 0x03D6E2EC 1 > $DCC_PATH/config
    echo 0x03D6E2F0 1 > $DCC_PATH/config
    echo 0x03D6E2F4 1 > $DCC_PATH/config
    echo 0x03D6E2F8 1 > $DCC_PATH/config
    echo 0x03D6E2FC 1 > $DCC_PATH/config
    echo 0x03D6E300 1 > $DCC_PATH/config
    echo 0x03D6E304 1 > $DCC_PATH/config
    echo 0x03D6E308 1 > $DCC_PATH/config
    echo 0x03D6E30C 1 > $DCC_PATH/config
    echo 0x03D6E310 1 > $DCC_PATH/config
    echo 0x03D6E314 1 > $DCC_PATH/config
    echo 0x03D6E318 1 > $DCC_PATH/config
    echo 0x03D6E31C 1 > $DCC_PATH/config
    echo 0x03D6E320 1 > $DCC_PATH/config
    echo 0x03D6E324 1 > $DCC_PATH/config
    echo 0x03D6E328 1 > $DCC_PATH/config
    echo 0x03D6E32C 1 > $DCC_PATH/config
    echo 0x03D6E330 1 > $DCC_PATH/config
    echo 0x03D6E334 1 > $DCC_PATH/config
    echo 0x03D6E338 1 > $DCC_PATH/config
    echo 0x03D6E33C 1 > $DCC_PATH/config
    echo 0x03D6E340 1 > $DCC_PATH/config
    echo 0x03D6E344 1 > $DCC_PATH/config
    echo 0x03D6E348 1 > $DCC_PATH/config
    echo 0x03D6E34C 1 > $DCC_PATH/config
    echo 0x03D6E350 1 > $DCC_PATH/config
    echo 0x03D6E354 1 > $DCC_PATH/config
    echo 0x03D6E358 1 > $DCC_PATH/config
    echo 0x03D6E35C 1 > $DCC_PATH/config
    echo 0x03D6E360 1 > $DCC_PATH/config
    echo 0x03D6E364 1 > $DCC_PATH/config
    echo 0x03D6E368 1 > $DCC_PATH/config
    echo 0x03D6E36C 1 > $DCC_PATH/config
    echo 0x03D6E370 1 > $DCC_PATH/config
    echo 0x03D6E374 1 > $DCC_PATH/config
    echo 0x03D6E378 1 > $DCC_PATH/config
    echo 0x03D6E37C 1 > $DCC_PATH/config
    echo 0x03D6E380 1 > $DCC_PATH/config
    echo 0x03D6E384 1 > $DCC_PATH/config
    echo 0x03D6E388 1 > $DCC_PATH/config
    echo 0x03D6E38C 1 > $DCC_PATH/config
    echo 0x03D6E390 1 > $DCC_PATH/config
    echo 0x03D6E394 1 > $DCC_PATH/config
    echo 0x03D6E398 1 > $DCC_PATH/config
    echo 0x03D6E39C 1 > $DCC_PATH/config
    echo 0x03D6E3A0 1 > $DCC_PATH/config
    echo 0x03D6E3A4 1 > $DCC_PATH/config
    echo 0x03D6E3A8 1 > $DCC_PATH/config
    echo 0x03D6E3AC 1 > $DCC_PATH/config
    echo 0x03D6E3B0 1 > $DCC_PATH/config
    echo 0x03D6E3B4 1 > $DCC_PATH/config
    echo 0x03D6E3B8 1 > $DCC_PATH/config
    echo 0x03D6E3BC 1 > $DCC_PATH/config
    echo 0x03D6E3C0 1 > $DCC_PATH/config
    echo 0x03D6E3C4 1 > $DCC_PATH/config
    echo 0x03D6E3C8 1 > $DCC_PATH/config
    echo 0x03D6E3CC 1 > $DCC_PATH/config
    echo 0x03D6E3D0 1 > $DCC_PATH/config
    echo 0x03D6E3D4 1 > $DCC_PATH/config
    echo 0x03D6E3D8 1 > $DCC_PATH/config
    echo 0x03D6E3DC 1 > $DCC_PATH/config
    echo 0x03D6E3E0 1 > $DCC_PATH/config
    echo 0x03D6E3E4 1 > $DCC_PATH/config
    echo 0x03D6E3E8 1 > $DCC_PATH/config
    echo 0x03D6E3EC 1 > $DCC_PATH/config
    echo 0x03D6E3F0 1 > $DCC_PATH/config
    echo 0x03D6E3F4 1 > $DCC_PATH/config
    echo 0x03D6E3F8 1 > $DCC_PATH/config
    echo 0x03D6E3FC 1 > $DCC_PATH/config
    echo 0x03D6E400 1 > $DCC_PATH/config
    echo 0x03D6E404 1 > $DCC_PATH/config
    echo 0x03D6E408 1 > $DCC_PATH/config
    echo 0x03D6E40C 1 > $DCC_PATH/config
    echo 0x03D6E410 1 > $DCC_PATH/config
    echo 0x03D6E414 1 > $DCC_PATH/config
    echo 0x03D6E418 1 > $DCC_PATH/config
    echo 0x03D6E41C 1 > $DCC_PATH/config
    echo 0x03D6E420 1 > $DCC_PATH/config
    echo 0x03D6E424 1 > $DCC_PATH/config
    echo 0x03D6E428 1 > $DCC_PATH/config
    echo 0x03D6E42C 1 > $DCC_PATH/config
    echo 0x03D6E430 1 > $DCC_PATH/config
    echo 0x03D6E434 1 > $DCC_PATH/config
    echo 0x03D6E438 1 > $DCC_PATH/config
    echo 0x03D6E43C 1 > $DCC_PATH/config
    echo 0x03D6E440 1 > $DCC_PATH/config
    echo 0x03D6E444 1 > $DCC_PATH/config
    echo 0x03D6E448 1 > $DCC_PATH/config
    echo 0x03D6E44C 1 > $DCC_PATH/config
    echo 0x03D6E450 1 > $DCC_PATH/config
    echo 0x03D6E454 1 > $DCC_PATH/config
    echo 0x03D6E458 1 > $DCC_PATH/config
    echo 0x03D6E45C 1 > $DCC_PATH/config
    echo 0x03D6E460 1 > $DCC_PATH/config
    echo 0x03D6E464 1 > $DCC_PATH/config
    echo 0x03D6E468 1 > $DCC_PATH/config
    echo 0x03D6E46C 1 > $DCC_PATH/config
    echo 0x03D6E470 1 > $DCC_PATH/config
    echo 0x03D6E474 1 > $DCC_PATH/config
    echo 0x03D6E478 1 > $DCC_PATH/config
    echo 0x03D6E47C 1 > $DCC_PATH/config
    echo 0x03D6E480 1 > $DCC_PATH/config
    echo 0x03D6E484 1 > $DCC_PATH/config
    echo 0x03D6E488 1 > $DCC_PATH/config
    echo 0x03D6E48C 1 > $DCC_PATH/config
    echo 0x03D6E490 1 > $DCC_PATH/config
    echo 0x03D6E494 1 > $DCC_PATH/config
    echo 0x03D6E498 1 > $DCC_PATH/config
    echo 0x03D6E49C 1 > $DCC_PATH/config
    echo 0x03D6E4A0 1 > $DCC_PATH/config
    echo 0x03D6E4A4 1 > $DCC_PATH/config
    echo 0x03D6E4A8 1 > $DCC_PATH/config
    echo 0x03D6E4AC 1 > $DCC_PATH/config
    echo 0x03D6E4B0 1 > $DCC_PATH/config
    echo 0x03D6E4B4 1 > $DCC_PATH/config
    echo 0x03D6E4B8 1 > $DCC_PATH/config
    echo 0x03D6E4BC 1 > $DCC_PATH/config
    echo 0x03D6E4C0 1 > $DCC_PATH/config
    echo 0x03D6E4C4 1 > $DCC_PATH/config
    echo 0x03D6E4C8 1 > $DCC_PATH/config
    echo 0x03D6E4CC 1 > $DCC_PATH/config
    echo 0x03D6E4D0 1 > $DCC_PATH/config
    echo 0x03D6E4D4 1 > $DCC_PATH/config
    echo 0x03D6E4D8 1 > $DCC_PATH/config
    echo 0x03D6E4DC 1 > $DCC_PATH/config
    echo 0x03D6E4E0 1 > $DCC_PATH/config
    echo 0x03D6E4E4 1 > $DCC_PATH/config
    echo 0x03D6E4E8 1 > $DCC_PATH/config
    echo 0x03D6E4EC 1 > $DCC_PATH/config
    echo 0x03D6E4F0 1 > $DCC_PATH/config
    echo 0x03D6E4F4 1 > $DCC_PATH/config
    echo 0x03D6E4F8 1 > $DCC_PATH/config
    echo 0x03D6E4FC 1 > $DCC_PATH/config
    echo 0x03D6E500 1 > $DCC_PATH/config
    echo 0x03D6E504 1 > $DCC_PATH/config
    echo 0x03D6E508 1 > $DCC_PATH/config
    echo 0x03D6E50C 1 > $DCC_PATH/config
    echo 0x03D6E510 1 > $DCC_PATH/config
    echo 0x03D6E514 1 > $DCC_PATH/config
    echo 0x03D6E518 1 > $DCC_PATH/config
    echo 0x03D6E51C 1 > $DCC_PATH/config
    echo 0x03D6E520 1 > $DCC_PATH/config
    echo 0x03D6E524 1 > $DCC_PATH/config
    echo 0x03D6E528 1 > $DCC_PATH/config
    echo 0x03D6E52C 1 > $DCC_PATH/config
    echo 0x03D6E530 1 > $DCC_PATH/config
    echo 0x03D6E534 1 > $DCC_PATH/config
    echo 0x03D6E538 1 > $DCC_PATH/config
    echo 0x03D6E53C 1 > $DCC_PATH/config
    echo 0x03D6E540 1 > $DCC_PATH/config
    echo 0x03D6E544 1 > $DCC_PATH/config
    echo 0x03D6E548 1 > $DCC_PATH/config
    echo 0x03D6E54C 1 > $DCC_PATH/config
    echo 0x03D6E550 1 > $DCC_PATH/config
    echo 0x03D6E554 1 > $DCC_PATH/config
    echo 0x03D6E558 1 > $DCC_PATH/config
    echo 0x03D6E55C 1 > $DCC_PATH/config
    echo 0x03D6E560 1 > $DCC_PATH/config
    echo 0x03D6E564 1 > $DCC_PATH/config
    echo 0x03D6E568 1 > $DCC_PATH/config
    echo 0x03D6E56C 1 > $DCC_PATH/config
    echo 0x03D6E570 1 > $DCC_PATH/config
    echo 0x03D6E574 1 > $DCC_PATH/config
    echo 0x03D6E578 1 > $DCC_PATH/config
    echo 0x03D6E57C 1 > $DCC_PATH/config
    echo 0x03D6E580 1 > $DCC_PATH/config
    echo 0x03D6E584 1 > $DCC_PATH/config
    echo 0x03D6E588 1 > $DCC_PATH/config
    echo 0x03D6E58C 1 > $DCC_PATH/config
    echo 0x03D6E590 1 > $DCC_PATH/config
    echo 0x03D6E594 1 > $DCC_PATH/config
    echo 0x03D6E598 1 > $DCC_PATH/config
    echo 0x03D6E59C 1 > $DCC_PATH/config
    echo 0x03D6E5A0 1 > $DCC_PATH/config
    echo 0x03D6E5A4 1 > $DCC_PATH/config
    echo 0x03D6E5A8 1 > $DCC_PATH/config
    echo 0x03D6E5AC 1 > $DCC_PATH/config
    echo 0x03D6E5B0 1 > $DCC_PATH/config
    echo 0x03D6E5B4 1 > $DCC_PATH/config
    echo 0x03D6E5B8 1 > $DCC_PATH/config
    echo 0x03D6E5BC 1 > $DCC_PATH/config
    echo 0x03D6E5C0 1 > $DCC_PATH/config
    echo 0x03D6E5C4 1 > $DCC_PATH/config
    echo 0x03D6E5C8 1 > $DCC_PATH/config
    echo 0x03D6E5CC 1 > $DCC_PATH/config
    echo 0x03D6E5D0 1 > $DCC_PATH/config
    echo 0x03D6E5D4 1 > $DCC_PATH/config
    echo 0x03D6E5D8 1 > $DCC_PATH/config
    echo 0x03D6E5DC 1 > $DCC_PATH/config
    echo 0x03D6E5E0 1 > $DCC_PATH/config
    echo 0x03D6E5E4 1 > $DCC_PATH/config
    echo 0x03D6E5E8 1 > $DCC_PATH/config
    echo 0x03D6E5EC 1 > $DCC_PATH/config
    echo 0x03D6E5F0 1 > $DCC_PATH/config
    echo 0x03D6E5F4 1 > $DCC_PATH/config
    echo 0x03D6E5F8 1 > $DCC_PATH/config
    echo 0x03D6E5FC 1 > $DCC_PATH/config
    echo 0x03D6E600 1 > $DCC_PATH/config
    echo 0x03D6E604 1 > $DCC_PATH/config
    echo 0x03D6E608 1 > $DCC_PATH/config
    echo 0x03D6E60C 1 > $DCC_PATH/config
    echo 0x03D6E610 1 > $DCC_PATH/config
    echo 0x03D6E614 1 > $DCC_PATH/config
    echo 0x03D6E618 1 > $DCC_PATH/config
    echo 0x03D6E61C 1 > $DCC_PATH/config
    echo 0x03D6E620 1 > $DCC_PATH/config
    echo 0x03D6E624 1 > $DCC_PATH/config
    echo 0x03D6E628 1 > $DCC_PATH/config
    echo 0x03D6E62C 1 > $DCC_PATH/config
    echo 0x03D6E630 1 > $DCC_PATH/config
    echo 0x03D6E634 1 > $DCC_PATH/config
    echo 0x03D6E638 1 > $DCC_PATH/config
    echo 0x03D6E63C 1 > $DCC_PATH/config
    echo 0x03D6E640 1 > $DCC_PATH/config
    echo 0x03D6E644 1 > $DCC_PATH/config
    echo 0x03D6E648 1 > $DCC_PATH/config
    echo 0x03D6E64C 1 > $DCC_PATH/config
    echo 0x03D6E650 1 > $DCC_PATH/config
    echo 0x03D6E654 1 > $DCC_PATH/config
    echo 0x03D6E658 1 > $DCC_PATH/config
    echo 0x03D6E65C 1 > $DCC_PATH/config
    echo 0x03D6E660 1 > $DCC_PATH/config
    echo 0x03D6E664 1 > $DCC_PATH/config
    echo 0x03D6E668 1 > $DCC_PATH/config
    echo 0x03D6E66C 1 > $DCC_PATH/config
    echo 0x03D6E670 1 > $DCC_PATH/config
    echo 0x03D6E674 1 > $DCC_PATH/config
    echo 0x03D6E678 1 > $DCC_PATH/config
    echo 0x03D6E67C 1 > $DCC_PATH/config
    echo 0x03D6E680 1 > $DCC_PATH/config
    echo 0x03D6E684 1 > $DCC_PATH/config
    echo 0x03D6E688 1 > $DCC_PATH/config
    echo 0x03D6E68C 1 > $DCC_PATH/config
    echo 0x03D6E690 1 > $DCC_PATH/config
    echo 0x03D6E694 1 > $DCC_PATH/config
    echo 0x03D6E698 1 > $DCC_PATH/config
    echo 0x03D6E69C 1 > $DCC_PATH/config
    echo 0x03D6E6A0 1 > $DCC_PATH/config
    echo 0x03D6E6A4 1 > $DCC_PATH/config
    echo 0x03D6E6A8 1 > $DCC_PATH/config
    echo 0x03D6E6AC 1 > $DCC_PATH/config
    echo 0x03D6E6B0 1 > $DCC_PATH/config
    echo 0x03D6E6B4 1 > $DCC_PATH/config
    echo 0x03D6E6B8 1 > $DCC_PATH/config
    echo 0x03D6E6BC 1 > $DCC_PATH/config
    echo 0x03D6E6C0 1 > $DCC_PATH/config
    echo 0x03D6E6C4 1 > $DCC_PATH/config
    echo 0x03D6E6C8 1 > $DCC_PATH/config
    echo 0x03D6E6CC 1 > $DCC_PATH/config
    echo 0x03D6E6D0 1 > $DCC_PATH/config
    echo 0x03D6E6D4 1 > $DCC_PATH/config
    echo 0x03D6E6D8 1 > $DCC_PATH/config
    echo 0x03D6E6DC 1 > $DCC_PATH/config
    echo 0x03D6E6E0 1 > $DCC_PATH/config
    echo 0x03D6E6E4 1 > $DCC_PATH/config
    echo 0x03D6E6E8 1 > $DCC_PATH/config
    echo 0x03D6E6EC 1 > $DCC_PATH/config
    echo 0x03D6E6F0 1 > $DCC_PATH/config
    echo 0x03D6E6F4 1 > $DCC_PATH/config
    echo 0x03D6E6F8 1 > $DCC_PATH/config
    echo 0x03D6E6FC 1 > $DCC_PATH/config
    echo 0x03D6E700 1 > $DCC_PATH/config
    echo 0x03D6E704 1 > $DCC_PATH/config
    echo 0x03D6E708 1 > $DCC_PATH/config
    echo 0x03D6E70C 1 > $DCC_PATH/config
    echo 0x03D6E710 1 > $DCC_PATH/config
    echo 0x03D6E714 1 > $DCC_PATH/config
    echo 0x03D6E718 1 > $DCC_PATH/config
    echo 0x03D6E71C 1 > $DCC_PATH/config
    echo 0x03D6E720 1 > $DCC_PATH/config
    echo 0x03D6E724 1 > $DCC_PATH/config
    echo 0x03D6E728 1 > $DCC_PATH/config
    echo 0x03D6E72C 1 > $DCC_PATH/config
    echo 0x03D6E730 1 > $DCC_PATH/config
    echo 0x03D6E734 1 > $DCC_PATH/config
    echo 0x03D6E738 1 > $DCC_PATH/config
    echo 0x03D6E73C 1 > $DCC_PATH/config
    echo 0x03D6E740 1 > $DCC_PATH/config
    echo 0x03D6E744 1 > $DCC_PATH/config
    echo 0x03D6E748 1 > $DCC_PATH/config
    echo 0x03D6E74C 1 > $DCC_PATH/config
    echo 0x03D6E750 1 > $DCC_PATH/config
    echo 0x03D6E754 1 > $DCC_PATH/config
    echo 0x03D6E758 1 > $DCC_PATH/config
    echo 0x03D6E75C 1 > $DCC_PATH/config
    echo 0x03D6E760 1 > $DCC_PATH/config
    echo 0x03D6E764 1 > $DCC_PATH/config
    echo 0x03D6E768 1 > $DCC_PATH/config
    echo 0x03D6E76C 1 > $DCC_PATH/config
    echo 0x03D6E770 1 > $DCC_PATH/config
    echo 0x03D6E774 1 > $DCC_PATH/config
    echo 0x03D6E778 1 > $DCC_PATH/config
    echo 0x03D6E77C 1 > $DCC_PATH/config
    echo 0x03D6E780 1 > $DCC_PATH/config
    echo 0x03D6E784 1 > $DCC_PATH/config
    echo 0x03D6E788 1 > $DCC_PATH/config
    echo 0x03D6E78C 1 > $DCC_PATH/config
    echo 0x03D6E790 1 > $DCC_PATH/config
    echo 0x03D6E794 1 > $DCC_PATH/config
    echo 0x03D6E798 1 > $DCC_PATH/config
    echo 0x03D6E79C 1 > $DCC_PATH/config
    echo 0x03D6E7A0 1 > $DCC_PATH/config
    echo 0x03D6E7A4 1 > $DCC_PATH/config
    echo 0x03D6E7A8 1 > $DCC_PATH/config
    echo 0x03D6E7AC 1 > $DCC_PATH/config
    echo 0x03D6E7B0 1 > $DCC_PATH/config
    echo 0x03D6E7B4 1 > $DCC_PATH/config
    echo 0x03D6E7B8 1 > $DCC_PATH/config
    echo 0x03D6E7BC 1 > $DCC_PATH/config
    echo 0x03D6E7C0 1 > $DCC_PATH/config
    echo 0x03D6E7C4 1 > $DCC_PATH/config
    echo 0x03D6E7C8 1 > $DCC_PATH/config
    echo 0x03D6E7CC 1 > $DCC_PATH/config
    echo 0x03D6E7D0 1 > $DCC_PATH/config
    echo 0x03D6E7D4 1 > $DCC_PATH/config
    echo 0x03D6E7D8 1 > $DCC_PATH/config
    echo 0x03D6E7DC 1 > $DCC_PATH/config
    echo 0x03D6E7E0 1 > $DCC_PATH/config
    echo 0x03D6E7E4 1 > $DCC_PATH/config
    echo 0x03D6E7E8 1 > $DCC_PATH/config
    echo 0x03D6E7EC 1 > $DCC_PATH/config
    echo 0x03D6E7F0 1 > $DCC_PATH/config
    echo 0x03D6E7F4 1 > $DCC_PATH/config
    echo 0x03D6E7F8 1 > $DCC_PATH/config
    echo 0x03D6E7FC 1 > $DCC_PATH/config
    echo 0x03D6E800 1 > $DCC_PATH/config
    echo 0x03D6E804 1 > $DCC_PATH/config
    echo 0x03D6E808 1 > $DCC_PATH/config
    echo 0x03D6E80C 1 > $DCC_PATH/config
    echo 0x03D6E810 1 > $DCC_PATH/config
    echo 0x03D6E814 1 > $DCC_PATH/config
    echo 0x03D6E818 1 > $DCC_PATH/config
    echo 0x03D6E81C 1 > $DCC_PATH/config
    echo 0x03D6E820 1 > $DCC_PATH/config
    echo 0x03D6E824 1 > $DCC_PATH/config
    echo 0x03D6E828 1 > $DCC_PATH/config
    echo 0x03D6E82C 1 > $DCC_PATH/config
    echo 0x03D6E830 1 > $DCC_PATH/config
    echo 0x03D6E834 1 > $DCC_PATH/config
    echo 0x03D6E838 1 > $DCC_PATH/config
    echo 0x03D6E83C 1 > $DCC_PATH/config
    echo 0x03D6E840 1 > $DCC_PATH/config
    echo 0x03D6E844 1 > $DCC_PATH/config
    echo 0x03D6E848 1 > $DCC_PATH/config
    echo 0x03D6E84C 1 > $DCC_PATH/config
    echo 0x03D6E850 1 > $DCC_PATH/config
    echo 0x03D6E854 1 > $DCC_PATH/config
    echo 0x03D6E858 1 > $DCC_PATH/config
    echo 0x03D6E85C 1 > $DCC_PATH/config
    echo 0x03D6E860 1 > $DCC_PATH/config
    echo 0x03D6E864 1 > $DCC_PATH/config
    echo 0x03D6E868 1 > $DCC_PATH/config
    echo 0x03D6E86C 1 > $DCC_PATH/config
    echo 0x03D6E870 1 > $DCC_PATH/config
    echo 0x03D6E874 1 > $DCC_PATH/config
    echo 0x03D6E878 1 > $DCC_PATH/config
    echo 0x03D6E87C 1 > $DCC_PATH/config
    echo 0x03D6E880 1 > $DCC_PATH/config
    echo 0x03D6E884 1 > $DCC_PATH/config
    echo 0x03D6E888 1 > $DCC_PATH/config
    echo 0x03D6E88C 1 > $DCC_PATH/config
    echo 0x03D6E890 1 > $DCC_PATH/config
    echo 0x03D6E894 1 > $DCC_PATH/config
    echo 0x03D6E898 1 > $DCC_PATH/config
    echo 0x03D6E89C 1 > $DCC_PATH/config
    echo 0x03D6E8A0 1 > $DCC_PATH/config
    echo 0x03D6E8A4 1 > $DCC_PATH/config
    echo 0x03D6E8A8 1 > $DCC_PATH/config
    echo 0x03D6E8AC 1 > $DCC_PATH/config
    echo 0x03D6E8B0 1 > $DCC_PATH/config
    echo 0x03D6E8B4 1 > $DCC_PATH/config
    echo 0x03D6E8B8 1 > $DCC_PATH/config
    echo 0x03D6E8BC 1 > $DCC_PATH/config
    echo 0x03D6E8C0 1 > $DCC_PATH/config
    echo 0x03D6E8C4 1 > $DCC_PATH/config
    echo 0x03D6E8C8 1 > $DCC_PATH/config
    echo 0x03D6E8CC 1 > $DCC_PATH/config
    echo 0x03D6E8D0 1 > $DCC_PATH/config
    echo 0x03D6E8D4 1 > $DCC_PATH/config
    echo 0x03D6E8D8 1 > $DCC_PATH/config
    echo 0x03D6E8DC 1 > $DCC_PATH/config
    echo 0x03D6E8E0 1 > $DCC_PATH/config
    echo 0x03D6E8E4 1 > $DCC_PATH/config
    echo 0x03D6E8E8 1 > $DCC_PATH/config
    echo 0x03D6E8EC 1 > $DCC_PATH/config
    echo 0x03D6E8F0 1 > $DCC_PATH/config
    echo 0x03D6E8F4 1 > $DCC_PATH/config
    echo 0x03D6E8F8 1 > $DCC_PATH/config
    echo 0x03D6E8FC 1 > $DCC_PATH/config
    echo 0x03D6E900 1 > $DCC_PATH/config
    echo 0x03D6E904 1 > $DCC_PATH/config
    echo 0x03D6E908 1 > $DCC_PATH/config
    echo 0x03D6E90C 1 > $DCC_PATH/config
    echo 0x03D6E910 1 > $DCC_PATH/config
    echo 0x03D6E914 1 > $DCC_PATH/config
    echo 0x03D6E918 1 > $DCC_PATH/config
    echo 0x03D6E91C 1 > $DCC_PATH/config
    echo 0x03D6E920 1 > $DCC_PATH/config
    echo 0x03D6E924 1 > $DCC_PATH/config
    echo 0x03D6E928 1 > $DCC_PATH/config
    echo 0x03D6E92C 1 > $DCC_PATH/config
    echo 0x03D6E930 1 > $DCC_PATH/config
    echo 0x03D6E934 1 > $DCC_PATH/config
    echo 0x03D6E938 1 > $DCC_PATH/config
    echo 0x03D6E93C 1 > $DCC_PATH/config
    echo 0x03D6E940 1 > $DCC_PATH/config
    echo 0x03D6E944 1 > $DCC_PATH/config
    echo 0x03D6E948 1 > $DCC_PATH/config
    echo 0x03D6E94C 1 > $DCC_PATH/config
    echo 0x03D6E950 1 > $DCC_PATH/config
    echo 0x03D6E954 1 > $DCC_PATH/config
    echo 0x03D6E958 1 > $DCC_PATH/config
    echo 0x03D6E95C 1 > $DCC_PATH/config
    echo 0x03D6E960 1 > $DCC_PATH/config
    echo 0x03D6E964 1 > $DCC_PATH/config
    echo 0x03D6E968 1 > $DCC_PATH/config
    echo 0x03D6E96C 1 > $DCC_PATH/config
    echo 0x03D6E970 1 > $DCC_PATH/config
    echo 0x03D6E974 1 > $DCC_PATH/config
    echo 0x03D6E978 1 > $DCC_PATH/config
    echo 0x03D6E97C 1 > $DCC_PATH/config
    echo 0x03D6E980 1 > $DCC_PATH/config
    echo 0x03D6E984 1 > $DCC_PATH/config
    echo 0x03D6E988 1 > $DCC_PATH/config
    echo 0x03D6E98C 1 > $DCC_PATH/config
    echo 0x03D6E990 1 > $DCC_PATH/config
    echo 0x03D6E994 1 > $DCC_PATH/config
    echo 0x03D6E998 1 > $DCC_PATH/config
    echo 0x03D6E99C 1 > $DCC_PATH/config
    echo 0x03D6E9A0 1 > $DCC_PATH/config
    echo 0x03D6E9A4 1 > $DCC_PATH/config
    echo 0x03D6E9A8 1 > $DCC_PATH/config
    echo 0x03D6E9AC 1 > $DCC_PATH/config
    echo 0x03D6E9B0 1 > $DCC_PATH/config
    echo 0x03D6E9B4 1 > $DCC_PATH/config
    echo 0x03D6E9B8 1 > $DCC_PATH/config
    echo 0x03D6E9BC 1 > $DCC_PATH/config
    echo 0x03D6E9C0 1 > $DCC_PATH/config
    echo 0x03D6E9C4 1 > $DCC_PATH/config
    echo 0x03D6E9C8 1 > $DCC_PATH/config
    echo 0x03D6E9CC 1 > $DCC_PATH/config
    echo 0x03D6E9D0 1 > $DCC_PATH/config
    echo 0x03D6E9D4 1 > $DCC_PATH/config
    echo 0x03D6E9D8 1 > $DCC_PATH/config
    echo 0x03D6E9DC 1 > $DCC_PATH/config
    echo 0x03D6E9E0 1 > $DCC_PATH/config
    echo 0x03D6E9E4 1 > $DCC_PATH/config
    echo 0x03D6E9E8 1 > $DCC_PATH/config
    echo 0x03D6E9EC 1 > $DCC_PATH/config
    echo 0x03D6E9F0 1 > $DCC_PATH/config
    echo 0x03D6E9F4 1 > $DCC_PATH/config
    echo 0x03D6E9F8 1 > $DCC_PATH/config
    echo 0x03D6E9FC 1 > $DCC_PATH/config
    echo 0x03D6EA00 1 > $DCC_PATH/config
    echo 0x03D6EA04 1 > $DCC_PATH/config
    echo 0x03D6EA08 1 > $DCC_PATH/config
    echo 0x03D6EA0C 1 > $DCC_PATH/config
    echo 0x03D6EA10 1 > $DCC_PATH/config
    echo 0x03D6EA14 1 > $DCC_PATH/config
    echo 0x03D6EA18 1 > $DCC_PATH/config
    echo 0x03D6EA1C 1 > $DCC_PATH/config
    echo 0x03D6EA20 1 > $DCC_PATH/config
    echo 0x03D6EA24 1 > $DCC_PATH/config
    echo 0x03D6EA28 1 > $DCC_PATH/config
    echo 0x03D6EA2C 1 > $DCC_PATH/config
    echo 0x03D6EA30 1 > $DCC_PATH/config
    echo 0x03D6EA34 1 > $DCC_PATH/config
    echo 0x03D6EA38 1 > $DCC_PATH/config
    echo 0x03D6EA3C 1 > $DCC_PATH/config
    echo 0x03D6EA40 1 > $DCC_PATH/config
    echo 0x03D6EA44 1 > $DCC_PATH/config
    echo 0x03D6EA48 1 > $DCC_PATH/config
    echo 0x03D6EA4C 1 > $DCC_PATH/config
    echo 0x03D6EA50 1 > $DCC_PATH/config
    echo 0x03D6EA54 1 > $DCC_PATH/config
    echo 0x03D6EA58 1 > $DCC_PATH/config
    echo 0x03D6EA5C 1 > $DCC_PATH/config
    echo 0x03D6EA60 1 > $DCC_PATH/config
    echo 0x03D6EA64 1 > $DCC_PATH/config
    echo 0x03D6EA68 1 > $DCC_PATH/config
    echo 0x03D6EA6C 1 > $DCC_PATH/config
    echo 0x03D6EA70 1 > $DCC_PATH/config
    echo 0x03D6EA74 1 > $DCC_PATH/config
    echo 0x03D6EA78 1 > $DCC_PATH/config
    echo 0x03D6EA7C 1 > $DCC_PATH/config
    echo 0x03D6EA80 1 > $DCC_PATH/config
    echo 0x03D6EA84 1 > $DCC_PATH/config
    echo 0x03D6EA88 1 > $DCC_PATH/config
    echo 0x03D6EA8C 1 > $DCC_PATH/config
    echo 0x03D6EA90 1 > $DCC_PATH/config
    echo 0x03D6EA94 1 > $DCC_PATH/config
    echo 0x03D6EA98 1 > $DCC_PATH/config
    echo 0x03D6EA9C 1 > $DCC_PATH/config
    echo 0x03D6EAA0 1 > $DCC_PATH/config
    echo 0x03D6EAA4 1 > $DCC_PATH/config
    echo 0x03D6EAA8 1 > $DCC_PATH/config
    echo 0x03D6EAAC 1 > $DCC_PATH/config
    echo 0x03D6EAB0 1 > $DCC_PATH/config
    echo 0x03D6EAB4 1 > $DCC_PATH/config
    echo 0x03D6EAB8 1 > $DCC_PATH/config
    echo 0x03D6EABC 1 > $DCC_PATH/config
    echo 0x03D6EAC0 1 > $DCC_PATH/config
    echo 0x03D6EAC4 1 > $DCC_PATH/config
    echo 0x03D6EAC8 1 > $DCC_PATH/config
    echo 0x03D6EACC 1 > $DCC_PATH/config
    echo 0x03D6EAD0 1 > $DCC_PATH/config
    echo 0x03D6EAD4 1 > $DCC_PATH/config
    echo 0x03D6EAD8 1 > $DCC_PATH/config
    echo 0x03D6EADC 1 > $DCC_PATH/config
    echo 0x03D6EAE0 1 > $DCC_PATH/config
    echo 0x03D6EAE4 1 > $DCC_PATH/config
    echo 0x03D6EAE8 1 > $DCC_PATH/config
    echo 0x03D6EAEC 1 > $DCC_PATH/config
    echo 0x03D6EAF0 1 > $DCC_PATH/config
    echo 0x03D6EAF4 1 > $DCC_PATH/config
    echo 0x03D6EAF8 1 > $DCC_PATH/config
    echo 0x03D6EAFC 1 > $DCC_PATH/config
    echo 0x03D6EB00 1 > $DCC_PATH/config
    echo 0x03D6EB04 1 > $DCC_PATH/config
    echo 0x03D6EB08 1 > $DCC_PATH/config
    echo 0x03D6EB0C 1 > $DCC_PATH/config
    echo 0x03D6EB10 1 > $DCC_PATH/config
    echo 0x03D6EB14 1 > $DCC_PATH/config
    echo 0x03D6EB18 1 > $DCC_PATH/config
    echo 0x03D6EB1C 1 > $DCC_PATH/config
    echo 0x03D6EB20 1 > $DCC_PATH/config
    echo 0x03D6EB24 1 > $DCC_PATH/config
    echo 0x03D6EB28 1 > $DCC_PATH/config
    echo 0x03D6EB2C 1 > $DCC_PATH/config
    echo 0x03D6EB30 1 > $DCC_PATH/config
    echo 0x03D6EB34 1 > $DCC_PATH/config
    echo 0x03D6EB38 1 > $DCC_PATH/config
    echo 0x03D6EB3C 1 > $DCC_PATH/config
    echo 0x03D6EB40 1 > $DCC_PATH/config
    echo 0x03D6EB44 1 > $DCC_PATH/config
    echo 0x03D6EB48 1 > $DCC_PATH/config
    echo 0x03D6EB4C 1 > $DCC_PATH/config
    echo 0x03D6EB50 1 > $DCC_PATH/config
    echo 0x03D6EB54 1 > $DCC_PATH/config
    echo 0x03D6EB58 1 > $DCC_PATH/config
    echo 0x03D6EB5C 1 > $DCC_PATH/config
    echo 0x03D6EB60 1 > $DCC_PATH/config
    echo 0x03D6EB64 1 > $DCC_PATH/config
    echo 0x03D6EB68 1 > $DCC_PATH/config
    echo 0x03D6EB6C 1 > $DCC_PATH/config
    echo 0x03D6EB70 1 > $DCC_PATH/config
    echo 0x03D6EB74 1 > $DCC_PATH/config
    echo 0x03D6EB78 1 > $DCC_PATH/config
    echo 0x03D6EB7C 1 > $DCC_PATH/config
    echo 0x03D6EB80 1 > $DCC_PATH/config
    echo 0x03D6EB84 1 > $DCC_PATH/config
    echo 0x03D6EB88 1 > $DCC_PATH/config
    echo 0x03D6EB8C 1 > $DCC_PATH/config
    echo 0x03D6EB90 1 > $DCC_PATH/config
    echo 0x03D6EB94 1 > $DCC_PATH/config
    echo 0x03D6EB98 1 > $DCC_PATH/config
    echo 0x03D6EB9C 1 > $DCC_PATH/config
    echo 0x03D6EBA0 1 > $DCC_PATH/config
    echo 0x03D6EBA4 1 > $DCC_PATH/config
    echo 0x03D6EBA8 1 > $DCC_PATH/config
    echo 0x03D6EBAC 1 > $DCC_PATH/config
    echo 0x03D6EBB0 1 > $DCC_PATH/config
    echo 0x03D6EBB4 1 > $DCC_PATH/config
    echo 0x03D6EBB8 1 > $DCC_PATH/config
    echo 0x03D6EBBC 1 > $DCC_PATH/config
    echo 0x03D6EBC0 1 > $DCC_PATH/config
    echo 0x03D6EBC4 1 > $DCC_PATH/config
    echo 0x03D6EBC8 1 > $DCC_PATH/config
    echo 0x03D6EBCC 1 > $DCC_PATH/config
    echo 0x03D6EBD0 1 > $DCC_PATH/config
    echo 0x03D6EBD4 1 > $DCC_PATH/config
    echo 0x03D6EBD8 1 > $DCC_PATH/config
    echo 0x03D6EBDC 1 > $DCC_PATH/config
    echo 0x03D6EBE0 1 > $DCC_PATH/config
    echo 0x03D6EBE4 1 > $DCC_PATH/config
    echo 0x03D6EBE8 1 > $DCC_PATH/config
    echo 0x03D6EBEC 1 > $DCC_PATH/config
    echo 0x03D6EBF0 1 > $DCC_PATH/config
    echo 0x03D6EBF4 1 > $DCC_PATH/config
    echo 0x03D6EBF8 1 > $DCC_PATH/config
    echo 0x03D6EBFC 1 > $DCC_PATH/config
    echo 0x03D6EC00 1 > $DCC_PATH/config
    echo 0x03D6EC04 1 > $DCC_PATH/config
    echo 0x03D6EC08 1 > $DCC_PATH/config
    echo 0x03D6EC0C 1 > $DCC_PATH/config
    echo 0x03D6EC10 1 > $DCC_PATH/config
    echo 0x03D6EC14 1 > $DCC_PATH/config
    echo 0x03D6EC18 1 > $DCC_PATH/config
    echo 0x03D6EC1C 1 > $DCC_PATH/config
    echo 0x03D6EC20 1 > $DCC_PATH/config
    echo 0x03D6EC24 1 > $DCC_PATH/config
    echo 0x03D6EC28 1 > $DCC_PATH/config
    echo 0x03D6EC2C 1 > $DCC_PATH/config
    echo 0x03D6EC30 1 > $DCC_PATH/config
    echo 0x03D6EC34 1 > $DCC_PATH/config
    echo 0x03D6EC38 1 > $DCC_PATH/config
    echo 0x03D6EC3C 1 > $DCC_PATH/config
    echo 0x03D6EC40 1 > $DCC_PATH/config
    echo 0x03D6EC44 1 > $DCC_PATH/config
    echo 0x03D6EC48 1 > $DCC_PATH/config
    echo 0x03D6EC4C 1 > $DCC_PATH/config
    echo 0x03D6EC50 1 > $DCC_PATH/config
    echo 0x03D6EC54 1 > $DCC_PATH/config
    echo 0x03D6EC58 1 > $DCC_PATH/config
    echo 0x03D6EC5C 1 > $DCC_PATH/config
    echo 0x03D6EC60 1 > $DCC_PATH/config
    echo 0x03D6EC64 1 > $DCC_PATH/config
    echo 0x03D6EC68 1 > $DCC_PATH/config
    echo 0x03D6EC6C 1 > $DCC_PATH/config
    echo 0x03D6EC70 1 > $DCC_PATH/config
    echo 0x03D6EC74 1 > $DCC_PATH/config
    echo 0x03D6EC78 1 > $DCC_PATH/config
    echo 0x03D6EC7C 1 > $DCC_PATH/config
    echo 0x03D6EC80 1 > $DCC_PATH/config
    echo 0x03D6EC84 1 > $DCC_PATH/config
    echo 0x03D6EC88 1 > $DCC_PATH/config
    echo 0x03D6EC8C 1 > $DCC_PATH/config
    echo 0x03D6EC90 1 > $DCC_PATH/config
    echo 0x03D6EC94 1 > $DCC_PATH/config
    echo 0x03D6EC98 1 > $DCC_PATH/config
    echo 0x03D6EC9C 1 > $DCC_PATH/config
    echo 0x03D6ECA0 1 > $DCC_PATH/config
    echo 0x03D6ECA4 1 > $DCC_PATH/config
    echo 0x03D6ECA8 1 > $DCC_PATH/config
    echo 0x03D6ECAC 1 > $DCC_PATH/config
    echo 0x03D6ECB0 1 > $DCC_PATH/config
    echo 0x03D6ECB4 1 > $DCC_PATH/config
    echo 0x03D6ECB8 1 > $DCC_PATH/config
    echo 0x03D6ECBC 1 > $DCC_PATH/config
    echo 0x03D6ECC0 1 > $DCC_PATH/config
    echo 0x03D6ECC4 1 > $DCC_PATH/config
    echo 0x03D6ECC8 1 > $DCC_PATH/config
    echo 0x03D6ECCC 1 > $DCC_PATH/config
    echo 0x03D6ECD0 1 > $DCC_PATH/config
    echo 0x03D6ECD4 1 > $DCC_PATH/config
    echo 0x03D6ECD8 1 > $DCC_PATH/config
    echo 0x03D6ECDC 1 > $DCC_PATH/config
    echo 0x03D6ECE0 1 > $DCC_PATH/config
    echo 0x03D6ECE4 1 > $DCC_PATH/config
    echo 0x03D6ECE8 1 > $DCC_PATH/config
    echo 0x03D6ECEC 1 > $DCC_PATH/config
    echo 0x03D6ECF0 1 > $DCC_PATH/config
    echo 0x03D6ECF4 1 > $DCC_PATH/config
    echo 0x03D6ECF8 1 > $DCC_PATH/config
    echo 0x03D6ECFC 1 > $DCC_PATH/config
    echo 0x03D6ED00 1 > $DCC_PATH/config
    echo 0x03D6ED04 1 > $DCC_PATH/config
    echo 0x03D6ED08 1 > $DCC_PATH/config
    echo 0x03D6ED0C 1 > $DCC_PATH/config
    echo 0x03D6ED10 1 > $DCC_PATH/config
    echo 0x03D6ED14 1 > $DCC_PATH/config
    echo 0x03D6ED18 1 > $DCC_PATH/config
    echo 0x03D6ED1C 1 > $DCC_PATH/config
    echo 0x03D6ED20 1 > $DCC_PATH/config
    echo 0x03D6ED24 1 > $DCC_PATH/config
    echo 0x03D6ED28 1 > $DCC_PATH/config
    echo 0x03D6ED2C 1 > $DCC_PATH/config
    echo 0x03D6ED30 1 > $DCC_PATH/config
    echo 0x03D6ED34 1 > $DCC_PATH/config
    echo 0x03D6ED38 1 > $DCC_PATH/config
    echo 0x03D6ED3C 1 > $DCC_PATH/config
    echo 0x03D6ED40 1 > $DCC_PATH/config
    echo 0x03D6ED44 1 > $DCC_PATH/config
    echo 0x03D6ED48 1 > $DCC_PATH/config
    echo 0x03D6ED4C 1 > $DCC_PATH/config
    echo 0x03D6ED50 1 > $DCC_PATH/config
    echo 0x03D6ED54 1 > $DCC_PATH/config
    echo 0x03D6ED58 1 > $DCC_PATH/config
    echo 0x03D6ED5C 1 > $DCC_PATH/config
    echo 0x03D6ED60 1 > $DCC_PATH/config
    echo 0x03D6ED64 1 > $DCC_PATH/config
    echo 0x03D6ED68 1 > $DCC_PATH/config
    echo 0x03D6ED6C 1 > $DCC_PATH/config
    echo 0x03D6ED70 1 > $DCC_PATH/config
    echo 0x03D6ED74 1 > $DCC_PATH/config
    echo 0x03D6ED78 1 > $DCC_PATH/config
    echo 0x03D6ED7C 1 > $DCC_PATH/config
    echo 0x03D6ED80 1 > $DCC_PATH/config
    echo 0x03D6ED84 1 > $DCC_PATH/config
    echo 0x03D6ED88 1 > $DCC_PATH/config
    echo 0x03D6ED8C 1 > $DCC_PATH/config
    echo 0x03D6ED90 1 > $DCC_PATH/config
    echo 0x03D6ED94 1 > $DCC_PATH/config
    echo 0x03D6ED98 1 > $DCC_PATH/config
    echo 0x03D6ED9C 1 > $DCC_PATH/config
    echo 0x03D6EDA0 1 > $DCC_PATH/config
    echo 0x03D6EDA4 1 > $DCC_PATH/config
    echo 0x03D6EDA8 1 > $DCC_PATH/config
    echo 0x03D6EDAC 1 > $DCC_PATH/config
    echo 0x03D6EDB0 1 > $DCC_PATH/config
    echo 0x03D6EDB4 1 > $DCC_PATH/config
    echo 0x03D6EDB8 1 > $DCC_PATH/config
    echo 0x03D6EDBC 1 > $DCC_PATH/config
    echo 0x03D6EDC0 1 > $DCC_PATH/config
    echo 0x03D6EDC4 1 > $DCC_PATH/config
    echo 0x03D6EDC8 1 > $DCC_PATH/config
    echo 0x03D6EDCC 1 > $DCC_PATH/config
    echo 0x03D6EDD0 1 > $DCC_PATH/config
    echo 0x03D6EDD4 1 > $DCC_PATH/config
    echo 0x03D6EDD8 1 > $DCC_PATH/config
    echo 0x03D6EDDC 1 > $DCC_PATH/config
    echo 0x03D6EDE0 1 > $DCC_PATH/config
    echo 0x03D6EDE4 1 > $DCC_PATH/config
    echo 0x03D6EDE8 1 > $DCC_PATH/config
    echo 0x03D6EDEC 1 > $DCC_PATH/config
    echo 0x03D6EDF0 1 > $DCC_PATH/config
    echo 0x03D6EDF4 1 > $DCC_PATH/config
    echo 0x03D6EDF8 1 > $DCC_PATH/config
    echo 0x03D6EDFC 1 > $DCC_PATH/config
    echo 0x03D6EE00 1 > $DCC_PATH/config
    echo 0x03D6EE04 1 > $DCC_PATH/config
    echo 0x03D6EE08 1 > $DCC_PATH/config
    echo 0x03D6EE0C 1 > $DCC_PATH/config
    echo 0x03D6EE10 1 > $DCC_PATH/config
    echo 0x03D6EE14 1 > $DCC_PATH/config
    echo 0x03D6EE18 1 > $DCC_PATH/config
    echo 0x03D6EE1C 1 > $DCC_PATH/config
    echo 0x03D6EE20 1 > $DCC_PATH/config
    echo 0x03D6EE24 1 > $DCC_PATH/config
    echo 0x03D6EE28 1 > $DCC_PATH/config
    echo 0x03D6EE2C 1 > $DCC_PATH/config
    echo 0x03D6EE30 1 > $DCC_PATH/config
    echo 0x03D6EE34 1 > $DCC_PATH/config
    echo 0x03D6EE38 1 > $DCC_PATH/config
    echo 0x03D6EE3C 1 > $DCC_PATH/config
    echo 0x03D6EE40 1 > $DCC_PATH/config
    echo 0x03D6EE44 1 > $DCC_PATH/config
    echo 0x03D6EE48 1 > $DCC_PATH/config
    echo 0x03D6EE4C 1 > $DCC_PATH/config
    echo 0x03D6EE50 1 > $DCC_PATH/config
    echo 0x03D6EE54 1 > $DCC_PATH/config
    echo 0x03D6EE58 1 > $DCC_PATH/config
    echo 0x03D6EE5C 1 > $DCC_PATH/config
    echo 0x03D6EE60 1 > $DCC_PATH/config
    echo 0x03D6EE64 1 > $DCC_PATH/config
    echo 0x03D6EE68 1 > $DCC_PATH/config
    echo 0x03D6EE6C 1 > $DCC_PATH/config
    echo 0x03D6EE70 1 > $DCC_PATH/config
    echo 0x03D6EE74 1 > $DCC_PATH/config
    echo 0x03D6EE78 1 > $DCC_PATH/config
    echo 0x03D6EE7C 1 > $DCC_PATH/config
    echo 0x03D6EE80 1 > $DCC_PATH/config
    echo 0x03D6EE84 1 > $DCC_PATH/config
    echo 0x03D6EE88 1 > $DCC_PATH/config
    echo 0x03D6EE8C 1 > $DCC_PATH/config
    echo 0x03D6EE90 1 > $DCC_PATH/config
    echo 0x03D6EE94 1 > $DCC_PATH/config
    echo 0x03D6EE98 1 > $DCC_PATH/config
    echo 0x03D6EE9C 1 > $DCC_PATH/config
    echo 0x03D6EEA0 1 > $DCC_PATH/config
    echo 0x03D6EEA4 1 > $DCC_PATH/config
    echo 0x03D6EEA8 1 > $DCC_PATH/config
    echo 0x03D6EEAC 1 > $DCC_PATH/config
    echo 0x03D6EEB0 1 > $DCC_PATH/config
    echo 0x03D6EEB4 1 > $DCC_PATH/config
    echo 0x03D6EEB8 1 > $DCC_PATH/config
    echo 0x03D6EEBC 1 > $DCC_PATH/config
    echo 0x03D6EEC0 1 > $DCC_PATH/config
    echo 0x03D6EEC4 1 > $DCC_PATH/config
    echo 0x03D6EEC8 1 > $DCC_PATH/config
    echo 0x03D6EECC 1 > $DCC_PATH/config
    echo 0x03D6EED0 1 > $DCC_PATH/config
    echo 0x03D6EED4 1 > $DCC_PATH/config
    echo 0x03D6EED8 1 > $DCC_PATH/config
    echo 0x03D6EEDC 1 > $DCC_PATH/config
    echo 0x03D6EEE0 1 > $DCC_PATH/config
    echo 0x03D6EEE4 1 > $DCC_PATH/config
    echo 0x03D6EEE8 1 > $DCC_PATH/config
    echo 0x03D6EEEC 1 > $DCC_PATH/config
    echo 0x03D6EEF0 1 > $DCC_PATH/config
    echo 0x03D6EEF4 1 > $DCC_PATH/config
    echo 0x03D6EEF8 1 > $DCC_PATH/config
    echo 0x03D6EEFC 1 > $DCC_PATH/config
    echo 0x03D6EF00 1 > $DCC_PATH/config
    echo 0x03D6EF04 1 > $DCC_PATH/config
    echo 0x03D6EF08 1 > $DCC_PATH/config
    echo 0x03D6EF0C 1 > $DCC_PATH/config
    echo 0x03D6EF10 1 > $DCC_PATH/config
    echo 0x03D6EF14 1 > $DCC_PATH/config
    echo 0x03D6EF18 1 > $DCC_PATH/config
    echo 0x03D6EF1C 1 > $DCC_PATH/config
    echo 0x03D6EF20 1 > $DCC_PATH/config
    echo 0x03D6EF24 1 > $DCC_PATH/config
    echo 0x03D6EF28 1 > $DCC_PATH/config
    echo 0x03D6EF2C 1 > $DCC_PATH/config
    echo 0x03D6EF30 1 > $DCC_PATH/config
    echo 0x03D6EF34 1 > $DCC_PATH/config
    echo 0x03D6EF38 1 > $DCC_PATH/config
    echo 0x03D6EF3C 1 > $DCC_PATH/config
    echo 0x03D6EF40 1 > $DCC_PATH/config
    echo 0x03D6EF44 1 > $DCC_PATH/config
    echo 0x03D6EF48 1 > $DCC_PATH/config
    echo 0x03D6EF4C 1 > $DCC_PATH/config
    echo 0x03D6EF50 1 > $DCC_PATH/config
    echo 0x03D6EF54 1 > $DCC_PATH/config
    echo 0x03D6EF58 1 > $DCC_PATH/config
    echo 0x03D6EF5C 1 > $DCC_PATH/config
    echo 0x03D6EF60 1 > $DCC_PATH/config
    echo 0x03D6EF64 1 > $DCC_PATH/config
    echo 0x03D6EF68 1 > $DCC_PATH/config
    echo 0x03D6EF6C 1 > $DCC_PATH/config
    echo 0x03D6EF70 1 > $DCC_PATH/config
    echo 0x03D6EF74 1 > $DCC_PATH/config
    echo 0x03D6EF78 1 > $DCC_PATH/config
    echo 0x03D6EF7C 1 > $DCC_PATH/config
    echo 0x03D6EF80 1 > $DCC_PATH/config
    echo 0x03D6EF84 1 > $DCC_PATH/config
    echo 0x03D6EF88 1 > $DCC_PATH/config
    echo 0x03D6EF8C 1 > $DCC_PATH/config
    echo 0x03D6EF90 1 > $DCC_PATH/config
    echo 0x03D6EF94 1 > $DCC_PATH/config
    echo 0x03D6EF98 1 > $DCC_PATH/config
    echo 0x03D6EF9C 1 > $DCC_PATH/config
    echo 0x03D6EFA0 1 > $DCC_PATH/config
    echo 0x03D6EFA4 1 > $DCC_PATH/config
    echo 0x03D6EFA8 1 > $DCC_PATH/config
    echo 0x03D6EFAC 1 > $DCC_PATH/config
    echo 0x03D6EFB0 1 > $DCC_PATH/config
    echo 0x03D6EFB4 1 > $DCC_PATH/config
    echo 0x03D6EFB8 1 > $DCC_PATH/config
    echo 0x03D6EFBC 1 > $DCC_PATH/config
    echo 0x03D6EFC0 1 > $DCC_PATH/config
    echo 0x03D6EFC4 1 > $DCC_PATH/config
    echo 0x03D6EFC8 1 > $DCC_PATH/config
    echo 0x03D6EFCC 1 > $DCC_PATH/config
    echo 0x03D6EFD0 1 > $DCC_PATH/config
    echo 0x03D6EFD4 1 > $DCC_PATH/config
    echo 0x03D6EFD8 1 > $DCC_PATH/config
    echo 0x03D6EFDC 1 > $DCC_PATH/config
    echo 0x03D6EFE0 1 > $DCC_PATH/config
    echo 0x03D6EFE4 1 > $DCC_PATH/config
    echo 0x03D6EFE8 1 > $DCC_PATH/config
    echo 0x03D6EFEC 1 > $DCC_PATH/config
    echo 0x03D6EFF0 1 > $DCC_PATH/config
    echo 0x03D6EFF4 1 > $DCC_PATH/config
    echo 0x03D6EFF8 1 > $DCC_PATH/config
    echo 0x03D6EFFC 1 > $DCC_PATH/config
    echo 0x03D6F000 1 > $DCC_PATH/config
    echo 0x03D6F004 1 > $DCC_PATH/config
    echo 0x03D6F008 1 > $DCC_PATH/config
    echo 0x03D6F00C 1 > $DCC_PATH/config
    echo 0x03D6F010 1 > $DCC_PATH/config
    echo 0x03D6F014 1 > $DCC_PATH/config
    echo 0x03D6F018 1 > $DCC_PATH/config
    echo 0x03D6F01C 1 > $DCC_PATH/config
    echo 0x03D6F020 1 > $DCC_PATH/config
    echo 0x03D6F024 1 > $DCC_PATH/config
    echo 0x03D6F028 1 > $DCC_PATH/config
    echo 0x03D6F02C 1 > $DCC_PATH/config
    echo 0x03D6F030 1 > $DCC_PATH/config
    echo 0x03D6F034 1 > $DCC_PATH/config
    echo 0x03D6F038 1 > $DCC_PATH/config
    echo 0x03D6F03C 1 > $DCC_PATH/config
    echo 0x03D6F040 1 > $DCC_PATH/config
    echo 0x03D6F044 1 > $DCC_PATH/config
    echo 0x03D6F048 1 > $DCC_PATH/config
    echo 0x03D6F04C 1 > $DCC_PATH/config
    echo 0x03D6F050 1 > $DCC_PATH/config
    echo 0x03D6F054 1 > $DCC_PATH/config
    echo 0x03D6F058 1 > $DCC_PATH/config
    echo 0x03D6F05C 1 > $DCC_PATH/config
    echo 0x03D6F060 1 > $DCC_PATH/config
    echo 0x03D6F064 1 > $DCC_PATH/config
    echo 0x03D6F068 1 > $DCC_PATH/config
    echo 0x03D6F06C 1 > $DCC_PATH/config
    echo 0x03D6F070 1 > $DCC_PATH/config
    echo 0x03D6F074 1 > $DCC_PATH/config
    echo 0x03D6F078 1 > $DCC_PATH/config
    echo 0x03D6F07C 1 > $DCC_PATH/config
    echo 0x03D6F080 1 > $DCC_PATH/config
    echo 0x03D6F084 1 > $DCC_PATH/config
    echo 0x03D6F088 1 > $DCC_PATH/config
    echo 0x03D6F08C 1 > $DCC_PATH/config
    echo 0x03D6F090 1 > $DCC_PATH/config
    echo 0x03D6F094 1 > $DCC_PATH/config
    echo 0x03D6F098 1 > $DCC_PATH/config
    echo 0x03D6F09C 1 > $DCC_PATH/config
    echo 0x03D6F0A0 1 > $DCC_PATH/config
    echo 0x03D6F0A4 1 > $DCC_PATH/config
    echo 0x03D6F0A8 1 > $DCC_PATH/config
    echo 0x03D6F0AC 1 > $DCC_PATH/config
    echo 0x03D6F0B0 1 > $DCC_PATH/config
    echo 0x03D6F0B4 1 > $DCC_PATH/config
    echo 0x03D6F0B8 1 > $DCC_PATH/config
    echo 0x03D6F0BC 1 > $DCC_PATH/config
    echo 0x03D6F0C0 1 > $DCC_PATH/config
    echo 0x03D6F0C4 1 > $DCC_PATH/config
    echo 0x03D6F0C8 1 > $DCC_PATH/config
    echo 0x03D6F0CC 1 > $DCC_PATH/config
    echo 0x03D6F0D0 1 > $DCC_PATH/config
    echo 0x03D6F0D4 1 > $DCC_PATH/config
    echo 0x03D6F0D8 1 > $DCC_PATH/config
    echo 0x03D6F0DC 1 > $DCC_PATH/config
    echo 0x03D6F0E0 1 > $DCC_PATH/config
    echo 0x03D6F0E4 1 > $DCC_PATH/config
    echo 0x03D6F0E8 1 > $DCC_PATH/config
    echo 0x03D6F0EC 1 > $DCC_PATH/config
    echo 0x03D6F0F0 1 > $DCC_PATH/config
    echo 0x03D6F0F4 1 > $DCC_PATH/config
    echo 0x03D6F0F8 1 > $DCC_PATH/config
    echo 0x03D6F0FC 1 > $DCC_PATH/config
    echo 0x03D6F100 1 > $DCC_PATH/config
    echo 0x03D6F104 1 > $DCC_PATH/config
    echo 0x03D6F108 1 > $DCC_PATH/config
    echo 0x03D6F10C 1 > $DCC_PATH/config
    echo 0x03D6F110 1 > $DCC_PATH/config
    echo 0x03D6F114 1 > $DCC_PATH/config
    echo 0x03D6F118 1 > $DCC_PATH/config
    echo 0x03D6F11C 1 > $DCC_PATH/config
    echo 0x03D6F120 1 > $DCC_PATH/config
    echo 0x03D6F124 1 > $DCC_PATH/config
    echo 0x03D6F128 1 > $DCC_PATH/config
    echo 0x03D6F12C 1 > $DCC_PATH/config
    echo 0x03D6F130 1 > $DCC_PATH/config
    echo 0x03D6F134 1 > $DCC_PATH/config
    echo 0x03D6F138 1 > $DCC_PATH/config
    echo 0x03D6F13C 1 > $DCC_PATH/config
    echo 0x03D6F140 1 > $DCC_PATH/config
    echo 0x03D6F144 1 > $DCC_PATH/config
    echo 0x03D6F148 1 > $DCC_PATH/config
    echo 0x03D6F14C 1 > $DCC_PATH/config
    echo 0x03D6F150 1 > $DCC_PATH/config
    echo 0x03D6F154 1 > $DCC_PATH/config
    echo 0x03D6F158 1 > $DCC_PATH/config
    echo 0x03D6F15C 1 > $DCC_PATH/config
    echo 0x03D6F160 1 > $DCC_PATH/config
    echo 0x03D6F164 1 > $DCC_PATH/config
    echo 0x03D6F168 1 > $DCC_PATH/config
    echo 0x03D6F16C 1 > $DCC_PATH/config
    echo 0x03D6F170 1 > $DCC_PATH/config
    echo 0x03D6F174 1 > $DCC_PATH/config
    echo 0x03D6F178 1 > $DCC_PATH/config
    echo 0x03D6F17C 1 > $DCC_PATH/config
    echo 0x03D6F180 1 > $DCC_PATH/config
    echo 0x03D6F184 1 > $DCC_PATH/config
    echo 0x03D6F188 1 > $DCC_PATH/config
    echo 0x03D6F18C 1 > $DCC_PATH/config
    echo 0x03D6F190 1 > $DCC_PATH/config
    echo 0x03D6F194 1 > $DCC_PATH/config
    echo 0x03D6F198 1 > $DCC_PATH/config
    echo 0x03D6F19C 1 > $DCC_PATH/config
    echo 0x03D6F1A0 1 > $DCC_PATH/config
    echo 0x03D6F1A4 1 > $DCC_PATH/config
    echo 0x03D6F1A8 1 > $DCC_PATH/config
    echo 0x03D6F1AC 1 > $DCC_PATH/config
    echo 0x03D6F1B0 1 > $DCC_PATH/config
    echo 0x03D6F1B4 1 > $DCC_PATH/config
    echo 0x03D6F1B8 1 > $DCC_PATH/config
    echo 0x03D6F1BC 1 > $DCC_PATH/config
    echo 0x03D6F1C0 1 > $DCC_PATH/config
    echo 0x03D6F1C4 1 > $DCC_PATH/config
    echo 0x03D6F1C8 1 > $DCC_PATH/config
    echo 0x03D6F1CC 1 > $DCC_PATH/config
    echo 0x03D6F1D0 1 > $DCC_PATH/config
    echo 0x03D6F1D4 1 > $DCC_PATH/config
    echo 0x03D6F1D8 1 > $DCC_PATH/config
    echo 0x03D6F1DC 1 > $DCC_PATH/config
    echo 0x03D6F1E0 1 > $DCC_PATH/config
    echo 0x03D6F1E4 1 > $DCC_PATH/config
    echo 0x03D6F1E8 1 > $DCC_PATH/config
    echo 0x03D6F1EC 1 > $DCC_PATH/config
    echo 0x03D6F1F0 1 > $DCC_PATH/config
    echo 0x03D6F1F4 1 > $DCC_PATH/config
    echo 0x03D6F1F8 1 > $DCC_PATH/config
    echo 0x03D6F1FC 1 > $DCC_PATH/config
    echo 0x03D6F200 1 > $DCC_PATH/config
    echo 0x03D6F204 1 > $DCC_PATH/config
    echo 0x03D6F208 1 > $DCC_PATH/config
    echo 0x03D6F20C 1 > $DCC_PATH/config
    echo 0x03D6F210 1 > $DCC_PATH/config
    echo 0x03D6F214 1 > $DCC_PATH/config
    echo 0x03D6F218 1 > $DCC_PATH/config
    echo 0x03D6F21C 1 > $DCC_PATH/config
    echo 0x03D6F220 1 > $DCC_PATH/config
    echo 0x03D6F224 1 > $DCC_PATH/config
    echo 0x03D6F228 1 > $DCC_PATH/config
    echo 0x03D6F22C 1 > $DCC_PATH/config
    echo 0x03D6F230 1 > $DCC_PATH/config
    echo 0x03D6F234 1 > $DCC_PATH/config
    echo 0x03D6F238 1 > $DCC_PATH/config
    echo 0x03D6F23C 1 > $DCC_PATH/config
    echo 0x03D6F240 1 > $DCC_PATH/config
    echo 0x03D6F244 1 > $DCC_PATH/config
    echo 0x03D6F248 1 > $DCC_PATH/config
    echo 0x03D6F24C 1 > $DCC_PATH/config
    echo 0x03D6F250 1 > $DCC_PATH/config
    echo 0x03D6F254 1 > $DCC_PATH/config
    echo 0x03D6F258 1 > $DCC_PATH/config
    echo 0x03D6F25C 1 > $DCC_PATH/config
    echo 0x03D6F260 1 > $DCC_PATH/config
    echo 0x03D6F264 1 > $DCC_PATH/config
    echo 0x03D6F268 1 > $DCC_PATH/config
    echo 0x03D6F26C 1 > $DCC_PATH/config
    echo 0x03D6F270 1 > $DCC_PATH/config
    echo 0x03D6F274 1 > $DCC_PATH/config
    echo 0x03D6F278 1 > $DCC_PATH/config
    echo 0x03D6F27C 1 > $DCC_PATH/config
    echo 0x03D6F280 1 > $DCC_PATH/config
    echo 0x03D6F284 1 > $DCC_PATH/config
    echo 0x03D6F288 1 > $DCC_PATH/config
    echo 0x03D6F28C 1 > $DCC_PATH/config
    echo 0x03D6F290 1 > $DCC_PATH/config
    echo 0x03D6F294 1 > $DCC_PATH/config
    echo 0x03D6F298 1 > $DCC_PATH/config
    echo 0x03D6F29C 1 > $DCC_PATH/config
    echo 0x03D6F2A0 1 > $DCC_PATH/config
    echo 0x03D6F2A4 1 > $DCC_PATH/config
    echo 0x03D6F2A8 1 > $DCC_PATH/config
    echo 0x03D6F2AC 1 > $DCC_PATH/config
    echo 0x03D6F2B0 1 > $DCC_PATH/config
    echo 0x03D6F2B4 1 > $DCC_PATH/config
    echo 0x03D6F2B8 1 > $DCC_PATH/config
    echo 0x03D6F2BC 1 > $DCC_PATH/config
    echo 0x03D6F2C0 1 > $DCC_PATH/config
    echo 0x03D6F2C4 1 > $DCC_PATH/config
    echo 0x03D6F2C8 1 > $DCC_PATH/config
    echo 0x03D6F2CC 1 > $DCC_PATH/config
    echo 0x03D6F2D0 1 > $DCC_PATH/config
    echo 0x03D6F2D4 1 > $DCC_PATH/config
    echo 0x03D6F2D8 1 > $DCC_PATH/config
    echo 0x03D6F2DC 1 > $DCC_PATH/config
    echo 0x03D6F2E0 1 > $DCC_PATH/config
    echo 0x03D6F2E4 1 > $DCC_PATH/config
    echo 0x03D6F2E8 1 > $DCC_PATH/config
    echo 0x03D6F2EC 1 > $DCC_PATH/config
    echo 0x03D6F2F0 1 > $DCC_PATH/config
    echo 0x03D6F2F4 1 > $DCC_PATH/config
    echo 0x03D6F2F8 1 > $DCC_PATH/config
    echo 0x03D6F2FC 1 > $DCC_PATH/config
    echo 0x03D6F300 1 > $DCC_PATH/config
    echo 0x03D6F304 1 > $DCC_PATH/config
    echo 0x03D6F308 1 > $DCC_PATH/config
    echo 0x03D6F30C 1 > $DCC_PATH/config
    echo 0x03D6F310 1 > $DCC_PATH/config
    echo 0x03D6F314 1 > $DCC_PATH/config
    echo 0x03D6F318 1 > $DCC_PATH/config
    echo 0x03D6F31C 1 > $DCC_PATH/config
    echo 0x03D6F320 1 > $DCC_PATH/config
    echo 0x03D6F324 1 > $DCC_PATH/config
    echo 0x03D6F328 1 > $DCC_PATH/config
    echo 0x03D6F32C 1 > $DCC_PATH/config
    echo 0x03D6F330 1 > $DCC_PATH/config
    echo 0x03D6F334 1 > $DCC_PATH/config
    echo 0x03D6F338 1 > $DCC_PATH/config
    echo 0x03D6F33C 1 > $DCC_PATH/config
    echo 0x03D6F340 1 > $DCC_PATH/config
    echo 0x03D6F344 1 > $DCC_PATH/config
    echo 0x03D6F348 1 > $DCC_PATH/config
    echo 0x03D6F34C 1 > $DCC_PATH/config
    echo 0x03D6F350 1 > $DCC_PATH/config
    echo 0x03D6F354 1 > $DCC_PATH/config
    echo 0x03D6F358 1 > $DCC_PATH/config
    echo 0x03D6F35C 1 > $DCC_PATH/config
    echo 0x03D6F360 1 > $DCC_PATH/config
    echo 0x03D6F364 1 > $DCC_PATH/config
    echo 0x03D6F368 1 > $DCC_PATH/config
    echo 0x03D6F36C 1 > $DCC_PATH/config
    echo 0x03D6F370 1 > $DCC_PATH/config
    echo 0x03D6F374 1 > $DCC_PATH/config
    echo 0x03D6F378 1 > $DCC_PATH/config
    echo 0x03D6F37C 1 > $DCC_PATH/config
    echo 0x03D6F380 1 > $DCC_PATH/config
    echo 0x03D6F384 1 > $DCC_PATH/config
    echo 0x03D6F388 1 > $DCC_PATH/config
    echo 0x03D6F38C 1 > $DCC_PATH/config
    echo 0x03D6F390 1 > $DCC_PATH/config
    echo 0x03D6F394 1 > $DCC_PATH/config
    echo 0x03D6F398 1 > $DCC_PATH/config
    echo 0x03D6F39C 1 > $DCC_PATH/config
    echo 0x03D6F3A0 1 > $DCC_PATH/config
    echo 0x03D6F3A4 1 > $DCC_PATH/config
    echo 0x03D6F3A8 1 > $DCC_PATH/config
    echo 0x03D6F3AC 1 > $DCC_PATH/config
    echo 0x03D6F3B0 1 > $DCC_PATH/config
    echo 0x03D6F3B4 1 > $DCC_PATH/config
    echo 0x03D6F3B8 1 > $DCC_PATH/config
    echo 0x03D6F3BC 1 > $DCC_PATH/config
    echo 0x03D6F3C0 1 > $DCC_PATH/config
    echo 0x03D6F3C4 1 > $DCC_PATH/config
    echo 0x03D6F3C8 1 > $DCC_PATH/config
    echo 0x03D6F3CC 1 > $DCC_PATH/config
    echo 0x03D6F3D0 1 > $DCC_PATH/config
    echo 0x03D6F3D4 1 > $DCC_PATH/config
    echo 0x03D6F3D8 1 > $DCC_PATH/config
    echo 0x03D6F3DC 1 > $DCC_PATH/config
    echo 0x03D6F3E0 1 > $DCC_PATH/config
    echo 0x03D6F3E4 1 > $DCC_PATH/config
    echo 0x03D6F3E8 1 > $DCC_PATH/config
    echo 0x03D6F3EC 1 > $DCC_PATH/config
    echo 0x03D6F3F0 1 > $DCC_PATH/config
    echo 0x03D6F3F4 1 > $DCC_PATH/config
    echo 0x03D6F3F8 1 > $DCC_PATH/config
    echo 0x03D6F3FC 1 > $DCC_PATH/config
    echo 0x03D6F400 1 > $DCC_PATH/config
    echo 0x03D6F404 1 > $DCC_PATH/config
    echo 0x03D6F408 1 > $DCC_PATH/config
    echo 0x03D6F40C 1 > $DCC_PATH/config
    echo 0x03D6F410 1 > $DCC_PATH/config
    echo 0x03D6F414 1 > $DCC_PATH/config
    echo 0x03D6F418 1 > $DCC_PATH/config
    echo 0x03D6F41C 1 > $DCC_PATH/config
    echo 0x03D6F420 1 > $DCC_PATH/config
    echo 0x03D6F424 1 > $DCC_PATH/config
    echo 0x03D6F428 1 > $DCC_PATH/config
    echo 0x03D6F42C 1 > $DCC_PATH/config
    echo 0x03D6F430 1 > $DCC_PATH/config
    echo 0x03D6F434 1 > $DCC_PATH/config
    echo 0x03D6F438 1 > $DCC_PATH/config
    echo 0x03D6F43C 1 > $DCC_PATH/config
    echo 0x03D6F440 1 > $DCC_PATH/config
    echo 0x03D6F444 1 > $DCC_PATH/config
    echo 0x03D6F448 1 > $DCC_PATH/config
    echo 0x03D6F44C 1 > $DCC_PATH/config
    echo 0x03D6F450 1 > $DCC_PATH/config
    echo 0x03D6F454 1 > $DCC_PATH/config
    echo 0x03D6F458 1 > $DCC_PATH/config
    echo 0x03D6F45C 1 > $DCC_PATH/config
    echo 0x03D6F460 1 > $DCC_PATH/config
    echo 0x03D6F464 1 > $DCC_PATH/config
    echo 0x03D6F468 1 > $DCC_PATH/config
    echo 0x03D6F46C 1 > $DCC_PATH/config
    echo 0x03D6F470 1 > $DCC_PATH/config
    echo 0x03D6F474 1 > $DCC_PATH/config
    echo 0x03D6F478 1 > $DCC_PATH/config
    echo 0x03D6F47C 1 > $DCC_PATH/config
    echo 0x03D6F480 1 > $DCC_PATH/config
    echo 0x03D6F484 1 > $DCC_PATH/config
    echo 0x03D6F488 1 > $DCC_PATH/config
    echo 0x03D6F48C 1 > $DCC_PATH/config
    echo 0x03D6F490 1 > $DCC_PATH/config
    echo 0x03D6F494 1 > $DCC_PATH/config
    echo 0x03D6F498 1 > $DCC_PATH/config
    echo 0x03D6F49C 1 > $DCC_PATH/config
    echo 0x03D6F4A0 1 > $DCC_PATH/config
    echo 0x03D6F4A4 1 > $DCC_PATH/config
    echo 0x03D6F4A8 1 > $DCC_PATH/config
    echo 0x03D6F4AC 1 > $DCC_PATH/config
    echo 0x03D6F4B0 1 > $DCC_PATH/config
    echo 0x03D6F4B4 1 > $DCC_PATH/config
    echo 0x03D6F4B8 1 > $DCC_PATH/config
    echo 0x03D6F4BC 1 > $DCC_PATH/config
    echo 0x03D6F4C0 1 > $DCC_PATH/config
    echo 0x03D6F4C4 1 > $DCC_PATH/config
    echo 0x03D6F4C8 1 > $DCC_PATH/config
    echo 0x03D6F4CC 1 > $DCC_PATH/config
    echo 0x03D6F4D0 1 > $DCC_PATH/config
    echo 0x03D6F4D4 1 > $DCC_PATH/config
    echo 0x03D6F4D8 1 > $DCC_PATH/config
    echo 0x03D6F4DC 1 > $DCC_PATH/config
    echo 0x03D6F4E0 1 > $DCC_PATH/config
    echo 0x03D6F4E4 1 > $DCC_PATH/config
    echo 0x03D6F4E8 1 > $DCC_PATH/config
    echo 0x03D6F4EC 1 > $DCC_PATH/config
    echo 0x03D6F4F0 1 > $DCC_PATH/config
    echo 0x03D6F4F4 1 > $DCC_PATH/config
    echo 0x03D6F4F8 1 > $DCC_PATH/config
    echo 0x03D6F4FC 1 > $DCC_PATH/config
    echo 0x03D6F500 1 > $DCC_PATH/config
    echo 0x03D6F504 1 > $DCC_PATH/config
    echo 0x03D6F508 1 > $DCC_PATH/config
    echo 0x03D6F50C 1 > $DCC_PATH/config
    echo 0x03D6F510 1 > $DCC_PATH/config
    echo 0x03D6F514 1 > $DCC_PATH/config
    echo 0x03D6F518 1 > $DCC_PATH/config
    echo 0x03D6F51C 1 > $DCC_PATH/config
    echo 0x03D6F520 1 > $DCC_PATH/config
    echo 0x03D6F524 1 > $DCC_PATH/config
    echo 0x03D6F528 1 > $DCC_PATH/config
    echo 0x03D6F52C 1 > $DCC_PATH/config
    echo 0x03D6F530 1 > $DCC_PATH/config
    echo 0x03D6F534 1 > $DCC_PATH/config
    echo 0x03D6F538 1 > $DCC_PATH/config
    echo 0x03D6F53C 1 > $DCC_PATH/config
    echo 0x03D6F540 1 > $DCC_PATH/config
    echo 0x03D6F544 1 > $DCC_PATH/config
    echo 0x03D6F548 1 > $DCC_PATH/config
    echo 0x03D6F54C 1 > $DCC_PATH/config
    echo 0x03D6F550 1 > $DCC_PATH/config
    echo 0x03D6F554 1 > $DCC_PATH/config
    echo 0x03D6F558 1 > $DCC_PATH/config
    echo 0x03D6F55C 1 > $DCC_PATH/config
    echo 0x03D6F560 1 > $DCC_PATH/config
    echo 0x03D6F564 1 > $DCC_PATH/config
    echo 0x03D6F568 1 > $DCC_PATH/config
    echo 0x03D6F56C 1 > $DCC_PATH/config
    echo 0x03D6F570 1 > $DCC_PATH/config
    echo 0x03D6F574 1 > $DCC_PATH/config
    echo 0x03D6F578 1 > $DCC_PATH/config
    echo 0x03D6F57C 1 > $DCC_PATH/config
    echo 0x03D6F580 1 > $DCC_PATH/config
    echo 0x03D6F584 1 > $DCC_PATH/config
    echo 0x03D6F588 1 > $DCC_PATH/config
    echo 0x03D6F58C 1 > $DCC_PATH/config
    echo 0x03D6F590 1 > $DCC_PATH/config
    echo 0x03D6F594 1 > $DCC_PATH/config
    echo 0x03D6F598 1 > $DCC_PATH/config
    echo 0x03D6F59C 1 > $DCC_PATH/config
    echo 0x03D6F5A0 1 > $DCC_PATH/config
    echo 0x03D6F5A4 1 > $DCC_PATH/config
    echo 0x03D6F5A8 1 > $DCC_PATH/config
    echo 0x03D6F5AC 1 > $DCC_PATH/config
    echo 0x03D6F5B0 1 > $DCC_PATH/config
    echo 0x03D6F5B4 1 > $DCC_PATH/config
    echo 0x03D6F5B8 1 > $DCC_PATH/config
    echo 0x03D6F5BC 1 > $DCC_PATH/config
    echo 0x03D6F5C0 1 > $DCC_PATH/config
    echo 0x03D6F5C4 1 > $DCC_PATH/config
    echo 0x03D6F5C8 1 > $DCC_PATH/config
    echo 0x03D6F5CC 1 > $DCC_PATH/config
    echo 0x03D6F5D0 1 > $DCC_PATH/config
    echo 0x03D6F5D4 1 > $DCC_PATH/config
    echo 0x03D6F5D8 1 > $DCC_PATH/config
    echo 0x03D6F5DC 1 > $DCC_PATH/config
    echo 0x03D6F5E0 1 > $DCC_PATH/config
    echo 0x03D6F5E4 1 > $DCC_PATH/config
    echo 0x03D6F5E8 1 > $DCC_PATH/config
    echo 0x03D6F5EC 1 > $DCC_PATH/config
    echo 0x03D6F5F0 1 > $DCC_PATH/config
    echo 0x03D6F5F4 1 > $DCC_PATH/config
    echo 0x03D6F5F8 1 > $DCC_PATH/config
    echo 0x03D6F5FC 1 > $DCC_PATH/config
    echo 0x03D6F600 1 > $DCC_PATH/config
    echo 0x03D6F604 1 > $DCC_PATH/config
    echo 0x03D6F608 1 > $DCC_PATH/config
    echo 0x03D6F60C 1 > $DCC_PATH/config
    echo 0x03D6F610 1 > $DCC_PATH/config
    echo 0x03D6F614 1 > $DCC_PATH/config
    echo 0x03D6F618 1 > $DCC_PATH/config
    echo 0x03D6F61C 1 > $DCC_PATH/config
    echo 0x03D6F620 1 > $DCC_PATH/config
    echo 0x03D6F624 1 > $DCC_PATH/config
    echo 0x03D6F628 1 > $DCC_PATH/config
    echo 0x03D6F62C 1 > $DCC_PATH/config
    echo 0x03D6F630 1 > $DCC_PATH/config
    echo 0x03D6F634 1 > $DCC_PATH/config
    echo 0x03D6F638 1 > $DCC_PATH/config
    echo 0x03D6F63C 1 > $DCC_PATH/config
    echo 0x03D6F640 1 > $DCC_PATH/config
    echo 0x03D6F644 1 > $DCC_PATH/config
    echo 0x03D6F648 1 > $DCC_PATH/config
    echo 0x03D6F64C 1 > $DCC_PATH/config
    echo 0x03D6F650 1 > $DCC_PATH/config
    echo 0x03D6F654 1 > $DCC_PATH/config
    echo 0x03D6F658 1 > $DCC_PATH/config
    echo 0x03D6F65C 1 > $DCC_PATH/config
    echo 0x03D6F660 1 > $DCC_PATH/config
    echo 0x03D6F664 1 > $DCC_PATH/config
    echo 0x03D6F668 1 > $DCC_PATH/config
    echo 0x03D6F66C 1 > $DCC_PATH/config
    echo 0x03D6F670 1 > $DCC_PATH/config
    echo 0x03D6F674 1 > $DCC_PATH/config
    echo 0x03D6F678 1 > $DCC_PATH/config
    echo 0x03D6F67C 1 > $DCC_PATH/config
    echo 0x03D6F680 1 > $DCC_PATH/config
    echo 0x03D6F684 1 > $DCC_PATH/config
    echo 0x03D6F688 1 > $DCC_PATH/config
    echo 0x03D6F68C 1 > $DCC_PATH/config
    echo 0x03D6F690 1 > $DCC_PATH/config
    echo 0x03D6F694 1 > $DCC_PATH/config
    echo 0x03D6F698 1 > $DCC_PATH/config
    echo 0x03D6F69C 1 > $DCC_PATH/config
    echo 0x03D6F6A0 1 > $DCC_PATH/config
    echo 0x03D6F6A4 1 > $DCC_PATH/config
    echo 0x03D6F6A8 1 > $DCC_PATH/config
    echo 0x03D6F6AC 1 > $DCC_PATH/config
    echo 0x03D6F6B0 1 > $DCC_PATH/config
    echo 0x03D6F6B4 1 > $DCC_PATH/config
    echo 0x03D6F6B8 1 > $DCC_PATH/config
    echo 0x03D6F6BC 1 > $DCC_PATH/config
    echo 0x03D6F6C0 1 > $DCC_PATH/config
    echo 0x03D6F6C4 1 > $DCC_PATH/config
    echo 0x03D6F6C8 1 > $DCC_PATH/config
    echo 0x03D6F6CC 1 > $DCC_PATH/config
    echo 0x03D6F6D0 1 > $DCC_PATH/config
    echo 0x03D6F6D4 1 > $DCC_PATH/config
    echo 0x03D6F6D8 1 > $DCC_PATH/config
    echo 0x03D6F6DC 1 > $DCC_PATH/config
    echo 0x03D6F6E0 1 > $DCC_PATH/config
    echo 0x03D6F6E4 1 > $DCC_PATH/config
    echo 0x03D6F6E8 1 > $DCC_PATH/config
    echo 0x03D6F6EC 1 > $DCC_PATH/config
    echo 0x03D6F6F0 1 > $DCC_PATH/config
    echo 0x03D6F6F4 1 > $DCC_PATH/config
    echo 0x03D6F6F8 1 > $DCC_PATH/config
    echo 0x03D6F6FC 1 > $DCC_PATH/config
    echo 0x03D6F700 1 > $DCC_PATH/config
    echo 0x03D6F704 1 > $DCC_PATH/config
    echo 0x03D6F708 1 > $DCC_PATH/config
    echo 0x03D6F70C 1 > $DCC_PATH/config
    echo 0x03D6F710 1 > $DCC_PATH/config
    echo 0x03D6F714 1 > $DCC_PATH/config
    echo 0x03D6F718 1 > $DCC_PATH/config
    echo 0x03D6F71C 1 > $DCC_PATH/config
    echo 0x03D6F720 1 > $DCC_PATH/config
    echo 0x03D6F724 1 > $DCC_PATH/config
    echo 0x03D6F728 1 > $DCC_PATH/config
    echo 0x03D6F72C 1 > $DCC_PATH/config
    echo 0x03D6F730 1 > $DCC_PATH/config
    echo 0x03D6F734 1 > $DCC_PATH/config
    echo 0x03D6F738 1 > $DCC_PATH/config
    echo 0x03D6F73C 1 > $DCC_PATH/config
    echo 0x03D6F740 1 > $DCC_PATH/config
    echo 0x03D6F744 1 > $DCC_PATH/config
    echo 0x03D6F748 1 > $DCC_PATH/config
    echo 0x03D6F74C 1 > $DCC_PATH/config
    echo 0x03D6F750 1 > $DCC_PATH/config
    echo 0x03D6F754 1 > $DCC_PATH/config
    echo 0x03D6F758 1 > $DCC_PATH/config
    echo 0x03D6F75C 1 > $DCC_PATH/config
    echo 0x03D6F760 1 > $DCC_PATH/config
    echo 0x03D6F764 1 > $DCC_PATH/config
    echo 0x03D6F768 1 > $DCC_PATH/config
    echo 0x03D6F76C 1 > $DCC_PATH/config
    echo 0x03D6F770 1 > $DCC_PATH/config
    echo 0x03D6F774 1 > $DCC_PATH/config
    echo 0x03D6F778 1 > $DCC_PATH/config
    echo 0x03D6F77C 1 > $DCC_PATH/config
    echo 0x03D6F780 1 > $DCC_PATH/config
    echo 0x03D6F784 1 > $DCC_PATH/config
    echo 0x03D6F788 1 > $DCC_PATH/config
    echo 0x03D6F78C 1 > $DCC_PATH/config
    echo 0x03D6F790 1 > $DCC_PATH/config
    echo 0x03D6F794 1 > $DCC_PATH/config
    echo 0x03D6F798 1 > $DCC_PATH/config
    echo 0x03D6F79C 1 > $DCC_PATH/config
    echo 0x03D6F7A0 1 > $DCC_PATH/config
    echo 0x03D6F7A4 1 > $DCC_PATH/config
    echo 0x03D6F7A8 1 > $DCC_PATH/config
    echo 0x03D6F7AC 1 > $DCC_PATH/config
    echo 0x03D6F7B0 1 > $DCC_PATH/config
    echo 0x03D6F7B4 1 > $DCC_PATH/config
    echo 0x03D6F7B8 1 > $DCC_PATH/config
    echo 0x03D6F7BC 1 > $DCC_PATH/config
    echo 0x03D6F7C0 1 > $DCC_PATH/config
    echo 0x03D6F7C4 1 > $DCC_PATH/config
    echo 0x03D6F7C8 1 > $DCC_PATH/config
    echo 0x03D6F7CC 1 > $DCC_PATH/config
    echo 0x03D6F7D0 1 > $DCC_PATH/config
    echo 0x03D6F7D4 1 > $DCC_PATH/config
    echo 0x03D6F7D8 1 > $DCC_PATH/config
    echo 0x03D6F7DC 1 > $DCC_PATH/config
    echo 0x03D6F7E0 1 > $DCC_PATH/config
    echo 0x03D6F7E4 1 > $DCC_PATH/config
    echo 0x03D6F7E8 1 > $DCC_PATH/config
    echo 0x03D6F7EC 1 > $DCC_PATH/config
    echo 0x03D6F7F0 1 > $DCC_PATH/config
    echo 0x03D6F7F4 1 > $DCC_PATH/config
    echo 0x03D6F7F8 1 > $DCC_PATH/config
    echo 0x03D6F7FC 1 > $DCC_PATH/config
    echo 0x03D6F800 1 > $DCC_PATH/config
    echo 0x03D6F804 1 > $DCC_PATH/config
    echo 0x03D6F808 1 > $DCC_PATH/config
    echo 0x03D6F80C 1 > $DCC_PATH/config
    echo 0x03D6F810 1 > $DCC_PATH/config
    echo 0x03D6F814 1 > $DCC_PATH/config
    echo 0x03D6F818 1 > $DCC_PATH/config
    echo 0x03D6F81C 1 > $DCC_PATH/config
    echo 0x03D6F820 1 > $DCC_PATH/config
    echo 0x03D6F824 1 > $DCC_PATH/config
    echo 0x03D6F828 1 > $DCC_PATH/config
    echo 0x03D6F82C 1 > $DCC_PATH/config
    echo 0x03D6F830 1 > $DCC_PATH/config
    echo 0x03D6F834 1 > $DCC_PATH/config
    echo 0x03D6F838 1 > $DCC_PATH/config
    echo 0x03D6F83C 1 > $DCC_PATH/config
    echo 0x03D6F840 1 > $DCC_PATH/config
    echo 0x03D6F844 1 > $DCC_PATH/config
    echo 0x03D6F848 1 > $DCC_PATH/config
    echo 0x03D6F84C 1 > $DCC_PATH/config
    echo 0x03D6F850 1 > $DCC_PATH/config
    echo 0x03D6F854 1 > $DCC_PATH/config
    echo 0x03D6F858 1 > $DCC_PATH/config
    echo 0x03D6F85C 1 > $DCC_PATH/config
    echo 0x03D6F860 1 > $DCC_PATH/config
    echo 0x03D6F864 1 > $DCC_PATH/config
    echo 0x03D6F868 1 > $DCC_PATH/config
    echo 0x03D6F86C 1 > $DCC_PATH/config
    echo 0x03D6F870 1 > $DCC_PATH/config
    echo 0x03D6F874 1 > $DCC_PATH/config
    echo 0x03D6F878 1 > $DCC_PATH/config
    echo 0x03D6F87C 1 > $DCC_PATH/config
    echo 0x03D6F880 1 > $DCC_PATH/config
    echo 0x03D6F884 1 > $DCC_PATH/config
    echo 0x03D6F888 1 > $DCC_PATH/config
    echo 0x03D6F88C 1 > $DCC_PATH/config
    echo 0x03D6F890 1 > $DCC_PATH/config
    echo 0x03D6F894 1 > $DCC_PATH/config
    echo 0x03D6F898 1 > $DCC_PATH/config
    echo 0x03D6F89C 1 > $DCC_PATH/config
    echo 0x03D6F8A0 1 > $DCC_PATH/config
    echo 0x03D6F8A4 1 > $DCC_PATH/config
    echo 0x03D6F8A8 1 > $DCC_PATH/config
    echo 0x03D6F8AC 1 > $DCC_PATH/config
    echo 0x03D6F8B0 1 > $DCC_PATH/config
    echo 0x03D6F8B4 1 > $DCC_PATH/config
    echo 0x03D6F8B8 1 > $DCC_PATH/config
    echo 0x03D6F8BC 1 > $DCC_PATH/config
    echo 0x03D6F8C0 1 > $DCC_PATH/config
    echo 0x03D6F8C4 1 > $DCC_PATH/config
    echo 0x03D6F8C8 1 > $DCC_PATH/config
    echo 0x03D6F8CC 1 > $DCC_PATH/config
    echo 0x03D6F8D0 1 > $DCC_PATH/config
    echo 0x03D6F8D4 1 > $DCC_PATH/config
    echo 0x03D6F8D8 1 > $DCC_PATH/config
    echo 0x03D6F8DC 1 > $DCC_PATH/config
    echo 0x03D6F8E0 1 > $DCC_PATH/config
    echo 0x03D6F8E4 1 > $DCC_PATH/config
    echo 0x03D6F8E8 1 > $DCC_PATH/config
    echo 0x03D6F8EC 1 > $DCC_PATH/config
    echo 0x03D6F8F0 1 > $DCC_PATH/config
    echo 0x03D6F8F4 1 > $DCC_PATH/config
    echo 0x03D6F8F8 1 > $DCC_PATH/config
    echo 0x03D6F8FC 1 > $DCC_PATH/config
    echo 0x03D6F900 1 > $DCC_PATH/config
    echo 0x03D6F904 1 > $DCC_PATH/config
    echo 0x03D6F908 1 > $DCC_PATH/config
    echo 0x03D6F90C 1 > $DCC_PATH/config
    echo 0x03D6F910 1 > $DCC_PATH/config
    echo 0x03D6F914 1 > $DCC_PATH/config
    echo 0x03D6F918 1 > $DCC_PATH/config
    echo 0x03D6F91C 1 > $DCC_PATH/config
    echo 0x03D6F920 1 > $DCC_PATH/config
    echo 0x03D6F924 1 > $DCC_PATH/config
    echo 0x03D6F928 1 > $DCC_PATH/config
    echo 0x03D6F92C 1 > $DCC_PATH/config
    echo 0x03D6F930 1 > $DCC_PATH/config
    echo 0x03D6F934 1 > $DCC_PATH/config
    echo 0x03D6F938 1 > $DCC_PATH/config
    echo 0x03D6F93C 1 > $DCC_PATH/config
    echo 0x03D6F940 1 > $DCC_PATH/config
    echo 0x03D6F944 1 > $DCC_PATH/config
    echo 0x03D6F948 1 > $DCC_PATH/config
    echo 0x03D6F94C 1 > $DCC_PATH/config
    echo 0x03D6F950 1 > $DCC_PATH/config
    echo 0x03D6F954 1 > $DCC_PATH/config
    echo 0x03D6F958 1 > $DCC_PATH/config
    echo 0x03D6F95C 1 > $DCC_PATH/config
    echo 0x03D6F960 1 > $DCC_PATH/config
    echo 0x03D6F964 1 > $DCC_PATH/config
    echo 0x03D6F968 1 > $DCC_PATH/config
    echo 0x03D6F96C 1 > $DCC_PATH/config
    echo 0x03D6F970 1 > $DCC_PATH/config
    echo 0x03D6F974 1 > $DCC_PATH/config
    echo 0x03D6F978 1 > $DCC_PATH/config
    echo 0x03D6F97C 1 > $DCC_PATH/config
    echo 0x03D6F980 1 > $DCC_PATH/config
    echo 0x03D6F984 1 > $DCC_PATH/config
    echo 0x03D6F988 1 > $DCC_PATH/config
    echo 0x03D6F98C 1 > $DCC_PATH/config
    echo 0x03D6F990 1 > $DCC_PATH/config
    echo 0x03D6F994 1 > $DCC_PATH/config
    echo 0x03D6F998 1 > $DCC_PATH/config
    echo 0x03D6F99C 1 > $DCC_PATH/config
    echo 0x03D6F9A0 1 > $DCC_PATH/config
    echo 0x03D6F9A4 1 > $DCC_PATH/config
    echo 0x03D6F9A8 1 > $DCC_PATH/config
    echo 0x03D6F9AC 1 > $DCC_PATH/config
    echo 0x03D6F9B0 1 > $DCC_PATH/config
    echo 0x03D6F9B4 1 > $DCC_PATH/config
    echo 0x03D6F9B8 1 > $DCC_PATH/config
    echo 0x03D6F9BC 1 > $DCC_PATH/config
    echo 0x03D6F9C0 1 > $DCC_PATH/config
    echo 0x03D6F9C4 1 > $DCC_PATH/config
    echo 0x03D6F9C8 1 > $DCC_PATH/config
    echo 0x03D6F9CC 1 > $DCC_PATH/config
    echo 0x03D6F9D0 1 > $DCC_PATH/config
    echo 0x03D6F9D4 1 > $DCC_PATH/config
    echo 0x03D6F9D8 1 > $DCC_PATH/config
    echo 0x03D6F9DC 1 > $DCC_PATH/config
    echo 0x03D6F9E0 1 > $DCC_PATH/config
    echo 0x03D6F9E4 1 > $DCC_PATH/config
    echo 0x03D6F9E8 1 > $DCC_PATH/config
    echo 0x03D6F9EC 1 > $DCC_PATH/config
    echo 0x03D6F9F0 1 > $DCC_PATH/config
    echo 0x03D6F9F4 1 > $DCC_PATH/config
    echo 0x03D6F9F8 1 > $DCC_PATH/config
    echo 0x03D6F9FC 1 > $DCC_PATH/config
    echo 0x03D6FA00 1 > $DCC_PATH/config
    echo 0x03D6FA04 1 > $DCC_PATH/config
    echo 0x03D6FA08 1 > $DCC_PATH/config
    echo 0x03D6FA0C 1 > $DCC_PATH/config
    echo 0x03D6FA10 1 > $DCC_PATH/config
    echo 0x03D6FA14 1 > $DCC_PATH/config
    echo 0x03D6FA18 1 > $DCC_PATH/config
    echo 0x03D6FA1C 1 > $DCC_PATH/config
    echo 0x03D6FA20 1 > $DCC_PATH/config
    echo 0x03D6FA24 1 > $DCC_PATH/config
    echo 0x03D6FA28 1 > $DCC_PATH/config
    echo 0x03D6FA2C 1 > $DCC_PATH/config
    echo 0x03D6FA30 1 > $DCC_PATH/config
    echo 0x03D6FA34 1 > $DCC_PATH/config
    echo 0x03D6FA38 1 > $DCC_PATH/config
    echo 0x03D6FA3C 1 > $DCC_PATH/config
    echo 0x03D6FA40 1 > $DCC_PATH/config
    echo 0x03D6FA44 1 > $DCC_PATH/config
    echo 0x03D6FA48 1 > $DCC_PATH/config
    echo 0x03D6FA4C 1 > $DCC_PATH/config
    echo 0x03D6FA50 1 > $DCC_PATH/config
    echo 0x03D6FA54 1 > $DCC_PATH/config
    echo 0x03D6FA58 1 > $DCC_PATH/config
    echo 0x03D6FA5C 1 > $DCC_PATH/config
    echo 0x03D6FA60 1 > $DCC_PATH/config
    echo 0x03D6FA64 1 > $DCC_PATH/config
    echo 0x03D6FA68 1 > $DCC_PATH/config
    echo 0x03D6FA6C 1 > $DCC_PATH/config
    echo 0x03D6FA70 1 > $DCC_PATH/config
    echo 0x03D6FA74 1 > $DCC_PATH/config
    echo 0x03D6FA78 1 > $DCC_PATH/config
    echo 0x03D6FA7C 1 > $DCC_PATH/config
    echo 0x03D6FA80 1 > $DCC_PATH/config
    echo 0x03D6FA84 1 > $DCC_PATH/config
    echo 0x03D6FA88 1 > $DCC_PATH/config
    echo 0x03D6FA8C 1 > $DCC_PATH/config
    echo 0x03D6FA90 1 > $DCC_PATH/config
    echo 0x03D6FA94 1 > $DCC_PATH/config
    echo 0x03D6FA98 1 > $DCC_PATH/config
    echo 0x03D6FA9C 1 > $DCC_PATH/config
    echo 0x03D6FAA0 1 > $DCC_PATH/config
    echo 0x03D6FAA4 1 > $DCC_PATH/config
    echo 0x03D6FAA8 1 > $DCC_PATH/config
    echo 0x03D6FAAC 1 > $DCC_PATH/config
    echo 0x03D6FAB0 1 > $DCC_PATH/config
    echo 0x03D6FAB4 1 > $DCC_PATH/config
    echo 0x03D6FAB8 1 > $DCC_PATH/config
    echo 0x03D6FABC 1 > $DCC_PATH/config
    echo 0x03D6FAC0 1 > $DCC_PATH/config
    echo 0x03D6FAC4 1 > $DCC_PATH/config
    echo 0x03D6FAC8 1 > $DCC_PATH/config
    echo 0x03D6FACC 1 > $DCC_PATH/config
    echo 0x03D6FAD0 1 > $DCC_PATH/config
    echo 0x03D6FAD4 1 > $DCC_PATH/config
    echo 0x03D6FAD8 1 > $DCC_PATH/config
    echo 0x03D6FADC 1 > $DCC_PATH/config
    echo 0x03D6FAE0 1 > $DCC_PATH/config
    echo 0x03D6FAE4 1 > $DCC_PATH/config
    echo 0x03D6FAE8 1 > $DCC_PATH/config
    echo 0x03D6FAEC 1 > $DCC_PATH/config
    echo 0x03D6FAF0 1 > $DCC_PATH/config
    echo 0x03D6FAF4 1 > $DCC_PATH/config
    echo 0x03D6FAF8 1 > $DCC_PATH/config
    echo 0x03D6FAFC 1 > $DCC_PATH/config
    echo 0x03D6FB00 1 > $DCC_PATH/config
    echo 0x03D6FB04 1 > $DCC_PATH/config
    echo 0x03D6FB08 1 > $DCC_PATH/config
    echo 0x03D6FB0C 1 > $DCC_PATH/config
    echo 0x03D6FB10 1 > $DCC_PATH/config
    echo 0x03D6FB14 1 > $DCC_PATH/config
    echo 0x03D6FB18 1 > $DCC_PATH/config
    echo 0x03D6FB1C 1 > $DCC_PATH/config
    echo 0x03D6FB20 1 > $DCC_PATH/config
    echo 0x03D6FB24 1 > $DCC_PATH/config
    echo 0x03D6FB28 1 > $DCC_PATH/config
    echo 0x03D6FB2C 1 > $DCC_PATH/config
    echo 0x03D6FB30 1 > $DCC_PATH/config
    echo 0x03D6FB34 1 > $DCC_PATH/config
    echo 0x03D6FB38 1 > $DCC_PATH/config
    echo 0x03D6FB3C 1 > $DCC_PATH/config
    echo 0x03D6FB40 1 > $DCC_PATH/config
    echo 0x03D6FB44 1 > $DCC_PATH/config
    echo 0x03D6FB48 1 > $DCC_PATH/config
    echo 0x03D6FB4C 1 > $DCC_PATH/config
    echo 0x03D6FB50 1 > $DCC_PATH/config
    echo 0x03D6FB54 1 > $DCC_PATH/config
    echo 0x03D6FB58 1 > $DCC_PATH/config
    echo 0x03D6FB5C 1 > $DCC_PATH/config
    echo 0x03D6FB60 1 > $DCC_PATH/config
    echo 0x03D6FB64 1 > $DCC_PATH/config
    echo 0x03D6FB68 1 > $DCC_PATH/config
    echo 0x03D6FB6C 1 > $DCC_PATH/config
    echo 0x03D6FB70 1 > $DCC_PATH/config
    echo 0x03D6FB74 1 > $DCC_PATH/config
    echo 0x03D6FB78 1 > $DCC_PATH/config
    echo 0x03D6FB7C 1 > $DCC_PATH/config
    echo 0x03D6FB80 1 > $DCC_PATH/config
    echo 0x03D6FB84 1 > $DCC_PATH/config
    echo 0x03D6FB88 1 > $DCC_PATH/config
    echo 0x03D6FB8C 1 > $DCC_PATH/config
    echo 0x03D6FB90 1 > $DCC_PATH/config
    echo 0x03D6FB94 1 > $DCC_PATH/config
    echo 0x03D6FB98 1 > $DCC_PATH/config
    echo 0x03D6FB9C 1 > $DCC_PATH/config
    echo 0x03D6FBA0 1 > $DCC_PATH/config
    echo 0x03D6FBA4 1 > $DCC_PATH/config
    echo 0x03D6FBA8 1 > $DCC_PATH/config
    echo 0x03D6FBAC 1 > $DCC_PATH/config
    echo 0x03D6FBB0 1 > $DCC_PATH/config
    echo 0x03D6FBB4 1 > $DCC_PATH/config
    echo 0x03D6FBB8 1 > $DCC_PATH/config
    echo 0x03D6FBBC 1 > $DCC_PATH/config
    echo 0x03D6FBC0 1 > $DCC_PATH/config
    echo 0x03D6FBC4 1 > $DCC_PATH/config
    echo 0x03D6FBC8 1 > $DCC_PATH/config
    echo 0x03D6FBCC 1 > $DCC_PATH/config
    echo 0x03D6FBD0 1 > $DCC_PATH/config
    echo 0x03D6FBD4 1 > $DCC_PATH/config
    echo 0x03D6FBD8 1 > $DCC_PATH/config
    echo 0x03D6FBDC 1 > $DCC_PATH/config
    echo 0x03D6FBE0 1 > $DCC_PATH/config
    echo 0x03D6FBE4 1 > $DCC_PATH/config
    echo 0x03D6FBE8 1 > $DCC_PATH/config
    echo 0x03D6FBEC 1 > $DCC_PATH/config
    echo 0x03D6FBF0 1 > $DCC_PATH/config
    echo 0x03D6FBF4 1 > $DCC_PATH/config
    echo 0x03D6FBF8 1 > $DCC_PATH/config
    echo 0x03D6FBFC 1 > $DCC_PATH/config
    echo 0x03D6FC00 1 > $DCC_PATH/config
    echo 0x03D6FC04 1 > $DCC_PATH/config
    echo 0x03D6FC08 1 > $DCC_PATH/config
    echo 0x03D6FC0C 1 > $DCC_PATH/config
    echo 0x03D6FC10 1 > $DCC_PATH/config
    echo 0x03D6FC14 1 > $DCC_PATH/config
    echo 0x03D6FC18 1 > $DCC_PATH/config
    echo 0x03D6FC1C 1 > $DCC_PATH/config
    echo 0x03D6FC20 1 > $DCC_PATH/config
    echo 0x03D6FC24 1 > $DCC_PATH/config
    echo 0x03D6FC28 1 > $DCC_PATH/config
    echo 0x03D6FC2C 1 > $DCC_PATH/config
    echo 0x03D6FC30 1 > $DCC_PATH/config
    echo 0x03D6FC34 1 > $DCC_PATH/config
    echo 0x03D6FC38 1 > $DCC_PATH/config
    echo 0x03D6FC3C 1 > $DCC_PATH/config
    echo 0x03D6FC40 1 > $DCC_PATH/config
    echo 0x03D6FC44 1 > $DCC_PATH/config
    echo 0x03D6FC48 1 > $DCC_PATH/config
    echo 0x03D6FC4C 1 > $DCC_PATH/config
    echo 0x03D6FC50 1 > $DCC_PATH/config
    echo 0x03D6FC54 1 > $DCC_PATH/config
    echo 0x03D6FC58 1 > $DCC_PATH/config
    echo 0x03D6FC5C 1 > $DCC_PATH/config
    echo 0x03D6FC60 1 > $DCC_PATH/config
    echo 0x03D6FC64 1 > $DCC_PATH/config
    echo 0x03D6FC68 1 > $DCC_PATH/config
    echo 0x03D6FC6C 1 > $DCC_PATH/config
    echo 0x03D6FC70 1 > $DCC_PATH/config
    echo 0x03D6FC74 1 > $DCC_PATH/config
    echo 0x03D6FC78 1 > $DCC_PATH/config
    echo 0x03D6FC7C 1 > $DCC_PATH/config
    echo 0x03D6FC80 1 > $DCC_PATH/config
    echo 0x03D6FC84 1 > $DCC_PATH/config
    echo 0x03D6FC88 1 > $DCC_PATH/config
    echo 0x03D6FC8C 1 > $DCC_PATH/config
    echo 0x03D6FC90 1 > $DCC_PATH/config
    echo 0x03D6FC94 1 > $DCC_PATH/config
    echo 0x03D6FC98 1 > $DCC_PATH/config
    echo 0x03D6FC9C 1 > $DCC_PATH/config
    echo 0x03D6FCA0 1 > $DCC_PATH/config
    echo 0x03D6FCA4 1 > $DCC_PATH/config
    echo 0x03D6FCA8 1 > $DCC_PATH/config
    echo 0x03D6FCAC 1 > $DCC_PATH/config
    echo 0x03D6FCB0 1 > $DCC_PATH/config
    echo 0x03D6FCB4 1 > $DCC_PATH/config
    echo 0x03D6FCB8 1 > $DCC_PATH/config
    echo 0x03D6FCBC 1 > $DCC_PATH/config
    echo 0x03D6FCC0 1 > $DCC_PATH/config
    echo 0x03D6FCC4 1 > $DCC_PATH/config
    echo 0x03D6FCC8 1 > $DCC_PATH/config
    echo 0x03D6FCCC 1 > $DCC_PATH/config
    echo 0x03D6FCD0 1 > $DCC_PATH/config
    echo 0x03D6FCD4 1 > $DCC_PATH/config
    echo 0x03D6FCD8 1 > $DCC_PATH/config
    echo 0x03D6FCDC 1 > $DCC_PATH/config
    echo 0x03D6FCE0 1 > $DCC_PATH/config
    echo 0x03D6FCE4 1 > $DCC_PATH/config
    echo 0x03D6FCE8 1 > $DCC_PATH/config
    echo 0x03D6FCEC 1 > $DCC_PATH/config
    echo 0x03D6FCF0 1 > $DCC_PATH/config
    echo 0x03D6FCF4 1 > $DCC_PATH/config
    echo 0x03D6FCF8 1 > $DCC_PATH/config
    echo 0x03D6FCFC 1 > $DCC_PATH/config
    echo 0x03D6FD00 1 > $DCC_PATH/config
    echo 0x03D6FD04 1 > $DCC_PATH/config
    echo 0x03D6FD08 1 > $DCC_PATH/config
    echo 0x03D6FD0C 1 > $DCC_PATH/config
    echo 0x03D6FD10 1 > $DCC_PATH/config
    echo 0x03D6FD14 1 > $DCC_PATH/config
    echo 0x03D6FD18 1 > $DCC_PATH/config
    echo 0x03D6FD1C 1 > $DCC_PATH/config
    echo 0x03D6FD20 1 > $DCC_PATH/config
    echo 0x03D6FD24 1 > $DCC_PATH/config
    echo 0x03D6FD28 1 > $DCC_PATH/config
    echo 0x03D6FD2C 1 > $DCC_PATH/config
    echo 0x03D6FD30 1 > $DCC_PATH/config
    echo 0x03D6FD34 1 > $DCC_PATH/config
    echo 0x03D6FD38 1 > $DCC_PATH/config
    echo 0x03D6FD3C 1 > $DCC_PATH/config
    echo 0x03D6FD40 1 > $DCC_PATH/config
    echo 0x03D6FD44 1 > $DCC_PATH/config
    echo 0x03D6FD48 1 > $DCC_PATH/config
    echo 0x03D6FD4C 1 > $DCC_PATH/config
    echo 0x03D6FD50 1 > $DCC_PATH/config
    echo 0x03D6FD54 1 > $DCC_PATH/config
    echo 0x03D6FD58 1 > $DCC_PATH/config
    echo 0x03D6FD5C 1 > $DCC_PATH/config
    echo 0x03D6FD60 1 > $DCC_PATH/config
    echo 0x03D6FD64 1 > $DCC_PATH/config
    echo 0x03D6FD68 1 > $DCC_PATH/config
    echo 0x03D6FD6C 1 > $DCC_PATH/config
    echo 0x03D6FD70 1 > $DCC_PATH/config
    echo 0x03D6FD74 1 > $DCC_PATH/config
    echo 0x03D6FD78 1 > $DCC_PATH/config
    echo 0x03D6FD7C 1 > $DCC_PATH/config
    echo 0x03D6FD80 1 > $DCC_PATH/config
    echo 0x03D6FD84 1 > $DCC_PATH/config
    echo 0x03D6FD88 1 > $DCC_PATH/config
    echo 0x03D6FD8C 1 > $DCC_PATH/config
    echo 0x03D6FD90 1 > $DCC_PATH/config
    echo 0x03D6FD94 1 > $DCC_PATH/config
    echo 0x03D6FD98 1 > $DCC_PATH/config
    echo 0x03D6FD9C 1 > $DCC_PATH/config
    echo 0x03D6FDA0 1 > $DCC_PATH/config
    echo 0x03D6FDA4 1 > $DCC_PATH/config
    echo 0x03D6FDA8 1 > $DCC_PATH/config
    echo 0x03D6FDAC 1 > $DCC_PATH/config
    echo 0x03D6FDB0 1 > $DCC_PATH/config
    echo 0x03D6FDB4 1 > $DCC_PATH/config
    echo 0x03D6FDB8 1 > $DCC_PATH/config
    echo 0x03D6FDBC 1 > $DCC_PATH/config
    echo 0x03D6FDC0 1 > $DCC_PATH/config
    echo 0x03D6FDC4 1 > $DCC_PATH/config
    echo 0x03D6FDC8 1 > $DCC_PATH/config
    echo 0x03D6FDCC 1 > $DCC_PATH/config
    echo 0x03D6FDD0 1 > $DCC_PATH/config
    echo 0x03D6FDD4 1 > $DCC_PATH/config
    echo 0x03D6FDD8 1 > $DCC_PATH/config
    echo 0x03D6FDDC 1 > $DCC_PATH/config
    echo 0x03D6FDE0 1 > $DCC_PATH/config
    echo 0x03D6FDE4 1 > $DCC_PATH/config
    echo 0x03D6FDE8 1 > $DCC_PATH/config
    echo 0x03D6FDEC 1 > $DCC_PATH/config
    echo 0x03D6FDF0 1 > $DCC_PATH/config
    echo 0x03D6FDF4 1 > $DCC_PATH/config
    echo 0x03D6FDF8 1 > $DCC_PATH/config
    echo 0x03D6FDFC 1 > $DCC_PATH/config
    echo 0x03D6FE00 1 > $DCC_PATH/config
    echo 0x03D6FE04 1 > $DCC_PATH/config
    echo 0x03D6FE08 1 > $DCC_PATH/config
    echo 0x03D6FE0C 1 > $DCC_PATH/config
    echo 0x03D6FE10 1 > $DCC_PATH/config
    echo 0x03D6FE14 1 > $DCC_PATH/config
    echo 0x03D6FE18 1 > $DCC_PATH/config
    echo 0x03D6FE1C 1 > $DCC_PATH/config
    echo 0x03D6FE20 1 > $DCC_PATH/config
    echo 0x03D6FE24 1 > $DCC_PATH/config
    echo 0x03D6FE28 1 > $DCC_PATH/config
    echo 0x03D6FE2C 1 > $DCC_PATH/config
    echo 0x03D6FE30 1 > $DCC_PATH/config
    echo 0x03D6FE34 1 > $DCC_PATH/config
    echo 0x03D6FE38 1 > $DCC_PATH/config
    echo 0x03D6FE3C 1 > $DCC_PATH/config
    echo 0x03D6FE40 1 > $DCC_PATH/config
    echo 0x03D6FE44 1 > $DCC_PATH/config
    echo 0x03D6FE48 1 > $DCC_PATH/config
    echo 0x03D6FE4C 1 > $DCC_PATH/config
    echo 0x03D6FE50 1 > $DCC_PATH/config
    echo 0x03D6FE54 1 > $DCC_PATH/config
    echo 0x03D6FE58 1 > $DCC_PATH/config
    echo 0x03D6FE5C 1 > $DCC_PATH/config
    echo 0x03D6FE60 1 > $DCC_PATH/config
    echo 0x03D6FE64 1 > $DCC_PATH/config
    echo 0x03D6FE68 1 > $DCC_PATH/config
    echo 0x03D6FE6C 1 > $DCC_PATH/config
    echo 0x03D6FE70 1 > $DCC_PATH/config
    echo 0x03D6FE74 1 > $DCC_PATH/config
    echo 0x03D6FE78 1 > $DCC_PATH/config
    echo 0x03D6FE7C 1 > $DCC_PATH/config
    echo 0x03D6FE80 1 > $DCC_PATH/config
    echo 0x03D6FE84 1 > $DCC_PATH/config
    echo 0x03D6FE88 1 > $DCC_PATH/config
    echo 0x03D6FE8C 1 > $DCC_PATH/config
    echo 0x03D6FE90 1 > $DCC_PATH/config
    echo 0x03D6FE94 1 > $DCC_PATH/config
    echo 0x03D6FE98 1 > $DCC_PATH/config
    echo 0x03D6FE9C 1 > $DCC_PATH/config
    echo 0x03D6FEA0 1 > $DCC_PATH/config
    echo 0x03D6FEA4 1 > $DCC_PATH/config
    echo 0x03D6FEA8 1 > $DCC_PATH/config
    echo 0x03D6FEAC 1 > $DCC_PATH/config
    echo 0x03D6FEB0 1 > $DCC_PATH/config
    echo 0x03D6FEB4 1 > $DCC_PATH/config
    echo 0x03D6FEB8 1 > $DCC_PATH/config
    echo 0x03D6FEBC 1 > $DCC_PATH/config
    echo 0x03D6FEC0 1 > $DCC_PATH/config
    echo 0x03D6FEC4 1 > $DCC_PATH/config
    echo 0x03D6FEC8 1 > $DCC_PATH/config
    echo 0x03D6FECC 1 > $DCC_PATH/config
    echo 0x03D6FED0 1 > $DCC_PATH/config
    echo 0x03D6FED4 1 > $DCC_PATH/config
    echo 0x03D6FED8 1 > $DCC_PATH/config
    echo 0x03D6FEDC 1 > $DCC_PATH/config
    echo 0x03D6FEE0 1 > $DCC_PATH/config
    echo 0x03D6FEE4 1 > $DCC_PATH/config
    echo 0x03D6FEE8 1 > $DCC_PATH/config
    echo 0x03D6FEEC 1 > $DCC_PATH/config
    echo 0x03D6FEF0 1 > $DCC_PATH/config
    echo 0x03D6FEF4 1 > $DCC_PATH/config
    echo 0x03D6FEF8 1 > $DCC_PATH/config
    echo 0x03D6FEFC 1 > $DCC_PATH/config
    echo 0x03D6FF00 1 > $DCC_PATH/config
    echo 0x03D6FF04 1 > $DCC_PATH/config
    echo 0x03D6FF08 1 > $DCC_PATH/config
    echo 0x03D6FF0C 1 > $DCC_PATH/config
    echo 0x03D6FF10 1 > $DCC_PATH/config
    echo 0x03D6FF14 1 > $DCC_PATH/config
    echo 0x03D6FF18 1 > $DCC_PATH/config
    echo 0x03D6FF1C 1 > $DCC_PATH/config
    echo 0x03D6FF20 1 > $DCC_PATH/config
    echo 0x03D6FF24 1 > $DCC_PATH/config
    echo 0x03D6FF28 1 > $DCC_PATH/config
    echo 0x03D6FF2C 1 > $DCC_PATH/config
    echo 0x03D6FF30 1 > $DCC_PATH/config
    echo 0x03D6FF34 1 > $DCC_PATH/config
    echo 0x03D6FF38 1 > $DCC_PATH/config
    echo 0x03D6FF3C 1 > $DCC_PATH/config
    echo 0x03D6FF40 1 > $DCC_PATH/config
    echo 0x03D6FF44 1 > $DCC_PATH/config
    echo 0x03D6FF48 1 > $DCC_PATH/config
    echo 0x03D6FF4C 1 > $DCC_PATH/config
    echo 0x03D6FF50 1 > $DCC_PATH/config
    echo 0x03D6FF54 1 > $DCC_PATH/config
    echo 0x03D6FF58 1 > $DCC_PATH/config
    echo 0x03D6FF5C 1 > $DCC_PATH/config
    echo 0x03D6FF60 1 > $DCC_PATH/config
    echo 0x03D6FF64 1 > $DCC_PATH/config
    echo 0x03D6FF68 1 > $DCC_PATH/config
    echo 0x03D6FF6C 1 > $DCC_PATH/config
    echo 0x03D6FF70 1 > $DCC_PATH/config
    echo 0x03D6FF74 1 > $DCC_PATH/config
    echo 0x03D6FF78 1 > $DCC_PATH/config
    echo 0x03D6FF7C 1 > $DCC_PATH/config
    echo 0x03D6FF80 1 > $DCC_PATH/config
    echo 0x03D6FF84 1 > $DCC_PATH/config
    echo 0x03D6FF88 1 > $DCC_PATH/config
    echo 0x03D6FF8C 1 > $DCC_PATH/config
    echo 0x03D6FF90 1 > $DCC_PATH/config
    echo 0x03D6FF94 1 > $DCC_PATH/config
    echo 0x03D6FF98 1 > $DCC_PATH/config
    echo 0x03D6FF9C 1 > $DCC_PATH/config
    echo 0x03D6FFA0 1 > $DCC_PATH/config
    echo 0x03D6FFA4 1 > $DCC_PATH/config
    echo 0x03D6FFA8 1 > $DCC_PATH/config
    echo 0x03D6FFAC 1 > $DCC_PATH/config
    echo 0x03D6FFB0 1 > $DCC_PATH/config
    echo 0x03D6FFB4 1 > $DCC_PATH/config
    echo 0x03D6FFB8 1 > $DCC_PATH/config
    echo 0x03D6FFBC 1 > $DCC_PATH/config
    echo 0x03D6FFC0 1 > $DCC_PATH/config
    echo 0x03D6FFC4 1 > $DCC_PATH/config
    echo 0x03D6FFC8 1 > $DCC_PATH/config
    echo 0x03D6FFCC 1 > $DCC_PATH/config
    echo 0x03D6FFD0 1 > $DCC_PATH/config
    echo 0x03D6FFD4 1 > $DCC_PATH/config
    echo 0x03D6FFD8 1 > $DCC_PATH/config
    echo 0x03D6FFDC 1 > $DCC_PATH/config
    echo 0x03D6FFE0 1 > $DCC_PATH/config
    echo 0x03D6FFE4 1 > $DCC_PATH/config
    echo 0x03D6FFE8 1 > $DCC_PATH/config
    echo 0x03D6FFEC 1 > $DCC_PATH/config
    echo 0x03D6FFF0 1 > $DCC_PATH/config
    echo 0x03D6FFF4 1 > $DCC_PATH/config
    echo 0x03D6FFF8 1 > $DCC_PATH/config
    echo 0x03D6FFFC 1 > $DCC_PATH/config
    echo 0x03D70000 1 > $DCC_PATH/config
    echo 0x03D70004 1 > $DCC_PATH/config
    echo 0x03D70008 1 > $DCC_PATH/config
    echo 0x03D7000C 1 > $DCC_PATH/config
    echo 0x03D70010 1 > $DCC_PATH/config
    echo 0x03D70014 1 > $DCC_PATH/config
    echo 0x03D70018 1 > $DCC_PATH/config
    echo 0x03D7001C 1 > $DCC_PATH/config
    echo 0x03D70020 1 > $DCC_PATH/config
    echo 0x03D70024 1 > $DCC_PATH/config
    echo 0x03D70028 1 > $DCC_PATH/config
    echo 0x03D7002C 1 > $DCC_PATH/config
    echo 0x03D70030 1 > $DCC_PATH/config
    echo 0x03D70034 1 > $DCC_PATH/config
    echo 0x03D70038 1 > $DCC_PATH/config
    echo 0x03D7003C 1 > $DCC_PATH/config
    echo 0x03D70040 1 > $DCC_PATH/config
    echo 0x03D70044 1 > $DCC_PATH/config
    echo 0x03D70048 1 > $DCC_PATH/config
    echo 0x03D7004C 1 > $DCC_PATH/config
    echo 0x03D70050 1 > $DCC_PATH/config
    echo 0x03D70054 1 > $DCC_PATH/config
    echo 0x03D70058 1 > $DCC_PATH/config
    echo 0x03D7005C 1 > $DCC_PATH/config
    echo 0x03D70060 1 > $DCC_PATH/config
    echo 0x03D70064 1 > $DCC_PATH/config
    echo 0x03D70068 1 > $DCC_PATH/config
    echo 0x03D7006C 1 > $DCC_PATH/config
    echo 0x03D70070 1 > $DCC_PATH/config
    echo 0x03D70074 1 > $DCC_PATH/config
    echo 0x03D70078 1 > $DCC_PATH/config
    echo 0x03D7007C 1 > $DCC_PATH/config
    echo 0x03D70080 1 > $DCC_PATH/config
    echo 0x03D70084 1 > $DCC_PATH/config
    echo 0x03D70088 1 > $DCC_PATH/config
    echo 0x03D7008C 1 > $DCC_PATH/config
    echo 0x03D70090 1 > $DCC_PATH/config
    echo 0x03D70094 1 > $DCC_PATH/config
    echo 0x03D70098 1 > $DCC_PATH/config
    echo 0x03D7009C 1 > $DCC_PATH/config
    echo 0x03D700A0 1 > $DCC_PATH/config
    echo 0x03D700A4 1 > $DCC_PATH/config
    echo 0x03D700A8 1 > $DCC_PATH/config
    echo 0x03D700AC 1 > $DCC_PATH/config
    echo 0x03D700B0 1 > $DCC_PATH/config
    echo 0x03D700B4 1 > $DCC_PATH/config
    echo 0x03D700B8 1 > $DCC_PATH/config
    echo 0x03D700BC 1 > $DCC_PATH/config
    echo 0x03D700C0 1 > $DCC_PATH/config
    echo 0x03D700C4 1 > $DCC_PATH/config
    echo 0x03D700C8 1 > $DCC_PATH/config
    echo 0x03D700CC 1 > $DCC_PATH/config
    echo 0x03D700D0 1 > $DCC_PATH/config
    echo 0x03D700D4 1 > $DCC_PATH/config
    echo 0x03D700D8 1 > $DCC_PATH/config
    echo 0x03D700DC 1 > $DCC_PATH/config
    echo 0x03D700E0 1 > $DCC_PATH/config
    echo 0x03D700E4 1 > $DCC_PATH/config
    echo 0x03D700E8 1 > $DCC_PATH/config
    echo 0x03D700EC 1 > $DCC_PATH/config
    echo 0x03D700F0 1 > $DCC_PATH/config
    echo 0x03D700F4 1 > $DCC_PATH/config
    echo 0x03D700F8 1 > $DCC_PATH/config
    echo 0x03D700FC 1 > $DCC_PATH/config
    echo 0x03D70100 1 > $DCC_PATH/config
    echo 0x03D70104 1 > $DCC_PATH/config
    echo 0x03D70108 1 > $DCC_PATH/config
    echo 0x03D7010C 1 > $DCC_PATH/config
    echo 0x03D70110 1 > $DCC_PATH/config
    echo 0x03D70114 1 > $DCC_PATH/config
    echo 0x03D70118 1 > $DCC_PATH/config
    echo 0x03D7011C 1 > $DCC_PATH/config
    echo 0x03D70120 1 > $DCC_PATH/config
    echo 0x03D70124 1 > $DCC_PATH/config
    echo 0x03D70128 1 > $DCC_PATH/config
    echo 0x03D7012C 1 > $DCC_PATH/config
    echo 0x03D70130 1 > $DCC_PATH/config
    echo 0x03D70134 1 > $DCC_PATH/config
    echo 0x03D70138 1 > $DCC_PATH/config
    echo 0x03D7013C 1 > $DCC_PATH/config
    echo 0x03D70140 1 > $DCC_PATH/config
    echo 0x03D70144 1 > $DCC_PATH/config
    echo 0x03D70148 1 > $DCC_PATH/config
    echo 0x03D7014C 1 > $DCC_PATH/config
    echo 0x03D70150 1 > $DCC_PATH/config
    echo 0x03D70154 1 > $DCC_PATH/config
    echo 0x03D70158 1 > $DCC_PATH/config
    echo 0x03D7015C 1 > $DCC_PATH/config
    echo 0x03D70160 1 > $DCC_PATH/config
    echo 0x03D70164 1 > $DCC_PATH/config
    echo 0x03D70168 1 > $DCC_PATH/config
    echo 0x03D7016C 1 > $DCC_PATH/config
    echo 0x03D70170 1 > $DCC_PATH/config
    echo 0x03D70174 1 > $DCC_PATH/config
    echo 0x03D70178 1 > $DCC_PATH/config
    echo 0x03D7017C 1 > $DCC_PATH/config
    echo 0x03D70180 1 > $DCC_PATH/config
    echo 0x03D70184 1 > $DCC_PATH/config
    echo 0x03D70188 1 > $DCC_PATH/config
    echo 0x03D7018C 1 > $DCC_PATH/config
    echo 0x03D70190 1 > $DCC_PATH/config
    echo 0x03D70194 1 > $DCC_PATH/config
    echo 0x03D70198 1 > $DCC_PATH/config
    echo 0x03D7019C 1 > $DCC_PATH/config
    echo 0x03D701A0 1 > $DCC_PATH/config
    echo 0x03D701A4 1 > $DCC_PATH/config
    echo 0x03D701A8 1 > $DCC_PATH/config
    echo 0x03D701AC 1 > $DCC_PATH/config
    echo 0x03D701B0 1 > $DCC_PATH/config
    echo 0x03D701B4 1 > $DCC_PATH/config
    echo 0x03D701B8 1 > $DCC_PATH/config
    echo 0x03D701BC 1 > $DCC_PATH/config
    echo 0x03D701C0 1 > $DCC_PATH/config
    echo 0x03D701C4 1 > $DCC_PATH/config
    echo 0x03D701C8 1 > $DCC_PATH/config
    echo 0x03D701CC 1 > $DCC_PATH/config
    echo 0x03D701D0 1 > $DCC_PATH/config
    echo 0x03D701D4 1 > $DCC_PATH/config
    echo 0x03D701D8 1 > $DCC_PATH/config
    echo 0x03D701DC 1 > $DCC_PATH/config
    echo 0x03D701E0 1 > $DCC_PATH/config
    echo 0x03D701E4 1 > $DCC_PATH/config
    echo 0x03D701E8 1 > $DCC_PATH/config
    echo 0x03D701EC 1 > $DCC_PATH/config
    echo 0x03D701F0 1 > $DCC_PATH/config
    echo 0x03D701F4 1 > $DCC_PATH/config
    echo 0x03D701F8 1 > $DCC_PATH/config
    echo 0x03D701FC 1 > $DCC_PATH/config
    echo 0x03D70200 1 > $DCC_PATH/config
    echo 0x03D70204 1 > $DCC_PATH/config
    echo 0x03D70208 1 > $DCC_PATH/config
    echo 0x03D7020C 1 > $DCC_PATH/config
    echo 0x03D70210 1 > $DCC_PATH/config
    echo 0x03D70214 1 > $DCC_PATH/config
    echo 0x03D70218 1 > $DCC_PATH/config
    echo 0x03D7021C 1 > $DCC_PATH/config
    echo 0x03D70220 1 > $DCC_PATH/config
    echo 0x03D70224 1 > $DCC_PATH/config
    echo 0x03D70228 1 > $DCC_PATH/config
    echo 0x03D7022C 1 > $DCC_PATH/config
    echo 0x03D70230 1 > $DCC_PATH/config
    echo 0x03D70234 1 > $DCC_PATH/config
    echo 0x03D70238 1 > $DCC_PATH/config
    echo 0x03D7023C 1 > $DCC_PATH/config
    echo 0x03D70240 1 > $DCC_PATH/config
    echo 0x03D70244 1 > $DCC_PATH/config
    echo 0x03D70248 1 > $DCC_PATH/config
    echo 0x03D7024C 1 > $DCC_PATH/config
    echo 0x03D70250 1 > $DCC_PATH/config
    echo 0x03D70254 1 > $DCC_PATH/config
    echo 0x03D70258 1 > $DCC_PATH/config
    echo 0x03D7025C 1 > $DCC_PATH/config
    echo 0x03D70260 1 > $DCC_PATH/config
    echo 0x03D70264 1 > $DCC_PATH/config
    echo 0x03D70268 1 > $DCC_PATH/config
    echo 0x03D7026C 1 > $DCC_PATH/config
    echo 0x03D70270 1 > $DCC_PATH/config
    echo 0x03D70274 1 > $DCC_PATH/config
    echo 0x03D70278 1 > $DCC_PATH/config
    echo 0x03D7027C 1 > $DCC_PATH/config
    echo 0x03D70280 1 > $DCC_PATH/config
    echo 0x03D70284 1 > $DCC_PATH/config
    echo 0x03D70288 1 > $DCC_PATH/config
    echo 0x03D7028C 1 > $DCC_PATH/config
    echo 0x03D70290 1 > $DCC_PATH/config
    echo 0x03D70294 1 > $DCC_PATH/config
    echo 0x03D70298 1 > $DCC_PATH/config
    echo 0x03D7029C 1 > $DCC_PATH/config
    echo 0x03D702A0 1 > $DCC_PATH/config
    echo 0x03D702A4 1 > $DCC_PATH/config
    echo 0x03D702A8 1 > $DCC_PATH/config
    echo 0x03D702AC 1 > $DCC_PATH/config
    echo 0x03D702B0 1 > $DCC_PATH/config
    echo 0x03D702B4 1 > $DCC_PATH/config
    echo 0x03D702B8 1 > $DCC_PATH/config
    echo 0x03D702BC 1 > $DCC_PATH/config
    echo 0x03D702C0 1 > $DCC_PATH/config
    echo 0x03D702C4 1 > $DCC_PATH/config
    echo 0x03D702C8 1 > $DCC_PATH/config
    echo 0x03D702CC 1 > $DCC_PATH/config
    echo 0x03D702D0 1 > $DCC_PATH/config
    echo 0x03D702D4 1 > $DCC_PATH/config
    echo 0x03D702D8 1 > $DCC_PATH/config
    echo 0x03D702DC 1 > $DCC_PATH/config
    echo 0x03D702E0 1 > $DCC_PATH/config
    echo 0x03D702E4 1 > $DCC_PATH/config
    echo 0x03D702E8 1 > $DCC_PATH/config
    echo 0x03D702EC 1 > $DCC_PATH/config
    echo 0x03D702F0 1 > $DCC_PATH/config
    echo 0x03D702F4 1 > $DCC_PATH/config
    echo 0x03D702F8 1 > $DCC_PATH/config
    echo 0x03D702FC 1 > $DCC_PATH/config
    echo 0x03D70300 1 > $DCC_PATH/config
    echo 0x03D70304 1 > $DCC_PATH/config
    echo 0x03D70308 1 > $DCC_PATH/config
    echo 0x03D7030C 1 > $DCC_PATH/config
    echo 0x03D70310 1 > $DCC_PATH/config
    echo 0x03D70314 1 > $DCC_PATH/config
    echo 0x03D70318 1 > $DCC_PATH/config
    echo 0x03D7031C 1 > $DCC_PATH/config
    echo 0x03D70320 1 > $DCC_PATH/config
    echo 0x03D70324 1 > $DCC_PATH/config
    echo 0x03D70328 1 > $DCC_PATH/config
    echo 0x03D7032C 1 > $DCC_PATH/config
    echo 0x03D70330 1 > $DCC_PATH/config
    echo 0x03D70334 1 > $DCC_PATH/config
    echo 0x03D70338 1 > $DCC_PATH/config
    echo 0x03D7033C 1 > $DCC_PATH/config
    echo 0x03D70340 1 > $DCC_PATH/config
    echo 0x03D70344 1 > $DCC_PATH/config
    echo 0x03D70348 1 > $DCC_PATH/config
    echo 0x03D7034C 1 > $DCC_PATH/config
    echo 0x03D70350 1 > $DCC_PATH/config
    echo 0x03D70354 1 > $DCC_PATH/config
    echo 0x03D70358 1 > $DCC_PATH/config
    echo 0x03D7035C 1 > $DCC_PATH/config
    echo 0x03D70360 1 > $DCC_PATH/config
    echo 0x03D70364 1 > $DCC_PATH/config
    echo 0x03D70368 1 > $DCC_PATH/config
    echo 0x03D7036C 1 > $DCC_PATH/config
    echo 0x03D70370 1 > $DCC_PATH/config
    echo 0x03D70374 1 > $DCC_PATH/config
    echo 0x03D70378 1 > $DCC_PATH/config
    echo 0x03D7037C 1 > $DCC_PATH/config
    echo 0x03D70380 1 > $DCC_PATH/config
    echo 0x03D70384 1 > $DCC_PATH/config
    echo 0x03D70388 1 > $DCC_PATH/config
    echo 0x03D7038C 1 > $DCC_PATH/config
    echo 0x03D70390 1 > $DCC_PATH/config
    echo 0x03D70394 1 > $DCC_PATH/config
    echo 0x03D70398 1 > $DCC_PATH/config
    echo 0x03D7039C 1 > $DCC_PATH/config
    echo 0x03D703A0 1 > $DCC_PATH/config
    echo 0x03D703A4 1 > $DCC_PATH/config
    echo 0x03D703A8 1 > $DCC_PATH/config
    echo 0x03D703AC 1 > $DCC_PATH/config
    echo 0x03D703B0 1 > $DCC_PATH/config
    echo 0x03D703B4 1 > $DCC_PATH/config
    echo 0x03D703B8 1 > $DCC_PATH/config
    echo 0x03D703BC 1 > $DCC_PATH/config
    echo 0x03D703C0 1 > $DCC_PATH/config
    echo 0x03D703C4 1 > $DCC_PATH/config
    echo 0x03D703C8 1 > $DCC_PATH/config
    echo 0x03D703CC 1 > $DCC_PATH/config
    echo 0x03D703D0 1 > $DCC_PATH/config
    echo 0x03D703D4 1 > $DCC_PATH/config
    echo 0x03D703D8 1 > $DCC_PATH/config
    echo 0x03D703DC 1 > $DCC_PATH/config
    echo 0x03D703E0 1 > $DCC_PATH/config
    echo 0x03D703E4 1 > $DCC_PATH/config
    echo 0x03D703E8 1 > $DCC_PATH/config
    echo 0x03D703EC 1 > $DCC_PATH/config
    echo 0x03D703F0 1 > $DCC_PATH/config
    echo 0x03D703F4 1 > $DCC_PATH/config
    echo 0x03D703F8 1 > $DCC_PATH/config
    echo 0x03D703FC 1 > $DCC_PATH/config
    echo 0x03D70400 1 > $DCC_PATH/config
    echo 0x03D70404 1 > $DCC_PATH/config
    echo 0x03D70408 1 > $DCC_PATH/config
    echo 0x03D7040C 1 > $DCC_PATH/config
    echo 0x03D70410 1 > $DCC_PATH/config
    echo 0x03D70414 1 > $DCC_PATH/config
    echo 0x03D70418 1 > $DCC_PATH/config
    echo 0x03D7041C 1 > $DCC_PATH/config
    echo 0x03D70420 1 > $DCC_PATH/config
    echo 0x03D70424 1 > $DCC_PATH/config
    echo 0x03D70428 1 > $DCC_PATH/config
    echo 0x03D7042C 1 > $DCC_PATH/config
    echo 0x03D70430 1 > $DCC_PATH/config
    echo 0x03D70434 1 > $DCC_PATH/config
    echo 0x03D70438 1 > $DCC_PATH/config
    echo 0x03D7043C 1 > $DCC_PATH/config
    echo 0x03D70440 1 > $DCC_PATH/config
    echo 0x03D70444 1 > $DCC_PATH/config
    echo 0x03D70448 1 > $DCC_PATH/config
    echo 0x03D7044C 1 > $DCC_PATH/config
    echo 0x03D70450 1 > $DCC_PATH/config
    echo 0x03D70454 1 > $DCC_PATH/config
    echo 0x03D70458 1 > $DCC_PATH/config
    echo 0x03D7045C 1 > $DCC_PATH/config
    echo 0x03D70460 1 > $DCC_PATH/config
    echo 0x03D70464 1 > $DCC_PATH/config
    echo 0x03D70468 1 > $DCC_PATH/config
    echo 0x03D7046C 1 > $DCC_PATH/config
    echo 0x03D70470 1 > $DCC_PATH/config
    echo 0x03D70474 1 > $DCC_PATH/config
    echo 0x03D70478 1 > $DCC_PATH/config
    echo 0x03D7047C 1 > $DCC_PATH/config
    echo 0x03D70480 1 > $DCC_PATH/config
    echo 0x03D70484 1 > $DCC_PATH/config
    echo 0x03D70488 1 > $DCC_PATH/config
    echo 0x03D7048C 1 > $DCC_PATH/config
    echo 0x03D70490 1 > $DCC_PATH/config
    echo 0x03D70494 1 > $DCC_PATH/config
    echo 0x03D70498 1 > $DCC_PATH/config
    echo 0x03D7049C 1 > $DCC_PATH/config
    echo 0x03D704A0 1 > $DCC_PATH/config
    echo 0x03D704A4 1 > $DCC_PATH/config
    echo 0x03D704A8 1 > $DCC_PATH/config
    echo 0x03D704AC 1 > $DCC_PATH/config
    echo 0x03D704B0 1 > $DCC_PATH/config
    echo 0x03D704B4 1 > $DCC_PATH/config
    echo 0x03D704B8 1 > $DCC_PATH/config
    echo 0x03D704BC 1 > $DCC_PATH/config
    echo 0x03D704C0 1 > $DCC_PATH/config
    echo 0x03D704C4 1 > $DCC_PATH/config
    echo 0x03D704C8 1 > $DCC_PATH/config
    echo 0x03D704CC 1 > $DCC_PATH/config
    echo 0x03D704D0 1 > $DCC_PATH/config
    echo 0x03D704D4 1 > $DCC_PATH/config
    echo 0x03D704D8 1 > $DCC_PATH/config
    echo 0x03D704DC 1 > $DCC_PATH/config
    echo 0x03D704E0 1 > $DCC_PATH/config
    echo 0x03D704E4 1 > $DCC_PATH/config
    echo 0x03D704E8 1 > $DCC_PATH/config
    echo 0x03D704EC 1 > $DCC_PATH/config
    echo 0x03D704F0 1 > $DCC_PATH/config
    echo 0x03D704F4 1 > $DCC_PATH/config
    echo 0x03D704F8 1 > $DCC_PATH/config
    echo 0x03D704FC 1 > $DCC_PATH/config
    echo 0x03D70500 1 > $DCC_PATH/config
    echo 0x03D70504 1 > $DCC_PATH/config
    echo 0x03D70508 1 > $DCC_PATH/config
    echo 0x03D7050C 1 > $DCC_PATH/config
    echo 0x03D70510 1 > $DCC_PATH/config
    echo 0x03D70514 1 > $DCC_PATH/config
    echo 0x03D70518 1 > $DCC_PATH/config
    echo 0x03D7051C 1 > $DCC_PATH/config
    echo 0x03D70520 1 > $DCC_PATH/config
    echo 0x03D70524 1 > $DCC_PATH/config
    echo 0x03D70528 1 > $DCC_PATH/config
    echo 0x03D7052C 1 > $DCC_PATH/config
    echo 0x03D70530 1 > $DCC_PATH/config
    echo 0x03D70534 1 > $DCC_PATH/config
    echo 0x03D70538 1 > $DCC_PATH/config
    echo 0x03D7053C 1 > $DCC_PATH/config
    echo 0x03D70540 1 > $DCC_PATH/config
    echo 0x03D70544 1 > $DCC_PATH/config
    echo 0x03D70548 1 > $DCC_PATH/config
    echo 0x03D7054C 1 > $DCC_PATH/config
    echo 0x03D70550 1 > $DCC_PATH/config
    echo 0x03D70554 1 > $DCC_PATH/config
    echo 0x03D70558 1 > $DCC_PATH/config
    echo 0x03D7055C 1 > $DCC_PATH/config
    echo 0x03D70560 1 > $DCC_PATH/config
    echo 0x03D70564 1 > $DCC_PATH/config
    echo 0x03D70568 1 > $DCC_PATH/config
    echo 0x03D7056C 1 > $DCC_PATH/config
    echo 0x03D70570 1 > $DCC_PATH/config
    echo 0x03D70574 1 > $DCC_PATH/config
    echo 0x03D70578 1 > $DCC_PATH/config
    echo 0x03D7057C 1 > $DCC_PATH/config
    echo 0x03D70580 1 > $DCC_PATH/config
    echo 0x03D70584 1 > $DCC_PATH/config
    echo 0x03D70588 1 > $DCC_PATH/config
    echo 0x03D7058C 1 > $DCC_PATH/config
    echo 0x03D70590 1 > $DCC_PATH/config
    echo 0x03D70594 1 > $DCC_PATH/config
    echo 0x03D70598 1 > $DCC_PATH/config
    echo 0x03D7059C 1 > $DCC_PATH/config
    echo 0x03D705A0 1 > $DCC_PATH/config
    echo 0x03D705A4 1 > $DCC_PATH/config
    echo 0x03D705A8 1 > $DCC_PATH/config
    echo 0x03D705AC 1 > $DCC_PATH/config
    echo 0x03D705B0 1 > $DCC_PATH/config
    echo 0x03D705B4 1 > $DCC_PATH/config
    echo 0x03D705B8 1 > $DCC_PATH/config
    echo 0x03D705BC 1 > $DCC_PATH/config
    echo 0x03D705C0 1 > $DCC_PATH/config
    echo 0x03D705C4 1 > $DCC_PATH/config
    echo 0x03D705C8 1 > $DCC_PATH/config
    echo 0x03D705CC 1 > $DCC_PATH/config
    echo 0x03D705D0 1 > $DCC_PATH/config
    echo 0x03D705D4 1 > $DCC_PATH/config
    echo 0x03D705D8 1 > $DCC_PATH/config
    echo 0x03D705DC 1 > $DCC_PATH/config
    echo 0x03D705E0 1 > $DCC_PATH/config
    echo 0x03D705E4 1 > $DCC_PATH/config
    echo 0x03D705E8 1 > $DCC_PATH/config
    echo 0x03D705EC 1 > $DCC_PATH/config
    echo 0x03D705F0 1 > $DCC_PATH/config
    echo 0x03D705F4 1 > $DCC_PATH/config
    echo 0x03D705F8 1 > $DCC_PATH/config
    echo 0x03D705FC 1 > $DCC_PATH/config
    echo 0x03D70600 1 > $DCC_PATH/config
    echo 0x03D70604 1 > $DCC_PATH/config
    echo 0x03D70608 1 > $DCC_PATH/config
    echo 0x03D7060C 1 > $DCC_PATH/config
    echo 0x03D70610 1 > $DCC_PATH/config
    echo 0x03D70614 1 > $DCC_PATH/config
    echo 0x03D70618 1 > $DCC_PATH/config
    echo 0x03D7061C 1 > $DCC_PATH/config
    echo 0x03D70620 1 > $DCC_PATH/config
    echo 0x03D70624 1 > $DCC_PATH/config
    echo 0x03D70628 1 > $DCC_PATH/config
    echo 0x03D7062C 1 > $DCC_PATH/config
    echo 0x03D70630 1 > $DCC_PATH/config
    echo 0x03D70634 1 > $DCC_PATH/config
    echo 0x03D70638 1 > $DCC_PATH/config
    echo 0x03D7063C 1 > $DCC_PATH/config
    echo 0x03D70640 1 > $DCC_PATH/config
    echo 0x03D70644 1 > $DCC_PATH/config
    echo 0x03D70648 1 > $DCC_PATH/config
    echo 0x03D7064C 1 > $DCC_PATH/config
    echo 0x03D70650 1 > $DCC_PATH/config
    echo 0x03D70654 1 > $DCC_PATH/config
    echo 0x03D70658 1 > $DCC_PATH/config
    echo 0x03D7065C 1 > $DCC_PATH/config
    echo 0x03D70660 1 > $DCC_PATH/config
    echo 0x03D70664 1 > $DCC_PATH/config
    echo 0x03D70668 1 > $DCC_PATH/config
    echo 0x03D7066C 1 > $DCC_PATH/config
    echo 0x03D70670 1 > $DCC_PATH/config
    echo 0x03D70674 1 > $DCC_PATH/config
    echo 0x03D70678 1 > $DCC_PATH/config
    echo 0x03D7067C 1 > $DCC_PATH/config
    echo 0x03D70680 1 > $DCC_PATH/config
    echo 0x03D70684 1 > $DCC_PATH/config
    echo 0x03D70688 1 > $DCC_PATH/config
    echo 0x03D7068C 1 > $DCC_PATH/config
    echo 0x03D70690 1 > $DCC_PATH/config
    echo 0x03D70694 1 > $DCC_PATH/config
    echo 0x03D70698 1 > $DCC_PATH/config
    echo 0x03D7069C 1 > $DCC_PATH/config
    echo 0x03D706A0 1 > $DCC_PATH/config
    echo 0x03D706A4 1 > $DCC_PATH/config
    echo 0x03D706A8 1 > $DCC_PATH/config
    echo 0x03D706AC 1 > $DCC_PATH/config
    echo 0x03D706B0 1 > $DCC_PATH/config
    echo 0x03D706B4 1 > $DCC_PATH/config
    echo 0x03D706B8 1 > $DCC_PATH/config
    echo 0x03D706BC 1 > $DCC_PATH/config
    echo 0x03D706C0 1 > $DCC_PATH/config
    echo 0x03D706C4 1 > $DCC_PATH/config
    echo 0x03D706C8 1 > $DCC_PATH/config
    echo 0x03D706CC 1 > $DCC_PATH/config
    echo 0x03D706D0 1 > $DCC_PATH/config
    echo 0x03D706D4 1 > $DCC_PATH/config
    echo 0x03D706D8 1 > $DCC_PATH/config
    echo 0x03D706DC 1 > $DCC_PATH/config
    echo 0x03D706E0 1 > $DCC_PATH/config
    echo 0x03D706E4 1 > $DCC_PATH/config
    echo 0x03D706E8 1 > $DCC_PATH/config
    echo 0x03D706EC 1 > $DCC_PATH/config
    echo 0x03D706F0 1 > $DCC_PATH/config
    echo 0x03D706F4 1 > $DCC_PATH/config
    echo 0x03D706F8 1 > $DCC_PATH/config
    echo 0x03D706FC 1 > $DCC_PATH/config
    echo 0x03D70700 1 > $DCC_PATH/config
    echo 0x03D70704 1 > $DCC_PATH/config
    echo 0x03D70708 1 > $DCC_PATH/config
    echo 0x03D7070C 1 > $DCC_PATH/config
    echo 0x03D70710 1 > $DCC_PATH/config
    echo 0x03D70714 1 > $DCC_PATH/config
    echo 0x03D70718 1 > $DCC_PATH/config
    echo 0x03D7071C 1 > $DCC_PATH/config
    echo 0x03D70720 1 > $DCC_PATH/config
    echo 0x03D70724 1 > $DCC_PATH/config
    echo 0x03D70728 1 > $DCC_PATH/config
    echo 0x03D7072C 1 > $DCC_PATH/config
    echo 0x03D70730 1 > $DCC_PATH/config
    echo 0x03D70734 1 > $DCC_PATH/config
    echo 0x03D70738 1 > $DCC_PATH/config
    echo 0x03D7073C 1 > $DCC_PATH/config
    echo 0x03D70740 1 > $DCC_PATH/config
    echo 0x03D70744 1 > $DCC_PATH/config
    echo 0x03D70748 1 > $DCC_PATH/config
    echo 0x03D7074C 1 > $DCC_PATH/config
    echo 0x03D70750 1 > $DCC_PATH/config
    echo 0x03D70754 1 > $DCC_PATH/config
    echo 0x03D70758 1 > $DCC_PATH/config
    echo 0x03D7075C 1 > $DCC_PATH/config
    echo 0x03D70760 1 > $DCC_PATH/config
    echo 0x03D70764 1 > $DCC_PATH/config
    echo 0x03D70768 1 > $DCC_PATH/config
    echo 0x03D7076C 1 > $DCC_PATH/config
    echo 0x03D70770 1 > $DCC_PATH/config
    echo 0x03D70774 1 > $DCC_PATH/config
    echo 0x03D70778 1 > $DCC_PATH/config
    echo 0x03D7077C 1 > $DCC_PATH/config
    echo 0x03D70780 1 > $DCC_PATH/config
    echo 0x03D70784 1 > $DCC_PATH/config
    echo 0x03D70788 1 > $DCC_PATH/config
    echo 0x03D7078C 1 > $DCC_PATH/config
    echo 0x03D70790 1 > $DCC_PATH/config
    echo 0x03D70794 1 > $DCC_PATH/config
    echo 0x03D70798 1 > $DCC_PATH/config
    echo 0x03D7079C 1 > $DCC_PATH/config
    echo 0x03D707A0 1 > $DCC_PATH/config
    echo 0x03D707A4 1 > $DCC_PATH/config
    echo 0x03D707A8 1 > $DCC_PATH/config
    echo 0x03D707AC 1 > $DCC_PATH/config
    echo 0x03D707B0 1 > $DCC_PATH/config
    echo 0x03D707B4 1 > $DCC_PATH/config
    echo 0x03D707B8 1 > $DCC_PATH/config
    echo 0x03D707BC 1 > $DCC_PATH/config
    echo 0x03D707C0 1 > $DCC_PATH/config
    echo 0x03D707C4 1 > $DCC_PATH/config
    echo 0x03D707C8 1 > $DCC_PATH/config
    echo 0x03D707CC 1 > $DCC_PATH/config
    echo 0x03D707D0 1 > $DCC_PATH/config
    echo 0x03D707D4 1 > $DCC_PATH/config
    echo 0x03D707D8 1 > $DCC_PATH/config
    echo 0x03D707DC 1 > $DCC_PATH/config
    echo 0x03D707E0 1 > $DCC_PATH/config
    echo 0x03D707E4 1 > $DCC_PATH/config
    echo 0x03D707E8 1 > $DCC_PATH/config
    echo 0x03D707EC 1 > $DCC_PATH/config
    echo 0x03D707F0 1 > $DCC_PATH/config
    echo 0x03D707F4 1 > $DCC_PATH/config
    echo 0x03D707F8 1 > $DCC_PATH/config
    echo 0x03D707FC 1 > $DCC_PATH/config
    echo 0x03D70800 1 > $DCC_PATH/config
    echo 0x03D70804 1 > $DCC_PATH/config
    echo 0x03D70808 1 > $DCC_PATH/config
    echo 0x03D7080C 1 > $DCC_PATH/config
    echo 0x03D70810 1 > $DCC_PATH/config
    echo 0x03D70814 1 > $DCC_PATH/config
    echo 0x03D70818 1 > $DCC_PATH/config
    echo 0x03D7081C 1 > $DCC_PATH/config
    echo 0x03D70820 1 > $DCC_PATH/config
    echo 0x03D70824 1 > $DCC_PATH/config
    echo 0x03D70828 1 > $DCC_PATH/config
    echo 0x03D7082C 1 > $DCC_PATH/config
    echo 0x03D70830 1 > $DCC_PATH/config
    echo 0x03D70834 1 > $DCC_PATH/config
    echo 0x03D70838 1 > $DCC_PATH/config
    echo 0x03D7083C 1 > $DCC_PATH/config
    echo 0x03D70840 1 > $DCC_PATH/config
    echo 0x03D70844 1 > $DCC_PATH/config
    echo 0x03D70848 1 > $DCC_PATH/config
    echo 0x03D7084C 1 > $DCC_PATH/config
    echo 0x03D70850 1 > $DCC_PATH/config
    echo 0x03D70854 1 > $DCC_PATH/config
    echo 0x03D70858 1 > $DCC_PATH/config
    echo 0x03D7085C 1 > $DCC_PATH/config
    echo 0x03D70860 1 > $DCC_PATH/config
    echo 0x03D70864 1 > $DCC_PATH/config
    echo 0x03D70868 1 > $DCC_PATH/config
    echo 0x03D7086C 1 > $DCC_PATH/config
    echo 0x03D70870 1 > $DCC_PATH/config
    echo 0x03D70874 1 > $DCC_PATH/config
    echo 0x03D70878 1 > $DCC_PATH/config
    echo 0x03D7087C 1 > $DCC_PATH/config
    echo 0x03D70880 1 > $DCC_PATH/config
    echo 0x03D70884 1 > $DCC_PATH/config
    echo 0x03D70888 1 > $DCC_PATH/config
    echo 0x03D7088C 1 > $DCC_PATH/config
    echo 0x03D70890 1 > $DCC_PATH/config
    echo 0x03D70894 1 > $DCC_PATH/config
    echo 0x03D70898 1 > $DCC_PATH/config
    echo 0x03D7089C 1 > $DCC_PATH/config
    echo 0x03D708A0 1 > $DCC_PATH/config
    echo 0x03D708A4 1 > $DCC_PATH/config
    echo 0x03D708A8 1 > $DCC_PATH/config
    echo 0x03D708AC 1 > $DCC_PATH/config
    echo 0x03D708B0 1 > $DCC_PATH/config
    echo 0x03D708B4 1 > $DCC_PATH/config
    echo 0x03D708B8 1 > $DCC_PATH/config
    echo 0x03D708BC 1 > $DCC_PATH/config
    echo 0x03D708C0 1 > $DCC_PATH/config
    echo 0x03D708C4 1 > $DCC_PATH/config
    echo 0x03D708C8 1 > $DCC_PATH/config
    echo 0x03D708CC 1 > $DCC_PATH/config
    echo 0x03D708D0 1 > $DCC_PATH/config
    echo 0x03D708D4 1 > $DCC_PATH/config
    echo 0x03D708D8 1 > $DCC_PATH/config
    echo 0x03D708DC 1 > $DCC_PATH/config
    echo 0x03D708E0 1 > $DCC_PATH/config
    echo 0x03D708E4 1 > $DCC_PATH/config
    echo 0x03D708E8 1 > $DCC_PATH/config
    echo 0x03D708EC 1 > $DCC_PATH/config
    echo 0x03D708F0 1 > $DCC_PATH/config
    echo 0x03D708F4 1 > $DCC_PATH/config
    echo 0x03D708F8 1 > $DCC_PATH/config
    echo 0x03D708FC 1 > $DCC_PATH/config
    echo 0x03D70900 1 > $DCC_PATH/config
    echo 0x03D70904 1 > $DCC_PATH/config
    echo 0x03D70908 1 > $DCC_PATH/config
    echo 0x03D7090C 1 > $DCC_PATH/config
    echo 0x03D70910 1 > $DCC_PATH/config
    echo 0x03D70914 1 > $DCC_PATH/config
    echo 0x03D70918 1 > $DCC_PATH/config
    echo 0x03D7091C 1 > $DCC_PATH/config
    echo 0x03D70920 1 > $DCC_PATH/config
    echo 0x03D70924 1 > $DCC_PATH/config
    echo 0x03D70928 1 > $DCC_PATH/config
    echo 0x03D7092C 1 > $DCC_PATH/config
    echo 0x03D70930 1 > $DCC_PATH/config
    echo 0x03D70934 1 > $DCC_PATH/config
    echo 0x03D70938 1 > $DCC_PATH/config
    echo 0x03D7093C 1 > $DCC_PATH/config
    echo 0x03D70940 1 > $DCC_PATH/config
    echo 0x03D70944 1 > $DCC_PATH/config
    echo 0x03D70948 1 > $DCC_PATH/config
    echo 0x03D7094C 1 > $DCC_PATH/config
    echo 0x03D70950 1 > $DCC_PATH/config
    echo 0x03D70954 1 > $DCC_PATH/config
    echo 0x03D70958 1 > $DCC_PATH/config
    echo 0x03D7095C 1 > $DCC_PATH/config
    echo 0x03D70960 1 > $DCC_PATH/config
    echo 0x03D70964 1 > $DCC_PATH/config
    echo 0x03D70968 1 > $DCC_PATH/config
    echo 0x03D7096C 1 > $DCC_PATH/config
    echo 0x03D70970 1 > $DCC_PATH/config
    echo 0x03D70974 1 > $DCC_PATH/config
    echo 0x03D70978 1 > $DCC_PATH/config
    echo 0x03D7097C 1 > $DCC_PATH/config
    echo 0x03D70980 1 > $DCC_PATH/config
    echo 0x03D70984 1 > $DCC_PATH/config
    echo 0x03D70988 1 > $DCC_PATH/config
    echo 0x03D7098C 1 > $DCC_PATH/config
    echo 0x03D70990 1 > $DCC_PATH/config
    echo 0x03D70994 1 > $DCC_PATH/config
    echo 0x03D70998 1 > $DCC_PATH/config
    echo 0x03D7099C 1 > $DCC_PATH/config
    echo 0x03D709A0 1 > $DCC_PATH/config
    echo 0x03D709A4 1 > $DCC_PATH/config
    echo 0x03D709A8 1 > $DCC_PATH/config
    echo 0x03D709AC 1 > $DCC_PATH/config
    echo 0x03D709B0 1 > $DCC_PATH/config
    echo 0x03D709B4 1 > $DCC_PATH/config
    echo 0x03D709B8 1 > $DCC_PATH/config
    echo 0x03D709BC 1 > $DCC_PATH/config
    echo 0x03D709C0 1 > $DCC_PATH/config
    echo 0x03D709C4 1 > $DCC_PATH/config
    echo 0x03D709C8 1 > $DCC_PATH/config
    echo 0x03D709CC 1 > $DCC_PATH/config
    echo 0x03D709D0 1 > $DCC_PATH/config
    echo 0x03D709D4 1 > $DCC_PATH/config
    echo 0x03D709D8 1 > $DCC_PATH/config
    echo 0x03D709DC 1 > $DCC_PATH/config
    echo 0x03D709E0 1 > $DCC_PATH/config
    echo 0x03D709E4 1 > $DCC_PATH/config
    echo 0x03D709E8 1 > $DCC_PATH/config
    echo 0x03D709EC 1 > $DCC_PATH/config
    echo 0x03D709F0 1 > $DCC_PATH/config
    echo 0x03D709F4 1 > $DCC_PATH/config
    echo 0x03D709F8 1 > $DCC_PATH/config
    echo 0x03D709FC 1 > $DCC_PATH/config
    echo 0x03D70A00 1 > $DCC_PATH/config
    echo 0x03D70A04 1 > $DCC_PATH/config
    echo 0x03D70A08 1 > $DCC_PATH/config
    echo 0x03D70A0C 1 > $DCC_PATH/config
    echo 0x03D70A10 1 > $DCC_PATH/config
    echo 0x03D70A14 1 > $DCC_PATH/config
    echo 0x03D70A18 1 > $DCC_PATH/config
    echo 0x03D70A1C 1 > $DCC_PATH/config
    echo 0x03D70A20 1 > $DCC_PATH/config
    echo 0x03D70A24 1 > $DCC_PATH/config
    echo 0x03D70A28 1 > $DCC_PATH/config
    echo 0x03D70A2C 1 > $DCC_PATH/config
    echo 0x03D70A30 1 > $DCC_PATH/config
    echo 0x03D70A34 1 > $DCC_PATH/config
    echo 0x03D70A38 1 > $DCC_PATH/config
    echo 0x03D70A3C 1 > $DCC_PATH/config
    echo 0x03D70A40 1 > $DCC_PATH/config
    echo 0x03D70A44 1 > $DCC_PATH/config
    echo 0x03D70A48 1 > $DCC_PATH/config
    echo 0x03D70A4C 1 > $DCC_PATH/config
    echo 0x03D70A50 1 > $DCC_PATH/config
    echo 0x03D70A54 1 > $DCC_PATH/config
    echo 0x03D70A58 1 > $DCC_PATH/config
    echo 0x03D70A5C 1 > $DCC_PATH/config
    echo 0x03D70A60 1 > $DCC_PATH/config
    echo 0x03D70A64 1 > $DCC_PATH/config
    echo 0x03D70A68 1 > $DCC_PATH/config
    echo 0x03D70A6C 1 > $DCC_PATH/config
    echo 0x03D70A70 1 > $DCC_PATH/config
    echo 0x03D70A74 1 > $DCC_PATH/config
    echo 0x03D70A78 1 > $DCC_PATH/config
    echo 0x03D70A7C 1 > $DCC_PATH/config
    echo 0x03D70A80 1 > $DCC_PATH/config
    echo 0x03D70A84 1 > $DCC_PATH/config
    echo 0x03D70A88 1 > $DCC_PATH/config
    echo 0x03D70A8C 1 > $DCC_PATH/config
    echo 0x03D70A90 1 > $DCC_PATH/config
    echo 0x03D70A94 1 > $DCC_PATH/config
    echo 0x03D70A98 1 > $DCC_PATH/config
    echo 0x03D70A9C 1 > $DCC_PATH/config
    echo 0x03D70AA0 1 > $DCC_PATH/config
    echo 0x03D70AA4 1 > $DCC_PATH/config
    echo 0x03D70AA8 1 > $DCC_PATH/config
    echo 0x03D70AAC 1 > $DCC_PATH/config
    echo 0x03D70AB0 1 > $DCC_PATH/config
    echo 0x03D70AB4 1 > $DCC_PATH/config
    echo 0x03D70AB8 1 > $DCC_PATH/config
    echo 0x03D70ABC 1 > $DCC_PATH/config
    echo 0x03D70AC0 1 > $DCC_PATH/config
    echo 0x03D70AC4 1 > $DCC_PATH/config
    echo 0x03D70AC8 1 > $DCC_PATH/config
    echo 0x03D70ACC 1 > $DCC_PATH/config
    echo 0x03D70AD0 1 > $DCC_PATH/config
    echo 0x03D70AD4 1 > $DCC_PATH/config
    echo 0x03D70AD8 1 > $DCC_PATH/config
    echo 0x03D70ADC 1 > $DCC_PATH/config
    echo 0x03D70AE0 1 > $DCC_PATH/config
    echo 0x03D70AE4 1 > $DCC_PATH/config
    echo 0x03D70AE8 1 > $DCC_PATH/config
    echo 0x03D70AEC 1 > $DCC_PATH/config
    echo 0x03D70AF0 1 > $DCC_PATH/config
    echo 0x03D70AF4 1 > $DCC_PATH/config
    echo 0x03D70AF8 1 > $DCC_PATH/config
    echo 0x03D70AFC 1 > $DCC_PATH/config
    echo 0x03D70B00 1 > $DCC_PATH/config
    echo 0x03D70B04 1 > $DCC_PATH/config
    echo 0x03D70B08 1 > $DCC_PATH/config
    echo 0x03D70B0C 1 > $DCC_PATH/config
    echo 0x03D70B10 1 > $DCC_PATH/config
    echo 0x03D70B14 1 > $DCC_PATH/config
    echo 0x03D70B18 1 > $DCC_PATH/config
    echo 0x03D70B1C 1 > $DCC_PATH/config
    echo 0x03D70B20 1 > $DCC_PATH/config
    echo 0x03D70B24 1 > $DCC_PATH/config
    echo 0x03D70B28 1 > $DCC_PATH/config
    echo 0x03D70B2C 1 > $DCC_PATH/config
    echo 0x03D70B30 1 > $DCC_PATH/config
    echo 0x03D70B34 1 > $DCC_PATH/config
    echo 0x03D70B38 1 > $DCC_PATH/config
    echo 0x03D70B3C 1 > $DCC_PATH/config
    echo 0x03D70B40 1 > $DCC_PATH/config
    echo 0x03D70B44 1 > $DCC_PATH/config
    echo 0x03D70B48 1 > $DCC_PATH/config
    echo 0x03D70B4C 1 > $DCC_PATH/config
    echo 0x03D70B50 1 > $DCC_PATH/config
    echo 0x03D70B54 1 > $DCC_PATH/config
    echo 0x03D70B58 1 > $DCC_PATH/config
    echo 0x03D70B5C 1 > $DCC_PATH/config
    echo 0x03D70B60 1 > $DCC_PATH/config
    echo 0x03D70B64 1 > $DCC_PATH/config
    echo 0x03D70B68 1 > $DCC_PATH/config
    echo 0x03D70B6C 1 > $DCC_PATH/config
    echo 0x03D70B70 1 > $DCC_PATH/config
    echo 0x03D70B74 1 > $DCC_PATH/config
    echo 0x03D70B78 1 > $DCC_PATH/config
    echo 0x03D70B7C 1 > $DCC_PATH/config
    echo 0x03D70B80 1 > $DCC_PATH/config
    echo 0x03D70B84 1 > $DCC_PATH/config
    echo 0x03D70B88 1 > $DCC_PATH/config
    echo 0x03D70B8C 1 > $DCC_PATH/config
    echo 0x03D70B90 1 > $DCC_PATH/config
    echo 0x03D70B94 1 > $DCC_PATH/config
    echo 0x03D70B98 1 > $DCC_PATH/config
    echo 0x03D70B9C 1 > $DCC_PATH/config
    echo 0x03D70BA0 1 > $DCC_PATH/config
    echo 0x03D70BA4 1 > $DCC_PATH/config
    echo 0x03D70BA8 1 > $DCC_PATH/config
    echo 0x03D70BAC 1 > $DCC_PATH/config
    echo 0x03D70BB0 1 > $DCC_PATH/config
    echo 0x03D70BB4 1 > $DCC_PATH/config
    echo 0x03D70BB8 1 > $DCC_PATH/config
    echo 0x03D70BBC 1 > $DCC_PATH/config
    echo 0x03D70BC0 1 > $DCC_PATH/config
    echo 0x03D70BC4 1 > $DCC_PATH/config
    echo 0x03D70BC8 1 > $DCC_PATH/config
    echo 0x03D70BCC 1 > $DCC_PATH/config
    echo 0x03D70BD0 1 > $DCC_PATH/config
    echo 0x03D70BD4 1 > $DCC_PATH/config
    echo 0x03D70BD8 1 > $DCC_PATH/config
    echo 0x03D70BDC 1 > $DCC_PATH/config
    echo 0x03D70BE0 1 > $DCC_PATH/config
    echo 0x03D70BE4 1 > $DCC_PATH/config
    echo 0x03D70BE8 1 > $DCC_PATH/config
    echo 0x03D70BEC 1 > $DCC_PATH/config
    echo 0x03D70BF0 1 > $DCC_PATH/config
    echo 0x03D70BF4 1 > $DCC_PATH/config
    echo 0x03D70BF8 1 > $DCC_PATH/config
    echo 0x03D70BFC 1 > $DCC_PATH/config
    echo 0x03D70C00 1 > $DCC_PATH/config
    echo 0x03D70C04 1 > $DCC_PATH/config
    echo 0x03D70C08 1 > $DCC_PATH/config
    echo 0x03D70C0C 1 > $DCC_PATH/config
    echo 0x03D70C10 1 > $DCC_PATH/config
    echo 0x03D70C14 1 > $DCC_PATH/config
    echo 0x03D70C18 1 > $DCC_PATH/config
    echo 0x03D70C1C 1 > $DCC_PATH/config
    echo 0x03D70C20 1 > $DCC_PATH/config
    echo 0x03D70C24 1 > $DCC_PATH/config
    echo 0x03D70C28 1 > $DCC_PATH/config
    echo 0x03D70C2C 1 > $DCC_PATH/config
    echo 0x03D70C30 1 > $DCC_PATH/config
    echo 0x03D70C34 1 > $DCC_PATH/config
    echo 0x03D70C38 1 > $DCC_PATH/config
    echo 0x03D70C3C 1 > $DCC_PATH/config
    echo 0x03D70C40 1 > $DCC_PATH/config
    echo 0x03D70C44 1 > $DCC_PATH/config
    echo 0x03D70C48 1 > $DCC_PATH/config
    echo 0x03D70C4C 1 > $DCC_PATH/config
    echo 0x03D70C50 1 > $DCC_PATH/config
    echo 0x03D70C54 1 > $DCC_PATH/config
    echo 0x03D70C58 1 > $DCC_PATH/config
    echo 0x03D70C5C 1 > $DCC_PATH/config
    echo 0x03D70C60 1 > $DCC_PATH/config
    echo 0x03D70C64 1 > $DCC_PATH/config
    echo 0x03D70C68 1 > $DCC_PATH/config
    echo 0x03D70C6C 1 > $DCC_PATH/config
    echo 0x03D70C70 1 > $DCC_PATH/config
    echo 0x03D70C74 1 > $DCC_PATH/config
    echo 0x03D70C78 1 > $DCC_PATH/config
    echo 0x03D70C7C 1 > $DCC_PATH/config
    echo 0x03D70C80 1 > $DCC_PATH/config
    echo 0x03D70C84 1 > $DCC_PATH/config
    echo 0x03D70C88 1 > $DCC_PATH/config
    echo 0x03D70C8C 1 > $DCC_PATH/config
    echo 0x03D70C90 1 > $DCC_PATH/config
    echo 0x03D70C94 1 > $DCC_PATH/config
    echo 0x03D70C98 1 > $DCC_PATH/config
    echo 0x03D70C9C 1 > $DCC_PATH/config
    echo 0x03D70CA0 1 > $DCC_PATH/config
    echo 0x03D70CA4 1 > $DCC_PATH/config
    echo 0x03D70CA8 1 > $DCC_PATH/config
    echo 0x03D70CAC 1 > $DCC_PATH/config
    echo 0x03D70CB0 1 > $DCC_PATH/config
    echo 0x03D70CB4 1 > $DCC_PATH/config
    echo 0x03D70CB8 1 > $DCC_PATH/config
    echo 0x03D70CBC 1 > $DCC_PATH/config
    echo 0x03D70CC0 1 > $DCC_PATH/config
    echo 0x03D70CC4 1 > $DCC_PATH/config
    echo 0x03D70CC8 1 > $DCC_PATH/config
    echo 0x03D70CCC 1 > $DCC_PATH/config
    echo 0x03D70CD0 1 > $DCC_PATH/config
    echo 0x03D70CD4 1 > $DCC_PATH/config
    echo 0x03D70CD8 1 > $DCC_PATH/config
    echo 0x03D70CDC 1 > $DCC_PATH/config
    echo 0x03D70CE0 1 > $DCC_PATH/config
    echo 0x03D70CE4 1 > $DCC_PATH/config
    echo 0x03D70CE8 1 > $DCC_PATH/config
    echo 0x03D70CEC 1 > $DCC_PATH/config
    echo 0x03D70CF0 1 > $DCC_PATH/config
    echo 0x03D70CF4 1 > $DCC_PATH/config
    echo 0x03D70CF8 1 > $DCC_PATH/config
    echo 0x03D70CFC 1 > $DCC_PATH/config
    echo 0x03D70D00 1 > $DCC_PATH/config
    echo 0x03D70D04 1 > $DCC_PATH/config
    echo 0x03D70D08 1 > $DCC_PATH/config
    echo 0x03D70D0C 1 > $DCC_PATH/config
    echo 0x03D70D10 1 > $DCC_PATH/config
    echo 0x03D70D14 1 > $DCC_PATH/config
    echo 0x03D70D18 1 > $DCC_PATH/config
    echo 0x03D70D1C 1 > $DCC_PATH/config
    echo 0x03D70D20 1 > $DCC_PATH/config
    echo 0x03D70D24 1 > $DCC_PATH/config
    echo 0x03D70D28 1 > $DCC_PATH/config
    echo 0x03D70D2C 1 > $DCC_PATH/config
    echo 0x03D70D30 1 > $DCC_PATH/config
    echo 0x03D70D34 1 > $DCC_PATH/config
    echo 0x03D70D38 1 > $DCC_PATH/config
    echo 0x03D70D3C 1 > $DCC_PATH/config
    echo 0x03D70D40 1 > $DCC_PATH/config
    echo 0x03D70D44 1 > $DCC_PATH/config
    echo 0x03D70D48 1 > $DCC_PATH/config
    echo 0x03D70D4C 1 > $DCC_PATH/config
    echo 0x03D70D50 1 > $DCC_PATH/config
    echo 0x03D70D54 1 > $DCC_PATH/config
    echo 0x03D70D58 1 > $DCC_PATH/config
    echo 0x03D70D5C 1 > $DCC_PATH/config
    echo 0x03D70D60 1 > $DCC_PATH/config
    echo 0x03D70D64 1 > $DCC_PATH/config
    echo 0x03D70D68 1 > $DCC_PATH/config
    echo 0x03D70D6C 1 > $DCC_PATH/config
    echo 0x03D70D70 1 > $DCC_PATH/config
    echo 0x03D70D74 1 > $DCC_PATH/config
    echo 0x03D70D78 1 > $DCC_PATH/config
    echo 0x03D70D7C 1 > $DCC_PATH/config
    echo 0x03D70D80 1 > $DCC_PATH/config
    echo 0x03D70D84 1 > $DCC_PATH/config
    echo 0x03D70D88 1 > $DCC_PATH/config
    echo 0x03D70D8C 1 > $DCC_PATH/config
    echo 0x03D70D90 1 > $DCC_PATH/config
    echo 0x03D70D94 1 > $DCC_PATH/config
    echo 0x03D70D98 1 > $DCC_PATH/config
    echo 0x03D70D9C 1 > $DCC_PATH/config
    echo 0x03D70DA0 1 > $DCC_PATH/config
    echo 0x03D70DA4 1 > $DCC_PATH/config
    echo 0x03D70DA8 1 > $DCC_PATH/config
    echo 0x03D70DAC 1 > $DCC_PATH/config
    echo 0x03D70DB0 1 > $DCC_PATH/config
    echo 0x03D70DB4 1 > $DCC_PATH/config
    echo 0x03D70DB8 1 > $DCC_PATH/config
    echo 0x03D70DBC 1 > $DCC_PATH/config
    echo 0x03D70DC0 1 > $DCC_PATH/config
    echo 0x03D70DC4 1 > $DCC_PATH/config
    echo 0x03D70DC8 1 > $DCC_PATH/config
    echo 0x03D70DCC 1 > $DCC_PATH/config
    echo 0x03D70DD0 1 > $DCC_PATH/config
    echo 0x03D70DD4 1 > $DCC_PATH/config
    echo 0x03D70DD8 1 > $DCC_PATH/config
    echo 0x03D70DDC 1 > $DCC_PATH/config
    echo 0x03D70DE0 1 > $DCC_PATH/config
    echo 0x03D70DE4 1 > $DCC_PATH/config
    echo 0x03D70DE8 1 > $DCC_PATH/config
    echo 0x03D70DEC 1 > $DCC_PATH/config
    echo 0x03D70DF0 1 > $DCC_PATH/config
    echo 0x03D70DF4 1 > $DCC_PATH/config
    echo 0x03D70DF8 1 > $DCC_PATH/config
    echo 0x03D70DFC 1 > $DCC_PATH/config
    echo 0x03D70E00 1 > $DCC_PATH/config
    echo 0x03D70E04 1 > $DCC_PATH/config
    echo 0x03D70E08 1 > $DCC_PATH/config
    echo 0x03D70E0C 1 > $DCC_PATH/config
    echo 0x03D70E10 1 > $DCC_PATH/config
    echo 0x03D70E14 1 > $DCC_PATH/config
    echo 0x03D70E18 1 > $DCC_PATH/config
    echo 0x03D70E1C 1 > $DCC_PATH/config
    echo 0x03D70E20 1 > $DCC_PATH/config
    echo 0x03D70E24 1 > $DCC_PATH/config
    echo 0x03D70E28 1 > $DCC_PATH/config
    echo 0x03D70E2C 1 > $DCC_PATH/config
    echo 0x03D70E30 1 > $DCC_PATH/config
    echo 0x03D70E34 1 > $DCC_PATH/config
    echo 0x03D70E38 1 > $DCC_PATH/config
    echo 0x03D70E3C 1 > $DCC_PATH/config
    echo 0x03D70E40 1 > $DCC_PATH/config
    echo 0x03D70E44 1 > $DCC_PATH/config
    echo 0x03D70E48 1 > $DCC_PATH/config
    echo 0x03D70E4C 1 > $DCC_PATH/config
    echo 0x03D70E50 1 > $DCC_PATH/config
    echo 0x03D70E54 1 > $DCC_PATH/config
    echo 0x03D70E58 1 > $DCC_PATH/config
    echo 0x03D70E5C 1 > $DCC_PATH/config
    echo 0x03D70E60 1 > $DCC_PATH/config
    echo 0x03D70E64 1 > $DCC_PATH/config
    echo 0x03D70E68 1 > $DCC_PATH/config
    echo 0x03D70E6C 1 > $DCC_PATH/config
    echo 0x03D70E70 1 > $DCC_PATH/config
    echo 0x03D70E74 1 > $DCC_PATH/config
    echo 0x03D70E78 1 > $DCC_PATH/config
    echo 0x03D70E7C 1 > $DCC_PATH/config
    echo 0x03D70E80 1 > $DCC_PATH/config
    echo 0x03D70E84 1 > $DCC_PATH/config
    echo 0x03D70E88 1 > $DCC_PATH/config
    echo 0x03D70E8C 1 > $DCC_PATH/config
    echo 0x03D70E90 1 > $DCC_PATH/config
    echo 0x03D70E94 1 > $DCC_PATH/config
    echo 0x03D70E98 1 > $DCC_PATH/config
    echo 0x03D70E9C 1 > $DCC_PATH/config
    echo 0x03D70EA0 1 > $DCC_PATH/config
    echo 0x03D70EA4 1 > $DCC_PATH/config
    echo 0x03D70EA8 1 > $DCC_PATH/config
    echo 0x03D70EAC 1 > $DCC_PATH/config
    echo 0x03D70EB0 1 > $DCC_PATH/config
    echo 0x03D70EB4 1 > $DCC_PATH/config
    echo 0x03D70EB8 1 > $DCC_PATH/config
    echo 0x03D70EBC 1 > $DCC_PATH/config
    echo 0x03D70EC0 1 > $DCC_PATH/config
    echo 0x03D70EC4 1 > $DCC_PATH/config
    echo 0x03D70EC8 1 > $DCC_PATH/config
    echo 0x03D70ECC 1 > $DCC_PATH/config
    echo 0x03D70ED0 1 > $DCC_PATH/config
    echo 0x03D70ED4 1 > $DCC_PATH/config
    echo 0x03D70ED8 1 > $DCC_PATH/config
    echo 0x03D70EDC 1 > $DCC_PATH/config
    echo 0x03D70EE0 1 > $DCC_PATH/config
    echo 0x03D70EE4 1 > $DCC_PATH/config
    echo 0x03D70EE8 1 > $DCC_PATH/config
    echo 0x03D70EEC 1 > $DCC_PATH/config
    echo 0x03D70EF0 1 > $DCC_PATH/config
    echo 0x03D70EF4 1 > $DCC_PATH/config
    echo 0x03D70EF8 1 > $DCC_PATH/config
    echo 0x03D70EFC 1 > $DCC_PATH/config
    echo 0x03D70F00 1 > $DCC_PATH/config
    echo 0x03D70F04 1 > $DCC_PATH/config
    echo 0x03D70F08 1 > $DCC_PATH/config
    echo 0x03D70F0C 1 > $DCC_PATH/config
    echo 0x03D70F10 1 > $DCC_PATH/config
    echo 0x03D70F14 1 > $DCC_PATH/config
    echo 0x03D70F18 1 > $DCC_PATH/config
    echo 0x03D70F1C 1 > $DCC_PATH/config
    echo 0x03D70F20 1 > $DCC_PATH/config
    echo 0x03D70F24 1 > $DCC_PATH/config
    echo 0x03D70F28 1 > $DCC_PATH/config
    echo 0x03D70F2C 1 > $DCC_PATH/config
    echo 0x03D70F30 1 > $DCC_PATH/config
    echo 0x03D70F34 1 > $DCC_PATH/config
    echo 0x03D70F38 1 > $DCC_PATH/config
    echo 0x03D70F3C 1 > $DCC_PATH/config
    echo 0x03D70F40 1 > $DCC_PATH/config
    echo 0x03D70F44 1 > $DCC_PATH/config
    echo 0x03D70F48 1 > $DCC_PATH/config
    echo 0x03D70F4C 1 > $DCC_PATH/config
    echo 0x03D70F50 1 > $DCC_PATH/config
    echo 0x03D70F54 1 > $DCC_PATH/config
    echo 0x03D70F58 1 > $DCC_PATH/config
    echo 0x03D70F5C 1 > $DCC_PATH/config
    echo 0x03D70F60 1 > $DCC_PATH/config
    echo 0x03D70F64 1 > $DCC_PATH/config
    echo 0x03D70F68 1 > $DCC_PATH/config
    echo 0x03D70F6C 1 > $DCC_PATH/config
    echo 0x03D70F70 1 > $DCC_PATH/config
    echo 0x03D70F74 1 > $DCC_PATH/config
    echo 0x03D70F78 1 > $DCC_PATH/config
    echo 0x03D70F7C 1 > $DCC_PATH/config
    echo 0x03D70F80 1 > $DCC_PATH/config
    echo 0x03D70F84 1 > $DCC_PATH/config
    echo 0x03D70F88 1 > $DCC_PATH/config
    echo 0x03D70F8C 1 > $DCC_PATH/config
    echo 0x03D70F90 1 > $DCC_PATH/config
    echo 0x03D70F94 1 > $DCC_PATH/config
    echo 0x03D70F98 1 > $DCC_PATH/config
    echo 0x03D70F9C 1 > $DCC_PATH/config
    echo 0x03D70FA0 1 > $DCC_PATH/config
    echo 0x03D70FA4 1 > $DCC_PATH/config
    echo 0x03D70FA8 1 > $DCC_PATH/config
    echo 0x03D70FAC 1 > $DCC_PATH/config
    echo 0x03D70FB0 1 > $DCC_PATH/config
    echo 0x03D70FB4 1 > $DCC_PATH/config
    echo 0x03D70FB8 1 > $DCC_PATH/config
    echo 0x03D70FBC 1 > $DCC_PATH/config
    echo 0x03D70FC0 1 > $DCC_PATH/config
    echo 0x03D70FC4 1 > $DCC_PATH/config
    echo 0x03D70FC8 1 > $DCC_PATH/config
    echo 0x03D70FCC 1 > $DCC_PATH/config
    echo 0x03D70FD0 1 > $DCC_PATH/config
    echo 0x03D70FD4 1 > $DCC_PATH/config
    echo 0x03D70FD8 1 > $DCC_PATH/config
    echo 0x03D70FDC 1 > $DCC_PATH/config
    echo 0x03D70FE0 1 > $DCC_PATH/config
    echo 0x03D70FE4 1 > $DCC_PATH/config
    echo 0x03D70FE8 1 > $DCC_PATH/config
    echo 0x03D70FEC 1 > $DCC_PATH/config
    echo 0x03D70FF0 1 > $DCC_PATH/config
    echo 0x03D70FF4 1 > $DCC_PATH/config
    echo 0x03D70FF8 1 > $DCC_PATH/config
    echo 0x03D70FFC 1 > $DCC_PATH/config
    echo 0x03D71000 1 > $DCC_PATH/config     # Dumping DTCM: 0x3d71000, size: 0x4 1 > $DCC_PATH/config000 bytes
    echo 0x03D71004 1 > $DCC_PATH/config
    echo 0x03D71008 1 > $DCC_PATH/config
    echo 0x03D7100C 1 > $DCC_PATH/config
    echo 0x03D71010 1 > $DCC_PATH/config
    echo 0x03D71014 1 > $DCC_PATH/config
    echo 0x03D71018 1 > $DCC_PATH/config
    echo 0x03D7101C 1 > $DCC_PATH/config
    echo 0x03D71020 1 > $DCC_PATH/config
    echo 0x03D71024 1 > $DCC_PATH/config
    echo 0x03D71028 1 > $DCC_PATH/config
    echo 0x03D7102C 1 > $DCC_PATH/config
    echo 0x03D71030 1 > $DCC_PATH/config
    echo 0x03D71034 1 > $DCC_PATH/config
    echo 0x03D71038 1 > $DCC_PATH/config
    echo 0x03D7103C 1 > $DCC_PATH/config
    echo 0x03D71040 1 > $DCC_PATH/config
    echo 0x03D71044 1 > $DCC_PATH/config
    echo 0x03D71048 1 > $DCC_PATH/config
    echo 0x03D7104C 1 > $DCC_PATH/config
    echo 0x03D71050 1 > $DCC_PATH/config
    echo 0x03D71054 1 > $DCC_PATH/config
    echo 0x03D71058 1 > $DCC_PATH/config
    echo 0x03D7105C 1 > $DCC_PATH/config
    echo 0x03D71060 1 > $DCC_PATH/config
    echo 0x03D71064 1 > $DCC_PATH/config
    echo 0x03D71068 1 > $DCC_PATH/config
    echo 0x03D7106C 1 > $DCC_PATH/config
    echo 0x03D71070 1 > $DCC_PATH/config
    echo 0x03D71074 1 > $DCC_PATH/config
    echo 0x03D71078 1 > $DCC_PATH/config
    echo 0x03D7107C 1 > $DCC_PATH/config
    echo 0x03D71080 1 > $DCC_PATH/config
    echo 0x03D71084 1 > $DCC_PATH/config
    echo 0x03D71088 1 > $DCC_PATH/config
    echo 0x03D7108C 1 > $DCC_PATH/config
    echo 0x03D71090 1 > $DCC_PATH/config
    echo 0x03D71094 1 > $DCC_PATH/config
    echo 0x03D71098 1 > $DCC_PATH/config
    echo 0x03D7109C 1 > $DCC_PATH/config
    echo 0x03D710A0 1 > $DCC_PATH/config
    echo 0x03D710A4 1 > $DCC_PATH/config
    echo 0x03D710A8 1 > $DCC_PATH/config
    echo 0x03D710AC 1 > $DCC_PATH/config
    echo 0x03D710B0 1 > $DCC_PATH/config
    echo 0x03D710B4 1 > $DCC_PATH/config
    echo 0x03D710B8 1 > $DCC_PATH/config
    echo 0x03D710BC 1 > $DCC_PATH/config
    echo 0x03D710C0 1 > $DCC_PATH/config
    echo 0x03D710C4 1 > $DCC_PATH/config
    echo 0x03D710C8 1 > $DCC_PATH/config
    echo 0x03D710CC 1 > $DCC_PATH/config
    echo 0x03D710D0 1 > $DCC_PATH/config
    echo 0x03D710D4 1 > $DCC_PATH/config
    echo 0x03D710D8 1 > $DCC_PATH/config
    echo 0x03D710DC 1 > $DCC_PATH/config
    echo 0x03D710E0 1 > $DCC_PATH/config
    echo 0x03D710E4 1 > $DCC_PATH/config
    echo 0x03D710E8 1 > $DCC_PATH/config
    echo 0x03D710EC 1 > $DCC_PATH/config
    echo 0x03D710F0 1 > $DCC_PATH/config
    echo 0x03D710F4 1 > $DCC_PATH/config
    echo 0x03D710F8 1 > $DCC_PATH/config
    echo 0x03D710FC 1 > $DCC_PATH/config
    echo 0x03D71100 1 > $DCC_PATH/config
    echo 0x03D71104 1 > $DCC_PATH/config
    echo 0x03D71108 1 > $DCC_PATH/config
    echo 0x03D7110C 1 > $DCC_PATH/config
    echo 0x03D71110 1 > $DCC_PATH/config
    echo 0x03D71114 1 > $DCC_PATH/config
    echo 0x03D71118 1 > $DCC_PATH/config
    echo 0x03D7111C 1 > $DCC_PATH/config
    echo 0x03D71120 1 > $DCC_PATH/config
    echo 0x03D71124 1 > $DCC_PATH/config
    echo 0x03D71128 1 > $DCC_PATH/config
    echo 0x03D7112C 1 > $DCC_PATH/config
    echo 0x03D71130 1 > $DCC_PATH/config
    echo 0x03D71134 1 > $DCC_PATH/config
    echo 0x03D71138 1 > $DCC_PATH/config
    echo 0x03D7113C 1 > $DCC_PATH/config
    echo 0x03D71140 1 > $DCC_PATH/config
    echo 0x03D71144 1 > $DCC_PATH/config
    echo 0x03D71148 1 > $DCC_PATH/config
    echo 0x03D7114C 1 > $DCC_PATH/config
    echo 0x03D71150 1 > $DCC_PATH/config
    echo 0x03D71154 1 > $DCC_PATH/config
    echo 0x03D71158 1 > $DCC_PATH/config
    echo 0x03D7115C 1 > $DCC_PATH/config
    echo 0x03D71160 1 > $DCC_PATH/config
    echo 0x03D71164 1 > $DCC_PATH/config
    echo 0x03D71168 1 > $DCC_PATH/config
    echo 0x03D7116C 1 > $DCC_PATH/config
    echo 0x03D71170 1 > $DCC_PATH/config
    echo 0x03D71174 1 > $DCC_PATH/config
    echo 0x03D71178 1 > $DCC_PATH/config
    echo 0x03D7117C 1 > $DCC_PATH/config
    echo 0x03D71180 1 > $DCC_PATH/config
    echo 0x03D71184 1 > $DCC_PATH/config
    echo 0x03D71188 1 > $DCC_PATH/config
    echo 0x03D7118C 1 > $DCC_PATH/config
    echo 0x03D71190 1 > $DCC_PATH/config
    echo 0x03D71194 1 > $DCC_PATH/config
    echo 0x03D71198 1 > $DCC_PATH/config
    echo 0x03D7119C 1 > $DCC_PATH/config
    echo 0x03D711A0 1 > $DCC_PATH/config
    echo 0x03D711A4 1 > $DCC_PATH/config
    echo 0x03D711A8 1 > $DCC_PATH/config
    echo 0x03D711AC 1 > $DCC_PATH/config
    echo 0x03D711B0 1 > $DCC_PATH/config
    echo 0x03D711B4 1 > $DCC_PATH/config
    echo 0x03D711B8 1 > $DCC_PATH/config
    echo 0x03D711BC 1 > $DCC_PATH/config
    echo 0x03D711C0 1 > $DCC_PATH/config
    echo 0x03D711C4 1 > $DCC_PATH/config
    echo 0x03D711C8 1 > $DCC_PATH/config
    echo 0x03D711CC 1 > $DCC_PATH/config
    echo 0x03D711D0 1 > $DCC_PATH/config
    echo 0x03D711D4 1 > $DCC_PATH/config
    echo 0x03D711D8 1 > $DCC_PATH/config
    echo 0x03D711DC 1 > $DCC_PATH/config
    echo 0x03D711E0 1 > $DCC_PATH/config
    echo 0x03D711E4 1 > $DCC_PATH/config
    echo 0x03D711E8 1 > $DCC_PATH/config
    echo 0x03D711EC 1 > $DCC_PATH/config
    echo 0x03D711F0 1 > $DCC_PATH/config
    echo 0x03D711F4 1 > $DCC_PATH/config
    echo 0x03D711F8 1 > $DCC_PATH/config
    echo 0x03D711FC 1 > $DCC_PATH/config
    echo 0x03D71200 1 > $DCC_PATH/config
    echo 0x03D71204 1 > $DCC_PATH/config
    echo 0x03D71208 1 > $DCC_PATH/config
    echo 0x03D7120C 1 > $DCC_PATH/config
    echo 0x03D71210 1 > $DCC_PATH/config
    echo 0x03D71214 1 > $DCC_PATH/config
    echo 0x03D71218 1 > $DCC_PATH/config
    echo 0x03D7121C 1 > $DCC_PATH/config
    echo 0x03D71220 1 > $DCC_PATH/config
    echo 0x03D71224 1 > $DCC_PATH/config
    echo 0x03D71228 1 > $DCC_PATH/config
    echo 0x03D7122C 1 > $DCC_PATH/config
    echo 0x03D71230 1 > $DCC_PATH/config
    echo 0x03D71234 1 > $DCC_PATH/config
    echo 0x03D71238 1 > $DCC_PATH/config
    echo 0x03D7123C 1 > $DCC_PATH/config
    echo 0x03D71240 1 > $DCC_PATH/config
    echo 0x03D71244 1 > $DCC_PATH/config
    echo 0x03D71248 1 > $DCC_PATH/config
    echo 0x03D7124C 1 > $DCC_PATH/config
    echo 0x03D71250 1 > $DCC_PATH/config
    echo 0x03D71254 1 > $DCC_PATH/config
    echo 0x03D71258 1 > $DCC_PATH/config
    echo 0x03D7125C 1 > $DCC_PATH/config
    echo 0x03D71260 1 > $DCC_PATH/config
    echo 0x03D71264 1 > $DCC_PATH/config
    echo 0x03D71268 1 > $DCC_PATH/config
    echo 0x03D7126C 1 > $DCC_PATH/config
    echo 0x03D71270 1 > $DCC_PATH/config
    echo 0x03D71274 1 > $DCC_PATH/config
    echo 0x03D71278 1 > $DCC_PATH/config
    echo 0x03D7127C 1 > $DCC_PATH/config
    echo 0x03D71280 1 > $DCC_PATH/config
    echo 0x03D71284 1 > $DCC_PATH/config
    echo 0x03D71288 1 > $DCC_PATH/config
    echo 0x03D7128C 1 > $DCC_PATH/config
    echo 0x03D71290 1 > $DCC_PATH/config
    echo 0x03D71294 1 > $DCC_PATH/config
    echo 0x03D71298 1 > $DCC_PATH/config
    echo 0x03D7129C 1 > $DCC_PATH/config
    echo 0x03D712A0 1 > $DCC_PATH/config
    echo 0x03D712A4 1 > $DCC_PATH/config
    echo 0x03D712A8 1 > $DCC_PATH/config
    echo 0x03D712AC 1 > $DCC_PATH/config
    echo 0x03D712B0 1 > $DCC_PATH/config
    echo 0x03D712B4 1 > $DCC_PATH/config
    echo 0x03D712B8 1 > $DCC_PATH/config
    echo 0x03D712BC 1 > $DCC_PATH/config
    echo 0x03D712C0 1 > $DCC_PATH/config
    echo 0x03D712C4 1 > $DCC_PATH/config
    echo 0x03D712C8 1 > $DCC_PATH/config
    echo 0x03D712CC 1 > $DCC_PATH/config
    echo 0x03D712D0 1 > $DCC_PATH/config
    echo 0x03D712D4 1 > $DCC_PATH/config
    echo 0x03D712D8 1 > $DCC_PATH/config
    echo 0x03D712DC 1 > $DCC_PATH/config
    echo 0x03D712E0 1 > $DCC_PATH/config
    echo 0x03D712E4 1 > $DCC_PATH/config
    echo 0x03D712E8 1 > $DCC_PATH/config
    echo 0x03D712EC 1 > $DCC_PATH/config
    echo 0x03D712F0 1 > $DCC_PATH/config
    echo 0x03D712F4 1 > $DCC_PATH/config
    echo 0x03D712F8 1 > $DCC_PATH/config
    echo 0x03D712FC 1 > $DCC_PATH/config
    echo 0x03D71300 1 > $DCC_PATH/config
    echo 0x03D71304 1 > $DCC_PATH/config
    echo 0x03D71308 1 > $DCC_PATH/config
    echo 0x03D7130C 1 > $DCC_PATH/config
    echo 0x03D71310 1 > $DCC_PATH/config
    echo 0x03D71314 1 > $DCC_PATH/config
    echo 0x03D71318 1 > $DCC_PATH/config
    echo 0x03D7131C 1 > $DCC_PATH/config
    echo 0x03D71320 1 > $DCC_PATH/config
    echo 0x03D71324 1 > $DCC_PATH/config
    echo 0x03D71328 1 > $DCC_PATH/config
    echo 0x03D7132C 1 > $DCC_PATH/config
    echo 0x03D71330 1 > $DCC_PATH/config
    echo 0x03D71334 1 > $DCC_PATH/config
    echo 0x03D71338 1 > $DCC_PATH/config
    echo 0x03D7133C 1 > $DCC_PATH/config
    echo 0x03D71340 1 > $DCC_PATH/config
    echo 0x03D71344 1 > $DCC_PATH/config
    echo 0x03D71348 1 > $DCC_PATH/config
    echo 0x03D7134C 1 > $DCC_PATH/config
    echo 0x03D71350 1 > $DCC_PATH/config
    echo 0x03D71354 1 > $DCC_PATH/config
    echo 0x03D71358 1 > $DCC_PATH/config
    echo 0x03D7135C 1 > $DCC_PATH/config
    echo 0x03D71360 1 > $DCC_PATH/config
    echo 0x03D71364 1 > $DCC_PATH/config
    echo 0x03D71368 1 > $DCC_PATH/config
    echo 0x03D7136C 1 > $DCC_PATH/config
    echo 0x03D71370 1 > $DCC_PATH/config
    echo 0x03D71374 1 > $DCC_PATH/config
    echo 0x03D71378 1 > $DCC_PATH/config
    echo 0x03D7137C 1 > $DCC_PATH/config
    echo 0x03D71380 1 > $DCC_PATH/config
    echo 0x03D71384 1 > $DCC_PATH/config
    echo 0x03D71388 1 > $DCC_PATH/config
    echo 0x03D7138C 1 > $DCC_PATH/config
    echo 0x03D71390 1 > $DCC_PATH/config
    echo 0x03D71394 1 > $DCC_PATH/config
    echo 0x03D71398 1 > $DCC_PATH/config
    echo 0x03D7139C 1 > $DCC_PATH/config
    echo 0x03D713A0 1 > $DCC_PATH/config
    echo 0x03D713A4 1 > $DCC_PATH/config
    echo 0x03D713A8 1 > $DCC_PATH/config
    echo 0x03D713AC 1 > $DCC_PATH/config
    echo 0x03D713B0 1 > $DCC_PATH/config
    echo 0x03D713B4 1 > $DCC_PATH/config
    echo 0x03D713B8 1 > $DCC_PATH/config
    echo 0x03D713BC 1 > $DCC_PATH/config
    echo 0x03D713C0 1 > $DCC_PATH/config
    echo 0x03D713C4 1 > $DCC_PATH/config
    echo 0x03D713C8 1 > $DCC_PATH/config
    echo 0x03D713CC 1 > $DCC_PATH/config
    echo 0x03D713D0 1 > $DCC_PATH/config
    echo 0x03D713D4 1 > $DCC_PATH/config
    echo 0x03D713D8 1 > $DCC_PATH/config
    echo 0x03D713DC 1 > $DCC_PATH/config
    echo 0x03D713E0 1 > $DCC_PATH/config
    echo 0x03D713E4 1 > $DCC_PATH/config
    echo 0x03D713E8 1 > $DCC_PATH/config
    echo 0x03D713EC 1 > $DCC_PATH/config
    echo 0x03D713F0 1 > $DCC_PATH/config
    echo 0x03D713F4 1 > $DCC_PATH/config
    echo 0x03D713F8 1 > $DCC_PATH/config
    echo 0x03D713FC 1 > $DCC_PATH/config
    echo 0x03D71400 1 > $DCC_PATH/config
    echo 0x03D71404 1 > $DCC_PATH/config
    echo 0x03D71408 1 > $DCC_PATH/config
    echo 0x03D7140C 1 > $DCC_PATH/config
    echo 0x03D71410 1 > $DCC_PATH/config
    echo 0x03D71414 1 > $DCC_PATH/config
    echo 0x03D71418 1 > $DCC_PATH/config
    echo 0x03D7141C 1 > $DCC_PATH/config
    echo 0x03D71420 1 > $DCC_PATH/config
    echo 0x03D71424 1 > $DCC_PATH/config
    echo 0x03D71428 1 > $DCC_PATH/config
    echo 0x03D7142C 1 > $DCC_PATH/config
    echo 0x03D71430 1 > $DCC_PATH/config
    echo 0x03D71434 1 > $DCC_PATH/config
    echo 0x03D71438 1 > $DCC_PATH/config
    echo 0x03D7143C 1 > $DCC_PATH/config
    echo 0x03D71440 1 > $DCC_PATH/config
    echo 0x03D71444 1 > $DCC_PATH/config
    echo 0x03D71448 1 > $DCC_PATH/config
    echo 0x03D7144C 1 > $DCC_PATH/config
    echo 0x03D71450 1 > $DCC_PATH/config
    echo 0x03D71454 1 > $DCC_PATH/config
    echo 0x03D71458 1 > $DCC_PATH/config
    echo 0x03D7145C 1 > $DCC_PATH/config
    echo 0x03D71460 1 > $DCC_PATH/config
    echo 0x03D71464 1 > $DCC_PATH/config
    echo 0x03D71468 1 > $DCC_PATH/config
    echo 0x03D7146C 1 > $DCC_PATH/config
    echo 0x03D71470 1 > $DCC_PATH/config
    echo 0x03D71474 1 > $DCC_PATH/config
    echo 0x03D71478 1 > $DCC_PATH/config
    echo 0x03D7147C 1 > $DCC_PATH/config
    echo 0x03D71480 1 > $DCC_PATH/config
    echo 0x03D71484 1 > $DCC_PATH/config
    echo 0x03D71488 1 > $DCC_PATH/config
    echo 0x03D7148C 1 > $DCC_PATH/config
    echo 0x03D71490 1 > $DCC_PATH/config
    echo 0x03D71494 1 > $DCC_PATH/config
    echo 0x03D71498 1 > $DCC_PATH/config
    echo 0x03D7149C 1 > $DCC_PATH/config
    echo 0x03D714A0 1 > $DCC_PATH/config
    echo 0x03D714A4 1 > $DCC_PATH/config
    echo 0x03D714A8 1 > $DCC_PATH/config
    echo 0x03D714AC 1 > $DCC_PATH/config
    echo 0x03D714B0 1 > $DCC_PATH/config
    echo 0x03D714B4 1 > $DCC_PATH/config
    echo 0x03D714B8 1 > $DCC_PATH/config
    echo 0x03D714BC 1 > $DCC_PATH/config
    echo 0x03D714C0 1 > $DCC_PATH/config
    echo 0x03D714C4 1 > $DCC_PATH/config
    echo 0x03D714C8 1 > $DCC_PATH/config
    echo 0x03D714CC 1 > $DCC_PATH/config
    echo 0x03D714D0 1 > $DCC_PATH/config
    echo 0x03D714D4 1 > $DCC_PATH/config
    echo 0x03D714D8 1 > $DCC_PATH/config
    echo 0x03D714DC 1 > $DCC_PATH/config
    echo 0x03D714E0 1 > $DCC_PATH/config
    echo 0x03D714E4 1 > $DCC_PATH/config
    echo 0x03D714E8 1 > $DCC_PATH/config
    echo 0x03D714EC 1 > $DCC_PATH/config
    echo 0x03D714F0 1 > $DCC_PATH/config
    echo 0x03D714F4 1 > $DCC_PATH/config
    echo 0x03D714F8 1 > $DCC_PATH/config
    echo 0x03D714FC 1 > $DCC_PATH/config
    echo 0x03D71500 1 > $DCC_PATH/config
    echo 0x03D71504 1 > $DCC_PATH/config
    echo 0x03D71508 1 > $DCC_PATH/config
    echo 0x03D7150C 1 > $DCC_PATH/config
    echo 0x03D71510 1 > $DCC_PATH/config
    echo 0x03D71514 1 > $DCC_PATH/config
    echo 0x03D71518 1 > $DCC_PATH/config
    echo 0x03D7151C 1 > $DCC_PATH/config
    echo 0x03D71520 1 > $DCC_PATH/config
    echo 0x03D71524 1 > $DCC_PATH/config
    echo 0x03D71528 1 > $DCC_PATH/config
    echo 0x03D7152C 1 > $DCC_PATH/config
    echo 0x03D71530 1 > $DCC_PATH/config
    echo 0x03D71534 1 > $DCC_PATH/config
    echo 0x03D71538 1 > $DCC_PATH/config
    echo 0x03D7153C 1 > $DCC_PATH/config
    echo 0x03D71540 1 > $DCC_PATH/config
    echo 0x03D71544 1 > $DCC_PATH/config
    echo 0x03D71548 1 > $DCC_PATH/config
    echo 0x03D7154C 1 > $DCC_PATH/config
    echo 0x03D71550 1 > $DCC_PATH/config
    echo 0x03D71554 1 > $DCC_PATH/config
    echo 0x03D71558 1 > $DCC_PATH/config
    echo 0x03D7155C 1 > $DCC_PATH/config
    echo 0x03D71560 1 > $DCC_PATH/config
    echo 0x03D71564 1 > $DCC_PATH/config
    echo 0x03D71568 1 > $DCC_PATH/config
    echo 0x03D7156C 1 > $DCC_PATH/config
    echo 0x03D71570 1 > $DCC_PATH/config
    echo 0x03D71574 1 > $DCC_PATH/config
    echo 0x03D71578 1 > $DCC_PATH/config
    echo 0x03D7157C 1 > $DCC_PATH/config
    echo 0x03D71580 1 > $DCC_PATH/config
    echo 0x03D71584 1 > $DCC_PATH/config
    echo 0x03D71588 1 > $DCC_PATH/config
    echo 0x03D7158C 1 > $DCC_PATH/config
    echo 0x03D71590 1 > $DCC_PATH/config
    echo 0x03D71594 1 > $DCC_PATH/config
    echo 0x03D71598 1 > $DCC_PATH/config
    echo 0x03D7159C 1 > $DCC_PATH/config
    echo 0x03D715A0 1 > $DCC_PATH/config
    echo 0x03D715A4 1 > $DCC_PATH/config
    echo 0x03D715A8 1 > $DCC_PATH/config
    echo 0x03D715AC 1 > $DCC_PATH/config
    echo 0x03D715B0 1 > $DCC_PATH/config
    echo 0x03D715B4 1 > $DCC_PATH/config
    echo 0x03D715B8 1 > $DCC_PATH/config
    echo 0x03D715BC 1 > $DCC_PATH/config
    echo 0x03D715C0 1 > $DCC_PATH/config
    echo 0x03D715C4 1 > $DCC_PATH/config
    echo 0x03D715C8 1 > $DCC_PATH/config
    echo 0x03D715CC 1 > $DCC_PATH/config
    echo 0x03D715D0 1 > $DCC_PATH/config
    echo 0x03D715D4 1 > $DCC_PATH/config
    echo 0x03D715D8 1 > $DCC_PATH/config
    echo 0x03D715DC 1 > $DCC_PATH/config
    echo 0x03D715E0 1 > $DCC_PATH/config
    echo 0x03D715E4 1 > $DCC_PATH/config
    echo 0x03D715E8 1 > $DCC_PATH/config
    echo 0x03D715EC 1 > $DCC_PATH/config
    echo 0x03D715F0 1 > $DCC_PATH/config
    echo 0x03D715F4 1 > $DCC_PATH/config
    echo 0x03D715F8 1 > $DCC_PATH/config
    echo 0x03D715FC 1 > $DCC_PATH/config
    echo 0x03D71600 1 > $DCC_PATH/config
    echo 0x03D71604 1 > $DCC_PATH/config
    echo 0x03D71608 1 > $DCC_PATH/config
    echo 0x03D7160C 1 > $DCC_PATH/config
    echo 0x03D71610 1 > $DCC_PATH/config
    echo 0x03D71614 1 > $DCC_PATH/config
    echo 0x03D71618 1 > $DCC_PATH/config
    echo 0x03D7161C 1 > $DCC_PATH/config
    echo 0x03D71620 1 > $DCC_PATH/config
    echo 0x03D71624 1 > $DCC_PATH/config
    echo 0x03D71628 1 > $DCC_PATH/config
    echo 0x03D7162C 1 > $DCC_PATH/config
    echo 0x03D71630 1 > $DCC_PATH/config
    echo 0x03D71634 1 > $DCC_PATH/config
    echo 0x03D71638 1 > $DCC_PATH/config
    echo 0x03D7163C 1 > $DCC_PATH/config
    echo 0x03D71640 1 > $DCC_PATH/config
    echo 0x03D71644 1 > $DCC_PATH/config
    echo 0x03D71648 1 > $DCC_PATH/config
    echo 0x03D7164C 1 > $DCC_PATH/config
    echo 0x03D71650 1 > $DCC_PATH/config
    echo 0x03D71654 1 > $DCC_PATH/config
    echo 0x03D71658 1 > $DCC_PATH/config
    echo 0x03D7165C 1 > $DCC_PATH/config
    echo 0x03D71660 1 > $DCC_PATH/config
    echo 0x03D71664 1 > $DCC_PATH/config
    echo 0x03D71668 1 > $DCC_PATH/config
    echo 0x03D7166C 1 > $DCC_PATH/config
    echo 0x03D71670 1 > $DCC_PATH/config
    echo 0x03D71674 1 > $DCC_PATH/config
    echo 0x03D71678 1 > $DCC_PATH/config
    echo 0x03D7167C 1 > $DCC_PATH/config
    echo 0x03D71680 1 > $DCC_PATH/config
    echo 0x03D71684 1 > $DCC_PATH/config
    echo 0x03D71688 1 > $DCC_PATH/config
    echo 0x03D7168C 1 > $DCC_PATH/config
    echo 0x03D71690 1 > $DCC_PATH/config
    echo 0x03D71694 1 > $DCC_PATH/config
    echo 0x03D71698 1 > $DCC_PATH/config
    echo 0x03D7169C 1 > $DCC_PATH/config
    echo 0x03D716A0 1 > $DCC_PATH/config
    echo 0x03D716A4 1 > $DCC_PATH/config
    echo 0x03D716A8 1 > $DCC_PATH/config
    echo 0x03D716AC 1 > $DCC_PATH/config
    echo 0x03D716B0 1 > $DCC_PATH/config
    echo 0x03D716B4 1 > $DCC_PATH/config
    echo 0x03D716B8 1 > $DCC_PATH/config
    echo 0x03D716BC 1 > $DCC_PATH/config
    echo 0x03D716C0 1 > $DCC_PATH/config
    echo 0x03D716C4 1 > $DCC_PATH/config
    echo 0x03D716C8 1 > $DCC_PATH/config
    echo 0x03D716CC 1 > $DCC_PATH/config
    echo 0x03D716D0 1 > $DCC_PATH/config
    echo 0x03D716D4 1 > $DCC_PATH/config
    echo 0x03D716D8 1 > $DCC_PATH/config
    echo 0x03D716DC 1 > $DCC_PATH/config
    echo 0x03D716E0 1 > $DCC_PATH/config
    echo 0x03D716E4 1 > $DCC_PATH/config
    echo 0x03D716E8 1 > $DCC_PATH/config
    echo 0x03D716EC 1 > $DCC_PATH/config
    echo 0x03D716F0 1 > $DCC_PATH/config
    echo 0x03D716F4 1 > $DCC_PATH/config
    echo 0x03D716F8 1 > $DCC_PATH/config
    echo 0x03D716FC 1 > $DCC_PATH/config
    echo 0x03D71700 1 > $DCC_PATH/config
    echo 0x03D71704 1 > $DCC_PATH/config
    echo 0x03D71708 1 > $DCC_PATH/config
    echo 0x03D7170C 1 > $DCC_PATH/config
    echo 0x03D71710 1 > $DCC_PATH/config
    echo 0x03D71714 1 > $DCC_PATH/config
    echo 0x03D71718 1 > $DCC_PATH/config
    echo 0x03D7171C 1 > $DCC_PATH/config
    echo 0x03D71720 1 > $DCC_PATH/config
    echo 0x03D71724 1 > $DCC_PATH/config
    echo 0x03D71728 1 > $DCC_PATH/config
    echo 0x03D7172C 1 > $DCC_PATH/config
    echo 0x03D71730 1 > $DCC_PATH/config
    echo 0x03D71734 1 > $DCC_PATH/config
    echo 0x03D71738 1 > $DCC_PATH/config
    echo 0x03D7173C 1 > $DCC_PATH/config
    echo 0x03D71740 1 > $DCC_PATH/config
    echo 0x03D71744 1 > $DCC_PATH/config
    echo 0x03D71748 1 > $DCC_PATH/config
    echo 0x03D7174C 1 > $DCC_PATH/config
    echo 0x03D71750 1 > $DCC_PATH/config
    echo 0x03D71754 1 > $DCC_PATH/config
    echo 0x03D71758 1 > $DCC_PATH/config
    echo 0x03D7175C 1 > $DCC_PATH/config
    echo 0x03D71760 1 > $DCC_PATH/config
    echo 0x03D71764 1 > $DCC_PATH/config
    echo 0x03D71768 1 > $DCC_PATH/config
    echo 0x03D7176C 1 > $DCC_PATH/config
    echo 0x03D71770 1 > $DCC_PATH/config
    echo 0x03D71774 1 > $DCC_PATH/config
    echo 0x03D71778 1 > $DCC_PATH/config
    echo 0x03D7177C 1 > $DCC_PATH/config
    echo 0x03D71780 1 > $DCC_PATH/config
    echo 0x03D71784 1 > $DCC_PATH/config
    echo 0x03D71788 1 > $DCC_PATH/config
    echo 0x03D7178C 1 > $DCC_PATH/config
    echo 0x03D71790 1 > $DCC_PATH/config
    echo 0x03D71794 1 > $DCC_PATH/config
    echo 0x03D71798 1 > $DCC_PATH/config
    echo 0x03D7179C 1 > $DCC_PATH/config
    echo 0x03D717A0 1 > $DCC_PATH/config
    echo 0x03D717A4 1 > $DCC_PATH/config
    echo 0x03D717A8 1 > $DCC_PATH/config
    echo 0x03D717AC 1 > $DCC_PATH/config
    echo 0x03D717B0 1 > $DCC_PATH/config
    echo 0x03D717B4 1 > $DCC_PATH/config
    echo 0x03D717B8 1 > $DCC_PATH/config
    echo 0x03D717BC 1 > $DCC_PATH/config
    echo 0x03D717C0 1 > $DCC_PATH/config
    echo 0x03D717C4 1 > $DCC_PATH/config
    echo 0x03D717C8 1 > $DCC_PATH/config
    echo 0x03D717CC 1 > $DCC_PATH/config
    echo 0x03D717D0 1 > $DCC_PATH/config
    echo 0x03D717D4 1 > $DCC_PATH/config
    echo 0x03D717D8 1 > $DCC_PATH/config
    echo 0x03D717DC 1 > $DCC_PATH/config
    echo 0x03D717E0 1 > $DCC_PATH/config
    echo 0x03D717E4 1 > $DCC_PATH/config
    echo 0x03D717E8 1 > $DCC_PATH/config
    echo 0x03D717EC 1 > $DCC_PATH/config
    echo 0x03D717F0 1 > $DCC_PATH/config
    echo 0x03D717F4 1 > $DCC_PATH/config
    echo 0x03D717F8 1 > $DCC_PATH/config
    echo 0x03D717FC 1 > $DCC_PATH/config
    echo 0x03D71800 1 > $DCC_PATH/config
    echo 0x03D71804 1 > $DCC_PATH/config
    echo 0x03D71808 1 > $DCC_PATH/config
    echo 0x03D7180C 1 > $DCC_PATH/config
    echo 0x03D71810 1 > $DCC_PATH/config
    echo 0x03D71814 1 > $DCC_PATH/config
    echo 0x03D71818 1 > $DCC_PATH/config
    echo 0x03D7181C 1 > $DCC_PATH/config
    echo 0x03D71820 1 > $DCC_PATH/config
    echo 0x03D71824 1 > $DCC_PATH/config
    echo 0x03D71828 1 > $DCC_PATH/config
    echo 0x03D7182C 1 > $DCC_PATH/config
    echo 0x03D71830 1 > $DCC_PATH/config
    echo 0x03D71834 1 > $DCC_PATH/config
    echo 0x03D71838 1 > $DCC_PATH/config
    echo 0x03D7183C 1 > $DCC_PATH/config
    echo 0x03D71840 1 > $DCC_PATH/config
    echo 0x03D71844 1 > $DCC_PATH/config
    echo 0x03D71848 1 > $DCC_PATH/config
    echo 0x03D7184C 1 > $DCC_PATH/config
    echo 0x03D71850 1 > $DCC_PATH/config
    echo 0x03D71854 1 > $DCC_PATH/config
    echo 0x03D71858 1 > $DCC_PATH/config
    echo 0x03D7185C 1 > $DCC_PATH/config
    echo 0x03D71860 1 > $DCC_PATH/config
    echo 0x03D71864 1 > $DCC_PATH/config
    echo 0x03D71868 1 > $DCC_PATH/config
    echo 0x03D7186C 1 > $DCC_PATH/config
    echo 0x03D71870 1 > $DCC_PATH/config
    echo 0x03D71874 1 > $DCC_PATH/config
    echo 0x03D71878 1 > $DCC_PATH/config
    echo 0x03D7187C 1 > $DCC_PATH/config
    echo 0x03D71880 1 > $DCC_PATH/config
    echo 0x03D71884 1 > $DCC_PATH/config
    echo 0x03D71888 1 > $DCC_PATH/config
    echo 0x03D7188C 1 > $DCC_PATH/config
    echo 0x03D71890 1 > $DCC_PATH/config
    echo 0x03D71894 1 > $DCC_PATH/config
    echo 0x03D71898 1 > $DCC_PATH/config
    echo 0x03D7189C 1 > $DCC_PATH/config
    echo 0x03D718A0 1 > $DCC_PATH/config
    echo 0x03D718A4 1 > $DCC_PATH/config
    echo 0x03D718A8 1 > $DCC_PATH/config
    echo 0x03D718AC 1 > $DCC_PATH/config
    echo 0x03D718B0 1 > $DCC_PATH/config
    echo 0x03D718B4 1 > $DCC_PATH/config
    echo 0x03D718B8 1 > $DCC_PATH/config
    echo 0x03D718BC 1 > $DCC_PATH/config
    echo 0x03D718C0 1 > $DCC_PATH/config
    echo 0x03D718C4 1 > $DCC_PATH/config
    echo 0x03D718C8 1 > $DCC_PATH/config
    echo 0x03D718CC 1 > $DCC_PATH/config
    echo 0x03D718D0 1 > $DCC_PATH/config
    echo 0x03D718D4 1 > $DCC_PATH/config
    echo 0x03D718D8 1 > $DCC_PATH/config
    echo 0x03D718DC 1 > $DCC_PATH/config
    echo 0x03D718E0 1 > $DCC_PATH/config
    echo 0x03D718E4 1 > $DCC_PATH/config
    echo 0x03D718E8 1 > $DCC_PATH/config
    echo 0x03D718EC 1 > $DCC_PATH/config
    echo 0x03D718F0 1 > $DCC_PATH/config
    echo 0x03D718F4 1 > $DCC_PATH/config
    echo 0x03D718F8 1 > $DCC_PATH/config
    echo 0x03D718FC 1 > $DCC_PATH/config
    echo 0x03D71900 1 > $DCC_PATH/config
    echo 0x03D71904 1 > $DCC_PATH/config
    echo 0x03D71908 1 > $DCC_PATH/config
    echo 0x03D7190C 1 > $DCC_PATH/config
    echo 0x03D71910 1 > $DCC_PATH/config
    echo 0x03D71914 1 > $DCC_PATH/config
    echo 0x03D71918 1 > $DCC_PATH/config
    echo 0x03D7191C 1 > $DCC_PATH/config
    echo 0x03D71920 1 > $DCC_PATH/config
    echo 0x03D71924 1 > $DCC_PATH/config
    echo 0x03D71928 1 > $DCC_PATH/config
    echo 0x03D7192C 1 > $DCC_PATH/config
    echo 0x03D71930 1 > $DCC_PATH/config
    echo 0x03D71934 1 > $DCC_PATH/config
    echo 0x03D71938 1 > $DCC_PATH/config
    echo 0x03D7193C 1 > $DCC_PATH/config
    echo 0x03D71940 1 > $DCC_PATH/config
    echo 0x03D71944 1 > $DCC_PATH/config
    echo 0x03D71948 1 > $DCC_PATH/config
    echo 0x03D7194C 1 > $DCC_PATH/config
    echo 0x03D71950 1 > $DCC_PATH/config
    echo 0x03D71954 1 > $DCC_PATH/config
    echo 0x03D71958 1 > $DCC_PATH/config
    echo 0x03D7195C 1 > $DCC_PATH/config
    echo 0x03D71960 1 > $DCC_PATH/config
    echo 0x03D71964 1 > $DCC_PATH/config
    echo 0x03D71968 1 > $DCC_PATH/config
    echo 0x03D7196C 1 > $DCC_PATH/config
    echo 0x03D71970 1 > $DCC_PATH/config
    echo 0x03D71974 1 > $DCC_PATH/config
    echo 0x03D71978 1 > $DCC_PATH/config
    echo 0x03D7197C 1 > $DCC_PATH/config
    echo 0x03D71980 1 > $DCC_PATH/config
    echo 0x03D71984 1 > $DCC_PATH/config
    echo 0x03D71988 1 > $DCC_PATH/config
    echo 0x03D7198C 1 > $DCC_PATH/config
    echo 0x03D71990 1 > $DCC_PATH/config
    echo 0x03D71994 1 > $DCC_PATH/config
    echo 0x03D71998 1 > $DCC_PATH/config
    echo 0x03D7199C 1 > $DCC_PATH/config
    echo 0x03D719A0 1 > $DCC_PATH/config
    echo 0x03D719A4 1 > $DCC_PATH/config
    echo 0x03D719A8 1 > $DCC_PATH/config
    echo 0x03D719AC 1 > $DCC_PATH/config
    echo 0x03D719B0 1 > $DCC_PATH/config
    echo 0x03D719B4 1 > $DCC_PATH/config
    echo 0x03D719B8 1 > $DCC_PATH/config
    echo 0x03D719BC 1 > $DCC_PATH/config
    echo 0x03D719C0 1 > $DCC_PATH/config
    echo 0x03D719C4 1 > $DCC_PATH/config
    echo 0x03D719C8 1 > $DCC_PATH/config
    echo 0x03D719CC 1 > $DCC_PATH/config
    echo 0x03D719D0 1 > $DCC_PATH/config
    echo 0x03D719D4 1 > $DCC_PATH/config
    echo 0x03D719D8 1 > $DCC_PATH/config
    echo 0x03D719DC 1 > $DCC_PATH/config
    echo 0x03D719E0 1 > $DCC_PATH/config
    echo 0x03D719E4 1 > $DCC_PATH/config
    echo 0x03D719E8 1 > $DCC_PATH/config
    echo 0x03D719EC 1 > $DCC_PATH/config
    echo 0x03D719F0 1 > $DCC_PATH/config
    echo 0x03D719F4 1 > $DCC_PATH/config
    echo 0x03D719F8 1 > $DCC_PATH/config
    echo 0x03D719FC 1 > $DCC_PATH/config
    echo 0x03D71A00 1 > $DCC_PATH/config
    echo 0x03D71A04 1 > $DCC_PATH/config
    echo 0x03D71A08 1 > $DCC_PATH/config
    echo 0x03D71A0C 1 > $DCC_PATH/config
    echo 0x03D71A10 1 > $DCC_PATH/config
    echo 0x03D71A14 1 > $DCC_PATH/config
    echo 0x03D71A18 1 > $DCC_PATH/config
    echo 0x03D71A1C 1 > $DCC_PATH/config
    echo 0x03D71A20 1 > $DCC_PATH/config
    echo 0x03D71A24 1 > $DCC_PATH/config
    echo 0x03D71A28 1 > $DCC_PATH/config
    echo 0x03D71A2C 1 > $DCC_PATH/config
    echo 0x03D71A30 1 > $DCC_PATH/config
    echo 0x03D71A34 1 > $DCC_PATH/config
    echo 0x03D71A38 1 > $DCC_PATH/config
    echo 0x03D71A3C 1 > $DCC_PATH/config
    echo 0x03D71A40 1 > $DCC_PATH/config
    echo 0x03D71A44 1 > $DCC_PATH/config
    echo 0x03D71A48 1 > $DCC_PATH/config
    echo 0x03D71A4C 1 > $DCC_PATH/config
    echo 0x03D71A50 1 > $DCC_PATH/config
    echo 0x03D71A54 1 > $DCC_PATH/config
    echo 0x03D71A58 1 > $DCC_PATH/config
    echo 0x03D71A5C 1 > $DCC_PATH/config
    echo 0x03D71A60 1 > $DCC_PATH/config
    echo 0x03D71A64 1 > $DCC_PATH/config
    echo 0x03D71A68 1 > $DCC_PATH/config
    echo 0x03D71A6C 1 > $DCC_PATH/config
    echo 0x03D71A70 1 > $DCC_PATH/config
    echo 0x03D71A74 1 > $DCC_PATH/config
    echo 0x03D71A78 1 > $DCC_PATH/config
    echo 0x03D71A7C 1 > $DCC_PATH/config
    echo 0x03D71A80 1 > $DCC_PATH/config
    echo 0x03D71A84 1 > $DCC_PATH/config
    echo 0x03D71A88 1 > $DCC_PATH/config
    echo 0x03D71A8C 1 > $DCC_PATH/config
    echo 0x03D71A90 1 > $DCC_PATH/config
    echo 0x03D71A94 1 > $DCC_PATH/config
    echo 0x03D71A98 1 > $DCC_PATH/config
    echo 0x03D71A9C 1 > $DCC_PATH/config
    echo 0x03D71AA0 1 > $DCC_PATH/config
    echo 0x03D71AA4 1 > $DCC_PATH/config
    echo 0x03D71AA8 1 > $DCC_PATH/config
    echo 0x03D71AAC 1 > $DCC_PATH/config
    echo 0x03D71AB0 1 > $DCC_PATH/config
    echo 0x03D71AB4 1 > $DCC_PATH/config
    echo 0x03D71AB8 1 > $DCC_PATH/config
    echo 0x03D71ABC 1 > $DCC_PATH/config
    echo 0x03D71AC0 1 > $DCC_PATH/config
    echo 0x03D71AC4 1 > $DCC_PATH/config
    echo 0x03D71AC8 1 > $DCC_PATH/config
    echo 0x03D71ACC 1 > $DCC_PATH/config
    echo 0x03D71AD0 1 > $DCC_PATH/config
    echo 0x03D71AD4 1 > $DCC_PATH/config
    echo 0x03D71AD8 1 > $DCC_PATH/config
    echo 0x03D71ADC 1 > $DCC_PATH/config
    echo 0x03D71AE0 1 > $DCC_PATH/config
    echo 0x03D71AE4 1 > $DCC_PATH/config
    echo 0x03D71AE8 1 > $DCC_PATH/config
    echo 0x03D71AEC 1 > $DCC_PATH/config
    echo 0x03D71AF0 1 > $DCC_PATH/config
    echo 0x03D71AF4 1 > $DCC_PATH/config
    echo 0x03D71AF8 1 > $DCC_PATH/config
    echo 0x03D71AFC 1 > $DCC_PATH/config
    echo 0x03D71B00 1 > $DCC_PATH/config
    echo 0x03D71B04 1 > $DCC_PATH/config
    echo 0x03D71B08 1 > $DCC_PATH/config
    echo 0x03D71B0C 1 > $DCC_PATH/config
    echo 0x03D71B10 1 > $DCC_PATH/config
    echo 0x03D71B14 1 > $DCC_PATH/config
    echo 0x03D71B18 1 > $DCC_PATH/config
    echo 0x03D71B1C 1 > $DCC_PATH/config
    echo 0x03D71B20 1 > $DCC_PATH/config
    echo 0x03D71B24 1 > $DCC_PATH/config
    echo 0x03D71B28 1 > $DCC_PATH/config
    echo 0x03D71B2C 1 > $DCC_PATH/config
    echo 0x03D71B30 1 > $DCC_PATH/config
    echo 0x03D71B34 1 > $DCC_PATH/config
    echo 0x03D71B38 1 > $DCC_PATH/config
    echo 0x03D71B3C 1 > $DCC_PATH/config
    echo 0x03D71B40 1 > $DCC_PATH/config
    echo 0x03D71B44 1 > $DCC_PATH/config
    echo 0x03D71B48 1 > $DCC_PATH/config
    echo 0x03D71B4C 1 > $DCC_PATH/config
    echo 0x03D71B50 1 > $DCC_PATH/config
    echo 0x03D71B54 1 > $DCC_PATH/config
    echo 0x03D71B58 1 > $DCC_PATH/config
    echo 0x03D71B5C 1 > $DCC_PATH/config
    echo 0x03D71B60 1 > $DCC_PATH/config
    echo 0x03D71B64 1 > $DCC_PATH/config
    echo 0x03D71B68 1 > $DCC_PATH/config
    echo 0x03D71B6C 1 > $DCC_PATH/config
    echo 0x03D71B70 1 > $DCC_PATH/config
    echo 0x03D71B74 1 > $DCC_PATH/config
    echo 0x03D71B78 1 > $DCC_PATH/config
    echo 0x03D71B7C 1 > $DCC_PATH/config
    echo 0x03D71B80 1 > $DCC_PATH/config
    echo 0x03D71B84 1 > $DCC_PATH/config
    echo 0x03D71B88 1 > $DCC_PATH/config
    echo 0x03D71B8C 1 > $DCC_PATH/config
    echo 0x03D71B90 1 > $DCC_PATH/config
    echo 0x03D71B94 1 > $DCC_PATH/config
    echo 0x03D71B98 1 > $DCC_PATH/config
    echo 0x03D71B9C 1 > $DCC_PATH/config
    echo 0x03D71BA0 1 > $DCC_PATH/config
    echo 0x03D71BA4 1 > $DCC_PATH/config
    echo 0x03D71BA8 1 > $DCC_PATH/config
    echo 0x03D71BAC 1 > $DCC_PATH/config
    echo 0x03D71BB0 1 > $DCC_PATH/config
    echo 0x03D71BB4 1 > $DCC_PATH/config
    echo 0x03D71BB8 1 > $DCC_PATH/config
    echo 0x03D71BBC 1 > $DCC_PATH/config
    echo 0x03D71BC0 1 > $DCC_PATH/config
    echo 0x03D71BC4 1 > $DCC_PATH/config
    echo 0x03D71BC8 1 > $DCC_PATH/config
    echo 0x03D71BCC 1 > $DCC_PATH/config
    echo 0x03D71BD0 1 > $DCC_PATH/config
    echo 0x03D71BD4 1 > $DCC_PATH/config
    echo 0x03D71BD8 1 > $DCC_PATH/config
    echo 0x03D71BDC 1 > $DCC_PATH/config
    echo 0x03D71BE0 1 > $DCC_PATH/config
    echo 0x03D71BE4 1 > $DCC_PATH/config
    echo 0x03D71BE8 1 > $DCC_PATH/config
    echo 0x03D71BEC 1 > $DCC_PATH/config
    echo 0x03D71BF0 1 > $DCC_PATH/config
    echo 0x03D71BF4 1 > $DCC_PATH/config
    echo 0x03D71BF8 1 > $DCC_PATH/config
    echo 0x03D71BFC 1 > $DCC_PATH/config
    echo 0x03D71C00 1 > $DCC_PATH/config
    echo 0x03D71C04 1 > $DCC_PATH/config
    echo 0x03D71C08 1 > $DCC_PATH/config
    echo 0x03D71C0C 1 > $DCC_PATH/config
    echo 0x03D71C10 1 > $DCC_PATH/config
    echo 0x03D71C14 1 > $DCC_PATH/config
    echo 0x03D71C18 1 > $DCC_PATH/config
    echo 0x03D71C1C 1 > $DCC_PATH/config
    echo 0x03D71C20 1 > $DCC_PATH/config
    echo 0x03D71C24 1 > $DCC_PATH/config
    echo 0x03D71C28 1 > $DCC_PATH/config
    echo 0x03D71C2C 1 > $DCC_PATH/config
    echo 0x03D71C30 1 > $DCC_PATH/config
    echo 0x03D71C34 1 > $DCC_PATH/config
    echo 0x03D71C38 1 > $DCC_PATH/config
    echo 0x03D71C3C 1 > $DCC_PATH/config
    echo 0x03D71C40 1 > $DCC_PATH/config
    echo 0x03D71C44 1 > $DCC_PATH/config
    echo 0x03D71C48 1 > $DCC_PATH/config
    echo 0x03D71C4C 1 > $DCC_PATH/config
    echo 0x03D71C50 1 > $DCC_PATH/config
    echo 0x03D71C54 1 > $DCC_PATH/config
    echo 0x03D71C58 1 > $DCC_PATH/config
    echo 0x03D71C5C 1 > $DCC_PATH/config
    echo 0x03D71C60 1 > $DCC_PATH/config
    echo 0x03D71C64 1 > $DCC_PATH/config
    echo 0x03D71C68 1 > $DCC_PATH/config
    echo 0x03D71C6C 1 > $DCC_PATH/config
    echo 0x03D71C70 1 > $DCC_PATH/config
    echo 0x03D71C74 1 > $DCC_PATH/config
    echo 0x03D71C78 1 > $DCC_PATH/config
    echo 0x03D71C7C 1 > $DCC_PATH/config
    echo 0x03D71C80 1 > $DCC_PATH/config
    echo 0x03D71C84 1 > $DCC_PATH/config
    echo 0x03D71C88 1 > $DCC_PATH/config
    echo 0x03D71C8C 1 > $DCC_PATH/config
    echo 0x03D71C90 1 > $DCC_PATH/config
    echo 0x03D71C94 1 > $DCC_PATH/config
    echo 0x03D71C98 1 > $DCC_PATH/config
    echo 0x03D71C9C 1 > $DCC_PATH/config
    echo 0x03D71CA0 1 > $DCC_PATH/config
    echo 0x03D71CA4 1 > $DCC_PATH/config
    echo 0x03D71CA8 1 > $DCC_PATH/config
    echo 0x03D71CAC 1 > $DCC_PATH/config
    echo 0x03D71CB0 1 > $DCC_PATH/config
    echo 0x03D71CB4 1 > $DCC_PATH/config
    echo 0x03D71CB8 1 > $DCC_PATH/config
    echo 0x03D71CBC 1 > $DCC_PATH/config
    echo 0x03D71CC0 1 > $DCC_PATH/config
    echo 0x03D71CC4 1 > $DCC_PATH/config
    echo 0x03D71CC8 1 > $DCC_PATH/config
    echo 0x03D71CCC 1 > $DCC_PATH/config
    echo 0x03D71CD0 1 > $DCC_PATH/config
    echo 0x03D71CD4 1 > $DCC_PATH/config
    echo 0x03D71CD8 1 > $DCC_PATH/config
    echo 0x03D71CDC 1 > $DCC_PATH/config
    echo 0x03D71CE0 1 > $DCC_PATH/config
    echo 0x03D71CE4 1 > $DCC_PATH/config
    echo 0x03D71CE8 1 > $DCC_PATH/config
    echo 0x03D71CEC 1 > $DCC_PATH/config
    echo 0x03D71CF0 1 > $DCC_PATH/config
    echo 0x03D71CF4 1 > $DCC_PATH/config
    echo 0x03D71CF8 1 > $DCC_PATH/config
    echo 0x03D71CFC 1 > $DCC_PATH/config
    echo 0x03D71D00 1 > $DCC_PATH/config
    echo 0x03D71D04 1 > $DCC_PATH/config
    echo 0x03D71D08 1 > $DCC_PATH/config
    echo 0x03D71D0C 1 > $DCC_PATH/config
    echo 0x03D71D10 1 > $DCC_PATH/config
    echo 0x03D71D14 1 > $DCC_PATH/config
    echo 0x03D71D18 1 > $DCC_PATH/config
    echo 0x03D71D1C 1 > $DCC_PATH/config
    echo 0x03D71D20 1 > $DCC_PATH/config
    echo 0x03D71D24 1 > $DCC_PATH/config
    echo 0x03D71D28 1 > $DCC_PATH/config
    echo 0x03D71D2C 1 > $DCC_PATH/config
    echo 0x03D71D30 1 > $DCC_PATH/config
    echo 0x03D71D34 1 > $DCC_PATH/config
    echo 0x03D71D38 1 > $DCC_PATH/config
    echo 0x03D71D3C 1 > $DCC_PATH/config
    echo 0x03D71D40 1 > $DCC_PATH/config
    echo 0x03D71D44 1 > $DCC_PATH/config
    echo 0x03D71D48 1 > $DCC_PATH/config
    echo 0x03D71D4C 1 > $DCC_PATH/config
    echo 0x03D71D50 1 > $DCC_PATH/config
    echo 0x03D71D54 1 > $DCC_PATH/config
    echo 0x03D71D58 1 > $DCC_PATH/config
    echo 0x03D71D5C 1 > $DCC_PATH/config
    echo 0x03D71D60 1 > $DCC_PATH/config
    echo 0x03D71D64 1 > $DCC_PATH/config
    echo 0x03D71D68 1 > $DCC_PATH/config
    echo 0x03D71D6C 1 > $DCC_PATH/config
    echo 0x03D71D70 1 > $DCC_PATH/config
    echo 0x03D71D74 1 > $DCC_PATH/config
    echo 0x03D71D78 1 > $DCC_PATH/config
    echo 0x03D71D7C 1 > $DCC_PATH/config
    echo 0x03D71D80 1 > $DCC_PATH/config
    echo 0x03D71D84 1 > $DCC_PATH/config
    echo 0x03D71D88 1 > $DCC_PATH/config
    echo 0x03D71D8C 1 > $DCC_PATH/config
    echo 0x03D71D90 1 > $DCC_PATH/config
    echo 0x03D71D94 1 > $DCC_PATH/config
    echo 0x03D71D98 1 > $DCC_PATH/config
    echo 0x03D71D9C 1 > $DCC_PATH/config
    echo 0x03D71DA0 1 > $DCC_PATH/config
    echo 0x03D71DA4 1 > $DCC_PATH/config
    echo 0x03D71DA8 1 > $DCC_PATH/config
    echo 0x03D71DAC 1 > $DCC_PATH/config
    echo 0x03D71DB0 1 > $DCC_PATH/config
    echo 0x03D71DB4 1 > $DCC_PATH/config
    echo 0x03D71DB8 1 > $DCC_PATH/config
    echo 0x03D71DBC 1 > $DCC_PATH/config
    echo 0x03D71DC0 1 > $DCC_PATH/config
    echo 0x03D71DC4 1 > $DCC_PATH/config
    echo 0x03D71DC8 1 > $DCC_PATH/config
    echo 0x03D71DCC 1 > $DCC_PATH/config
    echo 0x03D71DD0 1 > $DCC_PATH/config
    echo 0x03D71DD4 1 > $DCC_PATH/config
    echo 0x03D71DD8 1 > $DCC_PATH/config
    echo 0x03D71DDC 1 > $DCC_PATH/config
    echo 0x03D71DE0 1 > $DCC_PATH/config
    echo 0x03D71DE4 1 > $DCC_PATH/config
    echo 0x03D71DE8 1 > $DCC_PATH/config
    echo 0x03D71DEC 1 > $DCC_PATH/config
    echo 0x03D71DF0 1 > $DCC_PATH/config
    echo 0x03D71DF4 1 > $DCC_PATH/config
    echo 0x03D71DF8 1 > $DCC_PATH/config
    echo 0x03D71DFC 1 > $DCC_PATH/config
    echo 0x03D71E00 1 > $DCC_PATH/config
    echo 0x03D71E04 1 > $DCC_PATH/config
    echo 0x03D71E08 1 > $DCC_PATH/config
    echo 0x03D71E0C 1 > $DCC_PATH/config
    echo 0x03D71E10 1 > $DCC_PATH/config
    echo 0x03D71E14 1 > $DCC_PATH/config
    echo 0x03D71E18 1 > $DCC_PATH/config
    echo 0x03D71E1C 1 > $DCC_PATH/config
    echo 0x03D71E20 1 > $DCC_PATH/config
    echo 0x03D71E24 1 > $DCC_PATH/config
    echo 0x03D71E28 1 > $DCC_PATH/config
    echo 0x03D71E2C 1 > $DCC_PATH/config
    echo 0x03D71E30 1 > $DCC_PATH/config
    echo 0x03D71E34 1 > $DCC_PATH/config
    echo 0x03D71E38 1 > $DCC_PATH/config
    echo 0x03D71E3C 1 > $DCC_PATH/config
    echo 0x03D71E40 1 > $DCC_PATH/config
    echo 0x03D71E44 1 > $DCC_PATH/config
    echo 0x03D71E48 1 > $DCC_PATH/config
    echo 0x03D71E4C 1 > $DCC_PATH/config
    echo 0x03D71E50 1 > $DCC_PATH/config
    echo 0x03D71E54 1 > $DCC_PATH/config
    echo 0x03D71E58 1 > $DCC_PATH/config
    echo 0x03D71E5C 1 > $DCC_PATH/config
    echo 0x03D71E60 1 > $DCC_PATH/config
    echo 0x03D71E64 1 > $DCC_PATH/config
    echo 0x03D71E68 1 > $DCC_PATH/config
    echo 0x03D71E6C 1 > $DCC_PATH/config
    echo 0x03D71E70 1 > $DCC_PATH/config
    echo 0x03D71E74 1 > $DCC_PATH/config
    echo 0x03D71E78 1 > $DCC_PATH/config
    echo 0x03D71E7C 1 > $DCC_PATH/config
    echo 0x03D71E80 1 > $DCC_PATH/config
    echo 0x03D71E84 1 > $DCC_PATH/config
    echo 0x03D71E88 1 > $DCC_PATH/config
    echo 0x03D71E8C 1 > $DCC_PATH/config
    echo 0x03D71E90 1 > $DCC_PATH/config
    echo 0x03D71E94 1 > $DCC_PATH/config
    echo 0x03D71E98 1 > $DCC_PATH/config
    echo 0x03D71E9C 1 > $DCC_PATH/config
    echo 0x03D71EA0 1 > $DCC_PATH/config
    echo 0x03D71EA4 1 > $DCC_PATH/config
    echo 0x03D71EA8 1 > $DCC_PATH/config
    echo 0x03D71EAC 1 > $DCC_PATH/config
    echo 0x03D71EB0 1 > $DCC_PATH/config
    echo 0x03D71EB4 1 > $DCC_PATH/config
    echo 0x03D71EB8 1 > $DCC_PATH/config
    echo 0x03D71EBC 1 > $DCC_PATH/config
    echo 0x03D71EC0 1 > $DCC_PATH/config
    echo 0x03D71EC4 1 > $DCC_PATH/config
    echo 0x03D71EC8 1 > $DCC_PATH/config
    echo 0x03D71ECC 1 > $DCC_PATH/config
    echo 0x03D71ED0 1 > $DCC_PATH/config
    echo 0x03D71ED4 1 > $DCC_PATH/config
    echo 0x03D71ED8 1 > $DCC_PATH/config
    echo 0x03D71EDC 1 > $DCC_PATH/config
    echo 0x03D71EE0 1 > $DCC_PATH/config
    echo 0x03D71EE4 1 > $DCC_PATH/config
    echo 0x03D71EE8 1 > $DCC_PATH/config
    echo 0x03D71EEC 1 > $DCC_PATH/config
    echo 0x03D71EF0 1 > $DCC_PATH/config
    echo 0x03D71EF4 1 > $DCC_PATH/config
    echo 0x03D71EF8 1 > $DCC_PATH/config
    echo 0x03D71EFC 1 > $DCC_PATH/config
    echo 0x03D71F00 1 > $DCC_PATH/config
    echo 0x03D71F04 1 > $DCC_PATH/config
    echo 0x03D71F08 1 > $DCC_PATH/config
    echo 0x03D71F0C 1 > $DCC_PATH/config
    echo 0x03D71F10 1 > $DCC_PATH/config
    echo 0x03D71F14 1 > $DCC_PATH/config
    echo 0x03D71F18 1 > $DCC_PATH/config
    echo 0x03D71F1C 1 > $DCC_PATH/config
    echo 0x03D71F20 1 > $DCC_PATH/config
    echo 0x03D71F24 1 > $DCC_PATH/config
    echo 0x03D71F28 1 > $DCC_PATH/config
    echo 0x03D71F2C 1 > $DCC_PATH/config
    echo 0x03D71F30 1 > $DCC_PATH/config
    echo 0x03D71F34 1 > $DCC_PATH/config
    echo 0x03D71F38 1 > $DCC_PATH/config
    echo 0x03D71F3C 1 > $DCC_PATH/config
    echo 0x03D71F40 1 > $DCC_PATH/config
    echo 0x03D71F44 1 > $DCC_PATH/config
    echo 0x03D71F48 1 > $DCC_PATH/config
    echo 0x03D71F4C 1 > $DCC_PATH/config
    echo 0x03D71F50 1 > $DCC_PATH/config
    echo 0x03D71F54 1 > $DCC_PATH/config
    echo 0x03D71F58 1 > $DCC_PATH/config
    echo 0x03D71F5C 1 > $DCC_PATH/config
    echo 0x03D71F60 1 > $DCC_PATH/config
    echo 0x03D71F64 1 > $DCC_PATH/config
    echo 0x03D71F68 1 > $DCC_PATH/config
    echo 0x03D71F6C 1 > $DCC_PATH/config
    echo 0x03D71F70 1 > $DCC_PATH/config
    echo 0x03D71F74 1 > $DCC_PATH/config
    echo 0x03D71F78 1 > $DCC_PATH/config
    echo 0x03D71F7C 1 > $DCC_PATH/config
    echo 0x03D71F80 1 > $DCC_PATH/config
    echo 0x03D71F84 1 > $DCC_PATH/config
    echo 0x03D71F88 1 > $DCC_PATH/config
    echo 0x03D71F8C 1 > $DCC_PATH/config
    echo 0x03D71F90 1 > $DCC_PATH/config
    echo 0x03D71F94 1 > $DCC_PATH/config
    echo 0x03D71F98 1 > $DCC_PATH/config
    echo 0x03D71F9C 1 > $DCC_PATH/config
    echo 0x03D71FA0 1 > $DCC_PATH/config
    echo 0x03D71FA4 1 > $DCC_PATH/config
    echo 0x03D71FA8 1 > $DCC_PATH/config
    echo 0x03D71FAC 1 > $DCC_PATH/config
    echo 0x03D71FB0 1 > $DCC_PATH/config
    echo 0x03D71FB4 1 > $DCC_PATH/config
    echo 0x03D71FB8 1 > $DCC_PATH/config
    echo 0x03D71FBC 1 > $DCC_PATH/config
    echo 0x03D71FC0 1 > $DCC_PATH/config
    echo 0x03D71FC4 1 > $DCC_PATH/config
    echo 0x03D71FC8 1 > $DCC_PATH/config
    echo 0x03D71FCC 1 > $DCC_PATH/config
    echo 0x03D71FD0 1 > $DCC_PATH/config
    echo 0x03D71FD4 1 > $DCC_PATH/config
    echo 0x03D71FD8 1 > $DCC_PATH/config
    echo 0x03D71FDC 1 > $DCC_PATH/config
    echo 0x03D71FE0 1 > $DCC_PATH/config
    echo 0x03D71FE4 1 > $DCC_PATH/config
    echo 0x03D71FE8 1 > $DCC_PATH/config
    echo 0x03D71FEC 1 > $DCC_PATH/config
    echo 0x03D71FF0 1 > $DCC_PATH/config
    echo 0x03D71FF4 1 > $DCC_PATH/config
    echo 0x03D71FF8 1 > $DCC_PATH/config
    echo 0x03D71FFC 1 > $DCC_PATH/config
    echo 0x03D72000 1 > $DCC_PATH/config
    echo 0x03D72004 1 > $DCC_PATH/config
    echo 0x03D72008 1 > $DCC_PATH/config
    echo 0x03D7200C 1 > $DCC_PATH/config
    echo 0x03D72010 1 > $DCC_PATH/config
    echo 0x03D72014 1 > $DCC_PATH/config
    echo 0x03D72018 1 > $DCC_PATH/config
    echo 0x03D7201C 1 > $DCC_PATH/config
    echo 0x03D72020 1 > $DCC_PATH/config
    echo 0x03D72024 1 > $DCC_PATH/config
    echo 0x03D72028 1 > $DCC_PATH/config
    echo 0x03D7202C 1 > $DCC_PATH/config
    echo 0x03D72030 1 > $DCC_PATH/config
    echo 0x03D72034 1 > $DCC_PATH/config
    echo 0x03D72038 1 > $DCC_PATH/config
    echo 0x03D7203C 1 > $DCC_PATH/config
    echo 0x03D72040 1 > $DCC_PATH/config
    echo 0x03D72044 1 > $DCC_PATH/config
    echo 0x03D72048 1 > $DCC_PATH/config
    echo 0x03D7204C 1 > $DCC_PATH/config
    echo 0x03D72050 1 > $DCC_PATH/config
    echo 0x03D72054 1 > $DCC_PATH/config
    echo 0x03D72058 1 > $DCC_PATH/config
    echo 0x03D7205C 1 > $DCC_PATH/config
    echo 0x03D72060 1 > $DCC_PATH/config
    echo 0x03D72064 1 > $DCC_PATH/config
    echo 0x03D72068 1 > $DCC_PATH/config
    echo 0x03D7206C 1 > $DCC_PATH/config
    echo 0x03D72070 1 > $DCC_PATH/config
    echo 0x03D72074 1 > $DCC_PATH/config
    echo 0x03D72078 1 > $DCC_PATH/config
    echo 0x03D7207C 1 > $DCC_PATH/config
    echo 0x03D72080 1 > $DCC_PATH/config
    echo 0x03D72084 1 > $DCC_PATH/config
    echo 0x03D72088 1 > $DCC_PATH/config
    echo 0x03D7208C 1 > $DCC_PATH/config
    echo 0x03D72090 1 > $DCC_PATH/config
    echo 0x03D72094 1 > $DCC_PATH/config
    echo 0x03D72098 1 > $DCC_PATH/config
    echo 0x03D7209C 1 > $DCC_PATH/config
    echo 0x03D720A0 1 > $DCC_PATH/config
    echo 0x03D720A4 1 > $DCC_PATH/config
    echo 0x03D720A8 1 > $DCC_PATH/config
    echo 0x03D720AC 1 > $DCC_PATH/config
    echo 0x03D720B0 1 > $DCC_PATH/config
    echo 0x03D720B4 1 > $DCC_PATH/config
    echo 0x03D720B8 1 > $DCC_PATH/config
    echo 0x03D720BC 1 > $DCC_PATH/config
    echo 0x03D720C0 1 > $DCC_PATH/config
    echo 0x03D720C4 1 > $DCC_PATH/config
    echo 0x03D720C8 1 > $DCC_PATH/config
    echo 0x03D720CC 1 > $DCC_PATH/config
    echo 0x03D720D0 1 > $DCC_PATH/config
    echo 0x03D720D4 1 > $DCC_PATH/config
    echo 0x03D720D8 1 > $DCC_PATH/config
    echo 0x03D720DC 1 > $DCC_PATH/config
    echo 0x03D720E0 1 > $DCC_PATH/config
    echo 0x03D720E4 1 > $DCC_PATH/config
    echo 0x03D720E8 1 > $DCC_PATH/config
    echo 0x03D720EC 1 > $DCC_PATH/config
    echo 0x03D720F0 1 > $DCC_PATH/config
    echo 0x03D720F4 1 > $DCC_PATH/config
    echo 0x03D720F8 1 > $DCC_PATH/config
    echo 0x03D720FC 1 > $DCC_PATH/config
    echo 0x03D72100 1 > $DCC_PATH/config
    echo 0x03D72104 1 > $DCC_PATH/config
    echo 0x03D72108 1 > $DCC_PATH/config
    echo 0x03D7210C 1 > $DCC_PATH/config
    echo 0x03D72110 1 > $DCC_PATH/config
    echo 0x03D72114 1 > $DCC_PATH/config
    echo 0x03D72118 1 > $DCC_PATH/config
    echo 0x03D7211C 1 > $DCC_PATH/config
    echo 0x03D72120 1 > $DCC_PATH/config
    echo 0x03D72124 1 > $DCC_PATH/config
    echo 0x03D72128 1 > $DCC_PATH/config
    echo 0x03D7212C 1 > $DCC_PATH/config
    echo 0x03D72130 1 > $DCC_PATH/config
    echo 0x03D72134 1 > $DCC_PATH/config
    echo 0x03D72138 1 > $DCC_PATH/config
    echo 0x03D7213C 1 > $DCC_PATH/config
    echo 0x03D72140 1 > $DCC_PATH/config
    echo 0x03D72144 1 > $DCC_PATH/config
    echo 0x03D72148 1 > $DCC_PATH/config
    echo 0x03D7214C 1 > $DCC_PATH/config
    echo 0x03D72150 1 > $DCC_PATH/config
    echo 0x03D72154 1 > $DCC_PATH/config
    echo 0x03D72158 1 > $DCC_PATH/config
    echo 0x03D7215C 1 > $DCC_PATH/config
    echo 0x03D72160 1 > $DCC_PATH/config
    echo 0x03D72164 1 > $DCC_PATH/config
    echo 0x03D72168 1 > $DCC_PATH/config
    echo 0x03D7216C 1 > $DCC_PATH/config
    echo 0x03D72170 1 > $DCC_PATH/config
    echo 0x03D72174 1 > $DCC_PATH/config
    echo 0x03D72178 1 > $DCC_PATH/config
    echo 0x03D7217C 1 > $DCC_PATH/config
    echo 0x03D72180 1 > $DCC_PATH/config
    echo 0x03D72184 1 > $DCC_PATH/config
    echo 0x03D72188 1 > $DCC_PATH/config
    echo 0x03D7218C 1 > $DCC_PATH/config
    echo 0x03D72190 1 > $DCC_PATH/config
    echo 0x03D72194 1 > $DCC_PATH/config
    echo 0x03D72198 1 > $DCC_PATH/config
    echo 0x03D7219C 1 > $DCC_PATH/config
    echo 0x03D721A0 1 > $DCC_PATH/config
    echo 0x03D721A4 1 > $DCC_PATH/config
    echo 0x03D721A8 1 > $DCC_PATH/config
    echo 0x03D721AC 1 > $DCC_PATH/config
    echo 0x03D721B0 1 > $DCC_PATH/config
    echo 0x03D721B4 1 > $DCC_PATH/config
    echo 0x03D721B8 1 > $DCC_PATH/config
    echo 0x03D721BC 1 > $DCC_PATH/config
    echo 0x03D721C0 1 > $DCC_PATH/config
    echo 0x03D721C4 1 > $DCC_PATH/config
    echo 0x03D721C8 1 > $DCC_PATH/config
    echo 0x03D721CC 1 > $DCC_PATH/config
    echo 0x03D721D0 1 > $DCC_PATH/config
    echo 0x03D721D4 1 > $DCC_PATH/config
    echo 0x03D721D8 1 > $DCC_PATH/config
    echo 0x03D721DC 1 > $DCC_PATH/config
    echo 0x03D721E0 1 > $DCC_PATH/config
    echo 0x03D721E4 1 > $DCC_PATH/config
    echo 0x03D721E8 1 > $DCC_PATH/config
    echo 0x03D721EC 1 > $DCC_PATH/config
    echo 0x03D721F0 1 > $DCC_PATH/config
    echo 0x03D721F4 1 > $DCC_PATH/config
    echo 0x03D721F8 1 > $DCC_PATH/config
    echo 0x03D721FC 1 > $DCC_PATH/config
    echo 0x03D72200 1 > $DCC_PATH/config
    echo 0x03D72204 1 > $DCC_PATH/config
    echo 0x03D72208 1 > $DCC_PATH/config
    echo 0x03D7220C 1 > $DCC_PATH/config
    echo 0x03D72210 1 > $DCC_PATH/config
    echo 0x03D72214 1 > $DCC_PATH/config
    echo 0x03D72218 1 > $DCC_PATH/config
    echo 0x03D7221C 1 > $DCC_PATH/config
    echo 0x03D72220 1 > $DCC_PATH/config
    echo 0x03D72224 1 > $DCC_PATH/config
    echo 0x03D72228 1 > $DCC_PATH/config
    echo 0x03D7222C 1 > $DCC_PATH/config
    echo 0x03D72230 1 > $DCC_PATH/config
    echo 0x03D72234 1 > $DCC_PATH/config
    echo 0x03D72238 1 > $DCC_PATH/config
    echo 0x03D7223C 1 > $DCC_PATH/config
    echo 0x03D72240 1 > $DCC_PATH/config
    echo 0x03D72244 1 > $DCC_PATH/config
    echo 0x03D72248 1 > $DCC_PATH/config
    echo 0x03D7224C 1 > $DCC_PATH/config
    echo 0x03D72250 1 > $DCC_PATH/config
    echo 0x03D72254 1 > $DCC_PATH/config
    echo 0x03D72258 1 > $DCC_PATH/config
    echo 0x03D7225C 1 > $DCC_PATH/config
    echo 0x03D72260 1 > $DCC_PATH/config
    echo 0x03D72264 1 > $DCC_PATH/config
    echo 0x03D72268 1 > $DCC_PATH/config
    echo 0x03D7226C 1 > $DCC_PATH/config
    echo 0x03D72270 1 > $DCC_PATH/config
    echo 0x03D72274 1 > $DCC_PATH/config
    echo 0x03D72278 1 > $DCC_PATH/config
    echo 0x03D7227C 1 > $DCC_PATH/config
    echo 0x03D72280 1 > $DCC_PATH/config
    echo 0x03D72284 1 > $DCC_PATH/config
    echo 0x03D72288 1 > $DCC_PATH/config
    echo 0x03D7228C 1 > $DCC_PATH/config
    echo 0x03D72290 1 > $DCC_PATH/config
    echo 0x03D72294 1 > $DCC_PATH/config
    echo 0x03D72298 1 > $DCC_PATH/config
    echo 0x03D7229C 1 > $DCC_PATH/config
    echo 0x03D722A0 1 > $DCC_PATH/config
    echo 0x03D722A4 1 > $DCC_PATH/config
    echo 0x03D722A8 1 > $DCC_PATH/config
    echo 0x03D722AC 1 > $DCC_PATH/config
    echo 0x03D722B0 1 > $DCC_PATH/config
    echo 0x03D722B4 1 > $DCC_PATH/config
    echo 0x03D722B8 1 > $DCC_PATH/config
    echo 0x03D722BC 1 > $DCC_PATH/config
    echo 0x03D722C0 1 > $DCC_PATH/config
    echo 0x03D722C4 1 > $DCC_PATH/config
    echo 0x03D722C8 1 > $DCC_PATH/config
    echo 0x03D722CC 1 > $DCC_PATH/config
    echo 0x03D722D0 1 > $DCC_PATH/config
    echo 0x03D722D4 1 > $DCC_PATH/config
    echo 0x03D722D8 1 > $DCC_PATH/config
    echo 0x03D722DC 1 > $DCC_PATH/config
    echo 0x03D722E0 1 > $DCC_PATH/config
    echo 0x03D722E4 1 > $DCC_PATH/config
    echo 0x03D722E8 1 > $DCC_PATH/config
    echo 0x03D722EC 1 > $DCC_PATH/config
    echo 0x03D722F0 1 > $DCC_PATH/config
    echo 0x03D722F4 1 > $DCC_PATH/config
    echo 0x03D722F8 1 > $DCC_PATH/config
    echo 0x03D722FC 1 > $DCC_PATH/config
    echo 0x03D72300 1 > $DCC_PATH/config
    echo 0x03D72304 1 > $DCC_PATH/config
    echo 0x03D72308 1 > $DCC_PATH/config
    echo 0x03D7230C 1 > $DCC_PATH/config
    echo 0x03D72310 1 > $DCC_PATH/config
    echo 0x03D72314 1 > $DCC_PATH/config
    echo 0x03D72318 1 > $DCC_PATH/config
    echo 0x03D7231C 1 > $DCC_PATH/config
    echo 0x03D72320 1 > $DCC_PATH/config
    echo 0x03D72324 1 > $DCC_PATH/config
    echo 0x03D72328 1 > $DCC_PATH/config
    echo 0x03D7232C 1 > $DCC_PATH/config
    echo 0x03D72330 1 > $DCC_PATH/config
    echo 0x03D72334 1 > $DCC_PATH/config
    echo 0x03D72338 1 > $DCC_PATH/config
    echo 0x03D7233C 1 > $DCC_PATH/config
    echo 0x03D72340 1 > $DCC_PATH/config
    echo 0x03D72344 1 > $DCC_PATH/config
    echo 0x03D72348 1 > $DCC_PATH/config
    echo 0x03D7234C 1 > $DCC_PATH/config
    echo 0x03D72350 1 > $DCC_PATH/config
    echo 0x03D72354 1 > $DCC_PATH/config
    echo 0x03D72358 1 > $DCC_PATH/config
    echo 0x03D7235C 1 > $DCC_PATH/config
    echo 0x03D72360 1 > $DCC_PATH/config
    echo 0x03D72364 1 > $DCC_PATH/config
    echo 0x03D72368 1 > $DCC_PATH/config
    echo 0x03D7236C 1 > $DCC_PATH/config
    echo 0x03D72370 1 > $DCC_PATH/config
    echo 0x03D72374 1 > $DCC_PATH/config
    echo 0x03D72378 1 > $DCC_PATH/config
    echo 0x03D7237C 1 > $DCC_PATH/config
    echo 0x03D72380 1 > $DCC_PATH/config
    echo 0x03D72384 1 > $DCC_PATH/config
    echo 0x03D72388 1 > $DCC_PATH/config
    echo 0x03D7238C 1 > $DCC_PATH/config
    echo 0x03D72390 1 > $DCC_PATH/config
    echo 0x03D72394 1 > $DCC_PATH/config
    echo 0x03D72398 1 > $DCC_PATH/config
    echo 0x03D7239C 1 > $DCC_PATH/config
    echo 0x03D723A0 1 > $DCC_PATH/config
    echo 0x03D723A4 1 > $DCC_PATH/config
    echo 0x03D723A8 1 > $DCC_PATH/config
    echo 0x03D723AC 1 > $DCC_PATH/config
    echo 0x03D723B0 1 > $DCC_PATH/config
    echo 0x03D723B4 1 > $DCC_PATH/config
    echo 0x03D723B8 1 > $DCC_PATH/config
    echo 0x03D723BC 1 > $DCC_PATH/config
    echo 0x03D723C0 1 > $DCC_PATH/config
    echo 0x03D723C4 1 > $DCC_PATH/config
    echo 0x03D723C8 1 > $DCC_PATH/config
    echo 0x03D723CC 1 > $DCC_PATH/config
    echo 0x03D723D0 1 > $DCC_PATH/config
    echo 0x03D723D4 1 > $DCC_PATH/config
    echo 0x03D723D8 1 > $DCC_PATH/config
    echo 0x03D723DC 1 > $DCC_PATH/config
    echo 0x03D723E0 1 > $DCC_PATH/config
    echo 0x03D723E4 1 > $DCC_PATH/config
    echo 0x03D723E8 1 > $DCC_PATH/config
    echo 0x03D723EC 1 > $DCC_PATH/config
    echo 0x03D723F0 1 > $DCC_PATH/config
    echo 0x03D723F4 1 > $DCC_PATH/config
    echo 0x03D723F8 1 > $DCC_PATH/config
    echo 0x03D723FC 1 > $DCC_PATH/config
    echo 0x03D72400 1 > $DCC_PATH/config
    echo 0x03D72404 1 > $DCC_PATH/config
    echo 0x03D72408 1 > $DCC_PATH/config
    echo 0x03D7240C 1 > $DCC_PATH/config
    echo 0x03D72410 1 > $DCC_PATH/config
    echo 0x03D72414 1 > $DCC_PATH/config
    echo 0x03D72418 1 > $DCC_PATH/config
    echo 0x03D7241C 1 > $DCC_PATH/config
    echo 0x03D72420 1 > $DCC_PATH/config
    echo 0x03D72424 1 > $DCC_PATH/config
    echo 0x03D72428 1 > $DCC_PATH/config
    echo 0x03D7242C 1 > $DCC_PATH/config
    echo 0x03D72430 1 > $DCC_PATH/config
    echo 0x03D72434 1 > $DCC_PATH/config
    echo 0x03D72438 1 > $DCC_PATH/config
    echo 0x03D7243C 1 > $DCC_PATH/config
    echo 0x03D72440 1 > $DCC_PATH/config
    echo 0x03D72444 1 > $DCC_PATH/config
    echo 0x03D72448 1 > $DCC_PATH/config
    echo 0x03D7244C 1 > $DCC_PATH/config
    echo 0x03D72450 1 > $DCC_PATH/config
    echo 0x03D72454 1 > $DCC_PATH/config
    echo 0x03D72458 1 > $DCC_PATH/config
    echo 0x03D7245C 1 > $DCC_PATH/config
    echo 0x03D72460 1 > $DCC_PATH/config
    echo 0x03D72464 1 > $DCC_PATH/config
    echo 0x03D72468 1 > $DCC_PATH/config
    echo 0x03D7246C 1 > $DCC_PATH/config
    echo 0x03D72470 1 > $DCC_PATH/config
    echo 0x03D72474 1 > $DCC_PATH/config
    echo 0x03D72478 1 > $DCC_PATH/config
    echo 0x03D7247C 1 > $DCC_PATH/config
    echo 0x03D72480 1 > $DCC_PATH/config
    echo 0x03D72484 1 > $DCC_PATH/config
    echo 0x03D72488 1 > $DCC_PATH/config
    echo 0x03D7248C 1 > $DCC_PATH/config
    echo 0x03D72490 1 > $DCC_PATH/config
    echo 0x03D72494 1 > $DCC_PATH/config
    echo 0x03D72498 1 > $DCC_PATH/config
    echo 0x03D7249C 1 > $DCC_PATH/config
    echo 0x03D724A0 1 > $DCC_PATH/config
    echo 0x03D724A4 1 > $DCC_PATH/config
    echo 0x03D724A8 1 > $DCC_PATH/config
    echo 0x03D724AC 1 > $DCC_PATH/config
    echo 0x03D724B0 1 > $DCC_PATH/config
    echo 0x03D724B4 1 > $DCC_PATH/config
    echo 0x03D724B8 1 > $DCC_PATH/config
    echo 0x03D724BC 1 > $DCC_PATH/config
    echo 0x03D724C0 1 > $DCC_PATH/config
    echo 0x03D724C4 1 > $DCC_PATH/config
    echo 0x03D724C8 1 > $DCC_PATH/config
    echo 0x03D724CC 1 > $DCC_PATH/config
    echo 0x03D724D0 1 > $DCC_PATH/config
    echo 0x03D724D4 1 > $DCC_PATH/config
    echo 0x03D724D8 1 > $DCC_PATH/config
    echo 0x03D724DC 1 > $DCC_PATH/config
    echo 0x03D724E0 1 > $DCC_PATH/config
    echo 0x03D724E4 1 > $DCC_PATH/config
    echo 0x03D724E8 1 > $DCC_PATH/config
    echo 0x03D724EC 1 > $DCC_PATH/config
    echo 0x03D724F0 1 > $DCC_PATH/config
    echo 0x03D724F4 1 > $DCC_PATH/config
    echo 0x03D724F8 1 > $DCC_PATH/config
    echo 0x03D724FC 1 > $DCC_PATH/config
    echo 0x03D72500 1 > $DCC_PATH/config
    echo 0x03D72504 1 > $DCC_PATH/config
    echo 0x03D72508 1 > $DCC_PATH/config
    echo 0x03D7250C 1 > $DCC_PATH/config
    echo 0x03D72510 1 > $DCC_PATH/config
    echo 0x03D72514 1 > $DCC_PATH/config
    echo 0x03D72518 1 > $DCC_PATH/config
    echo 0x03D7251C 1 > $DCC_PATH/config
    echo 0x03D72520 1 > $DCC_PATH/config
    echo 0x03D72524 1 > $DCC_PATH/config
    echo 0x03D72528 1 > $DCC_PATH/config
    echo 0x03D7252C 1 > $DCC_PATH/config
    echo 0x03D72530 1 > $DCC_PATH/config
    echo 0x03D72534 1 > $DCC_PATH/config
    echo 0x03D72538 1 > $DCC_PATH/config
    echo 0x03D7253C 1 > $DCC_PATH/config
    echo 0x03D72540 1 > $DCC_PATH/config
    echo 0x03D72544 1 > $DCC_PATH/config
    echo 0x03D72548 1 > $DCC_PATH/config
    echo 0x03D7254C 1 > $DCC_PATH/config
    echo 0x03D72550 1 > $DCC_PATH/config
    echo 0x03D72554 1 > $DCC_PATH/config
    echo 0x03D72558 1 > $DCC_PATH/config
    echo 0x03D7255C 1 > $DCC_PATH/config
    echo 0x03D72560 1 > $DCC_PATH/config
    echo 0x03D72564 1 > $DCC_PATH/config
    echo 0x03D72568 1 > $DCC_PATH/config
    echo 0x03D7256C 1 > $DCC_PATH/config
    echo 0x03D72570 1 > $DCC_PATH/config
    echo 0x03D72574 1 > $DCC_PATH/config
    echo 0x03D72578 1 > $DCC_PATH/config
    echo 0x03D7257C 1 > $DCC_PATH/config
    echo 0x03D72580 1 > $DCC_PATH/config
    echo 0x03D72584 1 > $DCC_PATH/config
    echo 0x03D72588 1 > $DCC_PATH/config
    echo 0x03D7258C 1 > $DCC_PATH/config
    echo 0x03D72590 1 > $DCC_PATH/config
    echo 0x03D72594 1 > $DCC_PATH/config
    echo 0x03D72598 1 > $DCC_PATH/config
    echo 0x03D7259C 1 > $DCC_PATH/config
    echo 0x03D725A0 1 > $DCC_PATH/config
    echo 0x03D725A4 1 > $DCC_PATH/config
    echo 0x03D725A8 1 > $DCC_PATH/config
    echo 0x03D725AC 1 > $DCC_PATH/config
    echo 0x03D725B0 1 > $DCC_PATH/config
    echo 0x03D725B4 1 > $DCC_PATH/config
    echo 0x03D725B8 1 > $DCC_PATH/config
    echo 0x03D725BC 1 > $DCC_PATH/config
    echo 0x03D725C0 1 > $DCC_PATH/config
    echo 0x03D725C4 1 > $DCC_PATH/config
    echo 0x03D725C8 1 > $DCC_PATH/config
    echo 0x03D725CC 1 > $DCC_PATH/config
    echo 0x03D725D0 1 > $DCC_PATH/config
    echo 0x03D725D4 1 > $DCC_PATH/config
    echo 0x03D725D8 1 > $DCC_PATH/config
    echo 0x03D725DC 1 > $DCC_PATH/config
    echo 0x03D725E0 1 > $DCC_PATH/config
    echo 0x03D725E4 1 > $DCC_PATH/config
    echo 0x03D725E8 1 > $DCC_PATH/config
    echo 0x03D725EC 1 > $DCC_PATH/config
    echo 0x03D725F0 1 > $DCC_PATH/config
    echo 0x03D725F4 1 > $DCC_PATH/config
    echo 0x03D725F8 1 > $DCC_PATH/config
    echo 0x03D725FC 1 > $DCC_PATH/config
    echo 0x03D72600 1 > $DCC_PATH/config
    echo 0x03D72604 1 > $DCC_PATH/config
    echo 0x03D72608 1 > $DCC_PATH/config
    echo 0x03D7260C 1 > $DCC_PATH/config
    echo 0x03D72610 1 > $DCC_PATH/config
    echo 0x03D72614 1 > $DCC_PATH/config
    echo 0x03D72618 1 > $DCC_PATH/config
    echo 0x03D7261C 1 > $DCC_PATH/config
    echo 0x03D72620 1 > $DCC_PATH/config
    echo 0x03D72624 1 > $DCC_PATH/config
    echo 0x03D72628 1 > $DCC_PATH/config
    echo 0x03D7262C 1 > $DCC_PATH/config
    echo 0x03D72630 1 > $DCC_PATH/config
    echo 0x03D72634 1 > $DCC_PATH/config
    echo 0x03D72638 1 > $DCC_PATH/config
    echo 0x03D7263C 1 > $DCC_PATH/config
    echo 0x03D72640 1 > $DCC_PATH/config
    echo 0x03D72644 1 > $DCC_PATH/config
    echo 0x03D72648 1 > $DCC_PATH/config
    echo 0x03D7264C 1 > $DCC_PATH/config
    echo 0x03D72650 1 > $DCC_PATH/config
    echo 0x03D72654 1 > $DCC_PATH/config
    echo 0x03D72658 1 > $DCC_PATH/config
    echo 0x03D7265C 1 > $DCC_PATH/config
    echo 0x03D72660 1 > $DCC_PATH/config
    echo 0x03D72664 1 > $DCC_PATH/config
    echo 0x03D72668 1 > $DCC_PATH/config
    echo 0x03D7266C 1 > $DCC_PATH/config
    echo 0x03D72670 1 > $DCC_PATH/config
    echo 0x03D72674 1 > $DCC_PATH/config
    echo 0x03D72678 1 > $DCC_PATH/config
    echo 0x03D7267C 1 > $DCC_PATH/config
    echo 0x03D72680 1 > $DCC_PATH/config
    echo 0x03D72684 1 > $DCC_PATH/config
    echo 0x03D72688 1 > $DCC_PATH/config
    echo 0x03D7268C 1 > $DCC_PATH/config
    echo 0x03D72690 1 > $DCC_PATH/config
    echo 0x03D72694 1 > $DCC_PATH/config
    echo 0x03D72698 1 > $DCC_PATH/config
    echo 0x03D7269C 1 > $DCC_PATH/config
    echo 0x03D726A0 1 > $DCC_PATH/config
    echo 0x03D726A4 1 > $DCC_PATH/config
    echo 0x03D726A8 1 > $DCC_PATH/config
    echo 0x03D726AC 1 > $DCC_PATH/config
    echo 0x03D726B0 1 > $DCC_PATH/config
    echo 0x03D726B4 1 > $DCC_PATH/config
    echo 0x03D726B8 1 > $DCC_PATH/config
    echo 0x03D726BC 1 > $DCC_PATH/config
    echo 0x03D726C0 1 > $DCC_PATH/config
    echo 0x03D726C4 1 > $DCC_PATH/config
    echo 0x03D726C8 1 > $DCC_PATH/config
    echo 0x03D726CC 1 > $DCC_PATH/config
    echo 0x03D726D0 1 > $DCC_PATH/config
    echo 0x03D726D4 1 > $DCC_PATH/config
    echo 0x03D726D8 1 > $DCC_PATH/config
    echo 0x03D726DC 1 > $DCC_PATH/config
    echo 0x03D726E0 1 > $DCC_PATH/config
    echo 0x03D726E4 1 > $DCC_PATH/config
    echo 0x03D726E8 1 > $DCC_PATH/config
    echo 0x03D726EC 1 > $DCC_PATH/config
    echo 0x03D726F0 1 > $DCC_PATH/config
    echo 0x03D726F4 1 > $DCC_PATH/config
    echo 0x03D726F8 1 > $DCC_PATH/config
    echo 0x03D726FC 1 > $DCC_PATH/config
    echo 0x03D72700 1 > $DCC_PATH/config
    echo 0x03D72704 1 > $DCC_PATH/config
    echo 0x03D72708 1 > $DCC_PATH/config
    echo 0x03D7270C 1 > $DCC_PATH/config
    echo 0x03D72710 1 > $DCC_PATH/config
    echo 0x03D72714 1 > $DCC_PATH/config
    echo 0x03D72718 1 > $DCC_PATH/config
    echo 0x03D7271C 1 > $DCC_PATH/config
    echo 0x03D72720 1 > $DCC_PATH/config
    echo 0x03D72724 1 > $DCC_PATH/config
    echo 0x03D72728 1 > $DCC_PATH/config
    echo 0x03D7272C 1 > $DCC_PATH/config
    echo 0x03D72730 1 > $DCC_PATH/config
    echo 0x03D72734 1 > $DCC_PATH/config
    echo 0x03D72738 1 > $DCC_PATH/config
    echo 0x03D7273C 1 > $DCC_PATH/config
    echo 0x03D72740 1 > $DCC_PATH/config
    echo 0x03D72744 1 > $DCC_PATH/config
    echo 0x03D72748 1 > $DCC_PATH/config
    echo 0x03D7274C 1 > $DCC_PATH/config
    echo 0x03D72750 1 > $DCC_PATH/config
    echo 0x03D72754 1 > $DCC_PATH/config
    echo 0x03D72758 1 > $DCC_PATH/config
    echo 0x03D7275C 1 > $DCC_PATH/config
    echo 0x03D72760 1 > $DCC_PATH/config
    echo 0x03D72764 1 > $DCC_PATH/config
    echo 0x03D72768 1 > $DCC_PATH/config
    echo 0x03D7276C 1 > $DCC_PATH/config
    echo 0x03D72770 1 > $DCC_PATH/config
    echo 0x03D72774 1 > $DCC_PATH/config
    echo 0x03D72778 1 > $DCC_PATH/config
    echo 0x03D7277C 1 > $DCC_PATH/config
    echo 0x03D72780 1 > $DCC_PATH/config
    echo 0x03D72784 1 > $DCC_PATH/config
    echo 0x03D72788 1 > $DCC_PATH/config
    echo 0x03D7278C 1 > $DCC_PATH/config
    echo 0x03D72790 1 > $DCC_PATH/config
    echo 0x03D72794 1 > $DCC_PATH/config
    echo 0x03D72798 1 > $DCC_PATH/config
    echo 0x03D7279C 1 > $DCC_PATH/config
    echo 0x03D727A0 1 > $DCC_PATH/config
    echo 0x03D727A4 1 > $DCC_PATH/config
    echo 0x03D727A8 1 > $DCC_PATH/config
    echo 0x03D727AC 1 > $DCC_PATH/config
    echo 0x03D727B0 1 > $DCC_PATH/config
    echo 0x03D727B4 1 > $DCC_PATH/config
    echo 0x03D727B8 1 > $DCC_PATH/config
    echo 0x03D727BC 1 > $DCC_PATH/config
    echo 0x03D727C0 1 > $DCC_PATH/config
    echo 0x03D727C4 1 > $DCC_PATH/config
    echo 0x03D727C8 1 > $DCC_PATH/config
    echo 0x03D727CC 1 > $DCC_PATH/config
    echo 0x03D727D0 1 > $DCC_PATH/config
    echo 0x03D727D4 1 > $DCC_PATH/config
    echo 0x03D727D8 1 > $DCC_PATH/config
    echo 0x03D727DC 1 > $DCC_PATH/config
    echo 0x03D727E0 1 > $DCC_PATH/config
    echo 0x03D727E4 1 > $DCC_PATH/config
    echo 0x03D727E8 1 > $DCC_PATH/config
    echo 0x03D727EC 1 > $DCC_PATH/config
    echo 0x03D727F0 1 > $DCC_PATH/config
    echo 0x03D727F4 1 > $DCC_PATH/config
    echo 0x03D727F8 1 > $DCC_PATH/config
    echo 0x03D727FC 1 > $DCC_PATH/config
    echo 0x03D72800 1 > $DCC_PATH/config
    echo 0x03D72804 1 > $DCC_PATH/config
    echo 0x03D72808 1 > $DCC_PATH/config
    echo 0x03D7280C 1 > $DCC_PATH/config
    echo 0x03D72810 1 > $DCC_PATH/config
    echo 0x03D72814 1 > $DCC_PATH/config
    echo 0x03D72818 1 > $DCC_PATH/config
    echo 0x03D7281C 1 > $DCC_PATH/config
    echo 0x03D72820 1 > $DCC_PATH/config
    echo 0x03D72824 1 > $DCC_PATH/config
    echo 0x03D72828 1 > $DCC_PATH/config
    echo 0x03D7282C 1 > $DCC_PATH/config
    echo 0x03D72830 1 > $DCC_PATH/config
    echo 0x03D72834 1 > $DCC_PATH/config
    echo 0x03D72838 1 > $DCC_PATH/config
    echo 0x03D7283C 1 > $DCC_PATH/config
    echo 0x03D72840 1 > $DCC_PATH/config
    echo 0x03D72844 1 > $DCC_PATH/config
    echo 0x03D72848 1 > $DCC_PATH/config
    echo 0x03D7284C 1 > $DCC_PATH/config
    echo 0x03D72850 1 > $DCC_PATH/config
    echo 0x03D72854 1 > $DCC_PATH/config
    echo 0x03D72858 1 > $DCC_PATH/config
    echo 0x03D7285C 1 > $DCC_PATH/config
    echo 0x03D72860 1 > $DCC_PATH/config
    echo 0x03D72864 1 > $DCC_PATH/config
    echo 0x03D72868 1 > $DCC_PATH/config
    echo 0x03D7286C 1 > $DCC_PATH/config
    echo 0x03D72870 1 > $DCC_PATH/config
    echo 0x03D72874 1 > $DCC_PATH/config
    echo 0x03D72878 1 > $DCC_PATH/config
    echo 0x03D7287C 1 > $DCC_PATH/config
    echo 0x03D72880 1 > $DCC_PATH/config
    echo 0x03D72884 1 > $DCC_PATH/config
    echo 0x03D72888 1 > $DCC_PATH/config
    echo 0x03D7288C 1 > $DCC_PATH/config
    echo 0x03D72890 1 > $DCC_PATH/config
    echo 0x03D72894 1 > $DCC_PATH/config
    echo 0x03D72898 1 > $DCC_PATH/config
    echo 0x03D7289C 1 > $DCC_PATH/config
    echo 0x03D728A0 1 > $DCC_PATH/config
    echo 0x03D728A4 1 > $DCC_PATH/config
    echo 0x03D728A8 1 > $DCC_PATH/config
    echo 0x03D728AC 1 > $DCC_PATH/config
    echo 0x03D728B0 1 > $DCC_PATH/config
    echo 0x03D728B4 1 > $DCC_PATH/config
    echo 0x03D728B8 1 > $DCC_PATH/config
    echo 0x03D728BC 1 > $DCC_PATH/config
    echo 0x03D728C0 1 > $DCC_PATH/config
    echo 0x03D728C4 1 > $DCC_PATH/config
    echo 0x03D728C8 1 > $DCC_PATH/config
    echo 0x03D728CC 1 > $DCC_PATH/config
    echo 0x03D728D0 1 > $DCC_PATH/config
    echo 0x03D728D4 1 > $DCC_PATH/config
    echo 0x03D728D8 1 > $DCC_PATH/config
    echo 0x03D728DC 1 > $DCC_PATH/config
    echo 0x03D728E0 1 > $DCC_PATH/config
    echo 0x03D728E4 1 > $DCC_PATH/config
    echo 0x03D728E8 1 > $DCC_PATH/config
    echo 0x03D728EC 1 > $DCC_PATH/config
    echo 0x03D728F0 1 > $DCC_PATH/config
    echo 0x03D728F4 1 > $DCC_PATH/config
    echo 0x03D728F8 1 > $DCC_PATH/config
    echo 0x03D728FC 1 > $DCC_PATH/config
    echo 0x03D72900 1 > $DCC_PATH/config
    echo 0x03D72904 1 > $DCC_PATH/config
    echo 0x03D72908 1 > $DCC_PATH/config
    echo 0x03D7290C 1 > $DCC_PATH/config
    echo 0x03D72910 1 > $DCC_PATH/config
    echo 0x03D72914 1 > $DCC_PATH/config
    echo 0x03D72918 1 > $DCC_PATH/config
    echo 0x03D7291C 1 > $DCC_PATH/config
    echo 0x03D72920 1 > $DCC_PATH/config
    echo 0x03D72924 1 > $DCC_PATH/config
    echo 0x03D72928 1 > $DCC_PATH/config
    echo 0x03D7292C 1 > $DCC_PATH/config
    echo 0x03D72930 1 > $DCC_PATH/config
    echo 0x03D72934 1 > $DCC_PATH/config
    echo 0x03D72938 1 > $DCC_PATH/config
    echo 0x03D7293C 1 > $DCC_PATH/config
    echo 0x03D72940 1 > $DCC_PATH/config
    echo 0x03D72944 1 > $DCC_PATH/config
    echo 0x03D72948 1 > $DCC_PATH/config
    echo 0x03D7294C 1 > $DCC_PATH/config
    echo 0x03D72950 1 > $DCC_PATH/config
    echo 0x03D72954 1 > $DCC_PATH/config
    echo 0x03D72958 1 > $DCC_PATH/config
    echo 0x03D7295C 1 > $DCC_PATH/config
    echo 0x03D72960 1 > $DCC_PATH/config
    echo 0x03D72964 1 > $DCC_PATH/config
    echo 0x03D72968 1 > $DCC_PATH/config
    echo 0x03D7296C 1 > $DCC_PATH/config
    echo 0x03D72970 1 > $DCC_PATH/config
    echo 0x03D72974 1 > $DCC_PATH/config
    echo 0x03D72978 1 > $DCC_PATH/config
    echo 0x03D7297C 1 > $DCC_PATH/config
    echo 0x03D72980 1 > $DCC_PATH/config
    echo 0x03D72984 1 > $DCC_PATH/config
    echo 0x03D72988 1 > $DCC_PATH/config
    echo 0x03D7298C 1 > $DCC_PATH/config
    echo 0x03D72990 1 > $DCC_PATH/config
    echo 0x03D72994 1 > $DCC_PATH/config
    echo 0x03D72998 1 > $DCC_PATH/config
    echo 0x03D7299C 1 > $DCC_PATH/config
    echo 0x03D729A0 1 > $DCC_PATH/config
    echo 0x03D729A4 1 > $DCC_PATH/config
    echo 0x03D729A8 1 > $DCC_PATH/config
    echo 0x03D729AC 1 > $DCC_PATH/config
    echo 0x03D729B0 1 > $DCC_PATH/config
    echo 0x03D729B4 1 > $DCC_PATH/config
    echo 0x03D729B8 1 > $DCC_PATH/config
    echo 0x03D729BC 1 > $DCC_PATH/config
    echo 0x03D729C0 1 > $DCC_PATH/config
    echo 0x03D729C4 1 > $DCC_PATH/config
    echo 0x03D729C8 1 > $DCC_PATH/config
    echo 0x03D729CC 1 > $DCC_PATH/config
    echo 0x03D729D0 1 > $DCC_PATH/config
    echo 0x03D729D4 1 > $DCC_PATH/config
    echo 0x03D729D8 1 > $DCC_PATH/config
    echo 0x03D729DC 1 > $DCC_PATH/config
    echo 0x03D729E0 1 > $DCC_PATH/config
    echo 0x03D729E4 1 > $DCC_PATH/config
    echo 0x03D729E8 1 > $DCC_PATH/config
    echo 0x03D729EC 1 > $DCC_PATH/config
    echo 0x03D729F0 1 > $DCC_PATH/config
    echo 0x03D729F4 1 > $DCC_PATH/config
    echo 0x03D729F8 1 > $DCC_PATH/config
    echo 0x03D729FC 1 > $DCC_PATH/config
    echo 0x03D72A00 1 > $DCC_PATH/config
    echo 0x03D72A04 1 > $DCC_PATH/config
    echo 0x03D72A08 1 > $DCC_PATH/config
    echo 0x03D72A0C 1 > $DCC_PATH/config
    echo 0x03D72A10 1 > $DCC_PATH/config
    echo 0x03D72A14 1 > $DCC_PATH/config
    echo 0x03D72A18 1 > $DCC_PATH/config
    echo 0x03D72A1C 1 > $DCC_PATH/config
    echo 0x03D72A20 1 > $DCC_PATH/config
    echo 0x03D72A24 1 > $DCC_PATH/config
    echo 0x03D72A28 1 > $DCC_PATH/config
    echo 0x03D72A2C 1 > $DCC_PATH/config
    echo 0x03D72A30 1 > $DCC_PATH/config
    echo 0x03D72A34 1 > $DCC_PATH/config
    echo 0x03D72A38 1 > $DCC_PATH/config
    echo 0x03D72A3C 1 > $DCC_PATH/config
    echo 0x03D72A40 1 > $DCC_PATH/config
    echo 0x03D72A44 1 > $DCC_PATH/config
    echo 0x03D72A48 1 > $DCC_PATH/config
    echo 0x03D72A4C 1 > $DCC_PATH/config
    echo 0x03D72A50 1 > $DCC_PATH/config
    echo 0x03D72A54 1 > $DCC_PATH/config
    echo 0x03D72A58 1 > $DCC_PATH/config
    echo 0x03D72A5C 1 > $DCC_PATH/config
    echo 0x03D72A60 1 > $DCC_PATH/config
    echo 0x03D72A64 1 > $DCC_PATH/config
    echo 0x03D72A68 1 > $DCC_PATH/config
    echo 0x03D72A6C 1 > $DCC_PATH/config
    echo 0x03D72A70 1 > $DCC_PATH/config
    echo 0x03D72A74 1 > $DCC_PATH/config
    echo 0x03D72A78 1 > $DCC_PATH/config
    echo 0x03D72A7C 1 > $DCC_PATH/config
    echo 0x03D72A80 1 > $DCC_PATH/config
    echo 0x03D72A84 1 > $DCC_PATH/config
    echo 0x03D72A88 1 > $DCC_PATH/config
    echo 0x03D72A8C 1 > $DCC_PATH/config
    echo 0x03D72A90 1 > $DCC_PATH/config
    echo 0x03D72A94 1 > $DCC_PATH/config
    echo 0x03D72A98 1 > $DCC_PATH/config
    echo 0x03D72A9C 1 > $DCC_PATH/config
    echo 0x03D72AA0 1 > $DCC_PATH/config
    echo 0x03D72AA4 1 > $DCC_PATH/config
    echo 0x03D72AA8 1 > $DCC_PATH/config
    echo 0x03D72AAC 1 > $DCC_PATH/config
    echo 0x03D72AB0 1 > $DCC_PATH/config
    echo 0x03D72AB4 1 > $DCC_PATH/config
    echo 0x03D72AB8 1 > $DCC_PATH/config
    echo 0x03D72ABC 1 > $DCC_PATH/config
    echo 0x03D72AC0 1 > $DCC_PATH/config
    echo 0x03D72AC4 1 > $DCC_PATH/config
    echo 0x03D72AC8 1 > $DCC_PATH/config
    echo 0x03D72ACC 1 > $DCC_PATH/config
    echo 0x03D72AD0 1 > $DCC_PATH/config
    echo 0x03D72AD4 1 > $DCC_PATH/config
    echo 0x03D72AD8 1 > $DCC_PATH/config
    echo 0x03D72ADC 1 > $DCC_PATH/config
    echo 0x03D72AE0 1 > $DCC_PATH/config
    echo 0x03D72AE4 1 > $DCC_PATH/config
    echo 0x03D72AE8 1 > $DCC_PATH/config
    echo 0x03D72AEC 1 > $DCC_PATH/config
    echo 0x03D72AF0 1 > $DCC_PATH/config
    echo 0x03D72AF4 1 > $DCC_PATH/config
    echo 0x03D72AF8 1 > $DCC_PATH/config
    echo 0x03D72AFC 1 > $DCC_PATH/config
    echo 0x03D72B00 1 > $DCC_PATH/config
    echo 0x03D72B04 1 > $DCC_PATH/config
    echo 0x03D72B08 1 > $DCC_PATH/config
    echo 0x03D72B0C 1 > $DCC_PATH/config
    echo 0x03D72B10 1 > $DCC_PATH/config
    echo 0x03D72B14 1 > $DCC_PATH/config
    echo 0x03D72B18 1 > $DCC_PATH/config
    echo 0x03D72B1C 1 > $DCC_PATH/config
    echo 0x03D72B20 1 > $DCC_PATH/config
    echo 0x03D72B24 1 > $DCC_PATH/config
    echo 0x03D72B28 1 > $DCC_PATH/config
    echo 0x03D72B2C 1 > $DCC_PATH/config
    echo 0x03D72B30 1 > $DCC_PATH/config
    echo 0x03D72B34 1 > $DCC_PATH/config
    echo 0x03D72B38 1 > $DCC_PATH/config
    echo 0x03D72B3C 1 > $DCC_PATH/config
    echo 0x03D72B40 1 > $DCC_PATH/config
    echo 0x03D72B44 1 > $DCC_PATH/config
    echo 0x03D72B48 1 > $DCC_PATH/config
    echo 0x03D72B4C 1 > $DCC_PATH/config
    echo 0x03D72B50 1 > $DCC_PATH/config
    echo 0x03D72B54 1 > $DCC_PATH/config
    echo 0x03D72B58 1 > $DCC_PATH/config
    echo 0x03D72B5C 1 > $DCC_PATH/config
    echo 0x03D72B60 1 > $DCC_PATH/config
    echo 0x03D72B64 1 > $DCC_PATH/config
    echo 0x03D72B68 1 > $DCC_PATH/config
    echo 0x03D72B6C 1 > $DCC_PATH/config
    echo 0x03D72B70 1 > $DCC_PATH/config
    echo 0x03D72B74 1 > $DCC_PATH/config
    echo 0x03D72B78 1 > $DCC_PATH/config
    echo 0x03D72B7C 1 > $DCC_PATH/config
    echo 0x03D72B80 1 > $DCC_PATH/config
    echo 0x03D72B84 1 > $DCC_PATH/config
    echo 0x03D72B88 1 > $DCC_PATH/config
    echo 0x03D72B8C 1 > $DCC_PATH/config
    echo 0x03D72B90 1 > $DCC_PATH/config
    echo 0x03D72B94 1 > $DCC_PATH/config
    echo 0x03D72B98 1 > $DCC_PATH/config
    echo 0x03D72B9C 1 > $DCC_PATH/config
    echo 0x03D72BA0 1 > $DCC_PATH/config
    echo 0x03D72BA4 1 > $DCC_PATH/config
    echo 0x03D72BA8 1 > $DCC_PATH/config
    echo 0x03D72BAC 1 > $DCC_PATH/config
    echo 0x03D72BB0 1 > $DCC_PATH/config
    echo 0x03D72BB4 1 > $DCC_PATH/config
    echo 0x03D72BB8 1 > $DCC_PATH/config
    echo 0x03D72BBC 1 > $DCC_PATH/config
    echo 0x03D72BC0 1 > $DCC_PATH/config
    echo 0x03D72BC4 1 > $DCC_PATH/config
    echo 0x03D72BC8 1 > $DCC_PATH/config
    echo 0x03D72BCC 1 > $DCC_PATH/config
    echo 0x03D72BD0 1 > $DCC_PATH/config
    echo 0x03D72BD4 1 > $DCC_PATH/config
    echo 0x03D72BD8 1 > $DCC_PATH/config
    echo 0x03D72BDC 1 > $DCC_PATH/config
    echo 0x03D72BE0 1 > $DCC_PATH/config
    echo 0x03D72BE4 1 > $DCC_PATH/config
    echo 0x03D72BE8 1 > $DCC_PATH/config
    echo 0x03D72BEC 1 > $DCC_PATH/config
    echo 0x03D72BF0 1 > $DCC_PATH/config
    echo 0x03D72BF4 1 > $DCC_PATH/config
    echo 0x03D72BF8 1 > $DCC_PATH/config
    echo 0x03D72BFC 1 > $DCC_PATH/config
    echo 0x03D72C00 1 > $DCC_PATH/config
    echo 0x03D72C04 1 > $DCC_PATH/config
    echo 0x03D72C08 1 > $DCC_PATH/config
    echo 0x03D72C0C 1 > $DCC_PATH/config
    echo 0x03D72C10 1 > $DCC_PATH/config
    echo 0x03D72C14 1 > $DCC_PATH/config
    echo 0x03D72C18 1 > $DCC_PATH/config
    echo 0x03D72C1C 1 > $DCC_PATH/config
    echo 0x03D72C20 1 > $DCC_PATH/config
    echo 0x03D72C24 1 > $DCC_PATH/config
    echo 0x03D72C28 1 > $DCC_PATH/config
    echo 0x03D72C2C 1 > $DCC_PATH/config
    echo 0x03D72C30 1 > $DCC_PATH/config
    echo 0x03D72C34 1 > $DCC_PATH/config
    echo 0x03D72C38 1 > $DCC_PATH/config
    echo 0x03D72C3C 1 > $DCC_PATH/config
    echo 0x03D72C40 1 > $DCC_PATH/config
    echo 0x03D72C44 1 > $DCC_PATH/config
    echo 0x03D72C48 1 > $DCC_PATH/config
    echo 0x03D72C4C 1 > $DCC_PATH/config
    echo 0x03D72C50 1 > $DCC_PATH/config
    echo 0x03D72C54 1 > $DCC_PATH/config
    echo 0x03D72C58 1 > $DCC_PATH/config
    echo 0x03D72C5C 1 > $DCC_PATH/config
    echo 0x03D72C60 1 > $DCC_PATH/config
    echo 0x03D72C64 1 > $DCC_PATH/config
    echo 0x03D72C68 1 > $DCC_PATH/config
    echo 0x03D72C6C 1 > $DCC_PATH/config
    echo 0x03D72C70 1 > $DCC_PATH/config
    echo 0x03D72C74 1 > $DCC_PATH/config
    echo 0x03D72C78 1 > $DCC_PATH/config
    echo 0x03D72C7C 1 > $DCC_PATH/config
    echo 0x03D72C80 1 > $DCC_PATH/config
    echo 0x03D72C84 1 > $DCC_PATH/config
    echo 0x03D72C88 1 > $DCC_PATH/config
    echo 0x03D72C8C 1 > $DCC_PATH/config
    echo 0x03D72C90 1 > $DCC_PATH/config
    echo 0x03D72C94 1 > $DCC_PATH/config
    echo 0x03D72C98 1 > $DCC_PATH/config
    echo 0x03D72C9C 1 > $DCC_PATH/config
    echo 0x03D72CA0 1 > $DCC_PATH/config
    echo 0x03D72CA4 1 > $DCC_PATH/config
    echo 0x03D72CA8 1 > $DCC_PATH/config
    echo 0x03D72CAC 1 > $DCC_PATH/config
    echo 0x03D72CB0 1 > $DCC_PATH/config
    echo 0x03D72CB4 1 > $DCC_PATH/config
    echo 0x03D72CB8 1 > $DCC_PATH/config
    echo 0x03D72CBC 1 > $DCC_PATH/config
    echo 0x03D72CC0 1 > $DCC_PATH/config
    echo 0x03D72CC4 1 > $DCC_PATH/config
    echo 0x03D72CC8 1 > $DCC_PATH/config
    echo 0x03D72CCC 1 > $DCC_PATH/config
    echo 0x03D72CD0 1 > $DCC_PATH/config
    echo 0x03D72CD4 1 > $DCC_PATH/config
    echo 0x03D72CD8 1 > $DCC_PATH/config
    echo 0x03D72CDC 1 > $DCC_PATH/config
    echo 0x03D72CE0 1 > $DCC_PATH/config
    echo 0x03D72CE4 1 > $DCC_PATH/config
    echo 0x03D72CE8 1 > $DCC_PATH/config
    echo 0x03D72CEC 1 > $DCC_PATH/config
    echo 0x03D72CF0 1 > $DCC_PATH/config
    echo 0x03D72CF4 1 > $DCC_PATH/config
    echo 0x03D72CF8 1 > $DCC_PATH/config
    echo 0x03D72CFC 1 > $DCC_PATH/config
    echo 0x03D72D00 1 > $DCC_PATH/config
    echo 0x03D72D04 1 > $DCC_PATH/config
    echo 0x03D72D08 1 > $DCC_PATH/config
    echo 0x03D72D0C 1 > $DCC_PATH/config
    echo 0x03D72D10 1 > $DCC_PATH/config
    echo 0x03D72D14 1 > $DCC_PATH/config
    echo 0x03D72D18 1 > $DCC_PATH/config
    echo 0x03D72D1C 1 > $DCC_PATH/config
    echo 0x03D72D20 1 > $DCC_PATH/config
    echo 0x03D72D24 1 > $DCC_PATH/config
    echo 0x03D72D28 1 > $DCC_PATH/config
    echo 0x03D72D2C 1 > $DCC_PATH/config
    echo 0x03D72D30 1 > $DCC_PATH/config
    echo 0x03D72D34 1 > $DCC_PATH/config
    echo 0x03D72D38 1 > $DCC_PATH/config
    echo 0x03D72D3C 1 > $DCC_PATH/config
    echo 0x03D72D40 1 > $DCC_PATH/config
    echo 0x03D72D44 1 > $DCC_PATH/config
    echo 0x03D72D48 1 > $DCC_PATH/config
    echo 0x03D72D4C 1 > $DCC_PATH/config
    echo 0x03D72D50 1 > $DCC_PATH/config
    echo 0x03D72D54 1 > $DCC_PATH/config
    echo 0x03D72D58 1 > $DCC_PATH/config
    echo 0x03D72D5C 1 > $DCC_PATH/config
    echo 0x03D72D60 1 > $DCC_PATH/config
    echo 0x03D72D64 1 > $DCC_PATH/config
    echo 0x03D72D68 1 > $DCC_PATH/config
    echo 0x03D72D6C 1 > $DCC_PATH/config
    echo 0x03D72D70 1 > $DCC_PATH/config
    echo 0x03D72D74 1 > $DCC_PATH/config
    echo 0x03D72D78 1 > $DCC_PATH/config
    echo 0x03D72D7C 1 > $DCC_PATH/config
    echo 0x03D72D80 1 > $DCC_PATH/config
    echo 0x03D72D84 1 > $DCC_PATH/config
    echo 0x03D72D88 1 > $DCC_PATH/config
    echo 0x03D72D8C 1 > $DCC_PATH/config
    echo 0x03D72D90 1 > $DCC_PATH/config
    echo 0x03D72D94 1 > $DCC_PATH/config
    echo 0x03D72D98 1 > $DCC_PATH/config
    echo 0x03D72D9C 1 > $DCC_PATH/config
    echo 0x03D72DA0 1 > $DCC_PATH/config
    echo 0x03D72DA4 1 > $DCC_PATH/config
    echo 0x03D72DA8 1 > $DCC_PATH/config
    echo 0x03D72DAC 1 > $DCC_PATH/config
    echo 0x03D72DB0 1 > $DCC_PATH/config
    echo 0x03D72DB4 1 > $DCC_PATH/config
    echo 0x03D72DB8 1 > $DCC_PATH/config
    echo 0x03D72DBC 1 > $DCC_PATH/config
    echo 0x03D72DC0 1 > $DCC_PATH/config
    echo 0x03D72DC4 1 > $DCC_PATH/config
    echo 0x03D72DC8 1 > $DCC_PATH/config
    echo 0x03D72DCC 1 > $DCC_PATH/config
    echo 0x03D72DD0 1 > $DCC_PATH/config
    echo 0x03D72DD4 1 > $DCC_PATH/config
    echo 0x03D72DD8 1 > $DCC_PATH/config
    echo 0x03D72DDC 1 > $DCC_PATH/config
    echo 0x03D72DE0 1 > $DCC_PATH/config
    echo 0x03D72DE4 1 > $DCC_PATH/config
    echo 0x03D72DE8 1 > $DCC_PATH/config
    echo 0x03D72DEC 1 > $DCC_PATH/config
    echo 0x03D72DF0 1 > $DCC_PATH/config
    echo 0x03D72DF4 1 > $DCC_PATH/config
    echo 0x03D72DF8 1 > $DCC_PATH/config
    echo 0x03D72DFC 1 > $DCC_PATH/config
    echo 0x03D72E00 1 > $DCC_PATH/config
    echo 0x03D72E04 1 > $DCC_PATH/config
    echo 0x03D72E08 1 > $DCC_PATH/config
    echo 0x03D72E0C 1 > $DCC_PATH/config
    echo 0x03D72E10 1 > $DCC_PATH/config
    echo 0x03D72E14 1 > $DCC_PATH/config
    echo 0x03D72E18 1 > $DCC_PATH/config
    echo 0x03D72E1C 1 > $DCC_PATH/config
    echo 0x03D72E20 1 > $DCC_PATH/config
    echo 0x03D72E24 1 > $DCC_PATH/config
    echo 0x03D72E28 1 > $DCC_PATH/config
    echo 0x03D72E2C 1 > $DCC_PATH/config
    echo 0x03D72E30 1 > $DCC_PATH/config
    echo 0x03D72E34 1 > $DCC_PATH/config
    echo 0x03D72E38 1 > $DCC_PATH/config
    echo 0x03D72E3C 1 > $DCC_PATH/config
    echo 0x03D72E40 1 > $DCC_PATH/config
    echo 0x03D72E44 1 > $DCC_PATH/config
    echo 0x03D72E48 1 > $DCC_PATH/config
    echo 0x03D72E4C 1 > $DCC_PATH/config
    echo 0x03D72E50 1 > $DCC_PATH/config
    echo 0x03D72E54 1 > $DCC_PATH/config
    echo 0x03D72E58 1 > $DCC_PATH/config
    echo 0x03D72E5C 1 > $DCC_PATH/config
    echo 0x03D72E60 1 > $DCC_PATH/config
    echo 0x03D72E64 1 > $DCC_PATH/config
    echo 0x03D72E68 1 > $DCC_PATH/config
    echo 0x03D72E6C 1 > $DCC_PATH/config
    echo 0x03D72E70 1 > $DCC_PATH/config
    echo 0x03D72E74 1 > $DCC_PATH/config
    echo 0x03D72E78 1 > $DCC_PATH/config
    echo 0x03D72E7C 1 > $DCC_PATH/config
    echo 0x03D72E80 1 > $DCC_PATH/config
    echo 0x03D72E84 1 > $DCC_PATH/config
    echo 0x03D72E88 1 > $DCC_PATH/config
    echo 0x03D72E8C 1 > $DCC_PATH/config
    echo 0x03D72E90 1 > $DCC_PATH/config
    echo 0x03D72E94 1 > $DCC_PATH/config
    echo 0x03D72E98 1 > $DCC_PATH/config
    echo 0x03D72E9C 1 > $DCC_PATH/config
    echo 0x03D72EA0 1 > $DCC_PATH/config
    echo 0x03D72EA4 1 > $DCC_PATH/config
    echo 0x03D72EA8 1 > $DCC_PATH/config
    echo 0x03D72EAC 1 > $DCC_PATH/config
    echo 0x03D72EB0 1 > $DCC_PATH/config
    echo 0x03D72EB4 1 > $DCC_PATH/config
    echo 0x03D72EB8 1 > $DCC_PATH/config
    echo 0x03D72EBC 1 > $DCC_PATH/config
    echo 0x03D72EC0 1 > $DCC_PATH/config
    echo 0x03D72EC4 1 > $DCC_PATH/config
    echo 0x03D72EC8 1 > $DCC_PATH/config
    echo 0x03D72ECC 1 > $DCC_PATH/config
    echo 0x03D72ED0 1 > $DCC_PATH/config
    echo 0x03D72ED4 1 > $DCC_PATH/config
    echo 0x03D72ED8 1 > $DCC_PATH/config
    echo 0x03D72EDC 1 > $DCC_PATH/config
    echo 0x03D72EE0 1 > $DCC_PATH/config
    echo 0x03D72EE4 1 > $DCC_PATH/config
    echo 0x03D72EE8 1 > $DCC_PATH/config
    echo 0x03D72EEC 1 > $DCC_PATH/config
    echo 0x03D72EF0 1 > $DCC_PATH/config
    echo 0x03D72EF4 1 > $DCC_PATH/config
    echo 0x03D72EF8 1 > $DCC_PATH/config
    echo 0x03D72EFC 1 > $DCC_PATH/config
    echo 0x03D72F00 1 > $DCC_PATH/config
    echo 0x03D72F04 1 > $DCC_PATH/config
    echo 0x03D72F08 1 > $DCC_PATH/config
    echo 0x03D72F0C 1 > $DCC_PATH/config
    echo 0x03D72F10 1 > $DCC_PATH/config
    echo 0x03D72F14 1 > $DCC_PATH/config
    echo 0x03D72F18 1 > $DCC_PATH/config
    echo 0x03D72F1C 1 > $DCC_PATH/config
    echo 0x03D72F20 1 > $DCC_PATH/config
    echo 0x03D72F24 1 > $DCC_PATH/config
    echo 0x03D72F28 1 > $DCC_PATH/config
    echo 0x03D72F2C 1 > $DCC_PATH/config
    echo 0x03D72F30 1 > $DCC_PATH/config
    echo 0x03D72F34 1 > $DCC_PATH/config
    echo 0x03D72F38 1 > $DCC_PATH/config
    echo 0x03D72F3C 1 > $DCC_PATH/config
    echo 0x03D72F40 1 > $DCC_PATH/config
    echo 0x03D72F44 1 > $DCC_PATH/config
    echo 0x03D72F48 1 > $DCC_PATH/config
    echo 0x03D72F4C 1 > $DCC_PATH/config
    echo 0x03D72F50 1 > $DCC_PATH/config
    echo 0x03D72F54 1 > $DCC_PATH/config
    echo 0x03D72F58 1 > $DCC_PATH/config
    echo 0x03D72F5C 1 > $DCC_PATH/config
    echo 0x03D72F60 1 > $DCC_PATH/config
    echo 0x03D72F64 1 > $DCC_PATH/config
    echo 0x03D72F68 1 > $DCC_PATH/config
    echo 0x03D72F6C 1 > $DCC_PATH/config
    echo 0x03D72F70 1 > $DCC_PATH/config
    echo 0x03D72F74 1 > $DCC_PATH/config
    echo 0x03D72F78 1 > $DCC_PATH/config
    echo 0x03D72F7C 1 > $DCC_PATH/config
    echo 0x03D72F80 1 > $DCC_PATH/config
    echo 0x03D72F84 1 > $DCC_PATH/config
    echo 0x03D72F88 1 > $DCC_PATH/config
    echo 0x03D72F8C 1 > $DCC_PATH/config
    echo 0x03D72F90 1 > $DCC_PATH/config
    echo 0x03D72F94 1 > $DCC_PATH/config
    echo 0x03D72F98 1 > $DCC_PATH/config
    echo 0x03D72F9C 1 > $DCC_PATH/config
    echo 0x03D72FA0 1 > $DCC_PATH/config
    echo 0x03D72FA4 1 > $DCC_PATH/config
    echo 0x03D72FA8 1 > $DCC_PATH/config
    echo 0x03D72FAC 1 > $DCC_PATH/config
    echo 0x03D72FB0 1 > $DCC_PATH/config
    echo 0x03D72FB4 1 > $DCC_PATH/config
    echo 0x03D72FB8 1 > $DCC_PATH/config
    echo 0x03D72FBC 1 > $DCC_PATH/config
    echo 0x03D72FC0 1 > $DCC_PATH/config
    echo 0x03D72FC4 1 > $DCC_PATH/config
    echo 0x03D72FC8 1 > $DCC_PATH/config
    echo 0x03D72FCC 1 > $DCC_PATH/config
    echo 0x03D72FD0 1 > $DCC_PATH/config
    echo 0x03D72FD4 1 > $DCC_PATH/config
    echo 0x03D72FD8 1 > $DCC_PATH/config
    echo 0x03D72FDC 1 > $DCC_PATH/config
    echo 0x03D72FE0 1 > $DCC_PATH/config
    echo 0x03D72FE4 1 > $DCC_PATH/config
    echo 0x03D72FE8 1 > $DCC_PATH/config
    echo 0x03D72FEC 1 > $DCC_PATH/config
    echo 0x03D72FF0 1 > $DCC_PATH/config
    echo 0x03D72FF4 1 > $DCC_PATH/config
    echo 0x03D72FF8 1 > $DCC_PATH/config
    echo 0x03D72FFC 1 > $DCC_PATH/config
    echo 0x03D73000 1 > $DCC_PATH/config
    echo 0x03D73004 1 > $DCC_PATH/config
    echo 0x03D73008 1 > $DCC_PATH/config
    echo 0x03D7300C 1 > $DCC_PATH/config
    echo 0x03D73010 1 > $DCC_PATH/config
    echo 0x03D73014 1 > $DCC_PATH/config
    echo 0x03D73018 1 > $DCC_PATH/config
    echo 0x03D7301C 1 > $DCC_PATH/config
    echo 0x03D73020 1 > $DCC_PATH/config
    echo 0x03D73024 1 > $DCC_PATH/config
    echo 0x03D73028 1 > $DCC_PATH/config
    echo 0x03D7302C 1 > $DCC_PATH/config
    echo 0x03D73030 1 > $DCC_PATH/config
    echo 0x03D73034 1 > $DCC_PATH/config
    echo 0x03D73038 1 > $DCC_PATH/config
    echo 0x03D7303C 1 > $DCC_PATH/config
    echo 0x03D73040 1 > $DCC_PATH/config
    echo 0x03D73044 1 > $DCC_PATH/config
    echo 0x03D73048 1 > $DCC_PATH/config
    echo 0x03D7304C 1 > $DCC_PATH/config
    echo 0x03D73050 1 > $DCC_PATH/config
    echo 0x03D73054 1 > $DCC_PATH/config
    echo 0x03D73058 1 > $DCC_PATH/config
    echo 0x03D7305C 1 > $DCC_PATH/config
    echo 0x03D73060 1 > $DCC_PATH/config
    echo 0x03D73064 1 > $DCC_PATH/config
    echo 0x03D73068 1 > $DCC_PATH/config
    echo 0x03D7306C 1 > $DCC_PATH/config
    echo 0x03D73070 1 > $DCC_PATH/config
    echo 0x03D73074 1 > $DCC_PATH/config
    echo 0x03D73078 1 > $DCC_PATH/config
    echo 0x03D7307C 1 > $DCC_PATH/config
    echo 0x03D73080 1 > $DCC_PATH/config
    echo 0x03D73084 1 > $DCC_PATH/config
    echo 0x03D73088 1 > $DCC_PATH/config
    echo 0x03D7308C 1 > $DCC_PATH/config
    echo 0x03D73090 1 > $DCC_PATH/config
    echo 0x03D73094 1 > $DCC_PATH/config
    echo 0x03D73098 1 > $DCC_PATH/config
    echo 0x03D7309C 1 > $DCC_PATH/config
    echo 0x03D730A0 1 > $DCC_PATH/config
    echo 0x03D730A4 1 > $DCC_PATH/config
    echo 0x03D730A8 1 > $DCC_PATH/config
    echo 0x03D730AC 1 > $DCC_PATH/config
    echo 0x03D730B0 1 > $DCC_PATH/config
    echo 0x03D730B4 1 > $DCC_PATH/config
    echo 0x03D730B8 1 > $DCC_PATH/config
    echo 0x03D730BC 1 > $DCC_PATH/config
    echo 0x03D730C0 1 > $DCC_PATH/config
    echo 0x03D730C4 1 > $DCC_PATH/config
    echo 0x03D730C8 1 > $DCC_PATH/config
    echo 0x03D730CC 1 > $DCC_PATH/config
    echo 0x03D730D0 1 > $DCC_PATH/config
    echo 0x03D730D4 1 > $DCC_PATH/config
    echo 0x03D730D8 1 > $DCC_PATH/config
    echo 0x03D730DC 1 > $DCC_PATH/config
    echo 0x03D730E0 1 > $DCC_PATH/config
    echo 0x03D730E4 1 > $DCC_PATH/config
    echo 0x03D730E8 1 > $DCC_PATH/config
    echo 0x03D730EC 1 > $DCC_PATH/config
    echo 0x03D730F0 1 > $DCC_PATH/config
    echo 0x03D730F4 1 > $DCC_PATH/config
    echo 0x03D730F8 1 > $DCC_PATH/config
    echo 0x03D730FC 1 > $DCC_PATH/config
    echo 0x03D73100 1 > $DCC_PATH/config
    echo 0x03D73104 1 > $DCC_PATH/config
    echo 0x03D73108 1 > $DCC_PATH/config
    echo 0x03D7310C 1 > $DCC_PATH/config
    echo 0x03D73110 1 > $DCC_PATH/config
    echo 0x03D73114 1 > $DCC_PATH/config
    echo 0x03D73118 1 > $DCC_PATH/config
    echo 0x03D7311C 1 > $DCC_PATH/config
    echo 0x03D73120 1 > $DCC_PATH/config
    echo 0x03D73124 1 > $DCC_PATH/config
    echo 0x03D73128 1 > $DCC_PATH/config
    echo 0x03D7312C 1 > $DCC_PATH/config
    echo 0x03D73130 1 > $DCC_PATH/config
    echo 0x03D73134 1 > $DCC_PATH/config
    echo 0x03D73138 1 > $DCC_PATH/config
    echo 0x03D7313C 1 > $DCC_PATH/config
    echo 0x03D73140 1 > $DCC_PATH/config
    echo 0x03D73144 1 > $DCC_PATH/config
    echo 0x03D73148 1 > $DCC_PATH/config
    echo 0x03D7314C 1 > $DCC_PATH/config
    echo 0x03D73150 1 > $DCC_PATH/config
    echo 0x03D73154 1 > $DCC_PATH/config
    echo 0x03D73158 1 > $DCC_PATH/config
    echo 0x03D7315C 1 > $DCC_PATH/config
    echo 0x03D73160 1 > $DCC_PATH/config
    echo 0x03D73164 1 > $DCC_PATH/config
    echo 0x03D73168 1 > $DCC_PATH/config
    echo 0x03D7316C 1 > $DCC_PATH/config
    echo 0x03D73170 1 > $DCC_PATH/config
    echo 0x03D73174 1 > $DCC_PATH/config
    echo 0x03D73178 1 > $DCC_PATH/config
    echo 0x03D7317C 1 > $DCC_PATH/config
    echo 0x03D73180 1 > $DCC_PATH/config
    echo 0x03D73184 1 > $DCC_PATH/config
    echo 0x03D73188 1 > $DCC_PATH/config
    echo 0x03D7318C 1 > $DCC_PATH/config
    echo 0x03D73190 1 > $DCC_PATH/config
    echo 0x03D73194 1 > $DCC_PATH/config
    echo 0x03D73198 1 > $DCC_PATH/config
    echo 0x03D7319C 1 > $DCC_PATH/config
    echo 0x03D731A0 1 > $DCC_PATH/config
    echo 0x03D731A4 1 > $DCC_PATH/config
    echo 0x03D731A8 1 > $DCC_PATH/config
    echo 0x03D731AC 1 > $DCC_PATH/config
    echo 0x03D731B0 1 > $DCC_PATH/config
    echo 0x03D731B4 1 > $DCC_PATH/config
    echo 0x03D731B8 1 > $DCC_PATH/config
    echo 0x03D731BC 1 > $DCC_PATH/config
    echo 0x03D731C0 1 > $DCC_PATH/config
    echo 0x03D731C4 1 > $DCC_PATH/config
    echo 0x03D731C8 1 > $DCC_PATH/config
    echo 0x03D731CC 1 > $DCC_PATH/config
    echo 0x03D731D0 1 > $DCC_PATH/config
    echo 0x03D731D4 1 > $DCC_PATH/config
    echo 0x03D731D8 1 > $DCC_PATH/config
    echo 0x03D731DC 1 > $DCC_PATH/config
    echo 0x03D731E0 1 > $DCC_PATH/config
    echo 0x03D731E4 1 > $DCC_PATH/config
    echo 0x03D731E8 1 > $DCC_PATH/config
    echo 0x03D731EC 1 > $DCC_PATH/config
    echo 0x03D731F0 1 > $DCC_PATH/config
    echo 0x03D731F4 1 > $DCC_PATH/config
    echo 0x03D731F8 1 > $DCC_PATH/config
    echo 0x03D731FC 1 > $DCC_PATH/config
    echo 0x03D73200 1 > $DCC_PATH/config
    echo 0x03D73204 1 > $DCC_PATH/config
    echo 0x03D73208 1 > $DCC_PATH/config
    echo 0x03D7320C 1 > $DCC_PATH/config
    echo 0x03D73210 1 > $DCC_PATH/config
    echo 0x03D73214 1 > $DCC_PATH/config
    echo 0x03D73218 1 > $DCC_PATH/config
    echo 0x03D7321C 1 > $DCC_PATH/config
    echo 0x03D73220 1 > $DCC_PATH/config
    echo 0x03D73224 1 > $DCC_PATH/config
    echo 0x03D73228 1 > $DCC_PATH/config
    echo 0x03D7322C 1 > $DCC_PATH/config
    echo 0x03D73230 1 > $DCC_PATH/config
    echo 0x03D73234 1 > $DCC_PATH/config
    echo 0x03D73238 1 > $DCC_PATH/config
    echo 0x03D7323C 1 > $DCC_PATH/config
    echo 0x03D73240 1 > $DCC_PATH/config
    echo 0x03D73244 1 > $DCC_PATH/config
    echo 0x03D73248 1 > $DCC_PATH/config
    echo 0x03D7324C 1 > $DCC_PATH/config
    echo 0x03D73250 1 > $DCC_PATH/config
    echo 0x03D73254 1 > $DCC_PATH/config
    echo 0x03D73258 1 > $DCC_PATH/config
    echo 0x03D7325C 1 > $DCC_PATH/config
    echo 0x03D73260 1 > $DCC_PATH/config
    echo 0x03D73264 1 > $DCC_PATH/config
    echo 0x03D73268 1 > $DCC_PATH/config
    echo 0x03D7326C 1 > $DCC_PATH/config
    echo 0x03D73270 1 > $DCC_PATH/config
    echo 0x03D73274 1 > $DCC_PATH/config
    echo 0x03D73278 1 > $DCC_PATH/config
    echo 0x03D7327C 1 > $DCC_PATH/config
    echo 0x03D73280 1 > $DCC_PATH/config
    echo 0x03D73284 1 > $DCC_PATH/config
    echo 0x03D73288 1 > $DCC_PATH/config
    echo 0x03D7328C 1 > $DCC_PATH/config
    echo 0x03D73290 1 > $DCC_PATH/config
    echo 0x03D73294 1 > $DCC_PATH/config
    echo 0x03D73298 1 > $DCC_PATH/config
    echo 0x03D7329C 1 > $DCC_PATH/config
    echo 0x03D732A0 1 > $DCC_PATH/config
    echo 0x03D732A4 1 > $DCC_PATH/config
    echo 0x03D732A8 1 > $DCC_PATH/config
    echo 0x03D732AC 1 > $DCC_PATH/config
    echo 0x03D732B0 1 > $DCC_PATH/config
    echo 0x03D732B4 1 > $DCC_PATH/config
    echo 0x03D732B8 1 > $DCC_PATH/config
    echo 0x03D732BC 1 > $DCC_PATH/config
    echo 0x03D732C0 1 > $DCC_PATH/config
    echo 0x03D732C4 1 > $DCC_PATH/config
    echo 0x03D732C8 1 > $DCC_PATH/config
    echo 0x03D732CC 1 > $DCC_PATH/config
    echo 0x03D732D0 1 > $DCC_PATH/config
    echo 0x03D732D4 1 > $DCC_PATH/config
    echo 0x03D732D8 1 > $DCC_PATH/config
    echo 0x03D732DC 1 > $DCC_PATH/config
    echo 0x03D732E0 1 > $DCC_PATH/config
    echo 0x03D732E4 1 > $DCC_PATH/config
    echo 0x03D732E8 1 > $DCC_PATH/config
    echo 0x03D732EC 1 > $DCC_PATH/config
    echo 0x03D732F0 1 > $DCC_PATH/config
    echo 0x03D732F4 1 > $DCC_PATH/config
    echo 0x03D732F8 1 > $DCC_PATH/config
    echo 0x03D732FC 1 > $DCC_PATH/config
    echo 0x03D73300 1 > $DCC_PATH/config
    echo 0x03D73304 1 > $DCC_PATH/config
    echo 0x03D73308 1 > $DCC_PATH/config
    echo 0x03D7330C 1 > $DCC_PATH/config
    echo 0x03D73310 1 > $DCC_PATH/config
    echo 0x03D73314 1 > $DCC_PATH/config
    echo 0x03D73318 1 > $DCC_PATH/config
    echo 0x03D7331C 1 > $DCC_PATH/config
    echo 0x03D73320 1 > $DCC_PATH/config
    echo 0x03D73324 1 > $DCC_PATH/config
    echo 0x03D73328 1 > $DCC_PATH/config
    echo 0x03D7332C 1 > $DCC_PATH/config
    echo 0x03D73330 1 > $DCC_PATH/config
    echo 0x03D73334 1 > $DCC_PATH/config
    echo 0x03D73338 1 > $DCC_PATH/config
    echo 0x03D7333C 1 > $DCC_PATH/config
    echo 0x03D73340 1 > $DCC_PATH/config
    echo 0x03D73344 1 > $DCC_PATH/config
    echo 0x03D73348 1 > $DCC_PATH/config
    echo 0x03D7334C 1 > $DCC_PATH/config
    echo 0x03D73350 1 > $DCC_PATH/config
    echo 0x03D73354 1 > $DCC_PATH/config
    echo 0x03D73358 1 > $DCC_PATH/config
    echo 0x03D7335C 1 > $DCC_PATH/config
    echo 0x03D73360 1 > $DCC_PATH/config
    echo 0x03D73364 1 > $DCC_PATH/config
    echo 0x03D73368 1 > $DCC_PATH/config
    echo 0x03D7336C 1 > $DCC_PATH/config
    echo 0x03D73370 1 > $DCC_PATH/config
    echo 0x03D73374 1 > $DCC_PATH/config
    echo 0x03D73378 1 > $DCC_PATH/config
    echo 0x03D7337C 1 > $DCC_PATH/config
    echo 0x03D73380 1 > $DCC_PATH/config
    echo 0x03D73384 1 > $DCC_PATH/config
    echo 0x03D73388 1 > $DCC_PATH/config
    echo 0x03D7338C 1 > $DCC_PATH/config
    echo 0x03D73390 1 > $DCC_PATH/config
    echo 0x03D73394 1 > $DCC_PATH/config
    echo 0x03D73398 1 > $DCC_PATH/config
    echo 0x03D7339C 1 > $DCC_PATH/config
    echo 0x03D733A0 1 > $DCC_PATH/config
    echo 0x03D733A4 1 > $DCC_PATH/config
    echo 0x03D733A8 1 > $DCC_PATH/config
    echo 0x03D733AC 1 > $DCC_PATH/config
    echo 0x03D733B0 1 > $DCC_PATH/config
    echo 0x03D733B4 1 > $DCC_PATH/config
    echo 0x03D733B8 1 > $DCC_PATH/config
    echo 0x03D733BC 1 > $DCC_PATH/config
    echo 0x03D733C0 1 > $DCC_PATH/config
    echo 0x03D733C4 1 > $DCC_PATH/config
    echo 0x03D733C8 1 > $DCC_PATH/config
    echo 0x03D733CC 1 > $DCC_PATH/config
    echo 0x03D733D0 1 > $DCC_PATH/config
    echo 0x03D733D4 1 > $DCC_PATH/config
    echo 0x03D733D8 1 > $DCC_PATH/config
    echo 0x03D733DC 1 > $DCC_PATH/config
    echo 0x03D733E0 1 > $DCC_PATH/config
    echo 0x03D733E4 1 > $DCC_PATH/config
    echo 0x03D733E8 1 > $DCC_PATH/config
    echo 0x03D733EC 1 > $DCC_PATH/config
    echo 0x03D733F0 1 > $DCC_PATH/config
    echo 0x03D733F4 1 > $DCC_PATH/config
    echo 0x03D733F8 1 > $DCC_PATH/config
    echo 0x03D733FC 1 > $DCC_PATH/config
    echo 0x03D73400 1 > $DCC_PATH/config
    echo 0x03D73404 1 > $DCC_PATH/config
    echo 0x03D73408 1 > $DCC_PATH/config
    echo 0x03D7340C 1 > $DCC_PATH/config
    echo 0x03D73410 1 > $DCC_PATH/config
    echo 0x03D73414 1 > $DCC_PATH/config
    echo 0x03D73418 1 > $DCC_PATH/config
    echo 0x03D7341C 1 > $DCC_PATH/config
    echo 0x03D73420 1 > $DCC_PATH/config
    echo 0x03D73424 1 > $DCC_PATH/config
    echo 0x03D73428 1 > $DCC_PATH/config
    echo 0x03D7342C 1 > $DCC_PATH/config
    echo 0x03D73430 1 > $DCC_PATH/config
    echo 0x03D73434 1 > $DCC_PATH/config
    echo 0x03D73438 1 > $DCC_PATH/config
    echo 0x03D7343C 1 > $DCC_PATH/config
    echo 0x03D73440 1 > $DCC_PATH/config
    echo 0x03D73444 1 > $DCC_PATH/config
    echo 0x03D73448 1 > $DCC_PATH/config
    echo 0x03D7344C 1 > $DCC_PATH/config
    echo 0x03D73450 1 > $DCC_PATH/config
    echo 0x03D73454 1 > $DCC_PATH/config
    echo 0x03D73458 1 > $DCC_PATH/config
    echo 0x03D7345C 1 > $DCC_PATH/config
    echo 0x03D73460 1 > $DCC_PATH/config
    echo 0x03D73464 1 > $DCC_PATH/config
    echo 0x03D73468 1 > $DCC_PATH/config
    echo 0x03D7346C 1 > $DCC_PATH/config
    echo 0x03D73470 1 > $DCC_PATH/config
    echo 0x03D73474 1 > $DCC_PATH/config
    echo 0x03D73478 1 > $DCC_PATH/config
    echo 0x03D7347C 1 > $DCC_PATH/config
    echo 0x03D73480 1 > $DCC_PATH/config
    echo 0x03D73484 1 > $DCC_PATH/config
    echo 0x03D73488 1 > $DCC_PATH/config
    echo 0x03D7348C 1 > $DCC_PATH/config
    echo 0x03D73490 1 > $DCC_PATH/config
    echo 0x03D73494 1 > $DCC_PATH/config
    echo 0x03D73498 1 > $DCC_PATH/config
    echo 0x03D7349C 1 > $DCC_PATH/config
    echo 0x03D734A0 1 > $DCC_PATH/config
    echo 0x03D734A4 1 > $DCC_PATH/config
    echo 0x03D734A8 1 > $DCC_PATH/config
    echo 0x03D734AC 1 > $DCC_PATH/config
    echo 0x03D734B0 1 > $DCC_PATH/config
    echo 0x03D734B4 1 > $DCC_PATH/config
    echo 0x03D734B8 1 > $DCC_PATH/config
    echo 0x03D734BC 1 > $DCC_PATH/config
    echo 0x03D734C0 1 > $DCC_PATH/config
    echo 0x03D734C4 1 > $DCC_PATH/config
    echo 0x03D734C8 1 > $DCC_PATH/config
    echo 0x03D734CC 1 > $DCC_PATH/config
    echo 0x03D734D0 1 > $DCC_PATH/config
    echo 0x03D734D4 1 > $DCC_PATH/config
    echo 0x03D734D8 1 > $DCC_PATH/config
    echo 0x03D734DC 1 > $DCC_PATH/config
    echo 0x03D734E0 1 > $DCC_PATH/config
    echo 0x03D734E4 1 > $DCC_PATH/config
    echo 0x03D734E8 1 > $DCC_PATH/config
    echo 0x03D734EC 1 > $DCC_PATH/config
    echo 0x03D734F0 1 > $DCC_PATH/config
    echo 0x03D734F4 1 > $DCC_PATH/config
    echo 0x03D734F8 1 > $DCC_PATH/config
    echo 0x03D734FC 1 > $DCC_PATH/config
    echo 0x03D73500 1 > $DCC_PATH/config
    echo 0x03D73504 1 > $DCC_PATH/config
    echo 0x03D73508 1 > $DCC_PATH/config
    echo 0x03D7350C 1 > $DCC_PATH/config
    echo 0x03D73510 1 > $DCC_PATH/config
    echo 0x03D73514 1 > $DCC_PATH/config
    echo 0x03D73518 1 > $DCC_PATH/config
    echo 0x03D7351C 1 > $DCC_PATH/config
    echo 0x03D73520 1 > $DCC_PATH/config
    echo 0x03D73524 1 > $DCC_PATH/config
    echo 0x03D73528 1 > $DCC_PATH/config
    echo 0x03D7352C 1 > $DCC_PATH/config
    echo 0x03D73530 1 > $DCC_PATH/config
    echo 0x03D73534 1 > $DCC_PATH/config
    echo 0x03D73538 1 > $DCC_PATH/config
    echo 0x03D7353C 1 > $DCC_PATH/config
    echo 0x03D73540 1 > $DCC_PATH/config
    echo 0x03D73544 1 > $DCC_PATH/config
    echo 0x03D73548 1 > $DCC_PATH/config
    echo 0x03D7354C 1 > $DCC_PATH/config
    echo 0x03D73550 1 > $DCC_PATH/config
    echo 0x03D73554 1 > $DCC_PATH/config
    echo 0x03D73558 1 > $DCC_PATH/config
    echo 0x03D7355C 1 > $DCC_PATH/config
    echo 0x03D73560 1 > $DCC_PATH/config
    echo 0x03D73564 1 > $DCC_PATH/config
    echo 0x03D73568 1 > $DCC_PATH/config
    echo 0x03D7356C 1 > $DCC_PATH/config
    echo 0x03D73570 1 > $DCC_PATH/config
    echo 0x03D73574 1 > $DCC_PATH/config
    echo 0x03D73578 1 > $DCC_PATH/config
    echo 0x03D7357C 1 > $DCC_PATH/config
    echo 0x03D73580 1 > $DCC_PATH/config
    echo 0x03D73584 1 > $DCC_PATH/config
    echo 0x03D73588 1 > $DCC_PATH/config
    echo 0x03D7358C 1 > $DCC_PATH/config
    echo 0x03D73590 1 > $DCC_PATH/config
    echo 0x03D73594 1 > $DCC_PATH/config
    echo 0x03D73598 1 > $DCC_PATH/config
    echo 0x03D7359C 1 > $DCC_PATH/config
    echo 0x03D735A0 1 > $DCC_PATH/config
    echo 0x03D735A4 1 > $DCC_PATH/config
    echo 0x03D735A8 1 > $DCC_PATH/config
    echo 0x03D735AC 1 > $DCC_PATH/config
    echo 0x03D735B0 1 > $DCC_PATH/config
    echo 0x03D735B4 1 > $DCC_PATH/config
    echo 0x03D735B8 1 > $DCC_PATH/config
    echo 0x03D735BC 1 > $DCC_PATH/config
    echo 0x03D735C0 1 > $DCC_PATH/config
    echo 0x03D735C4 1 > $DCC_PATH/config
    echo 0x03D735C8 1 > $DCC_PATH/config
    echo 0x03D735CC 1 > $DCC_PATH/config
    echo 0x03D735D0 1 > $DCC_PATH/config
    echo 0x03D735D4 1 > $DCC_PATH/config
    echo 0x03D735D8 1 > $DCC_PATH/config
    echo 0x03D735DC 1 > $DCC_PATH/config
    echo 0x03D735E0 1 > $DCC_PATH/config
    echo 0x03D735E4 1 > $DCC_PATH/config
    echo 0x03D735E8 1 > $DCC_PATH/config
    echo 0x03D735EC 1 > $DCC_PATH/config
    echo 0x03D735F0 1 > $DCC_PATH/config
    echo 0x03D735F4 1 > $DCC_PATH/config
    echo 0x03D735F8 1 > $DCC_PATH/config
    echo 0x03D735FC 1 > $DCC_PATH/config
    echo 0x03D73600 1 > $DCC_PATH/config
    echo 0x03D73604 1 > $DCC_PATH/config
    echo 0x03D73608 1 > $DCC_PATH/config
    echo 0x03D7360C 1 > $DCC_PATH/config
    echo 0x03D73610 1 > $DCC_PATH/config
    echo 0x03D73614 1 > $DCC_PATH/config
    echo 0x03D73618 1 > $DCC_PATH/config
    echo 0x03D7361C 1 > $DCC_PATH/config
    echo 0x03D73620 1 > $DCC_PATH/config
    echo 0x03D73624 1 > $DCC_PATH/config
    echo 0x03D73628 1 > $DCC_PATH/config
    echo 0x03D7362C 1 > $DCC_PATH/config
    echo 0x03D73630 1 > $DCC_PATH/config
    echo 0x03D73634 1 > $DCC_PATH/config
    echo 0x03D73638 1 > $DCC_PATH/config
    echo 0x03D7363C 1 > $DCC_PATH/config
    echo 0x03D73640 1 > $DCC_PATH/config
    echo 0x03D73644 1 > $DCC_PATH/config
    echo 0x03D73648 1 > $DCC_PATH/config
    echo 0x03D7364C 1 > $DCC_PATH/config
    echo 0x03D73650 1 > $DCC_PATH/config
    echo 0x03D73654 1 > $DCC_PATH/config
    echo 0x03D73658 1 > $DCC_PATH/config
    echo 0x03D7365C 1 > $DCC_PATH/config
    echo 0x03D73660 1 > $DCC_PATH/config
    echo 0x03D73664 1 > $DCC_PATH/config
    echo 0x03D73668 1 > $DCC_PATH/config
    echo 0x03D7366C 1 > $DCC_PATH/config
    echo 0x03D73670 1 > $DCC_PATH/config
    echo 0x03D73674 1 > $DCC_PATH/config
    echo 0x03D73678 1 > $DCC_PATH/config
    echo 0x03D7367C 1 > $DCC_PATH/config
    echo 0x03D73680 1 > $DCC_PATH/config
    echo 0x03D73684 1 > $DCC_PATH/config
    echo 0x03D73688 1 > $DCC_PATH/config
    echo 0x03D7368C 1 > $DCC_PATH/config
    echo 0x03D73690 1 > $DCC_PATH/config
    echo 0x03D73694 1 > $DCC_PATH/config
    echo 0x03D73698 1 > $DCC_PATH/config
    echo 0x03D7369C 1 > $DCC_PATH/config
    echo 0x03D736A0 1 > $DCC_PATH/config
    echo 0x03D736A4 1 > $DCC_PATH/config
    echo 0x03D736A8 1 > $DCC_PATH/config
    echo 0x03D736AC 1 > $DCC_PATH/config
    echo 0x03D736B0 1 > $DCC_PATH/config
    echo 0x03D736B4 1 > $DCC_PATH/config
    echo 0x03D736B8 1 > $DCC_PATH/config
    echo 0x03D736BC 1 > $DCC_PATH/config
    echo 0x03D736C0 1 > $DCC_PATH/config
    echo 0x03D736C4 1 > $DCC_PATH/config
    echo 0x03D736C8 1 > $DCC_PATH/config
    echo 0x03D736CC 1 > $DCC_PATH/config
    echo 0x03D736D0 1 > $DCC_PATH/config
    echo 0x03D736D4 1 > $DCC_PATH/config
    echo 0x03D736D8 1 > $DCC_PATH/config
    echo 0x03D736DC 1 > $DCC_PATH/config
    echo 0x03D736E0 1 > $DCC_PATH/config
    echo 0x03D736E4 1 > $DCC_PATH/config
    echo 0x03D736E8 1 > $DCC_PATH/config
    echo 0x03D736EC 1 > $DCC_PATH/config
    echo 0x03D736F0 1 > $DCC_PATH/config
    echo 0x03D736F4 1 > $DCC_PATH/config
    echo 0x03D736F8 1 > $DCC_PATH/config
    echo 0x03D736FC 1 > $DCC_PATH/config
    echo 0x03D73700 1 > $DCC_PATH/config
    echo 0x03D73704 1 > $DCC_PATH/config
    echo 0x03D73708 1 > $DCC_PATH/config
    echo 0x03D7370C 1 > $DCC_PATH/config
    echo 0x03D73710 1 > $DCC_PATH/config
    echo 0x03D73714 1 > $DCC_PATH/config
    echo 0x03D73718 1 > $DCC_PATH/config
    echo 0x03D7371C 1 > $DCC_PATH/config
    echo 0x03D73720 1 > $DCC_PATH/config
    echo 0x03D73724 1 > $DCC_PATH/config
    echo 0x03D73728 1 > $DCC_PATH/config
    echo 0x03D7372C 1 > $DCC_PATH/config
    echo 0x03D73730 1 > $DCC_PATH/config
    echo 0x03D73734 1 > $DCC_PATH/config
    echo 0x03D73738 1 > $DCC_PATH/config
    echo 0x03D7373C 1 > $DCC_PATH/config
    echo 0x03D73740 1 > $DCC_PATH/config
    echo 0x03D73744 1 > $DCC_PATH/config
    echo 0x03D73748 1 > $DCC_PATH/config
    echo 0x03D7374C 1 > $DCC_PATH/config
    echo 0x03D73750 1 > $DCC_PATH/config
    echo 0x03D73754 1 > $DCC_PATH/config
    echo 0x03D73758 1 > $DCC_PATH/config
    echo 0x03D7375C 1 > $DCC_PATH/config
    echo 0x03D73760 1 > $DCC_PATH/config
    echo 0x03D73764 1 > $DCC_PATH/config
    echo 0x03D73768 1 > $DCC_PATH/config
    echo 0x03D7376C 1 > $DCC_PATH/config
    echo 0x03D73770 1 > $DCC_PATH/config
    echo 0x03D73774 1 > $DCC_PATH/config
    echo 0x03D73778 1 > $DCC_PATH/config
    echo 0x03D7377C 1 > $DCC_PATH/config
    echo 0x03D73780 1 > $DCC_PATH/config
    echo 0x03D73784 1 > $DCC_PATH/config
    echo 0x03D73788 1 > $DCC_PATH/config
    echo 0x03D7378C 1 > $DCC_PATH/config
    echo 0x03D73790 1 > $DCC_PATH/config
    echo 0x03D73794 1 > $DCC_PATH/config
    echo 0x03D73798 1 > $DCC_PATH/config
    echo 0x03D7379C 1 > $DCC_PATH/config
    echo 0x03D737A0 1 > $DCC_PATH/config
    echo 0x03D737A4 1 > $DCC_PATH/config
    echo 0x03D737A8 1 > $DCC_PATH/config
    echo 0x03D737AC 1 > $DCC_PATH/config
    echo 0x03D737B0 1 > $DCC_PATH/config
    echo 0x03D737B4 1 > $DCC_PATH/config
    echo 0x03D737B8 1 > $DCC_PATH/config
    echo 0x03D737BC 1 > $DCC_PATH/config
    echo 0x03D737C0 1 > $DCC_PATH/config
    echo 0x03D737C4 1 > $DCC_PATH/config
    echo 0x03D737C8 1 > $DCC_PATH/config
    echo 0x03D737CC 1 > $DCC_PATH/config
    echo 0x03D737D0 1 > $DCC_PATH/config
    echo 0x03D737D4 1 > $DCC_PATH/config
    echo 0x03D737D8 1 > $DCC_PATH/config
    echo 0x03D737DC 1 > $DCC_PATH/config
    echo 0x03D737E0 1 > $DCC_PATH/config
    echo 0x03D737E4 1 > $DCC_PATH/config
    echo 0x03D737E8 1 > $DCC_PATH/config
    echo 0x03D737EC 1 > $DCC_PATH/config
    echo 0x03D737F0 1 > $DCC_PATH/config
    echo 0x03D737F4 1 > $DCC_PATH/config
    echo 0x03D737F8 1 > $DCC_PATH/config
    echo 0x03D737FC 1 > $DCC_PATH/config
    echo 0x03D73800 1 > $DCC_PATH/config
    echo 0x03D73804 1 > $DCC_PATH/config
    echo 0x03D73808 1 > $DCC_PATH/config
    echo 0x03D7380C 1 > $DCC_PATH/config
    echo 0x03D73810 1 > $DCC_PATH/config
    echo 0x03D73814 1 > $DCC_PATH/config
    echo 0x03D73818 1 > $DCC_PATH/config
    echo 0x03D7381C 1 > $DCC_PATH/config
    echo 0x03D73820 1 > $DCC_PATH/config
    echo 0x03D73824 1 > $DCC_PATH/config
    echo 0x03D73828 1 > $DCC_PATH/config
    echo 0x03D7382C 1 > $DCC_PATH/config
    echo 0x03D73830 1 > $DCC_PATH/config
    echo 0x03D73834 1 > $DCC_PATH/config
    echo 0x03D73838 1 > $DCC_PATH/config
    echo 0x03D7383C 1 > $DCC_PATH/config
    echo 0x03D73840 1 > $DCC_PATH/config
    echo 0x03D73844 1 > $DCC_PATH/config
    echo 0x03D73848 1 > $DCC_PATH/config
    echo 0x03D7384C 1 > $DCC_PATH/config
    echo 0x03D73850 1 > $DCC_PATH/config
    echo 0x03D73854 1 > $DCC_PATH/config
    echo 0x03D73858 1 > $DCC_PATH/config
    echo 0x03D7385C 1 > $DCC_PATH/config
    echo 0x03D73860 1 > $DCC_PATH/config
    echo 0x03D73864 1 > $DCC_PATH/config
    echo 0x03D73868 1 > $DCC_PATH/config
    echo 0x03D7386C 1 > $DCC_PATH/config
    echo 0x03D73870 1 > $DCC_PATH/config
    echo 0x03D73874 1 > $DCC_PATH/config
    echo 0x03D73878 1 > $DCC_PATH/config
    echo 0x03D7387C 1 > $DCC_PATH/config
    echo 0x03D73880 1 > $DCC_PATH/config
    echo 0x03D73884 1 > $DCC_PATH/config
    echo 0x03D73888 1 > $DCC_PATH/config
    echo 0x03D7388C 1 > $DCC_PATH/config
    echo 0x03D73890 1 > $DCC_PATH/config
    echo 0x03D73894 1 > $DCC_PATH/config
    echo 0x03D73898 1 > $DCC_PATH/config
    echo 0x03D7389C 1 > $DCC_PATH/config
    echo 0x03D738A0 1 > $DCC_PATH/config
    echo 0x03D738A4 1 > $DCC_PATH/config
    echo 0x03D738A8 1 > $DCC_PATH/config
    echo 0x03D738AC 1 > $DCC_PATH/config
    echo 0x03D738B0 1 > $DCC_PATH/config
    echo 0x03D738B4 1 > $DCC_PATH/config
    echo 0x03D738B8 1 > $DCC_PATH/config
    echo 0x03D738BC 1 > $DCC_PATH/config
    echo 0x03D738C0 1 > $DCC_PATH/config
    echo 0x03D738C4 1 > $DCC_PATH/config
    echo 0x03D738C8 1 > $DCC_PATH/config
    echo 0x03D738CC 1 > $DCC_PATH/config
    echo 0x03D738D0 1 > $DCC_PATH/config
    echo 0x03D738D4 1 > $DCC_PATH/config
    echo 0x03D738D8 1 > $DCC_PATH/config
    echo 0x03D738DC 1 > $DCC_PATH/config
    echo 0x03D738E0 1 > $DCC_PATH/config
    echo 0x03D738E4 1 > $DCC_PATH/config
    echo 0x03D738E8 1 > $DCC_PATH/config
    echo 0x03D738EC 1 > $DCC_PATH/config
    echo 0x03D738F0 1 > $DCC_PATH/config
    echo 0x03D738F4 1 > $DCC_PATH/config
    echo 0x03D738F8 1 > $DCC_PATH/config
    echo 0x03D738FC 1 > $DCC_PATH/config
    echo 0x03D73900 1 > $DCC_PATH/config
    echo 0x03D73904 1 > $DCC_PATH/config
    echo 0x03D73908 1 > $DCC_PATH/config
    echo 0x03D7390C 1 > $DCC_PATH/config
    echo 0x03D73910 1 > $DCC_PATH/config
    echo 0x03D73914 1 > $DCC_PATH/config
    echo 0x03D73918 1 > $DCC_PATH/config
    echo 0x03D7391C 1 > $DCC_PATH/config
    echo 0x03D73920 1 > $DCC_PATH/config
    echo 0x03D73924 1 > $DCC_PATH/config
    echo 0x03D73928 1 > $DCC_PATH/config
    echo 0x03D7392C 1 > $DCC_PATH/config
    echo 0x03D73930 1 > $DCC_PATH/config
    echo 0x03D73934 1 > $DCC_PATH/config
    echo 0x03D73938 1 > $DCC_PATH/config
    echo 0x03D7393C 1 > $DCC_PATH/config
    echo 0x03D73940 1 > $DCC_PATH/config
    echo 0x03D73944 1 > $DCC_PATH/config
    echo 0x03D73948 1 > $DCC_PATH/config
    echo 0x03D7394C 1 > $DCC_PATH/config
    echo 0x03D73950 1 > $DCC_PATH/config
    echo 0x03D73954 1 > $DCC_PATH/config
    echo 0x03D73958 1 > $DCC_PATH/config
    echo 0x03D7395C 1 > $DCC_PATH/config
    echo 0x03D73960 1 > $DCC_PATH/config
    echo 0x03D73964 1 > $DCC_PATH/config
    echo 0x03D73968 1 > $DCC_PATH/config
    echo 0x03D7396C 1 > $DCC_PATH/config
    echo 0x03D73970 1 > $DCC_PATH/config
    echo 0x03D73974 1 > $DCC_PATH/config
    echo 0x03D73978 1 > $DCC_PATH/config
    echo 0x03D7397C 1 > $DCC_PATH/config
    echo 0x03D73980 1 > $DCC_PATH/config
    echo 0x03D73984 1 > $DCC_PATH/config
    echo 0x03D73988 1 > $DCC_PATH/config
    echo 0x03D7398C 1 > $DCC_PATH/config
    echo 0x03D73990 1 > $DCC_PATH/config
    echo 0x03D73994 1 > $DCC_PATH/config
    echo 0x03D73998 1 > $DCC_PATH/config
    echo 0x03D7399C 1 > $DCC_PATH/config
    echo 0x03D739A0 1 > $DCC_PATH/config
    echo 0x03D739A4 1 > $DCC_PATH/config
    echo 0x03D739A8 1 > $DCC_PATH/config
    echo 0x03D739AC 1 > $DCC_PATH/config
    echo 0x03D739B0 1 > $DCC_PATH/config
    echo 0x03D739B4 1 > $DCC_PATH/config
    echo 0x03D739B8 1 > $DCC_PATH/config
    echo 0x03D739BC 1 > $DCC_PATH/config
    echo 0x03D739C0 1 > $DCC_PATH/config
    echo 0x03D739C4 1 > $DCC_PATH/config
    echo 0x03D739C8 1 > $DCC_PATH/config
    echo 0x03D739CC 1 > $DCC_PATH/config
    echo 0x03D739D0 1 > $DCC_PATH/config
    echo 0x03D739D4 1 > $DCC_PATH/config
    echo 0x03D739D8 1 > $DCC_PATH/config
    echo 0x03D739DC 1 > $DCC_PATH/config
    echo 0x03D739E0 1 > $DCC_PATH/config
    echo 0x03D739E4 1 > $DCC_PATH/config
    echo 0x03D739E8 1 > $DCC_PATH/config
    echo 0x03D739EC 1 > $DCC_PATH/config
    echo 0x03D739F0 1 > $DCC_PATH/config
    echo 0x03D739F4 1 > $DCC_PATH/config
    echo 0x03D739F8 1 > $DCC_PATH/config
    echo 0x03D739FC 1 > $DCC_PATH/config
    echo 0x03D73A00 1 > $DCC_PATH/config
    echo 0x03D73A04 1 > $DCC_PATH/config
    echo 0x03D73A08 1 > $DCC_PATH/config
    echo 0x03D73A0C 1 > $DCC_PATH/config
    echo 0x03D73A10 1 > $DCC_PATH/config
    echo 0x03D73A14 1 > $DCC_PATH/config
    echo 0x03D73A18 1 > $DCC_PATH/config
    echo 0x03D73A1C 1 > $DCC_PATH/config
    echo 0x03D73A20 1 > $DCC_PATH/config
    echo 0x03D73A24 1 > $DCC_PATH/config
    echo 0x03D73A28 1 > $DCC_PATH/config
    echo 0x03D73A2C 1 > $DCC_PATH/config
    echo 0x03D73A30 1 > $DCC_PATH/config
    echo 0x03D73A34 1 > $DCC_PATH/config
    echo 0x03D73A38 1 > $DCC_PATH/config
    echo 0x03D73A3C 1 > $DCC_PATH/config
    echo 0x03D73A40 1 > $DCC_PATH/config
    echo 0x03D73A44 1 > $DCC_PATH/config
    echo 0x03D73A48 1 > $DCC_PATH/config
    echo 0x03D73A4C 1 > $DCC_PATH/config
    echo 0x03D73A50 1 > $DCC_PATH/config
    echo 0x03D73A54 1 > $DCC_PATH/config
    echo 0x03D73A58 1 > $DCC_PATH/config
    echo 0x03D73A5C 1 > $DCC_PATH/config
    echo 0x03D73A60 1 > $DCC_PATH/config
    echo 0x03D73A64 1 > $DCC_PATH/config
    echo 0x03D73A68 1 > $DCC_PATH/config
    echo 0x03D73A6C 1 > $DCC_PATH/config
    echo 0x03D73A70 1 > $DCC_PATH/config
    echo 0x03D73A74 1 > $DCC_PATH/config
    echo 0x03D73A78 1 > $DCC_PATH/config
    echo 0x03D73A7C 1 > $DCC_PATH/config
    echo 0x03D73A80 1 > $DCC_PATH/config
    echo 0x03D73A84 1 > $DCC_PATH/config
    echo 0x03D73A88 1 > $DCC_PATH/config
    echo 0x03D73A8C 1 > $DCC_PATH/config
    echo 0x03D73A90 1 > $DCC_PATH/config
    echo 0x03D73A94 1 > $DCC_PATH/config
    echo 0x03D73A98 1 > $DCC_PATH/config
    echo 0x03D73A9C 1 > $DCC_PATH/config
    echo 0x03D73AA0 1 > $DCC_PATH/config
    echo 0x03D73AA4 1 > $DCC_PATH/config
    echo 0x03D73AA8 1 > $DCC_PATH/config
    echo 0x03D73AAC 1 > $DCC_PATH/config
    echo 0x03D73AB0 1 > $DCC_PATH/config
    echo 0x03D73AB4 1 > $DCC_PATH/config
    echo 0x03D73AB8 1 > $DCC_PATH/config
    echo 0x03D73ABC 1 > $DCC_PATH/config
    echo 0x03D73AC0 1 > $DCC_PATH/config
    echo 0x03D73AC4 1 > $DCC_PATH/config
    echo 0x03D73AC8 1 > $DCC_PATH/config
    echo 0x03D73ACC 1 > $DCC_PATH/config
    echo 0x03D73AD0 1 > $DCC_PATH/config
    echo 0x03D73AD4 1 > $DCC_PATH/config
    echo 0x03D73AD8 1 > $DCC_PATH/config
    echo 0x03D73ADC 1 > $DCC_PATH/config
    echo 0x03D73AE0 1 > $DCC_PATH/config
    echo 0x03D73AE4 1 > $DCC_PATH/config
    echo 0x03D73AE8 1 > $DCC_PATH/config
    echo 0x03D73AEC 1 > $DCC_PATH/config
    echo 0x03D73AF0 1 > $DCC_PATH/config
    echo 0x03D73AF4 1 > $DCC_PATH/config
    echo 0x03D73AF8 1 > $DCC_PATH/config
    echo 0x03D73AFC 1 > $DCC_PATH/config
    echo 0x03D73B00 1 > $DCC_PATH/config
    echo 0x03D73B04 1 > $DCC_PATH/config
    echo 0x03D73B08 1 > $DCC_PATH/config
    echo 0x03D73B0C 1 > $DCC_PATH/config
    echo 0x03D73B10 1 > $DCC_PATH/config
    echo 0x03D73B14 1 > $DCC_PATH/config
    echo 0x03D73B18 1 > $DCC_PATH/config
    echo 0x03D73B1C 1 > $DCC_PATH/config
    echo 0x03D73B20 1 > $DCC_PATH/config
    echo 0x03D73B24 1 > $DCC_PATH/config
    echo 0x03D73B28 1 > $DCC_PATH/config
    echo 0x03D73B2C 1 > $DCC_PATH/config
    echo 0x03D73B30 1 > $DCC_PATH/config
    echo 0x03D73B34 1 > $DCC_PATH/config
    echo 0x03D73B38 1 > $DCC_PATH/config
    echo 0x03D73B3C 1 > $DCC_PATH/config
    echo 0x03D73B40 1 > $DCC_PATH/config
    echo 0x03D73B44 1 > $DCC_PATH/config
    echo 0x03D73B48 1 > $DCC_PATH/config
    echo 0x03D73B4C 1 > $DCC_PATH/config
    echo 0x03D73B50 1 > $DCC_PATH/config
    echo 0x03D73B54 1 > $DCC_PATH/config
    echo 0x03D73B58 1 > $DCC_PATH/config
    echo 0x03D73B5C 1 > $DCC_PATH/config
    echo 0x03D73B60 1 > $DCC_PATH/config
    echo 0x03D73B64 1 > $DCC_PATH/config
    echo 0x03D73B68 1 > $DCC_PATH/config
    echo 0x03D73B6C 1 > $DCC_PATH/config
    echo 0x03D73B70 1 > $DCC_PATH/config
    echo 0x03D73B74 1 > $DCC_PATH/config
    echo 0x03D73B78 1 > $DCC_PATH/config
    echo 0x03D73B7C 1 > $DCC_PATH/config
    echo 0x03D73B80 1 > $DCC_PATH/config
    echo 0x03D73B84 1 > $DCC_PATH/config
    echo 0x03D73B88 1 > $DCC_PATH/config
    echo 0x03D73B8C 1 > $DCC_PATH/config
    echo 0x03D73B90 1 > $DCC_PATH/config
    echo 0x03D73B94 1 > $DCC_PATH/config
    echo 0x03D73B98 1 > $DCC_PATH/config
    echo 0x03D73B9C 1 > $DCC_PATH/config
    echo 0x03D73BA0 1 > $DCC_PATH/config
    echo 0x03D73BA4 1 > $DCC_PATH/config
    echo 0x03D73BA8 1 > $DCC_PATH/config
    echo 0x03D73BAC 1 > $DCC_PATH/config
    echo 0x03D73BB0 1 > $DCC_PATH/config
    echo 0x03D73BB4 1 > $DCC_PATH/config
    echo 0x03D73BB8 1 > $DCC_PATH/config
    echo 0x03D73BBC 1 > $DCC_PATH/config
    echo 0x03D73BC0 1 > $DCC_PATH/config
    echo 0x03D73BC4 1 > $DCC_PATH/config
    echo 0x03D73BC8 1 > $DCC_PATH/config
    echo 0x03D73BCC 1 > $DCC_PATH/config
    echo 0x03D73BD0 1 > $DCC_PATH/config
    echo 0x03D73BD4 1 > $DCC_PATH/config
    echo 0x03D73BD8 1 > $DCC_PATH/config
    echo 0x03D73BDC 1 > $DCC_PATH/config
    echo 0x03D73BE0 1 > $DCC_PATH/config
    echo 0x03D73BE4 1 > $DCC_PATH/config
    echo 0x03D73BE8 1 > $DCC_PATH/config
    echo 0x03D73BEC 1 > $DCC_PATH/config
    echo 0x03D73BF0 1 > $DCC_PATH/config
    echo 0x03D73BF4 1 > $DCC_PATH/config
    echo 0x03D73BF8 1 > $DCC_PATH/config
    echo 0x03D73BFC 1 > $DCC_PATH/config
    echo 0x03D73C00 1 > $DCC_PATH/config
    echo 0x03D73C04 1 > $DCC_PATH/config
    echo 0x03D73C08 1 > $DCC_PATH/config
    echo 0x03D73C0C 1 > $DCC_PATH/config
    echo 0x03D73C10 1 > $DCC_PATH/config
    echo 0x03D73C14 1 > $DCC_PATH/config
    echo 0x03D73C18 1 > $DCC_PATH/config
    echo 0x03D73C1C 1 > $DCC_PATH/config
    echo 0x03D73C20 1 > $DCC_PATH/config
    echo 0x03D73C24 1 > $DCC_PATH/config
    echo 0x03D73C28 1 > $DCC_PATH/config
    echo 0x03D73C2C 1 > $DCC_PATH/config
    echo 0x03D73C30 1 > $DCC_PATH/config
    echo 0x03D73C34 1 > $DCC_PATH/config
    echo 0x03D73C38 1 > $DCC_PATH/config
    echo 0x03D73C3C 1 > $DCC_PATH/config
    echo 0x03D73C40 1 > $DCC_PATH/config
    echo 0x03D73C44 1 > $DCC_PATH/config
    echo 0x03D73C48 1 > $DCC_PATH/config
    echo 0x03D73C4C 1 > $DCC_PATH/config
    echo 0x03D73C50 1 > $DCC_PATH/config
    echo 0x03D73C54 1 > $DCC_PATH/config
    echo 0x03D73C58 1 > $DCC_PATH/config
    echo 0x03D73C5C 1 > $DCC_PATH/config
    echo 0x03D73C60 1 > $DCC_PATH/config
    echo 0x03D73C64 1 > $DCC_PATH/config
    echo 0x03D73C68 1 > $DCC_PATH/config
    echo 0x03D73C6C 1 > $DCC_PATH/config
    echo 0x03D73C70 1 > $DCC_PATH/config
    echo 0x03D73C74 1 > $DCC_PATH/config
    echo 0x03D73C78 1 > $DCC_PATH/config
    echo 0x03D73C7C 1 > $DCC_PATH/config
    echo 0x03D73C80 1 > $DCC_PATH/config
    echo 0x03D73C84 1 > $DCC_PATH/config
    echo 0x03D73C88 1 > $DCC_PATH/config
    echo 0x03D73C8C 1 > $DCC_PATH/config
    echo 0x03D73C90 1 > $DCC_PATH/config
    echo 0x03D73C94 1 > $DCC_PATH/config
    echo 0x03D73C98 1 > $DCC_PATH/config
    echo 0x03D73C9C 1 > $DCC_PATH/config
    echo 0x03D73CA0 1 > $DCC_PATH/config
    echo 0x03D73CA4 1 > $DCC_PATH/config
    echo 0x03D73CA8 1 > $DCC_PATH/config
    echo 0x03D73CAC 1 > $DCC_PATH/config
    echo 0x03D73CB0 1 > $DCC_PATH/config
    echo 0x03D73CB4 1 > $DCC_PATH/config
    echo 0x03D73CB8 1 > $DCC_PATH/config
    echo 0x03D73CBC 1 > $DCC_PATH/config
    echo 0x03D73CC0 1 > $DCC_PATH/config
    echo 0x03D73CC4 1 > $DCC_PATH/config
    echo 0x03D73CC8 1 > $DCC_PATH/config
    echo 0x03D73CCC 1 > $DCC_PATH/config
    echo 0x03D73CD0 1 > $DCC_PATH/config
    echo 0x03D73CD4 1 > $DCC_PATH/config
    echo 0x03D73CD8 1 > $DCC_PATH/config
    echo 0x03D73CDC 1 > $DCC_PATH/config
    echo 0x03D73CE0 1 > $DCC_PATH/config
    echo 0x03D73CE4 1 > $DCC_PATH/config
    echo 0x03D73CE8 1 > $DCC_PATH/config
    echo 0x03D73CEC 1 > $DCC_PATH/config
    echo 0x03D73CF0 1 > $DCC_PATH/config
    echo 0x03D73CF4 1 > $DCC_PATH/config
    echo 0x03D73CF8 1 > $DCC_PATH/config
    echo 0x03D73CFC 1 > $DCC_PATH/config
    echo 0x03D73D00 1 > $DCC_PATH/config
    echo 0x03D73D04 1 > $DCC_PATH/config
    echo 0x03D73D08 1 > $DCC_PATH/config
    echo 0x03D73D0C 1 > $DCC_PATH/config
    echo 0x03D73D10 1 > $DCC_PATH/config
    echo 0x03D73D14 1 > $DCC_PATH/config
    echo 0x03D73D18 1 > $DCC_PATH/config
    echo 0x03D73D1C 1 > $DCC_PATH/config
    echo 0x03D73D20 1 > $DCC_PATH/config
    echo 0x03D73D24 1 > $DCC_PATH/config
    echo 0x03D73D28 1 > $DCC_PATH/config
    echo 0x03D73D2C 1 > $DCC_PATH/config
    echo 0x03D73D30 1 > $DCC_PATH/config
    echo 0x03D73D34 1 > $DCC_PATH/config
    echo 0x03D73D38 1 > $DCC_PATH/config
    echo 0x03D73D3C 1 > $DCC_PATH/config
    echo 0x03D73D40 1 > $DCC_PATH/config
    echo 0x03D73D44 1 > $DCC_PATH/config
    echo 0x03D73D48 1 > $DCC_PATH/config
    echo 0x03D73D4C 1 > $DCC_PATH/config
    echo 0x03D73D50 1 > $DCC_PATH/config
    echo 0x03D73D54 1 > $DCC_PATH/config
    echo 0x03D73D58 1 > $DCC_PATH/config
    echo 0x03D73D5C 1 > $DCC_PATH/config
    echo 0x03D73D60 1 > $DCC_PATH/config
    echo 0x03D73D64 1 > $DCC_PATH/config
    echo 0x03D73D68 1 > $DCC_PATH/config
    echo 0x03D73D6C 1 > $DCC_PATH/config
    echo 0x03D73D70 1 > $DCC_PATH/config
    echo 0x03D73D74 1 > $DCC_PATH/config
    echo 0x03D73D78 1 > $DCC_PATH/config
    echo 0x03D73D7C 1 > $DCC_PATH/config
    echo 0x03D73D80 1 > $DCC_PATH/config
    echo 0x03D73D84 1 > $DCC_PATH/config
    echo 0x03D73D88 1 > $DCC_PATH/config
    echo 0x03D73D8C 1 > $DCC_PATH/config
    echo 0x03D73D90 1 > $DCC_PATH/config
    echo 0x03D73D94 1 > $DCC_PATH/config
    echo 0x03D73D98 1 > $DCC_PATH/config
    echo 0x03D73D9C 1 > $DCC_PATH/config
    echo 0x03D73DA0 1 > $DCC_PATH/config
    echo 0x03D73DA4 1 > $DCC_PATH/config
    echo 0x03D73DA8 1 > $DCC_PATH/config
    echo 0x03D73DAC 1 > $DCC_PATH/config
    echo 0x03D73DB0 1 > $DCC_PATH/config
    echo 0x03D73DB4 1 > $DCC_PATH/config
    echo 0x03D73DB8 1 > $DCC_PATH/config
    echo 0x03D73DBC 1 > $DCC_PATH/config
    echo 0x03D73DC0 1 > $DCC_PATH/config
    echo 0x03D73DC4 1 > $DCC_PATH/config
    echo 0x03D73DC8 1 > $DCC_PATH/config
    echo 0x03D73DCC 1 > $DCC_PATH/config
    echo 0x03D73DD0 1 > $DCC_PATH/config
    echo 0x03D73DD4 1 > $DCC_PATH/config
    echo 0x03D73DD8 1 > $DCC_PATH/config
    echo 0x03D73DDC 1 > $DCC_PATH/config
    echo 0x03D73DE0 1 > $DCC_PATH/config
    echo 0x03D73DE4 1 > $DCC_PATH/config
    echo 0x03D73DE8 1 > $DCC_PATH/config
    echo 0x03D73DEC 1 > $DCC_PATH/config
    echo 0x03D73DF0 1 > $DCC_PATH/config
    echo 0x03D73DF4 1 > $DCC_PATH/config
    echo 0x03D73DF8 1 > $DCC_PATH/config
    echo 0x03D73DFC 1 > $DCC_PATH/config
    echo 0x03D73E00 1 > $DCC_PATH/config
    echo 0x03D73E04 1 > $DCC_PATH/config
    echo 0x03D73E08 1 > $DCC_PATH/config
    echo 0x03D73E0C 1 > $DCC_PATH/config
    echo 0x03D73E10 1 > $DCC_PATH/config
    echo 0x03D73E14 1 > $DCC_PATH/config
    echo 0x03D73E18 1 > $DCC_PATH/config
    echo 0x03D73E1C 1 > $DCC_PATH/config
    echo 0x03D73E20 1 > $DCC_PATH/config
    echo 0x03D73E24 1 > $DCC_PATH/config
    echo 0x03D73E28 1 > $DCC_PATH/config
    echo 0x03D73E2C 1 > $DCC_PATH/config
    echo 0x03D73E30 1 > $DCC_PATH/config
    echo 0x03D73E34 1 > $DCC_PATH/config
    echo 0x03D73E38 1 > $DCC_PATH/config
    echo 0x03D73E3C 1 > $DCC_PATH/config
    echo 0x03D73E40 1 > $DCC_PATH/config
    echo 0x03D73E44 1 > $DCC_PATH/config
    echo 0x03D73E48 1 > $DCC_PATH/config
    echo 0x03D73E4C 1 > $DCC_PATH/config
    echo 0x03D73E50 1 > $DCC_PATH/config
    echo 0x03D73E54 1 > $DCC_PATH/config
    echo 0x03D73E58 1 > $DCC_PATH/config
    echo 0x03D73E5C 1 > $DCC_PATH/config
    echo 0x03D73E60 1 > $DCC_PATH/config
    echo 0x03D73E64 1 > $DCC_PATH/config
    echo 0x03D73E68 1 > $DCC_PATH/config
    echo 0x03D73E6C 1 > $DCC_PATH/config
    echo 0x03D73E70 1 > $DCC_PATH/config
    echo 0x03D73E74 1 > $DCC_PATH/config
    echo 0x03D73E78 1 > $DCC_PATH/config
    echo 0x03D73E7C 1 > $DCC_PATH/config
    echo 0x03D73E80 1 > $DCC_PATH/config
    echo 0x03D73E84 1 > $DCC_PATH/config
    echo 0x03D73E88 1 > $DCC_PATH/config
    echo 0x03D73E8C 1 > $DCC_PATH/config
    echo 0x03D73E90 1 > $DCC_PATH/config
    echo 0x03D73E94 1 > $DCC_PATH/config
    echo 0x03D73E98 1 > $DCC_PATH/config
    echo 0x03D73E9C 1 > $DCC_PATH/config
    echo 0x03D73EA0 1 > $DCC_PATH/config
    echo 0x03D73EA4 1 > $DCC_PATH/config
    echo 0x03D73EA8 1 > $DCC_PATH/config
    echo 0x03D73EAC 1 > $DCC_PATH/config
    echo 0x03D73EB0 1 > $DCC_PATH/config
    echo 0x03D73EB4 1 > $DCC_PATH/config
    echo 0x03D73EB8 1 > $DCC_PATH/config
    echo 0x03D73EBC 1 > $DCC_PATH/config
    echo 0x03D73EC0 1 > $DCC_PATH/config
    echo 0x03D73EC4 1 > $DCC_PATH/config
    echo 0x03D73EC8 1 > $DCC_PATH/config
    echo 0x03D73ECC 1 > $DCC_PATH/config
    echo 0x03D73ED0 1 > $DCC_PATH/config
    echo 0x03D73ED4 1 > $DCC_PATH/config
    echo 0x03D73ED8 1 > $DCC_PATH/config
    echo 0x03D73EDC 1 > $DCC_PATH/config
    echo 0x03D73EE0 1 > $DCC_PATH/config
    echo 0x03D73EE4 1 > $DCC_PATH/config
    echo 0x03D73EE8 1 > $DCC_PATH/config
    echo 0x03D73EEC 1 > $DCC_PATH/config
    echo 0x03D73EF0 1 > $DCC_PATH/config
    echo 0x03D73EF4 1 > $DCC_PATH/config
    echo 0x03D73EF8 1 > $DCC_PATH/config
    echo 0x03D73EFC 1 > $DCC_PATH/config
    echo 0x03D73F00 1 > $DCC_PATH/config
    echo 0x03D73F04 1 > $DCC_PATH/config
    echo 0x03D73F08 1 > $DCC_PATH/config
    echo 0x03D73F0C 1 > $DCC_PATH/config
    echo 0x03D73F10 1 > $DCC_PATH/config
    echo 0x03D73F14 1 > $DCC_PATH/config
    echo 0x03D73F18 1 > $DCC_PATH/config
    echo 0x03D73F1C 1 > $DCC_PATH/config
    echo 0x03D73F20 1 > $DCC_PATH/config
    echo 0x03D73F24 1 > $DCC_PATH/config
    echo 0x03D73F28 1 > $DCC_PATH/config
    echo 0x03D73F2C 1 > $DCC_PATH/config
    echo 0x03D73F30 1 > $DCC_PATH/config
    echo 0x03D73F34 1 > $DCC_PATH/config
    echo 0x03D73F38 1 > $DCC_PATH/config
    echo 0x03D73F3C 1 > $DCC_PATH/config
    echo 0x03D73F40 1 > $DCC_PATH/config
    echo 0x03D73F44 1 > $DCC_PATH/config
    echo 0x03D73F48 1 > $DCC_PATH/config
    echo 0x03D73F4C 1 > $DCC_PATH/config
    echo 0x03D73F50 1 > $DCC_PATH/config
    echo 0x03D73F54 1 > $DCC_PATH/config
    echo 0x03D73F58 1 > $DCC_PATH/config
    echo 0x03D73F5C 1 > $DCC_PATH/config
    echo 0x03D73F60 1 > $DCC_PATH/config
    echo 0x03D73F64 1 > $DCC_PATH/config
    echo 0x03D73F68 1 > $DCC_PATH/config
    echo 0x03D73F6C 1 > $DCC_PATH/config
    echo 0x03D73F70 1 > $DCC_PATH/config
    echo 0x03D73F74 1 > $DCC_PATH/config
    echo 0x03D73F78 1 > $DCC_PATH/config
    echo 0x03D73F7C 1 > $DCC_PATH/config
    echo 0x03D73F80 1 > $DCC_PATH/config
    echo 0x03D73F84 1 > $DCC_PATH/config
    echo 0x03D73F88 1 > $DCC_PATH/config
    echo 0x03D73F8C 1 > $DCC_PATH/config
    echo 0x03D73F90 1 > $DCC_PATH/config
    echo 0x03D73F94 1 > $DCC_PATH/config
    echo 0x03D73F98 1 > $DCC_PATH/config
    echo 0x03D73F9C 1 > $DCC_PATH/config
    echo 0x03D73FA0 1 > $DCC_PATH/config
    echo 0x03D73FA4 1 > $DCC_PATH/config
    echo 0x03D73FA8 1 > $DCC_PATH/config
    echo 0x03D73FAC 1 > $DCC_PATH/config
    echo 0x03D73FB0 1 > $DCC_PATH/config
    echo 0x03D73FB4 1 > $DCC_PATH/config
    echo 0x03D73FB8 1 > $DCC_PATH/config
    echo 0x03D73FBC 1 > $DCC_PATH/config
    echo 0x03D73FC0 1 > $DCC_PATH/config
    echo 0x03D73FC4 1 > $DCC_PATH/config
    echo 0x03D73FC8 1 > $DCC_PATH/config
    echo 0x03D73FCC 1 > $DCC_PATH/config
    echo 0x03D73FD0 1 > $DCC_PATH/config
    echo 0x03D73FD4 1 > $DCC_PATH/config
    echo 0x03D73FD8 1 > $DCC_PATH/config
    echo 0x03D73FDC 1 > $DCC_PATH/config
    echo 0x03D73FE0 1 > $DCC_PATH/config
    echo 0x03D73FE4 1 > $DCC_PATH/config
    echo 0x03D73FE8 1 > $DCC_PATH/config
    echo 0x03D73FEC 1 > $DCC_PATH/config
    echo 0x03D73FF0 1 > $DCC_PATH/config
    echo 0x03D73FF4 1 > $DCC_PATH/config
    echo 0x03D73FF8 1 > $DCC_PATH/config
    echo 0x03D73FFC 1 > $DCC_PATH/config
    echo 0x03D74000 1 > $DCC_PATH/config
    echo 0x03D74004 1 > $DCC_PATH/config
    echo 0x03D74008 1 > $DCC_PATH/config
    echo 0x03D7400C 1 > $DCC_PATH/config
    echo 0x03D74010 1 > $DCC_PATH/config
    echo 0x03D74014 1 > $DCC_PATH/config
    echo 0x03D74018 1 > $DCC_PATH/config
    echo 0x03D7401C 1 > $DCC_PATH/config
    echo 0x03D74020 1 > $DCC_PATH/config
    echo 0x03D74024 1 > $DCC_PATH/config
    echo 0x03D74028 1 > $DCC_PATH/config
    echo 0x03D7402C 1 > $DCC_PATH/config
    echo 0x03D74030 1 > $DCC_PATH/config
    echo 0x03D74034 1 > $DCC_PATH/config
    echo 0x03D74038 1 > $DCC_PATH/config
    echo 0x03D7403C 1 > $DCC_PATH/config
    echo 0x03D74040 1 > $DCC_PATH/config
    echo 0x03D74044 1 > $DCC_PATH/config
    echo 0x03D74048 1 > $DCC_PATH/config
    echo 0x03D7404C 1 > $DCC_PATH/config
    echo 0x03D74050 1 > $DCC_PATH/config
    echo 0x03D74054 1 > $DCC_PATH/config
    echo 0x03D74058 1 > $DCC_PATH/config
    echo 0x03D7405C 1 > $DCC_PATH/config
    echo 0x03D74060 1 > $DCC_PATH/config
    echo 0x03D74064 1 > $DCC_PATH/config
    echo 0x03D74068 1 > $DCC_PATH/config
    echo 0x03D7406C 1 > $DCC_PATH/config
    echo 0x03D74070 1 > $DCC_PATH/config
    echo 0x03D74074 1 > $DCC_PATH/config
    echo 0x03D74078 1 > $DCC_PATH/config
    echo 0x03D7407C 1 > $DCC_PATH/config
    echo 0x03D74080 1 > $DCC_PATH/config
    echo 0x03D74084 1 > $DCC_PATH/config
    echo 0x03D74088 1 > $DCC_PATH/config
    echo 0x03D7408C 1 > $DCC_PATH/config
    echo 0x03D74090 1 > $DCC_PATH/config
    echo 0x03D74094 1 > $DCC_PATH/config
    echo 0x03D74098 1 > $DCC_PATH/config
    echo 0x03D7409C 1 > $DCC_PATH/config
    echo 0x03D740A0 1 > $DCC_PATH/config
    echo 0x03D740A4 1 > $DCC_PATH/config
    echo 0x03D740A8 1 > $DCC_PATH/config
    echo 0x03D740AC 1 > $DCC_PATH/config
    echo 0x03D740B0 1 > $DCC_PATH/config
    echo 0x03D740B4 1 > $DCC_PATH/config
    echo 0x03D740B8 1 > $DCC_PATH/config
    echo 0x03D740BC 1 > $DCC_PATH/config
    echo 0x03D740C0 1 > $DCC_PATH/config
    echo 0x03D740C4 1 > $DCC_PATH/config
    echo 0x03D740C8 1 > $DCC_PATH/config
    echo 0x03D740CC 1 > $DCC_PATH/config
    echo 0x03D740D0 1 > $DCC_PATH/config
    echo 0x03D740D4 1 > $DCC_PATH/config
    echo 0x03D740D8 1 > $DCC_PATH/config
    echo 0x03D740DC 1 > $DCC_PATH/config
    echo 0x03D740E0 1 > $DCC_PATH/config
    echo 0x03D740E4 1 > $DCC_PATH/config
    echo 0x03D740E8 1 > $DCC_PATH/config
    echo 0x03D740EC 1 > $DCC_PATH/config
    echo 0x03D740F0 1 > $DCC_PATH/config
    echo 0x03D740F4 1 > $DCC_PATH/config
    echo 0x03D740F8 1 > $DCC_PATH/config
    echo 0x03D740FC 1 > $DCC_PATH/config
    echo 0x03D74100 1 > $DCC_PATH/config
    echo 0x03D74104 1 > $DCC_PATH/config
    echo 0x03D74108 1 > $DCC_PATH/config
    echo 0x03D7410C 1 > $DCC_PATH/config
    echo 0x03D74110 1 > $DCC_PATH/config
    echo 0x03D74114 1 > $DCC_PATH/config
    echo 0x03D74118 1 > $DCC_PATH/config
    echo 0x03D7411C 1 > $DCC_PATH/config
    echo 0x03D74120 1 > $DCC_PATH/config
    echo 0x03D74124 1 > $DCC_PATH/config
    echo 0x03D74128 1 > $DCC_PATH/config
    echo 0x03D7412C 1 > $DCC_PATH/config
    echo 0x03D74130 1 > $DCC_PATH/config
    echo 0x03D74134 1 > $DCC_PATH/config
    echo 0x03D74138 1 > $DCC_PATH/config
    echo 0x03D7413C 1 > $DCC_PATH/config
    echo 0x03D74140 1 > $DCC_PATH/config
    echo 0x03D74144 1 > $DCC_PATH/config
    echo 0x03D74148 1 > $DCC_PATH/config
    echo 0x03D7414C 1 > $DCC_PATH/config
    echo 0x03D74150 1 > $DCC_PATH/config
    echo 0x03D74154 1 > $DCC_PATH/config
    echo 0x03D74158 1 > $DCC_PATH/config
    echo 0x03D7415C 1 > $DCC_PATH/config
    echo 0x03D74160 1 > $DCC_PATH/config
    echo 0x03D74164 1 > $DCC_PATH/config
    echo 0x03D74168 1 > $DCC_PATH/config
    echo 0x03D7416C 1 > $DCC_PATH/config
    echo 0x03D74170 1 > $DCC_PATH/config
    echo 0x03D74174 1 > $DCC_PATH/config
    echo 0x03D74178 1 > $DCC_PATH/config
    echo 0x03D7417C 1 > $DCC_PATH/config
    echo 0x03D74180 1 > $DCC_PATH/config
    echo 0x03D74184 1 > $DCC_PATH/config
    echo 0x03D74188 1 > $DCC_PATH/config
    echo 0x03D7418C 1 > $DCC_PATH/config
    echo 0x03D74190 1 > $DCC_PATH/config
    echo 0x03D74194 1 > $DCC_PATH/config
    echo 0x03D74198 1 > $DCC_PATH/config
    echo 0x03D7419C 1 > $DCC_PATH/config
    echo 0x03D741A0 1 > $DCC_PATH/config
    echo 0x03D741A4 1 > $DCC_PATH/config
    echo 0x03D741A8 1 > $DCC_PATH/config
    echo 0x03D741AC 1 > $DCC_PATH/config
    echo 0x03D741B0 1 > $DCC_PATH/config
    echo 0x03D741B4 1 > $DCC_PATH/config
    echo 0x03D741B8 1 > $DCC_PATH/config
    echo 0x03D741BC 1 > $DCC_PATH/config
    echo 0x03D741C0 1 > $DCC_PATH/config
    echo 0x03D741C4 1 > $DCC_PATH/config
    echo 0x03D741C8 1 > $DCC_PATH/config
    echo 0x03D741CC 1 > $DCC_PATH/config
    echo 0x03D741D0 1 > $DCC_PATH/config
    echo 0x03D741D4 1 > $DCC_PATH/config
    echo 0x03D741D8 1 > $DCC_PATH/config
    echo 0x03D741DC 1 > $DCC_PATH/config
    echo 0x03D741E0 1 > $DCC_PATH/config
    echo 0x03D741E4 1 > $DCC_PATH/config
    echo 0x03D741E8 1 > $DCC_PATH/config
    echo 0x03D741EC 1 > $DCC_PATH/config
    echo 0x03D741F0 1 > $DCC_PATH/config
    echo 0x03D741F4 1 > $DCC_PATH/config
    echo 0x03D741F8 1 > $DCC_PATH/config
    echo 0x03D741FC 1 > $DCC_PATH/config
    echo 0x03D74200 1 > $DCC_PATH/config
    echo 0x03D74204 1 > $DCC_PATH/config
    echo 0x03D74208 1 > $DCC_PATH/config
    echo 0x03D7420C 1 > $DCC_PATH/config
    echo 0x03D74210 1 > $DCC_PATH/config
    echo 0x03D74214 1 > $DCC_PATH/config
    echo 0x03D74218 1 > $DCC_PATH/config
    echo 0x03D7421C 1 > $DCC_PATH/config
    echo 0x03D74220 1 > $DCC_PATH/config
    echo 0x03D74224 1 > $DCC_PATH/config
    echo 0x03D74228 1 > $DCC_PATH/config
    echo 0x03D7422C 1 > $DCC_PATH/config
    echo 0x03D74230 1 > $DCC_PATH/config
    echo 0x03D74234 1 > $DCC_PATH/config
    echo 0x03D74238 1 > $DCC_PATH/config
    echo 0x03D7423C 1 > $DCC_PATH/config
    echo 0x03D74240 1 > $DCC_PATH/config
    echo 0x03D74244 1 > $DCC_PATH/config
    echo 0x03D74248 1 > $DCC_PATH/config
    echo 0x03D7424C 1 > $DCC_PATH/config
    echo 0x03D74250 1 > $DCC_PATH/config
    echo 0x03D74254 1 > $DCC_PATH/config
    echo 0x03D74258 1 > $DCC_PATH/config
    echo 0x03D7425C 1 > $DCC_PATH/config
    echo 0x03D74260 1 > $DCC_PATH/config
    echo 0x03D74264 1 > $DCC_PATH/config
    echo 0x03D74268 1 > $DCC_PATH/config
    echo 0x03D7426C 1 > $DCC_PATH/config
    echo 0x03D74270 1 > $DCC_PATH/config
    echo 0x03D74274 1 > $DCC_PATH/config
    echo 0x03D74278 1 > $DCC_PATH/config
    echo 0x03D7427C 1 > $DCC_PATH/config
    echo 0x03D74280 1 > $DCC_PATH/config
    echo 0x03D74284 1 > $DCC_PATH/config
    echo 0x03D74288 1 > $DCC_PATH/config
    echo 0x03D7428C 1 > $DCC_PATH/config
    echo 0x03D74290 1 > $DCC_PATH/config
    echo 0x03D74294 1 > $DCC_PATH/config
    echo 0x03D74298 1 > $DCC_PATH/config
    echo 0x03D7429C 1 > $DCC_PATH/config
    echo 0x03D742A0 1 > $DCC_PATH/config
    echo 0x03D742A4 1 > $DCC_PATH/config
    echo 0x03D742A8 1 > $DCC_PATH/config
    echo 0x03D742AC 1 > $DCC_PATH/config
    echo 0x03D742B0 1 > $DCC_PATH/config
    echo 0x03D742B4 1 > $DCC_PATH/config
    echo 0x03D742B8 1 > $DCC_PATH/config
    echo 0x03D742BC 1 > $DCC_PATH/config
    echo 0x03D742C0 1 > $DCC_PATH/config
    echo 0x03D742C4 1 > $DCC_PATH/config
    echo 0x03D742C8 1 > $DCC_PATH/config
    echo 0x03D742CC 1 > $DCC_PATH/config
    echo 0x03D742D0 1 > $DCC_PATH/config
    echo 0x03D742D4 1 > $DCC_PATH/config
    echo 0x03D742D8 1 > $DCC_PATH/config
    echo 0x03D742DC 1 > $DCC_PATH/config
    echo 0x03D742E0 1 > $DCC_PATH/config
    echo 0x03D742E4 1 > $DCC_PATH/config
    echo 0x03D742E8 1 > $DCC_PATH/config
    echo 0x03D742EC 1 > $DCC_PATH/config
    echo 0x03D742F0 1 > $DCC_PATH/config
    echo 0x03D742F4 1 > $DCC_PATH/config
    echo 0x03D742F8 1 > $DCC_PATH/config
    echo 0x03D742FC 1 > $DCC_PATH/config
    echo 0x03D74300 1 > $DCC_PATH/config
    echo 0x03D74304 1 > $DCC_PATH/config
    echo 0x03D74308 1 > $DCC_PATH/config
    echo 0x03D7430C 1 > $DCC_PATH/config
    echo 0x03D74310 1 > $DCC_PATH/config
    echo 0x03D74314 1 > $DCC_PATH/config
    echo 0x03D74318 1 > $DCC_PATH/config
    echo 0x03D7431C 1 > $DCC_PATH/config
    echo 0x03D74320 1 > $DCC_PATH/config
    echo 0x03D74324 1 > $DCC_PATH/config
    echo 0x03D74328 1 > $DCC_PATH/config
    echo 0x03D7432C 1 > $DCC_PATH/config
    echo 0x03D74330 1 > $DCC_PATH/config
    echo 0x03D74334 1 > $DCC_PATH/config
    echo 0x03D74338 1 > $DCC_PATH/config
    echo 0x03D7433C 1 > $DCC_PATH/config
    echo 0x03D74340 1 > $DCC_PATH/config
    echo 0x03D74344 1 > $DCC_PATH/config
    echo 0x03D74348 1 > $DCC_PATH/config
    echo 0x03D7434C 1 > $DCC_PATH/config
    echo 0x03D74350 1 > $DCC_PATH/config
    echo 0x03D74354 1 > $DCC_PATH/config
    echo 0x03D74358 1 > $DCC_PATH/config
    echo 0x03D7435C 1 > $DCC_PATH/config
    echo 0x03D74360 1 > $DCC_PATH/config
    echo 0x03D74364 1 > $DCC_PATH/config
    echo 0x03D74368 1 > $DCC_PATH/config
    echo 0x03D7436C 1 > $DCC_PATH/config
    echo 0x03D74370 1 > $DCC_PATH/config
    echo 0x03D74374 1 > $DCC_PATH/config
    echo 0x03D74378 1 > $DCC_PATH/config
    echo 0x03D7437C 1 > $DCC_PATH/config
    echo 0x03D74380 1 > $DCC_PATH/config
    echo 0x03D74384 1 > $DCC_PATH/config
    echo 0x03D74388 1 > $DCC_PATH/config
    echo 0x03D7438C 1 > $DCC_PATH/config
    echo 0x03D74390 1 > $DCC_PATH/config
    echo 0x03D74394 1 > $DCC_PATH/config
    echo 0x03D74398 1 > $DCC_PATH/config
    echo 0x03D7439C 1 > $DCC_PATH/config
    echo 0x03D743A0 1 > $DCC_PATH/config
    echo 0x03D743A4 1 > $DCC_PATH/config
    echo 0x03D743A8 1 > $DCC_PATH/config
    echo 0x03D743AC 1 > $DCC_PATH/config
    echo 0x03D743B0 1 > $DCC_PATH/config
    echo 0x03D743B4 1 > $DCC_PATH/config
    echo 0x03D743B8 1 > $DCC_PATH/config
    echo 0x03D743BC 1 > $DCC_PATH/config
    echo 0x03D743C0 1 > $DCC_PATH/config
    echo 0x03D743C4 1 > $DCC_PATH/config
    echo 0x03D743C8 1 > $DCC_PATH/config
    echo 0x03D743CC 1 > $DCC_PATH/config
    echo 0x03D743D0 1 > $DCC_PATH/config
    echo 0x03D743D4 1 > $DCC_PATH/config
    echo 0x03D743D8 1 > $DCC_PATH/config
    echo 0x03D743DC 1 > $DCC_PATH/config
    echo 0x03D743E0 1 > $DCC_PATH/config
    echo 0x03D743E4 1 > $DCC_PATH/config
    echo 0x03D743E8 1 > $DCC_PATH/config
    echo 0x03D743EC 1 > $DCC_PATH/config
    echo 0x03D743F0 1 > $DCC_PATH/config
    echo 0x03D743F4 1 > $DCC_PATH/config
    echo 0x03D743F8 1 > $DCC_PATH/config
    echo 0x03D743FC 1 > $DCC_PATH/config
    echo 0x03D74400 1 > $DCC_PATH/config
    echo 0x03D74404 1 > $DCC_PATH/config
    echo 0x03D74408 1 > $DCC_PATH/config
    echo 0x03D7440C 1 > $DCC_PATH/config
    echo 0x03D74410 1 > $DCC_PATH/config
    echo 0x03D74414 1 > $DCC_PATH/config
    echo 0x03D74418 1 > $DCC_PATH/config
    echo 0x03D7441C 1 > $DCC_PATH/config
    echo 0x03D74420 1 > $DCC_PATH/config
    echo 0x03D74424 1 > $DCC_PATH/config
    echo 0x03D74428 1 > $DCC_PATH/config
    echo 0x03D7442C 1 > $DCC_PATH/config
    echo 0x03D74430 1 > $DCC_PATH/config
    echo 0x03D74434 1 > $DCC_PATH/config
    echo 0x03D74438 1 > $DCC_PATH/config
    echo 0x03D7443C 1 > $DCC_PATH/config
    echo 0x03D74440 1 > $DCC_PATH/config
    echo 0x03D74444 1 > $DCC_PATH/config
    echo 0x03D74448 1 > $DCC_PATH/config
    echo 0x03D7444C 1 > $DCC_PATH/config
    echo 0x03D74450 1 > $DCC_PATH/config
    echo 0x03D74454 1 > $DCC_PATH/config
    echo 0x03D74458 1 > $DCC_PATH/config
    echo 0x03D7445C 1 > $DCC_PATH/config
    echo 0x03D74460 1 > $DCC_PATH/config
    echo 0x03D74464 1 > $DCC_PATH/config
    echo 0x03D74468 1 > $DCC_PATH/config
    echo 0x03D7446C 1 > $DCC_PATH/config
    echo 0x03D74470 1 > $DCC_PATH/config
    echo 0x03D74474 1 > $DCC_PATH/config
    echo 0x03D74478 1 > $DCC_PATH/config
    echo 0x03D7447C 1 > $DCC_PATH/config
    echo 0x03D74480 1 > $DCC_PATH/config
    echo 0x03D74484 1 > $DCC_PATH/config
    echo 0x03D74488 1 > $DCC_PATH/config
    echo 0x03D7448C 1 > $DCC_PATH/config
    echo 0x03D74490 1 > $DCC_PATH/config
    echo 0x03D74494 1 > $DCC_PATH/config
    echo 0x03D74498 1 > $DCC_PATH/config
    echo 0x03D7449C 1 > $DCC_PATH/config
    echo 0x03D744A0 1 > $DCC_PATH/config
    echo 0x03D744A4 1 > $DCC_PATH/config
    echo 0x03D744A8 1 > $DCC_PATH/config
    echo 0x03D744AC 1 > $DCC_PATH/config
    echo 0x03D744B0 1 > $DCC_PATH/config
    echo 0x03D744B4 1 > $DCC_PATH/config
    echo 0x03D744B8 1 > $DCC_PATH/config
    echo 0x03D744BC 1 > $DCC_PATH/config
    echo 0x03D744C0 1 > $DCC_PATH/config
    echo 0x03D744C4 1 > $DCC_PATH/config
    echo 0x03D744C8 1 > $DCC_PATH/config
    echo 0x03D744CC 1 > $DCC_PATH/config
    echo 0x03D744D0 1 > $DCC_PATH/config
    echo 0x03D744D4 1 > $DCC_PATH/config
    echo 0x03D744D8 1 > $DCC_PATH/config
    echo 0x03D744DC 1 > $DCC_PATH/config
    echo 0x03D744E0 1 > $DCC_PATH/config
    echo 0x03D744E4 1 > $DCC_PATH/config
    echo 0x03D744E8 1 > $DCC_PATH/config
    echo 0x03D744EC 1 > $DCC_PATH/config
    echo 0x03D744F0 1 > $DCC_PATH/config
    echo 0x03D744F4 1 > $DCC_PATH/config
    echo 0x03D744F8 1 > $DCC_PATH/config
    echo 0x03D744FC 1 > $DCC_PATH/config
    echo 0x03D74500 1 > $DCC_PATH/config
    echo 0x03D74504 1 > $DCC_PATH/config
    echo 0x03D74508 1 > $DCC_PATH/config
    echo 0x03D7450C 1 > $DCC_PATH/config
    echo 0x03D74510 1 > $DCC_PATH/config
    echo 0x03D74514 1 > $DCC_PATH/config
    echo 0x03D74518 1 > $DCC_PATH/config
    echo 0x03D7451C 1 > $DCC_PATH/config
    echo 0x03D74520 1 > $DCC_PATH/config
    echo 0x03D74524 1 > $DCC_PATH/config
    echo 0x03D74528 1 > $DCC_PATH/config
    echo 0x03D7452C 1 > $DCC_PATH/config
    echo 0x03D74530 1 > $DCC_PATH/config
    echo 0x03D74534 1 > $DCC_PATH/config
    echo 0x03D74538 1 > $DCC_PATH/config
    echo 0x03D7453C 1 > $DCC_PATH/config
    echo 0x03D74540 1 > $DCC_PATH/config
    echo 0x03D74544 1 > $DCC_PATH/config
    echo 0x03D74548 1 > $DCC_PATH/config
    echo 0x03D7454C 1 > $DCC_PATH/config
    echo 0x03D74550 1 > $DCC_PATH/config
    echo 0x03D74554 1 > $DCC_PATH/config
    echo 0x03D74558 1 > $DCC_PATH/config
    echo 0x03D7455C 1 > $DCC_PATH/config
    echo 0x03D74560 1 > $DCC_PATH/config
    echo 0x03D74564 1 > $DCC_PATH/config
    echo 0x03D74568 1 > $DCC_PATH/config
    echo 0x03D7456C 1 > $DCC_PATH/config
    echo 0x03D74570 1 > $DCC_PATH/config
    echo 0x03D74574 1 > $DCC_PATH/config
    echo 0x03D74578 1 > $DCC_PATH/config
    echo 0x03D7457C 1 > $DCC_PATH/config
    echo 0x03D74580 1 > $DCC_PATH/config
    echo 0x03D74584 1 > $DCC_PATH/config
    echo 0x03D74588 1 > $DCC_PATH/config
    echo 0x03D7458C 1 > $DCC_PATH/config
    echo 0x03D74590 1 > $DCC_PATH/config
    echo 0x03D74594 1 > $DCC_PATH/config
    echo 0x03D74598 1 > $DCC_PATH/config
    echo 0x03D7459C 1 > $DCC_PATH/config
    echo 0x03D745A0 1 > $DCC_PATH/config
    echo 0x03D745A4 1 > $DCC_PATH/config
    echo 0x03D745A8 1 > $DCC_PATH/config
    echo 0x03D745AC 1 > $DCC_PATH/config
    echo 0x03D745B0 1 > $DCC_PATH/config
    echo 0x03D745B4 1 > $DCC_PATH/config
    echo 0x03D745B8 1 > $DCC_PATH/config
    echo 0x03D745BC 1 > $DCC_PATH/config
    echo 0x03D745C0 1 > $DCC_PATH/config
    echo 0x03D745C4 1 > $DCC_PATH/config
    echo 0x03D745C8 1 > $DCC_PATH/config
    echo 0x03D745CC 1 > $DCC_PATH/config
    echo 0x03D745D0 1 > $DCC_PATH/config
    echo 0x03D745D4 1 > $DCC_PATH/config
    echo 0x03D745D8 1 > $DCC_PATH/config
    echo 0x03D745DC 1 > $DCC_PATH/config
    echo 0x03D745E0 1 > $DCC_PATH/config
    echo 0x03D745E4 1 > $DCC_PATH/config
    echo 0x03D745E8 1 > $DCC_PATH/config
    echo 0x03D745EC 1 > $DCC_PATH/config
    echo 0x03D745F0 1 > $DCC_PATH/config
    echo 0x03D745F4 1 > $DCC_PATH/config
    echo 0x03D745F8 1 > $DCC_PATH/config
    echo 0x03D745FC 1 > $DCC_PATH/config
    echo 0x03D74600 1 > $DCC_PATH/config
    echo 0x03D74604 1 > $DCC_PATH/config
    echo 0x03D74608 1 > $DCC_PATH/config
    echo 0x03D7460C 1 > $DCC_PATH/config
    echo 0x03D74610 1 > $DCC_PATH/config
    echo 0x03D74614 1 > $DCC_PATH/config
    echo 0x03D74618 1 > $DCC_PATH/config
    echo 0x03D7461C 1 > $DCC_PATH/config
    echo 0x03D74620 1 > $DCC_PATH/config
    echo 0x03D74624 1 > $DCC_PATH/config
    echo 0x03D74628 1 > $DCC_PATH/config
    echo 0x03D7462C 1 > $DCC_PATH/config
    echo 0x03D74630 1 > $DCC_PATH/config
    echo 0x03D74634 1 > $DCC_PATH/config
    echo 0x03D74638 1 > $DCC_PATH/config
    echo 0x03D7463C 1 > $DCC_PATH/config
    echo 0x03D74640 1 > $DCC_PATH/config
    echo 0x03D74644 1 > $DCC_PATH/config
    echo 0x03D74648 1 > $DCC_PATH/config
    echo 0x03D7464C 1 > $DCC_PATH/config
    echo 0x03D74650 1 > $DCC_PATH/config
    echo 0x03D74654 1 > $DCC_PATH/config
    echo 0x03D74658 1 > $DCC_PATH/config
    echo 0x03D7465C 1 > $DCC_PATH/config
    echo 0x03D74660 1 > $DCC_PATH/config
    echo 0x03D74664 1 > $DCC_PATH/config
    echo 0x03D74668 1 > $DCC_PATH/config
    echo 0x03D7466C 1 > $DCC_PATH/config
    echo 0x03D74670 1 > $DCC_PATH/config
    echo 0x03D74674 1 > $DCC_PATH/config
    echo 0x03D74678 1 > $DCC_PATH/config
    echo 0x03D7467C 1 > $DCC_PATH/config
    echo 0x03D74680 1 > $DCC_PATH/config
    echo 0x03D74684 1 > $DCC_PATH/config
    echo 0x03D74688 1 > $DCC_PATH/config
    echo 0x03D7468C 1 > $DCC_PATH/config
    echo 0x03D74690 1 > $DCC_PATH/config
    echo 0x03D74694 1 > $DCC_PATH/config
    echo 0x03D74698 1 > $DCC_PATH/config
    echo 0x03D7469C 1 > $DCC_PATH/config
    echo 0x03D746A0 1 > $DCC_PATH/config
    echo 0x03D746A4 1 > $DCC_PATH/config
    echo 0x03D746A8 1 > $DCC_PATH/config
    echo 0x03D746AC 1 > $DCC_PATH/config
    echo 0x03D746B0 1 > $DCC_PATH/config
    echo 0x03D746B4 1 > $DCC_PATH/config
    echo 0x03D746B8 1 > $DCC_PATH/config
    echo 0x03D746BC 1 > $DCC_PATH/config
    echo 0x03D746C0 1 > $DCC_PATH/config
    echo 0x03D746C4 1 > $DCC_PATH/config
    echo 0x03D746C8 1 > $DCC_PATH/config
    echo 0x03D746CC 1 > $DCC_PATH/config
    echo 0x03D746D0 1 > $DCC_PATH/config
    echo 0x03D746D4 1 > $DCC_PATH/config
    echo 0x03D746D8 1 > $DCC_PATH/config
    echo 0x03D746DC 1 > $DCC_PATH/config
    echo 0x03D746E0 1 > $DCC_PATH/config
    echo 0x03D746E4 1 > $DCC_PATH/config
    echo 0x03D746E8 1 > $DCC_PATH/config
    echo 0x03D746EC 1 > $DCC_PATH/config
    echo 0x03D746F0 1 > $DCC_PATH/config
    echo 0x03D746F4 1 > $DCC_PATH/config
    echo 0x03D746F8 1 > $DCC_PATH/config
    echo 0x03D746FC 1 > $DCC_PATH/config
    echo 0x03D74700 1 > $DCC_PATH/config
    echo 0x03D74704 1 > $DCC_PATH/config
    echo 0x03D74708 1 > $DCC_PATH/config
    echo 0x03D7470C 1 > $DCC_PATH/config
    echo 0x03D74710 1 > $DCC_PATH/config
    echo 0x03D74714 1 > $DCC_PATH/config
    echo 0x03D74718 1 > $DCC_PATH/config
    echo 0x03D7471C 1 > $DCC_PATH/config
    echo 0x03D74720 1 > $DCC_PATH/config
    echo 0x03D74724 1 > $DCC_PATH/config
    echo 0x03D74728 1 > $DCC_PATH/config
    echo 0x03D7472C 1 > $DCC_PATH/config
    echo 0x03D74730 1 > $DCC_PATH/config
    echo 0x03D74734 1 > $DCC_PATH/config
    echo 0x03D74738 1 > $DCC_PATH/config
    echo 0x03D7473C 1 > $DCC_PATH/config
    echo 0x03D74740 1 > $DCC_PATH/config
    echo 0x03D74744 1 > $DCC_PATH/config
    echo 0x03D74748 1 > $DCC_PATH/config
    echo 0x03D7474C 1 > $DCC_PATH/config
    echo 0x03D74750 1 > $DCC_PATH/config
    echo 0x03D74754 1 > $DCC_PATH/config
    echo 0x03D74758 1 > $DCC_PATH/config
    echo 0x03D7475C 1 > $DCC_PATH/config
    echo 0x03D74760 1 > $DCC_PATH/config
    echo 0x03D74764 1 > $DCC_PATH/config
    echo 0x03D74768 1 > $DCC_PATH/config
    echo 0x03D7476C 1 > $DCC_PATH/config
    echo 0x03D74770 1 > $DCC_PATH/config
    echo 0x03D74774 1 > $DCC_PATH/config
    echo 0x03D74778 1 > $DCC_PATH/config
    echo 0x03D7477C 1 > $DCC_PATH/config
    echo 0x03D74780 1 > $DCC_PATH/config
    echo 0x03D74784 1 > $DCC_PATH/config
    echo 0x03D74788 1 > $DCC_PATH/config
    echo 0x03D7478C 1 > $DCC_PATH/config
    echo 0x03D74790 1 > $DCC_PATH/config
    echo 0x03D74794 1 > $DCC_PATH/config
    echo 0x03D74798 1 > $DCC_PATH/config
    echo 0x03D7479C 1 > $DCC_PATH/config
    echo 0x03D747A0 1 > $DCC_PATH/config
    echo 0x03D747A4 1 > $DCC_PATH/config
    echo 0x03D747A8 1 > $DCC_PATH/config
    echo 0x03D747AC 1 > $DCC_PATH/config
    echo 0x03D747B0 1 > $DCC_PATH/config
    echo 0x03D747B4 1 > $DCC_PATH/config
    echo 0x03D747B8 1 > $DCC_PATH/config
    echo 0x03D747BC 1 > $DCC_PATH/config
    echo 0x03D747C0 1 > $DCC_PATH/config
    echo 0x03D747C4 1 > $DCC_PATH/config
    echo 0x03D747C8 1 > $DCC_PATH/config
    echo 0x03D747CC 1 > $DCC_PATH/config
    echo 0x03D747D0 1 > $DCC_PATH/config
    echo 0x03D747D4 1 > $DCC_PATH/config
    echo 0x03D747D8 1 > $DCC_PATH/config
    echo 0x03D747DC 1 > $DCC_PATH/config
    echo 0x03D747E0 1 > $DCC_PATH/config
    echo 0x03D747E4 1 > $DCC_PATH/config
    echo 0x03D747E8 1 > $DCC_PATH/config
    echo 0x03D747EC 1 > $DCC_PATH/config
    echo 0x03D747F0 1 > $DCC_PATH/config
    echo 0x03D747F4 1 > $DCC_PATH/config
    echo 0x03D747F8 1 > $DCC_PATH/config
    echo 0x03D747FC 1 > $DCC_PATH/config
    echo 0x03D74800 1 > $DCC_PATH/config
    echo 0x03D74804 1 > $DCC_PATH/config
    echo 0x03D74808 1 > $DCC_PATH/config
    echo 0x03D7480C 1 > $DCC_PATH/config
    echo 0x03D74810 1 > $DCC_PATH/config
    echo 0x03D74814 1 > $DCC_PATH/config
    echo 0x03D74818 1 > $DCC_PATH/config
    echo 0x03D7481C 1 > $DCC_PATH/config
    echo 0x03D74820 1 > $DCC_PATH/config
    echo 0x03D74824 1 > $DCC_PATH/config
    echo 0x03D74828 1 > $DCC_PATH/config
    echo 0x03D7482C 1 > $DCC_PATH/config
    echo 0x03D74830 1 > $DCC_PATH/config
    echo 0x03D74834 1 > $DCC_PATH/config
    echo 0x03D74838 1 > $DCC_PATH/config
    echo 0x03D7483C 1 > $DCC_PATH/config
    echo 0x03D74840 1 > $DCC_PATH/config
    echo 0x03D74844 1 > $DCC_PATH/config
    echo 0x03D74848 1 > $DCC_PATH/config
    echo 0x03D7484C 1 > $DCC_PATH/config
    echo 0x03D74850 1 > $DCC_PATH/config
    echo 0x03D74854 1 > $DCC_PATH/config
    echo 0x03D74858 1 > $DCC_PATH/config
    echo 0x03D7485C 1 > $DCC_PATH/config
    echo 0x03D74860 1 > $DCC_PATH/config
    echo 0x03D74864 1 > $DCC_PATH/config
    echo 0x03D74868 1 > $DCC_PATH/config
    echo 0x03D7486C 1 > $DCC_PATH/config
    echo 0x03D74870 1 > $DCC_PATH/config
    echo 0x03D74874 1 > $DCC_PATH/config
    echo 0x03D74878 1 > $DCC_PATH/config
    echo 0x03D7487C 1 > $DCC_PATH/config
    echo 0x03D74880 1 > $DCC_PATH/config
    echo 0x03D74884 1 > $DCC_PATH/config
    echo 0x03D74888 1 > $DCC_PATH/config
    echo 0x03D7488C 1 > $DCC_PATH/config
    echo 0x03D74890 1 > $DCC_PATH/config
    echo 0x03D74894 1 > $DCC_PATH/config
    echo 0x03D74898 1 > $DCC_PATH/config
    echo 0x03D7489C 1 > $DCC_PATH/config
    echo 0x03D748A0 1 > $DCC_PATH/config
    echo 0x03D748A4 1 > $DCC_PATH/config
    echo 0x03D748A8 1 > $DCC_PATH/config
    echo 0x03D748AC 1 > $DCC_PATH/config
    echo 0x03D748B0 1 > $DCC_PATH/config
    echo 0x03D748B4 1 > $DCC_PATH/config
    echo 0x03D748B8 1 > $DCC_PATH/config
    echo 0x03D748BC 1 > $DCC_PATH/config
    echo 0x03D748C0 1 > $DCC_PATH/config
    echo 0x03D748C4 1 > $DCC_PATH/config
    echo 0x03D748C8 1 > $DCC_PATH/config
    echo 0x03D748CC 1 > $DCC_PATH/config
    echo 0x03D748D0 1 > $DCC_PATH/config
    echo 0x03D748D4 1 > $DCC_PATH/config
    echo 0x03D748D8 1 > $DCC_PATH/config
    echo 0x03D748DC 1 > $DCC_PATH/config
    echo 0x03D748E0 1 > $DCC_PATH/config
    echo 0x03D748E4 1 > $DCC_PATH/config
    echo 0x03D748E8 1 > $DCC_PATH/config
    echo 0x03D748EC 1 > $DCC_PATH/config
    echo 0x03D748F0 1 > $DCC_PATH/config
    echo 0x03D748F4 1 > $DCC_PATH/config
    echo 0x03D748F8 1 > $DCC_PATH/config
    echo 0x03D748FC 1 > $DCC_PATH/config
    echo 0x03D74900 1 > $DCC_PATH/config
    echo 0x03D74904 1 > $DCC_PATH/config
    echo 0x03D74908 1 > $DCC_PATH/config
    echo 0x03D7490C 1 > $DCC_PATH/config
    echo 0x03D74910 1 > $DCC_PATH/config
    echo 0x03D74914 1 > $DCC_PATH/config
    echo 0x03D74918 1 > $DCC_PATH/config
    echo 0x03D7491C 1 > $DCC_PATH/config
    echo 0x03D74920 1 > $DCC_PATH/config
    echo 0x03D74924 1 > $DCC_PATH/config
    echo 0x03D74928 1 > $DCC_PATH/config
    echo 0x03D7492C 1 > $DCC_PATH/config
    echo 0x03D74930 1 > $DCC_PATH/config
    echo 0x03D74934 1 > $DCC_PATH/config
    echo 0x03D74938 1 > $DCC_PATH/config
    echo 0x03D7493C 1 > $DCC_PATH/config
    echo 0x03D74940 1 > $DCC_PATH/config
    echo 0x03D74944 1 > $DCC_PATH/config
    echo 0x03D74948 1 > $DCC_PATH/config
    echo 0x03D7494C 1 > $DCC_PATH/config
    echo 0x03D74950 1 > $DCC_PATH/config
    echo 0x03D74954 1 > $DCC_PATH/config
    echo 0x03D74958 1 > $DCC_PATH/config
    echo 0x03D7495C 1 > $DCC_PATH/config
    echo 0x03D74960 1 > $DCC_PATH/config
    echo 0x03D74964 1 > $DCC_PATH/config
    echo 0x03D74968 1 > $DCC_PATH/config
    echo 0x03D7496C 1 > $DCC_PATH/config
    echo 0x03D74970 1 > $DCC_PATH/config
    echo 0x03D74974 1 > $DCC_PATH/config
    echo 0x03D74978 1 > $DCC_PATH/config
    echo 0x03D7497C 1 > $DCC_PATH/config
    echo 0x03D74980 1 > $DCC_PATH/config
    echo 0x03D74984 1 > $DCC_PATH/config
    echo 0x03D74988 1 > $DCC_PATH/config
    echo 0x03D7498C 1 > $DCC_PATH/config
    echo 0x03D74990 1 > $DCC_PATH/config
    echo 0x03D74994 1 > $DCC_PATH/config
    echo 0x03D74998 1 > $DCC_PATH/config
    echo 0x03D7499C 1 > $DCC_PATH/config
    echo 0x03D749A0 1 > $DCC_PATH/config
    echo 0x03D749A4 1 > $DCC_PATH/config
    echo 0x03D749A8 1 > $DCC_PATH/config
    echo 0x03D749AC 1 > $DCC_PATH/config
    echo 0x03D749B0 1 > $DCC_PATH/config
    echo 0x03D749B4 1 > $DCC_PATH/config
    echo 0x03D749B8 1 > $DCC_PATH/config
    echo 0x03D749BC 1 > $DCC_PATH/config
    echo 0x03D749C0 1 > $DCC_PATH/config
    echo 0x03D749C4 1 > $DCC_PATH/config
    echo 0x03D749C8 1 > $DCC_PATH/config
    echo 0x03D749CC 1 > $DCC_PATH/config
    echo 0x03D749D0 1 > $DCC_PATH/config
    echo 0x03D749D4 1 > $DCC_PATH/config
    echo 0x03D749D8 1 > $DCC_PATH/config
    echo 0x03D749DC 1 > $DCC_PATH/config
    echo 0x03D749E0 1 > $DCC_PATH/config
    echo 0x03D749E4 1 > $DCC_PATH/config
    echo 0x03D749E8 1 > $DCC_PATH/config
    echo 0x03D749EC 1 > $DCC_PATH/config
    echo 0x03D749F0 1 > $DCC_PATH/config
    echo 0x03D749F4 1 > $DCC_PATH/config
    echo 0x03D749F8 1 > $DCC_PATH/config
    echo 0x03D749FC 1 > $DCC_PATH/config
    echo 0x03D74A00 1 > $DCC_PATH/config
    echo 0x03D74A04 1 > $DCC_PATH/config
    echo 0x03D74A08 1 > $DCC_PATH/config
    echo 0x03D74A0C 1 > $DCC_PATH/config
    echo 0x03D74A10 1 > $DCC_PATH/config
    echo 0x03D74A14 1 > $DCC_PATH/config
    echo 0x03D74A18 1 > $DCC_PATH/config
    echo 0x03D74A1C 1 > $DCC_PATH/config
    echo 0x03D74A20 1 > $DCC_PATH/config
    echo 0x03D74A24 1 > $DCC_PATH/config
    echo 0x03D74A28 1 > $DCC_PATH/config
    echo 0x03D74A2C 1 > $DCC_PATH/config
    echo 0x03D74A30 1 > $DCC_PATH/config
    echo 0x03D74A34 1 > $DCC_PATH/config
    echo 0x03D74A38 1 > $DCC_PATH/config
    echo 0x03D74A3C 1 > $DCC_PATH/config
    echo 0x03D74A40 1 > $DCC_PATH/config
    echo 0x03D74A44 1 > $DCC_PATH/config
    echo 0x03D74A48 1 > $DCC_PATH/config
    echo 0x03D74A4C 1 > $DCC_PATH/config
    echo 0x03D74A50 1 > $DCC_PATH/config
    echo 0x03D74A54 1 > $DCC_PATH/config
    echo 0x03D74A58 1 > $DCC_PATH/config
    echo 0x03D74A5C 1 > $DCC_PATH/config
    echo 0x03D74A60 1 > $DCC_PATH/config
    echo 0x03D74A64 1 > $DCC_PATH/config
    echo 0x03D74A68 1 > $DCC_PATH/config
    echo 0x03D74A6C 1 > $DCC_PATH/config
    echo 0x03D74A70 1 > $DCC_PATH/config
    echo 0x03D74A74 1 > $DCC_PATH/config
    echo 0x03D74A78 1 > $DCC_PATH/config
    echo 0x03D74A7C 1 > $DCC_PATH/config
    echo 0x03D74A80 1 > $DCC_PATH/config
    echo 0x03D74A84 1 > $DCC_PATH/config
    echo 0x03D74A88 1 > $DCC_PATH/config
    echo 0x03D74A8C 1 > $DCC_PATH/config
    echo 0x03D74A90 1 > $DCC_PATH/config
    echo 0x03D74A94 1 > $DCC_PATH/config
    echo 0x03D74A98 1 > $DCC_PATH/config
    echo 0x03D74A9C 1 > $DCC_PATH/config
    echo 0x03D74AA0 1 > $DCC_PATH/config
    echo 0x03D74AA4 1 > $DCC_PATH/config
    echo 0x03D74AA8 1 > $DCC_PATH/config
    echo 0x03D74AAC 1 > $DCC_PATH/config
    echo 0x03D74AB0 1 > $DCC_PATH/config
    echo 0x03D74AB4 1 > $DCC_PATH/config
    echo 0x03D74AB8 1 > $DCC_PATH/config
    echo 0x03D74ABC 1 > $DCC_PATH/config
    echo 0x03D74AC0 1 > $DCC_PATH/config
    echo 0x03D74AC4 1 > $DCC_PATH/config
    echo 0x03D74AC8 1 > $DCC_PATH/config
    echo 0x03D74ACC 1 > $DCC_PATH/config
    echo 0x03D74AD0 1 > $DCC_PATH/config
    echo 0x03D74AD4 1 > $DCC_PATH/config
    echo 0x03D74AD8 1 > $DCC_PATH/config
    echo 0x03D74ADC 1 > $DCC_PATH/config
    echo 0x03D74AE0 1 > $DCC_PATH/config
    echo 0x03D74AE4 1 > $DCC_PATH/config
    echo 0x03D74AE8 1 > $DCC_PATH/config
    echo 0x03D74AEC 1 > $DCC_PATH/config
    echo 0x03D74AF0 1 > $DCC_PATH/config
    echo 0x03D74AF4 1 > $DCC_PATH/config
    echo 0x03D74AF8 1 > $DCC_PATH/config
    echo 0x03D74AFC 1 > $DCC_PATH/config
    echo 0x03D74B00 1 > $DCC_PATH/config
    echo 0x03D74B04 1 > $DCC_PATH/config
    echo 0x03D74B08 1 > $DCC_PATH/config
    echo 0x03D74B0C 1 > $DCC_PATH/config
    echo 0x03D74B10 1 > $DCC_PATH/config
    echo 0x03D74B14 1 > $DCC_PATH/config
    echo 0x03D74B18 1 > $DCC_PATH/config
    echo 0x03D74B1C 1 > $DCC_PATH/config
    echo 0x03D74B20 1 > $DCC_PATH/config
    echo 0x03D74B24 1 > $DCC_PATH/config
    echo 0x03D74B28 1 > $DCC_PATH/config
    echo 0x03D74B2C 1 > $DCC_PATH/config
    echo 0x03D74B30 1 > $DCC_PATH/config
    echo 0x03D74B34 1 > $DCC_PATH/config
    echo 0x03D74B38 1 > $DCC_PATH/config
    echo 0x03D74B3C 1 > $DCC_PATH/config
    echo 0x03D74B40 1 > $DCC_PATH/config
    echo 0x03D74B44 1 > $DCC_PATH/config
    echo 0x03D74B48 1 > $DCC_PATH/config
    echo 0x03D74B4C 1 > $DCC_PATH/config
    echo 0x03D74B50 1 > $DCC_PATH/config
    echo 0x03D74B54 1 > $DCC_PATH/config
    echo 0x03D74B58 1 > $DCC_PATH/config
    echo 0x03D74B5C 1 > $DCC_PATH/config
    echo 0x03D74B60 1 > $DCC_PATH/config
    echo 0x03D74B64 1 > $DCC_PATH/config
    echo 0x03D74B68 1 > $DCC_PATH/config
    echo 0x03D74B6C 1 > $DCC_PATH/config
    echo 0x03D74B70 1 > $DCC_PATH/config
    echo 0x03D74B74 1 > $DCC_PATH/config
    echo 0x03D74B78 1 > $DCC_PATH/config
    echo 0x03D74B7C 1 > $DCC_PATH/config
    echo 0x03D74B80 1 > $DCC_PATH/config
    echo 0x03D74B84 1 > $DCC_PATH/config
    echo 0x03D74B88 1 > $DCC_PATH/config
    echo 0x03D74B8C 1 > $DCC_PATH/config
    echo 0x03D74B90 1 > $DCC_PATH/config
    echo 0x03D74B94 1 > $DCC_PATH/config
    echo 0x03D74B98 1 > $DCC_PATH/config
    echo 0x03D74B9C 1 > $DCC_PATH/config
    echo 0x03D74BA0 1 > $DCC_PATH/config
    echo 0x03D74BA4 1 > $DCC_PATH/config
    echo 0x03D74BA8 1 > $DCC_PATH/config
    echo 0x03D74BAC 1 > $DCC_PATH/config
    echo 0x03D74BB0 1 > $DCC_PATH/config
    echo 0x03D74BB4 1 > $DCC_PATH/config
    echo 0x03D74BB8 1 > $DCC_PATH/config
    echo 0x03D74BBC 1 > $DCC_PATH/config
    echo 0x03D74BC0 1 > $DCC_PATH/config
    echo 0x03D74BC4 1 > $DCC_PATH/config
    echo 0x03D74BC8 1 > $DCC_PATH/config
    echo 0x03D74BCC 1 > $DCC_PATH/config
    echo 0x03D74BD0 1 > $DCC_PATH/config
    echo 0x03D74BD4 1 > $DCC_PATH/config
    echo 0x03D74BD8 1 > $DCC_PATH/config
    echo 0x03D74BDC 1 > $DCC_PATH/config
    echo 0x03D74BE0 1 > $DCC_PATH/config
    echo 0x03D74BE4 1 > $DCC_PATH/config
    echo 0x03D74BE8 1 > $DCC_PATH/config
    echo 0x03D74BEC 1 > $DCC_PATH/config
    echo 0x03D74BF0 1 > $DCC_PATH/config
    echo 0x03D74BF4 1 > $DCC_PATH/config
    echo 0x03D74BF8 1 > $DCC_PATH/config
    echo 0x03D74BFC 1 > $DCC_PATH/config
    echo 0x03D74C00 1 > $DCC_PATH/config
    echo 0x03D74C04 1 > $DCC_PATH/config
    echo 0x03D74C08 1 > $DCC_PATH/config
    echo 0x03D74C0C 1 > $DCC_PATH/config
    echo 0x03D74C10 1 > $DCC_PATH/config
    echo 0x03D74C14 1 > $DCC_PATH/config
    echo 0x03D74C18 1 > $DCC_PATH/config
    echo 0x03D74C1C 1 > $DCC_PATH/config
    echo 0x03D74C20 1 > $DCC_PATH/config
    echo 0x03D74C24 1 > $DCC_PATH/config
    echo 0x03D74C28 1 > $DCC_PATH/config
    echo 0x03D74C2C 1 > $DCC_PATH/config
    echo 0x03D74C30 1 > $DCC_PATH/config
    echo 0x03D74C34 1 > $DCC_PATH/config
    echo 0x03D74C38 1 > $DCC_PATH/config
    echo 0x03D74C3C 1 > $DCC_PATH/config
    echo 0x03D74C40 1 > $DCC_PATH/config
    echo 0x03D74C44 1 > $DCC_PATH/config
    echo 0x03D74C48 1 > $DCC_PATH/config
    echo 0x03D74C4C 1 > $DCC_PATH/config
    echo 0x03D74C50 1 > $DCC_PATH/config
    echo 0x03D74C54 1 > $DCC_PATH/config
    echo 0x03D74C58 1 > $DCC_PATH/config
    echo 0x03D74C5C 1 > $DCC_PATH/config
    echo 0x03D74C60 1 > $DCC_PATH/config
    echo 0x03D74C64 1 > $DCC_PATH/config
    echo 0x03D74C68 1 > $DCC_PATH/config
    echo 0x03D74C6C 1 > $DCC_PATH/config
    echo 0x03D74C70 1 > $DCC_PATH/config
    echo 0x03D74C74 1 > $DCC_PATH/config
    echo 0x03D74C78 1 > $DCC_PATH/config
    echo 0x03D74C7C 1 > $DCC_PATH/config
    echo 0x03D74C80 1 > $DCC_PATH/config
    echo 0x03D74C84 1 > $DCC_PATH/config
    echo 0x03D74C88 1 > $DCC_PATH/config
    echo 0x03D74C8C 1 > $DCC_PATH/config
    echo 0x03D74C90 1 > $DCC_PATH/config
    echo 0x03D74C94 1 > $DCC_PATH/config
    echo 0x03D74C98 1 > $DCC_PATH/config
    echo 0x03D74C9C 1 > $DCC_PATH/config
    echo 0x03D74CA0 1 > $DCC_PATH/config
    echo 0x03D74CA4 1 > $DCC_PATH/config
    echo 0x03D74CA8 1 > $DCC_PATH/config
    echo 0x03D74CAC 1 > $DCC_PATH/config
    echo 0x03D74CB0 1 > $DCC_PATH/config
    echo 0x03D74CB4 1 > $DCC_PATH/config
    echo 0x03D74CB8 1 > $DCC_PATH/config
    echo 0x03D74CBC 1 > $DCC_PATH/config
    echo 0x03D74CC0 1 > $DCC_PATH/config
    echo 0x03D74CC4 1 > $DCC_PATH/config
    echo 0x03D74CC8 1 > $DCC_PATH/config
    echo 0x03D74CCC 1 > $DCC_PATH/config
    echo 0x03D74CD0 1 > $DCC_PATH/config
    echo 0x03D74CD4 1 > $DCC_PATH/config
    echo 0x03D74CD8 1 > $DCC_PATH/config
    echo 0x03D74CDC 1 > $DCC_PATH/config
    echo 0x03D74CE0 1 > $DCC_PATH/config
    echo 0x03D74CE4 1 > $DCC_PATH/config
    echo 0x03D74CE8 1 > $DCC_PATH/config
    echo 0x03D74CEC 1 > $DCC_PATH/config
    echo 0x03D74CF0 1 > $DCC_PATH/config
    echo 0x03D74CF4 1 > $DCC_PATH/config
    echo 0x03D74CF8 1 > $DCC_PATH/config
    echo 0x03D74CFC 1 > $DCC_PATH/config
    echo 0x03D74D00 1 > $DCC_PATH/config
    echo 0x03D74D04 1 > $DCC_PATH/config
    echo 0x03D74D08 1 > $DCC_PATH/config
    echo 0x03D74D0C 1 > $DCC_PATH/config
    echo 0x03D74D10 1 > $DCC_PATH/config
    echo 0x03D74D14 1 > $DCC_PATH/config
    echo 0x03D74D18 1 > $DCC_PATH/config
    echo 0x03D74D1C 1 > $DCC_PATH/config
    echo 0x03D74D20 1 > $DCC_PATH/config
    echo 0x03D74D24 1 > $DCC_PATH/config
    echo 0x03D74D28 1 > $DCC_PATH/config
    echo 0x03D74D2C 1 > $DCC_PATH/config
    echo 0x03D74D30 1 > $DCC_PATH/config
    echo 0x03D74D34 1 > $DCC_PATH/config
    echo 0x03D74D38 1 > $DCC_PATH/config
    echo 0x03D74D3C 1 > $DCC_PATH/config
    echo 0x03D74D40 1 > $DCC_PATH/config
    echo 0x03D74D44 1 > $DCC_PATH/config
    echo 0x03D74D48 1 > $DCC_PATH/config
    echo 0x03D74D4C 1 > $DCC_PATH/config
    echo 0x03D74D50 1 > $DCC_PATH/config
    echo 0x03D74D54 1 > $DCC_PATH/config
    echo 0x03D74D58 1 > $DCC_PATH/config
    echo 0x03D74D5C 1 > $DCC_PATH/config
    echo 0x03D74D60 1 > $DCC_PATH/config
    echo 0x03D74D64 1 > $DCC_PATH/config
    echo 0x03D74D68 1 > $DCC_PATH/config
    echo 0x03D74D6C 1 > $DCC_PATH/config
    echo 0x03D74D70 1 > $DCC_PATH/config
    echo 0x03D74D74 1 > $DCC_PATH/config
    echo 0x03D74D78 1 > $DCC_PATH/config
    echo 0x03D74D7C 1 > $DCC_PATH/config
    echo 0x03D74D80 1 > $DCC_PATH/config
    echo 0x03D74D84 1 > $DCC_PATH/config
    echo 0x03D74D88 1 > $DCC_PATH/config
    echo 0x03D74D8C 1 > $DCC_PATH/config
    echo 0x03D74D90 1 > $DCC_PATH/config
    echo 0x03D74D94 1 > $DCC_PATH/config
    echo 0x03D74D98 1 > $DCC_PATH/config
    echo 0x03D74D9C 1 > $DCC_PATH/config
    echo 0x03D74DA0 1 > $DCC_PATH/config
    echo 0x03D74DA4 1 > $DCC_PATH/config
    echo 0x03D74DA8 1 > $DCC_PATH/config
    echo 0x03D74DAC 1 > $DCC_PATH/config
    echo 0x03D74DB0 1 > $DCC_PATH/config
    echo 0x03D74DB4 1 > $DCC_PATH/config
    echo 0x03D74DB8 1 > $DCC_PATH/config
    echo 0x03D74DBC 1 > $DCC_PATH/config
    echo 0x03D74DC0 1 > $DCC_PATH/config
    echo 0x03D74DC4 1 > $DCC_PATH/config
    echo 0x03D74DC8 1 > $DCC_PATH/config
    echo 0x03D74DCC 1 > $DCC_PATH/config
    echo 0x03D74DD0 1 > $DCC_PATH/config
    echo 0x03D74DD4 1 > $DCC_PATH/config
    echo 0x03D74DD8 1 > $DCC_PATH/config
    echo 0x03D74DDC 1 > $DCC_PATH/config
    echo 0x03D74DE0 1 > $DCC_PATH/config
    echo 0x03D74DE4 1 > $DCC_PATH/config
    echo 0x03D74DE8 1 > $DCC_PATH/config
    echo 0x03D74DEC 1 > $DCC_PATH/config
    echo 0x03D74DF0 1 > $DCC_PATH/config
    echo 0x03D74DF4 1 > $DCC_PATH/config
    echo 0x03D74DF8 1 > $DCC_PATH/config
    echo 0x03D74DFC 1 > $DCC_PATH/config
    echo 0x03D74E00 1 > $DCC_PATH/config
    echo 0x03D74E04 1 > $DCC_PATH/config
    echo 0x03D74E08 1 > $DCC_PATH/config
    echo 0x03D74E0C 1 > $DCC_PATH/config
    echo 0x03D74E10 1 > $DCC_PATH/config
    echo 0x03D74E14 1 > $DCC_PATH/config
    echo 0x03D74E18 1 > $DCC_PATH/config
    echo 0x03D74E1C 1 > $DCC_PATH/config
    echo 0x03D74E20 1 > $DCC_PATH/config
    echo 0x03D74E24 1 > $DCC_PATH/config
    echo 0x03D74E28 1 > $DCC_PATH/config
    echo 0x03D74E2C 1 > $DCC_PATH/config
    echo 0x03D74E30 1 > $DCC_PATH/config
    echo 0x03D74E34 1 > $DCC_PATH/config
    echo 0x03D74E38 1 > $DCC_PATH/config
    echo 0x03D74E3C 1 > $DCC_PATH/config
    echo 0x03D74E40 1 > $DCC_PATH/config
    echo 0x03D74E44 1 > $DCC_PATH/config
    echo 0x03D74E48 1 > $DCC_PATH/config
    echo 0x03D74E4C 1 > $DCC_PATH/config
    echo 0x03D74E50 1 > $DCC_PATH/config
    echo 0x03D74E54 1 > $DCC_PATH/config
    echo 0x03D74E58 1 > $DCC_PATH/config
    echo 0x03D74E5C 1 > $DCC_PATH/config
    echo 0x03D74E60 1 > $DCC_PATH/config
    echo 0x03D74E64 1 > $DCC_PATH/config
    echo 0x03D74E68 1 > $DCC_PATH/config
    echo 0x03D74E6C 1 > $DCC_PATH/config
    echo 0x03D74E70 1 > $DCC_PATH/config
    echo 0x03D74E74 1 > $DCC_PATH/config
    echo 0x03D74E78 1 > $DCC_PATH/config
    echo 0x03D74E7C 1 > $DCC_PATH/config
    echo 0x03D74E80 1 > $DCC_PATH/config
    echo 0x03D74E84 1 > $DCC_PATH/config
    echo 0x03D74E88 1 > $DCC_PATH/config
    echo 0x03D74E8C 1 > $DCC_PATH/config
    echo 0x03D74E90 1 > $DCC_PATH/config
    echo 0x03D74E94 1 > $DCC_PATH/config
    echo 0x03D74E98 1 > $DCC_PATH/config
    echo 0x03D74E9C 1 > $DCC_PATH/config
    echo 0x03D74EA0 1 > $DCC_PATH/config
    echo 0x03D74EA4 1 > $DCC_PATH/config
    echo 0x03D74EA8 1 > $DCC_PATH/config
    echo 0x03D74EAC 1 > $DCC_PATH/config
    echo 0x03D74EB0 1 > $DCC_PATH/config
    echo 0x03D74EB4 1 > $DCC_PATH/config
    echo 0x03D74EB8 1 > $DCC_PATH/config
    echo 0x03D74EBC 1 > $DCC_PATH/config
    echo 0x03D74EC0 1 > $DCC_PATH/config
    echo 0x03D74EC4 1 > $DCC_PATH/config
    echo 0x03D74EC8 1 > $DCC_PATH/config
    echo 0x03D74ECC 1 > $DCC_PATH/config
    echo 0x03D74ED0 1 > $DCC_PATH/config
    echo 0x03D74ED4 1 > $DCC_PATH/config
    echo 0x03D74ED8 1 > $DCC_PATH/config
    echo 0x03D74EDC 1 > $DCC_PATH/config
    echo 0x03D74EE0 1 > $DCC_PATH/config
    echo 0x03D74EE4 1 > $DCC_PATH/config
    echo 0x03D74EE8 1 > $DCC_PATH/config
    echo 0x03D74EEC 1 > $DCC_PATH/config
    echo 0x03D74EF0 1 > $DCC_PATH/config
    echo 0x03D74EF4 1 > $DCC_PATH/config
    echo 0x03D74EF8 1 > $DCC_PATH/config
    echo 0x03D74EFC 1 > $DCC_PATH/config
    echo 0x03D74F00 1 > $DCC_PATH/config
    echo 0x03D74F04 1 > $DCC_PATH/config
    echo 0x03D74F08 1 > $DCC_PATH/config
    echo 0x03D74F0C 1 > $DCC_PATH/config
    echo 0x03D74F10 1 > $DCC_PATH/config
    echo 0x03D74F14 1 > $DCC_PATH/config
    echo 0x03D74F18 1 > $DCC_PATH/config
    echo 0x03D74F1C 1 > $DCC_PATH/config
    echo 0x03D74F20 1 > $DCC_PATH/config
    echo 0x03D74F24 1 > $DCC_PATH/config
    echo 0x03D74F28 1 > $DCC_PATH/config
    echo 0x03D74F2C 1 > $DCC_PATH/config
    echo 0x03D74F30 1 > $DCC_PATH/config
    echo 0x03D74F34 1 > $DCC_PATH/config
    echo 0x03D74F38 1 > $DCC_PATH/config
    echo 0x03D74F3C 1 > $DCC_PATH/config
    echo 0x03D74F40 1 > $DCC_PATH/config
    echo 0x03D74F44 1 > $DCC_PATH/config
    echo 0x03D74F48 1 > $DCC_PATH/config
    echo 0x03D74F4C 1 > $DCC_PATH/config
    echo 0x03D74F50 1 > $DCC_PATH/config
    echo 0x03D74F54 1 > $DCC_PATH/config
    echo 0x03D74F58 1 > $DCC_PATH/config
    echo 0x03D74F5C 1 > $DCC_PATH/config
    echo 0x03D74F60 1 > $DCC_PATH/config
    echo 0x03D74F64 1 > $DCC_PATH/config
    echo 0x03D74F68 1 > $DCC_PATH/config
    echo 0x03D74F6C 1 > $DCC_PATH/config
    echo 0x03D74F70 1 > $DCC_PATH/config
    echo 0x03D74F74 1 > $DCC_PATH/config
    echo 0x03D74F78 1 > $DCC_PATH/config
    echo 0x03D74F7C 1 > $DCC_PATH/config
    echo 0x03D74F80 1 > $DCC_PATH/config
    echo 0x03D74F84 1 > $DCC_PATH/config
    echo 0x03D74F88 1 > $DCC_PATH/config
    echo 0x03D74F8C 1 > $DCC_PATH/config
    echo 0x03D74F90 1 > $DCC_PATH/config
    echo 0x03D74F94 1 > $DCC_PATH/config
    echo 0x03D74F98 1 > $DCC_PATH/config
    echo 0x03D74F9C 1 > $DCC_PATH/config
    echo 0x03D74FA0 1 > $DCC_PATH/config
    echo 0x03D74FA4 1 > $DCC_PATH/config
    echo 0x03D74FA8 1 > $DCC_PATH/config
    echo 0x03D74FAC 1 > $DCC_PATH/config
    echo 0x03D74FB0 1 > $DCC_PATH/config
    echo 0x03D74FB4 1 > $DCC_PATH/config
    echo 0x03D74FB8 1 > $DCC_PATH/config
    echo 0x03D74FBC 1 > $DCC_PATH/config
    echo 0x03D74FC0 1 > $DCC_PATH/config
    echo 0x03D74FC4 1 > $DCC_PATH/config
    echo 0x03D74FC8 1 > $DCC_PATH/config
    echo 0x03D74FCC 1 > $DCC_PATH/config
    echo 0x03D74FD0 1 > $DCC_PATH/config
    echo 0x03D74FD4 1 > $DCC_PATH/config
    echo 0x03D74FD8 1 > $DCC_PATH/config
    echo 0x03D74FDC 1 > $DCC_PATH/config
    echo 0x03D74FE0 1 > $DCC_PATH/config
    echo 0x03D74FE4 1 > $DCC_PATH/config
    echo 0x03D74FE8 1 > $DCC_PATH/config
    echo 0x03D74FEC 1 > $DCC_PATH/config
    echo 0x03D74FF0 1 > $DCC_PATH/config
    echo 0x03D74FF4 1 > $DCC_PATH/config
    echo 0x03D74FF8 1 > $DCC_PATH/config
    echo 0x03D74FFC 1 > $DCC_PATH/config
}

config_sdc_wa()
{
    echo 0x00185000 1 > $DCC_PATH/config
    echo 0x00185000 1  > $DCC_PATH/config_write
    echo 0x00185000 1 > $DCC_PATH/config
    echo 0x1084C000 1 1 > $DCC_PATH/config
    echo 0x10C06000 1 1 > $DCC_PATH/config
    echo 0x1084C000 0 1 > $DCC_PATH/config_write
    echo 0x10C06000 0 1 > $DCC_PATH/config_write
    echo 0x1084C000 1 1 > $DCC_PATH/config
    echo 0x10C06000 1 1 > $DCC_PATH/config
    echo 0x01FC4080 3 > $DCC_PATH/config
    echo 0x01FC4090 1 > $DCC_PATH/config
}

config_lpass()
{
    #LPASS RSC
    echo 0x6802028 1 > $DCC_PATH/config
    echo 0x68B0408 1 > $DCC_PATH/config
    echo 0x68B0404 1 > $DCC_PATH/config
    echo 0x7200408 1 > $DCC_PATH/config
    echo 0x7200404 1 > $DCC_PATH/config
}

config_qdsp_lpm()
{
    # LPASS
    echo 0x6802028 1 > $DCC_PATH/config
    echo 0x68B0404 2 > $DCC_PATH/config
    echo 0x68B0208 3 > $DCC_PATH/config
    echo 0x68B0228 3 > $DCC_PATH/config
    echo 0x68B0248 3 > $DCC_PATH/config
    echo 0x68B0268 3 > $DCC_PATH/config
    echo 0x7200404 2 > $DCC_PATH/config
    echo 0x7200208 3 > $DCC_PATH/config
    echo 0x7200228 3 > $DCC_PATH/config
    echo 0x7200248 3 > $DCC_PATH/config
    echo 0x7200268 3 > $DCC_PATH/config

    # NSP
    echo 0x32302028 1 > $DCC_PATH/config
    echo 0x323B0404 2 > $DCC_PATH/config
    echo 0x323B0208 3 > $DCC_PATH/config
    echo 0x323B0228 3 > $DCC_PATH/config
    echo 0x323B0248 3 > $DCC_PATH/config
    echo 0x323B0268 3 > $DCC_PATH/config
    echo 0x320A4404 2 > $DCC_PATH/config
    echo 0x320A4208 3 > $DCC_PATH/config
    echo 0x320A4228 3 > $DCC_PATH/config
    echo 0x320A4248 3 > $DCC_PATH/config
    echo 0x320A4268 3 > $DCC_PATH/config

    # MODEM
    echo 0x4082028 1 > $DCC_PATH/config
    echo 0x4130404 2 > $DCC_PATH/config
    echo 0x4130208 3 > $DCC_PATH/config
    echo 0x4130228 3 > $DCC_PATH/config
    echo 0x4130248 3 > $DCC_PATH/config
    echo 0x4130268 3 > $DCC_PATH/config
    echo 0x4200404 2 > $DCC_PATH/config
    echo 0x4200208 3 > $DCC_PATH/config
    echo 0x4200228 3 > $DCC_PATH/config
    echo 0x4200248 3 > $DCC_PATH/config
    echo 0x4200268 3 > $DCC_PATH/config
}

config_dcc_anoc_pcie()
{
    echo 0x110004 1 > $DCC_PATH/config
    echo 0x110008 1 > $DCC_PATH/config
    echo 0x11003C 1 > $DCC_PATH/config
    echo 0x110040 1 > $DCC_PATH/config
    echo 0x110044 1 > $DCC_PATH/config
    echo 0x11015C 1 > $DCC_PATH/config
    echo 0x110160 1 > $DCC_PATH/config
    echo 0x110464 1 > $DCC_PATH/config
    echo 0x110468 1 > $DCC_PATH/config
    #RPMH_SYS_NOC_CMD_DFSR
    echo 0x176040 1 > $DCC_PATH/config
}

enable_dcc()
{
    #TODO: Add DCC configuration
    DCC_PATH="/sys/bus/platform/devices/100ff000.dcc_v2"
    soc_version=`cat /sys/devices/soc0/revision`
    soc_version=${soc_version/./}

    if [ ! -d $DCC_PATH ]; then
        echo "DCC does not exist on this build."
        return
    fi

    echo 0 > $DCC_PATH/enable
    echo 1 > $DCC_PATH/config_reset
    echo 6 > $DCC_PATH/curr_list
    echo cap > $DCC_PATH/func_type
    echo sram > $DCC_PATH/data_sink
    #config_dcc_tsens
    config_sdc_wa
    config_qdsp_lpm
    config_dcc_core
    #config_smmu

    gemnoc_dump
    #config_gpu
    config_dcc_lpm_pcu
    config_dcc_lpm
    config_dcc_ddr
    config_adsp

    echo 4 > $DCC_PATH/curr_list
    echo cap > $DCC_PATH/func_type
    echo sram > $DCC_PATH/data_sink
    dc_noc_dump
    config_lpass
    mmss_noc_dump
    system_noc_dump
    aggre_noc_dump
    config_noc_dump

    config_dcc_gic
    config_dcc_rpmh
    config_dcc_apss_rscc
    config_dcc_misc
    config_dcc_epss
    config_dcc_gict
    config_dcc_anoc_pcie
    config_gpu

    #echo 3 > $DCC_PATH/curr_list
    #echo cap > $DCC_PATH/func_type
    #echo sram > $DCC_PATH/data_sink
    #config_confignoc
    #enable_dcc_pll_status

    echo  1 > $DCC_PATH/enable
}

##################################
# ACTPM trace API - usage example
##################################

actpm_traces_configure()
{
  echo ++++++++++++++++++++++++++++++++++++++
  echo actpm_traces_configure
  echo ++++++++++++++++++++++++++++++++++++++

  echo 1 > /sys/bus/coresight/devices/coresight-tpdm-actpm/reset
  ### CMB_MSR : [10]: debug_en, [7:6] : 0x0-0x3 : clkdom0-clkdom3 debug_bus
  ###         : [5]: trace_en, [4]: 0b0:continuous mode 0b1 : legacy mode
  ###         : [3:0] : legacy mode : 0x0 : combined_traces 0x1-0x4 : clkdom0-clkdom3
  echo 0 0x420 > /sys/bus/coresight/devices/coresight-tpdm-actpm/cmb_msr
  echo 0 > /sys/bus/coresight/devices/coresight-tpdm-actpm/mcmb_lanes_select
  echo 1 0 > /sys/bus/coresight/devices/coresight-tpdm-actpm/cmb_mode
  #echo 1 > /sys/bus/coresight/devices/coresight-tpda-actpm/cmbchan_mode
  echo 1 > /sys/bus/coresight/devices/coresight-tpdm-actpm/cmb_ts_all
  echo 1 > /sys/bus/coresight/devices/coresight-tpdm-actpm/cmb_patt_ts
  echo 0 0x20000000 > /sys/bus/coresight/devices/coresight-tpdm-actpm/cmb_patt_mask
  echo 0 0x20000000 > /sys/bus/coresight/devices/coresight-tpdm-actpm/cmb_patt_val

}

actpm_traces_start()
{
  echo ++++++++++++++++++++++++++++++++++++++
  echo actpm_traces_start
  echo ++++++++++++++++++++++++++++++++++++++
  # "Start actpm Trace collection "
  echo 0x4 > /sys/bus/coresight/devices/coresight-tpdm-actpm/enable_datasets
  echo 1 > /sys/bus/coresight/devices/coresight-tpdm-actpm/enable_source
}

stm_traces_configure()
{
  echo ++++++++++++++++++++++++++++++++++++++
  echo stm_traces_configure
  echo ++++++++++++++++++++++++++++++++++++++
  echo 0 > /sys/bus/coresight/devices/coresight-stm/hwevent_enable
}

stm_traces_start()
{
  echo ++++++++++++++++++++++++++++++++++++++
  echo stm_traces_start
  echo ++++++++++++++++++++++++++++++++++++++
  echo 1 > /sys/bus/coresight/devices/coresight-stm/enable_source
}

ipm_traces_configure()
{
  echo 1 > /sys/bus/coresight/devices/coresight-tpdm-apss/reset
  echo 0x0 0x3f 0x1 > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_edge_ctrl_mask
  echo 0x0 0x3f 0 > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_edge_ctrl
  #gic HW events
  echo 0xfb 0xfc 0x1 > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_edge_ctrl_mask
  echo 0xfb 0xfc 0 > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_edge_ctrl
  echo 0 0x00000000  > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_msr
  echo 1 0x00000000  > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_msr
  echo 2 0x00000000  > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_msr
  echo 3 0x00000000  > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_msr
  echo 4 0x00000000  > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_msr
  echo 5 0x00000000  > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_msr
  echo 6 0x00000000  > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_msr
  echo 7 0x00000000  > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_msr
  echo 1 > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_patt_ts
  echo 1 > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_patt_type
  echo 0 > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_trig_ts
  echo 0 0xFFFFFFFF > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_patt_mask
  echo 1 0xFFFFFFFF > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_patt_mask
  echo 2 0xFFFFFFFF > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_patt_mask
  echo 3 0xFFFFFFFF > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_patt_mask
  echo 4 0xFFFFFFFF > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_patt_mask
  echo 5 0xFFFFFFFF > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_patt_mask
  echo 6 0xFFFFFFFF > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_patt_mask
  echo 7 0xFFFFFFFF > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_patt_mask

  echo 1 > /sys/bus/coresight/devices/coresight-tpdm-apss-llm/reset
  echo 0x0 0x2 0x1 > /sys/bus/coresight/devices/coresight-tpdm-apss-llm/dsb_edge_ctrl_mask
  echo 0x0 0x2 0 > /sys/bus/coresight/devices/coresight-tpdm-apss-llm/dsb_edge_ctrl
  echo 0x8a 0x8b 0x1 > /sys/bus/coresight/devices/coresight-tpdm-apss-llm/dsb_edge_ctrl_mask
  echo 0x8a 0x8b 0 > /sys/bus/coresight/devices/coresight-tpdm-apss-llm/dsb_edge_ctrl
  echo 0xb8 0xca 0x1 > /sys/bus/coresight/devices/coresight-tpdm-apss-llm/dsb_edge_ctrl_mask
  echo 0xb8 0xca 0 > /sys/bus/coresight/devices/coresight-tpdm-apss-llm/dsb_edge_ctrl
  echo 1 > /sys/bus/coresight/devices/coresight-tpdm-apss-llm/dsb_patt_ts
  echo 1 > /sys/bus/coresight/devices/coresight-tpdm-apss-llm/dsb_patt_type
  echo 0 > /sys/bus/coresight/devices/coresight-tpdm-apss-llm/dsb_trig_ts
  echo 0 0xFFFFFFFF > /sys/bus/coresight/devices/coresight-tpdm-apss-llm/dsb_patt_mask
  echo 1 0xFFFFFFFF > /sys/bus/coresight/devices/coresight-tpdm-apss-llm/dsb_patt_mask
  echo 2 0xFFFFFFFF > /sys/bus/coresight/devices/coresight-tpdm-apss-llm/dsb_patt_mask
  echo 3 0xFFFFFFFF > /sys/bus/coresight/devices/coresight-tpdm-apss-llm/dsb_patt_mask
  echo 4 0xFFFFFFFF > /sys/bus/coresight/devices/coresight-tpdm-apss-llm/dsb_patt_mask
  echo 5 0xFFFFFFFF > /sys/bus/coresight/devices/coresight-tpdm-apss-llm/dsb_patt_mask
  echo 6 0xFFFFFFFF > /sys/bus/coresight/devices/coresight-tpdm-apss-llm/dsb_patt_mask
  echo 7 0xFFFFFFFF > /sys/bus/coresight/devices/coresight-tpdm-apss-llm/dsb_patt_mask

}

ipm_traces_start()
{
  # "Start ipm Trace collection "
  echo 2 > /sys/bus/coresight/devices/coresight-tpdm-apss/enable_datasets
  echo 1 > /sys/bus/coresight/devices/coresight-tpdm-apss/enable_source
  echo 2 > /sys/bus/coresight/devices/coresight-tpdm-apss-llm/enable_datasets
  echo 1 > /sys/bus/coresight/devices/coresight-tpdm-apss-llm/enable_source

}

enable_cpuss_hw_events()
{
    actpm_traces_configure
    ipm_traces_configure
    stm_traces_configure

    ipm_traces_start
    stm_traces_start
    actpm_traces_start
}

adjust_permission()
{
    #add permission for block_size, mem_type, mem_size nodes to collect diag over QDSS by ODL
    #application by "oem_2902" group
    chown -h root.oem_2902 /sys/devices/platform/soc/10048000.tmc/coresight-tmc-etr/block_size
    chmod 660 /sys/devices/platform/soc/10048000.tmc/coresight-tmc-etr/block_size
    chown -h root.oem_2902 /sys/devices/platform/soc/10048000.tmc/coresight-tmc-etr/buffer_size
    chmod 660 /sys/devices/platform/soc/10048000.tmc/coresight-tmc-etr/buffer_size
    chmod 660 /sys/devices/platform/soc/10048000.tmc/coresight-tmc-etr/out_mode
    chown -h root.oem_2902 /sys/devices/platform/soc/1004f000.tmc/coresight-tmc-etr1/block_size
    chmod 660 /sys/devices/platform/soc/1004f000.tmc/coresight-tmc-etr1/block_size
    chown -h root.oem_2902 /sys/devices/platform/soc/1004f000.tmc/coresight-tmc-etr1/buffer_size
    chmod 660 /sys/devices/platform/soc/1004f000.tmc/coresight-tmc-etr1/buffer_size
    chmod 660 /sys/devices/platform/soc/1004f000.tmc/coresight-tmc-etr1/out_mode
    chmod 660 /sys/devices/platform/soc/1004f000.tmc/coresight-tmc-etr1/enable_sink
    chmod 660 /sys/devices/platform/soc/soc:modem_diag/coresight-modem-diag/enable_source
    chown -h root.oem_2902 /sys/bus/coresight/reset_source_sink
    chmod 660 /sys/bus/coresight/reset_source_sink
}

enable_schedstats()
{
    # bail out if its perf config
    if [ ! -d /sys/module/msm_rtb ]
    then
        return
    fi

    if [ -f /proc/sys/kernel/sched_schedstats ]
    then
        echo 1 > /proc/sys/kernel/sched_schedstats
    fi
}

enable_cpuss_register()
{
	echo 1 > /sys/bus/platform/devices/soc:mem_dump/register_reset

	echo 0x17000000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17000008 0x48 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17000054 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x170000f0 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17000100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17008000 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17100000 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17100020 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17100030 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17100084 0x74 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17100104 0x74 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17100184 0x74 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17100204 0x74 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17100284 0x74 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17100304 0x74 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17100384 0x74 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17100420 0x3a0 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17100c08 0xe8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17100d04 0x74 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17100e08 0xe8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106108 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106110 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106118 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106120 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106128 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106130 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106138 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106140 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106148 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106150 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106158 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106160 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106168 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106170 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106178 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106180 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106188 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106190 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106198 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171061a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171061a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171061b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171061b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171061c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171061c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171061d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171061d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171061e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171061e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171061f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171061f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106200 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106208 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106210 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106218 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106220 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106228 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106230 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106238 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106240 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106248 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106250 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106258 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106260 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106268 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106270 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106278 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106280 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106288 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106290 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106298 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171062a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171062a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171062b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171062b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171062c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171062c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171062d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171062d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171062e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171062e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171062f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171062f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106300 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106308 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106310 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106318 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106320 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106328 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106330 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106338 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106340 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106348 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106350 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106358 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106360 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106368 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106370 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106378 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106380 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106388 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106390 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106398 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171063a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171063a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171063b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171063b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171063c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171063c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171063d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171063d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171063e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171063e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171063f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171063f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106400 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106408 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106410 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106418 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106420 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106428 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106430 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106438 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106440 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106448 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106450 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106458 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106460 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106468 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106470 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106478 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106480 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106488 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106490 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106498 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171064a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171064a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171064b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171064b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171064c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171064c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171064d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171064d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171064e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171064e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171064f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171064f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106500 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106508 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106510 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106518 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106520 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106528 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106530 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106538 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106540 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106548 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106550 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106558 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106560 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106568 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106570 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106578 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106580 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106588 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106590 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106598 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171065a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171065a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171065b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171065b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171065c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171065c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171065d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171065d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171065e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171065e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171065f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171065f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106600 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106608 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106610 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106618 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106620 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106628 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106630 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106638 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106640 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106648 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106650 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106658 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106660 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106668 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106670 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106678 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106680 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106688 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106690 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106698 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171066a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171066a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171066b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171066b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171066c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171066c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171066d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171066d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171066e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171066e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171066f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171066f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106700 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106708 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106710 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106718 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106720 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106728 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106730 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106738 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106740 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106748 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106750 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106758 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106760 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106768 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106770 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106778 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106780 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106788 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106790 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106798 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171067a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171067a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171067b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171067b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171067c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171067c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171067d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171067d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171067e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171067e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171067f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171067f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106800 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106808 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106810 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106818 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106820 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106828 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106830 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106838 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106840 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106848 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106850 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106858 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106860 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106868 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106870 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106878 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106880 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106888 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106890 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106898 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171068a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171068a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171068b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171068b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171068c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171068c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171068d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171068d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171068e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171068e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171068f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171068f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106900 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106908 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106910 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106918 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106920 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106928 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106930 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106938 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106940 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106948 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106950 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106958 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106960 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106968 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106970 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106978 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106980 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106988 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106990 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106998 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171069a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171069a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171069b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171069b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171069c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171069c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171069d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171069d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171069e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171069e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171069f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171069f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106a00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106a08 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106a10 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106a18 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106a20 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106a28 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106a30 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106a38 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106a40 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106a48 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106a50 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106a58 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106a60 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106a68 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106a70 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106a78 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106a80 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106a88 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106a90 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106a98 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106aa0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106aa8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106ab0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106ab8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106ac0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106ac8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106ad0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106ad8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106ae0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106ae8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106af0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106af8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106b00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106b08 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106b10 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106b18 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106b20 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106b28 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106b30 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106b38 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106b40 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106b48 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106b50 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106b58 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106b60 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106b68 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106b70 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106b78 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106b80 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106b88 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106b90 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106b98 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106ba0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106ba8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106bb0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106bb8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106bc0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106bc8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106bd0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106bd8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106be0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106be8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106bf0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106bf8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106c00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106c08 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106c10 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106c18 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106c20 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106c28 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106c30 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106c38 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106c40 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106c48 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106c50 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106c58 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106c60 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106c68 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106c70 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106c78 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106c80 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106c88 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106c90 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106c98 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106ca0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106ca8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106cb0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106cb8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106cc0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106cc8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106cd0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106cd8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106ce0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106ce8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106cf0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106cf8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106d00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106d08 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106d10 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106d18 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106d20 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106d28 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106d30 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106d38 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106d40 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106d48 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106d50 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106d58 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106d60 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106d68 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106d70 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106d78 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106d80 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106d88 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106d90 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106d98 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106da0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106da8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106db0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106db8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106dc0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106dc8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106dd0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106dd8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106de0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106de8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106df0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106df8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106e00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106e08 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106e10 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106e18 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106e20 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106e28 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106e30 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106e38 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106e40 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106e48 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106e50 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106e58 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106e60 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106e68 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106e70 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106e78 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106e80 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106e88 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106e90 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106e98 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106ea0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106ea8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106eb0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106eb8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106ec0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106ec8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106ed0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106ed8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106ee0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106ee8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106ef0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106ef8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106f00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106f08 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106f10 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106f18 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106f20 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106f28 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106f30 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106f38 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106f40 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106f48 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106f50 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106f58 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106f60 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106f68 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106f70 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106f78 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106f80 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106f88 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106f90 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106f98 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106fa0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106fa8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106fb0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106fb8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106fc0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106fc8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106fd0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106fd8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106fe0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106fe8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106ff0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106ff8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107008 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107018 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107020 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107028 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107030 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107038 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107040 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107048 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107050 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107058 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107060 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107068 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107070 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107078 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107080 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107088 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107090 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107098 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171070a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171070a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171070b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171070b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171070c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171070c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171070d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171070d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171070e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171070e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171070f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171070f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107108 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107110 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107118 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107120 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107128 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107130 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107138 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107140 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107148 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107150 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107158 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107160 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107168 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107170 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107178 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107180 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107188 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107190 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107198 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171071a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171071a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171071b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171071b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171071c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171071c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171071d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171071d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171071e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171071e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171071f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171071f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107200 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107208 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107210 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107218 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107220 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107228 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107230 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107238 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107240 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107248 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107250 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107258 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107260 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107268 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107270 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107278 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107280 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107288 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107290 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107298 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171072a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171072a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171072b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171072b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171072c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171072c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171072d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171072d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171072e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171072e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171072f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171072f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107300 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107308 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107310 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107318 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107320 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107328 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107330 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107338 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107340 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107348 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107350 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107358 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107360 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107368 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107370 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107378 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107380 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107388 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107390 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107398 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171073a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171073a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171073b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171073b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171073c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171073c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171073d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171073d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171073e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171073e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171073f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171073f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107400 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107408 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107410 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107418 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107420 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107428 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107430 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107438 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107440 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107448 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107450 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107458 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107460 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107468 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107470 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107478 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107480 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107488 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107490 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107498 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171074a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171074a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171074b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171074b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171074c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171074c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171074d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171074d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171074e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171074e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171074f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171074f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107500 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107508 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107510 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107518 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107520 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107528 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107530 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107538 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107540 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107548 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107550 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107558 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107560 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107568 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107570 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107578 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107580 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107588 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107590 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107598 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171075a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171075a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171075b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171075b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171075c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171075c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171075d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171075d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171075e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171075e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171075f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171075f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107600 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107608 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107610 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107618 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107620 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107628 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107630 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107638 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107640 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107648 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107650 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107658 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107660 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107668 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107670 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107678 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107680 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107688 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107690 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107698 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171076a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171076a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171076b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171076b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171076c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171076c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171076d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171076d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171076e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171076e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171076f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171076f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107700 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107708 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107710 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107718 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107720 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107728 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107730 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107738 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107740 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107748 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107750 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107758 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107760 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107768 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107770 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107778 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107780 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107788 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107790 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107798 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171077a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171077a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171077b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171077b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171077c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171077c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171077d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171077d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171077e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171077e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171077f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171077f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107800 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107808 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107810 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107818 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107820 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107828 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107830 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107838 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107840 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107848 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107850 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107858 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107860 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107868 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107870 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107878 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107880 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107888 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107890 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107898 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171078a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171078a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171078b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171078b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171078c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171078c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171078d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171078d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171078e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171078e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171078f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171078f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107900 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107908 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107910 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107918 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107920 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107928 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107930 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107938 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107940 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107948 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107950 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107958 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107960 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107968 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107970 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107978 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107980 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107988 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107990 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107998 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171079a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171079a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171079b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171079b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171079c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171079c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171079d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171079d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171079e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171079e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171079f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171079f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107a00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107a08 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107a10 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107a18 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107a20 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107a28 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107a30 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107a38 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107a40 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107a48 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107a50 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107a58 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107a60 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107a68 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107a70 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107a78 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107a80 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107a88 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107a90 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107a98 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107aa0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107aa8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107ab0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107ab8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107ac0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107ac8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107ad0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107ad8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107ae0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107ae8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107af0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107af8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107b00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107b08 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107b10 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107b18 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107b20 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107b28 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107b30 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107b38 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107b40 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107b48 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107b50 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107b58 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107b60 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107b68 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107b70 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107b78 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107b80 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107b88 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107b90 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107b98 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107ba0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107ba8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107bb0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107bb8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107bc0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107bc8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107bd0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107bd8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107be0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107be8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107bf0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107bf8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107c00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107c08 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107c10 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107c18 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107c20 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107c28 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107c30 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107c38 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107c40 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107c48 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107c50 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107c58 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107c60 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107c68 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107c70 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107c78 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107c80 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107c88 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107c90 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107c98 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107ca0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107ca8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107cb0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107cb8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107cc0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107cc8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107cd0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107cd8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107ce0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107ce8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107cf0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107cf8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107d00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107d08 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107d10 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107d18 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107d20 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107d28 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107d30 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107d38 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107d40 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107d48 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107d50 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107d58 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107d60 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107d68 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107d70 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107d78 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107d80 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107d88 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107d90 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107d98 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107da0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107da8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107db0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107db8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107dc0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107dc8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107dd0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107dd8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107de0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107de8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107df0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107df8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1710e008 0xe8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1710e104 0x74 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1710e184 0x74 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1710e204 0x74 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1710ea00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1710ea08 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1710ea10 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1710ea18 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1710ea20 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1710ea28 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1710ea30 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1710ea38 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1710ea40 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1710ea48 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1710ea50 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1710ea58 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1710ea60 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1710ea68 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1710ea70 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1710f000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1710ffd0 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17110008 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17110fcc 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1711ffd0 0x34 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120008 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120018 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120020 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120028 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120040 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120048 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120050 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120058 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120060 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120068 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120080 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120088 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120090 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120098 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171200a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171200a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171200c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171200c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171200d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171200d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171200e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171200e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120108 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120110 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120118 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120120 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120128 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120140 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120148 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120150 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120158 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120160 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120168 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120180 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120188 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120190 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120198 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171201a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171201a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171201c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171201c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171201d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171201d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171201e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171201e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120200 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120208 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120210 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120218 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120220 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120228 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120240 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120248 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120250 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120258 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120260 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120268 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120280 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120288 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120290 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120298 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171202a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171202a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171202c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171202c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171202d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171202d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171202e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171202e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120300 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120308 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120310 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120318 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120320 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120328 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120340 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120348 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120350 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120358 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120360 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120368 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120380 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120388 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120390 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120398 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171203a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171203a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171203c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171203c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171203d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171203d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171203e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171203e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120400 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120408 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120410 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120418 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120420 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120428 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120440 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120448 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120450 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120458 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120460 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120468 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120480 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120488 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120490 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120498 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171204a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171204a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171204c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171204c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171204d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171204d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171204e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171204e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120500 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120508 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120510 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120518 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120520 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120528 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120540 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120548 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120550 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120558 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120560 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120568 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120580 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120588 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120590 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120598 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171205a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171205a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171205c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171205c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171205d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171205d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171205e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171205e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120600 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120608 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120610 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120618 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120620 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120628 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120640 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120648 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120650 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120658 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120660 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120668 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120680 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120688 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120690 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120698 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171206a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171206a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171206c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171206c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171206d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171206d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171206e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171206e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1712e000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1712e800 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1712e808 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1712ffbc 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1712ffc8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1712ffd0 0x44 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17130400 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17130600 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17130a00 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17130c00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17130c20 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17130c40 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17130c60 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17130c80 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17130cc0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17130e00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17130e50 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17130fb8 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17130fcc 0x34 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17140000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17140010 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17140020 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17140028 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17140030 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17140080 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17140088 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17140090 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17140100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17140108 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17140110 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1714c000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1714c008 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1714c010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1714f000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1714ffd0 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17180000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17180014 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17180070 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17180078 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171800c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1718ffd0 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17190080 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17190100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17190180 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17190200 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17190280 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17190300 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17190380 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17190400 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17190c00 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17190d00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17190e00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1719c000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1719c008 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1719c010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1719c018 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1719c100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1719c180 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1719f000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1719f010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171a0070 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171a0078 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171a0088 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171a0120 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171ac000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171ac100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171ae100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171c0000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171c0014 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171c0070 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171c0078 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171c00c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171cffd0 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171d0080 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171d0100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171d0180 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171d0200 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171d0280 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171d0300 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171d0380 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171d0400 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171d0c00 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171d0d00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171d0e00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171dc000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171dc008 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171dc010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171dc018 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171dc100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171dc180 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171df000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171df010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171e0070 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171e0078 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171e0088 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171e0120 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171ec000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171ec100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171ee100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17200000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17200014 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17200070 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17200078 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172000c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1720ffd0 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17210080 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17210100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17210180 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17210200 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17210280 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17210300 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17210380 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17210400 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17210c00 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17210d00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17210e00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1721c000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1721c008 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1721c010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1721c018 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1721c100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1721c180 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1721f000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1721f010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17220070 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17220078 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17220088 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17220120 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1722c000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1722c100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1722e100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17240000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17240014 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17240070 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17240078 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172400c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1724ffd0 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17250080 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17250100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17250180 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17250200 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17250280 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17250300 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17250380 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17250400 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17250c00 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17250d00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17250e00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1725c000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1725c008 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1725c010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1725c018 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1725c100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1725c180 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1725f000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1725f010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17260070 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17260078 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17260088 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17260120 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1726c000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1726c100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1726e100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17280000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17280014 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17280070 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17280078 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172800c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1728ffd0 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17290080 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17290100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17290180 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17290200 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17290280 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17290300 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17290380 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17290400 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17290c00 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17290d00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17290e00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1729c000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1729c008 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1729c010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1729c018 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1729c100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1729c180 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1729f000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1729f010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172a0070 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172a0078 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172a0088 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172a0120 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172ac000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172ac100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172ae100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172c0000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172c0014 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172c0070 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172c0078 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172c00c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172cffd0 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172d0080 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172d0100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172d0180 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172d0200 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172d0280 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172d0300 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172d0380 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172d0400 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172d0c00 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172d0d00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172d0e00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172dc000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172dc008 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172dc010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172dc018 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172dc100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172dc180 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172df000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172df010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172e0070 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172e0078 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172e0088 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172e0120 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172ec000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172ec100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172ee100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17300000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17300014 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17300070 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17300078 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173000c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1730ffd0 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17310080 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17310100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17310180 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17310200 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17310280 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17310300 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17310380 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17310400 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17310c00 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17310d00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17310e00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1731c000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1731c008 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1731c010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1731c018 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1731c100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1731c180 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1731f000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1731f010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17320070 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17320078 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17320088 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17320120 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1732c000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1732c100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1732e100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17340000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17340014 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17340070 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17340078 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173400c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1734ffd0 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17350080 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17350100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17350180 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17350200 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17350280 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17350300 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17350380 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17350400 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17350c00 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17350d00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17350e00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1735c000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1735c008 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1735c010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1735c018 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1735c100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1735c180 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1735f000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1735f010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17360070 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17360078 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17360088 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17360120 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1736c000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1736c100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1736e100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17380000 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17380020 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17380030 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17380084 0x74 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17380104 0x74 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17380184 0x74 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17380204 0x74 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17380284 0x74 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17380304 0x74 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17380384 0x74 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17380420 0x3a0 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17380c08 0xe8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17380d04 0x74 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17380e08 0xe8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386108 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386110 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386118 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386120 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386128 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386130 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386138 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386140 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386148 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386150 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386158 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386160 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386168 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386170 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386178 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386180 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386188 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386190 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386198 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173861a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173861a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173861b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173861b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173861c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173861c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173861d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173861d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173861e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173861e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173861f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173861f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386200 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386208 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386210 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386218 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386220 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386228 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386230 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386238 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386240 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386248 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386250 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386258 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386260 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386268 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386270 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386278 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386280 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386288 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386290 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386298 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173862a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173862a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173862b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173862b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173862c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173862c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173862d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173862d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173862e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173862e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173862f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173862f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386300 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386308 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386310 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386318 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386320 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386328 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386330 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386338 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386340 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386348 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386350 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386358 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386360 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386368 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386370 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386378 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386380 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386388 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386390 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386398 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173863a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173863a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173863b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173863b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173863c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173863c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173863d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173863d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173863e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173863e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173863f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173863f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386400 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386408 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386410 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386418 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386420 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386428 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386430 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386438 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386440 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386448 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386450 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386458 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386460 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386468 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386470 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386478 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386480 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386488 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386490 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386498 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173864a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173864a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173864b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173864b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173864c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173864c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173864d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173864d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173864e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173864e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173864f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173864f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386500 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386508 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386510 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386518 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386520 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386528 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386530 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386538 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386540 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386548 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386550 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386558 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386560 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386568 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386570 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386578 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386580 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386588 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386590 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386598 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173865a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173865a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173865b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173865b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173865c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173865c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173865d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173865d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173865e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173865e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173865f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173865f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386600 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386608 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386610 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386618 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386620 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386628 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386630 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386638 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386640 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386648 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386650 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386658 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386660 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386668 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386670 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386678 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386680 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386688 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386690 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386698 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173866a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173866a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173866b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173866b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173866c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173866c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173866d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173866d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173866e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173866e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173866f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173866f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386700 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386708 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386710 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386718 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386720 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386728 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386730 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386738 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386740 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386748 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386750 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386758 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386760 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386768 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386770 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386778 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386780 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386788 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386790 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386798 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173867a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173867a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173867b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173867b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173867c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173867c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173867d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173867d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173867e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173867e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173867f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173867f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386800 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386808 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386810 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386818 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386820 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386828 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386830 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386838 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386840 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386848 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386850 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386858 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386860 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386868 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386870 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386878 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386880 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386888 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386890 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386898 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173868a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173868a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173868b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173868b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173868c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173868c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173868d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173868d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173868e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173868e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173868f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173868f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386900 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386908 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386910 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386918 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386920 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386928 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386930 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386938 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386940 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386948 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386950 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386958 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386960 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386968 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386970 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386978 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386980 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386988 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386990 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386998 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173869a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173869a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173869b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173869b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173869c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173869c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173869d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173869d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173869e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173869e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173869f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173869f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386a00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386a08 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386a10 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386a18 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386a20 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386a28 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386a30 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386a38 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386a40 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386a48 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386a50 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386a58 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386a60 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386a68 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386a70 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386a78 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386a80 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386a88 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386a90 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386a98 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386aa0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386aa8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386ab0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386ab8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386ac0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386ac8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386ad0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386ad8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386ae0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386ae8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386af0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386af8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386b00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386b08 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386b10 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386b18 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386b20 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386b28 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386b30 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386b38 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386b40 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386b48 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386b50 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386b58 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386b60 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386b68 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386b70 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386b78 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386b80 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386b88 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386b90 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386b98 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386ba0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386ba8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386bb0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386bb8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386bc0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386bc8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386bd0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386bd8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386be0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386be8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386bf0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386bf8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386c00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386c08 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386c10 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386c18 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386c20 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386c28 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386c30 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386c38 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386c40 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386c48 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386c50 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386c58 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386c60 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386c68 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386c70 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386c78 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386c80 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386c88 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386c90 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386c98 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386ca0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386ca8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386cb0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386cb8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386cc0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386cc8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386cd0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386cd8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386ce0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386ce8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386cf0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386cf8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386d00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386d08 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386d10 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386d18 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386d20 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386d28 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386d30 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386d38 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386d40 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386d48 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386d50 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386d58 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386d60 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386d68 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386d70 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386d78 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386d80 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386d88 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386d90 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386d98 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386da0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386da8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386db0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386db8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386dc0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386dc8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386dd0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386dd8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386de0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386de8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386df0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386df8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386e00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386e08 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386e10 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386e18 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386e20 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386e28 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386e30 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386e38 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386e40 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386e48 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386e50 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386e58 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386e60 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386e68 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386e70 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386e78 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386e80 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386e88 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386e90 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386e98 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386ea0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386ea8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386eb0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386eb8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386ec0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386ec8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386ed0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386ed8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386ee0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386ee8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386ef0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386ef8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386f00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386f08 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386f10 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386f18 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386f20 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386f28 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386f30 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386f38 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386f40 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386f48 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386f50 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386f58 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386f60 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386f68 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386f70 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386f78 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386f80 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386f88 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386f90 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386f98 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386fa0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386fa8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386fb0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386fb8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386fc0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386fc8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386fd0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386fd8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386fe0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386fe8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386ff0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386ff8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387008 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387018 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387020 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387028 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387030 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387038 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387040 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387048 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387050 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387058 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387060 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387068 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387070 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387078 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387080 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387088 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387090 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387098 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173870a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173870a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173870b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173870b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173870c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173870c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173870d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173870d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173870e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173870e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173870f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173870f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387108 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387110 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387118 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387120 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387128 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387130 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387138 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387140 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387148 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387150 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387158 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387160 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387168 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387170 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387178 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387180 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387188 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387190 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387198 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173871a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173871a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173871b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173871b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173871c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173871c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173871d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173871d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173871e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173871e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173871f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173871f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387200 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387208 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387210 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387218 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387220 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387228 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387230 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387238 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387240 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387248 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387250 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387258 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387260 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387268 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387270 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387278 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387280 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387288 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387290 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387298 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173872a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173872a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173872b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173872b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173872c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173872c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173872d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173872d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173872e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173872e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173872f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173872f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387300 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387308 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387310 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387318 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387320 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387328 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387330 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387338 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387340 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387348 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387350 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387358 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387360 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387368 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387370 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387378 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387380 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387388 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387390 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387398 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173873a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173873a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173873b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173873b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173873c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173873c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173873d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173873d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173873e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173873e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173873f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173873f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387400 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387408 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387410 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387418 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387420 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387428 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387430 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387438 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387440 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387448 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387450 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387458 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387460 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387468 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387470 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387478 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387480 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387488 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387490 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387498 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173874a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173874a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173874b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173874b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173874c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173874c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173874d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173874d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173874e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173874e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173874f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173874f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387500 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387508 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387510 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387518 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387520 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387528 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387530 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387538 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387540 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387548 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387550 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387558 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387560 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387568 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387570 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387578 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387580 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387588 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387590 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387598 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173875a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173875a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173875b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173875b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173875c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173875c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173875d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173875d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173875e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173875e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173875f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173875f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387600 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387608 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387610 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387618 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387620 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387628 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387630 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387638 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387640 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387648 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387650 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387658 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387660 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387668 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387670 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387678 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387680 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387688 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387690 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387698 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173876a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173876a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173876b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173876b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173876c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173876c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173876d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173876d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173876e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173876e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173876f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173876f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387700 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387708 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387710 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387718 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387720 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387728 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387730 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387738 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387740 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387748 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387750 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387758 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387760 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387768 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387770 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387778 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387780 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387788 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387790 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387798 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173877a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173877a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173877b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173877b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173877c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173877c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173877d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173877d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173877e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173877e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173877f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173877f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387800 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387808 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387810 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387818 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387820 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387828 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387830 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387838 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387840 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387848 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387850 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387858 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387860 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387868 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387870 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387878 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387880 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387888 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387890 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387898 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173878a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173878a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173878b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173878b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173878c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173878c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173878d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173878d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173878e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173878e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173878f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173878f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387900 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387908 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387910 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387918 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387920 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387928 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387930 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387938 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387940 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387948 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387950 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387958 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387960 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387968 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387970 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387978 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387980 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387988 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387990 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387998 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173879a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173879a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173879b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173879b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173879c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173879c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173879d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173879d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173879e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173879e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173879f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173879f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387a00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387a08 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387a10 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387a18 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387a20 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387a28 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387a30 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387a38 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387a40 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387a48 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387a50 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387a58 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387a60 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387a68 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387a70 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387a78 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387a80 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387a88 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387a90 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387a98 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387aa0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387aa8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387ab0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387ab8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387ac0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387ac8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387ad0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387ad8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387ae0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387ae8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387af0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387af8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387b00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387b08 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387b10 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387b18 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387b20 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387b28 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387b30 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387b38 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387b40 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387b48 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387b50 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387b58 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387b60 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387b68 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387b70 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387b78 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387b80 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387b88 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387b90 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387b98 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387ba0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387ba8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387bb0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387bb8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387bc0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387bc8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387bd0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387bd8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387be0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387be8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387bf0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387bf8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387c00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387c08 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387c10 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387c18 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387c20 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387c28 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387c30 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387c38 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387c40 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387c48 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387c50 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387c58 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387c60 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387c68 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387c70 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387c78 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387c80 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387c88 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387c90 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387c98 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387ca0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387ca8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387cb0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387cb8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387cc0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387cc8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387cd0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387cd8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387ce0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387ce8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387cf0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387cf8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387d00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387d08 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387d10 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387d18 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387d20 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387d28 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387d30 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387d38 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387d40 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387d48 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387d50 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387d58 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387d60 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387d68 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387d70 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387d78 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387d80 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387d88 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387d90 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387d98 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387da0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387da8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387db0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387db8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387dc0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387dc8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387dd0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387dd8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387de0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387de8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387df0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387df8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1738e008 0xe8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1738e104 0x74 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1738e184 0x74 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1738e204 0x74 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1738ea00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1738ea08 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1738ea10 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1738ea18 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1738ea20 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1738ea28 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1738ea30 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1738ea38 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1738ea40 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1738ea48 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1738ea50 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1738ea58 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1738ea60 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1738ea68 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1738ea70 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1738f000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1738ffd0 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17400004 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17400038 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17400044 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x174000f0 0x84 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17400200 0x84 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17400438 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17400444 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17410000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1741000c 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17410020 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17411000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1741100c 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17411020 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17420000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17420040 0x1c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17420080 0x38 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17420fc0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17420fd0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17420fe0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17420ff0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17421000 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17421fd0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17422000 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17422020 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17422fd0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17423000 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17423fd0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17425000 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17425fd0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17426000 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17426020 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17426fd0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17427000 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17427fd0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17429000 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17429fd0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1742b000 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1742bfd0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1742d000 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1742dfd0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17600004 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17600010 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17600024 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17600034 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17600040 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17600050 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17600080 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17600094 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176000d8 0x54 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17600134 0x28 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17600160 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17600170 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17600180 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17600210 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17600234 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17600240 0x2c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176002b4 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17600404 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1760041c 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17600434 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1760043c 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17600460 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17600470 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17600480 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17600490 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176004a0 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176004b0 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176004c0 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176004d0 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176004e0 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176004f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17600500 0x34 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17600600 0x28 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176009fc 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17601000 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17602000 0x104 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17603000 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17604000 0x104 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17605000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17606000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17607000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17608004 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17608020 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1760f000 0x5c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17610000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17610010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17610020 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17611000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17611010 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17612000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17612010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17612018 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17612040 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17612200 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17612210 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17612400 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17612490 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17614000 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17614100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17614208 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17614304 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17614500 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615000 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615030 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615040 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615070 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615080 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176150b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176150c0 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176150f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615100 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615130 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615140 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615170 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615180 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176151b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176151c0 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176151f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615200 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615230 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615240 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615270 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615280 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176152b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176152c0 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176152f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615300 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615330 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615340 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615370 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615380 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176153b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176153c0 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176153f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615400 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615430 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615440 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615470 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615480 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176154b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176154c0 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176154f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615500 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615530 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615540 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615570 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615580 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176155b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176155c0 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176155f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615600 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615630 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615640 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615670 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615680 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176156b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176156c0 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176156f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615700 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615730 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615740 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615770 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615780 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176157b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176157c0 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176157f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615800 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615830 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615840 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615870 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615880 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176158b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176158c0 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176158f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615900 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615930 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615940 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615970 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615980 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176159b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176159c0 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176159f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615a00 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615a30 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615a40 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615a70 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615a80 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615ab0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615ac0 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615af0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615b00 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615b30 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615b40 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615b70 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615b80 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615bb0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615bc0 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615bf0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17618000 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17618100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17618208 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17618304 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17618500 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1761900c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619014 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619030 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619040 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1761904c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619054 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619070 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619080 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1761908c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619094 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176190b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176190c0 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176190cc 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176190d4 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176190f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1761910c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619114 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619130 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619140 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1761914c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619154 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619170 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619180 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1761918c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619194 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176191b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176191c0 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176191cc 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176191d4 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176191f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619200 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1761920c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619214 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619230 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619240 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1761924c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619254 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619270 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619280 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1761928c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619294 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176192b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176192c0 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176192cc 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176192d4 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176192f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619300 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1761930c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619314 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619330 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619340 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1761934c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619354 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619370 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619380 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1761938c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619394 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176193b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176193c0 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176193cc 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176193d4 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176193f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619400 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1761940c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619414 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619430 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619440 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1761944c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619454 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619470 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619480 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1761948c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619494 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176194b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176194c0 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176194cc 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176194d4 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176194f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619500 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1761950c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619514 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619530 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619540 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1761954c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619554 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619570 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619580 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1761958c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619594 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176195b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176195c0 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176195cc 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176195d4 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176195f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619600 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1761960c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619614 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619630 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619640 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1761964c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619654 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619670 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619680 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1761968c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619694 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176196b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176196c0 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176196cc 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176196d4 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176196f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619700 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1761970c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619714 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619730 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619740 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1761974c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619754 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619770 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619780 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1761978c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619794 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176197b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176197c0 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176197cc 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176197d4 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176197f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17800000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17800008 0x48 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17800054 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178000f0 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17800100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17810000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17810008 0x48 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17810054 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178100f0 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17810100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17820000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17820008 0x48 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17820054 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178200f0 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17820100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17830000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17830008 0x48 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17830054 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178300f0 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17830100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17838000 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17840000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17840008 0x48 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17840054 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178400f0 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17840100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17848000 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17850000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17850008 0x48 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17850054 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178500f0 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17850100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17858000 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17860000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17860008 0x48 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17860054 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178600f0 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17860100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17868000 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17870000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17870008 0x48 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17870054 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178700f0 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17870100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17878000 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17880000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17880008 0x48 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17880068 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178800f0 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17888000 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17890000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17890008 0x48 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17890068 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178900f0 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17898000 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178a0000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178a0008 0x48 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178a0054 0x34 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178a0090 0x1dc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c0000 0x248 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c8000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c8008 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c8010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c8018 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c8020 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c8028 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c8030 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c8038 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c8040 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c8048 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c8050 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c8058 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c8060 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c8068 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c8070 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c8078 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c8080 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c8088 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c8090 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c8098 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c80a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c80a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c80b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c80b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c80c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c80c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c80d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c80d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c80e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c80e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c80f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c80f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c8100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c8108 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c8110 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c8118 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178cc000 0x24 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178cc030 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178cc040 0x48 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178cc090 0x88 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17900000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1790000c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17900040 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17900900 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17900c00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17900c0c 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17900c40 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17900fd0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17901000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1790100c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17901040 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17901900 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17901c00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17901c0c 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17901c40 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17901fd0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a00000 0xd4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a000d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a00100 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a00110 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a0011c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a00200 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a00224 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a00244 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a00264 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a00284 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a002a4 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a002c4 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a002e4 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a00400 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a00450 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a00490 0x3c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a00550 0x200 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a00d00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a00d10 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a00d18 0x19c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a00fc0 0x24 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a00fe8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a01000 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a01018 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a01030 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a01048 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a01060 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a01078 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a01090 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a010a8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a010c0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a010d8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a010f0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a01108 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a01120 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a01138 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a01150 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a01260 0x24 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a01288 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a012a0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a012b8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a012d0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a012e8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a01300 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a01318 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a01330 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a01348 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a01360 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a01378 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a01390 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a013a8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a013c0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a013d8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a013f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a01500 0x24 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a01528 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a01540 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a01558 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a01570 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a01588 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a015a0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a015b8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a015d0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a015e8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a01600 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a01618 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a01630 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a01648 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a01660 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a01678 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a01690 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a10000 0x4c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a10050 0x84 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a100d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a10100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a10108 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a10204 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a10224 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a10244 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a10264 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a10284 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a102a4 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a102c4 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a102e4 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a10400 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a10450 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a104a0 0x2c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a10550 0x200 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a10d00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a10d10 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a10d18 0x19c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a10fc0 0x24 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a10fe8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a11000 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a11018 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a11030 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a11048 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a11060 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a11078 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a11090 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a110a8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a110c0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a110d8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a110f0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a11108 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a11120 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a11138 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a11150 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a11260 0x24 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a11288 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a112a0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a112b8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a112d0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a112e8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a11300 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a11318 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a11330 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a11348 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a11360 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a11378 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a11390 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a113a8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a113c0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a113d8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a113f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a11500 0x24 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a11528 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a11540 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a11558 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a11570 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a11588 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a115a0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a115b8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a115d0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a115e8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a11600 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a11618 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a11630 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a11648 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a11660 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a11678 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a11690 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a20000 0x4c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a20050 0x84 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a200d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a20100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a20108 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a20204 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a20224 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a20244 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a20264 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a20284 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a202a4 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a202c4 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a202e4 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a20400 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a20450 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a204a0 0x2c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a20550 0x200 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a20d00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a20d10 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a20d18 0x19c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a20fc0 0x24 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a20fe8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21000 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21018 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21030 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21048 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21060 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21078 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21090 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a210a8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a210c0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a210d8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a210f0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21108 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21120 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21138 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21150 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21260 0x24 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21288 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a212a0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a212b8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a212d0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a212e8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21300 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21318 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21330 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21348 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21360 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21378 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21390 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a213a8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a213c0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a213d8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a213f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21500 0x24 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21528 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21540 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21558 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21570 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21588 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a215a0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a215b8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a215d0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a215e8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21600 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21618 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21630 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21648 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21660 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21678 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21690 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a217a0 0x24 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a217c8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a217e0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a217f8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21810 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21828 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21840 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21858 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21870 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21888 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a218a0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a218b8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a218d0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a218e8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21900 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21918 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21930 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21a40 0x24 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21a68 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21a80 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21a98 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21ab0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21ac8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21ae0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21af8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21b10 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21b28 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21b40 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21b58 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21b70 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21b88 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21ba0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21bb8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21bd0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21ce0 0x24 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21d08 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21d20 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21d38 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21d50 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21d68 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21d80 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21d98 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21db0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21dc8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21de0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21df8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21e10 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21e28 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21e40 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21e58 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21e70 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21f80 0x24 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21fa8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21fc0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21fd8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21ff0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a22008 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a22020 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a22038 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a22050 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a22068 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a22080 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a22098 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a220b0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a220c8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a220e0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a220f8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a22110 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a30000 0x4c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a30050 0x84 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a300d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a30100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a30108 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a30204 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a30224 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a30244 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a30264 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a30284 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a302a4 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a302c4 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a302e4 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a30400 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a30450 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a304a0 0x2c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a30550 0x200 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a30d00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a30d10 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a30d18 0x19c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a30fc0 0x24 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a30fe8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a31000 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a31018 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a31030 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a31048 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a31060 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a31078 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a31090 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a310a8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a310c0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a310d8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a310f0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a31108 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a31120 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a31138 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a31150 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a31260 0x24 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a31288 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a312a0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a312b8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a312d0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a312e8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a31300 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a31318 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a31330 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a31348 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a31360 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a31378 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a31390 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a313a8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a313c0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a313d8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a313f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a80000 0x44 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a82000 0x44 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a84000 0x44 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a86000 0x44 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a8c000 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a8e000 0x400 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a90000 0x5c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a90080 0x58 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a92000 0x5c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a92080 0x58 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a94000 0x5c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a94080 0x58 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a96000 0x5c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a96080 0x58 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17aa0000 0xb0 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17aa00fc 0x50 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17aa0200 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17aa0300 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17aa0400 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17aa0500 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17aa0600 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17aa0700 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b00000 0x120 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70010 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70090 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b700a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b700c0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70110 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70190 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b701a0 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70220 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b702a0 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70320 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70380 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70390 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70410 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70420 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b704a0 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70520 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70580 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70600 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70610 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70680 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70700 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70710 0x60 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70790 0x60 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70810 0x60 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70890 0x60 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70910 0x60 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70990 0x60 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70a10 0x60 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70a90 0x60 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70b10 0x60 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70b90 0x60 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70c00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70c10 0x60 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70c90 0x60 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70d10 0x60 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70d90 0x60 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70e10 0x60 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70e90 0x60 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70f10 0x60 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70f90 0x60 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b71010 0x60 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b71080 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b71090 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b71110 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b71190 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b71210 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b71290 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b71310 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b71380 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b71390 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b71410 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b71490 0x200 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b71c90 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b71d10 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b71d90 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b71e10 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b71e90 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b71f10 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b71f90 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b72010 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b72080 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b72090 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b72110 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b72120 0x1c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b72140 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b721c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b721d0 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b72260 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b72270 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b72300 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b72320 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b72340 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b72360 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b72370 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b72390 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b723b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b723d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b723f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b72410 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78010 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78090 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b780a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b780c0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78110 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78190 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b781a0 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78220 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b782a0 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78320 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78380 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78390 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78410 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78420 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b784a0 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78520 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78580 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78600 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78610 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78680 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78700 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78710 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78790 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78810 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78890 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78910 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78990 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78a10 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78a90 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78b10 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78b90 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78c00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78c10 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78c90 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78d10 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78d90 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78e10 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78e90 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78f10 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78f90 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b79010 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b79080 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b79090 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b79110 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b79190 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b79210 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b79290 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b79310 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b79380 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b79390 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b79410 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b79490 0x100 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b79c90 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b79d10 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b79d90 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b79e10 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b79e90 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b79f10 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b79f90 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b7a010 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b7a080 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b7a090 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b7a110 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b7a120 0x1c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b7a140 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b7a1c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b7a1d0 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b7a260 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b7a270 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b7a300 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b7a320 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b7a340 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b7a360 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b7a370 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b7a390 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b7a3b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b7a3d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b7a3f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b7a410 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b90000 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b90020 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b90050 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b90070 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b90080 0x64 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b90100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b90120 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b90140 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b90200 0x3c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b90700 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b9070c 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b90780 0x80 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b90808 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b90824 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b90840 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b90c48 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b90c64 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b90c80 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b93000 0x140 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b93500 0x140 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b93a00 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b93a24 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b93a2c 0xc4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b93b00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b93b20 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b93b30 0x2c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b93b64 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b93b70 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b93b90 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b93c00 0x8c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17ba0000 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17ba0020 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17ba0050 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17ba0070 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17ba0080 0x64 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17ba0100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17ba0120 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17ba0140 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17ba0200 0x24 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17ba0700 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17ba070c 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17ba0780 0x80 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17ba0808 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17ba0824 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17ba0840 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17ba0c48 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17ba0c64 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17ba0c80 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17ba3000 0x140 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17ba3500 0x140 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17ba3a00 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17ba3a24 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17ba3a2c 0xc4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17ba3b00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17ba3b20 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17ba3b30 0x2c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17ba3b64 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17ba3b70 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17ba3b90 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17ba3c00 0x8c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17c000e8 0x154 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17c01000 0x25c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17c20000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17c21000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d10000 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d10200 0x49c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d10700 0x11c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d10900 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d30000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d34000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d3bff8 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d40000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d40008 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d40010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d40018 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d40020 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d40028 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d50000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d50040 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d50050 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d50100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d50138 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d50178 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d50e00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d90000 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d90014 0x68 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d90080 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d900b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d900b8 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d900d0 0x24 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d90100 0xa0 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d90200 0xa0 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d90300 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d90320 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d9034c 0x7c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d903e0 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d90404 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d90420 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d90430 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d90450 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d90470 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d91000 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d91014 0x68 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d91080 0x1c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d910b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d910b8 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d910d0 0x24 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d91100 0xa0 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d91200 0xa0 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d91300 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d91320 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d9134c 0x88 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d913e0 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d91404 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d91420 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d91430 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d91450 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d91470 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d92000 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d92014 0x68 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d92080 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d920b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d920b8 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d920d0 0x24 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d92100 0xa0 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d92200 0xa0 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d92300 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d92320 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d9234c 0x8c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d923e0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d92404 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d92430 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d92450 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d92470 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d93000 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d93014 0x68 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d93080 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d930b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d930b8 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d930d0 0x24 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d93100 0xa0 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d93200 0xa0 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d93300 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d93320 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d9334c 0x80 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d933e0 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d93404 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d93430 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d93450 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d93470 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d98000 0x60 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e00000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e00008 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e00010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e00018 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e00020 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e00028 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e00030 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e00038 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e00040 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e00048 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e00050 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e00060 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e00068 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e10000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e10008 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e10018 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e10020 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e10030 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e100f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e100f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e10100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e11000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e20000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e20008 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e20010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e20018 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e20020 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e20028 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e20030 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e20038 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e20800 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e20808 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e20810 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e20e00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e20e10 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e20fa8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e20fbc 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e20fc8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e20fd0 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e30000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e30010 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e30030 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e30050 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e30170 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e30fb0 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e30fc8 0x38 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e80000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e80010 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e80030 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e80050 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e80170 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e80fb0 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e80fc8 0x38 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e90000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e90008 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e90010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e90018 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e90100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e90108 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e90110 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e90400 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e90480 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e90c00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e90c20 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e90ce0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e90e00 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e90fa8 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e90fbc 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e90fcc 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e90fe0 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17eb0000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17eb0010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17f80000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17f80010 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17f80030 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17f80050 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17f80170 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17f80fb0 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17f80fc8 0x38 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17f90000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17f90008 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17f90010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17f90018 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17f90100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17f90108 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17f90110 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17f90400 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17f90480 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17f90c00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17f90c20 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17f90ce0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17f90e00 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17f90fa8 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17f90fbc 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17f90fcc 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17f90fe0 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17fb0000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17fb0010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18080000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18080010 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18080030 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18080050 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18080170 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18080fb0 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18080fc8 0x38 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18090000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18090008 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18090010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18090018 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18090100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18090108 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18090110 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18090400 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18090480 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18090c00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18090c20 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18090ce0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18090e00 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18090fa8 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18090fbc 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18090fcc 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18090fe0 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x180b0000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x180b0010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18180000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18180010 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18180030 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18180050 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18180170 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18180fb0 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18180fc8 0x38 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18190000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18190008 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18190010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18190018 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18190100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18190108 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18190110 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18190400 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18190480 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18190c00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18190c20 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18190ce0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18190e00 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18190fa8 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18190fbc 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18190fcc 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18190fe0 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x181b0000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x181b0010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18280000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18280010 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18280030 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18280050 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18280170 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18280fb0 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18280fc8 0x38 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18290000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18290008 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18290010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18290018 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18290100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18290108 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18290110 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18290400 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18290480 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18290c00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18290c20 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18290ce0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18290e00 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18290fa8 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18290fbc 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18290fcc 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18290fe0 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x182b0000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x182b0010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18380000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18380010 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18380030 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18380050 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18380170 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18380fb0 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18380fc8 0x38 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18390000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18390008 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18390010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18390018 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18390100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18390108 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18390110 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18390400 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18390480 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18390c00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18390c20 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18390ce0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18390e00 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18390fa8 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18390fbc 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18390fcc 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18390fe0 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18480000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18480010 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18480030 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18480050 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18480170 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18480fb0 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18480fc8 0x38 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18490000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18490008 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18490010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18490018 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18490100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18490108 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18490110 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18490400 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18490480 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18490c00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18490c20 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18490ce0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18490e00 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18490fa8 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18490fbc 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18490fcc 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18490fe0 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18580000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18580010 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18580030 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18580050 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18580170 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18580fb0 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18580fc8 0x38 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18590000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18590008 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18590010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18590018 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18590100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18590108 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18590110 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18590400 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18590480 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18590c00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18590c20 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18590ce0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18590e00 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18590fa8 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18590fbc 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18590fcc 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18590fe0 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d00000 0x10000 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d20000 0x10000 > /sys/bus/platform/devices/soc:mem_dump/register_config
}

cpuss_spr_setup()
{
    echo 1 > /sys/bus/platform/devices/soc:mem_dump/sprs_register_reset

    echo 1 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 2 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 3 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 4 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 5 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 6 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 7 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 8 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 9 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 11 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 13 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 14 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 15 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 16 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 17 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 18 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 19 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 21 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 22 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 23 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 24 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 25 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 26 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 27 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 28 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 29 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 30 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 31 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 32 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 33 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 34 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 35 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 36 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 37 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 38 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 43 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 44 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 45 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 46 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 47 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 48 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 49 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 51 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 52 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 53 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 54 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 55 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 56 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 57 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 58 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 59 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 60 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 61 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 62 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 67 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 68 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 69 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 70 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 72 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 73 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 74 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 75 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 76 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 77 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 1 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 2 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 3 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 4 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 5 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 6 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 7 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 8 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 9 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 11 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 13 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 14 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 15 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 16 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 17 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 18 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 19 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 21 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 22 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 23 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 24 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 25 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 26 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 27 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 28 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 29 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 30 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 31 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 32 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 33 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 34 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 35 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 36 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 37 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 38 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 43 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 44 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 45 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 46 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 47 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 48 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 49 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 51 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 52 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 53 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 54 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 55 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 56 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 57 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 58 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 59 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 60 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 61 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 62 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 67 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 68 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 69 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 70 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 72 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 73 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 74 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 75 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 76 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 77 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 1 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 2 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 3 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 4 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 5 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 6 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 7 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 8 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 9 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 11 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 13 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 14 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 15 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 16 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 17 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 18 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 19 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 21 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 22 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 23 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 24 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 25 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 26 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 27 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 28 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 29 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 30 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 31 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 32 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 33 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 34 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 35 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 36 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 37 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 38 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 43 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 44 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 45 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 46 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 47 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 48 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 49 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 51 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 52 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 53 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 54 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 55 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 56 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 57 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 58 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 59 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 60 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 61 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 62 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 67 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 68 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 69 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 70 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 72 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 73 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 74 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 75 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 76 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 77 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 1 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 2 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 3 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 4 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 5 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 6 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 7 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 8 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 9 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 10 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 13 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 14 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 15 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 16 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 17 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 18 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 19 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 21 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 22 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 23 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 24 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 25 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 26 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 27 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 28 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 29 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 30 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 31 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 32 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 33 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 34 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 35 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 36 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 37 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 38 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 43 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 44 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 45 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 46 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 47 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 48 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 49 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 51 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 52 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 53 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 54 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 55 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 56 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 57 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 58 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 59 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 60 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 61 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 62 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 63 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 64 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 65 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 66 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 67 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 68 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 69 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 70 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 72 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 73 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 74 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 75 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 76 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 77 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 1 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 2 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 3 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 4 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 5 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 6 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 7 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 8 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 9 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 10 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 13 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 14 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 15 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 16 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 17 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 18 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 19 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 21 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 22 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 23 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 24 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 25 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 26 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 27 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 28 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 29 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 30 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 31 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 32 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 33 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 34 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 35 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 36 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 37 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 38 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 43 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 44 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 45 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 46 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 47 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 48 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 49 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 51 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 52 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 53 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 54 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 55 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 56 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 57 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 58 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 59 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 60 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 61 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 62 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 63 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 64 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 65 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 66 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 67 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 68 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 69 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 70 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 72 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 73 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 74 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 75 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 76 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 77 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 1 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 2 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 3 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 4 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 5 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 6 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 7 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 8 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 9 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 10 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 13 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 14 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 15 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 16 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 17 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 18 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 19 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 20 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 21 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 22 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 23 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 24 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 25 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 26 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 27 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 28 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 29 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 30 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 31 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 32 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 33 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 34 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 35 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 36 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 37 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 38 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 43 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 44 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 45 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 46 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 47 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 48 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 49 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 51 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 52 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 53 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 54 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 55 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 56 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 57 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 58 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 59 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 60 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 61 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 62 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 63 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 64 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 65 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 66 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 67 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 68 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 69 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 70 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 72 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 73 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 74 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 75 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 76 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 77 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 1 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 2 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 3 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 4 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 5 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 6 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 7 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 8 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 9 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 10 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 13 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 14 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 15 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 16 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 17 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 18 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 19 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 20 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 21 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 22 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 23 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 24 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 25 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 26 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 27 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 28 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 29 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 30 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 31 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 32 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 33 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 34 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 35 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 36 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 37 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 38 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 43 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 44 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 45 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 46 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 47 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 48 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 49 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 51 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 52 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 53 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 54 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 55 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 56 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 57 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 58 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 59 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 60 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 61 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 62 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 63 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 64 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 65 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 66 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 67 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 68 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 69 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 70 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 72 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 73 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 74 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 75 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 76 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 77 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 1 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 2 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 3 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 4 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 5 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 6 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 7 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 8 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 9 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 10 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 13 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 14 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 15 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 16 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 17 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 18 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 19 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 20 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 21 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 22 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 23 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 24 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 25 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 26 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 27 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 28 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 29 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 30 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 31 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 32 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 33 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 34 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 35 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 36 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 37 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 38 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 43 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 44 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 45 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 46 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 47 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 48 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 49 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 51 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 52 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 53 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 54 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 55 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 56 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 57 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 58 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 59 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 60 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 61 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 62 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 63 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 64 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 65 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 66 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 67 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 68 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 69 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 70 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 72 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 73 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 74 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 75 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 76 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 77 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
}

enable_buses_and_interconnect_tracefs_debug()
{
    if [ -d $tracefs ] && [ "$(getprop persist.vendor.tracing.enabled)" -eq "1" ]; then
        mkdir $tracefs/instances/hsuart
        #UART
        echo 800 > $tracefs/instances/hsuart/buffer_size_kb
        echo 1 > $tracefs/instances/hsuart/events/serial/enable
        echo 1 > $tracefs/instances/hsuart/tracing_on

        #SPI
        mkdir $tracefs/instances/spi_qup
        echo 1 > $tracefs/instances/spi_qup/events/qup_spi_trace/enable
        echo 1 > $tracefs/instances/spi_qup/tracing_on

        #I2C
        mkdir $tracefs/instances/i2c_qup
        echo 1 > $tracefs/instances/i2c_qup/events/qup_i2c_trace/enable
        echo 1 > $tracefs/instances/i2c_qup/tracing_on

        #GENI_COMMON
        mkdir $tracefs/instances/qupv3_common
        echo 1 > $tracefs/instances/qupv3_common/events/qup_common_trace/enable
        echo 1 > $tracefs/instances/qupv3_common/tracing_on

        #SLIMBUS
        mkdir $tracefs/instances/slimbus
        echo 1 > $tracefs/instances/slimbus/events/slimbus/slimbus_dbg/enable
        echo 1 > $tracefs/instances/slimbus/tracing_on

        #CLOCK, REGULATOR, INTERCONNECT, RPMH
        mkdir $tracefs/instances/clock_reg
        echo 1 > $tracefs/instances/clock_reg/events/clk/enable
        echo 1 > $tracefs/instances/clock_reg/events/regulator/enable
        echo 1 > $tracefs/instances/clock_reg/events/interconnect/enable
        echo 1 > $tracefs/instances/clock_reg/events/rpmh/enable
        echo 1 > $tracefs/instances/clock_reg/tracing_on
    fi
}

create_stp_policy()
{
    mkdir /config/stp-policy/coresight-stm:p_ost.policy
    chmod 660 /config/stp-policy/coresight-stm:p_ost.policy
    mkdir /config/stp-policy/coresight-stm:p_ost.policy/default
    chmod 660 /config/stp-policy/coresight-stm:p_ost.policy/default
    echo 0x10 > /sys/bus/coresight/devices/coresight-stm/traceid
}

ftrace_disable=`getprop persist.debug.ftrace_events_disable`
coresight_config=`getprop persist.debug.coresight.config`
tracefs=/sys/kernel/tracing
srcenable="enable"
enable_debug()
{
    echo "kalama debug"
    etr_size="0x2000000"
    srcenable="enable_source"
    sinkenable="enable_sink"
    create_stp_policy
    echo "Enabling STM events on kalama."
    adjust_permission
    enable_stm_events
    # enable_lpm_with_dcvs_tracing
    if [ "$ftrace_disable" != "Yes" ]; then
        enable_ftrace_event_tracing
	enable_buses_and_interconnect_tracefs_debug
    fi
    # removing core hang config from postboot as core hang detection is enabled from sysini
    enable_dcc
    enable_cpuss_hw_events
    enable_schedstats
    # setprop ro.dbg.coresight.stm_cfg_done 1
    enable_cpuss_register
    cpuss_spr_setup
    sf_tracing_disablement
}

enable_debug
