param([string]$d = "RR8W901JDRL")
$s = $PSScriptRoot
function tap($x, $y) { adb -s $d shell input tap $x $y | Out-Null }
function back() { adb -s $d shell input keyevent KEYCODE_BACK | Out-Null; Start-Sleep 2 }
function scrollDown() { adb -s $d shell input swipe 540 1700 540 900 600 | Out-Null }
function shot($n) { adb -s $d shell screencap -p /sdcard/s.png | Out-Null; adb -s $d pull /sdcard/s.png "$s\m_$n.png" | Out-Null }
$t0 = Get-Date
$log = @()
function mark($l) { $script:log += ("{0} {1:N1}" -f $l, ((Get-Date) - $t0).TotalSeconds) }

adb -s $d shell "nohup screenrecord --time-limit 170 --bit-rate 8000000 /sdcard/rec4.mp4 >/dev/null 2>&1 &"
$t0 = Get-Date
Start-Sleep 2
mark "daily"; tap 778 1462; Start-Sleep 5; shot daily; scrollDown; Start-Sleep 3; back
mark "season"; tap 301 1687; Start-Sleep 5; shot season; scrollDown; Start-Sleep 3; back
mark "ranks"; tap 778 1687; Start-Sleep 6; shot ranks; back
mark "store"; tap 301 1912; Start-Sleep 5; shot store; scrollDown; Start-Sleep 3; back
mark "powerups"; tap 778 1912; Start-Sleep 5; shot powerups; back
mark "versus"; tap 301 1462; Start-Sleep 6; shot versus; back
mark "end"
Start-Sleep 2
adb -s $d shell pkill -INT screenrecord | Out-Null; Start-Sleep 3
adb -s $d pull /sdcard/rec4.mp4 "$s\rec4.mp4" | Out-Null
$log
