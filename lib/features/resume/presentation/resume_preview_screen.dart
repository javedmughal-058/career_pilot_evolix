import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';

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
            tooltip: 'Share PDF',
            onPressed: () => service.share(r),
            icon: const Icon(Icons.share_outlined),
          ),
        ],
      ),
      body: PdfPreview(
        build: (_) => service.build(r),
        canChangeOrientation: false,
        canChangePageFormat: false,
        allowPrinting: true,
        allowSharing: true,
        pdfFileName: '${r.title}.pdf',
      ),
    );
  }
}
