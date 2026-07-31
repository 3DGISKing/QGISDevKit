SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
CONFIG_BAT="$SCRIPT_DIR/config.bat"
if [ ! -f "$CONFIG_BAT" ]; then
	echo "Missing shared config: $CONFIG_BAT"
	exit 1
fi

# Load defaults from config.bat (Windows paths). Existing env overrides win.
while IFS= read -r line || [ -n "$line" ]; do
	line=${line%$'\r'}
	[[ "$line" =~ ^if\ not\ defined\ ([A-Za-z0-9_]+)\ set\ \"[A-Za-z0-9_]+=(.*)\"$ ]] || continue
	var="${BASH_REMATCH[1]}"
	val="${BASH_REMATCH[2]}"
	if [ -z "${!var+x}" ]; then
		printf -v "$var" '%s' "$val"
	fi
done < "$CONFIG_BAT"

# Path vars from config.bat are Windows paths; convert for Cygwin.
for var in OSGEO4W_ROOT SRCDIR BUILDDIR INSTDIR; do
	eval "winpath=\${$var}"
	if [ -n "$winpath" ]; then
		printf -v "$var" '%s' "$(cygpath -u "$winpath")"
	fi
done

export OSGEO4W_ROOT VCSDK SRCDIR BUILDDIR INSTDIR P CC CXX

export WORK_DIR=$PWD

: ${SITE:=qgis.org}
: ${TARGET:=Nightly}
: ${BUILDCONF:=RelWithDebInfo}
: ${PUSH_TO_DASH:=FALSE}
: ${WITH_GRASS:=TRUE}
: ${WITH_GRASS8:=$WITH_GRASS}

export SITE TARGET CC CXX BUILDCONF WITH_GRASS WITH_GRASS8

if [ ! -d "$OSGEO4W_ROOT" ] || [ ! -f "$OSGEO4W_ROOT/bin/o4w_env.bat" ]; then
	echo "Invalid OSGEO4W_ROOT: $OSGEO4W_ROOT"
	echo "Expected an OSGeo4W installation with bin/o4w_env.bat"
	exit 1
fi

if [ ! -d "$SRCDIR" ] || [ ! -f "$SRCDIR/CMakeLists.txt" ]; then
	echo "Invalid SRCDIR: $SRCDIR"
	echo "Expected an existing QGIS source directory containing CMakeLists.txt"
	exit 1
fi

MAJOR=$(sed -ne 's/set(CPACK_PACKAGE_VERSION_MAJOR "\([0-9]*\)")/\1/ip' "$SRCDIR/CMakeLists.txt")
MINOR=$(sed -ne 's/set(CPACK_PACKAGE_VERSION_MINOR "\([0-9]*\)")/\1/ip' "$SRCDIR/CMakeLists.txt")
PATCH=$(sed -ne 's/set(CPACK_PACKAGE_VERSION_PATCH "\([0-9]*\)")/\1/ip' "$SRCDIR/CMakeLists.txt")
if [ -z "$MAJOR" ] || [ -z "$MINOR" ] || [ -z "$PATCH" ]; then
	echo "Could not determine QGIS version from $SRCDIR/CMakeLists.txt"
	exit 1
fi
V=$MAJOR.$MINOR.$PATCH
if [ -d "$SRCDIR/.git" ]; then
	SHA=$(git -C "$SRCDIR" log -n1 --pretty=%h 2>/dev/null)
	[ -n "$SHA" ] && V=$V-$SHA
fi
export V

mkdir -p "$BUILDDIR" || {
	echo "Cannot create BUILDDIR: $BUILDDIR"
	exit 1
}

echo "Using VCSDK: $VCSDK"
VCSDK_SETUPAPI_PATH="/cygdrive/c/Program Files (x86)/Windows Kits/10/Lib/$VCSDK/um/x64/SetupAPI.Lib"
if [ ! -f "$VCSDK_SETUPAPI_PATH" ]; then
	echo "VCSDK $VCSDK is not installed. please specify correct VCSDK"
	exit 1
fi

source ./build-helpers

cd "$OSGEO4W_ROOT"

fetchenv bin/o4w_env.bat
fetchenv bin/qt6_env.bat
fetchenv bin/gdal-dev-env.bat
fetchenv bin/pdal-dev-env.bat

cmakeenv

export BUILDNAME=$P-$V-$TARGET-VC17-x86_64

cd "$WORK_DIR"

fetchenv msvc2022-env.bat

cd "$OSGEO4W_ROOT"

[ -d "$DBGHLP_PATH" ] || { echo no directory $DBGHLP_PATH $DBGHLP_PATH; false; }

if [ "$WITH_GRASS" = "TRUE" ] || [ "$WITH_GRASS8" = "TRUE" ]; then
	[ -f "$GRASS" ] || { echo GRASS not set; false; }
	[ -d "$GRASS_PREFIX" ] || { echo no directory GRASS_PREFIX $GRASS_PREFIX; false; }

	export GRASS_VERSION=$(cmd /c $GRASS --config version | sed -e "s/\r//")
else
	echo "Skipping GRASS checks (WITH_GRASS=$WITH_GRASS, WITH_GRASS8=$WITH_GRASS8)"
fi

cd "$BUILDDIR"

# Ensure MSVC tools use a valid Windows temp directory for PDB operations.
mkdir -p /cygdrive/c/TEMP
export TEMP=$(cygpath -aw /cygdrive/c/TEMP)
export TMP=$TEMP
echo "Using TEMP: $TEMP"

echo CMAKE: $(date)

rm -f qgsversion.h

# If you use the touch command without any options, it will simply create a new empty file.
# If the file already exists, the touch command will update the access and modification times to the current time without changing the file contents.

touch "$SRCDIR/CMakeLists.txt"

# Qsci SIP files live under PyQt6 bindings; without this, HAVE_QSCI_SIP is disabled
# and QgsCodeEditor is missing from _gui.pyd while gui/__init__.py still references it.
QSCI_SIP_CANDIDATE=
if [ -n "$PYTHONHOME" ] && [ -f "$PYTHONHOME/Lib/site-packages/PyQt6/bindings/Qsci/qscimod6.sip" ]; then
	QSCI_SIP_CANDIDATE="$PYTHONHOME/Lib/site-packages/PyQt6/bindings"
elif [ -f "$OSGEO4W_ROOT/apps/Python312/Lib/site-packages/PyQt6/bindings/Qsci/qscimod6.sip" ]; then
	QSCI_SIP_CANDIDATE="$OSGEO4W_ROOT/apps/Python312/Lib/site-packages/PyQt6/bindings"
fi
if [ -z "$QSCI_SIP_CANDIDATE" ]; then
	echo "Qsci SIP (qscimod6.sip) not found under PYTHONHOME or $OSGEO4W_ROOT/apps/Python312"
	exit 1
fi
echo "Using QSCI/PYQT SIP dir: $QSCI_SIP_CANDIDATE"

GRASS_PREFIX8_ARG=
if [ "$WITH_GRASS8" = "TRUE" ]; then
	GRASS_PREFIX8_ARG="-D GRASS_PREFIX8=$(cygpath -m "$GRASS_PREFIX")"
fi

cmake -G "Visual Studio 17 2022" \
		-D CMAKE_CXX_COMPILER="$(cygpath -m $CXX)" \
		-D CMAKE_C_COMPILER="$(cygpath -m $CC)" \
		-D CMAKE_LINKER=link.exe \
		-D SUBMIT_URL="https://cdash.orfeo-toolbox.org/submit.php?project=QGIS" \
		-D CMAKE_CXX_FLAGS_${BUILDCONF^^}="/MD /Z7 /MP /Od /D NDEBUG /std:c++17 /permissive- /bigobj /I$(cygpath -am $OSGEO4W_ROOT/include)" \
		-D CMAKE_C_FLAGS_${BUILDCONF^^}="/MD /Z7 /MP /Od /D NDEBUG /I$(cygpath -am $OSGEO4W_ROOT/include)" \
		-D CMAKE_PDB_OUTPUT_DIRECTORY_${BUILDCONF^^}=$(cygpath -am $BUILDDIR/apps/$P/pdb) \
		-D BUILDNAME="$BUILDNAME" \
		-D WITH_BINDINGS=TRUE \
		-D SITE="$SITE" \
		-D PEDANTIC=TRUE \
		-D WITH_QSPATIALITE=TRUE \
		-D WITH_SERVER=TRUE \
		-D SERVER_SKIP_ECW=TRUE \
		-D WITH_QTWEBENGINE=TRUE \
		-D USE_OPENCL=TRUE \
		-D WITH_3D=TRUE \
		-D WITH_PDAL=TRUE \
		-D WITH_HANA=TRUE \
		-D WITH_PYTHON=TRUE \
		-D BUILD_SIP_PYTHON_MODULE=OFF \
		-D WITH_GEOGRAPHICLIB=TRUE \
		-D WITH_GRASS=$WITH_GRASS \
		-D WITH_GRASS8=$WITH_GRASS8 \
		$GRASS_PREFIX8_ARG \
		-D WITH_ORACLE=TRUE \
		-D WITH_CUSTOM_WIDGETS=TRUE \
		-D WITH_SFCGAL=TRUE \
		-D ENABLE_TESTS=FALSE \
		-D BUILD_TESTING=OFF \
		-D CMAKE_BUILD_TYPE=$BUILDCONF \
		-D CMAKE_CONFIGURATION_TYPES="$BUILDCONF" \
		-D SETUPAPI_LIBRARY="$SETUPAPI_LIBRARY" \
		-D PROJ_INCLUDE_DIR=$(cygpath -am $OSGEO4W_ROOT/include) \
		-D GDAL_INCLUDE_DIR=$(cygpath -am "$OSGEO4W_ROOT/apps/gdal-dev/include") \
		-D GDAL_LIBRARY=$(cygpath -am "$OSGEO4W_ROOT/apps/gdal-dev/lib/gdal.lib") \
		-D PDAL_DIR=$(cygpath -am "$OSGEO4W_ROOT/apps/pdal-dev/lib/cmake/PDAL") \
		-D POSTGRES_INCLUDE_DIR=$(cygpath -am $OSGEO4W_ROOT/include) \
		-D GEOS_LIBRARY=$(cygpath -am "$OSGEO4W_ROOT/lib/geos_c.lib") \
		-D SQLITE3_LIBRARY=$(cygpath -am "$OSGEO4W_ROOT/lib/sqlite3_i.lib") \
		-D SPATIALITE_LIBRARY=$(cygpath -am "$OSGEO4W_ROOT/lib/spatialite_i.lib") \
		-D SPATIALINDEX_LIBRARY=$(cygpath -am $OSGEO4W_ROOT/lib/spatialindex-64.lib) \
		-D Python_EXECUTABLE=$(cygpath -am $OSGEO4W_ROOT/bin/python3.exe) \
		-D QSCI_SIP_DIR=$(cygpath -am "$QSCI_SIP_CANDIDATE") \
		-D PYQT_SIP_DIR=$(cygpath -am "$QSCI_SIP_CANDIDATE") \
		-D SIP_MODULE_EXECUTABLE=$(cygpath -am $PYTHONHOME/Scripts/sip-module.exe) \
		-D PYTHON_INCLUDE_PATH=$(cygpath -am $PYTHONHOME/include) \
		-D PYTHON_LIBRARY=$(cygpath -am $PYTHONHOME/libs/$(basename $PYTHONHOME).lib) \
		-D Qt6_DIR=$(cygpath -am "$OSGEO4W_ROOT/apps/Qt6/lib/cmake/Qt6") \
		-D Qt6Keychain_DIR=$(cygpath -am "$OSGEO4W_ROOT/apps/Qt6/lib/cmake/Qt6Keychain") \
		-D Qt6Designer_DIR=$(cygpath -am "$OSGEO4W_ROOT/apps/Qt6/lib/cmake/Qt6Designer") \
		-D QT_LIBRARY_DIR=$(cygpath -am $OSGEO4W_ROOT/apps/Qt6/lib) \
		-D QT_HEADERS_DIR=$(cygpath -am $OSGEO4W_ROOT/apps/Qt6/include) \
		-D CMAKE_INSTALL_PREFIX=$(cygpath -am $INSTDIR/apps/$P) \
		-D CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_NO_WARNINGS=TRUE \
		-D FCGI_INCLUDE_DIR=$(cygpath -am $OSGEO4W_ROOT/include) \
		-D FCGI_LIBRARY=$(cygpath -am $OSGEO4W_ROOT/lib/libfcgi.lib) \
		-D QCA_INCLUDE_DIR=$(cygpath -am $OSGEO4W_ROOT/apps/Qt6/include/QtCrypto) \
		-D QCA_LIBRARY=$(cygpath -am $OSGEO4W_ROOT/apps/Qt6/lib/qca-qt6.lib) \
		-D QWT_LIBRARY=$(cygpath -am $OSGEO4W_ROOT/apps/Qt6/lib/qwt.lib) \
		-D QSCINTILLA_LIBRARY=$(cygpath -am $OSGEO4W_ROOT/apps/Qt6/lib/qscintilla2.lib) \
		-D DART_TESTING_TIMEOUT=60 \
		-D PUSH_TO_CDASH=$PUSH_TO_DASH \
		$(cygpath -m $SRCDIR)