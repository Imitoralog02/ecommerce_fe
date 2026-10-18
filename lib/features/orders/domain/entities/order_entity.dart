import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../address/domain/entities/address_entity.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';

enum OrderStatus {
  pendingConfirmation,
  processing,
  shipping,
  delivered,
  cancelled;

  String get label {
    switch (this) {
      case OrderStatus.pendingConfirmation:
        return 'Chờ xác nhận';
      case OrderStatus.processing:
        return 'Chờ lấy hàng';
      case OrderStatus.shipping:
        return 'Đang giao';
      case OrderStatus.delivered:
        return 'Đã giao';
      case OrderStatus.cancelled:
        return 'Đã huỷ';
    }
  }

  Color get textColor {
    switch (this) {
      case OrderStatus.pendingConfirmation:
        return AppColors.primaryBurgundy;
      case OrderStatus.processing:
        return const Color(0xFF385E7D);
      case OrderStatus.shipping:
        return const Color(0xFF2E6B4E);
      case OrderStatus.delivered:
        return AppColors.liveGreen;
      case OrderStatus.cancelled:
        return AppColors.saleRed;
    }
  }

  Color get bgColor {
    switch (this) {
      case OrderStatus.pendingConfirmation:
        return AppColors.softPeach;
      case OrderStatus.processing:
        return const Color(0xFFEFF3F7);
      case OrderStatus.shipping:
        return const Color(0xFFE8F3ED);
      case OrderStatus.delivered:
        return AppColors.liveGreenSoft;
      case OrderStatus.cancelled:
        return const Color(0xFFFBECEC);
    }
  }
}

class OrderEntity {
  final String id;
  final DateTime orderDate;
  final OrderStatus status;
  final List<CartItemEntity> items;
  final double subtotal;
  final double shippingFee;
  final double discountAmount;
  final double totalAmount;
  final AddressEntity shippingAddress;
  final String? trackingNumber;
  final String? estimatedDelivery;
  final String paymentMethod;

  const OrderEntity({
    required this.id,
    required this.orderDate,
    required this.status,
    required this.items,
    required this.subtotal,
    this.shippingFee = 0.0,
    this.discountAmount = 0.0,
    required this.totalAmount,
    required this.shippingAddress,
    this.trackingNumber,
    this.estimatedDelivery,
    this.paymentMethod = 'Thanh toán khi nhận hàng (COD)',
  });

  int get totalItemCount =>
      items.fold<int>(0, (sum, item) => sum + item.quantity);

  String get formattedTotal {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(totalAmount.toInt())}₫';
  }

  String get formattedSubtotal {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(subtotal.toInt())}₫';
  }

  String get formattedShippingFee {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(shippingFee.toInt())}₫';
  }

  String get orderDateFormatted {
    final formatter = DateFormat('dd/MM/yyyy HH:mm');
    return formatter.format(orderDate);
  }

  OrderEntity copyWith({
    String? id,
    DateTime? orderDate,
    OrderStatus? status,
    List<CartItemEntity>? items,
    double? subtotal,
    double? shippingFee,
    double? discountAmount,
    double? totalAmount,
    AddressEntity? shippingAddress,
    String? trackingNumber,
    String? estimatedDelivery,
    String? paymentMethod,
  }) {
    return OrderEntity(
      id: id ?? this.id,
      orderDate: orderDate ?? this.orderDate,
      status: status ?? this.status,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      shippingFee: shippingFee ?? this.shippingFee,
      discountAmount: discountAmount ?? this.discountAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }
}
