import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'core/database/app_database.dart';
import 'features/auth/data/auth_service.dart';
import 'features/auth/presentation/auth_provider.dart';
import 'features/purchases/data/purchase_service.dart';
import 'features/purchases/presentation/purchase_provider.dart';
import 'features/resume/data/local_resume_repository.dart';
import 'features/resume/data/pdf_resume_service.dart';
import 'features/resume/presentation/resume_provider.dart';
import 'features/settings/presentation/settings_provider.dart';
import 'features/sync/data/sync_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final db = AppDatabase();
  final repo = LocalResumeRepository(db);
  final authService = AuthService(FirebaseAuth.instance);
  final sync = SyncService(
    FirebaseFirestore.instance,
    FirebaseAuth.instance,
    repo,
  );
  final settings = SettingsProvider(db);
  await settings.load();
  final purchases = PurchaseProvider(PurchaseService(db));
  await purchases.initialize();
  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: db),
        Provider.value(value: repo),
        Provider.value(value: PdfResumeService()),
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider.value(value: purchases),
        ChangeNotifierProvider(create: (_) => ResumeProvider(repo)),
        ChangeNotifierProvider(create: (_) => AuthProvider(authService, sync)),
      ],
      child: const CareerPilotApp(),
    ),
  );
}
