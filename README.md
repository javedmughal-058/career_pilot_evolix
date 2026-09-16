# CareerPilot
## Flutter 3.47.0 target

This revision is explicitly configured for **Flutter 3.47.0** and **Dart 3.13+**. See `docs/FLUTTER_3_47.md`.

On Windows you can bootstrap native folders with:

```bat
setup_flutter_3_47.bat
```

On macOS/Linux:

```bash
./setup_flutter_3_47.sh
```

The scripts generate Android/iOS platform projects using *your installed Flutter 3.47.0 SDK*, which is preferable to shipping stale generated Gradle/Xcode files.
 - Resume Builder

Production-oriented Flutter source for an **offline-first** resume builder using Provider + Clean Architecture.

## What is implemented

- Guest-first flow: no login required to create, edit, preview, export, duplicate or delete resumes.
- SQLite local persistence is the source of truth.
- Dynamic resume sections: enable/disable, reorder, and add custom sections.
- Multiple hard-coded resume templates with free/premium entitlement metadata.
- Template styling: accent color, font scale, page density and photo visibility.
- A4 PDF generation and share/print.
- Optional Google Sign-In using Firebase Authentication.
- Firestore sync only after the user opts in by signing in.
- Conflict-aware offline sync using `updatedAt` + local dirty flags.
- Google Play Billing integration through Flutter's official `in_app_purchase` plugin.
- Restore purchases.
- Adjustable app font size with Urbanist as the default family.
- Profile screen with **Developed by Evolix Technologies**.

## Important setup before running

This ZIP contains the complete Flutter/Dart application source and Android configuration snippets. The execution environment used to generate it does not contain the Flutter SDK, so native runner files were not machine-generated or compiled here.

1. Install current stable Flutter.
2. In this folder run `flutter create . --platforms=android,ios` if your IDE reports missing platform runner files.
3. Run `flutter pub get`.
4. Configure Firebase:
   - `dart pub global activate flutterfire_cli`
   - `flutterfire configure`
   - enable Google provider in Firebase Authentication
   - enable Firestore
5. Android Google Sign-In: register SHA-1/SHA-256 in Firebase and download the generated configuration through FlutterFire.
6. Google Play Console IAP: create the following **one-time products** (or change IDs in `lib/core/constants/app_constants.dart`):
   - `careerpilot_template_executive`
   - `careerpilot_template_signature`
   - `careerpilot_template_tech`
   - `careerpilot_pro_templates`
7. Test IAP from an Internal/Closed testing track with a licensed test account. Billing does not work like production from an arbitrary sideloaded debug APK.

## Purchase verification

The app grants a local entitlement after Google Play returns a purchased/restored transaction and completes the transaction. For a commercial release, verify Google Play purchase tokens on a trusted backend (Cloud Functions / your API) before permanently granting entitlements. A verification abstraction is isolated in `PurchaseService`, so server verification can be inserted without changing UI/providers.

## Offline architecture

`Presentation -> Providers -> Domain repositories -> Data repositories -> SQLite`

Firebase is intentionally an optional sync adapter; it is not required for app usage.

## Firestore structure

```
users/{uid}/resumes/{resumeId}
users/{uid}/meta/profile
```

Security rule baseline:

```
match /users/{userId}/{document=**} {
  allow read, write: if request.auth != null && request.auth.uid == userId;
}
```

## Branding / fonts

The app bundles Urbanist locally from `assets/fonts/urbanist/` and declares all normal/italic weights in `pubspec.yaml`, so typography works on first launch without network access.
