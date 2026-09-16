import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class CareerPilotLogo extends StatelessWidget {
  const CareerPilotLogo({super.key, this.compact = false});
  final bool compact;

  static const _assetPath = 'assets/branding/app_logo.png';

  @override
  Widget build(BuildContext context) {
    final logoSize = compact ? 38.0 : 56.0;
    final radius = compact ? 12.0 : 18.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Image.asset(
            _assetPath,
            width: logoSize,
            height: logoSize,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            errorBuilder: (_, _, _) =>
                _LogoFallback(size: logoSize, radius: radius),
          ),
        ),
        const SizedBox(width: 10),
        RichText(
          overflow: TextOverflow.ellipsis,
          text: TextSpan(
            style: Theme.of(context).textTheme.titleLarge,
            children: [
              const TextSpan(
                text: 'Career',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppTheme.ink,
                ),
              ),
              TextSpan(
                text: 'Pilot',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LogoFallback extends StatelessWidget {
  const _LogoFallback({required this.size, required this.radius});

  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [AppTheme.secondary, AppTheme.primary],
      ),
      borderRadius: BorderRadius.circular(radius),
    ),
    child: Icon(Icons.near_me_rounded, color: Colors.white, size: size * 0.54),
  );
}
