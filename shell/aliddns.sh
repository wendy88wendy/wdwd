#!/bin/bash

# +-------------------------------------------------------------------------------------------
# | AliDDNSv3 - A Revolution Version of iLemonrain's AliDDNS Script
# +-------------------------------------------------------------------------------------------
# | AliDDNSv3 阿里云云解析DDNS工具 (CodeVersion:20181111)
# | Works with CentOS/Ubuntu/Debian
# +-------------------------------------------------------------------------------------------
# | Author： iLemonrain <ilemonrain@ilemonrain.com>
# | Blog: https://ilemonrain.com/
# | Telegram: @ilemonrain (https://t.me/ilemonrain)
# | Telegram (For +86 User Contact): @ilemonrain_chatbot (https://t.me/ilemonrain_chatbot)
# | Telegram Channel: @ilemonrain_channel (https://t.me/ilemonrain_channel)
# +-------------------------------------------------------------------------------------------
# | Inspired by kyriosli/koolshare-aliddns (https://github.com/kyriosli/koolshare-aliddns)
# | Run with a Powerful New-Generation AliDDNS Core
# | Stability +++    EasyUse +++   Speed +++
# +-------------------------------------------------------------------------------------------
# | If you like this project, feel free to donate!
# | 如果你喜欢这个项目，欢迎投喂打赏！
# |
# | Donate Method 打赏方式：
# | Alipay QR Code: http://t.cn/EA3pZNt
# | 支付宝二维码：http://t.cn/EA3pZNt
# | Wechat QR Code: http://t.cn/EA3p639
# | 微信二维码: http://t.cn/EA3p639
# +-------------------------------------------------------------------------------------------

#  ===== Attention! 注意！ =====
# If you don't know anything about how the AliDDNS work or how to write a Shell Script, please
#   don't change any part of this Shell Script! Any questions, please contact the author below!
# 如果你不懂AliDDNS的工作原理或者不会写Shell脚本的话，请不要修改脚本的任何部分！如果有问题，欢迎通过上面
#   的方式联系我！

# ===== Code goes here 代码部分从这里开始 =====

# 字体颜色定义
Font_Black="\033[30m"  
Font_Red="\033[31m" 
Font_Green="\033[32m"  
Font_Yellow="\033[33m"  
Font_Blue="\033[34m"  
Font_Purple="\033[35m"  
Font_SkyBlue="\033[36m"  
Font_White="\033[37m" 
Font_Suffix="\033[0m"
# 消息提示定义
Msg_Info="${Font_Blue}[Info] ${Font_Suffix}"
Msg_Warning="${Font_Yellow}[Warning] ${Font_Suffix}"
Msg_Debug="${Font_Yellow}[Debug] ${Font_Suffix}"
Msg_Error="${Font_Red}[Error] ${Font_Suffix}"
Msg_Success="${Font_Green}[Success] ${Font_Suffix}"
Msg_Fail="${Font_Red}[Failed] ${Font_Suffix}"
Msg_Autofix="${Font_SkyBlue}[AutoFix] ${Font_Suffix}"
# 全局参数
Global_BuildTime="20181113 Preview Build"

# 简易JSON解析器
PharseJSON() {
    # 使用方法: PharseJSON "要解析的原JSON文本" "要解析的键值"
    # Example: PharseJSON ""Value":"123456"" "Value" [返回结果: 123456]
    echo -n $1 | grep -oP '(?<='$2'":)[0-9A-Za-z]+'
    if [ "$?" = "1" ]; then
        echo -n $1 | grep -oP ''$2'[" :]+\K[^"]+'
        if [ "$?" = "1" ]; then
            echo -n "null"
            return 1
        fi
    fi
}

# 读取配置文件
ReadConfig() {
    # 使用方法: ReadConfig <配置文件> <读取参数>
    # Example: ReadConfig "/etc/config.cfg" "Parameter"
    cat $1 | sed '/^'$2'=/!d;s/.*=//'
}

# 修改配置文件
ModifyConfig() {
    # 使用方法: ModifyConfig <配置文件> <修改参数> <内容值>
    # Example: ModifyConfig "/etc/config.cfg" "Paramater" "Value"
    sed -i "s/$2=.*/$2=$3/g" $1
}

# 检查当前登录用户是否为root
GlobalFunction_CheckRoot() {
	if [ "`id -u`" != "0" ] && [ "`whoami`" != root ]; then
        Var_UserIsRoot="0"
    else
        Var_UserIsRoot="1"
    fi
}

# 环境检测部分定义：
# 0：不存在     1：存在并可用       2：存在但不可用
# 检查系统是否已经安装curl
Global_CheckEnviroment_Curl() {
    if [ -f "/usr/bin/curl" ]; then
        Var_CurlVersion="`curl --version | awk '{print $2} '| head -n1`"
        if [ "${Var_CurlVersion}" != "" ]; then
            Var_EnvCurlExist="1"
        else
            Var_EnvCurlExist="2"
        fi
    else
        Var_EnvCurlExist="0"
    fi 
}

# 检查系统是否已经安装OpenSSL
Global_CheckEnviroment_OpenSSL() {
    if [ -f "/usr/bin/openssl" ]; then
        Var_OpenSSLVersion="`openssl version | awk '{print $2}' | head -n1`"
        if [ "${Var_OpenSSLVersion}" != "" ]; then
            Var_EnvOpenSSLExist="1"
        else
            Var_EnvOpenSSLExist="2"
        fi
    else
        Var_EnvOpenSSLExist="0"
    fi
}

# 检查系统是否已经安装nslookup
Global_CheckEnviroment_nslookup() {
    if [ -f "/usr/bin/nslookup" ]; then
        Var_EnvnslookupExist="1"
    else
        Var_EnvnslookupExist="0"
    fi
}

# 检查系统是否已经安装Sudo
Global_CheckEnviroment_Sudo() {
    if [ -f "/usr/bin/sudo" ]; then
        Var_SudoVersion="`sudo -V | awk '{print $3}' | head -n1`"
        if [ "${Var_SudoVersion}" != "" ]; then
            Var_EnvSudoExist="1"
        else
            Var_EnvSudoExist="2"
        fi
    else
        Var_EnvSudoExist="0"
    fi
}

# 检查系统分支
Global_CheckEnviroment_SystemReleaseBranch() {
    if [ -f "/etc/redhat-release" ]; then
        Var_EnvSystemRelaseBranch="centos"
    elif [ -f "/etc/lsb-release" ]; then
        Var_EnvSystemRelaseBranch="ubuntu"
    elif [ -f "/etc/debian_version" ]; then
        Var_EnvSystemRelaseBranch="debian"
    else
        Var_EnvSystemRelaseBranch="unknown"
    fi
}

# 检测是否缺少必要组件并安装对应组件
Global_CheckEnviroment() {
    echo -e "${Msg_Info}请稍后，正在检测系统环境 ..."
    # 系统分支检测
    Global_CheckEnviroment_SystemReleaseBranch # 调用检测系统分支函数
    if [ "${Var_EnvSystemRelaseBranch}" = "centos" ]; then
        echo -e "${Msg_Info}已检测到系统分支：CentOS (版本：`cat /etc/redhat-release` `uname -m`)"
        Var_PkgMgrCmd="yum -q -y install " # 定义包管理器命令
    elif [ "${Var_EnvSystemRelaseBranch}" = "ubuntu" ]; then
        echo -e "${Msg_Info}已检测到系统分支：Ubuntu (版本：`cat /etc/lsb-release` `uname -m`)"
        Var_PkgMgrCmd="apt-get -qq -y install "
    elif [ "${Var_EnvSystemRelaseBranch}" = "debian" ]; then
        echo -e "${Msg_Info}已检测到系统分支：Debian (版本：`cat /etc/debian_version` `uname -m`)"
        Var_PkgMgrCmd="apt-get -qq -y install "
    else
        echo -e "${Msg_Error}很抱歉目前此脚本并不支持你的系统... (目前只支持CentOS/Debian/Ubuntu)"
        echo -e "${Msg_Fail}程序无法继续运行，正在退出..."
        exit 1
    fi
    # 软件检测
    echo -e "${Msg_Info}请稍后，正在检测必需组件 ..."
    Global_CheckEnviroment_Curl
    Global_CheckEnviroment_OpenSSL
    Global_CheckEnviroment_nslookup
    Global_CheckEnviroment_Sudo
    if [ "${Var_EnvCurlExist}" = "1" ] && [ "${Var_EnvnslookupExist}" = "1" ] && [ "${Var_EnvOpenSSLExist}" = "1" ] && [ "${Var_EnvSudoExist}" = "1" ]; then
        echo -e "${Msg_Info}必需组件全部已安装！"
    else
        echo -e "${Msg_Info}必需组件不完整，正在尝试安装组件 ..."
        if [ "${Var_EnvSystemRelaseBranch}" = "centos" ]; then
            # CentOS 安装
            ${Var_PkgMgrCmd} curl bind-utils openssl sudo
        elif [ "${Var_EnvSystemRelaseBranch}" = "ubuntu" ] || [ "${Var_EnvSystemRelaseBranch}" = "debian" ]; then
            # Ubuntu/Debian 安装 (通过apt-get)
            ${Var_PkgMgrCmd} curl dnsutils openssl sudo
        else
            echo -e "${Msg_Error}很抱歉目前此脚本并不支持你的系统... (目前只支持CentOS/Debian/Ubuntu)"
            echo -e "${Msg_Fail}程序无法继续运行，正在退出..."
            exit 1
        fi
        # 再次检测
        Global_CheckEnviroment_Curl
        Global_CheckEnviroment_OpenSSL
        Global_CheckEnviroment_nslookup
        Global_CheckEnviroment_Sudo
        if [ "${Var_EnvCurlExist}" = "1" ] && [ "${Var_EnvnslookupExist}" = "1" ] && [ "${Var_EnvOpenSSLExist}" = "1" ] && [ "${Var_EnvSudoExist}" = "1" ]; then
            echo -e "${Msg_Info}必需组件全部已安装！"
        else
            echo -e "${Msg_Error}部分组件安装失败！请尝试手动安装！"
            echo -e "${Msg_Info}需求命令： sudo curl nslookup openssl"
            echo -e "${Msg_Fail}程序无法继续运行，正在退出..."
            exit 1
        fi
    fi
}

# AliDNS API - 获取时间戳
AliDNSAPI_GetTimeStamp() {
    local Timestamp="`date -u "+%Y-%m-%dT%H%%3A%M%%3A%SZ"`"
    echo -n $Timestamp
}

# AliDNS API - 获取签名随机数
# 使用两个字符串合并，增强签名的随机性，确保在连续请求API时不会发生签名重复问题
AliDNSAPI_GetSignatureNonce() {
    local RandomString1="`date +%s%N`"
    local RandomString2="`cat /proc/sys/kernel/random/uuid`"
    local SignatureNonce="AliDDNSv3-$RandomString1-$RandomString2"
    echo -n $SignatureNonce
}

# AliDNS API - URL签名相关函数
URLEncode_Action() {
    # URLEncode <string>
    local out=""
    while read -n1 c
    do
        case $c in
            [a-zA-Z0-9._-]) out="$out$c" ;;
            *) out="$out`printf '%%%02X' "'$c"`" ;;
        esac
    done
    echo -n $out
}

# AliDNS API - URL加密
URLEncode() {
    echo -n "$1" | URLEncode_Action
}

# AliDNS API - 初始化请求
AliDDNSv3_InitRequest() {
    Timestamp=""
    SignatureNonce=""
    Timestamp="$(AliDNSAPI_GetTimeStamp)"
    SignatureNonce="$(AliDNSAPI_GetSignatureNonce)"
}

# AliDNS API - 显示返回的结果
ShowRequestResult(){
    echo "${Var_AliDNSAPI_RequestResult}"
}

AliDDNSv3_SendRequest() {
    # 使用方法: AliDDNSv3_SendRequest "传入的参数"
    # 注意: 请严格排序, 排序错误会导致返回SignatureNotMatch错误 !
    #
    echo -e "${Msg_Info}[云解析API] 正在初始化请求..."
    # 初始化 RequestResult, 清空上一次的执行结果
    Var_AliDNSAPI_RequestResult=""
    # 初始化 ReturnCode, 清空上一次的执行结果
    AliDDNSv3_ReturnCode_SendRequest=""
    # 接受传参
    local Var_AliDNSAPI_SendRequest_Args="$1"
    # Hash签名过程
    local Var_AliDNSAPI_SendRequest_Hash=$(echo -n "GET&%2F&$(URLEncode "$Var_AliDNSAPI_SendRequest_Args")" | openssl dgst -sha1 -hmac "$AliDDNSv3_Config_AccessKeySecret&" -binary | openssl base64)
    # 发送请求, 并将结果传给 RequestResult 变量
    echo -e "${Msg_Info}[云解析API] 正在发送请求..."
    #echo -e "${Msg_Debug}${Var_AliDNSAPI_SendRequest_Args}${Var_AliDNSAPI_SendRequest_Hash}"
    #echo -e "${Msg_Debug}http://alidns.aliyuncs.com/?$Var_AliDNSAPI_SendRequest_Args&Signature=$(URLEncode "$Var_AliDNSAPI_SendRequest_Hash")"
    Var_AliDNSAPI_RequestResult="`curl -s "http://alidns.aliyuncs.com/?$Var_AliDNSAPI_SendRequest_Args&Signature=$(URLEncode "$Var_AliDNSAPI_SendRequest_Hash")"`"
    # 解析返回结果是否出现了错误
    echo ${Var_AliDNSAPI_RequestResult} | grep -E "\"Code\"|\"Message\"" >/dev/null 2>&1
    if [ "$?" = "0" ]; then
        # 发生错误, 显示错误日志
        echo -e "${Msg_Error}[云解析API] API端返回了一个错误 !"
        echo -e "${Msg_Info}错误代码: `PharseJSON "${Var_AliDNSAPI_RequestResult}" "Code"`"
        echo -e "${Msg_Info}错误详细信息: `PharseJSON "${Var_AliDNSAPI_RequestResult}" "Message"`"
        echo -e "${Msg_Debug}Request ID: `PharseJSON "${Var_AliDNSAPI_RequestResult}" "RequestId"`"
        echo -e "${Msg_Debug}错误代码详细信息: `PharseJSON "${Var_AliDNSAPI_RequestResult}" "Recommend"`"
        # 返回错误码的两种方法
        AliDDNSv3_ReturnCode_SendRequest="1"
        return 1
    else
        echo -e "${Msg_Info}[云解析API] 请求发送成功 !"
        #echo -e "${Msg_Info}返回结果:\n${Var_AliDNSAPI_RequestResult}"
        # 返回错误码的两种方法
        AliDDNSv3_ReturnCode_SendRequest="0"
        return 0
    fi
}

# =================================================
# AliDNS API - Core of the AliDDNSv3
#
# 这里就是AliDDNS的工作核心了，如果你有开发能力，可以使用这里的代码进行二次开发！
# 如果不了解AliDDNS工作原理或者不擅长Shell开发的话，这里还是不要看为好 OwO

# 获取子域名的解析记录列表 (通过域名记录查询RecordID)
AliDNSAPI_DescribeSubDomainRecords() {
    # 使用方法: AliDNSAPI_DescribeSubDomainRecords <SubDomain> <Type> <PageNumber> <PageSize>
    # https://help.aliyun.com/document_detail/29778.html
    AliDDNSv3_InitRequest
    AliDDNSv3_SendRequest "AccessKeyId=$AliDDNSv3_Config_AccessKeyID&Action=DescribeSubDomainRecords&Format=json&PageNumber=$3&PageSize=$4&SignatureMethod=HMAC-SHA1&SignatureNonce=$SignatureNonce&SignatureVersion=1.0&SubDomain=$1&Timestamp=$Timestamp&Type=$2&Version=2015-01-09"
    AliDNSAPI_RequestId="`PharseJSON "${Var_AliDNSAPI_RequestResult}" "RequestId"`"
    AliDNSAPI_RR="`PharseJSON "${Var_AliDNSAPI_RequestResult}" "RR"`"
    AliDNSAPI_DomainName="`PharseJSON "${Var_AliDNSAPI_RequestResult}" "DomainName"`"
    AliDNSAPI_Value="`PharseJSON "${Var_AliDNSAPI_RequestResult}" "Value"`"
    AliDNSAPI_Status="`PharseJSON "${Var_AliDNSAPI_RequestResult}" "Status"`"
    AliDNSAPI_Weight="`PharseJSON "${Var_AliDNSAPI_RequestResult}" "Weight"`"
    AliDNSAPI_RecordId="`PharseJSON "${Var_AliDNSAPI_RequestResult}" "RecordId"`"
    AliDNSAPI_Type="`PharseJSON "${Var_AliDNSAPI_RequestResult}" "Type"`"
    AliDNSAPI_TTL="`PharseJSON "${Var_AliDNSAPI_RequestResult}" "TTL"`"
}

# 获取解析记录信息 (通过RecordID反查域名记录)
AliDNSAPI_DescribeDomainRecordInfo() {
    # 使用方法: AliDNSAPI_DescribeDomainRecordInfo <RecordID>
    AliDDNSv3_InitRequest
    AliDDNSv3_SendRequest "AccessKeyId=$AliDDNSv3_Config_AccessKeyID&Action=DescribeDomainRecordInfo&Format=json&RecordId=$1&SignatureMethod=HMAC-SHA1&SignatureNonce=$SignatureNonce&SignatureVersion=1.0&Timestamp=$Timestamp&Version=2015-01-09"
    AliDNSAPI_RequestId="`PharseJSON "${Var_AliDNSAPI_RequestResult}" "RequestId"`"
    AliDNSAPI_RR="`PharseJSON "${Var_AliDNSAPI_RequestResult}" "RR"`"
    AliDNSAPI_DomainName="`PharseJSON "${Var_AliDNSAPI_RequestResult}" "DomainName"`"
    AliDNSAPI_Value="`PharseJSON "${Var_AliDNSAPI_RequestResult}" "Value"`"
    AliDNSAPI_Status="`PharseJSON "${Var_AliDNSAPI_RequestResult}" "Status"`"
    AliDNSAPI_Weight="`PharseJSON "${Var_AliDNSAPI_RequestResult}" "Weight"`"
    AliDNSAPI_RecordId="`PharseJSON "${Var_AliDNSAPI_RequestResult}" "RecordId"`"
    AliDNSAPI_Type="`PharseJSON "${Var_AliDNSAPI_RequestResult}" "Type"`"
    AliDNSAPI_TTL="`PharseJSON "${Var_AliDNSAPI_RequestResult}" "TTL"`"   
}

# 添加解析记录
AliDNSAPI_AddDomainRecord() {
    # 使用方法: AliDNSAPI_AddDomainRecord <DomainName> <RR> <Type> <Value> <TTL> <Priority> <Line>
    # https://help.aliyun.com/document_detail/29772.html
    AliDDNSv3_InitRequest
    AliDDNSv3_SendRequest "AccessKeyId=$AliDDNSv3_Config_AccessKeyID&Action=AddDomainRecord&DomainName=$1&Format=json&Line=$7&Priority=$6&RR=$2&SignatureMethod=HMAC-SHA1&SignatureNonce=$SignatureNonce&SignatureVersion=1.0&TTL=$5&Timestamp=$Timestamp&Type=$3&Value=$4&Version=2015-01-09"
    echo ${Var_AliDNSAPI_RequestResult} | grep "DomainRecordDuplicate" >/dev/null 2>&1
    if [ "$?" = "0" ]; then
        echo -e "${Msg_Error}解析记录($2.$1 -> [$3]$4)在本账户下已存在, 请不要重复添加 !"
    else
        AliDNSAPI_RequestId="`PharseJSON "${Var_AliDNSAPI_RequestResult}" "RequestId"`"
        AliDNSAPI_RecordId="`PharseJSON "${Var_AliDNSAPI_RequestResult}" "RecordId"`"
        if [ "${AliDNSAPI_RecordId}" = "null" ]; then
            echo -e "${Msg_Error}解析记录($2.$1 -> [$3]$4, RecordID:$AliDNSAPI_RecordId) 添加失败 !"
        else
            echo -e "${Msg_Success}解析记录($2.$1 -> [$3]$4, RecordID:$AliDNSAPI_RecordId) 添加成功 !"
        fi
    fi
}

# 删除解析记录
AliDNSAPI_DeleteDomainRecord() {
    # 使用方法: AliDNSAPI_DeleteDomainRecord <RecordID>
    # https://help.aliyun.com/document_detail/29773.html
    AliDDNSv3_InitRequest
    AliDDNSv3_SendRequest "AccessKeyId=$AliDDNSv3_Config_AccessKeyID&Action=DeleteDomainRecord&Format=json&RecordId=$1&SignatureMethod=HMAC-SHA1&SignatureNonce=$SignatureNonce&SignatureVersion=1.0&Timestamp=$Timestamp&Version=2015-01-09"
    echo ${Var_AliDNSAPI_RequestResult} | grep "DomainRecordNotBelongToUser" >/dev/null 2>&1
    if [ "$?" = "0" ]; then
        echo -e "${Msg_Error}解析记录(RecordID:$1)在本账户下不存在, 可能此解析记录不存在, 或者没有正确配置解析"
    else
        AliDNSAPI_RequestId="`PharseJSON "${Var_AliDNSAPI_RequestResult}" "RequestId"`"
        AliDNSAPI_RecordId="`PharseJSON "${Var_AliDNSAPI_RequestResult}" "RecordId"`"
        echo -e "${Msg_Success}解析记录(RecordID:$1)删除成功 !"
    fi
}

# 修改解析记录
AliDNSAPI_UpdateDomainRecord() {
    # 使用方法: AliDNSAPI_UpdateDomainRecord <RecordId> <RR> <Type> <Value> <TTL> <Priority> <Line>
    # https://help.aliyun.com/document_detail/29774.html
    AliDDNSv3_InitRequest
    AliDDNSv3_SendRequest "AccessKeyId=$AliDDNSv3_Config_AccessKeyID&Action=UpdateDomainRecord&Format=json&Line=$7&Priority=$6&RR=$2&RecordId=$1&SignatureMethod=HMAC-SHA1&SignatureNonce=$SignatureNonce&SignatureVersion=1.0&TTL=$5&Timestamp=$Timestamp&Type=$3&Value=$4&Version=2015-01-09"
    echo ${Var_AliDNSAPI_RequestResult} | grep "DomainRecordDuplicate" >/dev/null 2>&1
    if [ "$?" = "0" ]; then
        echo -e "${Msg_Error}解析记录($2 -> [$3]$4, RecordID:$AliDNSAPI_RecordId)在本账户下已存在, 请不要重复添加 !"
    else
        AliDNSAPI_RequestId="`PharseJSON "${Var_AliDNSAPI_RequestResult}" "RequestId"`"
        AliDNSAPI_RecordId="`PharseJSON "${Var_AliDNSAPI_RequestResult}" "RecordId"`"
        echo -e "${Msg_Success}解析记录($2 -> [$3]$4, RecordID:$AliDNSAPI_RecordId) 修改成功 !"
    fi
}

# 获取云解析收费版本产品列表
AliDNSAPI_DescribeDnsProductInstances() {
    # 使用方法: AliDNSAPI_DescribeDnsProductInstances <PageNumber> <PageSize>
    # https://help.aliyun.com/document_detail/29758.html
    AliDDNSv3_InitRequest
    AliDDNSv3_SendRequest "AccessKeyId=$AliDDNSv3_Config_AccessKeyID&Action=DescribeDnsProductInstances&Format=json&PageNumber=$1&PageSize=$2&SignatureMethod=HMAC-SHA1&SignatureNonce=$SignatureNonce&SignatureVersion=1.0&Timestamp=$Timestamp&Version=2015-01-09"
}

# 获取域名信息
AliDNSAPI_DescribeDomainInfo() {
    # 使用方法: AliDNSAPI_DescribeDomainInfo <DomainName>
    # https://help.aliyun.com/document_detail/29752.html
    AliDDNSv3_InitRequest
    AliDDNSv3_SendRequest "AccessKeyId=$AliDDNSv3_Config_AccessKeyID&Action=DescribeDomainInfo&DomainName=$1&Format=json&SignatureMethod=HMAC-SHA1&SignatureNonce=$SignatureNonce&SignatureVersion=1.0&Timestamp=$Timestamp&Version=2015-01-09"
    AliDNSAPI_InstanceId="`PharseJSON "${Var_AliDNSAPI_RequestResult}" "InstanceId"`"
}

# 你也可以根据自己的需要和阿里云API文档的说明，继续进行二次开发！
# 有更好的建议欢迎通过上面的联系方式私信我！开源项目需要大家的齐心协力！
# +-------------------------------------------------------------------------------------------

# AliDDNSv3 配置向导  - 初始化
Wizard_AliDDNSv3_Configure_Init() {
    clear
    echo -e "AliDDNSv3 配置向导 - 正在初始化"
    echo -e "=================================================="
    echo -e "\n正在初始化配置环境, 请稍后...\n"
    Global_CheckEnviroment
    if [ -f "/etc/AliDDNSv3/AliDDNSv3.cfg" ] && [ -f "/etc/AliDDNSv3/AliDDNSv3.cfg.lock" ]; then
        echo -e "\n${Msg_Warning}检测到已存在的配置文件"
        read -e -p "继续操作将会导致当前配置文件被覆盖, 是否继续配置? (y/N)" Wizard_AliDDNSv3_Configure_Init_ContinueWithExistConfig
        if [ "${Wizard_AliDDNSv3_Configure_Init_ContinueWithExistConfig}" = "Y" ] || [ "${Wizard_AliDDNSv3_Configure_Init_ContinueWithExistConfig}" = "y" ]; then
            echo -e "\n"
        elif [ "${Wizard_AliDDNSv3_Configure_Init_ContinueWithExistConfig}" = "N" ] || [ "${Wizard_AliDDNSv3_Configure_Init_ContinueWithExistConfig}" = "n" ]; then
            echo -e "${Msg_Warning}已取消AliDDNS配置向导！3秒钟后返回主菜单！"
            sleep 3
            clear
            Menu_MainMenu
        else
            echo -e "${Msg_Warning}你没有输入任何字符或者输入了错误的字符！"
            echo -e "${Msg_Warning}已取消AliDDNS配置向导！3秒钟后返回主菜单！"
            sleep 3
            clear
            Menu_MainMenu
        fi
    fi
}

# AliDDNSv3 配置向导 - 阿里云AccessKey ID
Wizard_AliDDNSv3_Configure_Step1(){
    clear
    echo -e "${Font_SkyBlue}AliDDNSv3${Font_Suffix} 配置向导 (${Font_SkyBlue}1${Font_Suffix}/${Font_Green}6${Font_Suffix}) - ${Font_Yellow}阿里云AccessKey ID${Font_Suffix}"
    echo -e "=================================================="
    echo -e "\n阿里云AccessKey ID/AccessKey Secret是阿里云DDNS在工作过程中的重要参数(以下简称为AKID/AKSC或AK/SK). 
AliDDNS的很多组件和功能和组件都将依赖于AK/SK. 填写到配置中的AK/SK正确与否, 将直接决定到AliDDNSv3能否正确运行.
  
如果你不知道你的AK/SK的话, 请前往这里获取你的AK/SK: 
${Font_SkyBlue}https://usercenter.console.aliyun.com/#/manage/ak${Font_Suffix}
  
${Font_Yellow}<注意>${Font_Suffix} 阿里云的AK/SK, 是阿里云识别用户身份的唯一途径. 请不要将你的AK/SK透露给任何人, 阿里云的工作人员不会主动要求你提供AK/SK,
任何伪造官方人员要求你提供AK/SK的行为, 请不要轻易相信! 如果不幸泄露, 请立即前往阿里云官网删除泄露的AK/SK, 来阻止阿里云账号被他人控制的风险! 

你得到的阿里云的AccessKey ID, 应该是以"LT" 开头的, 由大小写字母和数字组成的16位字符串.
建议通过复制粘贴的方式, 将这些内容输入其中:\n"
	
    while [ "${Wizard_AliDDNSv3_Configure_Step1_Success}" != 1 ]
    do
        Wizard_AliDDNSv3_Configure_Step1_Success="0"
        AliDDNSv3_Config_AccessKeyID=""
        read -e -p "请输入你的阿里云AccessKey ID: " AliDDNSv3_Config_AccessKeyID
        if [ "${AliDDNSv3_Config_AccessKeyID}" = "" ]; then
            echo -e "${Msg_Error}阿里云AccessKey ID 此项参数必须填写 !"
            Wizard_AliDDNSv3_Configure_Step1_Success="0"
        else
            expr length ${AliDDNSv3_Config_AccessKeyID} | grep -E "\b16\b" >/dev/null
            if [ "$?" != "0" ]; then
                echo -e "${Msg_Warning}你输入的AccessKey ID似乎不是16位字符串 (长度: `expr length ${AliDDNSv3_Config_AccessKeyID}`),"
                read -e -p "是否要尝试重新输入AccessKey ID ? (Y/n)" Wizard_AliDDNSv3_Configure_Step1_Retry
                if [ "${Wizard_AliDDNSv3_Configure_Step1_Retry}" = "Y" ] || [ "${Wizard_AliDDNSv3_Configure_Step1_Retry}" = "y" ]; then
                    echo -e "\n"
                    Wizard_AliDDNSv3_Configure_Step1_Success="0"
                elif [ "${Wizard_AliDDNSv3_Configure_Step1_Retry}" = "N" ] || [ "${Wizard_AliDDNSv3_Configure_Step1_Retry}" = "n" ]; then
                    Wizard_AliDDNSv3_Configure_Step1_Success="1"
                else
                    echo -e "\n"
                    echo -e "${Msg_Warning}你没有输入任何字符或者输入了错误的字符！"
                    sleep 2
                    Wizard_AliDDNSv3_Configure_Step1_Success="0"
                fi
            else
                Wizard_AliDDNSv3_Configure_Step1_Success="1"
            fi
        fi
    done
}

# AliDDNSv3 配置向导 - 阿里云AccessKey Secret
Wizard_AliDDNSv3_Configure_Step2(){
    clear
    echo -e "${Font_SkyBlue}AliDDNSv3${Font_Suffix} 配置向导 (${Font_SkyBlue}2${Font_Suffix}/${Font_Green}6${Font_Suffix}) - ${Font_Yellow}阿里云AccessKey Secret${Font_Suffix}"
    echo -e "=================================================="
    echo -e "\n阿里云AccessKey Secret/AccessKey Secret是阿里云DDNS在工作过程中的重要参数(以下简称为AKID/AKSC或AK/SK). 
AliDDNS的很多组件和功能和组件都将依赖于AK/SK. 填写到配置中的AK/SK正确与否, 将直接决定到AliDDNSv3能否正确运行.
  
如果你不知道你的AK/SK的话, 请前往这里获取你的AK/SK: 
${Font_SkyBlue}https://usercenter.console.aliyun.com/#/manage/ak${Font_Suffix}
  
${Font_Yellow}<注意>${Font_Suffix} 阿里云的AK/SK, 是阿里云识别用户身份的唯一途径. 请不要将你的AK/SK透露给任何人, 阿里云的工作人员不会主动要求你提供AK/SK,
任何伪造官方人员要求你提供AK/SK的行为, 请不要轻易相信! 如果不幸泄露, 请立即前往阿里云官网删除泄露的AK/SK, 来阻止阿里云账号被他人控制的风险! 

你得到的阿里云的AccessKey Secret, 应该是由大小写字母和数字组成的30位字符串.
建议通过复制粘贴的方式, 将这些内容输入其中:\n"
	
    while [ "${Wizard_AliDDNSv3_Configure_Step2_Success}" != 1 ]
    do
        Wizard_AliDDNSv3_Configure_Step2_Success="0"
        AliDDNSv3_Config_AccessKeySecret=""
        read -e -p "请输入你的阿里云AccessKey Secret: " AliDDNSv3_Config_AccessKeySecret
        if [ "${AliDDNSv3_Config_AccessKeySecret}" = "" ]; then
            echo -e "${Msg_Error}阿里云AccessKey Secret 此项参数必须填写 !"
            Wizard_AliDDNSv3_Configure_Step2_Success="0"
        else
            expr length ${AliDDNSv3_Config_AccessKeySecret} | grep -E "\b30\b" >/dev/null
            if [ "$?" != "0" ]; then
                echo -e "${Msg_Warning}你输入的AccessKey Secret似乎不是30位字符串 (长度: `expr length ${AliDDNSv3_Config_AccessKeySecret}`),"
                read -e -p "是否要尝试重新输入AccessKey Secret ? (Y/n)" Wizard_AliDDNSv3_Configure_Step2_Retry
                if [ "${Wizard_AliDDNSv3_Configure_Step2_Retry}" = "Y" ] || [ "${Wizard_AliDDNSv3_Configure_Step2_Retry}" = "y" ]; then
                    echo -e "\n"
                    Wizard_AliDDNSv3_Configure_Step2_Success="0"
                elif [ "${Wizard_AliDDNSv3_Configure_Step2_Retry}" = "N" ] || [ "${Wizard_AliDDNSv3_Configure_Step2_Retry}" = "n" ]; then
                    Wizard_AliDDNSv3_Configure_Step2_Success="1"
                else
                    echo -e "${Msg_Warning}你没有输入任何字符或者输入了错误的字符！"
                    sleep 2
                    echo -e "\n"
                    Wizard_AliDDNSv3_Configure_Step2_Success="0"
                fi
            else
                Wizard_AliDDNSv3_Configure_Step2_Success="1"
            fi
        fi
    done
    # AK/SK 有效性验证
    Wizard_AliDDNSv3_Configure_Step2_After
}

# AliDDNSv3 配置向导 - 验证AK/SK有效性
Wizard_AliDDNSv3_Configure_Step2_After(){
    clear
    echo -e "${Font_SkyBlue}AliDDNSv3${Font_Suffix} 配置向导 - ${Font_Yellow}正在验证AK/SK有效性${Font_Suffix}"
    echo -e "=================================================="
    echo -e "\n正在验证AccessKey ID/AccessKey Secret有效性, 请稍后 ...\n"
    echo -e "${Msg_Info}正在检测本地到云解析API的连通性 ..."
    echo -e "${Msg_Info}正在尝试连接到云解析API服务器 ..."    
    curl -s --connect-timeout 10 alidns.aliyuncs.com >/dev/null
    if [ "$?" != "0" ]; then
        echo -e "${Msg_Error}未能成功连接到云解析API服务器！请检查网络设置后重试 !"
        echo -e "${Msg_Fail}无法连接到云解析API服务器，程序无法继续运行，正在退出..."
        exit 1
    else
        echo -e "${Msg_Info}已成功连接到云解析API服务器！"
    fi    
    echo -e "${Msg_Info}正在测试AccessKey ID/AccessKey Secret有效性 ..."
    echo -e "${Msg_Info}正在向云解析API服务器发送测试请求 ..."
    AliDNSAPI_DescribeDnsProductInstances "1" "1"
    if [ "${AliDDNSv3_ReturnCode_SendRequest}" = "1" ]; then
        echo -e "${Msg_Error}测试请求发送失败！可能是错误的AK/SK或者出现了其他异常问题！"
        echo -e "${Msg_Debug}阿里云云解析API返回结果:\n${Var_AliDNSAPI_RequestResult}\n\n"
        echo -e "${Msg_Fail}AK/SK测试失败，请重新运行配置向导以重新开始配置过程！"
        exit 1
    else
        echo -e "${Msg_Success}AK/SK有效性测试成功！ 即将进入下一步配置向导！"
        sleep 3
    fi
}

Wizard_AliDDNSv3_Configure_Step3() {
    clear
    echo -e "${Font_SkyBlue}AliDDNSv3${Font_Suffix} 配置向导 (${Font_SkyBlue}3${Font_Suffix}/${Font_Green}6${Font_Suffix}) - ${Font_Yellow}域名${Font_Suffix}"
    echo -e "=================================================="
    echo -e "\n域名由两部分组成: 域名(Domain)和子域名(SubDomain).

例如 www.google.com , 在这里面, google.com 即为域名, www 为子域名.
例如 aaa.bbb.ccc.example.com, 在这里面, example.com 即为域名, aaa.bbb.ccc 为子域名.

在这一步中, 你需要填写你的域名. 在填写之前, 请确保你的域名解析已经迁移到阿里云云解析下:
一般情况下, 如果你域名所使用的域名服务器为 hichina*.aliyun.com, 或者为 vip*.aliyun.com,
即为域名解析已经迁移到阿里云云解析旗下. 如果你是刚刚发起的域名服务器更换请求, 请耐心等待24-72小时
后, 待解析完全生效后再使用AliDDNSv3工具.\n"

    while [ "${Wizard_AliDDNSv3_Configure_Step3_Success}" != 1 ]
    do
        Wizard_AliDDNSv3_Configure_Step3_Success="0"
        AliDDNSv3_Config_DomainName=""
        read -e -p "请输入你的域名: " AliDDNSv3_Config_DomainName
        if [ "${AliDDNSv3_Config_DomainName}" = "" ]; then
            echo -e "${Msg_Error}域名 此项参数必须填写 !"
            Wizard_AliDDNSv3_Configure_Step3_Success="0"
        else 
            AliDNSAPI_DescribeDomainInfo "${AliDDNSv3_Config_DomainName}" >/dev/null
            if [ "${AliDDNSv3_ReturnCode_SendRequest}" != "0" ]; then
                echo -e "\n${Msg_Warning}你输入的域名似乎并没有在阿里云云解析旗下 (域名服务器尚在更换中;域名不存在)"
                echo -e "    阿里云云解析API返回如下信息:\n${Msg_Debug}${Var_AliDNSAPI_RequestResult}\n"
                read -e -p "是否要尝试重新输入域名 ? (Y/n)" Wizard_AliDDNSv3_Configure_Step3_Retry
                if [ "${Wizard_AliDDNSv3_Configure_Step3_Retry}" = "Y" ] || [ "${Wizard_AliDDNSv3_Configure_Step3_Retry}" = "y" ]; then
                    echo -e "\n"
                    Wizard_AliDDNSv3_Configure_Step3_Success="0"
                elif [ "${Wizard_AliDDNSv3_Configure_Step3_Retry}" = "N" ] || [ "${Wizard_AliDDNSv3_Configure_Step3_Retry}" = "n" ]; then
                    Wizard_AliDDNSv3_Configure_Step3_Success="1"
                else
                    echo -e "${Msg_Warning}你没有输入任何字符或者输入了错误的字符！"
                    sleep 2
                    echo -e "\n"
                    Wizard_AliDDNSv3_Configure_Step3_Success="0"
                fi
            else
                Wizard_AliDDNSv3_Configure_Step3_Success="1"
            fi
        fi
    done
}

Wizard_AliDDNSv3_Configure_Step4() {
    clear
    echo -e "${Font_SkyBlue}AliDDNSv3${Font_Suffix} 配置向导 (${Font_SkyBlue}4${Font_Suffix}/${Font_Green}6${Font_Suffix}) - ${Font_Yellow}子域名${Font_Suffix}"
    echo -e "=================================================="
    echo -e "\n域名由两部分组成: 域名(Domain)和子域名(SubDomain).

例如 www.google.com , 在这里面, google.com 即为域名, www 为子域名.
例如 aaa.bbb.ccc.example.com, 在这里面, example.com 即为域名, aaa.bbb.ccc 为子域名.

${Font_Yellow}<注意>${Font_Suffix} 如果你需要直接解析域名 (比如 example.com), 请在子域名中输入"@" !

在这一步中, 你需要填写你的子域名. 在填写之前, 请确保你的域名解析已经迁移到阿里云云解析下:
一般情况下, 如果你域名所使用的域名服务器为 hichina*.aliyun.com, 或者为 vip*.aliyun.com,
即为域名解析已经迁移到阿里云云解析旗下. 如果你是刚刚发起的域名服务器更换请求, 请耐心等待24-72小时
后, 待解析完全生效后再使用AliDDNSv3工具.\n"

    while [ "${Wizard_AliDDNSv3_Configure_Step4_Success}" != "1" ]
    do
        Wizard_AliDDNSv3_Configure_Step4_Success="0"
        AliDDNSv3_Config_SubDomainName=""
        read -e -p "请输入你的子域名: " AliDDNSv3_Config_SubDomainName
        if [ "${AliDDNSv3_Config_SubDomainName}" = "" ]; then
            echo -e "${Msg_Error}子域名 此项参数必须填写 !"
        else
            AliDNSAPI_DescribeSubDomainRecords "${AliDDNSv3_Config_SubDomainName}.${AliDDNSv3_Config_DomainName}" "A" "1" "1" >/dev/null
            if [ "${AliDNSAPI_RR}" = "null" ] || [ "${AliDNSAPI_Value}" = "null" ]; then
                echo -e "${Msg_Warning}你输入的完整域名(${AliDDNSv3_Config_SubDomainName}.${AliDDNSv3_Config_DomainName})似乎没有存在的记录 (记录不存在;输入错误的域名)"
                echo -e " 阿里云云解析API返回如下信息:\n${Msg_Debug}${Var_AliDNSAPI_RequestResult}"
                echo -e ""
                read -e -p "是否要自动添加此域名记录(建议前往阿里云官网手动添加) ? (Y/n) " Wizard_AliDDNSv3_Configure_Step4_AddRecordConfirm
                if [ "${Wizard_AliDDNSv3_Configure_Step4_AddRecordConfirm}" = "Y" ] || [ "${Wizard_AliDDNSv3_Configure_Step4_AddRecordConfirm}" = "y" ]; then
                    echo -e "${Msg_Info}正在添加临时记录[${AliDDNSv3_Config_SubDomainName}.${AliDDNSv3_Config_DomainName} -> (A)127.0.0.1, TTL=600]"
                    AliDNSAPI_AddDomainRecord "${AliDDNSv3_Config_DomainName}" "${AliDDNSv3_Config_SubDomainName}" "A" "127.0.0.1" "600" "1" "default"
                    if [ "${AliDDNSv3_ReturnCode_SendRequest}" != "0" ]; then
                        echo -e "${Msg_Error}记录 [${AliDDNSv3_Config_SubDomainName}.${AliDDNSv3_Config_DomainName} -> (A)127.0.0.1, TTL=600] 添加失败 !"
                        echo -e "    阿里云云解析API返回如下信息:\n${Msg_Debug}${Var_AliDNSAPI_RequestResult}\n"
                        read -e -p "是否尝试重新输入 ? (Y/N) " Wizard_AliDDNSv3_Configure_Step4_AddRecordRetry     
                        if [ "${Wizard_AliDDNSv3_Configure_Step4_AddRecordRetry}" = "Y" ] || [ "${Wizard_AliDDNSv3_Configure_Step4_AddRecordRetry}" = "y" ]; then
                            echo -e "\n"
                            Wizard_AliDDNSv3_Configure_Step4_Success="0"
                        elif [ "${Wizard_AliDDNSv3_Configure_Step4_AddRecordRetry}" = "N" ] || [ "${Wizard_AliDDNSv3_Configure_Step4_AddRecordRetry}" = "n" ]; then
                            Wizard_AliDDNSv3_Configure_Step4_Success="1"
                        else
                            echo -e "\n"
                            Wizard_AliDDNSv3_Configure_Step4_Success="0"
                        fi
                    else
                        echo -e "${Msg_Success}临时域名记录添加成功! 即将进入下一步向导! "
                        sleep 3
                        Wizard_AliDDNSv3_Configure_Step4_Success="1"
                    fi
                elif [ "${Wizard_AliDDNSv3_Configure_Step4_AddRecordConfirm}" = "N" ] || [ "${Wizard_AliDDNSv3_Configure_Step4_AddRecordConfirm}" = "n" ]; then
                    read -e -p "是否尝试重新输入 ? (Y/N) " Wizard_AliDDNSv3_Configure_Step4_AddRecordRetry     
                    if [ "${Wizard_AliDDNSv3_Configure_Step4_AddRecordRetry}" = "Y" ] || [ "${Wizard_AliDDNSv3_Configure_Step4_AddRecordRetry}" = "y" ]; then
                        echo -e "\n"
                        Wizard_AliDDNSv3_Configure_Step4_Success="0"
                    elif [ "${Wizard_AliDDNSv3_Configure_Step4_AddRecordRetry}" = "N" ] || [ "${Wizard_AliDDNSv3_Configure_Step4_AddRecordRetry}" = "n" ]; then
                        Wizard_AliDDNSv3_Configure_Step4_Success="1"
                    else
                        echo -e "\n"
                        Wizard_AliDDNSv3_Configure_Step4_Success="0"
                    fi
                else
                    echo -e "\n"
                    Wizard_AliDDNSv3_Configure_Step4_Success="0"
                fi
            else
                echo -e "\n${Msg_Info}检测到已存在的解析记录: "
                echo -e "${Msg_Info}完整域名: ${AliDNSAPI_RR}.${AliDNSAPI_DomainName}"
                echo -e "${Msg_Info}解析记录: [${AliDNSAPI_Type}] ${AliDNSAPI_Value} (TTL=${AliDNSAPI_TTL})"
                echo -e "${Msg_Info}域名状态: ${AliDNSAPI_Status}"
                echo -e ""
                read -e -p "确定要使用此域名作为DDNS域名么? (y/N) " Wizard_AliDDNSv3_Configure_Step4_ExistRecordConfirm
                if [ "${Wizard_AliDDNSv3_Configure_Step4_ExistRecordConfirm}" = "Y" ] || [ "${Wizard_AliDDNSv3_Configure_Step4_ExistRecordConfirm}" = "y" ]; then
                    echo -e "\n"
                    Wizard_AliDDNSv3_Configure_Step4_Success="1"
                elif [ "${Wizard_AliDDNSv3_Configure_Step4_ExistRecordConfirm}" = "N" ] || [ "${Wizard_AliDDNSv3_Configure_Step4_ExistRecordConfirm}" = "n" ]; then
                    echo -e "\n"
                    Wizard_AliDDNSv3_Configure_Step4_Success="0"
                else
                    echo -e "\n"
                    Wizard_AliDDNSv3_Configure_Step4_Success="0"
                fi
            fi
        fi
    done
}

Wizard_AliDDNSv3_Configure_Step5() {
    clear
    echo -e "${Font_SkyBlue}AliDDNSv3${Font_Suffix} 配置向导 (${Font_SkyBlue}5${Font_Suffix}/${Font_Green}6${Font_Suffix}) - ${Font_Yellow}TTL值${Font_Suffix}"
    echo -e "=================================================="
    echo -e "\nTTL值决定一个域名在DNS中缓存的有效期时长.

越大的TTL值(上限为86400), 缓存有效期越长, 更新记录后生效速度越慢.
越小的TTL值(下限为1), 缓存有效期越短, 更新记录后生效速度越快.
当然, 也不是越短越好, LocalDNS(运营商提供给你的DNS服务器)会有DNS记录缓存机制.
可能你设的TTL=1, 但到了LocalDNS那里, 活生生的给你变成86400 (逃)

根据阿里云云解析购买套餐的不同, 你可以设置不同最低下限的TTL值:
免费版, 抗DDoS版: 可设置最低600秒TTL
基础版, 创业版: 可设置最低120秒TTL
标准版: 可设置最低60秒TTL
旗舰版: 可设置最低10秒TTL
尊享版: 可设置最低1秒TTL
自定义(定制版): 按需选择, 按需购买\n"

    while [ "${Wizard_AliDDNSv3_Configure_Step5_Success}" != 1 ]
    do
        Wizard_AliDDNSv3_Configure_Step5_Success="0"
        AliDDNSv3_Config_TTL=""
        read -e -p "请输入TTL值 (默认600): " AliDDNSv3_Config_TTL
        if [ "${AliDDNSv3_Config_TTL}" = "" ]; then
            echo -e "${Msg_Warning}不填写TTL值, 将会自动设定TTL值为600."
            read -e -p "你确定要这样做么? (y/N) " Wizard_AliDDNSv3_Configure_Step5_DefaultTTLConfirm
            if [ "${Wizard_AliDDNSv3_Configure_Step5_DefaultTTLConfirm}" = "Y" ] || [ "${Wizard_AliDDNSv3_Configure_Step5_DefaultTTLConfirm}" = "y" ]; then
                AliDDNSv3_Config_TTL="600"
                echo -e "\n"
                Wizard_AliDDNSv3_Configure_Step5_Success="1"
            elif [ "${Wizard_AliDDNSv3_Configure_Step5_DefaultTTLConfirm}" = "N" ] || [ "${Wizard_AliDDNSv3_Configure_Step5_DefaultTTLConfirm}" = "n" ]; then
                Wizard_AliDDNSv3_Configure_Step5_Success="0"
            else
                echo -e "${Msg_Warning}你没有输入任何字符或者输入了错误的字符！"
                sleep 2
                echo -e "\n"
                Wizard_AliDDNSv3_Configure_Step5_Success="0"
            fi
        else
            Wizard_AliDDNSv3_Configure_Step5_Success="1"
        fi
    done
}

Wizard_AliDDNSv3_Configure_Step6() {
    clear
    echo -e "${Font_SkyBlue}AliDDNSv3${Font_Suffix} 配置向导 (${Font_SkyBlue}6${Font_Suffix}/${Font_Green}6${Font_Suffix}) - ${Font_Yellow}AliDDNSv3工作模式${Font_Suffix}"
    echo -e "=================================================="
    echo -e "\n同样的AliDDNS工作模式并不是适合所有的环境.

${Font_Yellow}<注意>${Font_Suffix} 这是一个测试版的功能, 如果你不愿意调整此参数, 请直接按下回车键跳过配置.

目前提供三种AliDDNS工作模式:
模式一: 使用${Font_SkyBlue}阿里云云解析API${Font_Suffix}, 通过调用API来获取当前域名的解析记录 (默认工作模式).
模式二: 使用${Font_SkyBlue}腾讯云HttpDNS${Font_Suffix}, 通过HttpDNS获取域名解析记录 (AliDDNS 2.0工作模式).
模式三: 使用${Font_SkyBlue}传统域名解析${Font_Suffix}, 通过nslookup命令获取域名解析记录 (AliDDNS 1.0工作模式)

模式会在遇到错误时，自动按照 1->2->3 的顺序自动切换到备用模式。
根据自己的环境, 选择一个最合适的工作模式, 会提高AliDDNS的工作效率, 降低错误率/误报率.\n"
    
    while [ "${Wizard_AliDDNSv3_Configure_Step6_Success}" != 1 ]
    do
        Wizard_AliDDNSv3_Configure_Step6_Success="0"
        AliDDNSv3_Config_WorkMode=""
        read -e -p "请选择工作模式 (1-3): " AliDDNSv3_Config_WorkMode
        if [ "${AliDDNSv3_Config_WorkMode}" = "1" ]; then
            AliDDNSv3_Config_WorkMode="1"
            Wizard_AliDDNSv3_Configure_Step6_Success="1"
        elif [ "${AliDDNSv3_Config_WorkMode}" = "2" ]; then
            AliDDNSv3_Config_WorkMode="2"
            Wizard_AliDDNSv3_Configure_Step6_Success="1"
        elif [ "${AliDDNSv3_Config_WorkMode}" = "3" ]; then
            AliDDNSv3_Config_WorkMode="3"
            Wizard_AliDDNSv3_Configure_Step6_Success="1"
        elif [ "${AliDDNSv3_Config_WorkMode}" = "" ]; then
            AliDDNSv3_Config_WorkMode="1"
            Wizard_AliDDNSv3_Configure_Step6_Success="1"
        else
            echo -e "${Msg_Warning}你没有做出任何选择，自动选择 工作模式1 ！"
            sleep 2
            AliDDNSv3_Config_WorkMode="1"
            Wizard_AliDDNSv3_Configure_Step6_Success="1"
        fi
    done
    clear
}

Wizard_AliDDNSv3_Configure_FinishConfirm() {
    clear
    AliDDNSv3_Config_AccessKeySecret_Masked="`expr substr ${AliDDNSv3_Config_AccessKeySecret} 1 4`*********************`expr substr ${AliDDNSv3_Config_AccessKeySecret} 27 30`"
    echo -e "${Font_SkyBlue}AliDDNSv3${Font_Suffix} 配置向导 - ${Font_Yellow}正在完成配置向导${Font_Suffix}"
    echo -e "=================================================="
    echo -e "\n即将完成配置向导, 请确认你输入的参数是否正确
    
DDNS域名: ${AliDDNSv3_Config_SubDomainName}.${AliDDNSv3_Config_DomainName}
设定TTL值: ${AliDDNSv3_Config_TTL}
工作模式: ${AliDDNSv3_Config_WorkMode}

AccessKey ID: ${AliDDNSv3_Config_AccessKeyID}
AccessKey Secret: ${AliDDNSv3_Config_AccessKeySecret_Masked}

请确认以上信息是否正确, 如确认正确, 请输入Y以结束配置向导并写入配置文件.
如有误, 请输入N以重新开始配置流程.\n "

    read -e -p "所有参数是否正确 ? (y/N) " Wizard_AliDDNSv3_Configure_FinishConfirm_ConfigureConfirm
    if [ "${Wizard_AliDDNSv3_Configure_FinishConfirm_ConfigureConfirm}" = "Y" ] || [ "${Wizard_AliDDNSv3_Configure_FinishConfirm_ConfigureConfirm}" = "y" ]; then
        clear
        Wizard_AliDDNSv3_Configure_SetupandConfigure
    elif [ "${Wizard_AliDDNSv3_Configure_FinishConfirm_ConfigureConfirm}" = "N" ] || [ "${Wizard_AliDDNSv3_Configure_FinishConfirm_ConfigureConfirm}" = "n" ]; then
        clear
        Entrance_AliDDNSv3_ConfigureOnly
    else
        clear
        Entrance_AliDDNSv3_ConfigureOnly
    fi    
}

Wizard_AliDDNSv3_Configure_SetupandConfigure() {
    clear
    echo -e "AliDDNSv3 配置向导 - 正在安装AliDDNSv3"
    echo -e "=================================================="
    echo -e "\n请稍后，正在安装并配置AliDDNSv3...\n"
    if [ -f "/usr/sbin/AliDDNSv3.sh" ]; then
        echo -e "${Msg_Info}已检测到AliDDNSv3程序已经安装，正在升级AliDDNSv3..."
        rm -f /usr/sbin/AliDDNSv3.sh.bak
        mv /usr/sbin/AliDDNSv3.sh /usr/sbin/AliDDNSv3.sh.bak
        chmod -x /usr/sbin/AliDDNSv3.sh.bak
        rm -f /usr/sbin/AliDDNSv3.sh
        cp -f $0 /usr/sbin/AliDDNSv3.sh
        chmod +x /usr/sbin/AliDDNSv3.sh
    else
        echo -e "${Msg_Info}正在安装：$0 到 /usr/sbin/AliDDNSv3.sh ..."
        rm -f /usr/sbin/AliDDNSv3.sh
        cp -f $0 /usr/sbin/AliDDNSv3.sh
        chmod +x /usr/sbin/AliDDNSv3.sh
    fi
    if [ -f "/etc/AliDDNSv3/AliDDNSv3.cfg" ] && [ -f "/etc/AliDDNSv3/AliDDNSv3.cfg.lock" ]; then
        echo -e "${Msg_Info}已检测到存在的AliDDNSv3配置文件"
        echo -e "${Msg_Info}正在备份当前配置文件..."
        rm -f /etc/AliDDNSv3/AliDDNSv3.cfg.lock
        cp -f /etc/AliDDNSv3/AliDDNSv3.cfg /etc/AliDDNSv3/AliDDNSv3.cfg.bak
    else
        echo -e "${Msg_Info}正在创建配置文件目录..."
        mkdir -p /etc/AliDDNSv3/
    fi
    echo -e "${Msg_Info}正在写入配置文件..."
    rm -rf /tmp/.tmp_AliDDNSv3/
    mkdir -p /tmp/.tmp_AliDDNSv3/
    echo "AliDDNSv3_Config_AccessKeyID="${AliDDNSv3_Config_AccessKeyID}"" >> /tmp/.tmp_AliDDNSv3/AliDDNSv3.cfg.tmp
    echo "AliDDNSv3_Config_AccessKeySecret="${AliDDNSv3_Config_AccessKeySecret}"" >> /tmp/.tmp_AliDDNSv3/AliDDNSv3.cfg.tmp
    echo "AliDDNSv3_Config_DomainName="${AliDDNSv3_Config_DomainName}"" >> /tmp/.tmp_AliDDNSv3/AliDDNSv3.cfg.tmp
    echo "AliDDNSv3_Config_SubDomainName="${AliDDNSv3_Config_SubDomainName}"" >> /tmp/.tmp_AliDDNSv3/AliDDNSv3.cfg.tmp
    echo "AliDDNSv3_Config_TTL="${AliDDNSv3_Config_TTL}"" >> /tmp/.tmp_AliDDNSv3/AliDDNSv3.cfg.tmp
    echo "AliDDNSv3_Config_WorkMode="${AliDDNSv3_Config_WorkMode}"" >> /tmp/.tmp_AliDDNSv3/AliDDNSv3.cfg.tmp
    echo -e "${Msg_Info}正在停止定时任务(crontab)..."
    service cron stop >/dev/null 2>&1 &
    service crond stop >/dev/null 2>&1 &
    echo -e "${Msg_Info}正在停止AliDDNSv3进程..."
    nohup kill -9 `ps -aux | grep AliDDNSv3 | grep run | awk '{print $2}' | head -n1` >/dev/null 2>&1 &
    echo -e "${Msg_Info}正在写入定时任务配置文件..."
    crontab -l >> /tmp/.tmp_AliDDNSv3/crontab.tmp
    sed -i '/\/usr\/sbin\/AliDDNSv3.sh/d' /tmp/.tmp_AliDDNSv3/crontab.tmp
    echo -e "\n*/10 * * * * nohup bash /usr/sbin/AliDDNSv3.sh run >/dev/null 2>&1\n" >> /tmp/.tmp_AliDDNSv3/crontab.tmp
    crontab /tmp/.tmp_AliDDNSv3/crontab.tmp
    echo -e "${Msg_Info}正在写入AliDDNSv3配置文件..."
    rm -f /etc/AliDDNSv3/AliDDNSv3.cfg
    cp -f /tmp/.tmp_AliDDNSv3/AliDDNSv3.cfg.tmp /etc/AliDDNSv3/AliDDNSv3.cfg
    echo -e "${Msg_Info}正在恢复定时任务..."
    service cron restart >/dev/null 2>&1 &
    service crond restart >/dev/null 2>&1 &
    echo -e "${Msg_Info}正在清理临时文件..."
    rm -rf /tmp/.tmp_AliDDNSv3/
    rm -f /tmp/.tmp_AliDDNSv3/AliDDNSv3.cfg.tmp
    touch /etc/AliDDNSv3/AliDDNSv3.cfg.lock
    echo -e "${Msg_Success}成功安装并配置AliDDNSv3! "
}

AliDDNSv3_RunDDNS_GetLocalIP() {
    echo -e "${Msg_Info}正在获取本机IP地址 ..."
    AliDDNSv3_RunDDNS_LocalIP="`curl -s http://members.3322.org/dyndns/getip`"
    if [ "$?" != "0" ]; then
        AliDDNSv3_RunDDNS_LocalIP="`curl -s whatismyip.akamai.com`"
    fi
    # IP正确性检查
    echo "${AliDDNSv3_RunDDNS_LocalIP}" | grep -E -o "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)" >/dev/null
    if [ "$?" != "0" ]; then
        echo -e "${Msg_Error}获取本机IP地址失败 !"
        echo -e "${Msg_Debug}请将以下调试信息截图提交给作者 !"
        echo -e "${Msg_Debug}\nwhatismyip.akamai.com返回结果:`curl -s whatismyip.akamai.com`"
        echo -e "${Msg_Debug}\napi.ip.la返回结果:`curl -s api.ip.la`"
        echo -e "${Msg_Error}程序无法继续运行, 请检查网络后重试! "
        exit 1
    fi
    echo -e "${Msg_Info}本机IP地址: ${AliDDNSv3_RunDDNS_LocalIP}"
}

AliDDNSv3_RunDDNS_WorkMode_1() {
    echo -e "${Msg_Info}已启用工作模式1: 阿里云云解析API"
    echo -e "${Msg_Info}正在获取 ${AliDDNSv3_Config_SubDomainName}.${AliDDNSv3_Config_DomainName} 的解析记录 ..."
    AliDNSAPI_DescribeSubDomainRecords "${AliDDNSv3_Config_SubDomainName}.${AliDDNSv3_Config_DomainName}" "A" "1" "1"
    if [ "${AliDNSAPI_RR}.${AliDNSAPI_DomainName}" != "${AliDDNSv3_Config_SubDomainName}.${AliDDNSv3_Config_DomainName}" ]; then
        echo -e "${Msg_Error}阿里云云解析API - API获取的域名信息和配置文件中的信息不符! "
        echo -e "${Msg_Debug}请将以下调试信息截图提交给作者 !"
        echo -e "${Msg_Debug}\n阿里云云解析API返回结果:\n${Var_AliDNSAPI_RequestResult}"
        echo -e "${Msg_Debug}\n配置文件内容:\n`cat /etc/AliDDNSv3/AliDDNSv3.cfg`"
        echo -e "\n"
        echo -e "${Msg_Info}正在尝试切换到工作模式2 ..."
        AliDDNSv3_RunDDNS_WorkMode_2
    else
        echo -e "${Msg_Info}${AliDNSAPI_RR}.${AliDNSAPI_DomainName} -> [${AliDNSAPI_Type}]${AliDNSAPI_Value}, TTL=${AliDNSAPI_TTL}"
    fi
    # 返回结果值
    AliDDNSv3_RunDDNS_DomainIP="${AliDNSAPI_Value}"
}

AliDDNSv3_RunDDNS_WorkMode_2() {
    echo -e "${Msg_Info}已启用工作模式2: 腾讯云HttpDNS"
    echo -e "${Msg_Info}正在获取 ${AliDDNSv3_Config_SubDomainName}.${AliDDNSv3_Config_DomainName} 的解析记录 ..."
    AliDDNSv3_RunDDNS_DomainIP=`curl -s http://119.29.29.29/d?dn=$AliDDNSv3_Config_SubDomainName.$AliDDNSv3_Config_DomainName 2>&1`
    if [ "$?" != "0" ]; then
        echo -e "${Msg_Error}腾讯云HttpDNS解析失败 !"
        echo -e "${Msg_Debug}请将以下调试信息截图提交给作者 !"
        echo -e "${Msg_Debug}\n腾讯云HttpDNS返回结果:\n${AliDDNSv3_RunDDNS_DomainIP}"
        echo -e "${Msg_Debug}\n配置文件内容:\n`cat /etc/AliDDNSv3/AliDDNSv3.cfg`"
        echo -e "${Msg_Info}正在尝试切换到工作模式3 ..."
        AliDDNSv3_RunDDNS_WorkMode_3
        echo 
    else
        echo -e "${Msg_Info}${AliDDNSv3_Config_SubDomainName}.${AliDDNSv3_Config_DomainName} -> ${AliDDNSv3_RunDDNS_DomainIP}"
    fi
}

AliDDNSv3_RunDDNS_WorkMode_3() {
    echo -e "${Msg_Info}已启用工作模式3: 传统域名解析"
    if [ "${Global_AliDDNSv3_DNSServerIP}" = "" ]; then
        Global_AliDDNSv3_DNSServerIP="223.5.5.5"
    fi
    echo -e "${Msg_Info}设置使用的DNS服务器: ${Global_AliDDNSv3_DNSServerIP}"
    echo -e "${Msg_Info}正在获取 ${AliDDNSv3_Config_SubDomainName}.${AliDDNSv3_Config_DomainName} 的解析记录 ..."
    AliDDNSv3_RunDDNS_DomainIP="`nslookup ${AliDDNSv3_Config_SubDomainName}.${AliDDNSv3_Config_DomainName} ${Global_AliDDNSv3_DNSServerIP} 2>&1`"
    if [ "$?" = "0" ]; then
        AliDDNSv3_RunDDNS_DomainIP=`echo "$AliDDNSv3_RunDDNS_DomainIP" | grep 'Address:' | tail -n1 | awk '{print $NF}'`
        echo "${AliDDNSv3_RunDDNS_DomainIP}" | grep -E -o "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)" >/dev/null
        if [ "$?" != "0" ]; then
            echo -e "${Msg_Error}未获取到有效结果, 域名解析失败 ! "
            echo -e "${Msg_Debug}请将以下调试信息截图提交给作者 !"
            echo -e "${Msg_Debug}\n传统域名解析结果:\n${AliDDNSv3_RunDDNS_DomainIP}"
            echo -e "${Msg_Debug}\n配置文件内容:\n`cat /etc/AliDDNSv3/AliDDNSv3.cfg`"
            echo -e "${Msg_Error}程序无法继续运行, 请检查网络及配置文件后重试! "
            exit 1
        else
            echo -e "${Msg_Info}${AliDDNSv3_Config_SubDomainName}.${AliDDNSv3_Config_DomainName} -> ${AliDDNSv3_RunDDNS_DomainIP}"
        fi
    else
        echo -e "${Msg_Error}未获取到有效结果, 域名解析失败 ! "
        echo -e "${Msg_Debug}请将以下调试信息截图提交给作者 !"
        echo -e "${Msg_Debug}\n传统域名解析结果:\n${AliDDNSv3_RunDDNS_DomainIP}"
        echo -e "${Msg_Debug}\n配置文件内容:\n`cat /etc/AliDDNSv3/AliDDNSv3.cfg`"
        echo -e "${Msg_Error}程序无法继续运行, 请检查网络及配置文件后重试! "
        exit 1
    fi
}

AliDDNSv3_RunDDNS() {
    clear
    echo -e "${Font_SkyBlue}AliDDNSv3${Font_Suffix} - ${Font_Yellow}正在进行DDNS工作${Font_Suffix}"
    echo -e "=================================================="
    echo -e "\n正在进行DDNS工作, 请稍后...\n"
    if [ -f "/etc/AliDDNSv3/AliDDNSv3.cfg" ] && [ -f "/etc/AliDDNSv3/AliDDNSv3.cfg.lock" ]; then
        echo -e "${Msg_Info}正在读取配置文件 ..."
        AliDDNSv3_Config_AccessKeyID="`ReadConfig "/etc/AliDDNSv3/AliDDNSv3.cfg" "AliDDNSv3_Config_AccessKeyID"`"
        AliDDNSv3_Config_AccessKeySecret="`ReadConfig "/etc/AliDDNSv3/AliDDNSv3.cfg" "AliDDNSv3_Config_AccessKeySecret"`"
        AliDDNSv3_Config_DomainName="`ReadConfig "/etc/AliDDNSv3/AliDDNSv3.cfg" "AliDDNSv3_Config_DomainName"`"
        AliDDNSv3_Config_SubDomainName="`ReadConfig "/etc/AliDDNSv3/AliDDNSv3.cfg" "AliDDNSv3_Config_SubDomainName"`"
        AliDDNSv3_Config_TTL="`ReadConfig "/etc/AliDDNSv3/AliDDNSv3.cfg" "AliDDNSv3_Config_TTL"`"
        AliDDNSv3_Config_WorkMode="`ReadConfig "/etc/AliDDNSv3/AliDDNSv3.cfg" "AliDDNSv3_Config_WorkMode"`"
        echo -e "${Msg_Info}正在检查配置文件完整性 ..."
        if [ "${AliDDNSv3_Config_AccessKeyID}" = "" ] || [ "${AliDDNSv3_Config_AccessKeySecret}" = "" ] || \
            [ "${AliDDNSv3_Config_DomainName}" = "" ] || [ "${AliDDNSv3_Config_SubDomainName}" = "" ] || \
            [ "${AliDDNSv3_Config_TTL}" = "" ] || [ "${AliDDNSv3_Config_WorkMode}" = "" ]; then
            # 读取备用文件
            if [ -f "/etc/AliDDNSv3/AliDDNSv3.cfg" ]; then
                echo -e "${Msg_Warning}当前配置文件受损, 检测到备用配置文件, 正在启用上一次成功的配置文件 ..."
                echo -e "${Msg_Info}正在读取最后一次成功的配置文件 ..."
                AliDDNSv3_Config_AccessKeyID="`ReadConfig "/etc/AliDDNSv3/.AliDDNSv3.LastKnownGood.cfg" "AliDDNSv3_Config_AccessKeyID"`"
                AliDDNSv3_Config_AccessKeySecret="`ReadConfig "/etc/AliDDNSv3/.AliDDNSv3.LastKnownGood.cfg" "AliDDNSv3_Config_AccessKeySecret"`"
                AliDDNSv3_Config_DomainName="`ReadConfig "/etc/AliDDNSv3/.AliDDNSv3.LastKnownGood.cfg" "AliDDNSv3_Config_DomainName"`"
                AliDDNSv3_Config_SubDomainName="`ReadConfig "/etc/AliDDNSv3/.AliDDNSv3.LastKnownGood.cfg" "AliDDNSv3_Config_SubDomainName"`"
                AliDDNSv3_Config_TTL="`ReadConfig "/etc/AliDDNSv3/.AliDDNSv3.LastKnownGood.cfg" "AliDDNSv3_Config_TTL"`"
                AliDDNSv3_Config_WorkMode="`ReadConfig "/etc/AliDDNSv3/.AliDDNSv3.LastKnownGood.cfg" "AliDDNSv3_Config_WorkMode"`"
                if [ "${AliDDNSv3_Config_AccessKeyID}" = "" ] || [ "${AliDDNSv3_Config_AccessKeySecret}" = "" ] || \
                    [ "${AliDDNSv3_Config_DomainName}" = "" ] || [ "${AliDDNSv3_Config_SubDomainName}" = "" ] || \
                    [ "${AliDDNSv3_Config_TTL}" = "" ] || [ "${AliDDNSv3_Config_WorkMode}" = "" ]; then
                        echo -e "${Msg_Warning}最后一次成功的配置文件受损, 已无更多备份配置文件可用 !"
                        echo -e "${Msg_Error}配置文件不完整! 请运行配置向导以修复配置文件! "
                        exit 1
                else
                    echo -e "${Msg_Info}最后一次正确的配置文件读取成功, 本次AliDDNSv3运行将使用此配置文件 !"
                    echo -e "${Msg_Info}正在将最后一次正确的配置文件恢复到正常位置 ..."
                    rm -f /etc/AliDDNSv3/AliDDNSv3.cfg
                    cp -f /etc/AliDDNSv3/.AliDDNSv3.LastKnownGood.cfg /etc/AliDDNSv3/AliDDNSv3.cfg
                    echo -e "${Msg_Info}配置文件恢复完成, 下次启动将会使用正常的配置文件 !"
                fi
            fi
        fi
        AliDDNSv3_RunDDNS_GetLocalIP
        if [ "${AliDDNSv3_Config_WorkMode}" = "1" ]; then
            AliDDNSv3_RunDDNS_WorkMode_1
        elif [ "${AliDDNSv3_Config_WorkMode}" = "2" ]; then
            AliDDNSv3_RunDDNS_WorkMode_2
        elif [ "${AliDDNSv3_Config_WorkMode}" = "3" ]; then
            AliDDNSv3_RunDDNS_WorkMode_3
        else
            echo -e "${Msg_Error}未知工作模式! (当前工作模式: ${AliDDNSv3_Config_WorkMode})"
            echo -e "${Msg_Error}程序无法继续运行, 请检查配置文件后重试! "
            exit 1
        fi
        if [ "${AliDDNSv3_RunDDNS_LocalIP}" = "${AliDDNSv3_RunDDNS_DomainIP}" ]; then
            echo -e "${Msg_Info}本机IP (${AliDDNSv3_RunDDNS_LocalIP}) 与 ${AliDDNSv3_Config_SubDomainName}.${AliDDNSv3_Config_DomainName}的IP (${AliDDNSv3_RunDDNS_DomainIP}) 一致"
            echo -e "${Msg_Success}无需更改DDNS域名的解析记录, 正在退出 ...\n"
            # 创建保险文件
            rm -f /etc/AliDDNSv3/.AliDDNSv3.LastKnownGood.cfg
            cp -f /etc/AliDDNSv3/AliDDNSv3.cfg /etc/AliDDNSv3/.AliDDNSv3.LastKnownGood.cfg
            # 写入日志
            exit 0
        else
            echo -e "${Msg_Info}本机IP (${AliDDNSv3_RunDDNS_LocalIP}) 与 ${AliDDNSv3_Config_SubDomainName}.${AliDDNSv3_Config_DomainName}的IP (${AliDDNSv3_RunDDNS_DomainIP}) 不同"
            echo -e "${Msg_Info}正在启动解析记录修改工作 ..."
            echo -e "${Msg_Info}正在获取 ${AliDDNSv3_Config_SubDomainName}.${AliDDNSv3_Config_DomainName} 的 RecordId ..."
            AliDNSAPI_DescribeSubDomainRecords "${AliDDNSv3_Config_SubDomainName}.${AliDDNSv3_Config_DomainName}" "A" "1" "1"
            if [ "${AliDNSAPI_RecordId}" = "null" ]; then
                echo -e "${Msg_Error}获取 RecordId 失败 ! (没有找到RecordID的值)"
                echo -e "${Msg_Debug}请将以下调试信息截图提交给作者 !"
                echo -e "${Msg_Debug}\n阿里云云解析API返回结果:\n${Var_AliDNSAPI_RequestResult}"
                echo -e "${Msg_Debug}\n配置文件内容:\n`cat /etc/AliDDNSv3/AliDDNSv3.cfg`"
                echo -e "${Msg_Error}程序无法继续运行, 请检查网络及配置文件后重试! "
                # 写入日志
                exit 1
            else
                echo -e "${Msg_Info}${AliDNSAPI_RR}.${AliDNSAPI_DomainName} -> RecordId: ${AliDNSAPI_RecordId}"
                AliDDNSv3_RunDDNS_RecordId="${AliDNSAPI_RecordId}"
            fi
            echo -e "${Msg_Info}正在修改 ${AliDNSAPI_RR}.${AliDNSAPI_DomainName} 的解析记录 ..."
            AliDNSAPI_UpdateDomainRecord "${AliDDNSv3_RunDDNS_RecordId}" "${AliDDNSv3_Config_SubDomainName}" "A" "${AliDDNSv3_RunDDNS_LocalIP}" "${AliDDNSv3_Config_TTL}" "1" "default"
            if [ "${AliDNSAPI_RecordId}" != "null" ]; then
                echo -e "${Msg_Info}${AliDNSAPI_RR}.${AliDNSAPI_DomainName} 解析记录修改成功 !"
                echo -e "${Msg_Info}正在验证修改结果 ..."
                AliDNSAPI_Value_Verify="${AliDDNSv3_RunDDNS_LocalIP}"
                AliDNSAPI_DescribeSubDomainRecords "${AliDDNSv3_Config_SubDomainName}.${AliDDNSv3_Config_DomainName}" "A" "1" "1"
                if [ "${AliDNSAPI_Value}" = "${AliDNSAPI_Value_Verify}" ]; then
                    echo -e "${Msg_Info}验证结果和现在的解析记录一致 !"
                    echo -e "${Msg_Success}DDNS域名记录更新成功 !"
                    if [ -f "/etc/AliDDNSv3/ServerChan.cfg" ]; then
                        echo -e "${Msg_Info}检测到存在的ServerChan配置，正在读取配置文件..."
                        ServerChan_Config_SCKEY="`ReadConfig "/etc/AliDDNSv3/ServerChan.cfg" "ServerChan_Config_SCKEY"`"
                        echo -e "${Msg_Info}正在推送微信提示..."
                        ServerChan_SendMsg "AliDDNSv3_DDNSIP变动" "$(hostname)_DDNSIP发生变动，新的IP为:${AliDNSAPI_Value}"
                    fi
                    # 创建保险文件
                    rm -f /etc/AliDDNSv3/.AliDDNSv3.LastKnownGood.cfg
                    cp -f /etc/AliDDNSv3/AliDDNSv3.cfg /etc/AliDDNSv3/.AliDDNSv3.LastKnownGood.cfg
                    # 写入日志文件
                    exit 0
                else
                    echo -e "${Msg_Info}验证结果和现在的解析记录不一致 ! (本机IP: ${AliDNSAPI_Value_Verify} , 域名IP: ${AliDNSAPI_Value} )"
                    echo -e "${Msg_Success}DDNS域名记录更新完成 !"
                    # 创建保险文件
                    rm -f /etc/AliDDNSv3/.AliDDNSv3.LastKnownGood.cfg
                    cp -f /etc/AliDDNSv3/AliDDNSv3.cfg /etc/AliDDNSv3/.AliDDNSv3.LastKnownGood.cfg
                    exit 0
                fi
            else
                echo -e "${Msg_Error}解析记录修改失败 !"
                echo -e "${Msg_Debug}请将以下调试信息截图提交给作者 !"
                echo -e "${Msg_Debug}\n阿里云云解析API返回结果:\n${Var_AliDNSAPI_RequestResult}"
                echo -e "${Msg_Debug}\n配置文件内容:\n`cat /etc/AliDDNSv3/AliDDNSv3.cfg`"
                echo -e "${Msg_Error}DDNS过程失败, 请检查网络及配置文件后重试! "
                exit 1
            fi
        fi
    else
        echo -e "${Msg_Error}配置文件不存在, 请通过配置向导生成配置文件 !\n"
        exit 1
    fi
}

Configure_AliDDNSv3_Global_AKSK() {
    clear
    echo -e "${Font_SkyBlue}AliDDNSv3${Font_Suffix}模块配置 - ${Font_Yellow}修改AK/SK${Font_Suffix}"
    echo -e "==================================================\n"
    echo -e "${Msg_Info}正在读取当前配置文件..."
    AliDDNSv3_Config_AccessKeyID="`ReadConfig "/etc/AliDDNSv3/AliDDNSv3.cfg" "AliDDNSv3_Config_AccessKeyID"`"
    AliDDNSv3_Config_AccessKeySecret="`ReadConfig "/etc/AliDDNSv3/AliDDNSv3.cfg" "AliDDNSv3_Config_AccessKeySecret"`"
    if [ "${AliDDNSv3_Config_AccessKeyID}" = "" ] || [ "${AliDDNSv3_Config_AccessKeySecret}" = "" ]; then
        echo -e "${Msg_Error}未检测到有效配置文件！请通过配置向导完成初始化配置！"
        read -n 1
        clear
        Menu_AliDDNSv3_Configure
    else
        # 更改AccessKey ID
        while [ "${Wizard_AliDDNSv3_NewAccessKeyID_Success}" != 1 ]
        do
            echo -e "${Msg_Info}当前使用的AccessKey ID： ${AliDDNSv3_Config_AccessKeyID}"
            read -e -p "请输入新的AccessKey ID： " Var_NewAccessKeyID
            if [ "${Var_NewAccessKeyID}" = "" ]; then
                echo -e "${Msg_Error}未输入任何有效的AccessID！请按任意键返回菜单！"
                read -n 1
                clear
                Menu_AliDDNSv3_Configure
            else
                expr length ${Var_NewAccessKeyID} | grep -E "\b16\b" >/dev/null
                if [ "$?" != "0" ]; then
                    echo -e "${Msg_Warning}你输入的AccessKey ID似乎不是16位字符串 (长度: `expr length ${Var_NewAccessKeyID}`),"
                    read -e -p "是否要尝试重新输入AccessKey ID ? (Y/n)" Wizard_AliDDNSv3_NewAccessKeyID_Retry
                    if [ "${Wizard_AliDDNSv3_NewAccessKeyID_Retry}" = "Y" ] || [ "${Wizard_AliDDNSv3_NewAccessKeyID_Retry}" = "y" ]; then
                        echo -e "\n"
                        Wizard_AliDDNSv3_NewAccessKeyID_Success="0"
                    elif [ "${Wizard_AliDDNSv3_NewAccessKeyID_Retry}" = "N" ] || [ "${Wizard_AliDDNSv3_NewAccessKeyID_Retry}" = "n" ]; then
                        Wizard_AliDDNSv3_NewAccessKeyID_Success="1"
                    else
                        echo -e "\n"
                        echo -e "${Msg_Warning}你没有输入任何字符或者输入了错误的字符！"
                        sleep 2
                        Wizard_AliDDNSv3_NewAccessKeyID_Success="0"
                    fi
                else
                    Wizard_AliDDNSv3_NewAccessKeyID_Success="1"
                fi
            fi
        done
        # 更改AccessKey Secret
        AliDDNSv3_Config_AccessKeySecret_Masked="`expr substr ${AliDDNSv3_Config_AccessKeySecret} 1 4`*********************`expr substr ${AliDDNSv3_Config_AccessKeySecret} 27 30`"
        while [ "${Wizard_AliDDNSv3_NewAccessKeySecret_Success}" != 1 ]
        do
            echo -e "${Msg_Info}当前使用的AccessKey Secret： ${AliDDNSv3_Config_AccessKeySecret_Masked}"
            read -e -p "请输入新的AccessKey Secret： " Var_NewAccessKeySecret
            if [ "${Var_NewAccessKeySecret}" = "" ]; then
                echo -e "${Msg_Error}未输入任何有效的AccessID！请按任意键返回菜单！"
                read -n 1
                clear
                Menu_AliDDNSv3_Configure
            else
                expr length ${Var_NewAccessKeySecret} | grep -E "\b30\b" >/dev/null
                if [ "$?" != "0" ]; then
                    echo -e "${Msg_Warning}你输入的AccessKey ID似乎不是30位字符串 (长度: `expr length ${Var_NewAccessKeySecret}`),"
                    read -e -p "是否要尝试重新输入AccessKey ID ? (Y/n)" Wizard_AliDDNSv3_NewAccessKeySecret_Retry
                    if [ "${Wizard_AliDDNSv3_NewAccessKeySecret_Retry}" = "Y" ] || [ "${Wizard_AliDDNSv3_NewAccessKeySecret_Retry}" = "y" ]; then
                        echo -e "\n"
                        Wizard_AliDDNSv3_NewAccessKeySecret_Success="0"
                    elif [ "${Wizard_AliDDNSv3_NewAccessKeySecret_Retry}" = "N" ] || [ "${Wizard_AliDDNSv3_NewAccessKeySecret_Retry}" = "n" ]; then
                        Wizard_AliDDNSv3_NewAccessKeySecret_Success="1"
                    else
                        echo -e "\n"
                        echo -e "${Msg_Warning}你没有输入任何字符或者输入了错误的字符！"
                        sleep 2
                        Wizard_AliDDNSv3_NewAccessKeySecret_Success="0"
                    fi
                else
                    Wizard_AliDDNSv3_NewAccessKeySecret_Success="1"
                fi
            fi
        done
        echo -e "\n${Msg_Info}正在写入配置文件..."
        ModifyConfig "/etc/AliDDNSv3/AliDDNSv3.cfg" "AliDDNSv3_Config_AccessKeyID" "${Var_NewAccessKeyID}"
        ModifyConfig "/etc/AliDDNSv3/AliDDNSv3.cfg" "AliDDNSv3_Config_AccessKeySecret" "${Var_NewAccessKeySecret}"
        echo -e "${Msg_Success}写入成功！将于下一次执行AliDDNS时生效！请按任意键返回！"
        read -n 1
        clear
        Menu_AliDDNSv3_Configure
    fi
}

Configure_AliDDNSv3_Global_DDNSDomain() {
    clear
    echo -e "${Font_SkyBlue}AliDDNSv3${Font_Suffix}模块配置 - ${Font_Yellow}修改AK/SK${Font_Suffix}"
    echo -e "==================================================\n"
    echo -e "${Msg_Info}正在读取当前配置文件..."
    AliDDNSv3_Config_AccessKeyID="`ReadConfig "/etc/AliDDNSv3/AliDDNSv3.cfg" "AliDDNSv3_Config_AccessKeyID"`"
    AliDDNSv3_Config_AccessKeySecret="`ReadConfig "/etc/AliDDNSv3/AliDDNSv3.cfg" "AliDDNSv3_Config_AccessKeySecret"`"
    if [ "${AliDDNSv3_Config_AccessKeyID}" = "" ] || [ "${AliDDNSv3_Config_AccessKeySecret}" = "" ]; then
        echo -e "${Msg_Error}未检测到有效配置文件！请通过配置向导完成初始化配置！"
        read -n 1
        clear
        Menu_AliDDNSv3_Configure
    else
        while [ "${Configure_AliDDNSv3_Global_DDNSDomain_Success}" != 1 ]
        do
            Configure_AliDDNSv3_Global_DDNSDomain_Success="0"
            AliDDNSv3_Config_DomainName=""
            read -e -p "请输入你的域名: " AliDDNSv3_Config_DomainName
            if [ "${AliDDNSv3_Config_DomainName}" = "" ]; then
                echo -e "${Msg_Error}域名 此项参数必须填写 !"
                Configure_AliDDNSv3_Global_DDNSDomain_Success="0"
            else 
                AliDNSAPI_DescribeDomainInfo "${AliDDNSv3_Config_DomainName}" >/dev/null
                if [ "${AliDDNSv3_ReturnCode_SendRequest}" != "0" ]; then
                    echo -e "\n${Msg_Warning}你输入的域名似乎并没有在阿里云云解析旗下 (域名服务器尚在更换中;域名不存在)"
                    echo -e "    阿里云云解析API返回如下信息:\n${Msg_Debug}${Var_AliDNSAPI_RequestResult}\n"
                    read -e -p "是否要尝试重新输入域名 ? (Y/n)" Configure_AliDDNSv3_Global_DDNSDomain_Retry
                    if [ "${Configure_AliDDNSv3_Global_DDNSDomain_Retry}" = "Y" ] || [ "${Configure_AliDDNSv3_Global_DDNSDomain_Retry}" = "y" ]; then
                        echo -e "\n"
                        Configure_AliDDNSv3_Global_DDNSDomain_Success="0"
                    elif [ "${Configure_AliDDNSv3_Global_DDNSDomain_Retry}" = "N" ] || [ "${Configure_AliDDNSv3_Global_DDNSDomain_Retry}" = "n" ]; then
                        Configure_AliDDNSv3_Global_DDNSDomain_Success="1"
                    else
                        echo -e "${Msg_Warning}你没有输入任何字符或者输入了错误的字符！"
                        sleep 2
                        echo -e "\n"
                        Configure_AliDDNSv3_Global_DDNSDomain_Success="0"
                    fi
                else
                    Configure_AliDDNSv3_Global_DDNSDomain_Success="1"
                fi
            fi
        done
        Configure_AliDDNSv3_Global_DDNSDomain_Success="0"
        while [ "${Configure_AliDDNSv3_Global_DDNSDomain_Success}" != "1" ]
        do
            Configure_AliDDNSv3_Global_DDNSDomain_Success="0"
            AliDDNSv3_Config_SubDomainName=""
            read -e -p "请输入你的子域名: " AliDDNSv3_Config_SubDomainName
            if [ "${AliDDNSv3_Config_SubDomainName}" = "" ]; then
                echo -e "${Msg_Error}子域名 此项参数必须填写 !"
            else
                AliDNSAPI_DescribeSubDomainRecords "${AliDDNSv3_Config_SubDomainName}.${AliDDNSv3_Config_DomainName}" "A" "1" "1" >/dev/null
                if [ "${AliDNSAPI_RR}" = "null" ] || [ "${AliDNSAPI_Value}" = "null" ]; then
                    echo -e "${Msg_Warning}你输入的完整域名(${AliDDNSv3_Config_SubDomainName}.${AliDDNSv3_Config_DomainName})似乎没有存在的记录 (记录不存在;输入错误的域名)"
                    echo -e " 阿里云云解析API返回如下信息:\n${Msg_Debug}${Var_AliDNSAPI_RequestResult}"
                    echo -e ""
                    read -e -p "是否要自动添加此域名记录(建议前往阿里云官网手动添加) ? (Y/n) " Configure_AliDDNSv3_Global_DDNSDomain_AddRecordConfirm
                    if [ "${Configure_AliDDNSv3_Global_DDNSDomain_AddRecordConfirm}" = "Y" ] || [ "${Configure_AliDDNSv3_Global_DDNSDomain_AddRecordConfirm}" = "y" ]; then
                        echo -e "${Msg_Info}正在添加临时记录[${AliDDNSv3_Config_SubDomainName}.${AliDDNSv3_Config_DomainName} -> (A)127.0.0.1, TTL=600]"
                        AliDNSAPI_AddDomainRecord "${AliDDNSv3_Config_DomainName}" "${AliDDNSv3_Config_SubDomainName}" "A" "127.0.0.1" "600" "1" "default"
                        if [ "${AliDDNSv3_ReturnCode_SendRequest}" != "0" ]; then
                            echo -e "${Msg_Error}记录 [${AliDDNSv3_Config_SubDomainName}.${AliDDNSv3_Config_DomainName} -> (A)127.0.0.1, TTL=600] 添加失败 !"
                            echo -e "    阿里云云解析API返回如下信息:\n${Msg_Debug}${Var_AliDNSAPI_RequestResult}\n"
                            read -e -p "是否尝试重新输入 ? (Y/N) " Configure_AliDDNSv3_Global_DDNSDomain_AddRecordRetry     
                            if [ "${Configure_AliDDNSv3_Global_DDNSDomain_AddRecordRetry}" = "Y" ] || [ "${Configure_AliDDNSv3_Global_DDNSDomain_AddRecordRetry}" = "y" ]; then
                                echo -e "\n"
                                Configure_AliDDNSv3_Global_DDNSDomain_Success="0"
                            elif [ "${Configure_AliDDNSv3_Global_DDNSDomain_AddRecordRetry}" = "N" ] || [ "${Configure_AliDDNSv3_Global_DDNSDomain_AddRecordRetry}" = "n" ]; then
                                Configure_AliDDNSv3_Global_DDNSDomain_Success="1"
                            else
                                echo -e "\n"
                                Configure_AliDDNSv3_Global_DDNSDomain_Success="0"
                            fi
                        else
                            echo -e "${Msg_Success}临时域名记录添加成功! "
                            Configure_AliDDNSv3_Global_DDNSDomain_Success="1"
                        fi
                    elif [ "${Configure_AliDDNSv3_Global_DDNSDomain_AddRecordConfirm}" = "N" ] || [ "${Configure_AliDDNSv3_Global_DDNSDomain_AddRecordConfirm}" = "n" ]; then
                        read -e -p "是否尝试重新输入 ? (Y/N) " Configure_AliDDNSv3_Global_DDNSDomain_AddRecordRetry     
                        if [ "${Configure_AliDDNSv3_Global_DDNSDomain_AddRecordRetry}" = "Y" ] || [ "${Configure_AliDDNSv3_Global_DDNSDomain_AddRecordRetry}" = "y" ]; then
                            echo -e "\n"
                            Configure_AliDDNSv3_Global_DDNSDomain_Success="0"
                        elif [ "${Configure_AliDDNSv3_Global_DDNSDomain_AddRecordRetry}" = "N" ] || [ "${Configure_AliDDNSv3_Global_DDNSDomain_AddRecordRetry}" = "n" ]; then
                            Configure_AliDDNSv3_Global_DDNSDomain_Success="1"
                        else
                            echo -e "\n"
                            Configure_AliDDNSv3_Global_DDNSDomain_Success="0"
                        fi
                    else
                        echo -e "\n"
                        Configure_AliDDNSv3_Global_DDNSDomain_Success="0"
                    fi
                else
                    echo -e "\n${Msg_Info}检测到已存在的解析记录: "
                    echo -e "${Msg_Info}完整域名: ${AliDNSAPI_RR}.${AliDNSAPI_DomainName}"
                    echo -e "${Msg_Info}解析记录: [${AliDNSAPI_Type}] ${AliDNSAPI_Value} (TTL=${AliDNSAPI_TTL})"
                    echo -e "${Msg_Info}域名状态: ${AliDNSAPI_Status}"
                    echo -e ""
                    read -e -p "确定要使用此域名作为DDNS域名么? (y/N) " Configure_AliDDNSv3_Global_DDNSDomain_ExistRecordConfirm
                    if [ "${Configure_AliDDNSv3_Global_DDNSDomain_ExistRecordConfirm}" = "Y" ] || [ "${Configure_AliDDNSv3_Global_DDNSDomain_ExistRecordConfirm}" = "y" ]; then
                        echo -e "\n"
                        Configure_AliDDNSv3_Global_DDNSDomain_Success="1"
                    elif [ "${Configure_AliDDNSv3_Global_DDNSDomain_ExistRecordConfirm}" = "N" ] || [ "${Configure_AliDDNSv3_Global_DDNSDomain_ExistRecordConfirm}" = "n" ]; then
                        echo -e "\n"
                        Configure_AliDDNSv3_Global_DDNSDomain_Success="0"
                    else
                        echo -e "\n"
                        Configure_AliDDNSv3_Global_DDNSDomain_Success="0"
                    fi
                fi
            fi
        done
        echo -e "\n${Msg_Info}正在写入配置文件..."
        ModifyConfig "/etc/AliDDNSv3/AliDDNSv3.cfg" "AliDDNSv3_Config_DomainName" "${AliDDNSv3_Config_DomainName}"
        ModifyConfig "/etc/AliDDNSv3/AliDDNSv3.cfg" "AliDDNSv3_Config_SubDomainName" "${AliDDNSv3_Config_SubDomainName}"
        echo -e "${Msg_Success}写入成功！将于下一次执行AliDDNS时生效！请按任意键返回！"
        read -n 1
        clear
        Menu_AliDDNSv3_Configure
    fi
}

Test_AliDDNSv3_Init() {
    echo -e "${Font_SkyBlue}AliDDNSv3 调试模式${Font_Suffix} - ${Font_Yellow}正在初始化${Font_Suffix}"
    echo -e "=================================================="
    echo -e "\n正在初始化测试环境, 请稍后..."

    echo -e "${Msg_Info}正在检测系统必要环境 ..."
    Global_AliDDNSv3_CheckRoot
    Global_AliDDNSv3_CheckEnviroment
    Global_AliDDNSv3_InstallEnviroment
    if [ !-f "/etc/AliDDNSv3/AliDDNSv3.cfg" ] && [ !-f "/etc/AliDDNSv3/AliDDNSv3.cfg.lock" ]; then
        echo -e "${Msg_Error}未检测到有效配置文件, 请先使用配置向导生成配置文件 !"
        echo -e "${Msg_Fail}测试失败! (原因: 未检测到配置文件)"
    fi
}

Test_AliDDNSv3_WorkMode1_Connection() {
    clear
    Test_AliDDNSv3_Init
    clear
    echo -e "${Font_SkyBlue}AliDDNSv3 调试模式${Font_Suffix} - ${Font_Yellow}正在测试 工作模式1${Font_Suffix}"
    echo -e "=================================================="
    echo -e "\n正在测试 工作模式1, 请稍后...\n"
    echo -e "${Msg_Info}正在测试: 工作模式1 ..."
    echo -e "${Msg_Info}正在读取配置文件 ..."
    AliDDNSv3_Config_AccessKeyID="`ReadConfig "/etc/AliDDNSv3/AliDDNSv3.cfg" "AliDDNSv3_Config_AccessKeyID"`"
    AliDDNSv3_Config_AccessKeySecret="`ReadConfig "/etc/AliDDNSv3/AliDDNSv3.cfg" "AliDDNSv3_Config_AccessKeySecret"`"
    echo -e "${Msg_Info}正在检测本地到阿里云云解析API的连通性 ..."
    echo -e "${Msg_Info}(1/2) 正在测试: API功能调用 ..."    
    curl -s --connect-timeout 10 alidns.aliyuncs.com >/dev/null
    if [ "$?" != "0" ]; then
        echo -e "${Msg_Error}本地到阿里云云解析API - API功能调用测试失败 !"
        echo -e "${Msg_Warning}请检查网络设置后重试 !"
        exit 1
    else
        echo -e "${Msg_Info}API功能调用 测试通过 !"
    fi    
    echo -e "${Msg_Info}(2/2) 正在测试: AccessKey ID/AccessKey Secret 有效性 ..."
    AliDNSAPI_DescribeDnsProductInstances "1" "1"
    if [ "${AliDDNSv3_ReturnCode_SendRequest}" = "1" ]; then
        echo -e "${Msg_Error}测试请求发送失败! 可能是错误的AK/SK或者出现了其他异常问题! "
        echo -e "${Msg_Debug}阿里云云解析API返回结果:\n${Var_AliDNSAPI_RequestResult}\n\n"
        exit 1
    else
        echo -e "${Msg_Info}AccessKey ID/AccessKey Secret 有效性 测试通过 !"
        echo -e "${Msg_Success}测试成功! 请按任意键返回菜单! "
        read -n 1
        clear
        Menu_AliDDNSv3_Configure
    fi
}

Test_AliDDNSv3_WorkMode1_ReadWrite() {
    clear
    Test_AliDDNSv3_Init
    clear
    echo -e "${Font_SkyBlue}AliDDNSv3 调试模式${Font_Suffix} - ${Font_Yellow}正在测试 阿里云云解析API读写${Font_Suffix}"
    echo -e "=================================================="
    echo -e "\n正在测试 阿里云云解析API读写, 请稍后...\n"
    echo -e "${Msg_Info}正在读取配置文件 ..."
    AliDDNSv3_Config_AccessKeyID="`ReadConfig "/etc/AliDDNSv3/.AliDDNSv3.LastKnownGood.cfg" "AliDDNSv3_Config_AccessKeyID"`"
    AliDDNSv3_Config_AccessKeySecret="`ReadConfig "/etc/AliDDNSv3/.AliDDNSv3.LastKnownGood.cfg" "AliDDNSv3_Config_AccessKeySecret"`"
    AliDDNSv3_Config_DomainName="`ReadConfig "/etc/AliDDNSv3/.AliDDNSv3.LastKnownGood.cfg" "AliDDNSv3_Config_DomainName"`"
    # 测试1: 写入记录
    echo -e "${Msg_Info}(1/4) 正在测试: 阿里云云解析API - 写入记录 ..."
    echo -e "${Msg_Info}正在生成随机域名记录 ..."
    AliDDNSv3_Config_SubDomainName="aliddnsv3-test-${RANDOM}"
    echo -e "${Msg_Info}已生成随机域名记录: ${AliDDNSv3_Config_SubDomainName}.${AliDDNSv3_Config_DomainName}"
    echo -e "${Msg_Info}正在生成域名记录参数 ..."
    AliDDNSv3_Config_TTL="600"
    AliDDNSv3_Config_LocalIP="127.0.0.1"
    AliDDNSv3_Config_TargetIP="127.0.0.2"
    AliDDNSv3_Config_Type="A"
    echo -e "${Msg_Info}${AliDDNSv3_Config_SubDomainName}.${AliDDNSv3_Config_DomainName} -> [${AliDDNSv3_Config_Type}]${AliDDNSv3_Config_LocalIP} , TTL=${AliDDNSv3_Config_TTL}"
    echo -e "${Msg_Info}正在写入域名记录: ${AliDDNSv3_Config_SubDomainName}.${AliDDNSv3_Config_DomainName} ..."
    AliDNSAPI_Test_RequestId=""
    AliDNSAPI_Test_RecordId=""
    AliDNSAPI_AddDomainRecord "${AliDDNSv3_Config_DomainName}" "${AliDDNSv3_Config_SubDomainName}" "${AliDDNSv3_Config_Type}" "${AliDDNSv3_Config_LocalIP}" "${AliDDNSv3_Config_TTL}" "1" "default"
    AliDNSAPI_Test_RequestId="`PharseJSON "${Var_AliDNSAPI_RequestResult}" "RequestId"`"
    AliDNSAPI_Test_RecordId="`PharseJSON "${Var_AliDNSAPI_RequestResult}" "RecordId"`"
    if [ "${AliDNSAPI_Test_RecordId}" = "null" ]; then
        echo -e "${Msg_Error}写入记录测试 失败 !"
        echo -e "${Msg_Debug}阿里云云解析API返回信息: \n${Var_AliDNSAPI_RequestResult}\n"
        echo -e "${Msg_Fail}测试失败, 请按任意键返回上一级菜单 ..."
        read -n 1
        clear
        Menu_AliDDNSv3_Configure
    fi
    echo -e "${Msg_Info}阿里云云解析API返回RecordId: ${AliDNSAPI_Test_RecordId}"
    echo -e "${Msg_Info}写入记录测试成功 !"
    echo -e "${Msg_Info}请等待3秒钟后自动进行下一项测试! "
    sleep 3
    # 测试2: 读取记录
    echo -e "${Msg_Info}(2/4) 正在测试: 阿里云云解析API - 读取记录 ..."
    echo -e "${Msg_Info}使用上一步测试获取的RecordID: ${AliDNSAPI_Test_RecordId} 读取记录"
    AliDNSAPI_DescribeDomainRecordInfo "${AliDNSAPI_Test_RecordId}"
    if [ "${AliDNSAPI_RR}" = "null" ]; then
        echo -e "${Msg_Error}读取记录测试 失败 !"
        echo -e "${Msg_Debug}阿里云云解析API返回信息: \n${Var_AliDNSAPI_RequestResult}\n"
        echo -e "${Msg_Fail}测试失败, 请按任意键返回上一级菜单 ..."
        read -n 1
        clear
        Menu_AliDDNSv3_Configure
    fi
    echo -e "${Msg_Info}${AliDNSAPI_RecordId} -> ${AliDNSAPI_RR}.${AliDNSAPI_DomainName} -> [${AliDNSAPI_Type}]${AliDNSAPI_Value}"
    echo -e "${Msg_Info}读取记录测试成功 !"
    echo -e "${Msg_Info}请等待3秒钟后自动进行下一项测试! "
    sleep 3
    # 测试3: 修改记录
    echo -e "${Msg_Info}(3/4) 正在测试: 阿里云云解析API - 修改记录 ..."
    echo -e "${Msg_Info}使用上一步测试获取的RecordID: ${AliDNSAPI_Test_RecordId} 修改记录"
    AliDNSAPI_UpdateDomainRecord "${AliDNSAPI_Test_RecordId}" "${AliDDNSv3_Config_SubDomainName}" "${AliDDNSv3_Config_Type}" "${AliDDNSv3_Config_TargetIP}" "${AliDDNSv3_Config_TTL}" "1" "default"
    AliDNSAPI_Test_RequestId="`PharseJSON "${Var_AliDNSAPI_RequestResult}" "RequestId"`"
    AliDNSAPI_Test_RecordId="`PharseJSON "${Var_AliDNSAPI_RequestResult}" "RecordId"`"
    if [ "${AliDNSAPI_Test_RecordId}" = "null" ]; then
        echo -e "${Msg_Error}修改记录测试 失败 !"
        echo -e "${Msg_Debug}阿里云云解析API返回信息: \n${Var_AliDNSAPI_RequestResult}\n"
        echo -e "${Msg_Fail}测试失败, 请按任意键返回上一级菜单 ..."
        read -n 1
        clear
        Menu_AliDDNSv3_Configure
    fi
    echo -e "${Msg_Info}阿里云云解析API返回RecordId: ${AliDNSAPI_Test_RecordId}"
    echo -e "${Msg_Info}修改记录测试成功 !"
    echo -e "${Msg_Info}请等待3秒钟后自动进行下一项测试! "
    sleep 3
    # 测试4: 删除记录
    echo -e "${Msg_Info}(4/4) 正在测试: 阿里云云解析API - 修改记录 ..."
    echo -e "${Msg_Info}使用上一步测试获取的RecordID: ${AliDNSAPI_Test_RecordId} 删除记录"
    AliDNSAPI_DeleteDomainRecord "${AliDNSAPI_Test_RecordId}"
    AliDNSAPI_Test_RequestId="`PharseJSON "${Var_AliDNSAPI_RequestResult}" "RequestId"`"
    AliDNSAPI_Test_RecordId="`PharseJSON "${Var_AliDNSAPI_RequestResult}" "RecordId"`"
    if [ "${AliDNSAPI_Test_RecordId}" = "null" ]; then
        echo -e "${Msg_Error}删除记录测试 失败 !"
        echo -e "${Msg_Debug}阿里云云解析API返回信息: \n${Var_AliDNSAPI_RequestResult}\n"
        echo -e "${Msg_Fail}测试失败, 请按任意键返回上一级菜单 ..."
        read -n 1
        clear
        Menu_AliDDNSv3_Configure
    fi
    echo -e "${Msg_Info}阿里云云解析API返回RecordId: ${AliDNSAPI_Test_RecordId}"
    echo -e "${Msg_Info}删除记录测试成功 !"
    AliDNSAPI_Test_RequestId=""
    AliDNSAPI_Test_RecordId=""
    echo -e "\n${Msg_Success}所有测试全部成功! 请按任意键返回上一级菜单! "
    read -n 1
    clear
    Menu_AliDDNSv3_Configure
}

Test_AliDDNSv3_WorkMode2_Connection() {
    clear
    echo -e "${Font_SkyBlue}AliDDNSv3 调试模式${Font_Suffix} - ${Font_Yellow}正在测试 阿里云云解析API读写${Font_Suffix}"
    echo -e "=================================================="
    echo -e "\n正在测试 腾讯云HttpDNS解析, 请稍后...\n"
    echo -e "${Msg_Info}(1/2) 正在尝试解析 www.baidu.com ..."
    DnspodHttpDns_Result="`curl -s http://119.29.29.29/d?dn=www.baidu.com 2>&1`"
    if [ "${DnspodHttpDns_Result}" = "" ]; then
        echo -e "${Msg_Error}www.baidu.com 解析失败！"
    else
        echo -e "${Msg_Info}www.baidu.com -> ${DnspodHttpDns_Result}"
    fi
    echo -e "${Msg_Info}(2/2) 正在尝试解析 www.google.com ..."
    DnspodHttpDns_Result="`curl -s http://119.29.29.29/d?dn=www.google.com 2>&1`"
    if [ "${DnspodHttpDns_Result}" = "" ]; then
        echo -e "${Msg_Error}www.google.com 解析失败！"
    else
        echo -e "${Msg_Info}www.google.com -> ${DnspodHttpDns_Result}"
    fi
    echo -e "\n${Msg_Success}所有测试全部完成! 请按任意键返回上一级菜单! "
    read -n 1
    clear
    Menu_AliDDNSv3_Configure
}

Entrance_ServerChan_Configure() {
    Wizard_ServerChan_Configure_Step1
    Wizard_ServerChan_Configure_Step2
    clear
    Menu_MainMenu
}

ServerChan_SendMsg() {
    local ServerChan_Text="$1"
    local ServerChan_Content="$2"
    curl -s "http://sc.ftqq.com/$ServerChan_Config_SCKEY.send?text=${ServerChan_Text}" -d "&desp=${ServerChan_Content}" >/dev/null 2>&1
    if [ "$?" -eq "0" ]; then
        echo -e "\n${Msg_Success}[ServerChan] ServerChan推送成功! "
    else
        echo -e "${Msg_Warning}[ServerChan] ServerChan推送失败! "
    fi
}

Wizard_ServerChan_Configure_Step1() {
    clear
    echo -e "${Font_SkyBlue}ServerChan${Font_Suffix} 配置向导 (${Font_SkyBlue}1${Font_Suffix}/${Font_Green}2${Font_Suffix}) - ${Font_Yellow}配置SCKEY${Font_Suffix}"
    echo -e "=================================================="
    echo -e "\nSCKEY (ServerChan Key)即你在ServerChan平台上获取到的API密钥。向你的微信发送消息需要此密钥。
更多配置教程请参考：http://sc.ftqq.com \n"
    while [ "${Wizard_ServerChan_Configure_Step1_Success}" != 1 ]
    do
        Wizard_ServerChan_Configure_Step1_Success="0"
        ServerChan_Config_SCKEY=""
        read -e -p "请输入你的ServerChan SCKEY: " ServerChan_Config_SCKEY
        if [ "${ServerChan_Config_SCKEY}" = "" ]; then
            echo -e "${Msg_Error}ServerChan SCKEY 此项参数必须填写 !"
            Wizard_ServerChan_Configure_Step1_Success="0"
        else
            expr length ${ServerChan_Config_SCKEY} | grep -E "\b54\b" >/dev/null
            if [ "$?" != "0" ]; then
                echo -e "${Msg_Warning}你输入的AccessKey Secret似乎不是54位字符串 (长度: `expr length ${ServerChan_Config_SCKEY}`),"
                read -e -p "是否要尝试重新输入AccessKey Secret ? (Y/n)" Wizard_ServerChan_Configure_Step1_Retry
                if [ "${Wizard_ServerChan_Configure_Step1_Retry}" = "Y" ] || [ "${Wizard_ServerChan_Configure_Step1_Retry}" = "y" ]; then
                    echo -e "\n"
                    Wizard_ServerChan_Configure_Step1_Success="0"
                elif [ "${Wizard_ServerChan_Configure_Step1_Retry}" = "N" ] || [ "${Wizard_ServerChan_Configure_Step1_Retry}" = "n" ]; then
                    Wizard_ServerChan_Configure_Step1_Success="1"
                else
                    echo -e "${Msg_Warning}你没有输入任何字符或者输入了错误的字符！"
                    sleep 2
                    echo -e "\n"
                    Wizard_ServerChan_Configure_Step1_Success="0"
                fi
            else
                Wizard_ServerChan_Configure_Step1_Success="1"
            fi
        fi
    done
}

Wizard_ServerChan_Configure_Step2() {
    clear
    echo -e "${Font_SkyBlue}ServerChan${Font_Suffix} 配置向导 (${Font_SkyBlue}2${Font_Suffix}/${Font_Green}2${Font_Suffix}) - ${Font_Yellow}验证SCKEY有效性${Font_Suffix}"
    echo -e "=================================================="
    echo -e "\n为了确保ServerChan正确工作，程序将会通过ServerChan API向此SCKEY所绑定的微信发送一条验证码信息。
请根据收到的验证码，填写信息以完成验证。\n\n如果你暂时收不到验证码信息，或者不愿意进行验证配置，请输入"skip"跳过验证流程。\n"
    while [ "${Wizard_ServerChan_Configure_Step2_Success}" != 1 ]
    do
        ServerChan_IdentifyCode="`date +%N | cut -c 1-4`"
        echo -e "${Msg_Info}正在通过ServerChan API发送信息，请稍后..."
        ServerChan_SendMsg "AliDDNSv3_ServerChan配置验证" "您的验证码是：${ServerChan_IdentifyCode}，请填写到配置向导中以完成配置，感谢您对AliDDNS项目的支持。"
        echo -e " "
        read -e -p "请输入收到的验证码： " ServerChan_Verify
        if [ "${ServerChan_Verify}" = "skip" ] || [ "${ServerChan_Verify}" = "SKIP" ]; then
            echo -e "${Msg_Warning}已跳过ServerChan配置验证，如配置错误可能导致ServerChan无法使用! "
            sleep 2
            Wizard_ServerChan_Configure_Step2_Success="1"
        elif [ "${ServerChan_Verify}" = "${ServerChan_IdentifyCode}" ]; then
            echo -e "\n${Msg_Success}ServerChan验证成功! "
            sleep 2
            Wizard_ServerChan_Configure_Step2_Success="1"
        else
            echo -e "\n${Msg_Error}ServerChan验证失败!"
            sleep 2
            Wizard_ServerChan_Configure_Step2_Success="0"
            Wizard_ServerChan_Configure_Step1
        fi
    done
    Wizard_ServerChan_Configure_SetupandConfigure
}

Wizard_ServerChan_Configure_SetupandConfigure() {
    clear
    echo -e "ServerChan 配置向导 - 正在配置ServerChan"
    echo -e "=================================================="
    echo -e "\n请稍后，正在配置ServerChan...\n"
    if [ -f "/etc/AliDDNSv3/ServerChan.cfg" ] && [ -f "/etc/AliDDNSv3/ServerChan.cfg.lock" ]; then
        echo -e "${Msg_Info}已检测到存在的ServerChan配置文件"
        echo -e "${Msg_Info}正在备份当前配置文件..."
        rm -f /etc/AliDDNSv3/ServerChan.cfg.lock
        cp -f /etc/AliDDNSv3/ServerChan.cfg /etc/AliDDNSv3/ServerChan.cfg.bak
    else
        echo -e "${Msg_Info}正在创建配置文件目录..."
        mkdir -p /etc/AliDDNSv3/
    fi
    echo -e "${Msg_Info}正在写入配置文件..."
    rm -rf /tmp/.tmp_AliDDNSv3/
    mkdir -p /tmp/.tmp_AliDDNSv3/
    echo "ServerChan_Config_SCKEY="${ServerChan_Config_SCKEY}"" >> /tmp/.tmp_AliDDNSv3/ServerChan.cfg.tmp
    echo -e "${Msg_Info}正在停止运行中的AliDDNSv3进程..."
    nohup kill -9 `ps -aux | grep AliDDNSv3 | grep run | awk '{print $2}' | head -n1` >/dev/null 2>&1 &
    echo -e "${Msg_Info}正在写入ServerChan配置文件..."
    rm -f /etc/AliDDNSv3/ServerChan.cfg
    cp -f /tmp/.tmp_AliDDNSv3/ServerChan.cfg.tmp /etc/AliDDNSv3/ServerChan.cfg
    echo -e "${Msg_Info}正在清理临时文件..."
    rm -rf /tmp/.tmp_AliDDNSv3/
    touch /etc/AliDDNSv3/ServerChan.cfg.lock
    echo -e "${Msg_Success}成功配置ServerChan! "
    sleep 2
}

# 入口-AliDDNSv3-仅配置
Entrance_AliDDNSv3_ConfigureAndRun() {
    if [ "${Var_StartFromMenu}" != "1" ]; then
        echo -e "${Msg_Error}出于防止死循环保护的需要，请不要直接调用此参数！请通过配置菜单调用！"
        exit 1
    fi
    clear
    Entrance_AliDDNSv3_ConfigureOnly
    echo -e "${Msg_Info}3秒钟后开始执行AliDDNS !"
    sleep 3
    clear
    Entrance_AliDDNSv3_RunOnly
}

Entrance_AliDDNSv3_ConfigureOnly() {
    echo -e "\n${Msg_Info}正在初始化配置向导, 请稍后..."
    clear
    Wizard_AliDDNSv3_Configure_Init
    Wizard_AliDDNSv3_Configure_Step1
    Wizard_AliDDNSv3_Configure_Step2
    Wizard_AliDDNSv3_Configure_Step3
    Wizard_AliDDNSv3_Configure_Step4
    Wizard_AliDDNSv3_Configure_Step5
    Wizard_AliDDNSv3_Configure_Step6
    Wizard_AliDDNSv3_Configure_FinishConfirm
}

Entrance_AliDDNSv3_RunOnly(){
    clear
    AliDDNSv3_RunDDNS
}

# 入口-帮助文档
Entrance_HelpDocument() {
    echo -e "\n${Font_SkyBlue}AliDDNSv3${Font_Suffix} - A ${Font_Red}Revolution${Font_Suffix} of ${Font_SkyBlue}iLemonrain${Font_Suffix}'s ${Font_Yellow}AliDDNS${Font_Suffix} Script\n"
    echo -e "AliDDNSv3 阿里云云解析 - DDNS辅助工具"
    echo -e "使用教程请参考：https://example.com/aliddnsv3.html"
    echo -e "参数说明："
    echo -e "    menu                 显示主菜单 (默认选项)"
    echo -e "    config               启动配置向导 "
    echo -e "    run                  启动AliDDNS"
    echo -e "    aliddns-config       显示AliDDNS模块配置菜单"
    echo -e "    serverchan-config    显示ServerChan模块配置菜单 (开发中，暂不开放)"
    echo -e "    help, -h, --help     显示此帮助信息"
    echo -e "    donate               显示捐赠信息"
    echo -e ""
    echo -e "AliDDNS历经三个版本的迭代更新，独立开发实属不易。\n如果你觉得AliDDNS很好用，可以考虑下向我捐赠，就当是赞助我这条苦逼学生狗的生活费了(逃)"
    echo -e "捐赠方式请在菜单中选择捐赠选项，或者使用donate参数启动AliDDNS可见 OwO\n"
}

# 入口-退出
Entrance_Exit() {
    exit 0
}

# Menu_MainMenu
Menu_Header() {
    Var_StartFromMenu="1"
    echo -e ""
    echo -e "  *=======================================*"
    echo -e "  |                                       |"
    echo -e "  | ${Font_SkyBlue}AliDDNSv3${Font_Suffix} - 阿里云云解析 DDNS辅助工具 |"
    echo -e "  |                                       |"
    echo -e "  |   ${Font_SkyBlue}Written by${Font_Suffix} iLemonrain ${Font_SkyBlue}Version${Font_Suffix} 3.0   |"
    echo -e "  |     ${Font_SkyBlue}An Evolution of   AliDDNS 2.0${Font_Suffix} ${BuildTime}    |"
    echo -e "  |                                       |"
    echo -e "  *=======================================*"
    echo -e ""
    echo -e " ${Font_SkyBlue}版本:${Font_Suffix} ${Global_BuildTime}"
    echo -e " ${Font_SkyBlue}作者:${Font_Suffix} iLemonrain <ilemonrain@ilemonrain.com>"
    echo -e " ${Font_SkyBlue}Telegram:${Font_Suffix} @ilemonrain"
    echo -e " ${Font_SkyBlue}Telegram频道:${Font_Suffix} @ilemonrain_channel"
    echo -e ""
}

Menu_MainMenu(){
    Menu_Header
    sleep 1
    echo -e ""
    echo -e "  ${Font_Yellow}主菜单 > ${Font_Suffix}"
    echo -e " \n${Font_Purple}===== AliDDNS 模块 =====${Font_Suffix}"
    echo -e " 1. 配置并运行 ${Font_SkyBlue}AliDDNSv3${Font_Suffix}"
    echo -e " 2. 仅配置 ${Font_SkyBlue}AliDDNSv3${Font_Suffix}"
    echo -e " 3. 仅运行 ${Font_SkyBlue}AliDDNSv3${Font_Suffix}"
    echo -e " 4. ${Font_SkyBlue}AliDDNSv3${Font_Suffix} 模块设置"
    echo -e " \n${Font_Purple}===== ServerChan 模块 =====${Font_Suffix}"
    echo -e " 5. 配置 ${Font_SkyBlue}ServerChan${Font_Suffix}"
    echo -e " \n${Font_Purple}=====全局设置=====${Font_Suffix}"
    echo -e " ${Font_Red}6. 清理配置文件及重置环境${Font_Suffix}"
    echo -e " ${Font_Red}7. 安装/卸载/恢复出厂设置${Font_Suffix}"
    echo -e " ${Font_Red}8. 关于 AliDDNSv3${Font_Suffix}"
    echo -e " ${Font_Red}9. 求捐赠 OwO${Font_Suffix}"
    echo -e " 0. 退出"
    echo -e ""
    read -e -p " 请输入你的选择[0-9]: " Input_MainMenu
    expr $Input_MainMenu + 1 &>/dev/null
    if [ "$?" -ne "0" ]; then
        exit 1
    fi
    case $Input_MainMenu in
        1)
            Entrance_AliDDNSv3_ConfigureAndRun
            ;;
        2)
            Entrance_AliDDNSv3_ConfigureOnly
            ;;
        3)
            Entrance_AliDDNSv3_RunOnly
            ;;
        4)
            Menu_AliDDNSv3_Configure
            ;;
        5)
            Entrance_ServerChan_Configure
            ;;
        6)
            Menu_ServerChan_Configure
            ;;
        7)
            Entrance_Global_CleanEnviroment
            ;;
        8)
            Entrance_About_AliDDNSv3
            ;;
        9)
            Entrance_Donate
            ;;
        0)
            Entrance_Exit
            ;;
        *)
            clear
            echo -e "${Msg_Error}你的输入似乎有误...请输入0-9之间的数字 !"
            Menu_MainMenu
esac
}

Menu_AliDDNSv3_Configure(){
    clear
    echo -e "${Font_SkyBlue}主菜单${Font_Suffix} > ${Font_Yellow}AliDDNSv3 模块设置${Font_Suffix}"
    echo -e "=================================================="
    echo -e ""
    echo -e " ===== 工作模式参数 ====="
    echo -e " 1. 全局 - 修改AccessKey ID/AccessKey Secret"
    echo -e " 2. 全局 - 修改DDNS域名"
    echo -e " ${Font_Red}3. 工作模式3 - 修改DNS服务器配置${Font_Suffix}"
    echo -e " ===== 工作模式测试 ====="
    echo -e " 4. 工作模式1 - 测试阿里云云解析API连通性"
    echo -e " 5. 工作模式1 - 测试阿里云云解析API读写操作"
    echo -e " 6. 工作模式2 - 测试腾讯云HttpDNS连通性"
    echo -e " ${Font_Red}7. 工作模式3 - 测试域名解析连通性${Font_Suffix}"
    echo -e " "
    echo -e " 0. 返回上一级菜单"

    echo -e ""
    read -e -p " 请输入你的选择[0-10]: " Input_AliDDNSv3_Configure
    expr $Input_AliDDNSv3_Configure + 1 &>/dev/null
    if [ "$?" -ne "0" ]; then
        exit 1
    fi
    case $Input_AliDDNSv3_Configure in
        1)
            Configure_AliDDNSv3_Global_AKSK
            ;;
        2)
            Configure_AliDDNSv3_Global_DDNSDomain
            ;;
        3)
            exit 1
            Configure_AliDDNSv3_WorkMode3_DNSServer
            ;;
        4)
            Test_AliDDNSv3_WorkMode1_Connection
            ;;
        5)
            Test_AliDDNSv3_WorkMode1_ReadWrite
            ;;
        6)
            Test_AliDDNSv3_WorkMode2_Connection
            ;;
        7)
            exit 1
            Test_AliDDNSv3_WorkMode3_Connection
            ;;
        0)
            clear
            Menu_MainMenu
            ;;
        *)
            echo -e "${Msg_Error}你的输入似乎有误...请输入0-10之间的数字 !"
            sleep 2
            clear 
            Menu_AliDDNSv3_Configure
    esac
}

# 命令行参数
case "$1" in
    configandrun)
        Entrance_AliDDNSv3_ConfigureAndRun
        ;;
    configureandrun)
        Entrance_AliDDNSv3_ConfigureAndRun
        ;;
    config)
        Entrance_AliDDNSv3_ConfigureOnly
        ;;
    configure)
        Entrance_AliDDNSv3_ConfigureOnly
        ;;
    run)
        Entrance_AliDDNSv3_RunOnly
        ;;
    aliddns-config)
        Menu_AliDDNSv3_Configure
        ;;
    serverchan)
        Entrance_ServerChan_Configure
        ;;
    serverchan-config)
        Menu_ServerChan_Configure
        ;;
    clean)
        Entrance_Global_CleanEnviroment
        ;;
    about)
        Entrance_About_AliDDNSv3
        ;;
    donate)
        Entrance_Donate
        ;;
    iwannapaymore)
        Entrance_Donate
        ;;
    --help)
        Entrance_HelpDocument
        exit 0
        ;;    
    -h)
        Entrance_HelpDocument
        exit 0
        ;;    
    help)
        Entrance_HelpDocument
        exit 0
        ;;    
    *)
        clear
        Menu_MainMenu
        ;;
esac

# 全局程序入口
#clear
#Menu_MainMenu

