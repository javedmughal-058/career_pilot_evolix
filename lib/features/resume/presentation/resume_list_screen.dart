import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/app_logo.dart';
import 'resume_provider.dart';
import 'resume_editor_screen.dart';

class ResumeListScreen extends StatefulWidget {
  const ResumeListScreen({super.key});
  @override
  State<ResumeListScreen> createState() => _S();
}

class _S extends State<ResumeListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ResumeProvider>().loadAll());
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ResumeProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const CareerPilotLogo(compact: true),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => _create(context),
          ),
        ],
      ),
      body: p.loading
          ? const Center(child: CircularProgressIndicator())
          : p.resumes.isEmpty
          ? _Empty(onTap: () => _create(context))
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: p.resumes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (c, i) {
                final r = p.resumes[i];
                return Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () async {
                      await p.open(r.id);
                      if (c.mounted)
                        Navigator.push(
                          c,
                          MaterialPageRoute(
                            builder: (_) => const ResumeEditorScreen(),
                          ),
                        );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 54,
                            height: 72,
                            decoration: BoxDecoration(
                              color: Color(
                                int.parse(
                                      r.accentColor.substring(1),
                                      radix: 16,
                                    ) +
                                    0xFF000000,
                              ).withValues(alpha: .1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.description_outlined),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  r.title,
                                  style: Theme.of(c).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${r.contact.fullName.isEmpty ? 'No name yet' : r.contact.fullName} • ${r.templateId}',
                                  style: Theme.of(c).textTheme.bodySmall,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Updated ${r.updatedAt.toLocal().toString().substring(0, 16)}',
                                  style: Theme.of(c).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (v) async {
                              if (v == 'copy') await p.duplicate(r);
                              if (v == 'delete') await p.delete(r.id);
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
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _create(context),
        icon: const Icon(Icons.add),
        label: const Text('New Resume'),
      ),
    );
  }

  Future<void> _create(BuildContext c) async {
    final p = c.read<ResumeProvider>();
    await p.create();
    if (c.mounted)
      Navigator.push(
        c,
        MaterialPageRoute(builder: (_) => const ResumeEditorScreen()),
      );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext c) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.description_outlined,
            size: 72,
            color: Colors.blueGrey,
          ),
          const SizedBox(height: 18),
          Text(
            'Create your first resume',
            style: Theme.of(c).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text(
            'No login required. Your work is saved locally on this device.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton(onPressed: onTap, child: const Text('Create Resume')),
        ],
      ),
    ),
  );
}
