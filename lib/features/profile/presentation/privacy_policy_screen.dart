import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_scaling.dart';
import '../../../core/widgets/design_system.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final muted = dark ? Colors.white60 : AppColors.muted;
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(22.w, 16.h, 22.w, 30.h),
          children: [
            const ScreenHeading(
              title: 'Privacy',
              subtitle: 'How CareerPilot handles your resume information',
            ),
            SizedBox(height: 18.h),
            PremiumCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AccentIcon(Icons.lock_outline_rounded, size: 46),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Local-first by design',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          'CareerPilot is built to help you create resumes offline. Your resume content stays on your device unless you choose to sign in, sync, share, export, print, or use another device feature.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: muted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            PremiumCard(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PolicySection(
                    icon: Icons.badge_outlined,
                    title: 'Information you add',
                    body: 'Resume details such as your name, contact details, education, work experience, skills, projects, certifications, achievements, languages, interests, references, template choices, and profile photo are used to create your resumes and previews.',
                  ),
                  _PolicyDivider(),
                  _PolicySection(
                    icon: Icons.phone_android_rounded,
                    title: 'Device storage',
                    body: 'The app stores resume drafts, settings, template selections, onboarding status, and generated files locally so the app remains usable without an internet connection.',
                  ),
                  _PolicyDivider(),
                  _PolicySection(
                    icon: Icons.cloud_done_outlined,
                    title: 'Optional account features',
                    body: 'If you continue with Google, authentication information such as your name, email address, and profile photo may be used to show your account and enable optional cloud-related features.',
                  ),
                  _PolicyDivider(),
                  _PolicySection(
                    icon: Icons.ios_share_outlined,
                    title: 'Sharing and exports',
                    body: 'When you export, print, or share a resume, the selected PDF and its content are sent only to the system service or app you choose, such as a printer, email app, file manager, or messaging app.',
                  ),
                  _PolicyDivider(),
                  _PolicySection(
                    icon: Icons.wifi_off_rounded,
                    title: 'Offline use',
                    body: 'Core resume creation, preview, and export features are intended to work offline. Some optional features, including sign-in and external sharing destinations, may require internet access.',
                  ),
                  _PolicyDivider(),
                  _PolicySection(
                    icon: Icons.security_rounded,
                    title: 'Your control',
                    body: 'You can edit or remove resume information inside the app. You can also sign out at any time from the Profile screen. Files you export or share are controlled by the destination app or location you selected.',
                  ),
                  _PolicyDivider(),
                  _PolicySection(
                    icon: Icons.business_rounded,
                    title: 'Contact',
                    body:
                        'For privacy questions about CareerPilot, contact ${AppConstants.developerName}.',
                  ),
                ],
              ),
            ),
            SizedBox(height: 14.h),
            Text(
              'Last updated: September 17, 2026',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: dark ? Colors.white38 : AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  const _PolicySection({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: dark ? AppColors.amber : AppColors.ink, size: 22.r),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 6.h),
              Text(
                body,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: dark ? Colors.white60 : AppColors.muted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PolicyDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(vertical: 16.h),
    child: Divider(height: 1.h),
  );
}
