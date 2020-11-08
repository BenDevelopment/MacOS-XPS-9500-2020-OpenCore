@echo off
for %%f in (*.dsl) do (
    echo %%~f
    start /B "" "C:\Program Files\IASL\iasl.exe" %%~f
)