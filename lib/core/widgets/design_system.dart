import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/app_scaling.dart';

class PremiumCard extends StatelessWidget {
  const PremiumCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.highlighted = false,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final radius = BorderRadius.circular(24.r);
    final shape = RoundedRectangleBorder(
      borderRadius: radius,
      side: BorderSide(
        color: highlighted
            ? AppColors.amberDeep
            : (dark ? const Color(0xFF363636) : AppColors.line),
      ),
    );
    final content = Padding(
      padding: padding ?? EdgeInsets.all(12.r),
      child: child,
    );
    final surface = Material(
      color: dark ? AppColors.darkSurface : Colors.white,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: onTap == null ? content : InkWell(onTap: onTap, child: content),
    );

    if (dark) return surface;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .04),
            blurRadius: 20.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: surface,
    );
  }
}

class AccentIcon extends StatelessWidget {
  const AccentIcon(this.icon, {super.key, this.size = 48});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size.w,
    height: size.h,
    decoration: BoxDecoration(
      color: AppColors.amber.withValues(alpha: .28),
      borderRadius: BorderRadius.circular((size * .32).r),
    ),
    child: Icon(
      icon,
      color: Theme.of(context).brightness == Brightness.dark
          ? AppColors.amber
          : AppColors.ink,
      size: (size * .46).r,
    ),
  );
}

class ScreenHeading extends StatelessWidget {
  const ScreenHeading({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium
                  ?.copyWith(fontSize: 30),
            ),
            if (subtitle != null) ...[
              SizedBox(height: 4.h),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white60
                      : AppColors.muted,
                ),
              ),
            ],
          ],
        ),
      ),
      if (trailing != null) trailing!,
    ],
  );
}

class StatusPill extends StatelessWidget {
  const StatusPill(this.text, {super.key, this.premium = false});

  final String text;
  final bool premium;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
    decoration: BoxDecoration(
      color: premium
          ? AppColors.amber.withValues(alpha: .30)
          : AppColors.success.withValues(alpha: .14),
      borderRadius: BorderRadius.circular(999.r),
    ),
    child: Text(
      text,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: premium
            ? (Theme.of(context).brightness == Brightness.dark
                  ? AppColors.amber
                  : const Color(0xFF8A5612))
            : AppColors.success,
      ),
    ),
  );
}
