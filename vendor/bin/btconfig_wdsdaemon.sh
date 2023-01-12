#!/vendor/bin/sh

#Read the arguments passed to the script
LOG_TAG="btnb-wdsdaemon-sh"
LOG_NAME="${0}:"
BIN_PATH=/vendor/bin/wdsdaemon

logd ()
{
  /system/bin/log -t $LOG_TAG -p d "$LOG_NAME $@"
}

logd "start wdsdaemon"

${BIN_PATH} -su >/dev/null 2>&1

logd "stop wdsdaemon"

exit 0
