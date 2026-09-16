import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/presentation/auth_provider.dart';
import '../../../core/constants/app_constants.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext c) {
    final a = c.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 12),
          CircleAvatar(
            radius: 42,
            backgroundColor: const Color(0xFFDBEAFE),
            backgroundImage: a.user?.photoURL != null
                ? NetworkImage(a.user!.photoURL!)
                : null,
            child: a.user?.photoURL == null
                ? const Icon(Icons.person, size: 42)
                : null,
          ),
          const SizedBox(height: 12),
          Text(
            a.user?.displayName ?? 'Guest user',
            textAlign: TextAlign.center,
            style: Theme.of(c).textTheme.titleLarge,
          ),
          Text(
            a.user?.email ?? 'Build resumes without signing in',
            textAlign: TextAlign.center,
            style: Theme.of(c).textTheme.bodyMedium,
          ),
          const SizedBox(height: 18),
          if (!a.isSignedIn)
            OutlinedButton.icon(
              onPressed: a.busy ? null : a.signIn,
              icon: const Icon(Icons.login),
              label: const Text('Continue with Google for sync'),
            )
          else
            OutlinedButton(onPressed: a.signOut, child: const Text('Sign out')),
          const SizedBox(height: 26),
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.shield_outlined),
                  title: Text('Privacy'),
                  subtitle: Text('Local-first. Cloud sync is optional.'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('About CareerPilot'),
                  subtitle: const Text(
                    'Professional offline-first resume builder',
                  ),
                  trailing: const Text('v1.0.0'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 34),
          Center(
            child: Column(
              children: [
                Text('Developed by', style: Theme.of(c).textTheme.bodySmall),
                const SizedBox(height: 8),
                Image.asset(
                  'assets/branding/evolix_logo.png',
                  height: 42,
                  errorBuilder: (_, __, ___) => const Text(
                    AppConstants.developerName,
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(height: 6),
                // const Text(
                //   AppConstants.developerName,
                //   style: TextStyle(fontWeight: FontWeight.w600),
                // ),
                Text(
                  'Simple tools. Brighter careers.',
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
