import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/app_scaling.dart';

class CareerPilotLogoMark extends StatefulWidget {
  const CareerPilotLogoMark({
    super.key,
    required this.size,
    this.radius,
    this.shadow = false,
  });

  static const assetPath = 'assets/branding/app_logo.png';

  final double size;
  final double? radius;
  final bool shadow;

  @override
  State<CareerPilotLogoMark> createState() => _CareerPilotLogoMarkState();
}

class _CareerPilotLogoMarkState extends State<CareerPilotLogoMark> {
  bool _didPrecache = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didPrecache) return;
    _didPrecache = true;
    precacheImage(const AssetImage(CareerPilotLogoMark.assetPath), context);
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.radius ?? widget.size * .3;
    return Container(
      width: widget.size.w,
      height: widget.size.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius.r),
        boxShadow: widget.shadow
            ? [
                BoxShadow(
                  color: AppColors.amber.withValues(alpha: .24),
                  blurRadius: 34.r,
                  spreadRadius: 6.r,
                ),
              ]
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        CareerPilotLogoMark.assetPath,
        width: widget.size.w,
        height: widget.size.h,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
        errorBuilder: (_, _, _) => DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.amber,
            borderRadius: BorderRadius.circular(radius.r),
          ),
          child: Center(
            child: Text(
              'CP',
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(color: AppColors.ink, fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ),
    );
  }
}

class CareerPilotLogo extends StatelessWidget {
  const CareerPilotLogo({super.key, this.compact = false});
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final logoSize = compact ? 40.0 : 58.0;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CareerPilotLogoMark(size: logoSize, radius: compact ? 13 : 18),
        SizedBox(width: 10.w),
        RichText(
          overflow: TextOverflow.ellipsis,
          text: TextSpan(
            style: Theme.of(context).textTheme.titleLarge,
            children: [
              TextSpan(
                text: 'Career',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: dark ? Colors.white : AppColors.ink,
                ),
              ),
              TextSpan(
                text: 'Pilot',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.amberDeep,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
