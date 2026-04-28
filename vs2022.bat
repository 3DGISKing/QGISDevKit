set O4W_ROOT=C:\OSGeo4W
call "%O4W_ROOT%\bin\o4w_env.bat"
where uic.exe >nul 2>nul || (
  echo ERROR: uic.exe not found in PATH after OSGeo4W env setup.
  exit /b 1
)
uic.exe -v >nul 2>nul || (
  echo ERROR: uic.exe failed to start. Qt runtime env is still broken.
  exit /b 1
)

set BUILDDIR=D:\QGISBuild
"C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe" "%BUILDDIR%\qgis.sln"
