#!/bin/bash

flutter channel beta
flutter upgrade
cp web/index.html web/index.html.bak
cp web/index.html.wasm-test web/index.html
flutter build web --wasm
cp web/index.html.bak web/index.html
rm web/index.html.bak
if [ $? -ne 0 ]; then
  exit 1
fi
flutter pub global activate dhttpd
cd build/web
dhttpd '--headers=Cross-Origin-Embedder-Policy=credentialless;Cross-Origin-Opener-Policy=same-origin' -p 8080
