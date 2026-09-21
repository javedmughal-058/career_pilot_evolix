import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_scaling.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/design_system.dart';
import '../../templates/domain/template_catalog.dart';
import 'resume_editor_screen.dart';
import 'resume_provider.dart';

class ResumeListScreen extends StatefulWidget {
  const ResumeListScreen({super.key});
  @override
  State<ResumeListScreen> createState() => _ResumeListScreenState();
}

class _ResumeListScreenState extends State<ResumeListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ResumeProvider>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ResumeProvider>();
    return Scaffold(
      body: SafeArea(
        child: p.loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(22.w, 18.h, 22.w, 120.h),
                children: [
                  Row(
                    children: [
                      const CareerPilotLogoMark(size: 46, radius: 15),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CareerPilot',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                            Text(
                              'Resume Builder',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.muted),
                            ),
                          ],
                        ),
                      ),
                      IconButton.filledTonal(
                        onPressed: () => _create(context),
                        icon: const Icon(Icons.add_rounded),
                      ),
                    ],
                  ),
                  SizedBox(height: 28.h),
                  const ScreenHeading(
                    title: 'My Resumes',
                    subtitle: 'Build a better tomorrow, one resume at a time.',
                  ),
                  SizedBox(height: 20.h),
                  if (p.resumes.isEmpty)
                    _Empty(onTap: () => _create(context))
                  else ...[
                    for (final r in p.resumes) ...[
                      PremiumCard(
                        onTap: () async {
                          await p.open(r.id);
                          if (context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ResumeEditorScreen(),
                              ),
                            );
                          }
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12.r),
                              child: Image.asset(
                                TemplateCatalog.byId(r.templateId)
                                    .thumbnailAsset,
                                width: 78.w,
                                height: 92.h,
                                fit: BoxFit.contain,
                                alignment: Alignment.topCenter,
                                errorBuilder: (_, _, _) => Container(
                                  width: 78.w,
                                  height: 92.h,
                                  color: AppColors.amber.withValues(alpha: .2),
                                  child: const Icon(Icons.description_outlined),
                                ),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    r.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium,
                                  ),
                                  SizedBox(height: 5.h),
                                  Text(
                                    '${r.contact.fullName.isEmpty ? 'No name yet' : r.contact.fullName} · ${TemplateCatalog.byId(r.templateId).name}',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: AppColors.muted),
                                  ),
                                  SizedBox(height: 10.h),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today_outlined,
                                        size: 14.r,
                                        color: AppColors.muted,
                                      ),
                                      SizedBox(width: 6.w),
                                      Expanded(
                                        child: Text(
                                          'Updated ${DateFormat('MMM d, yyyy').format(r.updatedAt)}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: AppColors.muted,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (v) async {
                                if (v == 'copy') {
                                  await p.duplicate(r);
                                }
                                if (v == 'delete') {
                                  await p.delete(r.id);
                                }
                              },
                              itemBuilder: (_) => const [
                                PopupMenuItem(
                                  value: 'copy',
                                  child: Text('Duplicate'),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 14.h),
                    ],
                  ],
                ],
              ),
      ),
      floatingActionButton: p.resumes.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _create(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('New Resume'),
            ),
    );
  }

  Future<void> _create(BuildContext c) async {
    final p = c.read<ResumeProvider>();
    await p.create();
    if (c.mounted) {
      Navigator.push(
        c,
        MaterialPageRoute(builder: (_) => const ResumeEditorScreen()),
      );
    }
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext c) => PremiumCard(
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 34.h),
      child: Column(
        children: [
          const AccentIcon(Icons.description_outlined, size: 86),
          SizedBox(height: 20.h),
          Text(
            'Create your first resume',
            style: Theme.of(c).textTheme.titleLarge,
          ),
          SizedBox(height: 8.h),
          Text(
            'No login required. Your work is saved locally on this device.',
            textAlign: TextAlign.center,
            style: Theme.of(c).textTheme.bodyMedium
                ?.copyWith(color: AppColors.muted),
          ),
          SizedBox(height: 24.h),
          FilledButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Create Resume'),
          ),
        ],
      ),
    ),
  );
}
