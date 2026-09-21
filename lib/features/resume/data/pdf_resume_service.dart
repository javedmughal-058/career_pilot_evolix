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
    final regular = await _font('Urbanist-Regular.ttf');
    final semiBold = await _font('Urbanist-SemiBold.ttf');
    final bold = await _font('Urbanist-Bold.ttf');
    final templateIcons = await _templateIcons();
    final accent = _pdfColor(r.accentColor);
    pw.MemoryImage? photo;
    if (r.showPhoto && r.contact.photoPath != null) {
      final f = File(r.contact.photoPath!);
      if (await f.exists()) photo = pw.MemoryImage(await f.readAsBytes());
    }

    final doc = pw.Document(
      theme: pw.ThemeData.withFont(base: regular, bold: bold),
    );
    if (r.templateId == 'minimal') {
      doc.addPage(
        _minimalTemplatePage(r, regular, semiBold, bold, templateIcons),
      );
    } else if (r.templateId == 'classic') {
      doc.addPage(_releasedTemplatePage(r, regular, semiBold, bold, photo));
    } else {
      doc.addPage(_twoColumnPage(r, accent, regular, semiBold, bold, photo));
    }
    return doc.save();
  }

  pw.Page _minimalTemplatePage(
    ResumeDocument r,
    pw.Font regular,
    pw.Font semiBold,
    pw.Font bold,
    Map<String, String> templateIcons,
  ) {
    const ink = PdfColor.fromInt(0xFF262626);
    const muted = PdfColor.fromInt(0xFF5F5A55);
    const line = PdfColor.fromInt(0xFFC9C0B4);
    const gold = PdfColor.fromInt(0xFFB89B74);
    final enabled = _enabledSections(r);
    final leftSections = enabled
        .where(
          (s) =>
              s.type == ResumeSectionType.education ||
              s.type == ResumeSectionType.skills ||
              s.type == ResumeSectionType.languages ||
              s.type == ResumeSectionType.interests,
        )
        .toList();
    final rightSections = enabled
        .where(
          (s) =>
              s.type == ResumeSectionType.summary ||
              s.type == ResumeSectionType.experience ||
              s.type == ResumeSectionType.projects ||
              s.type == ResumeSectionType.certifications ||
              s.type == ResumeSectionType.achievements ||
              s.type == ResumeSectionType.references ||
              s.type == ResumeSectionType.custom,
        )
        .toList();

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(34, 46, 34, 36),
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Center(
            child: pw.Text(
              (r.contact.fullName.isEmpty ? 'Your Name' : r.contact.fullName)
                  .toUpperCase(),
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(
                font: semiBold,
                fontSize: 22 * r.templateFontScale,
                color: ink,
                letterSpacing: 8,
              ),
            ),
          ),
          if (r.contact.jobTitle.isNotEmpty) ...[
            pw.SizedBox(height: 13),
            pw.Center(
              child: pw.Text(
                r.contact.jobTitle.toUpperCase(),
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  font: semiBold,
                  fontSize: 9.5 * r.templateFontScale,
                  color: muted,
                  letterSpacing: 5,
                ),
              ),
            ),
          ],
          pw.SizedBox(height: 40),
          pw.Container(height: 3, color: gold),
          pw.SizedBox(height: 26),
          pw.Expanded(
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.SizedBox(
                  width: 138,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _minimalContactBlock(
                        r,
                        regular,
                        templateIcons,
                        muted,
                        line,
                      ),
                      for (final section in leftSections)
                        ..._minimalSideSection(
                          r,
                          section,
                          regular,
                          semiBold,
                          bold,
                          ink,
                          muted,
                          line,
                        ),
                    ],
                  ),
                ),
                pw.Container(width: .8, color: line),
                pw.SizedBox(width: 38),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      for (final section in rightSections)
                        ..._minimalMainSection(
                          r,
                          section,
                          regular,
                          semiBold,
                          bold,
                          ink,
                          muted,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _minimalContactBlock(
    ResumeDocument r,
    pw.Font regular,
    Map<String, String> templateIcons,
    PdfColor muted,
    PdfColor line,
  ) {
    final rows = <(String, String)>[
      ('phone', r.contact.phone),
      ('email', r.contact.email),
      ('linkedin', r.contact.linkedIn),
      ('location', r.contact.location),
    ].where((row) => row.$2.trim().isNotEmpty).toList();
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          for (final row in rows)
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 12),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.SizedBox(
                    width: 15,
                    child: _templateIcon(row.$1, templateIcons),
                  ),
                  pw.SizedBox(width: 9),
                  pw.Expanded(
                    child: pw.Text(
                      row.$2,
                      style: pw.TextStyle(
                        font: regular,
                        fontSize: 7.2 * r.templateFontScale,
                        color: muted,
                        lineSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (rows.isNotEmpty) pw.Container(height: .8, color: line),
        ],
      ),
    );
  }

  List<pw.Widget> _minimalSideSection(
    ResumeDocument r,
    ResumeSectionConfig s,
    pw.Font regular,
    pw.Font semiBold,
    pw.Font bold,
    PdfColor ink,
    PdfColor muted,
    PdfColor line,
  ) {
    final widgets = <pw.Widget>[
      pw.SizedBox(height: 14),
      _minimalHeading(s.title, bold, ink, r.templateFontScale, 10.4),
      pw.SizedBox(height: 14),
    ];
    final sideText = pw.TextStyle(
      font: regular,
      fontSize: 7.4 * r.templateFontScale,
      color: muted,
      lineSpacing: 1.15,
    );
    final sideStrong = pw.TextStyle(
      font: bold,
      fontSize: 7.5 * r.templateFontScale,
      color: ink,
    );
    switch (s.type) {
      case ResumeSectionType.education:
        for (final e in r.education) {
          widgets.add(
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 17),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(e.school, style: sideStrong),
                  if (e.degree.isNotEmpty) pw.Text(e.degree, style: sideText),
                  if ([e.start, e.end].where((v) => v.isNotEmpty).isNotEmpty)
                    pw.Text(
                      [e.start, e.end].where((v) => v.isNotEmpty).join(' - '),
                      style: sideText,
                    ),
                ],
              ),
            ),
          );
        }
        widgets.add(pw.Container(height: .8, color: line));
        break;
      case ResumeSectionType.skills:
        widgets.addAll(_minimalSideList(r.skills, sideText));
        break;
      case ResumeSectionType.languages:
        widgets.addAll(_minimalSideList(r.languages, sideText));
        break;
      case ResumeSectionType.interests:
        widgets.addAll(_minimalSideList(r.interests, sideText));
        break;
      default:
        break;
    }
    return widgets;
  }

  List<pw.Widget> _minimalSideList(List<String> items, pw.TextStyle style) => [
    for (final item in items)
      pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 8),
        child: pw.Text(item, style: style),
      ),
  ];

  List<pw.Widget> _minimalMainSection(
    ResumeDocument r,
    ResumeSectionConfig s,
    pw.Font regular,
    pw.Font semiBold,
    pw.Font bold,
    PdfColor ink,
    PdfColor muted,
  ) {
    final widgets = <pw.Widget>[
      _minimalHeading(
        s.type == ResumeSectionType.summary ? 'Profile' : s.title,
        bold,
        ink,
        r.templateFontScale,
        11,
      ),
      pw.SizedBox(height: 18),
    ];
    pw.TextStyle text([double size = 7.8]) => pw.TextStyle(
      font: regular,
      fontSize: size * r.templateFontScale,
      color: muted,
      lineSpacing: 1.45,
    );
    pw.TextStyle strong([double size = 8.3]) => pw.TextStyle(
      font: bold,
      fontSize: size * r.templateFontScale,
      color: ink,
    );
    switch (s.type) {
      case ResumeSectionType.summary:
        widgets.add(pw.Text(r.summary, style: text()));
        break;
      case ResumeSectionType.experience:
        for (final e in r.experiences) {
          widgets.add(
            _minimalDatedItem(
              title: e.role,
              subtitle: [
                e.company,
                e.location,
                [e.start, e.end].where((v) => v.isNotEmpty).join(' - '),
              ].where((v) => v.isNotEmpty).join(' | '),
              description: e.description,
              text: text,
              strong: strong,
              bullet: (value) => _minimalBulletText(value, text, strong),
            ),
          );
        }
        break;
      case ResumeSectionType.projects:
        widgets.addAll(_minimalNamed(r.projects, text, strong));
        break;
      case ResumeSectionType.certifications:
        widgets.addAll(_minimalNamed(r.certifications, text, strong));
        break;
      case ResumeSectionType.achievements:
        widgets.addAll(_minimalNamed(r.achievements, text, strong));
        break;
      case ResumeSectionType.references:
        widgets.add(_minimalBulletList(r.references, text, strong));
        break;
      case ResumeSectionType.custom:
        widgets.addAll(
          _minimalNamed(r.customSections[s.id] ?? [], text, strong),
        );
        break;
      default:
        break;
    }
    widgets.add(pw.SizedBox(height: 32));
    return widgets;
  }

  pw.Widget _minimalHeading(
    String text,
    pw.Font bold,
    PdfColor color,
    double scale,
    double size,
  ) => pw.Text(
    text.toUpperCase(),
    style: pw.TextStyle(
      font: bold,
      fontSize: size * scale,
      color: color,
      letterSpacing: 5,
    ),
  );

  pw.Widget _minimalDatedItem({
    required String title,
    required String subtitle,
    required String description,
    required pw.TextStyle Function([double]) text,
    required pw.TextStyle Function([double]) strong,
    required pw.Widget Function(String) bullet,
  }) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 26),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title.toUpperCase(), style: strong()),
        if (subtitle.isNotEmpty) pw.Text(subtitle, style: text(7.4)),
        if (description.trim().isNotEmpty) ...[
          pw.SizedBox(height: 4),
          bullet(description),
        ],
      ],
    ),
  );

  List<pw.Widget> _minimalNamed(
    List<NamedDetailItem> items,
    pw.TextStyle Function([double]) text,
    pw.TextStyle Function([double]) strong,
  ) => [
    for (final item in items)
      pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 20),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(item.title.toUpperCase(), style: strong()),
            if (item.subtitle.isNotEmpty)
              pw.Text(item.subtitle, style: text(7.4)),
            if (item.description.isNotEmpty) ...[
              pw.SizedBox(height: 4),
              _minimalBulletText(item.description, text, strong),
            ],
          ],
        ),
      ),
  ];

  pw.Widget _templateIcon(String type, Map<String, String> templateIcons) =>
      pw.SvgImage(svg: templateIcons[type]!, width: 14, height: 14);

  pw.Widget _minimalBulletList(
    List<String> items,
    pw.TextStyle Function([double]) text,
    pw.TextStyle Function([double]) strong,
  ) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      for (final item in items)
        if (item.trim().isNotEmpty) _minimalBulletText(item, text, strong),
    ],
  );

  pw.Widget _minimalBulletText(
    String source,
    pw.TextStyle Function([double]) text,
    pw.TextStyle Function([double]) strong,
  ) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      for (final line in _bulletLines(source))
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 4),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(
                width: 14,
                child: pw.Text(String.fromCharCode(0x2022), style: strong(9)),
              ),
              pw.Expanded(child: pw.Text(line, style: text(7.8))),
            ],
          ),
        ),
    ],
  );

  List<String> _bulletLines(String raw) => raw
      .split(RegExp(r'\r?\n'))
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  pw.Page _releasedTemplatePage(
    ResumeDocument r,
    pw.Font regular,
    pw.Font semiBold,
    pw.Font bold,
    pw.MemoryImage? photo,
  ) {
    final classic = r.templateId == 'classic';
    final accent = classic
        ? const PdfColor.fromInt(0xFF0C5066)
        : const PdfColor.fromInt(0xFF092049);
    final rule = classic
        ? const PdfColor.fromInt(0xFF57717A)
        : const PdfColor.fromInt(0xFF6D7C87);
    final body = const PdfColor.fromInt(0xFF333333);

    return pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(42, 36, 42, 34),
      build: (_) => [
        _releasedHeader(r, regular, semiBold, bold, photo, accent, body),
        pw.SizedBox(height: 18),
        ..._enabledSections(r).expand(
          (s) => _releasedSectionWidgets(
            r,
            s,
            regular,
            semiBold,
            bold,
            accent,
            rule,
            body,
          ),
        ),
      ],
    );
  }

  pw.Widget _releasedHeader(
    ResumeDocument r,
    pw.Font regular,
    pw.Font semiBold,
    pw.Font bold,
    pw.MemoryImage? photo,
    PdfColor accent,
    PdfColor body,
  ) {
    final contacts = <(String, String)>[
      ('Address:', r.contact.location),
      ('Phone:', r.contact.phone),
      ('Email:', r.contact.email),
      (
        'Website:',
        r.contact.website.isNotEmpty ? r.contact.website : r.contact.linkedIn,
      ),
    ].where((e) => e.$2.trim().isNotEmpty).toList();

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (photo != null) ...[
          pw.Container(
            width: 82,
            height: 82,
            decoration: pw.BoxDecoration(
              image: pw.DecorationImage(image: photo, fit: pw.BoxFit.cover),
            ),
          ),
          pw.SizedBox(width: 28),
        ],
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                (r.contact.fullName.isEmpty ? 'Your Name' : r.contact.fullName)
                    .toUpperCase(),
                style: pw.TextStyle(
                  font: bold,
                  fontSize: 20 * r.templateFontScale,
                  color: accent,
                ),
              ),
              if (r.contact.jobTitle.isNotEmpty) ...[
                pw.SizedBox(height: 2),
                pw.Text(
                  r.contact.jobTitle,
                  style: pw.TextStyle(
                    font: semiBold,
                    fontSize: 9.5 * r.templateFontScale,
                    color: body,
                  ),
                ),
              ],
              pw.SizedBox(height: 8),
              for (final contact in contacts)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 2.2),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.SizedBox(
                        width: 52,
                        child: pw.Text(
                          contact.$1,
                          style: pw.TextStyle(
                            font: semiBold,
                            fontSize: 8.5 * r.templateFontScale,
                            color: PdfColors.black,
                          ),
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Text(
                          contact.$2,
                          style: pw.TextStyle(
                            font: semiBold,
                            fontSize: 8.5 * r.templateFontScale,
                            color: body,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  List<pw.Widget> _releasedSectionWidgets(
    ResumeDocument r,
    ResumeSectionConfig s,
    pw.Font regular,
    pw.Font semiBold,
    pw.Font bold,
    PdfColor accent,
    PdfColor rule,
    PdfColor body,
  ) {
    final widgets = <pw.Widget>[
      pw.SizedBox(height: 12),
      pw.Text(
        _releasedSectionTitle(s),
        style: pw.TextStyle(
          font: bold,
          fontSize: 10.5 * r.templateFontScale,
          color: accent,
        ),
      ),
      pw.SizedBox(height: 2),
      pw.Container(height: .8, width: double.infinity, color: rule),
      pw.SizedBox(height: 6),
    ];
    pw.TextStyle text([double size = 8.6]) => pw.TextStyle(
      font: semiBold,
      fontSize: size * r.templateFontScale,
      color: body,
      lineSpacing: 1.25,
    );
    pw.TextStyle strong([double size = 8.8]) => pw.TextStyle(
      font: bold,
      fontSize: size * r.templateFontScale,
      color: PdfColors.black,
    );

    switch (s.type) {
      case ResumeSectionType.summary:
        widgets.add(pw.Text(r.summary, style: text()));
        break;
      case ResumeSectionType.experience:
        for (final e in r.experiences) {
          widgets.add(
            _releasedDatedItem(
              title: e.role,
              subtitle: [
                e.company,
                e.location,
              ].where((v) => v.isNotEmpty).join(', '),
              date: [e.start, e.end].where((v) => v.isNotEmpty).join(' - '),
              description: e.description,
              text: text,
              strong: strong,
            ),
          );
        }
        break;
      case ResumeSectionType.education:
        for (final e in r.education) {
          widgets.add(
            _releasedDatedItem(
              title: e.degree,
              subtitle: e.school,
              date: [e.start, e.end].where((v) => v.isNotEmpty).join(' - '),
              description: e.details,
              text: text,
              strong: strong,
            ),
          );
        }
        break;
      case ResumeSectionType.skills:
        widgets.add(_releasedBulletList(r.skills, text));
        break;
      case ResumeSectionType.languages:
        widgets.add(_releasedBulletList(r.languages, text));
        break;
      case ResumeSectionType.interests:
        widgets.add(_releasedBulletList(r.interests, text));
        break;
      case ResumeSectionType.references:
        widgets.add(_releasedBulletList(r.references, text));
        break;
      case ResumeSectionType.projects:
        widgets.addAll(_releasedNamed(r.projects, text, strong));
        break;
      case ResumeSectionType.certifications:
        widgets.addAll(_releasedNamed(r.certifications, text, strong));
        break;
      case ResumeSectionType.achievements:
        widgets.addAll(_releasedNamed(r.achievements, text, strong));
        break;
      case ResumeSectionType.custom:
        widgets.addAll(
          _releasedNamed(r.customSections[s.id] ?? [], text, strong),
        );
        break;
    }
    return widgets;
  }

  String _releasedSectionTitle(ResumeSectionConfig s) =>
      s.type == ResumeSectionType.summary ? 'SUMMARY' : s.title.toUpperCase();

  pw.Widget _releasedDatedItem({
    required String title,
    required String subtitle,
    required String date,
    required String description,
    required pw.TextStyle Function([double]) text,
    required pw.TextStyle Function([double]) strong,
  }) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 8),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(child: pw.Text(title, style: strong())),
            if (date.isNotEmpty) pw.Text(date, style: strong(8.1)),
          ],
        ),
        if (subtitle.isNotEmpty) pw.Text(subtitle, style: strong(8.1)),
        if (description.trim().isNotEmpty)
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 2),
            child: _releasedBulletText(description, text),
          ),
      ],
    ),
  );

  pw.Widget _releasedBulletText(
    String raw,
    pw.TextStyle Function([double]) text,
  ) {
    final lines = raw
        .split(RegExp(r'\r?\n'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [for (final line in lines) _releasedBullet(line, text)],
    );
  }

  pw.Widget _releasedBulletList(
    List<String> items,
    pw.TextStyle Function([double]) text,
  ) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [for (final item in items) _releasedBullet(item, text)],
  );

  pw.Widget _releasedBullet(
    String value,
    pw.TextStyle Function([double]) text,
  ) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 2),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 10,
          child: pw.Text(String.fromCharCode(0x2022), style: text()),
        ),
        pw.Expanded(child: pw.Text(value, style: text())),
      ],
    ),
  );

  List<pw.Widget> _releasedNamed(
    List<NamedDetailItem> items,
    pw.TextStyle Function([double]) text,
    pw.TextStyle Function([double]) strong,
  ) => [
    for (final e in items)
      pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 7),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(child: pw.Text(e.title, style: strong())),
                if (e.subtitle.isNotEmpty)
                  pw.Text(e.subtitle, style: strong(8.1)),
              ],
            ),
            if (e.description.isNotEmpty)
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 2),
                child: _releasedBulletText(e.description, text),
              ),
          ],
        ),
      ),
  ];

  pw.Page _twoColumnPage(
    ResumeDocument r,
    PdfColor accent,
    pw.Font regular,
    pw.Font semiBold,
    pw.Font bold,
    pw.MemoryImage? photo,
  ) {
    final darkSidebar =
        r.templateId == 'modern' ||
        r.templateId == 'executive' ||
        r.templateId == 'signature';
    final sidebarColor = darkSidebar ? PdfColors.grey900 : accent;
    final leftTypes = <ResumeSectionType>{
      ResumeSectionType.skills,
      ResumeSectionType.languages,
      ResumeSectionType.interests,
      ResumeSectionType.references,
    };
    final enabled = _enabledSections(r);
    final left = enabled.where((s) => leftTypes.contains(s.type)).toList();
    final right = enabled.where((s) => !leftTypes.contains(s.type)).toList();

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (_) => pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Container(
            width: 178,
            color: sidebarColor,
            padding: const pw.EdgeInsets.fromLTRB(22, 28, 18, 24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (photo != null)
                  pw.Center(
                    child: pw.Container(
                      width: 78,
                      height: 78,
                      decoration: pw.BoxDecoration(
                        shape: pw.BoxShape.circle,
                        border: pw.Border.all(color: PdfColors.white, width: 2),
                        image: pw.DecorationImage(
                          image: photo,
                          fit: pw.BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                if (photo != null) pw.SizedBox(height: 14),
                pw.Text(
                  r.contact.fullName.isEmpty
                      ? 'YOUR NAME'
                      : r.contact.fullName.toUpperCase(),
                  style: pw.TextStyle(
                    font: bold,
                    fontSize: 16 * r.templateFontScale,
                    color: PdfColors.white,
                  ),
                ),
                if (r.contact.jobTitle.isNotEmpty) ...[
                  pw.SizedBox(height: 3),
                  pw.Text(
                    r.contact.jobTitle,
                    style: pw.TextStyle(
                      font: regular,
                      fontSize: 9 * r.templateFontScale,
                      color: PdfColors.white,
                    ),
                  ),
                ],
                pw.SizedBox(height: 16),
                _sideHeading('CONTACT', semiBold),
                pw.SizedBox(height: 6),
                for (final text in [
                  r.contact.email,
                  r.contact.phone,
                  r.contact.location,
                  r.contact.website,
                  r.contact.linkedIn,
                  r.contact.dateOfBirth,
                ].where((e) => e.isNotEmpty))
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 5),
                    child: pw.Text(
                      text,
                      style: pw.TextStyle(
                        font: regular,
                        fontSize: 7.5 * r.templateFontScale,
                        color: PdfColors.white,
                      ),
                    ),
                  ),
                for (final s in left)
                  ..._sectionWidgets(
                    r,
                    s,
                    regular,
                    semiBold,
                    bold,
                    PdfColors.white,
                    true,
                  ),
              ],
            ),
          ),
          pw.Expanded(
            child: pw.Padding(
              padding: const pw.EdgeInsets.fromLTRB(24, 28, 28, 24),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  for (final s in right)
                    ..._sectionWidgets(
                      r,
                      s,
                      regular,
                      semiBold,
                      bold,
                      accent,
                      false,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<ResumeSectionConfig> _enabledSections(ResumeDocument r) {
    final list = [...r.sections]..sort((a, b) => a.order.compareTo(b.order));
    return list.where((s) => s.enabled && _hasContent(r, s)).toList();
  }

  bool _hasContent(ResumeDocument r, ResumeSectionConfig s) => switch (s.type) {
    ResumeSectionType.summary => r.summary.trim().isNotEmpty,
    ResumeSectionType.experience => r.experiences.isNotEmpty,
    ResumeSectionType.education => r.education.isNotEmpty,
    ResumeSectionType.skills => r.skills.isNotEmpty,
    ResumeSectionType.projects => r.projects.isNotEmpty,
    ResumeSectionType.certifications => r.certifications.isNotEmpty,
    ResumeSectionType.achievements => r.achievements.isNotEmpty,
    ResumeSectionType.languages => r.languages.isNotEmpty,
    ResumeSectionType.interests => r.interests.isNotEmpty,
    ResumeSectionType.references => r.references.isNotEmpty,
    ResumeSectionType.custom => (r.customSections[s.id] ?? []).isNotEmpty,
  };

  List<pw.Widget> _sectionWidgets(
    ResumeDocument r,
    ResumeSectionConfig s,
    pw.Font regular,
    pw.Font semiBold,
    pw.Font bold,
    PdfColor headingColor,
    bool onDark,
  ) {
    final textColor = onDark ? PdfColors.white : PdfColors.grey800;
    final widgets = <pw.Widget>[
      pw.SizedBox(height: onDark ? 14 : 10),
      pw.Text(
        s.title.toUpperCase(),
        style: pw.TextStyle(
          font: bold,
          fontSize: (onDark ? 9.5 : 11) * r.templateFontScale,
          color: headingColor,
          letterSpacing: .8,
        ),
      ),
      pw.SizedBox(height: 4),
      if (!onDark) pw.Container(height: 1, width: 34, color: headingColor),
      pw.SizedBox(height: 5),
    ];
    pw.TextStyle body([double size = 8.5]) => pw.TextStyle(
      font: semiBold,
      fontSize: size * r.templateFontScale,
      color: textColor,
      lineSpacing: 1.5,
    );
    pw.TextStyle strong([double size = 9]) => pw.TextStyle(
      font: bold,
      fontSize: size * r.templateFontScale,
      color: textColor,
    );

    switch (s.type) {
      case ResumeSectionType.summary:
        widgets.add(pw.Text(r.summary, style: body()));
        break;
      case ResumeSectionType.experience:
        for (final e in r.experiences) {
          widgets.add(
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 7),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(e.role, style: strong()),
                  pw.Text(
                    [
                      e.company,
                      e.location,
                      [e.start, e.end].where((x) => x.isNotEmpty).join(' - '),
                    ].where((x) => x.isNotEmpty).join(' · '),
                    style: body(7.5),
                  ),
                  if (e.description.isNotEmpty) ...[
                    pw.SizedBox(height: 2),
                    pw.Text(e.description, style: body()),
                  ],
                ],
              ),
            ),
          );
        }
        break;
      case ResumeSectionType.education:
        for (final e in r.education) {
          widgets.add(
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 7),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(e.degree, style: strong()),
                  pw.Text(
                    [
                      e.school,
                      [e.start, e.end].where((x) => x.isNotEmpty).join(' - '),
                    ].where((x) => x.isNotEmpty).join(' · '),
                    style: body(7.5),
                  ),
                  if (e.details.isNotEmpty) pw.Text(e.details, style: body()),
                ],
              ),
            ),
          );
        }
        break;
      case ResumeSectionType.skills:
        widgets.add(
          pw.Text(r.skills.join(onDark ? '\n' : '  •  '), style: body()),
        );
        break;
      case ResumeSectionType.languages:
        widgets.add(
          pw.Text(r.languages.join(onDark ? '\n' : '  •  '), style: body()),
        );
        break;
      case ResumeSectionType.interests:
        widgets.add(
          pw.Text(r.interests.join(onDark ? '\n' : '  •  '), style: body()),
        );
        break;
      case ResumeSectionType.references:
        widgets.add(pw.Text(r.references.join('\n'), style: body()));
        break;
      case ResumeSectionType.projects:
        _named(widgets, r.projects, body, strong);
        break;
      case ResumeSectionType.certifications:
        _named(widgets, r.certifications, body, strong);
        break;
      case ResumeSectionType.achievements:
        _named(widgets, r.achievements, body, strong);
        break;
      case ResumeSectionType.custom:
        _named(widgets, r.customSections[s.id] ?? [], body, strong);
        break;
    }
    return widgets;
  }

  void _named(
    List<pw.Widget> widgets,
    List<NamedDetailItem> items,
    pw.TextStyle Function([double]) body,
    pw.TextStyle Function([double]) strong,
  ) {
    for (final e in items) {
      widgets.add(
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 6),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(e.title, style: strong()),
              if (e.subtitle.isNotEmpty) pw.Text(e.subtitle, style: body(7.5)),
              if (e.description.isNotEmpty)
                pw.Text(e.description, style: body()),
            ],
          ),
        ),
      );
    }
  }

  pw.Widget _sideHeading(String text, pw.Font semiBold) => pw.Text(
    text,
    style: pw.TextStyle(
      font: semiBold,
      fontSize: 9,
      color: PdfColors.white,
      letterSpacing: 1,
    ),
  );

  PdfColor _pdfColor(String hex) {
    final s = hex.replaceFirst('#', '');
    final v = int.tryParse(s, radix: 16) ?? 0xFFCB74;
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

  Future<Map<String, String>> _templateIcons() async => {
    'phone': await rootBundle.loadString('assets/branding/icon_phone.svg'),
    'email': await rootBundle.loadString('assets/branding/icon_email.svg'),
    'linkedin': await rootBundle.loadString(
      'assets/branding/icon_linkedin.svg',
    ),
    'location': await rootBundle.loadString(
      'assets/branding/icon_location.svg',
    ),
  };

  Future<void> printResume(ResumeDocument r) =>
      Printing.layoutPdf(onLayout: (_) => build(r));
  Future<void> share(ResumeDocument r) async {
    final dir = await getTemporaryDirectory();
    final safe = r.title.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
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
