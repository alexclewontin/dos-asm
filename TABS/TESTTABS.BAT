@echo  off
echo.

rem // verify files exist and are valid
if not exist gradcpy.bat   goto error1
if not exist tabs.exe      goto error2

if not exist %1 goto errin

if %2. == . goto usertest
if %2  == 1 goto usertest
if %2  == 2 goto usertest
if %2  == 3 goto usertest
if %2  == 4 goto usertest
if %2  == 5 goto usertest
if %2  == 6 goto usertest
if %2  == 7 goto usertest
if %2  == 8 goto usertest
if %2  == 9 goto usertest
goto errcmd

:usertest
if errorlevel 4 goto locked

call gradcpy.bat %1+EOF grad.tmp
echo.
echo. To be safe, I added a DOS end_of_file character to %1
echo. and stored the result in grad.tmp which is being used
echo. as the input to the tabs program.
echo.
echo The program's input:
    type grad.tmp
echo.
echo The program's output:
    tabs %2 < grad.tmp
echo.

echo.
goto exit

:errcmd
echo.
echo To run a test type:
echo    testtabs  input_file
echo    testtabs  input_file  n  ... where n is the tab stop position 1 to 9
echo.
goto   exit

:errin
echo.
echo The input file specified: %1 does not exist.
echo.
goto   exit

:error1
echo.
echo The batch file 'gradcpy.bat' does not exist in this directory.
echo.
goto   exit

:error2
echo.
echo The executable file 'tabs.exe' does not exist in this directory.
echo.
goto   exit

:locked
echo.
echo I cannot access the required files.
echo Shutdown and reboot the system.
echo If the problem persists contact the instructor.
echo.
goto exit

:exit
if exist gradjunk erase gradjunk
echo.

