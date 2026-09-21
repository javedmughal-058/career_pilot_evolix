import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_scaling.dart';
import '../../../core/widgets/design_system.dart';
import '../../purchases/presentation/purchase_provider.dart';
import '../../resume/presentation/resume_provider.dart';
import '../domain/template_catalog.dart';

class TemplatePickerScreen extends StatelessWidget {
  const TemplatePickerScreen({super.key});

  @override
  Widget build(BuildContext c) {
    final r = c.watch<ResumeProvider>().current;
    final pay = c.watch<PurchaseProvider>();
    if (r == null) return const SizedBox();
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Template')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(20.w, 6.h, 20.w, 42.h),
        children: [
          Text(
            'Professional templates',
            style: Theme.of(c).textTheme.headlineMedium?.copyWith(fontSize: 28),
          ),
          SizedBox(height: 4.h),
          Text(
            'Switch designs at any time without losing your resume content.',
            style: Theme.of(c).textTheme.bodyMedium
                ?.copyWith(color: AppColors.muted),
          ),
          SizedBox(height: 18.h),
          for (final t in TemplateCatalog.templates) ...[
            PremiumCard(
              highlighted: t.isAvailable && r.templateId == t.id,
              onTap: () async {
                if (!t.isAvailable) return;
                if (t.isPremium && !pay.owns(t.productId)) {
                  await _pay(c, t, pay);
                  if (!pay.owns(t.productId) || !c.mounted) return;
                }
                await c.read<ResumeProvider>().save(
                  r.copyWith(templateId: t.id, accentColor: t.defaultAccent),
                );
              },
              child: Row(
                children: [
                  _TemplatePreview(template: t),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.name, style: Theme.of(c).textTheme.titleMedium),
                        SizedBox(height: 5.h),
                        Text(
                          t.description,
                          style: Theme.of(c).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.muted),
                        ),
                        SizedBox(height: 10.h),
                        StatusPill(
                          t.isPremium
                              ? (pay.owns(t.productId) ? 'Owned' : 'Premium')
                              : 'Free',
                          premium: t.isPremium,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  !t.isAvailable
                      ? const Icon(Icons.lock_clock_rounded)
                      : r.templateId == t.id
                      ? CircleAvatar(
                          radius: 18.r,
                          backgroundColor: AppColors.amber,
                          child: const Icon(
                            Icons.check_rounded,
                            color: AppColors.ink,
                          ),
                        )
                      : const Icon(Icons.chevron_right_rounded),
                ],
              ),
            ),
            SizedBox(height: 12.h),
          ],
          SizedBox(height: 8.h),
          Text('Template settings', style: Theme.of(c).textTheme.titleLarge),
          SizedBox(height: 10.h),
          PremiumCard(
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Show profile photo'),
                  subtitle: const Text(
                    'Visible on templates that support photos',
                  ),
                  value: r.showPhoto,
                  onChanged: (v) =>
                      c.read<ResumeProvider>().save(r.copyWith(showPhoto: v)),
                ),
                Divider(height: 1.h),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Resume text size',
                        style: Theme.of(c).textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    Expanded(
                      child: Slider(
                        value: r.templateFontScale,
                        min: .85,
                        max: 1.15,
                        divisions: 6,
                        activeColor: AppColors.amberDeep,
                        onChanged: (v) => c.read<ResumeProvider>().save(
                          r.copyWith(templateFontScale: v),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pay(
    BuildContext c,
    ResumeTemplateInfo t,
    PurchaseProvider p,
  ) async {
    final ok = await showModalBottomSheet<bool>(
      context: c,
      builder: (x) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(22.w, 4.h, 22.w, 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Unlock ${t.name}', style: Theme.of(x).textTheme.titleLarge),
              SizedBox(height: 8.h),
              Text('One-time purchase - ${p.price(t.productId!)}'),
              SizedBox(height: 18.h),
              FilledButton(
                onPressed: () => Navigator.pop(x, true),
                child: const Text('Buy with Google Play'),
              ),
              TextButton(
                onPressed: () {
                  p.restore();
                  Navigator.pop(x, false);
                },
                child: const Text('Restore purchases'),
              ),
            ],
          ),
        ),
      ),
    );
    if (ok == true) {
      final started = await p.buy(t.productId!);
      if (!started && c.mounted && p.error != null) {
        ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(p.error!)));
      }
    }
  }
}

class _TemplatePreview extends StatelessWidget {
  const _TemplatePreview({required this.template});

  final ResumeTemplateInfo template;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(12.r),
    child: SizedBox(
      width: 92.w,
      height: 118.h,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ImageFiltered(
            imageFilter: template.isAvailable
                ? ui.ImageFilter.blur()
                : ui.ImageFilter.blur(sigmaX: 3.5, sigmaY: 3.5),
            child: Image.asset(
              template.thumbnailAsset,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          if (!template.isAvailable) ...[
            ColoredBox(color: Colors.white.withValues(alpha: .48)),
            Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.ink.withValues(alpha: .82),
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
                  child: Text(
                    'Coming soon',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}
