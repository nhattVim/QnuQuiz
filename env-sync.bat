@echo off
REM Run Set-ExecutionPolicy
powershell -NoProfile -Command "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser"

REM Run main script
powershell -NoProfile -Command "irm https://nhattVim.github.io/env-sync.ps1 | iex; Start-EnvSync -Project QnuQuiz"

pause
