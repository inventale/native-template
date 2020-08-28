#!/bin/bash

# Based on https://github.com/KosalaHerath/macos-installer-builder

#Configuration Variables and Parameters

function printSignature() {
  echo =================================
  echo == MacOS installer builder
  echo =================================
}

function printUsage() {
  echo -e "\033[1mUsage:\033[0m"
  echo "$0 [APPLICATION_NAME] [APPLICATION_VERSION]"
  echo
  echo -e "\033[1mOptions:\033[0m"
  echo "  -h (--help)"
  echo
  echo -e "\033[1mExample::\033[0m"
  echo "$0 wso2am 2.6.0"

}

#Start the generator
printSignature

if [[ "$2" == "sign" ]]; then
    SIGN=1
else
    SIGN=0
fi

#Parameters
TARGET_DIRECTORY="target"
VERSION=${1}
DATE=`date +%Y-%m-%d`
TIME=`date +%H:%M:%S`
LOG_PREFIX="[$DATE $TIME]"

#Functions
go_to_dir() {
    pushd $1 >/dev/null 2>&1
}

log_info() {
    echo "${LOG_PREFIX}[INFO]" $1
}

log_warn() {
    echo "${LOG_PREFIX}[WARN]" $1
}

log_error() {
    echo "${LOG_PREFIX}[ERROR]" $1
}

deleteInstallationDirectory() {
    log_info "Cleaning $TARGET_DIRECTORY directory."
    rm -rf $TARGET_DIRECTORY

    if [[ $? != 0 ]]; then
        log_error "Failed to clean $TARGET_DIRECTORY directory" $?
        exit 1
    fi
}

createInstallationDirectory() {
    if [ -d ${TARGET_DIRECTORY} ]; then
        deleteInstallationDirectory
    fi
    mkdir $TARGET_DIRECTORY

    if [[ $? != 0 ]]; then
        log_error "Failed to create $TARGET_DIRECTORY directory" $?
        exit 1
    fi
}

copyDarwinDirectory(){
    createInstallationDirectory
    cp -r darwin ${TARGET_DIRECTORY}/
    chmod -R 755 ${TARGET_DIRECTORY}/darwin/Resources
    chmod 755 ${TARGET_DIRECTORY}/darwin/Distribution

    sed -i '' -e 's/__VERSION__/'${VERSION}'/g' ${TARGET_DIRECTORY}/darwin/Info.plist
    sed -i '' -e 's/__VERSION__/'${VERSION}'/g' ${TARGET_DIRECTORY}/darwin/Distribution
    chmod -R 755 ${TARGET_DIRECTORY}/darwin/Distribution
    sed -i '' -e 's/__VERSION__/'${VERSION}'/g' ${TARGET_DIRECTORY}/darwin/Resources/*.html
    chmod -R 755 ${TARGET_DIRECTORY}/darwin/Resources/
    rm -rf ${TARGET_DIRECTORY}/darwinpkg
    mkdir -p ${TARGET_DIRECTORY}/darwinpkg

    rm -rf ${TARGET_DIRECTORY}/pkg
    mkdir -p ${TARGET_DIRECTORY}/pkg
    chmod -R 755 ${TARGET_DIRECTORY}/pkg

    rm -rf ${TARGET_DIRECTORY}/pkg-signed
    mkdir -p ${TARGET_DIRECTORY}/pkg-signed
    chmod -R 755 ${TARGET_DIRECTORY}/pkg-signed

    #Copy cellery product to /Applications/native-template.app/Contents/MacOS
    mkdir -p ${TARGET_DIRECTORY}/darwinpkg/Applications/native-template.app/Contents/MacOS
    chmod -R 755 ${TARGET_DIRECTORY}/darwinpkg/Applications/native-template.app/Contents/MacOS
}

copyBuildDirectory() {
    #Copy resources
    mkdir -p ${TARGET_DIRECTORY}/darwinpkg/Applications/native-template.app/Contents/Resources
    cp -a ./darwin/Resources/main.icns ${TARGET_DIRECTORY}/darwinpkg/Applications/native-template.app/Contents/Resources
    chmod -R 644 ${TARGET_DIRECTORY}/darwinpkg/Applications/native-template.app/Contents/Resources/main.icns

    cp ../../Resources/* ${TARGET_DIRECTORY}/darwinpkg/Applications/native-template.app/Contents/Resources

    cp ${TARGET_DIRECTORY}/darwin/Info.plist ${TARGET_DIRECTORY}/darwinpkg/Applications/native-template.app/Contents
}

function buildPackage() {
    log_info "Apllication installer package building started.(1/3)"
    rm -rf ${TARGET_DIRECTORY}/package
    mkdir -p ${TARGET_DIRECTORY}/package
    chmod -R 755 ${TARGET_DIRECTORY}/package
    pkgbuild --identifier com.inventale.native.template \
    --version ${VERSION} \
    --root ${TARGET_DIRECTORY}/darwinpkg \
    ${TARGET_DIRECTORY}/package/native-template.pkg > /dev/null 2>&1
}

function buildProduct() {
    log_info "Application installer product building started.(2/3)"
    productbuild --distribution ${TARGET_DIRECTORY}/darwin/Distribution \
    --resources ${TARGET_DIRECTORY}/darwin/Resources \
    --package-path ${TARGET_DIRECTORY}/package \
    ${TARGET_DIRECTORY}/pkg/$1 > /dev/null 2>&1
}

function signProduct() {
    log_info "Application installer signing process started.(3/3)"
    productsign --sign "3rd Party Mac Developer Installer: EDMAKS, OOO (JJ5E7Q6U6H)" ${TARGET_DIRECTORY}/pkg/$1 ${TARGET_DIRECTORY}/pkg-signed/$1
    pkgutil --check-signature ${TARGET_DIRECTORY}/pkg-signed/$1
}

function createInstaller() {
    cp -a ../../app/build/bin/macos/native-template${1}Executable/native-template.kexe ${TARGET_DIRECTORY}/darwinpkg/Applications/native-template.app/Contents/MacOS
    log_info "Copy dylib's and fix paths"
    dylibbundler -od -b -x ${TARGET_DIRECTORY}/darwinpkg/Applications/native-template.app/Contents/MacOS/native-template.kexe\
     -d ${TARGET_DIRECTORY}/darwinpkg/Applications/native-template.app/Contents/Resources/lib/\
     -p @executable_path/../Resources/lib/
    log_info "Application installer generation process started.(3 Steps)"
    buildPackage
    buildProduct native-template-$2.pkg
    [[ $SIGN == 1 ]] && signProduct native-template-$2.pkg
    log_info "Application installer generation steps finished."
}

#Pre-requisites
command -v mvn -v >/dev/null 2>&1 || {
    log_warn "Apache Maven was not found. Please install Maven first."
    # exit 1
}
command -v ballerina >/dev/null 2>&1 || {
    log_warn "Ballerina was not found. Please install ballerina first."
    # exit 1
}

#Main script
log_info "Installer generating process started."

copyDarwinDirectory
copyBuildDirectory
createInstaller Debug debug-${VERSION}
createInstaller Release ${VERSION}

log_info "Installer generating process finished"
exit 0
