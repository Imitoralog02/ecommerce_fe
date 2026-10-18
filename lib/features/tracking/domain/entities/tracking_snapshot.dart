enum TrackingStage { processing, shipping, delivered }

class TrackingSnapshot {
  const TrackingSnapshot({
    required this.orderId,
    required this.stage,
    required this.statusLabel,
    required this.deliveryMethod,
  });

  final String orderId;
  final TrackingStage stage;
  final String statusLabel;
  final String deliveryMethod;

  bool isStepDone(TrackingStage step) => step.index <= stage.index;
  bool isStepActive(TrackingStage step) => step == stage;
}
