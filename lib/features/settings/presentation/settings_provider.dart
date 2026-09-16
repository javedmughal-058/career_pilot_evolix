import 'package:flutter/foundation.dart';

import '../../../core/database/app_database.dart';
import '../domain/app_settings.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider(this._db);
  final AppDatabase _db;
  AppSettings settings = const AppSettings();
  bool ready = false;
  Future<void> load() async {
    settings = await _db.readSettings();
    ready = true;
    notifyListeners();
  }

  Future<void> setFontSize(AppFontSize size) async {
    settings = settings.copyWith(fontSize: size);
    await _db.saveSettings(settings);
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    settings = settings.copyWith(onboardingSeen: true);
    await _db.saveSettings(settings);
    notifyListeners();
  }
}
