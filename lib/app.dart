import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/utils/app_scaling.dart';
import 'features/settings/presentation/settings_provider.dart';
import 'features/splash/presentation/splash_screen.dart';

class CareerPilotApp extends StatelessWidget {
  const CareerPilotApp({super.key});
  @override
  Widget build(BuildContext c) {
    final s = c.watch<SettingsProvider>();
    if (!s.ready) {
      return MaterialApp(
        navigatorKey: globalNavigatorKey,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(1),
        darkTheme: AppTheme.dark(1),
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }
    return MaterialApp(
      navigatorKey: globalNavigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'CareerPilot - Resume Builder',
      theme: AppTheme.light(s.settings.textScale),
      darkTheme: AppTheme.dark(s.settings.textScale),
      themeMode: s.settings.darkMode ? ThemeMode.dark : ThemeMode.light,
      builder: (context, child) {
        final dark = Theme.of(context).brightness == Brightness.dark;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
            statusBarBrightness: dark ? Brightness.dark : Brightness.light,
            systemNavigationBarColor: dark
                ? AppColors.darkCanvas
                : AppColors.canvas,
            systemNavigationBarIconBrightness: dark
                ? Brightness.light
                : Brightness.dark,
          ),
          child: MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(s.settings.textScale)),
            child: child!,
          ),
        );
      },
      home: const SplashScreen(),
    );
  }
}
