import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../domain/template_catalog.dart';
import '../../purchases/presentation/purchase_provider.dart';
import '../../resume/presentation/resume_provider.dart';

class TemplatePickerScreen extends StatefulWidget {
  const TemplatePickerScreen({super.key});

  @override
  State<TemplatePickerScreen> createState() => _TemplatePickerScreenState();
}

class _TemplatePickerScreenState extends State<TemplatePickerScreen> {
  bool _didPrecache = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didPrecache) return;
    _didPrecache = true;
    for (final template in TemplateCatalog.templates) {
      precacheImage(AssetImage(template.thumbnailAsset), context);
    }
  }

  @override
  Widget build(BuildContext c) {
    final r = c.watch<ResumeProvider>().current;
    final pay = c.watch<PurchaseProvider>();
    if (r == null) return const SizedBox();
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Template')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Professional templates',
            style: Theme.of(c).textTheme.titleLarge,
          ),
          const SizedBox(height: 5),
          const Text(
            'Switch designs at any time without losing your resume content.',
          ),
          const SizedBox(height: 16),
          for (final t in TemplateCatalog.templates) ...[
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () async {
                  if (t.isPremium && !pay.owns(t.productId)) {
                    await _pay(c, t, pay);
                    return;
                  }
                  await c.read<ResumeProvider>().save(
                    r.copyWith(templateId: t.id),
                  );
                  if (c.mounted) Navigator.pop(c);
                },
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      _TemplateThumbnail(asset: t.thumbnailAsset),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              t.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              t.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            _TemplateStatus(template: t, purchases: pay),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      r.templateId == t.id
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 14),
          Text('Template settings', style: Theme.of(c).textTheme.titleMedium),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Show profile photo'),
                    value: r.showPhoto,
                    onChanged: (v) =>
                        c.read<ResumeProvider>().save(r.copyWith(showPhoto: v)),
                  ),
                  Row(
                    children: [
                      const Expanded(child: Text('Resume text size')),
                      Expanded(
                        child: Slider(
                          value: r.templateFontScale,
                          min: .85,
                          max: 1.15,
                          divisions: 6,
                          label: r.templateFontScale.toStringAsFixed(2),
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
      builder: (x) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Unlock ${t.name}', style: Theme.of(x).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('One-time purchase • ${p.price(t.productId!)}'),
            const SizedBox(height: 18),
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
    );
    if (ok == true) await p.buy(t.productId!);
  }
}

class _TemplateThumbnail extends StatelessWidget {
  const _TemplateThumbnail({required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: DecoratedBox(
      decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
      child: Image.asset(
        asset,
        width: 82,
        height: 104,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => const SizedBox(
          width: 82,
          height: 104,
          child: Icon(Icons.description_outlined),
        ),
      ),
    ),
  );
}

class _TemplateStatus extends StatelessWidget {
  const _TemplateStatus({required this.template, required this.purchases});

  final ResumeTemplateInfo template;
  final PurchaseProvider purchases;

  @override
  Widget build(BuildContext context) {
    final label = template.isPremium
        ? purchases.owns(template.productId)
              ? 'Purchased'
              : purchases.price(template.productId!)
        : 'Free';
    final color = template.isPremium
        ? const Color(0xFF92400E)
        : const Color(0xFF166534);
    final background = template.isPremium
        ? const Color(0xFFFFF7ED)
        : const Color(0xFFF0FDF4);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
