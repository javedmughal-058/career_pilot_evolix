@echo off
flutter --version
if errorlevel 1 exit /b 1
flutter create . --platforms=android,ios --org com.evolixtechnologies
if errorlevel 1 exit /b 1
flutter pub get
if errorlevel 1 exit /b 1
echo Platform folders generated. Next run: flutterfire configure
