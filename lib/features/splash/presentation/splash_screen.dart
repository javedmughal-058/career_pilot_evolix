import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_scaling.dart';
import '../../../core/widgets/app_logo.dart';
import '../../home/presentation/home_shell.dart';
import '../../onboarding/presentation/onboarding_screen.dart';
import '../../settings/presentation/settings_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    Timer(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      final seen = context.read<SettingsProvider>().settings.onboardingSeen;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 350),
          pageBuilder: (_, _, _) =>
              seen ? const HomeShell() : const OnboardingScreen(),
          transitionsBuilder: (_, a, _, child) =>
              FadeTransition(opacity: a, child: child),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: CurvedAnimation(parent: _controller, curve: Curves.easeOut),
          child: Padding(
            padding: EdgeInsets.all(28.r),
            child: Column(
              children: [
                const Spacer(flex: 2),
                ScaleTransition(
                  scale: Tween(begin: .86, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _controller,
                      curve: Curves.easeOutBack,
                    ),
                  ),
                  child: const CareerPilotLogoMark(
                    size: 84,
                    radius: 26,
                    shadow: true,
                  ),
                ),
                SizedBox(height: 22.h),
                Text(
                  'CareerPilot',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text(
                  'Resume Builder',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: dark ? Colors.white54 : AppColors.muted,
                  ),
                ),
                const Spacer(),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20.r),
                  margin: EdgeInsets.only(bottom: 20.h),
                  // decoration: BoxDecoration(
                  //   color: dark ? AppColors.darkSurface : Colors.white,
                  //   borderRadius: BorderRadius.circular(24.r),
                  // ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.description_outlined,
                        size: 52.r,
                        color: AppColors.amberDeep,
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'Build resumes that open doors.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        'Simple. Professional. Offline-first.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: dark ? Colors.white54 : AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                // const Spacer(flex: 2),
                SizedBox(
                  width: 180.w,
                  child: LinearProgressIndicator(
                    minHeight: 5.h,
                    borderRadius: BorderRadius.all(Radius.circular(99.r)),
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  'Loading your future...',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: dark ? Colors.white38 : AppColors.muted,
                  ),
                ),
                SizedBox(height: 18.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
