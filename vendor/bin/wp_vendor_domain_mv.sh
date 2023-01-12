#!/vendor/bin/sh

LOG_TAG="wp_vendor_domain_mv"
LOG_NAME="woodpecker："

logd ()
{
  /vendor/bin/log -t $LOG_TAG -p d "$LOG_NAME $@"
}

logd "mv receive args : $@ "

/vendor/bin/mv  ${1} ${2}

logd "end move ${1} -> ${2} , status  $? "

setprop vendor.woodpeckerd.mv.path ${1}
logd "setprop status  $? "
