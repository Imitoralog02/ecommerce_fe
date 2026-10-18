import '../../../address/domain/entities/address_entity.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../../../home/domain/entities/product_entity.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';

class MockOrderRepository implements OrderRepository {
  MockOrderRepository(this._catalog);

  final List<ProductEntity> _catalog;
  List<OrderEntity>? _orders;

  @override
  List<OrderEntity> getOrders() {
    _orders ??= _buildOrders();
    return List.unmodifiable(_orders!);
  }

  @override
  OrderEntity? getOrderById(String id) {
    for (final order in getOrders()) {
      if (order.id == id) return order;
    }
    return null;
  }

  @override
  void saveOrder(OrderEntity order) {
    final orders = List<OrderEntity>.from(getOrders());
    orders.removeWhere((item) => item.id == order.id);
    orders.insert(0, order);
    _orders = orders;
  }

  @override
  void updateStatus(String orderId, OrderStatus status) {
    _orders = getOrders()
        .map(
          (order) =>
              order.id == orderId ? order.copyWith(status: status) : order,
        )
        .toList();
  }

  List<OrderEntity> _buildOrders() {
    const address = AddressEntity(
      id: 'addr_1',
      recipientName: 'Trần Phương Linh',
      phoneNumber: '0908 123 456',
      streetAddress: 'Tầng 12, Toà nhà Bitexco, 2 Hải Triều',
      ward: 'Phường Bến Nghé',
      district: 'Quận 1',
      city: 'TP. Hồ Chí Minh',
      isDefault: true,
      label: 'Văn phòng',
    );

    final now = DateTime.now();
    ProductEntity product(String id) =>
        _catalog.firstWhere((item) => item.id == id);

    return [
      OrderEntity(
        id: 'NEO-2094',
        orderDate: now.subtract(const Duration(hours: 4)),
        status: OrderStatus.shipping,
        items: [
          CartItemEntity(
            product: product('prod_dress_wrap'),
            selectedSize: 'M',
            selectedColor: 'Kem Be',
            quantity: 1,
          ),
          CartItemEntity(
            product: product('prod_knit_sweater'),
            selectedSize: 'L',
            selectedColor: 'Be Yến Mạch',
            quantity: 1,
          ),
        ],
        subtotal: 848000,
        totalAmount: 848000,
        shippingAddress: address,
        trackingNumber: 'SPX-8931238472VN',
        estimatedDelivery: '16:30 hôm nay',
        paymentMethod: 'Ví NÉORA Pay',
      ),
      OrderEntity(
        id: 'NEO-5102',
        orderDate: now.subtract(const Duration(hours: 1)),
        status: OrderStatus.pendingConfirmation,
        items: [
          CartItemEntity(
            product: product('prod_sneaker_white'),
            selectedSize: '38',
            selectedColor: 'Trắng',
            quantity: 1,
          ),
        ],
        subtotal: 690000,
        discountAmount: 50000,
        totalAmount: 640000,
        shippingAddress: address,
      ),
      OrderEntity(
        id: 'NEO-1930',
        orderDate: now.subtract(const Duration(days: 1)),
        status: OrderStatus.processing,
        items: [
          CartItemEntity(
            product: product('prod_hoodie_lavender'),
            selectedSize: 'L',
            selectedColor: 'Lavender',
            quantity: 2,
          ),
        ],
        subtotal: 658000,
        shippingFee: 20000,
        totalAmount: 678000,
        shippingAddress: address,
        paymentMethod: 'Thẻ tín dụng Visa •••• 4242',
      ),
      OrderEntity(
        id: 'NEO-3841',
        orderDate: now.subtract(const Duration(days: 3)),
        status: OrderStatus.delivered,
        items: [
          CartItemEntity(
            product: product('prod_leather_bag'),
            selectedSize: 'Free size',
            selectedColor: 'Nâu Bò',
            quantity: 1,
          ),
        ],
        subtotal: 590000,
        discountAmount: 100000,
        totalAmount: 490000,
        shippingAddress: address,
        trackingNumber: 'GHN-66291884VN',
        paymentMethod: 'Ví NÉORA Pay',
      ),
      OrderEntity(
        id: 'NEO-0814',
        orderDate: now.subtract(const Duration(days: 7)),
        status: OrderStatus.cancelled,
        items: [
          CartItemEntity(
            product: product('prod_linen_shirt'),
            selectedSize: 'M',
            selectedColor: 'Trắng Basic',
            quantity: 1,
          ),
        ],
        subtotal: 279000,
        shippingFee: 25000,
        totalAmount: 304000,
        shippingAddress: address,
      ),
    ];
  }
}
