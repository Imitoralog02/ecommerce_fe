import 'package:intl/intl.dart';
import '../../../home/domain/entities/product_entity.dart';

class CartItemEntity {
  final ProductEntity product;
  final String selectedSize;
  final String selectedColor;
  final int quantity;

  const CartItemEntity({
    required this.product,
    required this.selectedSize,
    this.selectedColor = 'Trắng kem',
    this.quantity = 1,
  });

  double get totalPrice => product.price * quantity;

  String get formattedTotalPrice {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(totalPrice.toInt())}₫';
  }

  CartItemEntity copyWith({
    ProductEntity? product,
    String? selectedSize,
    String? selectedColor,
    int? quantity,
  }) {
    return CartItemEntity(
      product: product ?? this.product,
      selectedSize: selectedSize ?? this.selectedSize,
      selectedColor: selectedColor ?? this.selectedColor,
      quantity: quantity ?? this.quantity,
    );
  }
}
