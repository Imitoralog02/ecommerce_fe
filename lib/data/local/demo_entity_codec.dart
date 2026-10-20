import 'dart:ui';

import '../../features/address/domain/entities/address_entity.dart';
import '../../features/cart/domain/entities/cart_item_entity.dart';
import '../../features/checkout/domain/entities/checkout_selection.dart';
import '../../features/home/domain/entities/product_entity.dart';
import '../../features/orders/domain/entities/order_entity.dart';

/// JSON mapping for local demo state. Order and cart products are snapshots.
abstract final class DemoEntityCodec {
  static Map<String, dynamic> _map(Object? value) =>
      Map<String, dynamic>.from(value as Map);

  static String _string(Map<String, dynamic> map, String key) =>
      map[key] as String;

  static double _double(Map<String, dynamic> map, String key) =>
      (map[key] as num).toDouble();

  static Map<String, dynamic> productToJson(ProductEntity product) => {
    'id': product.id,
    'pieceNumber': product.pieceNumber,
    'title': product.title,
    'brand': product.brand,
    'subCategory': product.subCategory,
    'category': product.category,
    'price': product.price,
    'originalPrice': product.originalPrice,
    'composition': product.composition,
    'description': product.description,
    'availableSizes': product.availableSizes,
    'availableColors': product.availableColors
        .map((color) => color.toARGB32())
        .toList(),
    'colorNames': product.colorNames,
    'imageType': product.imageType,
    'imagePath': product.imagePath,
    'tag': product.tag,
    'isHeroPiece': product.isHeroPiece,
    'rating': product.rating,
    'reviewCount': product.reviewCount,
    'soldCount': product.soldCount,
    'isFavorite': product.isFavorite,
  };

  static ProductEntity productFromJson(Object? value) {
    final map = _map(value);
    return ProductEntity(
      id: _string(map, 'id'),
      pieceNumber: _string(map, 'pieceNumber'),
      title: _string(map, 'title'),
      brand: _string(map, 'brand'),
      subCategory: _string(map, 'subCategory'),
      category: _string(map, 'category'),
      price: _double(map, 'price'),
      originalPrice: (map['originalPrice'] as num?)?.toDouble(),
      composition: _string(map, 'composition'),
      description: _string(map, 'description'),
      availableSizes: List<String>.from(map['availableSizes'] as List),
      availableColors: (map['availableColors'] as List)
          .map((color) => Color((color as num).toInt()))
          .toList(),
      colorNames: List<String>.from(map['colorNames'] as List),
      imageType: _string(map, 'imageType'),
      imagePath: map['imagePath'] as String?,
      tag: _string(map, 'tag'),
      isHeroPiece: map['isHeroPiece'] as bool,
      rating: _double(map, 'rating'),
      reviewCount: map['reviewCount'] as int,
      soldCount: map['soldCount'] as int,
      isFavorite: map['isFavorite'] as bool,
    );
  }

  static Map<String, dynamic> cartItemToJson(CartItemEntity item) => {
    'product': productToJson(item.product),
    'selectedSize': item.selectedSize,
    'selectedColor': item.selectedColor,
    'quantity': item.quantity,
  };

  static CartItemEntity cartItemFromJson(Object? value) {
    final map = _map(value);
    return CartItemEntity(
      product: productFromJson(map['product']),
      selectedSize: _string(map, 'selectedSize'),
      selectedColor: _string(map, 'selectedColor'),
      quantity: map['quantity'] as int,
    );
  }

  static Map<String, dynamic> addressToJson(AddressEntity address) => {
    'id': address.id,
    'recipientName': address.recipientName,
    'phoneNumber': address.phoneNumber,
    'streetAddress': address.streetAddress,
    'ward': address.ward,
    'district': address.district,
    'city': address.city,
    'isDefault': address.isDefault,
    'label': address.label,
  };

  static AddressEntity addressFromJson(Object? value) {
    final map = _map(value);
    return AddressEntity(
      id: _string(map, 'id'),
      recipientName: _string(map, 'recipientName'),
      phoneNumber: _string(map, 'phoneNumber'),
      streetAddress: _string(map, 'streetAddress'),
      ward: _string(map, 'ward'),
      district: _string(map, 'district'),
      city: _string(map, 'city'),
      isDefault: map['isDefault'] as bool,
      label: _string(map, 'label'),
    );
  }

  static Map<String, dynamic> orderToJson(OrderEntity order) => {
    'id': order.id,
    'orderDate': order.orderDate.toIso8601String(),
    'status': order.status.name,
    'items': order.items.map(cartItemToJson).toList(),
    'subtotal': order.subtotal,
    'shippingFee': order.shippingFee,
    'discountAmount': order.discountAmount,
    'totalAmount': order.totalAmount,
    'shippingAddress': addressToJson(order.shippingAddress),
    'trackingNumber': order.trackingNumber,
    'estimatedDelivery': order.estimatedDelivery,
    'paymentMethod': order.paymentMethod,
    'shippingType': order.shippingType.name,
    'couponCode': order.couponCode,
    'coinReward': order.coinReward,
    'giftDescription': order.giftDescription,
    'isUserPlaced': order.isUserPlaced,
  };

  static OrderEntity orderFromJson(Object? value) {
    final map = _map(value);
    return OrderEntity(
      id: _string(map, 'id'),
      orderDate: DateTime.parse(_string(map, 'orderDate')),
      status: OrderStatus.values.byName(_string(map, 'status')),
      items: (map['items'] as List).map(cartItemFromJson).toList(),
      subtotal: _double(map, 'subtotal'),
      shippingFee: _double(map, 'shippingFee'),
      discountAmount: _double(map, 'discountAmount'),
      totalAmount: _double(map, 'totalAmount'),
      shippingAddress: addressFromJson(map['shippingAddress']),
      trackingNumber: map['trackingNumber'] as String?,
      estimatedDelivery: map['estimatedDelivery'] as String?,
      paymentMethod: _string(map, 'paymentMethod'),
      shippingType: ShippingType.values.byName(
        map['shippingType'] as String? ??
            ((map['shippingFee'] as num?)?.toDouble() == 30000
                ? ShippingType.express.name
                : ShippingType.standard.name),
      ),
      couponCode: map['couponCode'] as String?,
      coinReward: (map['coinReward'] as num?)?.toInt() ?? 0,
      giftDescription: map['giftDescription'] as String?,
      isUserPlaced: map['isUserPlaced'] as bool? ?? false,
    );
  }
}
