param([string]$d = "RR8W901JDRL")
$s = $PSScriptRoot
function tap($x, $y) { adb -s $d shell input tap $x $y | Out-Null }
function quitRun() { adb -s $d shell input keyevent KEYCODE_BACK | Out-Null; Start-Sleep 2; tap 737 1315; Start-Sleep 3 }

# home (from game over), ready on mode 1
tap 539 1928; Start-Sleep 3
adb -s $d shell "nohup screenrecord --time-limit 178 --bit-rate 8000000 /sdcard/rec2.mp4 >/dev/null 2>&1 &"
Start-Sleep 2
$log = @()
# Zen (mode 2)
tap 817 1265; Start-Sleep 2; tap 539 954; $log += "zen start $(Get-Date -Format HH:mm:ss)"; Start-Sleep 36; quitRun
# Speed Challenge (mode 3)
tap 817 1265; Start-Sleep 2; tap 539 954; $log += "speed start $(Get-Date -Format HH:mm:ss)"; Start-Sleep 36; quitRun
# Multi-Food (mode 4)
tap 817 1265; Start-Sleep 2; tap 539 954; $log += "multi start $(Get-Date -Format HH:mm:ss)"; Start-Sleep 36; quitRun
# Power-Up Madness (mode 7)
tap 817 1265; Start-Sleep 1; tap 817 1265; Start-Sleep 1; tap 817 1265; Start-Sleep 2; tap 539 954; $log += "madness start $(Get-Date -Format HH:mm:ss)"
Start-Sleep 40
adb -s $d shell pkill -INT screenrecord | Out-Null; Start-Sleep 3
adb -s $d pull /sdcard/rec2.mp4 "$s\rec2.mp4" | Out-Null
adb -s $d shell screencap -p /sdcard/s.png; adb -s $d pull /sdcard/s.png "$s\s8.png" | Out-Null
$log
