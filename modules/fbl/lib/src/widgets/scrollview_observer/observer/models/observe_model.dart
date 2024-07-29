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
  });
}

class ObserveScrollChildModel {
  /// The size of child widget.
  double size;

  /// The layout offset of child widget.
  double layoutOffset;

  ObserveScrollChildModel({
    required this.size,
    required this.layoutOffset,
  });
}

/// [ObserveFindChildModel] is used to pass data internally.
class ObserveFindChildModel {
  ObserveFindChildModel({
    required this.sliver,
    required this.viewport,
    required this.index,
    required this.renderObject,
  });

  /// The target sliverList.
  RenderSliver sliver;

  /// The viewport of sliver.
  RenderViewportBase viewport;

  /// The index of child widget.
  int index;

  /// The renderObject [RenderIndexedSemantics] of child widget.
  RenderIndexedSemantics renderObject;
}
