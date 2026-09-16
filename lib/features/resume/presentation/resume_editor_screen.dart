import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../domain/entities/resume_models.dart';
import 'resume_provider.dart';
import '../../templates/presentation/template_picker_screen.dart';
import 'resume_preview_screen.dart';

class ResumeEditorScreen extends StatelessWidget {
  const ResumeEditorScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final p = context.watch<ResumeProvider>();
    final r = p.current;
    if (r == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final sorted = [...r.sections]..sort((a, b) => a.order.compareTo(b.order));
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
        padding: const EdgeInsets.all(20),
        children: [
          _Progress(r: r),
          const SizedBox(height: 20),
          _InfoCard(
            title: 'Personal Information',
            subtitle: r.contact.fullName.isEmpty
                ? 'Add name and contact details'
                : r.contact.fullName,
            icon: Icons.person_outline,
            onTap: () => _personal(context, r),
          ),
          const SizedBox(height: 12),
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
          const SizedBox(height: 24),
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
          const SizedBox(height: 12),
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sorted.length,
            onReorder: p.reorderSections,
            itemBuilder: (c, i) {
              final s = sorted[i];
              return Card(
                key: ValueKey(s.id),
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: const Icon(Icons.drag_indicator),
                  title: Text(s.title),
                  subtitle: Text(_sectionHint(s.type)),
                  trailing: Switch(
                    value: s.enabled,
                    onChanged: (v) => p.toggleSection(s.id, v),
                  ),
                  onTap: () => _editSection(c, r, s),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

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
  Future<void> _personal(BuildContext c, ResumeDocument r) async {
    final ctrls = [
      TextEditingController(text: r.contact.fullName),
      TextEditingController(text: r.contact.jobTitle),
      TextEditingController(text: r.contact.email),
      TextEditingController(text: r.contact.phone),
      TextEditingController(text: r.contact.location),
      TextEditingController(text: r.contact.linkedIn),
    ];
    final out = await showModalBottomSheet<List<String>>(
      context: c,
      isScrollControlled: true,
      builder: (x) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.viewInsetsOf(x).bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                'Personal Information',
                style: Theme.of(x).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              for (var i = 0; i < ctrls.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextField(
                    controller: ctrls[i],
                    decoration: InputDecoration(
                      labelText: const [
                        'Full name',
                        'Professional title',
                        'Email',
                        'Phone',
                        'Location',
                        'LinkedIn',
                      ][i],
                    ),
                  ),
                ),
              FilledButton(
                onPressed: () =>
                    Navigator.pop(x, ctrls.map((e) => e.text.trim()).toList()),
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
    if (out != null && c.mounted) {
      await c.read<ResumeProvider>().save(
        r.copyWith(
          contact: r.contact.copyWith(
            fullName: out[0],
            jobTitle: out[1],
            email: out[2],
            phone: out[3],
            location: out[4],
            linkedIn: out[5],
          ),
          title: out[1].isNotEmpty ? '${out[1]} Resume' : r.title,
        ),
      );
    }
  }

  Future<void> _editSection(
    BuildContext c,
    ResumeDocument r,
    ResumeSectionConfig s,
  ) async {
    if (!s.enabled) await c.read<ResumeProvider>().toggleSection(s.id, true);
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
    final v = await _textDialog(c, 'Professional Summary', ctl, maxLines: 7);
    if (v != null && c.mounted)
      await c.read<ResumeProvider>().save(r.copyWith(summary: v));
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
    final ctl = TextEditingController(text: current.join(', '));
    final v = await _textDialog(
      c,
      '$title (comma separated)',
      ctl,
      maxLines: 5,
    );
    if (v == null || !c.mounted) return;
    final list = v
        .split(',')
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
    final title = TextEditingController(),
        subtitle = TextEditingController(),
        desc = TextEditingController();
    final ok = await showDialog<bool>(
      context: c,
      builder: (x) => AlertDialog(
        title: Text('Add ${s.title}'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: title,
                decoration: const InputDecoration(
                  labelText: 'Title / role / degree',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: subtitle,
                decoration: const InputDecoration(
                  labelText: 'Organization / subtitle',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: desc,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Details'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(x, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(x, true),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (ok != true || !c.mounted) return;
    final id = const Uuid().v4();
    if (s.type == ResumeSectionType.experience) {
      final list = [
        ...r.experiences,
        ExperienceItem(
          id: id,
          role: title.text,
          company: subtitle.text,
          description: desc.text,
        ),
      ];
      await c.read<ResumeProvider>().save(r.copyWith(experiences: list));
    } else if (s.type == ResumeSectionType.education) {
      final list = [
        ...r.education,
        EducationItem(
          id: id,
          degree: title.text,
          school: subtitle.text,
          details: desc.text,
        ),
      ];
      await c.read<ResumeProvider>().save(r.copyWith(education: list));
    } else {
      final item = NamedDetailItem(
        id: id,
        title: title.text,
        subtitle: subtitle.text,
        description: desc.text,
      );
      if (s.type == ResumeSectionType.projects)
        await c.read<ResumeProvider>().save(
          r.copyWith(projects: [...r.projects, item]),
        );
      else if (s.type == ResumeSectionType.certifications)
        await c.read<ResumeProvider>().save(
          r.copyWith(certifications: [...r.certifications, item]),
        );
      else if (s.type == ResumeSectionType.achievements)
        await c.read<ResumeProvider>().save(
          r.copyWith(achievements: [...r.achievements, item]),
        );
      else if (s.type == ResumeSectionType.custom) {
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
    if (v != null && v.isNotEmpty && c.mounted)
      await c.read<ResumeProvider>().addCustomSection(v);
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Resume completeness',
                    style: Theme.of(c).textTheme.titleMedium,
                  ),
                ),
                Text('${n * 20}%'),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: n / 5,
              borderRadius: BorderRadius.circular(20),
            ),
          ],
        ),
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
  Widget build(BuildContext c) => Card(
    child: ListTile(
      contentPadding: const EdgeInsets.all(14),
      leading: CircleAvatar(child: Icon(icon)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    ),
  );
}
