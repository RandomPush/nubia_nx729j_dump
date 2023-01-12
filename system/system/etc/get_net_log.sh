#!/system/bin/sh
echo "the param is :" $1
tcpdump -i any -C 100 -p -vv -s 0 -w $1