@echo off
for %%f in (*.aml) do (
    echo %%~f
    start /B "" "C:\Program Files\IASL\iasl.exe" %%~f
)