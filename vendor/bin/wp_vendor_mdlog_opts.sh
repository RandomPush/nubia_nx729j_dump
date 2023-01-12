#! /vendor/bin/sh

chown -h root.oem_2902 /sys/devices/platform/soc/10048000.tmc/coresight-tmc-etr/block_size
chmod 660 /sys/devices/platform/soc/10048000.tmc/coresight-tmc-etr/block_size
chown -h root.oem_2902 /sys/devices/platform/soc/1004f000.tmc/coresight-tmc-etr1/block_size
chmod 660 /sys/devices/platform/soc/1004f000.tmc/coresight-tmc-etr1/block_size
chmod 666 /sys/devices/platform/soc/10048000.tmc/coresight-tmc-etr/enable_sink
chmod 666 /sys/devices/platform/soc/10048000.tmc/coresight-tmc-etr/out_mode
chmod 666 /sys/devices/platform/soc/soc:modem_diag/coresight-modem-diag/enable_source
mkdir /config/stp-policy/coresight-stm:p_ost.policy
chmod 660 /config/stp-policy/coresight-stm:p_ost.policy
mkdir /config/stp-policy/coresight-stm:p_ost.policy/default
chmod 660 /config/stp-policy/coresight-stm:p_ost.policy/default
echo 0x10 > /sys/bus/coresight/devices/coresight-stm/traceid
chmod 666 /dev/byte-cntr
chmod 666 /dev/byte-cntr1
