#!/bin/bash

WIFI_SCAN_COMMAND="/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -s"
RESULT_LOG_FPATH=/Users/`whoami`/Desktop/akerun_net_check.log
TMP_LOG=/tmp/net_test.log
PING_TARGET=8.8.8.8
PING_TARGET_2=8.8.4.4


declare -a TCP_SERVER=( \
  "api.akerun.com" \
  "broker.akerun.com" \
  "tg2repo.akerun.com" \
  "tg3repo.akerun.com" \
  "tg4repo.akerun.com" \
)

declare -a TCP_SERVER_PORT=( \
  "443" \
  "8883" \
  "80" \
  "80" \
  "80" \
  "80" \
)

declare -a UDP_SERVER=( \
  "0.debian.pool.ntp.org" \
  "1.debian.pool.ntp.org" \
  "2.debian.pool.ntp.org" \
  "3.debian.pool.ntp.org" \
)


function writelog () {
  echo $1 >> $RESULT_LOG_FPATH
}

function writetext () {
  echo $1 | tee -a $RESULT_LOG_FPATH
}

function resultConnectionTest () {

  SERVER=$1
  PORT=$2
  IS_CONNECTED=""
  RETRY_COUNT=0

  while true
  do
    sleep 1
    IS_CONNECTED=`grep "${SERVER}.*${PORT}.*succeeded!" $TMP_LOG`
    [ -n "$IS_CONNECTED" ] && break;
    RETRY_COUNT=`expr $RETRY_COUNT + 1`
    [ $RETRY_COUNT -ge 15 ] && break;
  done

  echo $IS_CONNECTED

}

# Remove previous log file
rm ${RESULT_LOG_FPATH}

writelog "##############################################"
writelog "         Akerun Remote通信確認結果"
writelog "                              software v0.1"
writelog "##############################################"
writelog ''
writelog ''

osascript -e "display alert \"!!!! ご注意 !!!!\" message \"必ず、Akerun Remoteへ設定するご予定のネットワークと\n同じネットワークへ接続したうえで、このプログラムを\n実行してください。\""

writetext "##############################################"
writetext "# ネットワーク種別 確認"
echo "Akerun Remoteに設定するネットワーク接続の種類を選択してください"
while :
do
  echo "1. LANケーブル"
  echo "2. Wi-Fi"
  echo "\"1\"か\"2\"を入力ください"
  echo -n "> "
  read NET_TYPE
  [ "${NET_TYPE}" = "1" -o "${NET_TYPE}" = "2" ] && break;
done

if [ ${NET_TYPE} = "2" ]; then
  echo "Wi-Fiの 暗号化方式/認証方式 を確認します。"
  echo "設定されるWi-FiのSSIDを入力してください。"

  while :
  do
    echo -n "> "
    read SSID
    [ -n "$SSID" ] && break;
  done

  echo "SSID情報の確認中..."
  writetext "[[ SSID情報 ]]"
  writetext "入力SSID名 : ${SSID}"
  writetext "SSID名    MACアドレス   電波強度   チャンネル    認証方式(暗号化方式)"
  $WIFI_SCAN_COMMAND | grep $SSID | sed 's/^ *//g' | tee -a ${RESULT_LOG_FPATH}
else
  writetext "LANケーブルを利用のため　確認必要なし"
fi

writelog ''
writelog ''

writetext "##############################################"
writetext "# TCP 接続確認"
for i in ${!TCP_SERVER[@]}; do
  server=${TCP_SERVER[$i]}
  port=${TCP_SERVER_PORT[$i]}

  writetext "${server}:${port}への接続確認中..."
  nc -v ${server} ${port} 2>&1 | tee $TMP_LOG > /dev/null &

  RESULT=`resultConnectionTest ${server} ${port}`
  if [ -n "$RESULT" ]; then writetext "接続成功!"
  else                      writetext "接続失敗..."
  fi

  pkill -f "nc -v" && pkill -f "tee"
done
writelog ''
writelog ''

writetext "###############################################"
writetext "# UDP 接続確認"
for i in ${!UDP_SERVER[@]}; do
  server=${UDP_SERVER[$i]}
  port="123"

  writetext "${server}:${port}への接続確認中..."
  nc -uv ${server} ${port} 2>&1 | tee $TMP_LOG > /dev/null &

  RESULT=`resultConnectionTest ${server} ${port}`
  if [ -n "${RESULT}" ]; then writetext "接続成功!"
  else                      writetext "接続失敗..."
  fi

  pkill -f "nc -uv" && pkill -f "tee"
done
writelog ''
writelog ''


writetext "###############################################"
writetext "# ping 確認"
writetext "${PING_TARGET}への ping 確認中..."
ping -c 20 ${PING_TARGET} | tee -a $RESULT_LOG_FPATH
writelog ''
writetext "${PING_TARGET_2}への ping 確認中..."
ping -c 20 ${PING_TARGET_2} | tee -a $RESULT_LOG_FPATH
writelog ''


writetext "###############################################"
writetext "# 実際のAPI通信確認"
writetext "APIサーバーへの通信確認中..."
curl -vs -i -m 10 https://api.akerun.com/v2/app_version >/tmp/api_comm_result 2>&1
RESULT=`grep -E "(Status|HTTP).*200" /tmp/api_comm_result`

cat /tmp/api_comm_result >> $RESULT_LOG_FPATH
writelog ''
writelog ''

if [ -n "$RESULT" ]; then
  writetext "接続成功!"
else
  writetext "接続失敗..."
fi
writelog ''
writelog ''

writelog "########################################################"
writelog "   本ファイルを、弊社からの要請に応じて通信確認結果の証憑として"
writelog "   お送り頂く場合がございます。"
writelog "########################################################"

echo ''
echo '通信テスト完了しました。'
echo '何かキーを押すと終了します。'
read WAIT_ANYKEY

open -a TextEdit $RESULT_LOG_FPATH

exit 0;
