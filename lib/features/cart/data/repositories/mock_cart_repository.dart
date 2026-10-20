import '../../../home/data/repositories/mock_product_repository.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/entities/cart_snapshot.dart';
import '../../domain/repositories/cart_repository.dart';

class MockCartRepository implements CartRepository {
  CartSnapshot _snapshot = const CartSnapshot();

  @override
  CartSnapshot load() => CartSnapshot(
    items: List.unmodifiable(_snapshot.items),
    appliedCoupon: _snapshot.appliedCoupon,
    discount: _snapshot.discount,
    shippingFee: _snapshot.shippingFee,
  );

  @override
  void save(CartSnapshot snapshot) => _snapshot = snapshot;

  @override
  CartSnapshot demoCart() {
    final catalog = MockProductRepository.mockCatalog;
    return CartSnapshot(
      items: [
        CartItemEntity(
          product: catalog.firstWhere((item) => item.id == 'prod_dress_wrap'),
          selectedSize: 'M',
          selectedColor: 'Kem Be',
        ),
        CartItemEntity(
          product: catalog.firstWhere(
            (item) => item.id == 'prod_hoodie_lavender',
          ),
          selectedSize: 'L',
          selectedColor: 'Be Cát',
        ),
      ],
    );
  }
}
