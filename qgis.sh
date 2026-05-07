export O4W_ROOT=/cygdrive/C/OSGeo4W
export VCSDK=10.0.26100.0
export SRCDIR=/cygdrive/D/QGIS-final-3_44_9
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
: ${WITH_GRASS:=FALSE}
: ${WITH_GRASS8:=$WITH_GRASS}

export SITE TARGET CC CXX BUILDCONF WITH_GRASS WITH_GRASS8

echo "Using VCSDK: $VCSDK"
VCSDK_SETUPAPI_PATH="/cygdrive/c/Program Files (x86)/Windows Kits/10/Lib/$VCSDK/um/x64/SetupAPI.Lib"
if [ ! -f "$VCSDK_SETUPAPI_PATH" ]; then
	echo "VCSDK $VCSDK is not installed. please specify correct VCSDK"
	exit 1
fi

source ./build-helpers

cd $O4W_ROOT

fetchenv bin/o4w_env.bat

cmakeenv

export BUILDNAME=$P-$V-$TARGET-VC16-x86_64

mkdir -p $BUILDDIR

cd $WORK_DIR

fetchenv msvc2022-env.bat

cd $OSGEO4W_ROOT

[ -d "$DBGHLP_PATH" ] || { echo no directory $DBGHLP_PATH $DBGHLP_PATH; false; }

if [ "$WITH_GRASS" = "TRUE" ] || [ "$WITH_GRASS8" = "TRUE" ]; then
	[ -f "$GRASS" ] || { echo GRASS not set; false; }
	[ -d "$GRASS_PREFIX" ] || { echo no directory GRASS_PREFIX $GRASS_PREFIX; false; }

	export GRASS_VERSION=$(cmd /c $GRASS --config version | sed -e "s/\r//")
else
	echo "Skipping GRASS checks (WITH_GRASS=$WITH_GRASS, WITH_GRASS8=$WITH_GRASS8)"
fi

cd $BUILDDIR

# Ensure MSVC tools use a valid Windows temp directory for PDB operations.
mkdir -p /cygdrive/c/TEMP
export TEMP=$(cygpath -aw /cygdrive/c/TEMP)
export TMP=$TEMP
echo "Using TEMP: $TEMP"

echo CMAKE: $(date)

rm -f qgsversion.h

# If you use the touch command without any options, it will simply create a new empty file.
# If the file already exists, the touch command will update the access and modification times to the current time without changing the file contents.

touch $SRCDIR/CMakeLists.txt

GRASS_PREFIX8_ARG=
if [ "$WITH_GRASS8" = "TRUE" ]; then
	GRASS_PREFIX8_ARG="-D GRASS_PREFIX8=$(cygpath -m "$GRASS_PREFIX")"
fi

cmake -G "Visual Studio 17 2022" \
		-D CMAKE_CXX_COMPILER="$(cygpath -m $CXX)" \
		-D CMAKE_C_COMPILER="$(cygpath -m $CC)" \
		-D CMAKE_LINKER=link.exe \
		-D SUBMIT_URL="https://cdash.orfeo-toolbox.org/submit.php?project=QGIS" \
		-D CMAKE_CXX_FLAGS_${BUILDCONF^^}="/MD /Z7 /MP /Od /D NDEBUG /std:c++17 /permissive- /bigobj" \
		-D CMAKE_PDB_OUTPUT_DIRECTORY_${BUILDCONF^^}=$(cygpath -am $BUILDDIR/apps/$P/pdb) \
		-D BUILDNAME="$BUILDNAME" \
		-D WITH_BINDINGS=FALSE \
		-D SITE="$SITE" \
		-D PEDANTIC=TRUE \
		-D WITH_QSPATIALITE=TRUE \
		-D WITH_SERVER=FALSE \
		-D SERVER_SKIP_ECW=TRUE \
		-D WITH_3D=TRUE \
		-D WITH_PDAL=TRUE \
		-D WITH_HANA=TRUE \
		-D WITH_PYTHON=FALSE \
		-D BUILD_SIP_PYTHON_MODULE=OFF \
		-D WITH_GRASS=$WITH_GRASS \
		-D WITH_GRASS8=$WITH_GRASS8 \
		$GRASS_PREFIX8_ARG \
		-D WITH_ORACLE=TRUE \
		-D WITH_CUSTOM_WIDGETS=TRUE \
		-D ENABLE_TESTS=FALSE \
		-D BUILD_TESTING=OFF \
		-D CMAKE_BUILD_TYPE=$BUILDCONF \
		-D CMAKE_CONFIGURATION_TYPES="$BUILDCONF" \
		-D SETUPAPI_LIBRARY="$SETUPAPI_LIBRARY" \
		-D PROJ_INCLUDE_DIR=$(cygpath -am $O4W_ROOT/include) \
		-D PROJ_LIBRARY=$(cygpath -am "$O4W_ROOT/lib/proj.lib") \
		-D PROJ_LIBRARIES=$(cygpath -am "$O4W_ROOT/lib/proj.lib") \
		-D GEOS_LIBRARY=$(cygpath -am "$O4W_ROOT/lib/geos_c.lib") \
		-D SQLite3_INCLUDE_DIR=$(cygpath -am "$O4W_ROOT/include") \
		-D SQLite3_LIBRARY=$(cygpath -am "$O4W_ROOT/lib/sqlite3_i.lib") \
		-D SQLITE3_INCLUDE_DIR=$(cygpath -am "$O4W_ROOT/include") \
		-D SQLITE3_LIBRARY=$(cygpath -am "$O4W_ROOT/lib/sqlite3_i.lib") \
		-D LIBZIP_LIBRARY=$(cygpath -am "$O4W_ROOT/lib/zip.lib") \
		-D LIBZIP_INCLUDE_DIR=$(cygpath -am "$O4W_ROOT/include") \
		-D LIBZIP_CONF_INCLUDE_DIR=$(cygpath -am "$O4W_ROOT/include") \
		-D EXIV2_INCLUDE_DIR=$(cygpath -am "$O4W_ROOT/include") \
		-D EXIV2_LIBRARY=$(cygpath -am "$O4W_ROOT/lib/exiv2.lib") \
		-D SPATIALITE_INCLUDE_DIR=$(cygpath -am "$O4W_ROOT/include") \
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
		-D GDAL_INCLUDE_DIR=$(cygpath -am "$O4W_ROOT/include") \
		-D GDAL_LIBRARY=$(cygpath -am "$O4W_ROOT/lib/gdal.lib") \
		-D ZLIB_INCLUDE_DIR=$(cygpath -am $O4W_ROOT/include/) \
		-D ZLIB_LIBRARY=$(cygpath -am "$O4W_ROOT/lib/zlib.lib") \
		-D ZSTD_INCLUDE_DIR=$(cygpath -am $O4W_ROOT/include/) \
		-D ZSTD_LIBRARY=$(cygpath -am "$O4W_ROOT/lib/zstd.lib") \
		-D DRACO_INCLUDE_DIR=$(cygpath -am $O4W_ROOT/include/) \
		-D DRACO_LIBRARY=$(cygpath -am "$O4W_ROOT/lib/draco.lib") \
		-D CURL_INCLUDE_DIR=$(cygpath -am "$O4W_ROOT/include") \
		-D CURL_LIBRARY=$(cygpath -am "$O4W_ROOT/lib/libcurl_imp.lib") \
		-D GSL_INCLUDE_DIR=$(cygpath -am $O4W_ROOT/include/) \
		-D GSL_LIBRARY=$(cygpath -am "$O4W_ROOT/lib/gsl.lib") \
		-D GSL_CBLAS_LIBRARY=$(cygpath -am "$O4W_ROOT/lib/zlib.lib") \
		-D QWT_INCLUDE_DIR=$(cygpath -am $O4W_ROOT/apps/Qt5/include/qwt6) \
		-D POSTGRES_INCLUDE_DIR=$(cygpath -am "$O4W_ROOT/include/postgresql/server") \
		-D POSTGRES_LIBRARY=$(cygpath -am "$O4W_ROOT/lib/libpq.lib") \
		-D PostgreSQL_INCLUDE_DIR=$(cygpath -am "$O4W_ROOT/include") \
		-D PostgreSQL_LIBRARY=$(cygpath -am "$O4W_ROOT/lib/libpq.lib") \
		$(cygpath -m $SRCDIR)