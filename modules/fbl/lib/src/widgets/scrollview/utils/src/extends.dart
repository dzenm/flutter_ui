import 'package:flutter/rendering.dart';

extension ObserverDouble on double {
  /// Rectify the value according to the current growthDirection of sliver.
  ///
  /// If the growthDirection is [GrowthDirection.forward], the value is
  /// returned directly, otherwise the opposite value is returned.
  double rectify(
    RenderSliver obj,
  ) {
    return obj.isForwardGrowthDirection ? this : -this;
  }
}

extension ObserverRenderSliverMultiBoxAdaptor on RenderSliver {
  /// Determine whether the current growthDirection of sliver is
  /// [GrowthDirection.forward].
  bool get isForwardGrowthDirection {
    return GrowthDirection.forward == constraints.growthDirection;
  }
}
