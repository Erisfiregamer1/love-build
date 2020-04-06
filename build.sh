#!/bin/sh
set -e

# Check for application name
if [ -z "${INPUT_APP_NAME}" ]; then
    echo "Application name is unspecified"
    exit 1
fi

# Check for love version
if [ -z "${INPUT_LOVE_VERSION}" ]; then
    echo "LOVE version is unspecified"
    exit 1
fi

# Check for source directory 
if [ -z "${INPUT_SOURCE_DIR}" ]; then
    echo "Source directory is unspecified"
    exit 1
fi

# Check for build directory 
if [ -z "${INPUT_BUILD_DIR}" ]; then
    echo "Build directory is unspecified"
    exit 1
fi

# Check for result directory 
if [ -z "${INPUT_RESULT_DIR}" ]; then
    echo "Result directory is unspecified"
    exit 1
fi

# Shorten variables a little
AN=${INPUT_APP_NAME}
LV=${INPUT_LOVE_VERSION}

# Make results directory if it does not exist
mkdir -p "${INPUT_RESULT_DIR}"

# Change CWD to the build directory and copy source files
mkdir -p "${INPUT_BUILD_DIR}"
cp -a "${INPUT_SOURCE_DIR}/." "${INPUT_BUILD_DIR}"

### Dependencies #################################################

# If the usingLoveRocks flag is set to true, build loverocks deps
if [ "${INPUT_ENABLE_LOVEROCKS}" = true ]; then
    loverocks deps
fi

### LOVE build ####################################################

zip -r "${AN}.love" ./* -x '*.git*'
cp "${AN}.love" "${INPUT_RESULT_DIR}"/
echo "::set-output name=love-filename::${AN}.love"

### macos build ###################################################

# Download love for macos
wget "https://bitbucket.org/rude/love/downloads/love-${LV}-macos.zip"
unzip "love-${LV}-macos.zip" && rm "love-${LV}-macos.zip"
# Copy Data
cp "${AN}.love" love.app/Contents/Resources/ 
# If a plist file is provided, use that
if [ -f "Info.plist" ]; then
    cp "Info.plist" love.app/Contents/
fi
mv love.app "${AN}.app"
# Setup final archives
zip -ry "${AN}_macos.zip" "${AN}.app" && rm -rf "${AN}.app"
mv "${AN}_macos.zip" "${INPUT_RESULT_DIR}"/
# Export filename
echo "::set-output name=macos-filename::${AN}_macos.zip"

### win32 build ###################################################

# Download love for windows
wget "https://bitbucket.org/rude/love/downloads/love-${LV}-win32.zip"
unzip -j "love-${LV}-win32.zip" -d "${AN}_win32" && rm "love-${LV}-win32.zip" 
# Copy data
cat "${AN}_win32/love.exe" "${AN}.love" > "${AN}_win32/${AN}.exe"
# Delete unneeded files
rm "${AN}_win32/love.exe"
rm "${AN}_win32/lovec.exe"
rm "${AN}_win32/love.ico"
rm "${AN}_win32/changes.txt"
rm "${AN}_win32/readme.txt"
# Setup final archive
zip -ry "${AN}_win32.zip" "${AN}_win32" && rm -rf "${AN}_win32"
mv "${AN}_win32.zip" "${INPUT_RESULT_DIR}"/
# Export filename
echo "::set-output name=win32-filename::${AN}_win32.zip"
