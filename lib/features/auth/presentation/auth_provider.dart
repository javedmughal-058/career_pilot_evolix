import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../data/auth_service.dart';
import '../../sync/data/sync_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._auth, this._sync) {
    _sub = _auth.userChanges.listen((u) {
      user = u;
      notifyListeners();
    });
  }
  final AuthService _auth;
  final SyncService _sync;
  StreamSubscription<User?>? _sub;
  User? user;
  bool busy = false;
  String? error;
  bool get isSignedIn => user != null;
  Future<void> signIn() async {
    busy = true;
    error = null;
    notifyListeners();
    try {
      await _auth.signInWithGoogle();
      await _sync.sync();
    } catch (e) {
      error = e.toString();
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> syncNow() async {
    busy = true;
    notifyListeners();
    try {
      await _sync.sync();
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
