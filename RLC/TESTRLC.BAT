@echo  off
echo.

if not exist rlcdrvr.exe   goto error2

rem // verify the user typed the correct command
if %1. == .      goto errcmd

rem // verify the input and output file exist
if %1 == 1 goto usertest
if %1 == 2 goto usertest
if %1 == 3 goto usertest
goto errcmd

:usertest
if errorlevel 4 goto locked

rem // run the test
rlcdrvr %1
goto exit

:errcmd
echo.
echo To run a test type:
echo    testrlc n     ... where n is 1, 2 or 3
echo.
goto   exit

:errin
echo.
echo The input valid testcases are 1, 2, 3
echo.
goto   exit

:error2
echo.
echo The executable file 'rlcdrvr.exe' does not exist in this directory.
echo.
goto   exit

:locked
echo.
echo I can not access the required files.
echo Shutdown and reboot the system.
echo.
goto exit

:exit
echo.

