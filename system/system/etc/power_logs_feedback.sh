#!/system/bin/sh

ROOT_DIR="/sdcard/Android/data/.woodpecker/nblog/"
LOG_DIR="/sdcard/Android/data/.woodpecker/nblog/feedback/power/"

/system/bin/mkdir -p $LOG_DIR
/system/bin/touch $LOG_DIR/ps.txt
/system/bin/touch $LOG_DIR/top.txt
/system/bin/touch $LOG_DIR/dump_alarm.txt
/system/bin/touch $LOG_DIR/dump_power.txt
/system/bin/touch $LOG_DIR/main.txt
/system/bin/touch $LOG_DIR/events.txt
/system/bin/touch $LOG_DIR/system.txt
/system/bin/touch $LOG_DIR/radio.txt
/system/bin/touch $LOG_DIR/kernel.txt
/system/bin/touch $LOG_DIR/dump_batterys.txt
/system/bin/touch $LOG_DIR/uevent.txt
/system/bin/chwon -R root:system $ROOT_DIR
/system/bin/chmod -R 766 $ROOT_DIR


/system/bin/ps >> $LOG_DIR/ps.txt
/system/bin/top -m 20 -n 3 -t -s cpu >> $LOG_DIR/top.txt
/system/bin/cat /sys/class/power_supply/battery/uevent >> $LOG_DIR/uevent.txt
/system/bin/dumpsys alarm >> $LOG_DIR/dump_alarm.txt
/system/bin/dumpsys power >> $LOG_DIR/dump_power.txt
/system/bin/beak -d -v threadtime -b main -r 1024 -n 1 -f $LOG_DIR/main.txt
/system/bin/beak -d -v threadtime -b events -r 1024 -n 1 -f $LOG_DIR/events.txt
/system/bin/beak -d -v threadtime -b system -r 1024 -n 1 -f $LOG_DIR/system.txt
/system/bin/beak -d -v threadtime -b radio -r 1024 -n 1 -f $LOG_DIR/radio.txt
/system/bin/beak -d -v threadtime -b kernel -r 1024 -n 1 -f $LOG_DIR/kernel.txt
/system/bin/dumpsys battery >> $LOG_DIR/dump_batterys.txt
/system/bin/dumpsys batteryproperties >> $LOG_DIR/dump_batterys.txt
/system/bin/dumpsys batterystats >> $LOG_DIR/dump_batterys.txt

