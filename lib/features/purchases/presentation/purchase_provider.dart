import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/constants/app_constants.dart';
import '../data/purchase_service.dart';

class PurchaseProvider extends ChangeNotifier {
  PurchaseProvider(this._service);
  final PurchaseService _service;
  Set<String> owned = {};
  bool ready = false;
  String? error;
  StreamSubscription<void>? _sub;
  Future<void> initialize() async {
    error = null;
    await _service.initialize();
    owned = await _service.entitlements();
    _sub = _service.changes.listen((_) async {
      owned = await _service.entitlements();
      notifyListeners();
    });
    ready = true;
    notifyListeners();
  }

  bool owns(String? productId) =>
      productId == null ||
      owned.contains(productId) ||
      owned.contains(AppConstants.productProPack);
  Future<bool> buy(String id) async {
    error = null;
    notifyListeners();
    try {
      await _service.buy(id);
      return true;
    } on StateError catch (e) {
      error = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      error = 'Purchase could not be started. Please try again later.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> restore() async {
    error = null;
    notifyListeners();
    try {
      await _service.restore();
      return true;
    } catch (_) {
      error = 'Restore failed. Please try again later.';
      notifyListeners();
      return false;
    }
  }

  String price(String id) =>
      _service.products
          .where((e) => e.id == id)
          .map((e) => e.price)
          .firstOrNull ??
      'Premium';
  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
