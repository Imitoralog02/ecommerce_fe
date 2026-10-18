import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../di/cart_providers.dart';
import '../../domain/entities/cart_snapshot.dart';
import '../../../home/domain/entities/product_entity.dart';
import '../../domain/entities/cart_item_entity.dart';

class CartState {
  final List<CartItemEntity> items;
  final String? appliedCoupon;
  final double discount;
  final double shippingFee;

  const CartState({
    required this.items,
    this.appliedCoupon,
    this.discount = 0.0,
    this.shippingFee = 0.0,
  });

  double get subtotal => items.fold(0.0, (acc, item) => acc + item.totalPrice);
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
    List<CartItemEntity>? items,
    String? appliedCoupon,
    double? discount,
    double? shippingFee,
  }) {
    return CartState(
      items: items ?? this.items,
      appliedCoupon: appliedCoupon ?? this.appliedCoupon,
      discount: discount ?? this.discount,
      shippingFee: shippingFee ?? this.shippingFee,
    );
  }
}

class CartViewModel extends Notifier<CartState> {
  @override
  CartState build() {
    final repository = ref.read(cartRepositoryProvider);
    final snapshot = repository.load();
    return CartState(
      items: snapshot.items,
      appliedCoupon: snapshot.appliedCoupon,
      discount: snapshot.discount,
      shippingFee: snapshot.shippingFee,
    );
  }

  void _emit(CartState next) {
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

  void addToCart(
    ProductEntity product, [
    String size = 'M',
    String color = 'Black',
  ]) {
    final existingIndex = state.items.indexWhere(
      (item) => item.product.id == product.id && item.selectedSize == size,
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
              selectedSize: size,
              selectedColor: color,
              quantity: 1,
            ),
          ],
        ),
      );
    }
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }
    final index = state.items.indexWhere((i) => i.product.id == productId);
    if (index >= 0) {
      final updatedList = List<CartItemEntity>.from(state.items);
      updatedList[index] = updatedList[index].copyWith(quantity: quantity);
      _emit(state.copyWith(items: updatedList));
    }
  }

  void removeFromCart(String productId) {
    final updatedList = state.items
        .where((i) => i.product.id != productId)
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

  void applyCoupon(String code) {
    final trimmed = code.trim().toUpperCase();
    if (trimmed == 'NEO20' || trimmed == 'NEORA20') {
      final disc = (state.subtotal * 0.20).roundToDouble();
      _emit(state.copyWith(appliedCoupon: trimmed, discount: disc));
    } else if (trimmed == 'NEO10' || trimmed == 'NEORA10') {
      final disc = (state.subtotal * 0.10).roundToDouble();
      _emit(state.copyWith(appliedCoupon: trimmed, discount: disc));
    } else if (trimmed == 'FREESHIP') {
      _emit(state.copyWith(appliedCoupon: trimmed, shippingFee: 0.0));
    } else {
      _emit(state.copyWith(appliedCoupon: trimmed, discount: 50000.0));
    }
  }

  void clearCart() {
    _emit(const CartState(items: [], discount: 0.0));
  }

  void addItems(List<CartItemEntity> newItems) {
    final updated = List<CartItemEntity>.from(state.items);
    for (final newItem in newItems) {
      final idx = updated.indexWhere(
        (i) =>
            i.product.id == newItem.product.id &&
            i.selectedSize == newItem.selectedSize,
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
        discount: snapshot.discount,
        shippingFee: snapshot.shippingFee,
      ),
    );
  }
}

final cartViewModelProvider = NotifierProvider<CartViewModel, CartState>(() {
  return CartViewModel();
});
