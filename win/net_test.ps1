Add-Type -AssemblyName System.Net.Http

$result_filedir = "~/Desktop"
$result_filename = "AkerunRemote�ڑ��v���m�F����.log"

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
write_text "    Akerun Remote�ʐM�m�F����"
write_text "                              software v0.6"
write_text "*********************************************"

Write-Host "`r`n"
echo "              !!!! ������ !!!!"
echo "�K���AAkerun Remote�֐ݒ肷�邲�\��̃l�b�g���[�N��"
echo "�����l�b�g���[�N�֐ڑ����������ŁA���̃v���O������"
echo "���s���Ă��������B"
Read-Host "Enter�L�[�ŊJ�n���܂�"

write_text "`r`n"
write_text "Wi-Fi �ڑ������m�F"
write_text "================="
echo "Akerun Remote�ɐݒ肷��Wi-Fi�l�b�g���[�N������͂��Ă��������B"
$ssid = Read-Host "�L���ڑ��̏ꍇ�͂��̂܂�Enter�L�[�������Ă��������B"
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
write_text "tcp�ڑ��m�F"
write_text "================="
for( $i=0; $i -lt $hostary.length; $i++ ){
    write_text "$($hostary[$i]):$($portary[$i]) ���m�F��..."

    $tcp = New-Object System.Net.Sockets.tcpClient
    $tcp.connect( $hostary[$i], $portary[$i] )
    sleep 2
    if( $tcp.connected ){
        write_text "�ڑ��\"
    }else{
        write_text "�ڑ����s"
        write_text "�T�[�o�[�F$($hostary[$i])��IP�t�B���^�����O���Ă��Ȃ����m�F�������B"
        write_text "�|�[�g�FTCP $($portary[$i])�Ԃ��������Ă��邩�m�F�������B"
    }
    $tcp.Dispose()
}

#Check UDP connection
write_text "`r`n"
write_text "udp�ڑ��m�F"
write_text "================="
$udphostary = @("0.debian.pool.ntp.org","1.debian.pool.ntp.org","2.debian.pool.ntp.org","3.debian.pool.ntp.org")
for( $i=0; $i -lt $udphostary.length; $i++ ){
    write_text "$($udphostary[$i]):123 ���m�F��..."

    $udp = New-Object System.Net.Sockets.udpClient
    $udp.connect( $udphostary[$i], "123" )
    sleep 2
    if( $udp.client.connected ){
        write_text "�ڑ��\"
    }else{
        write_text "�ڑ����s"
        write_text "�T�[�o�[�F$($hostary[$i])��IP�t�B���^�����O���Ă��Ȃ����m�F�������B"
        write_text "�|�[�g�FUDP $($portary[$i])�Ԃ��������Ă��邩�m�F�������B"
    }
    $udp.Dispose()
}

#Check ping
write_text "`r`n"
write_text "ping 8.8.8.8 20��@�m�F��...."
$pingresult = ping -n 20 8.8.8.8
$pingstr1 = $pingresult -match "����"
write_text $pingstr1
$pingstr2 = $pingresult -match "�ŏ�"
write_text $pingstr2

$pinglost = $pingresult -match "100% �̑���"
if( $pinglost.length -eq 1 ){
    write_text "ping��������Ă��邩���m�F���������B"
}else{
    write_text "ping 8.8.8.8 �L��"
}

#Check ping 2
write_text "`r`n"
write_text "ping 8.8.4.4 20��@�m�F��...."
$pingresult2 = ping -n 20 8.8.4.4
$pingstr3 = $pingresult2 -match "����"
write_text $pingstr3
$pingstr4 = $pingresult2 -match "�ŏ�"
write_text $pingstr4

$pinglost2 = $pingresult2 -match "100% �̑���"
if( $pinglost2.length -eq 1 ){
    write_text "ping��������Ă��邩���m�F���������B"
}else{
    write_text "ping 8.8.4.4 �L��"
}

#Check Rest API communication
write_text "`r`n"
write_text "API�T�[�o�[�Ƃ̒ʐM�e�X�g��..."
$hc = New-Object System.Net.Http.HttpClient
$stream = $hc.GetAsync(�ghttps://api.akerun.com/v2/app_version�h)
sleep 5
if( $stream.Result.StatusCode -eq "OK" ){
    write_text "����Ɋ������܂���"
}else{
    write_text "�ʐM�Ɏ��s�����\��������̂ŁA�m�F���K�v�ƂȂ�܂��B"
    $status_code = "StatusCode:" + $stream.Result.StatusCode
    write_text $status_code
�@�@write_log $stream
}


write_text "`r`n"
write_text "�ʐM�e�X�g�������܂����B"


write_log "`r`n"
write_log "********************************************************************"
write_log "   �{�t�@�C�����A���Ђ���̗v���ɉ����ĒʐM�m�F���ʂ̏؜߂Ƃ���"
write_log "   �����蒸���ꍇ���������܂��B"
write_log "********************************************************************"

#Open result log with notepad
$path = Resolve-Path -Path $result_filedir/$result_filename
notepad.exe $path.Path

#Read-Host "��������ɂ�ENTER�L�[�������ĉ������B"
