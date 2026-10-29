import 'package:flutter/material.dart';

import '../../features/address/domain/entities/address_entity.dart';
import '../../features/cart/domain/entities/cart_item_entity.dart';
import '../../features/cart/domain/entities/cart_snapshot.dart';
import '../../features/checkout/domain/entities/checkout_selection.dart';
import '../../features/home/domain/entities/product_entity.dart';
import '../../features/notifications/domain/entities/notification_entity.dart';
import '../../features/orders/domain/entities/order_entity.dart';

Map<String, dynamic> asMap(dynamic value) =>
    Map<String, dynamic>.from(value as Map);
List<dynamic> asList(dynamic value) => List<dynamic>.from(value as List);
double asAmount(dynamic value) => (value as num).toDouble();

ProductEntity productFromApi(dynamic value) {
  final data = asMap(value);
  Color color(dynamic hex) {
    final value = (hex as String).replaceFirst('#', '');
    return Color(int.parse('FF$value', radix: 16));
  }

  return ProductEntity(
    id: data['id'] as String,
    pieceNumber: data['pieceNumber'] as String? ?? '',
    title: data['title'] as String? ?? '',
    brand: data['brand'] as String? ?? 'NÉORA',
    subCategory: data['subCategory'] as String? ?? '',
    category: data['category'] as String? ?? '',
    price: asAmount(data['price']),
    originalPrice: data['originalPrice'] == null
        ? null
        : asAmount(data['originalPrice']),
    composition: data['composition'] as String? ?? '',
    description: data['description'] as String? ?? '',
    availableSizes: List<String>.from(
      data['availableSizes'] as List? ?? const [],
    ),
    availableColors: (data['availableColors'] as List? ?? const [])
        .map(color)
        .toList(),
    colorNames: List<String>.from(data['colorNames'] as List? ?? const []),
    imageType: data['imageType'] as String? ?? '',
    imagePath: data['imagePath'] as String?,
    tag: data['tag'] as String? ?? '',
    isHeroPiece: data['isHeroPiece'] as bool? ?? false,
    rating: (data['rating'] as num?)?.toDouble() ?? 0,
    reviewCount: data['reviewCount'] as int? ?? 0,
    soldCount: data['soldCount'] as int? ?? 0,
  );
}

AddressEntity addressFromApi(dynamic value) {
  final data = asMap(value);
  return AddressEntity(
    id: data['id'] as String,
    recipientName: data['recipientName'] as String? ?? '',
    phoneNumber: data['phoneNumber'] as String? ?? '',
    streetAddress: data['streetAddress'] as String? ?? '',
    ward: data['ward'] as String? ?? '',
    district: data['district'] as String? ?? '',
    city: data['city'] as String? ?? '',
    isDefault: data['isDefault'] as bool? ?? false,
    label: data['label'] as String? ?? 'Nhà riêng',
  );
}

Map<String, Object?> addressToApi(AddressEntity value) => {
  'recipientName': value.recipientName,
  'phoneNumber': value.phoneNumber,
  'streetAddress': value.streetAddress,
  'ward': value.ward,
  'district': value.district,
  'city': value.city,
  'isDefault': value.isDefault,
  'label': value.label,
};

CartSnapshot cartFromApi(dynamic value) {
  final data = asMap(value);
  return CartSnapshot(
    items: asList(data['items']).map((entry) {
      final item = asMap(entry);
      return CartItemEntity(
        serverId: item['id'] as String,
        product: productFromApi(item['product']),
        selectedSize: item['selectedSize'] as String,
        selectedColor: item['selectedColor'] as String,
        quantity: item['quantity'] as int,
      );
    }).toList(),
    discount: asAmount(data['discount']),
    shippingFee: asAmount(data['shippingFee']),
  );
}

OrderEntity orderFromApi(dynamic value, {AddressEntity? address}) {
  final data = asMap(value);
  final addressLine = data['addressLine'] as String? ?? '';
  final shippingAddress =
      address ??
      AddressEntity(
        id: '',
        recipientName: data['recipientName'] as String? ?? '',
        phoneNumber: data['phone'] as String? ?? '',
        streetAddress: addressLine,
        ward: '',
        district: '',
        city: '',
      );
  final status = data['status'] as String? ?? 'PENDING';
  return OrderEntity(
    id: data['id'] as String,
    orderDate: DateTime.parse(data['createdAt'] as String).toLocal(),
    status: switch (status) {
      'CONFIRMED' || 'PROCESSING' => OrderStatus.processing,
      'SHIPPED' => OrderStatus.shipping,
      'DELIVERED' => OrderStatus.delivered,
      'CANCELLED' => OrderStatus.cancelled,
      _ => OrderStatus.pendingConfirmation,
    },
    items: asList(data['items']).map((entry) {
      final item = asMap(entry);
      final price = asAmount(item['unitPrice']);
      return CartItemEntity(
        serverId: item['cartItemId'] as String?,
        product: ProductEntity(
          id: item['productId'] as String,
          pieceNumber: '',
          title: item['title'] as String? ?? '',
          subCategory: '',
          category: '',
          price: price,
          composition: '',
          description: '',
          availableSizes: [item['selectedSize'] as String],
          colorNames: [item['selectedColor'] as String],
          imageType: '',
          imagePath: item['imagePath'] as String?,
        ),
        selectedSize: item['selectedSize'] as String,
        selectedColor: item['selectedColor'] as String,
        quantity: item['quantity'] as int,
      );
    }).toList(),
    subtotal: asAmount(data['subtotal']),
    shippingFee: asAmount(data['shippingFee']),
    discountAmount: asAmount(data['discount']),
    totalAmount: asAmount(data['total']),
    shippingAddress: shippingAddress,
    trackingNumber: data['trackingNumber'] as String?,
    estimatedDelivery: data['estimatedDelivery'] as String?,
    paymentMethod: 'Thanh toán khi nhận hàng (COD)',
    shippingType: switch (data['shippingType']) {
      'EXPRESS' => ShippingType.express,
      'STORE_PICKUP' => ShippingType.storePickup,
      _ => ShippingType.standard,
    },
    isUserPlaced: true,
  );
}

NotificationEntity notificationFromApi(dynamic value) {
  final data = asMap(value);
  final created = DateTime.parse(data['createdAt'] as String).toLocal();
  final duration = DateTime.now().difference(created);
  final timeLabel = duration.inDays > 0
      ? '${duration.inDays} ngày trước'
      : duration.inHours > 0
      ? '${duration.inHours} giờ trước'
      : '${duration.inMinutes.clamp(0, 59)} phút trước';
  return NotificationEntity(
    id: data['id'] as String,
    title: data['title'] as String? ?? '',
    description: data['message'] as String? ?? '',
    timeLabel: timeLabel,
    iconEmoji: '📦',
    iconBackgroundValue: 0xFFEDF2ED,
    category: NotificationCategory.order,
    relatedOrderId: data['referenceId'] as String?,
    isRead: data['read'] as bool? ?? false,
  );
}
