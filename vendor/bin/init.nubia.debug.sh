#! /vendor/bin/sh

# Copyright (c) 2009-2016, The Linux Foundation. All rights reserved.
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
#

#if [ ! -d /data/media/0/nubialog ]; then
#    mkdir /data/media/0/nubialog
#    chmod 777 -R /data/media/0/nubialog
#fi

#if [ ! -d /data/media/0/nubialog/xbl ]; then
#    mkdir /data/media/0/nubialog/xbl
#fi

for i in 4 3 2 1
do
if [ -f /data/vendor/nubialog/common/xbl/log.last.$i ]; then
    cp /data/vendor/nubialog/common/xbl/log.last.$i /data/vendor/nubialog/common/xbl/log.last.$(($i+1))
    chmod 777 /data/vendor/nubialog/common/xbl/log.last.$(($i+1))
fi
done

dd if=/dev/block/by-name/xbl_sc_logs of=/data/vendor/nubialog/common/xbl/log.last.1 bs=128k count=1
chmod 777 /data/vendor/nubialog/common/xbl/log.last.1

for j in 4 3 2 1
do
if [ -f /data/vendor/nubialog/common/xbl/pon.last.$j ]; then
    cp /data/vendor/nubialog/common/xbl/pon.last.$j /data/vendor/nubialog/common/xbl/pon.last.$(($j+1))
    chmod 777 /data/vendor/nubialog/common/xbl/pon.last.$(($j+1))
fi
done

echo 0x100 > /sys/kernel/debug/regmap/0-00/count
echo 0x800 > /sys/kernel/debug/regmap/0-00/address
cat /sys/kernel/debug/regmap/0-00/data >> /data/vendor/nubialog/common/xbl/pon.last.1
echo 0x1300 > /sys/kernel/debug/regmap/0-00/address
cat /sys/kernel/debug/regmap/0-00/data >> /data/vendor/nubialog/common/xbl/pon.last.1
echo 0x7400 > /sys/kernel/debug/regmap/0-00/address
cat /sys/kernel/debug/regmap/0-00/data >> /data/vendor/nubialog/common/xbl/pon.last.1
echo 0x7500 > /sys/kernel/debug/regmap/0-00/address
cat /sys/kernel/debug/regmap/0-00/data >> /data/vendor/nubialog/common/xbl/pon.last.1

echo 0xFFFF > /sys/kernel/debug/regmap/0-00/count
cat 0x0 > /sys/kernel/debug/regmap/0-00/address
cat /sys/kernel/debug/regmap/0-00/data >> /data/vendor/nubialog/common/xbl/sdam_regmap

chmod 777 /data/vendor/nubialog/common/xbl/pon.last.1
chmod 777 /data/vendor/nubialog/common/xbl/sdam_regmap

exit 0
