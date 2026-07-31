### QGIS Windows build/debug helper

Building QGIS on Windows does not have a single, well-maintained guide. This repository helps you generate a Visual Studio 2022 solution from QGIS source (OSGeo4W deps) and debug it more easily.

## Generate a QGIS Visual Studio solution

1. Install Cygwin from: https://www.cygwin.com/setup-x86_64.exe  
   During setup, install the packages `flex` and `bison`.
2. Install OSGeo4W v2 from: http://download.osgeo.org/osgeo4w/v2/osgeo4w-setup.exe  
   Select package `qgis-dev-deps` 4.3.0-1194-df0339da91b-1 (QGIS Nightly build of development branch).
3. Install Microsoft Visual Studio Community 2022 (64-bit), version `17.14.34`.
4. Install CMake.
5. Clone/download QGIS source and point `SRCDIR` in `config.bat` at that tree (must contain `CMakeLists.txt`).
6. Clone this repository.
7. Open a Cygwin shell (`C:\cygwin64\Cygwin.bat`) and run:

```
cd /cygdrive/d/MyResearch/QGIS/QGISDevKit
./qgis.sh
```

`qgis.sh` loads OSGeo4W env scripts (`o4w_env.bat`, `qt6_env.bat`, `gdal-dev-env.bat`, `pdal-dev-env.bat`) plus `msvc2022-env.bat`, then runs CMake with the Visual Studio 17 2022 generator.

To generate `Release` instead of `RelWithDebInfo`:

```
cd /cygdrive/d/MyResearch/QGIS/QGISDevKit
BUILDCONF=Release ./qgis.sh
```

Other useful overrides:

```
WITH_GRASS=FALSE ./qgis.sh
PUSH_TO_DASH=TRUE ./qgis.sh
```

If you switch between build configurations, clear the previous CMake cache first (for example remove `D:/MyResearch/QGIS/qgis-build/CMakeCache.txt`).

Shared paths live in `config.bat` (edit that file only). Defaults:

- `OSGEO4W_ROOT` — OSGeo4W root (`C:\OSGeo4W`)
- `VCSDK` — Windows SDK version used with MSVC (`10.0.26100.0`)
- `SRCDIR` — QGIS source tree
- `BUILDDIR` — CMake/VS build directory
- `INSTDIR` — install prefix root (apps installed under `$INSTDIR/apps/qgis-dev`)

`qgis.sh`, `launch-vs2022.bat`, `run-qgis.bat`, and `msvc2022-env.bat` all load `config.bat`. The script exits early if `OSGEO4W_ROOT` or `SRCDIR` is invalid. `BUILDNAME` is built as `qgis-dev-<version>[-<gitsha>]-Nightly-VC17-x86_64`, with `<version>` taken from `SRCDIR/CMakeLists.txt`.

## Troubleshooting

If CMake fails on **"Check for working C compiler"** with MSVC error `C1090` (PDB API call failed), the compiler itself is usually fine, but `.pdb` generation is being blocked.

A common cause is Windows Defender Real-time Protection scanning/locking generated `.pdb` files in the build directory.

Workarounds:

- Temporarily disable Real-time Protection while configuring/building.
- Or add your QGIS build directory (for example `D:\MyResearch\QGIS\qgis-build`) to Defender exclusions (recommended over disabling protection globally).

## Build and start debugging

Open `launch-vs2022.bat` in the cloned directory.

Before running it, verify `OSGEO4W_ROOT` and `BUILDDIR` in `config.bat`.

To start debugging in Visual Studio:

1. Set project `qgis` as **Startup Project**.
2. Right-click `qgis` -> **Properties**.
3. Go to **Configuration Properties -> Debugging**.
4. Update **Environment** with:

```
PATH=C:\OSGeo4W\bin;C:\OSGeo4W\apps\Qt6\bin;C:\OSGeo4W\apps\gdal-dev\bin;C:\OSGeo4W\apps\pdal-dev\bin;D:\MyResearch\QGIS\qgis-build1\output\bin\RelWithDebInfo;%PATH%
```

To run a built `qgis.exe` without Visual Studio, use `run-qgis.bat` (paths come from `config.bat`).

## Tested with

- QGIS `4.2.0`
- Microsoft Visual Studio Community 2022 (64-bit) `17.14.34`
- CMake `4.3.2`

![QGIS4.2.0](./QGIS-4.2.0-about.png?raw=true "QGIS4.2.0")
