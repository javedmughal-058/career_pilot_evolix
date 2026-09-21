# CareerPilot 2026 UI refresh

The refreshed app follows the supplied premium black / charcoal / off-white / amber reference.

## Core palette
- Ink: `#111111`
- Charcoal: `#2F2F2F`
- Light canvas: `#F6F6F6`
- Accent amber: `#FFCB74`
- Accent deep: `#F4B649`

## Product behavior kept intact
- SQLite remains the source of truth. Resume building does not require authentication or network access.
- Google sign-in is optional and uses the existing Firebase Auth configuration.
- Firestore sync happens only for an authenticated user and does not replace local-first editing.
- Resume content is template-independent. Changing templates does not delete entered content.
- Every resume owns section visibility and ordering settings.
- PDF preview/export renders the currently selected template family and only enabled sections.

## UI architecture
- `AppTheme`: light and dark design tokens.
- `PremiumCard`, `AccentIcon`, `ScreenHeading`, `StatusPill`: reusable UI components.
- Flutter splash screen: premium CareerPilot loading experience.
- Multi-step onboarding: templates, offline-first behavior, flexible sections and optional cloud sync.

## Setup note
`image_picker` was added for local profile-photo selection. Run `flutter pub get` after opening the project.
