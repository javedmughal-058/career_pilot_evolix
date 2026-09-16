#!/usr/bin/env sh
set -eu
flutter --version
flutter create . --platforms=android,ios --org com.evolixtechnologies
flutter pub get
echo "Platform folders generated. Next run: flutterfire configure"
