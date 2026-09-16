import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'features/settings/presentation/settings_provider.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'features/home/presentation/home_shell.dart';

class CareerPilotApp extends StatelessWidget {
  const CareerPilotApp({super.key});
  @override
  Widget build(BuildContext c) {
    final s = c.watch<SettingsProvider>();
    if (!s.ready) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CareerPilot',
      theme: AppTheme.light(s.settings.textScale),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(s.settings.textScale)),
        child: child!,
      ),
      home: s.settings.onboardingSeen
          ? const HomeShell()
          : const OnboardingScreen(),
    );
  }
}
