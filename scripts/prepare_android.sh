#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
if [ -d android ]; then echo 'Existing Android runner preserved.'; exit 0; fi
mq_tmp=$(mktemp -d)
flutter create --platforms=android --org edu.gsu.codingmaster --project-name movement_quest --no-pub "$mq_tmp"
cp -R "$mq_tmp/android" .
cp "$mq_tmp/.metadata" .
sed -i 's/android:label="movement_quest"/android:label="Movement Quest"/' android/app/src/main/AndroidManifest.xml
rm -rf "$mq_tmp"
