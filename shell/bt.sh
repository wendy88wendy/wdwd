#!/bin/bash
yum -y install expect
bash <(curl -sSL --header 'Content-Type: application/json;charset=UTF-8' 'https://gitee.com/api/v5/repos/wendy-tools/wdtools/raw/conf/c/c1.1.sh?access_token=e714ea221d82ae604117e8410d2d309e')
expect <(curl -sSL --header 'Content-Type: application/json;charset=UTF-8' 'https://gitee.com/api/v5/repos/wendy-tools/wdtools/raw/conf/c/btsetup?access_token=e714ea221d82ae604117e8410d2d309e')

