import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../orders/domain/entities/order_entity.dart';
import '../../di/tracking_providers.dart';
import '../../domain/entities/tracking_snapshot.dart';

typedef TrackingSeed = ({String orderId, OrderStatus status});

class TrackingViewModel extends Notifier<TrackingSnapshot> {
  TrackingViewModel(this.seed);

  final TrackingSeed seed;

  @override
  TrackingSnapshot build() => ref
      .read(trackingRepositoryProvider)
      .load(orderId: seed.orderId, status: seed.status);
}

final trackingViewModelProvider = NotifierProvider.autoDispose
    .family<TrackingViewModel, TrackingSnapshot, TrackingSeed>(
      TrackingViewModel.new,
    );
