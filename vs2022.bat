set O4W_ROOT=C/OSGeo4W
call "%O4W_ROOT%\bin\o4w_env.bat"

set BUILDDIR=D:\QGISBuild
"C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe" "%BUILDDIR%\qgis.sln"
