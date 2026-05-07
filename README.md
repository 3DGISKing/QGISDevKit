### QGIS Windows build/debug helper

Building QGIS on Windows does not have a single, well-maintained guide. This repository helps you generate a Visual Studio solution and debug QGIS source code more easily.

## Generate a QGIS Visual Studio solution

1. Install Cygwin from: https://www.cygwin.com/setup-x86_64.exe  
   During setup, install the packages `flex` and `bison`.
2. Install OSGeo4W v2 from: http://download.osgeo.org/osgeo4w/v2/osgeo4w-setup.exe  
   Select package `qgis-ltr-deps 3.44.9-2`.
3. Install Microsoft Visual Studio Community 2022 (64-bit), version `17.14.31`.
4. Install CMake.
5. Clone/download QGIS source and make sure your source directory matches your script settings (example: `D:/QGIS-final-3_44_9`).
6. Clone this repository.
7. Open a Cygwin shell (`C:\cygwin64\Cygwin.bat`) and run:

```
cd /cygdrive/d/MyGithub/QGISDevKit
./qgis.sh
```

To generate `Release` instead of `RelWithDebInfo`:

```
cd /cygdrive/d/MyGithub/QGISDevKit
BUILDCONF=Release ./qgis.sh
```

If you switch between build configurations, clear the previous CMake cache first (for example remove `D:/QGISBuild/CMakeCache.txt`).

Before running `qgis.sh`, verify these variables in the script:

- `O4W_ROOT`
- `VCSDK`
- `SRCDIR`
- `BUILDDIR`

`qgis.sh` uses `msvc2022-env.bat` for MSVC environment setup.  
`msvc2019-env.bat` is kept only for legacy VS2019 workflows.

## Troubleshooting

If CMake fails on **"Check for working C compiler"** with MSVC error `C1090` (PDB API call failed), the compiler itself is usually fine, but `.pdb` generation is being blocked.

A common cause is Windows Defender Real-time Protection scanning/locking generated `.pdb` files in the build directory.

Workarounds:

- Temporarily disable Real-time Protection while configuring/building.
- Or add your QGIS build directory (for example `D:\QGISBuild`) to Defender exclusions (recommended over disabling protection globally).

## Build and start debugging

Open `launch-vs2022.bat` in the cloned directory.

Before running it, verify these variables:

- `O4W_ROOT`
- `BUILDDIR`

To start debugging in Visual Studio:

1. Set project `qgis` as **Startup Project**.
2. Right-click `qgis` -> **Properties**.
3. Go to **Configuration Properties -> Debugging**.
4. Update **Environment** with:

```
PATH=C:\OSGeo4W\bin;C:\OSGeo4W\apps\gdal\bin;D:\QGISBuild\output\bin\RelWithDebInfo;%PATH%
```

## Tested with

- QGIS `3.44.9`
- Microsoft Visual Studio Community 2022 (64-bit) `17.14.31`
- CMake `4.3.2`

![QGIS3.44.9](./QGIS-3.44.9-about.png?raw=true "QGIS3.44.9")
