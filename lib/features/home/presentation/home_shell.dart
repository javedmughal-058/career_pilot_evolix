import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/presentation/auth_provider.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../resume/presentation/resume_list_screen.dart';
import '../../resume/presentation/resume_provider.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../templates/presentation/template_gallery_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int i = 0;
  final pages = const [
    ResumeListScreen(),
    TemplateGalleryScreen(),
    SettingsScreen(),
    ProfileScreen(),
  ];
  @override
  Widget build(BuildContext context) => Scaffold(
    body: RefreshIndicator(
      onRefresh: () => _refresh(context),
      notificationPredicate: (_) => i == 0,
      child: IndexedStack(index: i, children: pages),
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: i,
      onDestinationSelected: (v) => setState(() => i = v),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.description_outlined),
          selectedIcon: Icon(Icons.description_rounded),
          label: 'Resumes',
        ),
        NavigationDestination(
          icon: Icon(Icons.grid_view_rounded),
          selectedIcon: Icon(Icons.grid_view_rounded),
          label: 'Templates',
        ),
        NavigationDestination(
          icon: Icon(Icons.tune_rounded),
          selectedIcon: Icon(Icons.tune_rounded),
          label: 'Settings',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline_rounded),
          selectedIcon: Icon(Icons.person_rounded),
          label: 'Profile',
        ),
      ],
    ),
  );

  Future<void> _refresh(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final resumes = context.read<ResumeProvider>();
    try {
      if (auth.isSignedIn) {
        await auth.syncNow();
      }
      await resumes.loadAll();
      // if (!context.mounted) return;
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(
      //       auth.isSignedIn
      //           ? 'Resumes refreshed.'
      //           : 'Local resumes refreshed.',
      //     ),
      //   ),
      // );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Refresh failed. Please try again.')),
      );
    }
  }
}
