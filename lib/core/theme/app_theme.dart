import 'package:flutter/material.dart';

import '../utils/app_scaling.dart';

class AppColors {
  AppColors._();
  static const ink = Color(0xFF111111);
  static const charcoal = Color(0xFF2F2F2F);
  static const canvas = Color(0xFFF6F6F6);
  static const amber = Color(0xFFFFCB74);
  static const amberDeep = Color(0xFFF4B649);
  static const muted = Color(0xFF737373);
  static const line = Color(0xFFE8E8E8);
  static const success = Color(0xFF42A968);
  static const danger = Color(0xFFD84B4B);
  static const darkCanvas = Color(0xFF111111);
  static const darkSurface = Color(0xFF1B1B1B);
  static const darkSurface2 = Color(0xFF242424);
}

class AppTheme {
  AppTheme._();
  static const fontFamily = 'Urbanist';

  static ThemeData light(double textScaleFactor) => _build(Brightness.light);
  static ThemeData dark(double textScaleFactor) => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.amber,
      onPrimary: AppColors.ink,
      secondary: AppColors.amberDeep,
      onSecondary: AppColors.ink,
      error: AppColors.danger,
      onError: Colors.white,
      surface: dark ? AppColors.darkSurface : Colors.white,
      onSurface: dark ? Colors.white : AppColors.ink,
    );
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: dark ? AppColors.darkCanvas : AppColors.canvas,
      fontFamily: fontFamily,
      splashFactory: InkSparkle.splashFactory,
    );
    final textTheme = base.textTheme
        .apply(fontFamily: fontFamily)
        .copyWith(
          headlineLarge: base.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
          headlineMedium: base.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
          titleLarge: base.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
          titleMedium: base.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          bodyLarge: base.textTheme.bodyLarge?.copyWith(height: 1.35),
          bodyMedium: base.textTheme.bodyMedium?.copyWith(height: 1.35),
        );
    final surface = dark ? AppColors.darkSurface : Colors.white;
    final border = dark ? const Color(0xFF353535) : AppColors.line;
    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: dark ? AppColors.darkCanvas : AppColors.canvas,
        foregroundColor: dark ? Colors.white : AppColors.ink,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: dark ? Colors.white : AppColors.ink,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
          side: BorderSide(color: border.withValues(alpha: dark ? .9 : .55)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? AppColors.darkSurface2 : Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
        hintStyle: TextStyle(color: dark ? Colors.white38 : Colors.black38),
        labelStyle: TextStyle(color: dark ? Colors.white60 : AppColors.muted),
        prefixIconColor: dark ? Colors.white60 : AppColors.charcoal,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: const BorderSide(color: AppColors.amberDeep, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: Size.fromHeight(54.h),
          backgroundColor: AppColors.amber,
          foregroundColor: AppColors.ink,
          disabledBackgroundColor: AppColors.amber.withValues(alpha: .45),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.r),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: Size.fromHeight(52.h),
          foregroundColor: dark ? Colors.white : AppColors.ink,
          side: BorderSide(color: border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.r),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.amber,
        foregroundColor: AppColors.ink,
        elevation: 6,
        shape: StadiumBorder(),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: dark ? const Color(0xFF171717) : Colors.white,
        indicatorColor: dark
            ? const Color(0xFF493817)
            : const Color(0xFFFFE9BE),
        height: 76.h,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            color: states.contains(WidgetState.selected)
                ? (dark ? AppColors.amber : AppColors.ink)
                : (dark ? Colors.white60 : AppColors.muted),
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w800
                : FontWeight.w600,
            fontSize: 12,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? (dark ? AppColors.amber : AppColors.ink)
                : (dark ? Colors.white60 : AppColors.muted),
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color?>(
          (states) =>
              states.contains(WidgetState.selected) ? AppColors.ink : null,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.amber
              : (dark ? Colors.white24 : Colors.black12),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: dark ? AppColors.darkSurface : Colors.white,
        modalBackgroundColor: dark ? AppColors.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
        ),
        showDragHandle: true,
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 1),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.amber,
      ),
    );
  }
}
