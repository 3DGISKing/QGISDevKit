# Change Log

### 1.2.0 - 2026-07-31

##### Tested with 4.2.0

##### Changes

- Added shared `config.bat` for `OSGEO4W_ROOT`, `VCSDK`, `SRCDIR`, `BUILDDIR`, `INSTDIR`, `P`, `CC`, and `CXX`; `qgis.sh`, `launch-vs2022.bat`, and `msvc2022-env.bat` load it.
- Replaced `O4W_ROOT` with `OSGEO4W_ROOT` across scripts.
- Moved OSGeo4W/Qt stack to Qt6 (`qt6_env.bat`, Qt6 include/lib paths); `launch-vs2022.bat` now calls `qt6_env.bat` so MSBuild/Python can find Qt platform plugins.
- Updated `qgis.sh` for `qgis-dev-deps` / Qt6: loads `gdal-dev` and `pdal-dev` envs, enables Python/bindings/server, sets Qsci/PyQt SIP dirs, and builds `BUILDNAME` as `…-VC17-…` from `CMakeLists.txt` version (+ git sha).
- Softened GRASS requirement in `msvc2022-env.bat` (grass85/84/83, continue without GRASS); switched VS tool var to `VS170COMNTOOLS`.
- Updated `README.md` for shared config, Qt6/`gdal-dev`/`pdal-dev` paths, and screenshot `QGIS-4.2.0-about.png`.

### 1.1.1 - 2026-06-16

##### Changes

- Updated `VCSDK` to `10.0.26100.0` in `msvc2022-env.bat`.
- Updated `Visual Studio` version to `17.14.34` in `README.md`.

### 1.1.0 - 2026-04-28

##### Update

- Rewrote `README.md` with clearer setup and debugging instructions for Windows.
- Added explicit prerequisite and environment-variable checks for `qgis.sh` and `vs2022.bat`.
- Improved troubleshooting guidance for MSVC `C1090`/PDB lock issues.
- Updated "Tested with" versions to QGIS `3.44.9`, Visual Studio `17.14.31`, and CMake `4.3.2`.
- Updated README screenshot reference to `QGIS-3.44.9-about.png`.

### 1.0.0 - 2024-05-01

##### Tested with 3.36.1
