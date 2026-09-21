import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../domain/entities/resume_models.dart';
import 'resume_provider.dart';
import '../../templates/presentation/template_picker_screen.dart';
import 'resume_preview_screen.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_scaling.dart';
import '../../../core/widgets/design_system.dart';

class ResumeEditorScreen extends StatelessWidget {
  const ResumeEditorScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final p = context.watch<ResumeProvider>();
    final r = p.current;
    if (r == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final sorted = _allSections(r);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Build Resume'),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ResumePreviewScreen()),
            ),
            icon: const Icon(Icons.visibility_outlined),
            label: const Text('Preview'),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(20.r),
        children: [
          _Progress(r: r),
          SizedBox(height: 8.h),
          _InfoCard(
            title: 'Personal Information',
            subtitle: r.contact.fullName.isEmpty
                ? 'Add name and contact details'
                : r.contact.fullName,
            icon: Icons.person_outline,
            onTap: () => _personal(context, r),
          ),
          SizedBox(height: 8.h),
          _InfoCard(
            title: 'Choose Template',
            subtitle:
                '${r.templateId[0].toUpperCase()}${r.templateId.substring(1)} • customize layout',
            icon: Icons.dashboard_customize_outlined,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TemplatePickerScreen()),
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Resume Sections',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              TextButton.icon(
                onPressed: () => _newSection(context),
                icon: const Icon(Icons.add),
                label: const Text('Custom'),
              ),
            ],
          ),
          const Text(
            'Toggle sections on/off and drag them into the order you want.',
          ),
          SizedBox(height: 12.h),
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sorted.length,
            onReorder: p.reorderSections,
            itemBuilder: (c, i) {
              final s = sorted[i];
              return Padding(
                key: ValueKey(s.id),
                padding: EdgeInsets.only(bottom: 10.h),
                child: PremiumCard(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.drag_indicator_rounded,
                        color: Theme.of(c).brightness == Brightness.dark
                            ? Colors.white38
                            : AppColors.muted,
                      ),
                      SizedBox(width: 8.w),
                      AccentIcon(_sectionIcon(s.type), size: 44),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: InkWell(
                          onTap: () => _editSection(c, r, s),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.title,
                                  style: Theme.of(c).textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  _sectionInputSubtitle(r, s),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(c).textTheme.bodySmall
                                      ?.copyWith(color: AppColors.muted),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Switch(
                        value: s.enabled,
                        onChanged: (v) => p.toggleSection(s.id, v),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  IconData _sectionIcon(ResumeSectionType t) => switch (t) {
    ResumeSectionType.summary => Icons.article_outlined,
    ResumeSectionType.experience => Icons.work_outline_rounded,
    ResumeSectionType.education => Icons.school_outlined,
    ResumeSectionType.skills => Icons.bar_chart_rounded,
    ResumeSectionType.projects => Icons.folder_open_outlined,
    ResumeSectionType.certifications => Icons.workspace_premium_outlined,
    ResumeSectionType.achievements => Icons.emoji_events_outlined,
    ResumeSectionType.languages => Icons.language_rounded,
    ResumeSectionType.interests => Icons.interests_outlined,
    ResumeSectionType.references => Icons.people_outline_rounded,
    ResumeSectionType.custom => Icons.add_box_outlined,
  };

  String _sectionHint(ResumeSectionType t) => switch (t) {
    ResumeSectionType.summary => 'A concise professional introduction',
    ResumeSectionType.experience => 'Roles, employers and impact',
    ResumeSectionType.education => 'Degrees and academic history',
    ResumeSectionType.skills => 'Technical and soft skills',
    ResumeSectionType.projects => 'Selected work and projects',
    ResumeSectionType.certifications => 'Courses and credentials',
    ResumeSectionType.achievements => 'Awards and accomplishments',
    ResumeSectionType.languages => 'Languages you speak',
    ResumeSectionType.interests => 'Relevant hobbies and interests',
    ResumeSectionType.references => 'Professional references',
    ResumeSectionType.custom => 'Your custom content',
  };

  List<ResumeSectionConfig> _allSections(ResumeDocument r) {
    final byId = {for (final section in r.sections) section.id: section};
    final defaults = ResumeDocument.defaultSections()
        .map((section) => byId[section.id] ?? section)
        .toList();
    final custom = r.sections
        .where((section) => section.type == ResumeSectionType.custom)
        .toList();
    final merged = [...defaults, ...custom]
      ..sort((a, b) => a.order.compareTo(b.order));
    return merged;
  }

  String _sectionInputSubtitle(ResumeDocument r, ResumeSectionConfig s) {
    final hint = _sectionHint(s.type);
    final count = switch (s.type) {
      ResumeSectionType.summary => r.summary.trim().isEmpty ? 0 : 1,
      ResumeSectionType.experience => r.experiences.length,
      ResumeSectionType.education => r.education.length,
      ResumeSectionType.skills => r.skills.length,
      ResumeSectionType.projects => r.projects.length,
      ResumeSectionType.certifications => r.certifications.length,
      ResumeSectionType.achievements => r.achievements.length,
      ResumeSectionType.languages => r.languages.length,
      ResumeSectionType.interests => r.interests.length,
      ResumeSectionType.references => r.references.length,
      ResumeSectionType.custom => (r.customSections[s.id] ?? []).length,
    };
    if (count == 0) return '$hint. Tap to add details.';
    return '$count item${count == 1 ? '' : 's'} added. Tap to edit.';
  }

  Future<void> _personal(BuildContext c, ResumeDocument r) async {
    final ctrls = [
      TextEditingController(text: r.contact.fullName),
      TextEditingController(text: r.contact.jobTitle),
      TextEditingController(text: r.contact.email),
      TextEditingController(text: r.contact.phone),
      TextEditingController(text: r.contact.location),
      TextEditingController(text: r.contact.dateOfBirth),
      TextEditingController(text: r.contact.website),
      TextEditingController(text: r.contact.linkedIn),
    ];
    String? photoPath = r.contact.photoPath;
    final out = await showModalBottomSheet<Map<String, dynamic>>(
      context: c,
      isScrollControlled: true,
      builder: (x) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20.w,
              4.h,
              20.w,
              MediaQuery.viewInsetsOf(x).bottom + 32.h,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Personal Information',
                    style: Theme.of(x).textTheme.titleLarge,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Add the contact details used by your selected template.',
                    style: Theme.of(x).textTheme.bodyMedium
                        ?.copyWith(color: AppColors.muted),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Container(
                        width: 72.w,
                        height: 72.h,
                        decoration: BoxDecoration(
                          color: AppColors.amber.withValues(alpha: .25),
                          borderRadius: BorderRadius.circular(22.r),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child:
                            photoPath != null && File(photoPath!).existsSync()
                            ? Image.file(File(photoPath!), fit: BoxFit.cover)
                            : Icon(Icons.person_outline_rounded, size: 34.r),
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Profile photo',
                              style: Theme.of(x).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            SizedBox(height: 6.h),
                            OutlinedButton.icon(
                              onPressed: () async {
                                final image = await ImagePicker().pickImage(
                                  source: ImageSource.gallery,
                                  imageQuality: 88,
                                  maxWidth: 1200,
                                );
                                if (image != null) {
                                  final dir =
                                      await getApplicationDocumentsDirectory();
                                  final ext = image.path.contains('.')
                                      ? image.path.substring(
                                          image.path.lastIndexOf('.'),
                                        )
                                      : '.jpg';
                                  final saved = await File(
                                    image.path,
                                  ).copy('${dir.path}/careerpilot_${r.id}$ext');
                                  setSheetState(() => photoPath = saved.path);
                                }
                              },
                              icon: const Icon(Icons.photo_library_outlined),
                              label: Text(
                                photoPath == null
                                    ? 'Choose photo'
                                    : 'Change photo',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  for (var i = 0; i < ctrls.length; i++)
                    Padding(
                      padding: EdgeInsets.only(bottom: 11.h),
                      child: TextField(
                        controller: ctrls[i],
                        keyboardType: i == 2
                            ? TextInputType.emailAddress
                            : i == 3
                            ? TextInputType.phone
                            : TextInputType.text,
                        decoration: InputDecoration(
                          labelText: const [
                            'Full name',
                            'Professional title',
                            'Email',
                            'Phone',
                            'Location',
                            'Date of birth',
                            'Website / portfolio',
                            'LinkedIn',
                          ][i],
                          prefixIcon: Icon(
                            const [
                              Icons.person_outline,
                              Icons.work_outline,
                              Icons.mail_outline,
                              Icons.phone_outlined,
                              Icons.location_on_outlined,
                              Icons.cake_outlined,
                              Icons.language_outlined,
                              Icons.link_rounded,
                            ][i],
                          ),
                        ),
                      ),
                    ),
                  FilledButton(
                    onPressed: () => Navigator.pop(x, {
                      'values': ctrls.map((e) => e.text.trim()).toList(),
                      'photoPath': photoPath,
                    }),
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    if (out != null && c.mounted) {
      final values = List<String>.from(out['values'] as List);
      await c.read<ResumeProvider>().save(
        r.copyWith(
          contact: r.contact.copyWith(
            fullName: values[0],
            jobTitle: values[1],
            email: values[2],
            phone: values[3],
            location: values[4],
            dateOfBirth: values[5],
            website: values[6],
            linkedIn: values[7],
            photoPath: out['photoPath'] as String?,
          ),
          title: values[1].isNotEmpty ? '${values[1]} Resume' : r.title,
        ),
      );
    }
  }

  Future<void> _editSection(
    BuildContext c,
    ResumeDocument r,
    ResumeSectionConfig s,
  ) async {
    if (!s.enabled) {
      await c.read<ResumeProvider>().toggleSection(s.id, true);
      if (!c.mounted) return;
    }
    switch (s.type) {
      case ResumeSectionType.summary:
        await _editSummary(c, r);
        break;
      case ResumeSectionType.skills:
        await _editStringList(c, r, s, 'Skills', r.skills);
        break;
      case ResumeSectionType.languages:
        await _editStringList(c, r, s, 'Languages', r.languages);
        break;
      case ResumeSectionType.interests:
        await _editStringList(c, r, s, 'Interests', r.interests);
        break;
      case ResumeSectionType.references:
        await _editStringList(c, r, s, 'References', r.references);
        break;
      default:
        await _editDetails(c, r, s);
    }
  }

  Future<void> _editSummary(BuildContext c, ResumeDocument r) async {
    final ctl = TextEditingController(text: r.summary);
    final v = await showModalBottomSheet<String>(
      context: c,
      isScrollControlled: true,
      builder: (x) => SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20.w,
            4.h,
            20.w,
            MediaQuery.viewInsetsOf(x).bottom + 32.h,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Professional Summary',
                  style: Theme.of(x).textTheme.titleLarge,
                ),
                SizedBox(height: 4.h),
                Text(
                  'Write a concise introduction that highlights your strengths, experience and goals.',
                  style: Theme.of(x).textTheme.bodyMedium
                      ?.copyWith(color: AppColors.muted),
                ),
                SizedBox(height: 16.h),
                TextField(
                  controller: ctl,
                  maxLines: 7,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Summary',
                    alignLabelWithHint: true,
                  ),
                ),
                SizedBox(height: 16.h),
                FilledButton(
                  onPressed: () => Navigator.pop(x, ctl.text.trim()),
                  child: const Text('Save summary'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (v != null && c.mounted) {
      await c.read<ResumeProvider>().save(r.copyWith(summary: v));
    }
  }

  Future<String?> _textDialog(
    BuildContext c,
    String title,
    TextEditingController ctl, {
    int maxLines = 4,
  }) => showDialog<String>(
    context: c,
    builder: (x) => AlertDialog(
      title: Text(title),
      content: TextField(controller: ctl, maxLines: maxLines, autofocus: true),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(x),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(x, ctl.text.trim()),
          child: const Text('Save'),
        ),
      ],
    ),
  );
  Future<void> _editStringList(
    BuildContext c,
    ResumeDocument r,
    ResumeSectionConfig s,
    String title,
    List<String> current,
  ) async {
    final ctl = TextEditingController(text: current.join('\n'));
    final v = await showModalBottomSheet<String>(
      context: c,
      isScrollControlled: true,
      builder: (x) => SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20.w,
            4.h,
            20.w,
            MediaQuery.viewInsetsOf(x).bottom + 32.h,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(x).textTheme.titleLarge),
                SizedBox(height: 4.h),
                Text(
                  'Enter one item per line. These will appear in the ${s.title.toLowerCase()} section.',
                  style: Theme.of(x).textTheme.bodyMedium
                      ?.copyWith(color: AppColors.muted),
                ),
                SizedBox(height: 16.h),
                TextField(
                  controller: ctl,
                  maxLines: 8,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: title,
                    alignLabelWithHint: true,
                  ),
                ),
                SizedBox(height: 16.h),
                FilledButton(
                  onPressed: () => Navigator.pop(x, ctl.text.trim()),
                  child: Text('Save $title'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (v == null || !c.mounted) return;
    final list = v
        .split(RegExp(r'[,\n]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final next = s.type == ResumeSectionType.skills
        ? r.copyWith(skills: list)
        : s.type == ResumeSectionType.languages
        ? r.copyWith(languages: list)
        : s.type == ResumeSectionType.interests
        ? r.copyWith(interests: list)
        : r.copyWith(references: list);
    await c.read<ResumeProvider>().save(next);
  }

  Future<void> _editDetails(
    BuildContext c,
    ResumeDocument r,
    ResumeSectionConfig s,
  ) async {
    final title = TextEditingController();
    final subtitle = TextEditingController();
    final location = TextEditingController();
    final startDate = TextEditingController();
    final endDate = TextEditingController();
    final desc = TextEditingController();
    final isExperience = s.type == ResumeSectionType.experience;
    final isEducation = s.type == ResumeSectionType.education;
    final ok = await showModalBottomSheet<bool>(
      context: c,
      isScrollControlled: true,
      builder: (x) => SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20.w,
            4.h,
            20.w,
            MediaQuery.viewInsetsOf(x).bottom + 32.h,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add ${s.title}', style: Theme.of(x).textTheme.titleLarge),
                SizedBox(height: 4.h),
                Text(
                  'Use clear dates and achievement-focused details.',
                  style: Theme.of(x).textTheme.bodyMedium
                      ?.copyWith(color: AppColors.muted),
                ),
                SizedBox(height: 16.h),
                TextField(
                  controller: title,
                  decoration: InputDecoration(
                    labelText: isExperience
                        ? 'Role / job title'
                        : isEducation
                        ? 'Degree / qualification'
                        : 'Title',
                  ),
                ),
                SizedBox(height: 10.h),
                TextField(
                  controller: subtitle,
                  decoration: InputDecoration(
                    labelText: isExperience
                        ? 'Company / employer'
                        : isEducation
                        ? 'School / university'
                        : 'Organization / subtitle',
                  ),
                ),
                if (isExperience) ...[
                  SizedBox(height: 10.h),
                  TextField(
                    controller: location,
                    decoration: const InputDecoration(labelText: 'Location'),
                  ),
                ],
                if (isExperience || isEducation) ...[
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: startDate,
                          decoration: const InputDecoration(
                            labelText: 'Start date',
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: TextField(
                          controller: endDate,
                          decoration: const InputDecoration(
                            labelText: 'End date / Present',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                SizedBox(height: 10.h),
                TextField(
                  controller: desc,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: isExperience
                        ? 'Achievements / responsibilities'
                        : isEducation
                        ? 'Details / coursework'
                        : 'Details',
                  ),
                ),
                SizedBox(height: 16.h),
                FilledButton(
                  onPressed: () => Navigator.pop(x, true),
                  child: const Text('Add to resume'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (ok != true || !c.mounted) return;
    final id = const Uuid().v4();
    if (isExperience) {
      await c.read<ResumeProvider>().save(
        r.copyWith(
          experiences: [
            ...r.experiences,
            ExperienceItem(
              id: id,
              role: title.text.trim(),
              company: subtitle.text.trim(),
              location: location.text.trim(),
              start: startDate.text.trim(),
              end: endDate.text.trim(),
              description: desc.text.trim(),
            ),
          ],
        ),
      );
    } else if (isEducation) {
      await c.read<ResumeProvider>().save(
        r.copyWith(
          education: [
            ...r.education,
            EducationItem(
              id: id,
              degree: title.text.trim(),
              school: subtitle.text.trim(),
              start: startDate.text.trim(),
              end: endDate.text.trim(),
              details: desc.text.trim(),
            ),
          ],
        ),
      );
    } else {
      final item = NamedDetailItem(
        id: id,
        title: title.text.trim(),
        subtitle: subtitle.text.trim(),
        description: desc.text.trim(),
      );
      if (s.type == ResumeSectionType.projects) {
        await c.read<ResumeProvider>().save(
          r.copyWith(projects: [...r.projects, item]),
        );
      } else if (s.type == ResumeSectionType.certifications) {
        await c.read<ResumeProvider>().save(
          r.copyWith(certifications: [...r.certifications, item]),
        );
      } else if (s.type == ResumeSectionType.achievements) {
        await c.read<ResumeProvider>().save(
          r.copyWith(achievements: [...r.achievements, item]),
        );
      } else if (s.type == ResumeSectionType.custom) {
        final map = <String, List<NamedDetailItem>>{
          ...r.customSections,
          s.id: [...(r.customSections[s.id] ?? []), item],
        };
        await c.read<ResumeProvider>().save(r.copyWith(customSections: map));
      }
    }
  }

  Future<void> _newSection(BuildContext c) async {
    final ctl = TextEditingController();
    final v = await _textDialog(c, 'Custom section name', ctl, maxLines: 1);
    if (v != null && v.isNotEmpty && c.mounted) {
      await c.read<ResumeProvider>().addCustomSection(v);
    }
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.r});
  final ResumeDocument r;
  @override
  Widget build(BuildContext c) {
    final n = [
      r.contact.fullName.isNotEmpty,
      r.summary.isNotEmpty,
      r.experiences.isNotEmpty,
      r.education.isNotEmpty,
      r.skills.isNotEmpty,
    ].where((e) => e).length;
    final value = n / 5;
    return PremiumCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resume completeness',
                  style: Theme.of(c).textTheme.titleMedium,
                ),
                SizedBox(height: 6.h),
                Text(
                  'Complete the main sections to build a stronger resume.',
                  style: Theme.of(c).textTheme.bodySmall
                      ?.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ),
          SizedBox(width: 16.w),
          SizedBox(
            width: 58.w,
            height: 58.h,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: value,
                  strokeWidth: 5,
                  backgroundColor: Theme.of(c).brightness == Brightness.dark
                      ? Colors.white12
                      : Colors.black12,
                ),
                Text(
                  '${(value * 100).round()}%',
                  style: Theme.of(c).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });
  final String title, subtitle;
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext c) => PremiumCard(
    onTap: onTap,
    child: ListTile(
      // contentPadding: EdgeInsets.all(14.r),
      leading: AccentIcon(icon),
      title: Text(
        title,
        style: Theme.of(c).textTheme.titleSmall
            ?.copyWith(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
    ),
  );
}
