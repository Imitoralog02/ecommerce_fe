import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../checkout/domain/entities/checkout_selection.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../orders/presentation/viewmodels/order_viewmodel.dart';
import '../../di/tracking_providers.dart';
import '../../domain/entities/tracking_snapshot.dart';

typedef TrackingSeed = ({String orderId, OrderStatus status});

class TrackingViewModel extends Notifier<TrackingSnapshot> {
  TrackingViewModel(this.seed);

  final TrackingSeed seed;

  @override
  TrackingSnapshot build() {
    final order = ref.watch(orderViewModelProvider).findById(seed.orderId);
    return ref
        .read(trackingRepositoryProvider)
        .load(
          orderId: seed.orderId,
          status: order?.status ?? seed.status,
          shippingType: order?.shippingType ?? ShippingType.express,
        );
  }
}

final trackingViewModelProvider = NotifierProvider.autoDispose
    .family<TrackingViewModel, TrackingSnapshot, TrackingSeed>(
      TrackingViewModel.new,
    );
