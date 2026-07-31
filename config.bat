@echo off
REM Shared QGISDevKit paths - edit this file only.
REM Values use Windows paths; qgis.sh converts them via cygpath.

if not defined OSGEO4W_ROOT set "OSGEO4W_ROOT=C:\OSGeo4W"
if not defined VCSDK set "VCSDK=10.0.26100.0"
if not defined SRCDIR set "SRCDIR=D:\MyResearch\QGIS\qgis"
if not defined BUILDDIR set "BUILDDIR=C:\qgis-build"
if not defined INSTDIR set "INSTDIR=C:\QGIS"
if not defined P set "P=qgis-dev"
if not defined CC set "CC=cl.exe"
if not defined CXX set "CXX=cl.exe"
