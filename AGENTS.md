# CareerPilot Agent Guidelines

## Project Structure

- Keep shared app infrastructure in `lib/core/`.
- Keep feature-owned UI, data, domain, and provider code in `lib/features/<feature>/`.
- Put reusable utilities in `lib/core/utils/`.
- Put shared visual components in `lib/core/widgets/`.
- Keep static app assets under `assets/` and register folders in `pubspec.yaml`.
- Do not place feature-specific logic in `main.dart` or `app.dart`; use those files for app bootstrapping, providers, theme, routing, and shell setup.

## Responsive Layout

- Use `lib/core/utils/app_scaling.dart` for layout measurements.
- Do not add hardcoded mobile layout dimensions directly in widgets.
- Use `.w` for widths and horizontal spacing.
- Use `.h` for heights and vertical spacing.
- Use `.r` for border radius, circular sizes, icon sizes, shadows, and other scale-neutral dimensions.
- Keep font sizes controlled by the app settings text scale and theme. Do not convert normal app font sizes to `.sp` unless a future product decision explicitly changes text scaling strategy.
- Prefer text styles from `Theme.of(context).textTheme`; only override weight/color/size when the design needs it.
- Do not hardcode Flutter widget `TextStyle(...)` in feature UI. Always start from `Theme.of(context).textTheme` and use `.copyWith(...)` for local color/weight tweaks. The theme file itself and PDF `pw.TextStyle` definitions are exceptions.

## Assets

- Use bundled assets for offline support.
- Precache important bitmap assets before first display when they appear in splash, onboarding, logos, or template galleries.
- Use `Image.asset` for local UI artwork and thumbnails.

## Future Deployment

- Keep Android `compileSdk` and `targetSdk` aligned with the project requirement.
- Release builds must use the configured signing setup from `android/key.properties`.
- Do not commit keystores, `.p12`, `.jks`, `.keystore`, or real signing passwords.
- Keep ProGuard/R8 rules in `android/app/proguard-rules.pro` and update them when adding SDKs that require keep rules.
- Run formatting and targeted analyzer checks before handing off UI or build changes.
