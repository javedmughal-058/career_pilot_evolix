import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_scaling.dart';
import '../../../core/widgets/design_system.dart';
import '../../purchases/presentation/purchase_provider.dart';
import '../domain/template_catalog.dart';

class TemplateGalleryScreen extends StatefulWidget {
  const TemplateGalleryScreen({super.key});
  @override
  State<TemplateGalleryScreen> createState() => _TemplateGalleryScreenState();
}

class _TemplateGalleryScreenState extends State<TemplateGalleryScreen> {
  String filter = 'All';
  @override
  Widget build(BuildContext c) {
    final pay = c.watch<PurchaseProvider>();
    final items = TemplateCatalog.templates
        .where(
          (t) =>
              filter == 'All' ||
              (filter == 'Free' && !t.isPremium) ||
              (filter == 'Premium' && t.isPremium),
        )
        .toList();
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(22.w, 22.h, 22.w, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ScreenHeading(
                      title: 'Templates',
                      subtitle: 'Choose a design and make it yours.',
                    ),
                    SizedBox(height: 16.h),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ['All', 'Free', 'Premium']
                            .map(
                              (v) => Padding(
                                padding: EdgeInsets.only(right: 8.w),
                                child: ChoiceChip(
                                  label: Text(v),
                                  selected: filter == v,
                                  selectedColor: AppColors.amber,
                                  onSelected: (_) => setState(() => filter = v),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    SizedBox(height: 18.h),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(22.w, 0, 22.w, 110.h),
              sliver: SliverGrid.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14.w,
                  mainAxisSpacing: 14.h,
                  childAspectRatio: .62,
                ),
                itemCount: items.length,
                itemBuilder: (x, i) {
                  final t = items[i];
                  final owned = pay.owns(t.productId);
                  return PremiumCard(
                    padding: EdgeInsets.all(10.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _TemplatePreview(template: t)),
                        SizedBox(height: 10.h),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                t.name,
                                style: Theme.of(c).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w900),
                              ),
                            ),
                            StatusPill(
                              t.isPremium
                                  ? (owned ? 'Owned' : 'Premium')
                                  : 'Free',
                              premium: t.isPremium,
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          t.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(c).textTheme.bodySmall
                              ?.copyWith(color: AppColors.muted),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TemplatePreview extends StatelessWidget {
  const _TemplatePreview({required this.template});

  final ResumeTemplateInfo template;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(14.r),
    child: Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(
          color: Colors.white,
          child: ImageFiltered(
            imageFilter: template.isAvailable
                ? ui.ImageFilter.blur()
                : ui.ImageFilter.blur(sigmaX: 3.5, sigmaY: 3.5),
            child: Image.asset(
              template.thumbnailAsset,
              width: double.infinity,
              fit: BoxFit.contain,
              alignment: Alignment.topCenter,
            ),
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
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                child: Text(
                  'Coming soon',
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
  );
}
