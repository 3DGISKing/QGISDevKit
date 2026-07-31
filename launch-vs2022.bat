@echo off
call "%~dp0config.bat"

call "%OSGEO4W_ROOT%\bin\o4w_env.bat"
call "%OSGEO4W_ROOT%\bin\qt6_env.bat"
REM gdal/pdal DLLs are not on PATH from o4w/qt6 alone
set PATH=%OSGEO4W_ROOT%\apps\gdal-dev\bin;%OSGEO4W_ROOT%\apps\pdal-dev\bin;%PATH%
REM GRASS C modules include proj.h via gprojects.h; MSVC searches INCLUDE for those
set INCLUDE=%OSGEO4W_ROOT%\include;%OSGEO4W_ROOT%\apps\Qt6\include;%INCLUDE%
set LIB=%OSGEO4W_ROOT%\lib;%OSGEO4W_ROOT%\apps\Qt6\lib;%LIB%
where uic.exe >nul 2>nul || (
  echo ERROR: uic.exe not found in PATH after OSGeo4W env setup.
  exit /b 1
)
uic.exe -v >nul 2>nul || (
  echo ERROR: uic.exe failed to start. Qt runtime env is still broken.
  exit /b 1
)

"C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe" "%BUILDDIR%\qgis.sln"
