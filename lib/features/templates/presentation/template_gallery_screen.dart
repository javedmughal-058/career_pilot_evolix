import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../domain/template_catalog.dart';
import '../../purchases/presentation/purchase_provider.dart';

class TemplateGalleryScreen extends StatefulWidget {
  const TemplateGalleryScreen({super.key});

  @override
  State<TemplateGalleryScreen> createState() => _TemplateGalleryScreenState();
}

class _TemplateGalleryScreenState extends State<TemplateGalleryScreen> {
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
    final pay = c.watch<PurchaseProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Templates')),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: .66,
        ),
        itemCount: TemplateCatalog.templates.length,
        itemBuilder: (x, i) {
          final t = TemplateCatalog.templates[i];
          final owned = pay.owns(t.productId);
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _TemplatePreview(asset: t.thumbnailAsset)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          t.name,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      if (t.isPremium)
                        Icon(
                          owned ? Icons.verified : Icons.workspace_premium,
                          color: owned ? Colors.green : Colors.amber,
                          size: 18,
                        ),
                    ],
                  ),
                  Text(
                    t.isPremium
                        ? (owned ? 'Owned' : pay.price(t.productId!))
                        : 'Free',
                    style: Theme.of(c).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TemplatePreview extends StatelessWidget {
  const _TemplatePreview({required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF4FAFF),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Image.asset(
        asset,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
        errorBuilder: (_, _, _) => const Center(
          child: Icon(
            Icons.description_outlined,
            size: 58,
            color: Colors.blueGrey,
          ),
        ),
      ),
    ),
  );
}
