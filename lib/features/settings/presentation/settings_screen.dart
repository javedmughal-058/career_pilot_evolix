import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_scaling.dart';
import '../../../core/widgets/design_system.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../purchases/presentation/purchase_provider.dart';
import '../domain/app_settings.dart';
import 'settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext c) {
    final provider = c.watch<SettingsProvider>();
    final s = provider.settings;
    final auth = c.watch<AuthProvider>();
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(22.w, 22.h, 22.w, 28.h),
          children: [
            const ScreenHeading(
              title: 'Settings',
              subtitle: 'Customize your CareerPilot experience',
            ),
            SizedBox(height: 26.h),
            _section(c, 'Appearance', Icons.wb_sunny_outlined, [
              ListTile(
                leading: const AccentIcon(Icons.dark_mode_outlined, size: 42),
                title: Text(
                  'Dark mode',
                  style: Theme.of(c).textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(s.darkMode ? 'On' : 'Off'),
                trailing: Switch(
                  value: s.darkMode,
                  onChanged: provider.setDarkMode,
                ),
              ),
              Divider(height: 1.h),
              ListTile(
                leading: const AccentIcon(Icons.text_fields_rounded, size: 42),
                title: Text(
                  'Font size',
                  style: Theme.of(c).textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(_fontLabel(s.fontSize)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _fontSize(c),
              ),
              Divider(height: 1.h),
              ListTile(
                leading: const AccentIcon(
                  Icons.font_download_outlined,
                  size: 42,
                ),
                title: Text(
                  'App font',
                  style: Theme.of(c).textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                subtitle: const Text('Urbanist'),
              ),
            ]),
            SizedBox(height: 18.h),
            _section(c, 'Data & Sync', Icons.cloud_outlined, [
              ListTile(
                leading: const AccentIcon(Icons.cloud_sync_outlined, size: 42),
                title: Text(
                  auth.isSignedIn ? 'Sync now' : 'Cloud backup',
                  style: Theme.of(c).textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(
                  auth.isSignedIn
                      ? 'Signed in as ${auth.user?.email ?? ''}'
                      : 'Optional · Google Sign-In',
                ),
                trailing: auth.busy
                    ? SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.chevron_right_rounded),
                onTap: auth.busy
                    ? null
                    : () => _runAuthAction(
                        c,
                        (provider) => provider.isSignedIn
                            ? provider.syncNow()
                            : provider.signIn(),
                      ),
              ),
              Divider(height: 1.h),
              ListTile(
                leading: const AccentIcon(
                  Icons.phone_android_rounded,
                  size: 42,
                ),
                title: Text(
                  'Local data',
                  style: Theme.of(c).textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                subtitle: const Text('Resume creation works fully offline'),
              ),
            ]),
            SizedBox(height: 18.h),
            _section(c, 'Purchases', Icons.shopping_bag_outlined, [
              ListTile(
                leading: const AccentIcon(Icons.restore_rounded, size: 42),
                title: Text(
                  'Restore purchases',
                  style: Theme.of(c).textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                subtitle: const Text(
                  'Restore premium templates from Google Play',
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => c.read<PurchaseProvider>().restore(),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Future<void> _runAuthAction(
    BuildContext context,
    Future<void> Function(AuthProvider provider) action,
  ) async {
    final provider = context.read<AuthProvider>();
    await action(provider);
    if (!context.mounted || provider.error == null) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(provider.error!)));
  }

  Widget _section(
    BuildContext c,
    String title,
    IconData icon,
    List<Widget> children,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          // Icon(icon, size: 20.r, color: AppColors.amberDeep),
          SizedBox(width: 8.w),
          Text(title, style: Theme.of(c).textTheme.titleMedium),
        ],
      ),
      SizedBox(height: 10.h),
      PremiumCard(
        padding: EdgeInsets.zero,
        child: Column(children: children),
      ),
    ],
  );

  String _fontLabel(AppFontSize v) => switch (v) {
    AppFontSize.small => 'Small',
    AppFontSize.medium => 'Medium',
    AppFontSize.large => 'Large',
    AppFontSize.extraLarge => 'Extra Large',
  };

  Future<void> _fontSize(BuildContext c) => showModalBottomSheet(
    context: c,
    builder: (x) {
      final current = x.watch<SettingsProvider>().settings.fontSize;
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(22.w, 4.h, 22.w, 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Font Size', style: Theme.of(x).textTheme.titleLarge),
              SizedBox(height: 10.h),
              for (final v in AppFontSize.values)
                RadioListTile<AppFontSize>(
                  value: v,
                  groupValue: current,
                  activeColor: AppColors.amberDeep,
                  title: Text(
                    _fontLabel(v),
                    style: Theme.of(x).textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    v == AppFontSize.medium
                        ? 'Recommended / default'
                        : 'Preview text size',
                  ),
                  onChanged: (n) async {
                    if (n != null) {
                      await c.read<SettingsProvider>().setFontSize(n);
                      if (x.mounted) Navigator.pop(x);
                    }
                  },
                ),
            ],
          ),
        ),
      );
    },
  );
}
