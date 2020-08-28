#!/usr/bin/env bash
set -e
set -x
export VERSION=1.0.0
./gradlew -Dorg.gradle.daemon=false assemble || exit 1
cd installer/macos || exit 1
echo building version $VERSION
./make.sh $VERSION || exit 1
cd ../../

echo "==============================================="
echo "== VERSION: $VERSION"
echo "==============================================="
