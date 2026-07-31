call "%~dp0config.bat"

if defined PROGRAMFILES(X86) set PF86=%PROGRAMFILES(X86)%
if not defined PF86 set PF86=%PROGRAMFILES%
if not defined PF86 (echo PROGRAMFILES not set & goto error)

set VCARCH=amd64
set SETUPAPI_LIBRARY=%PF86%\Windows Kits\10\Lib\%VCSDK%\um\x64\SetupAPI.Lib
set DBGHLP_PATH=%PF86%\Windows Kits\10\Debuggers\x64

if not exist "%SETUPAPI_LIBRARY%" (
  echo SETUPAPI_LIBRARY not found
  dir /s /b "%PF86%\setupapi.lib"
  goto error
)

if not exist "%DBGHLP_PATH%\dbghelp.dll" (
  echo dbghelp.dll not found
  dir /s /b "%PF86%\dbghelp.dll" "%PF86%\symsrv.dll"
  goto error
)

if not exist "%OSGEO4W_ROOT%\bin\o4w_env.bat" (echo o4w_env.bat not found & goto error)
call "%OSGEO4W_ROOT%\bin\o4w_env.bat"

for %%e in (Community Professional Enterprise) do if exist "%PROGRAMFILES%\Microsoft Visual Studio\2022\%%e" set vcdir=%PROGRAMFILES%\Microsoft Visual Studio\2022\%%e
if not defined vcdir (echo Visual C++ not found & goto error)

set VS170COMNTOOLS=%vcdir%\Common7\Tools
call "%vcdir%\VC\Auxiliary\Build\vcvarsall.bat" %VCARCH% %VCSDK%
path %path%;%vcdir%\VC\bin

set GRASS=
if exist "%OSGEO4W_ROOT%\bin\grass85.bat" set GRASS=%OSGEO4W_ROOT%\bin\grass85.bat
if not defined GRASS if exist "%OSGEO4W_ROOT%\bin\grass84.bat" set GRASS=%OSGEO4W_ROOT%\bin\grass84.bat
if not defined GRASS if exist "%OSGEO4W_ROOT%\bin\grass83.bat" set GRASS=%OSGEO4W_ROOT%\bin\grass83.bat
if defined GRASS (
  for /f "usebackq tokens=1" %%a in (`"%GRASS%" --config path`) do set GRASS_PREFIX=%%a
  echo Using GRASS: %GRASS%
) else (
  echo GRASS not found; continuing without GRASS
)

set PYTHONPATH=
if exist "%PROGRAMFILES%\CMake\bin" path %PROGRAMFILES%\CMake\bin;%PATH%
if exist "%PF86%\CMake\bin" path %PF86%\CMake\bin;%PATH%
if exist c:\cygwin64\bin path %PATH%;c:\cygwin64\bin
if exist c:\cygwin\bin path %PATH%;c:\cygwin\bin

set LIB=%LIB%;%OSGEO4W_ROOT%\apps\Qt6\lib;%OSGEO4W_ROOT%\lib
set INCLUDE=%INCLUDE%;%OSGEO4W_ROOT%\apps\Qt6\include;%OSGEO4W_ROOT%\include

goto end

:usage
echo usage: %0
exit /b 1

:error
echo ENV ERROR %ERRORLEVEL%: %DATE% %TIME%
exit /b 1

:end
