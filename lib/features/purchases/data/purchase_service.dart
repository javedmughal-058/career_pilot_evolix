import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/database/app_database.dart';

class PurchaseService {
  PurchaseService(this._db);
  final AppDatabase _db;
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _sub;
  final _controller = StreamController<void>.broadcast();
  Stream<void> get changes => _controller.stream;
  List<ProductDetails> products = [];
  bool available = false;

  Future<void> initialize() async {
    available = await _iap.isAvailable();
    if (!available) return;
    final response = await _iap.queryProductDetails(AppConstants.iapProductIds);
    products = response.productDetails;
    _sub = _iap.purchaseStream.listen(_onPurchases, onError: (_) {});
  }

  Future<void> _onPurchases(List<PurchaseDetails> items) async {
    for (final p in items) {
      if (p.status == PurchaseStatus.purchased ||
          p.status == PurchaseStatus.restored) {
        // Production: verify p.verificationData.serverVerificationData on trusted backend first.
        await _db.grant(p.productID);
        _controller.add(null);
      }
      if (p.pendingCompletePurchase) {
        await _iap.completePurchase(p);
      }
    }
  }

  Future<void> buy(String productId) async {
    final p = products.where((e) => e.id == productId).firstOrNull;
    if (p == null) throw StateError('Product not loaded: $productId');
    await _iap.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: p),
    );
  }

  Future<void> restore() => _iap.restorePurchases();
  Future<Set<String>> entitlements() => _db.entitlements();
  Future<void> dispose() async {
    await _sub?.cancel();
    await _controller.close();
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
