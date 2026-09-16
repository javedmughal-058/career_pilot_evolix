# Architecture

## Principles

1. Local SQLite is authoritative so guest/offline usage is never blocked by authentication or network state.
2. Domain entities do not import Firebase, SQLite, UI or billing packages.
3. Providers coordinate presentation state; infrastructure is injected.
4. Resume content is template-independent. A template only decides how the same `ResumeDocument` is rendered.
5. Section configuration belongs to each resume, allowing visibility and ordering to vary per document.
6. Cloud sync is opt-in and idempotent.
7. Premium access is entitlement-based, not UI-based.

## Feature folders

- `features/resume`: resume domain, persistence, editing and PDF export.
- `features/templates`: template metadata and selection.
- `features/auth`: optional Google sign-in.
- `features/sync`: Firestore synchronization.
- `features/purchases`: Google Play IAP and local entitlements.
- `features/settings`: app font size and local preferences.
- `features/profile`: account and developer information.

## Future backend-driven templates

Do not download executable Dart. Define a versioned JSON template schema such as:

```
{
  "id": "modern_v2",
  "renderer": "twoColumn",
  "version": 2,
  "premiumProductId": "...",
  "style": {"accent":"#2563EB","headingScale":1.0},
  "slots": ["personal","summary","experience","education","skills"]
}
```

Map `renderer` to a vetted Flutter/PDF renderer already shipped with the app. This keeps remote configuration safe and backwards-compatible.
