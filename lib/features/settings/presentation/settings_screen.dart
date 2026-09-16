import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../domain/app_settings.dart';
import 'settings_provider.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../purchases/presentation/purchase_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext c) {
    final s = c.watch<SettingsProvider>().settings;
    final auth = c.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Appearance', style: Theme.of(c).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.text_fields),
                  title: const Text('Font Size'),
                  subtitle: Text(
                    '${s.fontSize.name[0].toUpperCase()}${s.fontSize.name.substring(1)}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _fontSize(c),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.font_download_outlined),
                  title: Text('App Font'),
                  subtitle: Text('Urbanist'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Data & Sync', style: Theme.of(c).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.cloud_sync_outlined),
                  title: Text(auth.isSignedIn ? 'Sync now' : 'Cloud backup'),
                  subtitle: Text(
                    auth.isSignedIn
                        ? 'Signed in as ${auth.user?.email ?? ''}'
                        : 'Optional — Google Sign-In',
                  ),
                  trailing: auth.busy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.chevron_right),
                  onTap: auth.isSignedIn ? auth.syncNow : auth.signIn,
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.phone_android),
                  title: Text('Local data'),
                  subtitle: Text('Resume creation works fully offline'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Purchases', style: Theme.of(c).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.restore),
              title: const Text('Restore purchases'),
              subtitle: const Text(
                'Restore premium templates from Google Play',
              ),
              onTap: () => c.read<PurchaseProvider>().restore(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _fontSize(BuildContext c) => showModalBottomSheet(
    context: c,
    builder: (x) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Font Size', style: Theme.of(x).textTheme.titleLarge),
            const SizedBox(height: 10),
            for (final v in AppFontSize.values)
              RadioListTile<AppFontSize>(
                value: v,
                groupValue: c.read<SettingsProvider>().settings.fontSize,
                title: Text(v.name[0].toUpperCase() + v.name.substring(1)),
                subtitle: Text(
                  v == AppFontSize.medium
                      ? 'Recommended / default'
                      : 'Preview text size',
                ),
                onChanged: (n) {
                  if (n != null) {
                    c.read<SettingsProvider>().setFontSize(n);
                    Navigator.pop(x);
                  }
                },
              ),
          ],
        ),
      ),
    ),
  );
}
