import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_scaling.dart';
import '../../../core/widgets/design_system.dart';
import '../../auth/presentation/auth_provider.dart';
import 'privacy_policy_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext c) {
    final a = c.watch<AuthProvider>();
    final dark = Theme.of(c).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(22.w, 22.h, 22.w, 30.h),
          children: [
            const ScreenHeading(
              title: 'Profile',
              subtitle: 'Account, privacy and app information',
            ),
            SizedBox(height: 24.h),
            PremiumCard(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48.r,
                    backgroundColor: AppColors.amber.withValues(alpha: .35),
                    backgroundImage: a.user?.photoURL != null
                        ? NetworkImage(a.user!.photoURL!)
                        : null,
                    child: a.user?.photoURL == null
                        ? Icon(
                            Icons.person_outline_rounded,
                            size: 48.r,
                            color: dark ? AppColors.amber : AppColors.ink,
                          )
                        : null,
                  ),
                  SizedBox(height: 14.h),
                  Text(
                    a.user?.displayName ?? 'Guest user',
                    style: Theme.of(c).textTheme.titleLarge,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    a.user?.email ?? 'Build resumes without signing in',
                    textAlign: TextAlign.center,
                    style: Theme.of(c).textTheme.bodyMedium?.copyWith(
                      color: dark ? Colors.white60 : AppColors.muted,
                    ),
                  ),
                  SizedBox(height: 18.h),
                  if (!a.isSignedIn)
                    OutlinedButton.icon(
                      onPressed: a.busy
                          ? null
                          : () => _runAuthAction(c, (auth) => auth.signIn()),
                      icon: const Icon(Icons.login_rounded),
                      label: const Text('Continue with Google'),
                    )
                  else
                    OutlinedButton.icon(
                      onPressed: a.busy ? null : a.signOut,
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Sign out'),
                    ),
                ],
              ),
            ),
            SizedBox(height: 18.h),
            PremiumCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    onTap: () => Navigator.push(
                      c,
                      MaterialPageRoute(
                        builder: (_) => const PrivacyPolicyScreen(),
                      ),
                    ),
                    leading: const AccentIcon(Icons.shield_outlined, size: 42),
                    title: Text(
                      'Privacy',
                      style: Theme.of(c).textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    subtitle: const Text(
                      'Local-first. Cloud sync is optional.',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                  ),
                  Divider(height: 1.h),
                  ListTile(
                    leading: const AccentIcon(
                      Icons.phone_android_rounded,
                      size: 42,
                    ),
                    title: Text(
                      'Local-first data',
                      style: Theme.of(c).textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    subtitle: const Text('Your resume stays usable offline.'),
                  ),
                  Divider(height: 1.h),
                  ListTile(
                    leading: const AccentIcon(
                      Icons.info_outline_rounded,
                      size: 42,
                    ),
                    title: Text(
                      'About CareerPilot',
                      style: Theme.of(c).textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    subtitle: const Text(
                      'Professional offline-first resume builder',
                    ),
                    trailing: const Text('v1.0.0'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30.h),
            Center(
              child: Column(
                children: [
                  Text(
                    'Developed by',
                    style: Theme.of(c).textTheme.bodySmall?.copyWith(
                      color: dark ? Colors.white38 : AppColors.muted,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Image.asset(
                    'assets/branding/evolix_logo.png',
                    height: 42.h,
                    errorBuilder: (_, _, _) => Text(
                      AppConstants.developerName,
                      style: Theme.of(c).textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Simple tools. Brighter careers.',
                    style: Theme.of(c).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
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
}
