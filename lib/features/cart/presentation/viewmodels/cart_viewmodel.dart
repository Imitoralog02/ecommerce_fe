import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/network/remote_repositories.dart';
import '../../di/cart_providers.dart';
import '../../domain/entities/cart_snapshot.dart';
import '../../domain/services/cart_pricing.dart';
import '../../../home/domain/entities/product_entity.dart';
import '../../../orders/di/order_providers.dart';
import '../../../wallet/di/wallet_providers.dart';
import '../../../wallet/domain/entities/voucher_entity.dart';
import '../../domain/entities/cart_item_entity.dart';

class CartState {
  final String? errorMessage;
  final List<CartItemEntity> items;
  final String? appliedCoupon;
  final double shippingFee;
  final String memberTier;
  final List<VoucherEntity> vouchers;
  final bool firstOrder;

  const CartState({
    this.errorMessage,
    required this.items,
    this.appliedCoupon,
    this.shippingFee = 0.0,
    this.memberTier = '',
    this.vouchers = const [],
    this.firstOrder = false,
  });

  double get subtotal => items.fold(0.0, (acc, item) => acc + item.totalPrice);
  PromotionResult get promotion => CartPricing.evaluate(
    appliedCoupon,
    subtotal: subtotal,
    items: items,
    voucher: vouchers.where((v) => v.code == appliedCoupon).firstOrNull,
    memberTier: memberTier,
    firstOrder: firstOrder,
  );
  double get discount => promotion.itemDiscount;
  double get total =>
      (subtotal - discount + shippingFee).clamp(0.0, double.infinity);
  int get totalItemCount =>
      items.fold<int>(0, (acc, item) => acc + item.quantity);

  String get formattedSubtotal {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(subtotal.toInt())}₫';
  }

  String get formattedTotal {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(total.toInt())}₫';
  }

  String get formattedDiscount {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '-${formatter.format(discount.toInt())}₫';
  }

  CartState copyWith({
    String? errorMessage,
    List<CartItemEntity>? items,
    String? appliedCoupon,
    double? shippingFee,
    String? memberTier,
    List<VoucherEntity>? vouchers,
    bool? firstOrder,
    bool clearCoupon = false,
  }) {
    return CartState(
      errorMessage: errorMessage,
      items: items ?? this.items,
      appliedCoupon: clearCoupon ? null : (appliedCoupon ?? this.appliedCoupon),
      shippingFee: shippingFee ?? this.shippingFee,
      memberTier: memberTier ?? this.memberTier,
      vouchers: vouchers ?? this.vouchers,
      firstOrder: firstOrder ?? this.firstOrder,
    );
  }
}

class CartViewModel extends Notifier<CartState> {
  int _syncGeneration = 0;
  @override
  CartState build() {
    final repository = ref.read(cartRepositoryProvider);
    if (repository is RemoteCartRepository) {
      Future.microtask(() async {
        try {
          final snapshot = await repository.refresh();
          if (ref.mounted) {
            state = state.copyWith(
              items: snapshot.items,
              shippingFee: snapshot.shippingFee,
            );
          }
        } catch (error) {
          if (ref.mounted) state = state.copyWith(errorMessage: '$error');
        }
      });
    }
    final snapshot = repository.load();
    final wallet = ref.read(walletRepositoryProvider).load();
    final firstOrder = !ref
        .read(orderRepositoryProvider)
        .getOrders()
        .any((order) => order.isUserPlaced);
    final loaded = CartState(
      items: snapshot.items,
      appliedCoupon: snapshot.appliedCoupon,
      shippingFee: snapshot.shippingFee,
      memberTier: wallet.memberTier,
      vouchers: wallet.vouchers,
      firstOrder: firstOrder,
    );
    return loaded.appliedCoupon != null && !loaded.promotion.isValid
        ? loaded.copyWith(clearCoupon: true)
        : loaded;
  }

  void _emit(CartState next) {
    final repository = ref.read(cartRepositoryProvider);
    if (repository is RemoteCartRepository) {
      state = next;
      final generation = ++_syncGeneration;
      repository
          .synchronize(CartSnapshot(items: next.items))
          .then((snapshot) {
            if (ref.mounted && generation == _syncGeneration) {
              state = state.copyWith(
                items: snapshot.items,
                shippingFee: snapshot.shippingFee,
                errorMessage: '',
              );
            }
          })
          .catchError((Object error) async {
            if (!ref.mounted || generation != _syncGeneration) return;
            try {
              final server = await repository.refresh();
              if (ref.mounted && generation == _syncGeneration) {
                state = state.copyWith(
                  items: server.items,
                  errorMessage: '$error',
                );
              }
            } catch (_) {
              if (ref.mounted && generation == _syncGeneration) {
                state = state.copyWith(errorMessage: '$error');
              }
            }
          });
      return;
    }
    if (next.appliedCoupon != null && !next.promotion.isValid) {
      next = next.copyWith(clearCoupon: true);
    }
    ref
        .read(cartRepositoryProvider)
        .save(
          CartSnapshot(
            items: next.items,
            appliedCoupon: next.appliedCoupon,
            discount: next.discount,
            shippingFee: next.shippingFee,
          ),
        );
    state = next;
  }

  bool addToCart(ProductEntity product, [String? size, String? color]) {
    final selectedSize =
        size ??
        (product.availableSizes.isNotEmpty
            ? product.availableSizes.first
            : null);
    final selectedColor =
        color ??
        (product.colorNames.isNotEmpty ? product.colorNames.first : null);
    if (selectedSize == null ||
        selectedColor == null ||
        !product.availableSizes.contains(selectedSize) ||
        !product.colorNames.contains(selectedColor)) {
      return false;
    }
    final existingIndex = state.items.indexWhere(
      (item) =>
          item.product.id == product.id &&
          item.selectedSize == selectedSize &&
          item.selectedColor == selectedColor,
    );

    if (existingIndex >= 0) {
      final updatedList = List<CartItemEntity>.from(state.items);
      final current = updatedList[existingIndex];
      updatedList[existingIndex] = current.copyWith(
        quantity: current.quantity + 1,
      );
      _emit(state.copyWith(items: updatedList));
    } else {
      _emit(
        state.copyWith(
          items: [
            ...state.items,
            CartItemEntity(
              product: product,
              selectedSize: selectedSize,
              selectedColor: selectedColor,
              quantity: 1,
            ),
          ],
        ),
      );
    }
    return true;
  }

  void updateQuantity(
    String productId,
    int quantity, {
    String? size,
    String? color,
  }) {
    if (quantity <= 0) {
      removeFromCart(productId, size: size, color: color);
      return;
    }
    final index = state.items.indexWhere(
      (i) =>
          i.product.id == productId &&
          (size == null || i.selectedSize == size) &&
          (color == null || i.selectedColor == color),
    );
    if (index >= 0) {
      final updatedList = List<CartItemEntity>.from(state.items);
      updatedList[index] = updatedList[index].copyWith(quantity: quantity);
      _emit(state.copyWith(items: updatedList));
    }
  }

  void removeFromCart(String productId, {String? size, String? color}) {
    final updatedList = state.items
        .where(
          (i) =>
              i.product.id != productId ||
              (size != null && i.selectedSize != size) ||
              (color != null && i.selectedColor != color),
        )
        .toList();
    _emit(state.copyWith(items: updatedList));
  }

  void incrementQuantity(int index) {
    if (index >= 0 && index < state.items.length) {
      final updatedList = List<CartItemEntity>.from(state.items);
      updatedList[index] = updatedList[index].copyWith(
        quantity: updatedList[index].quantity + 1,
      );
      _emit(state.copyWith(items: updatedList));
    }
  }

  void decrementQuantity(int index) {
    if (index >= 0 && index < state.items.length) {
      final updatedList = List<CartItemEntity>.from(state.items);
      if (updatedList[index].quantity > 1) {
        updatedList[index] = updatedList[index].copyWith(
          quantity: updatedList[index].quantity - 1,
        );
        _emit(state.copyWith(items: updatedList));
      } else {
        updatedList.removeAt(index);
        _emit(state.copyWith(items: updatedList));
      }
    }
  }

  bool applyCoupon(String code) {
    if (ref.read(cartRepositoryProvider) is RemoteCartRepository) return false;
    final normalized = CartPricing.normalizeCode(code);
    final wallet = ref.read(walletRepositoryProvider).load();
    final refreshed = state.copyWith(
      memberTier: wallet.memberTier,
      vouchers: wallet.vouchers,
      firstOrder: !ref
          .read(orderRepositoryProvider)
          .getOrders()
          .any((order) => order.isUserPlaced),
    );
    if (!refreshed.copyWith(appliedCoupon: normalized).promotion.isValid) {
      return false;
    }
    _emit(refreshed.copyWith(appliedCoupon: normalized));
    return true;
  }

  String? couponRejection(String code) {
    if (ref.read(cartRepositoryProvider) is RemoteCartRepository) {
      return 'Mã ưu đãi chưa được hỗ trợ khi đặt hàng COD.';
    }
    final wallet = ref.read(walletRepositoryProvider).load();
    final normalized = CartPricing.normalizeCode(code);
    return CartPricing.evaluate(
      normalized,
      subtotal: state.subtotal,
      items: state.items,
      voucher: wallet.vouchers.where((v) => v.code == normalized).firstOrNull,
      memberTier: wallet.memberTier,
      firstOrder: !ref
          .read(orderRepositoryProvider)
          .getOrders()
          .any((order) => order.isUserPlaced),
    ).reason;
  }

  void clearCart() {
    _emit(state.copyWith(items: [], clearCoupon: true));
  }

  void addItems(List<CartItemEntity> newItems) {
    final updated = List<CartItemEntity>.from(state.items);
    for (final newItem in newItems) {
      final idx = updated.indexWhere(
        (i) =>
            i.product.id == newItem.product.id &&
            i.selectedSize == newItem.selectedSize &&
            i.selectedColor == newItem.selectedColor,
      );
      if (idx >= 0) {
        updated[idx] = updated[idx].copyWith(
          quantity: updated[idx].quantity + newItem.quantity,
        );
      } else {
        updated.add(newItem);
      }
    }
    _emit(state.copyWith(items: updated));
  }

  void restoreVideoOrder() {
    final snapshot = ref.read(cartRepositoryProvider).demoCart();
    _emit(
      CartState(
        items: snapshot.items,
        appliedCoupon: snapshot.appliedCoupon,
        shippingFee: snapshot.shippingFee,
        memberTier: state.memberTier,
        vouchers: state.vouchers,
        firstOrder: state.firstOrder,
      ),
    );
  }
}

final cartViewModelProvider = NotifierProvider<CartViewModel, CartState>(() {
  return CartViewModel();
});
