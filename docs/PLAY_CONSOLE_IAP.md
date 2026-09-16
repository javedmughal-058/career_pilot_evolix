# Google Play Console IAP

Create one-time in-app products matching the IDs in `AppConstants`.

Recommended catalog:

| Product ID | Purpose |
|---|---|
| careerpilot_template_executive | Executive template |
| careerpilot_template_signature | Signature template |
| careerpilot_template_tech | Tech template |
| careerpilot_pro_templates | Unlock all current premium templates |

Upload an Android App Bundle to Internal Testing, add license testers, activate products, then install from the Play test link. Use `restorePurchases()` for previously-owned non-consumables.

For production security, send `PurchaseDetails.verificationData.serverVerificationData` to a trusted server and verify with Google Play Developer API before writing permanent entitlements to a backend account.
