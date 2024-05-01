export O4W_ROOT=/cygdrive/C/OSGeo4W
export VCSDK=10.0.22621.0
export SRCDIR=/cygdrive/D/0Sources/QGIS/QGIS-final-3_36_1
export BUILDDIR=/cygdrive/D/QGISBuild
export INSTDIR=/cygdrive/C/QGIS

export P=qgis-dev
export V=tbd
export B=tbd

export WORK_DIR=$PWD

: ${SITE:=qgis.org}
: ${TARGET:=Nightly}
: ${CC:=cl.exe}
: ${CXX:=cl.exe}
: ${BUILDCONF:=RelWithDebInfo}
: ${PUSH_TO_DASH:=TRUE}

export SITE TARGET CC CXX BUILDCONF

source ./build-helpers

cd $O4W_ROOT

fetchenv bin/o4w_env.bat

cmakeenv

export BUILDNAME=$P-$V-$TARGET-VC16-x86_64

mkdir -p $BUILDDIR

cd $WORK_DIR

fetchenv msvc-env2022.bat

cd $OSGEO4W_ROOT

fetchenv bin/gdal-dev-env.bat

[ -f "$GRASS" ] || { echo GRASS not set; false; }
[ -d "$GRASS_PREFIX" ] || { echo no directory GRASS_PREFIX $GRASS_PREFIX; false; }
[ -d "$DBGHLP_PATH" ] || { echo no directory $DBGHLP_PATH $DBGHLP_PATH; false; }

export GRASS_VERSION=$(cmd /c $GRASS --config version | sed -e "s/\r//")

cd $BUILDDIR

echo CMAKE: $(date)

rm -f qgsversion.h

# If you use the touch command without any options, it will simply create a new empty file.
# If the file already exists, the touch command will update the access and modification times to the current time without changing the file contents.

touch $SRCDIR/CMakeLists.txt

cmake -G "Visual Studio 17 2022" \
		-D CMAKE_CXX_COMPILER="$(cygpath -m $CXX)" \
		-D CMAKE_C_COMPILER="$(cygpath -m $CC)" \
		-D CMAKE_LINKER=link.exe \
		-D SUBMIT_URL="https://cdash.orfeo-toolbox.org/submit.php?project=QGIS" \
		-D CMAKE_CXX_FLAGS_${BUILDCONF^^}="/MD /Z7 /MP /Od /D NDEBUG /std:c++17 /permissive- /bigobj" \
		-D CMAKE_PDB_OUTPUT_DIRECTORY_${BUILDCONF^^}=$(cygpath -am $BUILDDIR/apps/$P/pdb) \
		-D BUILDNAME="$BUILDNAME" \
		-D SITE="$SITE" \
		-D PEDANTIC=TRUE \
		-D WITH_QSPATIALITE=TRUE \
		-D WITH_SERVER=TRUE \
		-D SERVER_SKIP_ECW=TRUE \
		-D WITH_3D=TRUE \
		-D WITH_PDAL=TRUE \
		-D WITH_HANA=TRUE \
		-D WITH_GRASS=TRUE \
		-D WITH_GRASS8=TRUE \
		-D GRASS_PREFIX8="$(cygpath -m $GRASS_PREFIX)" \
		-D WITH_ORACLE=TRUE \
		-D WITH_CUSTOM_WIDGETS=TRUE \
		-D CMAKE_BUILD_TYPE=$BUILDCONF \
		-D CMAKE_CONFIGURATION_TYPES="$BUILDCONF" \
		-D SETUPAPI_LIBRARY="$SETUPAPI_LIBRARY" \
		-D PROJ_INCLUDE_DIR=$(cygpath -am $O4W_ROOT/include) \
		-D GEOS_LIBRARY=$(cygpath -am "$O4W_ROOT/lib/geos_c.lib") \
		-D SQLITE3_LIBRARY=$(cygpath -am "$O4W_ROOT/lib/sqlite3_i.lib") \
		-D SPATIALITE_LIBRARY=$(cygpath -am "$O4W_ROOT/lib/spatialite_i.lib") \
		-D SPATIALINDEX_LIBRARY=$(cygpath -am $O4W_ROOT/lib/spatialindex-64.lib) \
		-D Python_EXECUTABLE=$(cygpath -am $O4W_ROOT/bin/python3.exe) \
		-D SIP_MODULE_EXECUTABLE=$(cygpath -am $PYTHONHOME/Scripts/sip-module.exe) \
		-D PYUIC_PROGRAM=$(cygpath -am $PYTHONHOME/Scripts/pyuic5.exe) \
		-D PYRCC_PROGRAM=$(cygpath -am $PYTHONHOME/Scripts/pyrcc5.exe) \
		-D PYTHON_INCLUDE_PATH=$(cygpath -am $PYTHONHOME/include) \
		-D PYTHON_LIBRARY=$(cygpath -am $PYTHONHOME/libs/$(basename $PYTHONHOME).lib) \
		-D QT_LIBRARY_DIR=$(cygpath -am $O4W_ROOT/lib) \
		-D QT_HEADERS_DIR=$(cygpath -am $O4W_ROOT/apps/qt5/include) \
		-D CMAKE_INSTALL_PREFIX=$(cygpath -am $INSTDIR/apps/$P) \
		-D CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_NO_WARNINGS=TRUE \
		-D FCGI_INCLUDE_DIR=$(cygpath -am $O4W_ROOT/include) \
		-D FCGI_LIBRARY=$(cygpath -am $O4W_ROOT/lib/libfcgi.lib) \
		-D QCA_INCLUDE_DIR=$(cygpath -am $O4W_ROOT/apps/Qt5/include/QtCrypto) \
		-D QCA_LIBRARY=$(cygpath -am $O4W_ROOT/apps/Qt5/lib/qca-qt5.lib) \
		-D QWT_LIBRARY=$(cygpath -am $O4W_ROOT/apps/Qt5/lib/qwt.lib) \
		-D QSCINTILLA_LIBRARY=$(cygpath -am $O4W_ROOT/apps/Qt5/lib/qscintilla2.lib) \
		-D DART_TESTING_TIMEOUT=60 \
		-D PUSH_TO_CDASH=$PUSH_TO_DASH \
		-D EXPAT_INCLUDE_DIR=$(cygpath -am $O4W_ROOT/include) \
		-D EXPAT_LIBRARY=$(cygpath -am "$O4W_ROOT/lib/libexpat.lib") \
		-D Protobuf_INCLUDE_DIR=$(cygpath -am $O4W_ROOT/include/) \
		-D Protobuf_LIBRARIES=$(cygpath -am "$O4W_ROOT/lib/libprotobuf.lib") \
		-D ZLIB_INCLUDE_DIR=$(cygpath -am $O4W_ROOT/include/) \
		-D ZLIB_LIBRARY=$(cygpath -am "$O4W_ROOT/lib/zlib.lib") \
		-D DRACO_INCLUDE_DIR=$(cygpath -am $O4W_ROOT/include/) \
		-D DRACO_LIBRARY=$(cygpath -am "$O4W_ROOT/lib/draco.lib") \
		-D GSL_INCLUDE_DIR=$(cygpath -am $O4W_ROOT/include/) \
		-D GSL_LIBRARY=$(cygpath -am "$O4W_ROOT/lib/gsl.lib") \
		-D GSL_CBLAS_LIBRARY=$(cygpath -am "$O4W_ROOT/lib/zlib.lib") \
		-D QWT_INCLUDE_DIR=$(cygpath -am $O4W_ROOT/apps/Qt5/include/qwt6) \
		$(cygpath -m $SRCDIR)