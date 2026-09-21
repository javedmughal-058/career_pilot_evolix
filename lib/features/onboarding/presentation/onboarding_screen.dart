import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_scaling.dart';
import '../../../core/widgets/app_logo.dart';
import '../../home/presentation/home_shell.dart';
import '../../settings/presentation/settings_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _index = 0;
  bool _didPrecache = false;

  static const _pages = [
    (
      'assets/branding/onboard-1.png',
      'Create a standout resume in minutes',
      'Choose a professional template, add your career story and export a polished PDF.',
      ['Professional templates', 'Easy section editor', 'PDF export'],
    ),
    (
      'assets/branding/onboard-2.png',
      'Your resume works offline',
      'Create, edit and preview resumes without an account or internet connection. Your local copy always stays available.',
      ['Local-first storage', 'No sign-in required', 'Fast offline editing'],
    ),
    (
      'assets/branding/onboard-3.png',
      'Make every resume your own',
      'Reorder sections, hide anything you do not need and switch templates without losing your information.',
      ['Hide or show sections', 'Reorder content', 'Switch designs anytime'],
    ),
    (
      'assets/branding/onboard-4.png',
      'Sync only when you want to',
      'Google sign-in is optional. If you choose it, CareerPilot can back up your local resumes with Firebase.',
      [
        'Optional Google sign-in',
        'Firebase cloud backup',
        'Local data remains usable',
      ],
    ),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didPrecache) return;
    _didPrecache = true;
    for (final page in _pages) {
      precacheImage(AssetImage(page.$1), context);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await context.read<SettingsProvider>().completeOnboarding();
    if (!mounted) return;
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => const HomeShell()));
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(22.w, 12.h, 18.w, 0),
              child: Row(
                children: [
                  const CareerPilotLogoMark(size: 44, radius: 14),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CareerPilot',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        Text(
                          'Resume Builder',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _finish,
                    child: Text(
                      'Skip',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: dark ? Colors.white70 : AppColors.charcoal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (v) => setState(() => _index = v),
                itemCount: _pages.length,
                itemBuilder: (_, i) {
                  final p = _pages[i];
                  return Padding(
                    padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 6.h),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: dark
                            ? AppColors.darkSurface
                            : Colors.white,
                        borderRadius: BorderRadius.circular(32.r),
                        boxShadow: dark
                            ? null
                            : [
                                BoxShadow(
                                  color: Colors.black.withValues(
                                    alpha: .04,
                                  ),
                                  blurRadius: 30.r,
                                  offset: Offset(0, 12.h),
                                ),
                              ],
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16.r),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(34.r),
                            child: Image.asset(
                              p.$1,
                              width: 256.w,
                              height: 256.h,
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.high,
                            ),
                          ),
                          SizedBox(height: 36.h),
                          Text(
                            p.$2,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(fontSize: 24),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            p.$3,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: dark
                                      ? Colors.white60
                                      : AppColors.muted,
                                ),
                          ),
                          SizedBox(height: 12.h),
                          // for (final item in p.$4)
                          //   Padding(
                          //     padding: EdgeInsets.only(bottom: 10.h),
                          //     child: Row(
                          //       mainAxisAlignment:
                          //           MainAxisAlignment.center,
                          //       children: [
                          //         Icon(
                          //           Icons.check_circle_rounded,
                          //           color: AppColors.amberDeep,
                          //           size: 20.r,
                          //         ),
                          //         SizedBox(width: 8.w),
                          //         Text(
                          //           item,
                          //           style: Theme.of(context)
                          //               .textTheme
                          //               .labelLarge
                          //               ?.copyWith(
                          //                 fontWeight: FontWeight.w700,
                          //               ),
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 24.h),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        width: i == _index ? 28.w : 8.w,
                        height: 8.h,
                        decoration: BoxDecoration(
                          color: i == _index
                              ? AppColors.amberDeep
                              : (dark ? Colors.white24 : Colors.black12),
                          borderRadius: BorderRadius.circular(99.r),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  FilledButton(
                    onPressed: () async {
                      if (_index == _pages.length - 1) return await _finish();
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _index == _pages.length - 1
                              ? 'Get Started'
                              : 'Continue',
                        ),
                        SizedBox(width: 10.w),
                        const Icon(Icons.arrow_forward_rounded),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
