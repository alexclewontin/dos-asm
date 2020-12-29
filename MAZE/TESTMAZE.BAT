@echo  off
echo.

rem // verify files exist
if not exist mazedrvr.exe  goto error2

rem // verify the user typed the correct command
if %1. == .      goto errcmd

rem // verify the input and output file exist
if not exist %1            goto errin

:usertest
if errorlevel 4 goto locked

rem // run the test
:readmaze
mazedrvr %2 < %1
goto exit

:errcmd
echo.
echo To run a test type:
echo    testmaze.bat  input_file
echo.
goto   exit

:errin
echo.
echo The input file specified: %1 does not exist.
echo.
goto   exit

:error2
echo.
echo The executable file 'mazedrvr.exe' does not exist in this directory.
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
