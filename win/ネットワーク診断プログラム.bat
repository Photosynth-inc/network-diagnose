@echo off

powershell -NoProfile -ExecutionPolicy Unrestricted .\net_test.ps1
echo 完了するにはENTERキーを押して下さい。
pause > nul

exit