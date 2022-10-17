Add-Type -AssemblyName System.Net.Http

$result_filedir = "~/Desktop"
$result_filename = "AkerunRemote接続要件確認結果.log"

function write_log( $str ){
#    Write-Output "$str" | Add-Content $result_filedir/$result_filename -Encoding UTF8
    $str >> $result_filedir/$result_filename
}

function write_text( $str ){
    write_log $str
    echo $str
}

if( Test-Path $result_filedir/$result_filename ){
    Remove-Item $result_filedir/$result_filename
}

write_text "*********************************************"
write_text "    Akerun Remote通信確認結果"
write_text "                              software v0.6"
write_text "*********************************************"

Write-Host "`r`n"
echo "              !!!! ご注意 !!!!"
echo "必ず、Akerun Remoteへ設定するご予定のネットワークと"
echo "同じネットワークへ接続したうえで、このプログラムを"
echo "実行してください。"
Read-Host "Enterキーで開始します"

write_text "`r`n"
write_text "Wi-Fi 接続方式確認"
write_text "================="
echo "Akerun Remoteに設定するWi-Fiネットワーク名を入力してください。"
$ssid = Read-Host "有線接続の場合はそのままEnterキーを押してください。"
$wifi = netsh wlan show networks

if( $ssid.length -gt 0 )
{
    for( $i=0; $i -lt $wifi.length; $i++ ){
        if( $wifi[$i] -match $ssid ){
            write_text $wifi[$i]
            write_text $wifi[$i+2]
            write_text $wifi[$i+3]
        }
    }
}

$hostary = @(
    "broker.akerun.com",
    "api.akerun.com",
    "cdn.debian.or.jp",
    "tg2repo.akerun.com",
    "tg3repo.akerun.com",
    "tg4repo.akerun.com")
$portary = @("8883","443","80","80","80","80")

# Check TCP connection
#Write-Host "`r`n"
write_text "`r`n"
write_text "tcp接続確認"
write_text "================="
for( $i=0; $i -lt $hostary.length; $i++ ){
    write_text "$($hostary[$i]):$($portary[$i]) を確認中..."

    $tcp = New-Object System.Net.Sockets.tcpClient
    $tcp.connect( $hostary[$i], $portary[$i] )
    sleep 2
    if( $tcp.connected ){
        write_text "接続可能"
    }else{
        write_text "接続失敗"
        write_text "サーバー：$($hostary[$i])をIPフィルタリングしていないか確認下さい。"
        write_text "ポート：TCP $($portary[$i])番が解放されているか確認下さい。"
    }
    $tcp.Dispose()
}

#Check UDP connection
write_text "`r`n"
write_text "udp接続確認"
write_text "================="
$udphostary = @("0.debian.pool.ntp.org","1.debian.pool.ntp.org","2.debian.pool.ntp.org","3.debian.pool.ntp.org")
for( $i=0; $i -lt $udphostary.length; $i++ ){
    write_text "$($udphostary[$i]):123 を確認中..."

    $udp = New-Object System.Net.Sockets.udpClient
    $udp.connect( $udphostary[$i], "123" )
    sleep 2
    if( $udp.client.connected ){
        write_text "接続可能"
    }else{
        write_text "接続失敗"
        write_text "サーバー：$($hostary[$i])をIPフィルタリングしていないか確認下さい。"
        write_text "ポート：UDP $($portary[$i])番が解放されているか確認下さい。"
    }
    $udp.Dispose()
}

#Check ping
write_text "`r`n"
write_text "ping 8.8.8.8 20回　確認中...."
$pingresult = ping -n 20 8.8.8.8
$pingstr1 = $pingresult -match "損失"
write_text $pingstr1
$pingstr2 = $pingresult -match "最小"
write_text $pingstr2

$pinglost = $pingresult -match "100% の損失"
if( $pinglost.length -eq 1 ){
    write_text "pingが許可されているかご確認ください。"
}else{
    write_text "ping 8.8.8.8 有効"
}

#Check ping 2
write_text "`r`n"
write_text "ping 8.8.4.4 20回　確認中...."
$pingresult2 = ping -n 20 8.8.4.4
$pingstr3 = $pingresult2 -match "損失"
write_text $pingstr3
$pingstr4 = $pingresult2 -match "最小"
write_text $pingstr4

$pinglost2 = $pingresult2 -match "100% の損失"
if( $pinglost2.length -eq 1 ){
    write_text "pingが許可されているかご確認ください。"
}else{
    write_text "ping 8.8.4.4 有効"
}

#Check Rest API communication
write_text "`r`n"
write_text "APIサーバーとの通信テスト中..."
$hc = New-Object System.Net.Http.HttpClient
$stream = $hc.GetAsync(“https://api.akerun.com/v2/app_version”)
sleep 5
if( $stream.Result.StatusCode -eq "OK" ){
    write_text "正常に完了しました"
}else{
    write_text "通信に失敗した可能性があるので、確認が必要となります。"
    $status_code = "StatusCode:" + $stream.Result.StatusCode
    write_text $status_code
　　write_log $stream
}


write_text "`r`n"
write_text "通信テスト完了しました。"


write_log "`r`n"
write_log "********************************************************************"
write_log "   本ファイルを、弊社からの要請に応じて通信確認結果の証憑として"
write_log "   お送り頂く場合がございます。"
write_log "********************************************************************"

#Open result log with notepad
$path = Resolve-Path -Path $result_filedir/$result_filename
notepad.exe $path.Path

#Read-Host "完了するにはENTERキーを押して下さい。"
