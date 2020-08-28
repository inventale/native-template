makeRelease() {
    cp ../../app/build/bin/mingw/native-template${2}Executable/native-template.exe target/app/
    echo --- collecting dlls
    for i in $(ldd target/app/native-template.exe | grep /mingw64 | sed 's/.dll.*/.dll/' | sed 's/^[ \t]*//'); do
        cp c:/msys64/mingw64/bin/$i target/dlls/
        echo "$i"
    done
    echo --- build instalator
    iscc native-template.iss -DMyAppVersion=$1
}


rm -rf target
mkdir target
mkdir target/app
mkdir target/dlls
mkdir target/ssl
mkdir target/ssl/certs
cp c:/msys64/mingw64/ssl/certs/ca-bundle.crt target/ssl/certs/

makeRelease debug-$1 Debug
makeRelease $1 Release
