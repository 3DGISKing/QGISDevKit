### Building QGIS on Windows is definitively lacking of a good and shared documentation. So I hope you study awesome algorithms of QGIS by debugging QGIS source code through this repository.

## How to generate QGIS Microsoft Visual Studio solution.

1 Download and install Cygwin : https://www.cygwin.com/setup-x86_64.exe  
Install it and and install the following packages : flex bison  
2 Download and install OSGeo4w v2 : http://download.osgeo.org/osgeo4w/v2/osgeo4w-setup.exe  
3 Install Microsoft Visual Studio Community 2022 (64-bit) - Version 17.9.6.  
4 Install CMake.  
5 Download QGIS source or clone the repository of QGIS.  
6 Clone this repository.  
7 Open a new cygwin console and navigate to the cloned directory.

```
./qgis.sh
```

make sure that following variables are valid in shell script:
O4W_ROOT, VCSDK, SRCDIR, BUILDDIR

## How to build and start debugging

Open vs2022.bat in the cloned directory.  
Make sure that following variables are valid in this bat file:
O4W_ROOT, BUILDDIR

To start debugging, mark the qgis project of the generated solution as Startup Project and right click at the qgis project and select Properties... Under Configuration Properties -> Debugging, edit the 'Environment' value like this.

```
PATH=C:\OSGeo4W\bin;C:\OSGeo4W\apps\gdal-dev\bin;%PATH%
```

## Tested with

QGIS 3.36.1  
Microsoft Visual Studio Community 2022 (64-bit) - Version 17.9.6  
CMake3.29.0

![QGIS3.36.1](./QGIS-3.36.1-about.png?raw=true "QGIS3.36.1")
