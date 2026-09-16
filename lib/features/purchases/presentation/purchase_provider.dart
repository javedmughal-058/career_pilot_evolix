import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/purchase_service.dart';
import '../../../core/constants/app_constants.dart';

class PurchaseProvider extends ChangeNotifier {
  PurchaseProvider(this._service);
  final PurchaseService _service;
  Set<String> owned = {};
  bool ready = false;
  StreamSubscription<void>? _sub;
  Future<void> initialize() async {
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
  Future<void> buy(String id) => _service.buy(id);
  Future<void> restore() => _service.restore();
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
