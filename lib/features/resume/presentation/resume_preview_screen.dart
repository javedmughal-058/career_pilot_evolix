import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_scaling.dart';
import '../../../core/widgets/design_system.dart';
import '../data/pdf_resume_service.dart';
import 'resume_provider.dart';

class ResumePreviewScreen extends StatelessWidget {
  const ResumePreviewScreen({super.key});
  @override
  Widget build(BuildContext c) {
    final r = c.watch<ResumeProvider>().current;
    if (r == null) return const SizedBox();
    final service = c.read<PdfResumeService>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resume Preview'),
        actions: [
          IconButton(
            onPressed: () => service.share(r),
            icon: const Icon(Icons.ios_share_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(10.w, 4.h, 10.w, 8.h),
              child: PdfPreview.builder(
                build: (_) => service.build(r),
                canChangeOrientation: false,
                canChangePageFormat: false,
                allowPrinting: false,
                allowSharing: false,
                canDebug: false,
                useActions: false,
                maxPageWidth: 640.w,
                padding: EdgeInsets.symmetric(vertical: 8.h),
                previewPageMargin: EdgeInsets.symmetric(
                  horizontal: 8.w,
                  vertical: 8.h,
                ),
                scrollViewDecoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                pdfPreviewPageDecoration: const BoxDecoration(
                  color: Colors.white,
                ),
                pdfFileName: '${r.title}.pdf',
                loadingWidget: const Center(child: CircularProgressIndicator()),
                pagesBuilder: (context, pages) => InteractiveViewer(
                  minScale: 0.75,
                  maxScale: 4,
                  boundaryMargin: EdgeInsets.all(96.r),
                  child: Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (final page in pages)
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 8.h,
                              ),
                              child: SizedBox(
                                width: 335.w,
                                child: DecoratedBox(
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                  ),
                                  child: AspectRatio(
                                    aspectRatio: page.aspectRatio,
                                    child: Image(
                                      image: page.image,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 4.h),
              child: PremiumCard(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h),
                child: Row(
                  children: [
                    _Action(
                      icon: Icons.edit_outlined,
                      label: 'Edit',
                      active: true,
                      onTap: () => Navigator.pop(c),
                    ),
                    _Action(
                      icon: Icons.ios_share_outlined,
                      label: 'Share',
                      onTap: () => service.share(r),
                    ),
                    _Action(
                      icon: Icons.picture_as_pdf_outlined,
                      label: 'Export PDF',
                      onTap: () => service.share(r),
                    ),
                    _Action(
                      icon: Icons.print_outlined,
                      label: 'Print',
                      onTap: () => service.printResume(r),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;
  @override
  Widget build(BuildContext context) => Expanded(
    child: InkWell(
      borderRadius: BorderRadius.circular(16.r),
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 2.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42.w,
              height: 42.h,
              decoration: BoxDecoration(
                color: active ? AppColors.amber : Colors.transparent,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(icon, color: active ? AppColors.ink : null),
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              maxLines: 1,
              style: Theme.of(context).textTheme.labelSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    ),
  );
}
