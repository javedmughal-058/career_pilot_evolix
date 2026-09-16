# Flutter 3.47.0 compatibility

This source tree targets:

- Flutter: 3.47.0 or newer within the 3.x line
- Dart: 3.13.x or newer, below Dart 4
- State management: Provider
- Architecture: feature-first clean architecture

`pubspec.yaml` intentionally declares both SDK constraints:

```yaml
environment:
  sdk: '>=3.13.0 <4.0.0'
  flutter: '>=3.47.0'
```

## Bootstrap platform folders with your installed Flutter SDK

The source archive is SDK-independent and does not contain generated Android/iOS build folders. Generate those folders with your own Flutter 3.47.0 installation so Gradle, AGP, Kotlin, iOS project files and plugin registrants match that SDK exactly.

From the project root:

```bash
flutter --version
flutter create . --platforms=android,ios --org com.evolixtechnologies
flutter pub get
```

Then configure Firebase:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

When `flutterfire configure` creates `lib/firebase_options.dart`, update `lib/main.dart` to initialize Firebase with `DefaultFirebaseOptions.currentPlatform` if desired. Native google-services files also work when configured correctly.

## Android application id

After platform generation, set a final unique application id before registering Firebase / Play Console products, for example:

`com.evolixtechnologies.careerpilot`

Do not change it after creating production Firebase and Play Console records unless you intend to create a separate app.

## IAP

Product IDs expected by the sample are located in:

`lib/core/constants/app_constants.dart`

Create matching one-time products in Google Play Console. Premium templates are non-consumable entitlements.

## Offline-first note

Resume creation, local editing, section configuration, template selection and PDF generation do not require authentication. Firebase is only initialized for optional sync/auth. If Firebase configuration is absent during early UI development, temporarily guard initialization or add your project configuration before launching.

## Urbanist font

Urbanist is bundled locally under `assets/fonts/urbanist/` and configured in `pubspec.yaml` with normal and italic weights from 100 through 900. The app theme and PDF export use these bundled files, so font rendering does not depend on runtime network access.
