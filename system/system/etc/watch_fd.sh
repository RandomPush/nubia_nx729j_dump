#!/system/bin/sh

function watch_process_fd()
{
	pid=$(ps | grep $1 | cut -d ' ' -f 5)

	if [ "$pid" = "" ]; then
		echo no such process!
		return;
	fi

	fd_num=$(ls -l /proc/$pid/fd | wc -l)
	if [ $fd_num -ge 700 ]; then
		echo $1 $pid $(date)
		echo ====lsof======
		lsof -p $pid
		echo ====/proc/$pid/net/unix====
		cat /proc/$pid/net/unix
		echo ====/proc/$pid/maps====
		cat /proc/$pid/maps
		echo ========dumpsys input=======
		dumpsys input
		echo ========dumpsys window=======
		dumpsys window windows
		return 1
	else
		return 0
	fi
}

function watch_fd_of_surfaceflinger()
{
	watch_process_fd surfaceflinger

	if [ $? -eq 1 ]; then
		echo ====dumpsys SurfaceFlinger======
		dumpsys SurfaceFlinger
	fi
}

function watch_fd_of_system_server()
{
	watch_process_fd system_server
}

function check_parent_process_exit()
{
	now_ppid=$(cat /proc/$$/status | grep PPid | cut -f 2)
	if [ $PPID -ne $now_ppid ]; then
		echo ====exit======
		exit 0
	fi
}
while true
do
	watch_fd_of_system_server
	watch_fd_of_surfaceflinger
	sleep 5
	check_parent_process_exit
done
