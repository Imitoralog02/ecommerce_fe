import '../../../home/domain/entities/product_entity.dart';
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
  CartSnapshot demoCart() => const CartSnapshot(
    items: [
      CartItemEntity(
        product: ProductEntity(
          id: 'prod_dress_wrap',
          pieceNumber: '01',
          title: 'Đầm hoa wrap dáng midi nữ tính',
          brand: 'NÉORA Collection',
          subCategory: 'ĐẦM',
          category: 'Đầm',
          price: 459000,
          originalPrice: 659000,
          composition: 'Voan tơ mềm mại thoáng mát · Lót lụa mềm',
          description:
              'Đầm hoa nhí dáng wrap thắt nơ tôn dáng, chất liệu voan tơ bay bổng.',
          availableSizes: ['S', 'M', 'L', 'XL'],
          imageType: 'dress',
          imagePath: 'assets/images/real/p_dress.jpg',
        ),
        selectedSize: 'M',
        selectedColor: 'Hoa Pastel',
        quantity: 1,
      ),
      CartItemEntity(
        product: ProductEntity(
          id: 'prod_hoodie_lavender',
          pieceNumber: '03',
          title: 'Áo hoodie oversize màu lavender',
          brand: 'NÉORA Street',
          subCategory: 'HOODIE',
          category: 'Hoodie',
          price: 329000,
          originalPrice: 450000,
          composition: 'Nỉ bông cao cấp dày dặn (420gsm)',
          description: 'Áo hoodie dáng rộng phong cách trẻ trung năng động.',
          availableSizes: ['L', 'XL'],
          imageType: 'hoodie',
          imagePath: 'assets/images/real/p_hoodie.jpg',
        ),
        selectedSize: 'L',
        selectedColor: 'Lavender',
        quantity: 1,
      ),
    ],
  );
}
