#!/system/bin/sh

LOG_TAG="power_logs_start"
LOG_NAME="woodpeckerd: "

logd ()
{
  /system/bin/log -t $LOG_TAG -p d "$LOG_NAME $@"
}

ROOT_DIR="${1}"
LOG_DIR="${2}/start"

logd "start power log ${ROOT_DIR}:${LOG_DIR}"

/system/bin/mkdir -p $LOG_DIR
/system/bin/touch $LOG_DIR/ps.txt
/system/bin/touch $LOG_DIR/wakeup_sources.txt
/system/bin/touch $LOG_DIR/rpm_stats.txt
#/system/bin/touch $LOG_DIR/gpio.txt
/system/bin/touch $LOG_DIR/capacity.txt
/system/bin/chown -R root:system $ROOT_DIR
/system/bin/chmod -R 766 $ROOT_DIR


/system/bin/ps -efT -O S >> $LOG_DIR/ps.txt
/system/bin/cat /sys/kernel/debug/wakeup_sources >> $LOG_DIR/wakeup_sources.txt
/system/bin/cat /sys/kernel/debug/rpm_stats >> $LOG_DIR/rpm_stats.txt
/system/bin/cat /sys/kernel/debug/rpm_master_stats >> $LOG_DIR/rpm_stats.txt
/system/bin/cat /sys/power/system_sleep/stats >> $LOG_DIR/rpm_stats.txt
#Begin [0016004715,read the rpmh_stats/master_stats information about the subsystem,20180316]
/system/bin/cat /sys/power/rpmh_stats/master_stats >> $LOG_DIR/rpm_stats.txt
#End   [0016004715,read the rpmh_stats/master_stats information about the subsystem,20180316]
#/system/bin/cat /sys/kernel/debug/gpio >> $LOG_DIR/gpio.txt
/system/bin/cat /sys/class/power_supply/battery/capacity >> $LOG_DIR/capacity.txt
/system/bin/date >> $LOG_DIR/capacity.txt

/system/bin/dumpsys alarm >> $LOG_DIR/alarm.txt
/system/bin/dumpsys power >> $LOG_DIR/power.txt
/system/bin/dumpsys battery >> $LOG_DIR/battery.txt
/system/bin/dumpsys batteryproperties >> $LOG_DIR/batteryproperties.txt
/system/bin/dumpsys batterystats >> $LOG_DIR/batterystats.txt

/system/bin/dumpsys wifi >> $LOG_DIR/wifi.txt
/system/bin/dumpsys sensorservice >> $LOG_DIR/sensorservice.txt
/system/bin/dumpsys netstats >> $LOG_DIR/netstats.txt
/system/bin/dumpsys netpolicy >> $LOG_DIR/netpolicy.txt
/system/bin/dumpsys telephony.registry >> $LOG_DIR/telephony.registry.txt
/system/bin/dumpsys location >> $LOG_DIR/location.txt


#Battery Historian
/system/bin/dumpsys batterystats --enable full-wake-history
/system/bin/dumpsys batterystats --reset
