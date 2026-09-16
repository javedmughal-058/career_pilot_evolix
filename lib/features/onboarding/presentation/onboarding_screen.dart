import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/app_logo.dart';
import '../../settings/presentation/settings_provider.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(),
            const CareerPilotLogo(),
            const SizedBox(height: 32),
            Text(
              'Create a resume that gets noticed.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'Build offline, customize every section, choose professional templates and export your PDF without creating an account.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge
                  ?.copyWith(color: Colors.blueGrey),
            ),
            const SizedBox(height: 30),
            for (final item in const [
              (
                Icons.offline_bolt_outlined,
                'Works offline',
                'Your resume stays available on this device.',
              ),
              (
                Icons.tune,
                'Flexible sections',
                'Enable, disable and reorder every section.',
              ),
              (
                Icons.cloud_sync_outlined,
                'Optional sync',
                'Sign in with Google only when you want cloud backup.',
              ),
            ])
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(child: Icon(item.$1)),
                title: Text(
                  item.$2,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(item.$3),
              ),
            const Spacer(),
            FilledButton(
              onPressed: () async {
                await context.read<SettingsProvider>().completeOnboarding();
              },
              child: const Text('Start building'),
            ),
            const SizedBox(height: 8),
            Text(
              'Your data. Your choice.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    ),
  );
}
