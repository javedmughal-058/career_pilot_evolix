import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../domain/entities/resume_models.dart';

class PdfResumeService {
  Future<Uint8List> build(ResumeDocument r) async {
    final doc = pw.Document();
    final accent = _pdfColor(r.accentColor);
    final regular = await _font('Urbanist-Regular.ttf');
    final semiBold = await _font('Urbanist-SemiBold.ttf');
    final bold = await _font('Urbanist-Bold.ttf');
    pw.TextStyle text([double s = 9]) => pw.TextStyle(
      font: regular,
      fontSize: s * r.templateFontScale,
      color: PdfColors.grey800,
    );
    pw.TextStyle heading([double s = 12]) => pw.TextStyle(
      font: semiBold,
      fontSize: s * r.templateFontScale,
      color: accent,
    );
    final enabled = [...r.sections]..sort((a, b) => a.order.compareTo(b.order));
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(base: regular, bold: bold),
        header: (c) => c.pageNumber == 1
            ? pw.SizedBox()
            : pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(r.contact.fullName, style: text(8)),
              ),
        build: (ctx) => [
          pw.Text(
            r.contact.fullName.isEmpty ? 'Your Name' : r.contact.fullName,
            style: pw.TextStyle(
              font: bold,
              fontSize: 24,
              color: PdfColors.grey900,
            ),
          ),
          if (r.contact.jobTitle.isNotEmpty)
            pw.Text(r.contact.jobTitle, style: heading(11)),
          pw.SizedBox(height: 5),
          pw.Text(
            [
              r.contact.email,
              r.contact.phone,
              r.contact.location,
              r.contact.linkedIn,
            ].where((e) => e.isNotEmpty).join('  •  '),
            style: text(8),
          ),
          pw.SizedBox(height: 14),
          ...enabled
              .where((s) => s.enabled)
              .expand((s) => _section(r, s, heading, text)),
        ],
      ),
    );
    return doc.save();
  }

  Iterable<pw.Widget> _section(
    ResumeDocument r,
    ResumeSectionConfig s,
    pw.TextStyle Function([double]) h,
    pw.TextStyle Function([double]) t,
  ) sync* {
    List<String> lines = [];
    switch (s.type) {
      case ResumeSectionType.summary:
        if (r.summary.isNotEmpty) lines = [r.summary];
        break;
      case ResumeSectionType.experience:
        lines = r.experiences
            .map(
              (e) =>
                  '${e.role} — ${e.company} | ${e.start}–${e.end}\n${e.description}',
            )
            .toList();
        break;
      case ResumeSectionType.education:
        lines = r.education
            .map(
              (e) =>
                  '${e.degree} — ${e.school} | ${e.start}–${e.end}\n${e.details}',
            )
            .toList();
        break;
      case ResumeSectionType.skills:
        lines = [r.skills.join('  •  ')];
        break;
      case ResumeSectionType.projects:
        lines = r.projects
            .map(
              (e) =>
                  '${e.title}${e.subtitle.isEmpty ? '' : ' — ${e.subtitle}'}\n${e.description}',
            )
            .toList();
        break;
      case ResumeSectionType.certifications:
        lines = r.certifications
            .map(
              (e) =>
                  '${e.title}${e.subtitle.isEmpty ? '' : ' — ${e.subtitle}'}',
            )
            .toList();
        break;
      case ResumeSectionType.achievements:
        lines = r.achievements
            .map((e) => '${e.title}\n${e.description}')
            .toList();
        break;
      case ResumeSectionType.languages:
        lines = [r.languages.join('  •  ')];
        break;
      case ResumeSectionType.interests:
        lines = [r.interests.join('  •  ')];
        break;
      case ResumeSectionType.references:
        lines = r.references;
        break;
      case ResumeSectionType.custom:
        lines = (r.customSections[s.id] ?? [])
            .map((e) => '${e.title}\n${e.description}')
            .toList();
        break;
    }
    if (lines.every((e) => e.trim().isEmpty)) return;
    yield pw.Padding(
      padding: const pw.EdgeInsets.only(top: 9, bottom: 4),
      child: pw.Text(s.title.toUpperCase(), style: h()),
    );
    for (final line in lines.where((e) => e.trim().isNotEmpty)) {
      yield pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 6),
        child: pw.Text(line, style: t(), softWrap: true),
      );
    }
  }

  PdfColor _pdfColor(String hex) {
    final s = hex.replaceFirst('#', '');
    final v = int.tryParse(s, radix: 16) ?? 0x2563EB;
    return PdfColor(
      (v >> 16 & 255) / 255,
      (v >> 8 & 255) / 255,
      (v & 255) / 255,
    );
  }

  Future<pw.Font> _font(String fileName) async {
    final data = await rootBundle.load('assets/fonts/urbanist/$fileName');
    return pw.Font.ttf(data);
  }

  Future<void> printResume(ResumeDocument r) =>
      Printing.layoutPdf(onLayout: (_) => build(r));
  Future<void> share(ResumeDocument r) async {
    final dir = await getTemporaryDirectory();
    final safe = r.title.runes.map((codeUnit) {
      final isDigit = codeUnit >= 48 && codeUnit <= 57;
      final isUpper = codeUnit >= 65 && codeUnit <= 90;
      final isLower = codeUnit >= 97 && codeUnit <= 122;
      final isAllowedSymbol = codeUnit == 45 || codeUnit == 95;
      return isDigit || isUpper || isLower || isAllowedSymbol
          ? String.fromCharCode(codeUnit)
          : '_';
    }).join();
    final f = File('${dir.path}/$safe.pdf');
    await f.writeAsBytes(await build(r));
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(f.path)],
        text: 'Resume created with CareerPilot',
      ),
    );
  }
}
