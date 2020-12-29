@echo  off
echo.

rem // verify files exist and are valid
if not exist linkdrvr.exe  goto error2

:usertest
if errorlevel 4 goto locked

echo.
echo   Program output:
linkdrvr  0
goto exit

:errcmd
echo.
echo To run a test type:
echo    testlink
goto   exit

:error2
echo.
echo The executable file 'linkdrvr.exe' does not exist in this directory.
echo.
goto   exit

:locked
echo.
echo I can not access the required files.
echo Shutdown and reboot the system.
echo If the problem persists contact the instructor.
echo.
goto exit

:exit
echo.

