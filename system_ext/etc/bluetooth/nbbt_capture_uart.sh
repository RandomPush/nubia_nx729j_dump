#!/system/bin/sh

#Read the arguments passed to the script
cmd="$1"
uart_addr=""

LOG_TAG="btnb-uart-sh"
LOG_NAME="${0}:"

prop_pid="bluetooth.nblog.uart.pid"
ipc_path="/sys/kernel/debug/ipc_logging"
#save uart node name
unode_arr={}

#trace flag
trace=`getprop bluetooth.nblog.uart.trace`

logv ()
{
  if [ trace -eq 1 ];then
    /system/bin/log -t $LOG_TAG -p e "$LOG_NAME $@"
  fi
}

logd ()
{
  /system/bin/log -t $LOG_TAG -p d "$LOG_NAME $@"
}

get_conf_uart_addr ()
{
  conf_path="/etc/bluetooth/uart_config.conf"
  #read addr
  for i in `cat ${addr_path}`
  do
    logv "read addr : ${i}"
	#change to lower letters
	typeset -l tmp
	tmp=${i#*0x}
	uart_addr=${tmp}
	logv "get addr by conf: ${uart_addr}"
	return 1;
  done

  return 0;
}
get_ipc_logging_uart_addr ()
{
  uart_tx="uart_tx"
  for i in `ls ${ipc_path} | grep ${uart_tx} | cut -d '.' -f 1`
  do
    uart_addr=${i}
	logv "get addr by ipc: ${uart_addr}"
	return 1
  done
  
  return 0;
}
get_uart_addr ()
{
  get_conf_uart_addr
  if [ $? -eq 0 ];then
    get_ipc_logging_uart_addr
	if [ $? -eq 0 ];then
	  return 0
	fi
  fi

  #get uart node name
  index=0
  for i in `ls ${ipc_path} | grep ${uart_addr}`
  do
    logv "find : ${i}"
	unode_arr[index++]=${i}
  done
}
start_cat_node ()
{
  if [ ! -f $1 ];then
    logv "$1 not exist"
    return
  fi
  
  logv "$1,$2,$3"
  cat $1 > $2 &
  setprop $3 $!
  logv "$3 pid = $!"
}
start_capture ()
{
  #get addr
  get_uart_addr
  if [ -z ${uart_addr} ];then
    return 0
  fi

  logv "uart_addr = ${uart_addr}"
  
  umask 007
  #create root dir if need
  root_dir="/data/misc/bluetooth/logs/uart"
  if [ ! -d ${dir} ];then
    mkdir -p ${root_dir}
  fi

  #create dir for this
  now_time=`date +%Y%m%d%H%M%S`
  this_dir=${root_dir}/${now_time}
  mkdir -p ${this_dir}

  logd "start capture uart log ..."

  #save pid numbers
  setprop ${prop_pid}.count ${#unode_arr[@]}
  index=1
  for i in ${unode_arr[@]}
  do
    start_cat_node ${ipc_path}/${i}/log_cont ${this_dir}/${i}.txt ${prop_pid}.${index}
	((index++))
	logv "index = ${index}"
  done
}

stop_cat_node ()
{
  pid=`getprop $1`
  logv "$1 = ${pid}"
  if [ pid -eq 0 ];then
    logd "invalid pid , do nothing"
  elif [ -d /proc/${pid} ];then
    kill -9 ${pid}
    logv "${pid} exist, kill it"
    setprop $1 0
  else
    logv "${pid} not exist, do nothing"
    setprop $1 0
  fi
}
stop_capture ()
{
  logd "stop capture uart log"
  count=`getprop ${prop_pid}.count`
  #check count and reset
  if [ ${count} -eq 0 ];then
    return
  fi
  setprop ${prop_pid}.count 0
  
  i=1
  while [ ${i} -le ${count} ]
  do
    stop_cat_node ${prop_pid}.${i}
	((i++))
  done
}

init ()
{
  prop=`getprop bluetooth.nblog.capture.uart`
  if [ ${prop} -eq 1 ];then
    cmd="start"
  elif [ ${prop} -eq 0 ];then
    cmd="stop"
  else
    cmd=""
  fi
}

init
logd "cmd is : ${cmd}"
if [ "start" = ${cmd} ];then
  start_capture
  wait
elif [ "stop" = ${cmd} ];then
  stop_capture
else
  logd "invalid cmd, do nothing"
fi

exit 0
