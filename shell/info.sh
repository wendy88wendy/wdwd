#!/bin/sh
#
# @Time    : 2022-10-21
# @Author  : wendy
# @Desc    : ssh login banner
# disk
totaldisk=$(df -h -x devtmpfs -x tmpfs -x debugfs -x aufs -x overlay --total 2>/dev/null | tail -1)
disktotal=$(awk '{print $2}' <<< "${totaldisk}")
diskused=$(awk '{print $3}' <<< "${totaldisk}")
diskusedper=$(awk '{print $5}' <<< "${totaldisk}")
DISK_INFO="${diskused} of ${disktotal} disk space used (${diskusedper})"
# network
# extranet_ip=" and $(curl -s http://members.3322.org/dyndns/getip)"
IP_INFO="$(curl -s http://members.3322.org/dyndns/getip)"
# Container info
CONTAINER_INFO="$(sudo /usr/bin/crictl ps -a -o yaml 2> /dev/null | awk '/^  state: /{gsub("CONTAINER_", "", $NF) ++S[$NF]}END{for(m in S) printf "%s%s:%s ",substr(m,1,1),tolower(substr(m,2)),S[m]}')Images:$(sudo /usr/bin/crictl images -q 2> /dev/null | wc -l)"
# info
echo "--- Linux 系统信息 ---"
echo "主机名: $(hostname)"
echo "操作系统/发行版: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'=' -f2 | tr -d '"')"
echo "内核版本: $(uname -r)"
echo "CPU型号: $(lscpu | grep 'Model name' | cut -d':' -f2 | tr -s ' ')"
echo "内存总大小: $(free -h | grep Mem | awk '{print $2}')"
if [[ -d /sys/firmware/efi ]]; then
    echo "系统启动模式:EFI。"
else
    echo "系统启动模式:Legacy"
fi
echo "磁盘使用情况: ${DISK_INFO}"
echo "不间断运行时长:${UPTIME_INFO}"
echo "外网IP地址:${IP_INFO}"
echo "-----------------------"
