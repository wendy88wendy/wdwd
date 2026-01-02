#!/bin/bash
 
if [[ -d /sys/firmware/efi ]]; then
    echo "系统以EFI模式启动。"
else
    echo "系统是以Legacy模式启动。"
fi
