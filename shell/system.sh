#!/bin/bash

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
echo "磁盘使用情况: $(df -h)"
echo "-----------------------"
