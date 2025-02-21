import 'package:flutter/rendering.dart';

import 'observe_displaying_child_model.dart';

abstract class ObserveModel {
  /// Whether this sliver should be painted.
  bool visible;

  /// The target sliver.
  RenderSliver sliver;

  /// The viewport of sliver.
  RenderViewportBase viewport;

  /// Stores model list for children widgets those are displaying.
  List<ObserveDisplayingChildModel> innerDisplayingChildModelList;

  /// Stores model map for children widgets those are displaying.
  Map<int, ObserveDisplayingChildModel> innerDisplayingChildModelMap;

  /// Stores index list for children widgets those are displaying.
  List<int> get displayingChildIndexList =>
      innerDisplayingChildModelList.map((e) => e.index).toList();

  /// The axis of sliver.
  Axis get axis => sliver.constraints.axis;

  /// The scroll offset of sliver.
  double get scrollOffset => sliver.constraints.scrollOffset;

  ObserveModel({
    required this.visible,
    required this.sliver,
    required this.viewport,
    required this.innerDisplayingChildModelList,
    required this.innerDisplayingChildModelMap,
  });
}
