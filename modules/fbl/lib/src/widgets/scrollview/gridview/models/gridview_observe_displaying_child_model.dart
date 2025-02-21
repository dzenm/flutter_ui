import 'package:flutter/rendering.dart';
import '../../common/models/observe_displaying_child_model.dart';
import '../../common/models/observe_displaying_child_model_mixin.dart';

class GridViewObserveDisplayingChildModel extends ObserveDisplayingChildModel
    with ObserveDisplayingChildModelMixin {
  GridViewObserveDisplayingChildModel({
    required this.sliverGrid,
    required super.viewport,
    required super.index,
    required super.renderObject,
  }) : super(
          sliver: sliverGrid,
        );

  /// The target sliverGrid
  RenderSliverMultiBoxAdaptor sliverGrid;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is GridViewObserveDisplayingChildModel) {
      return index == other.index && renderObject == other.renderObject;
    } else {
      return false;
    }
  }

  @override
  int get hashCode {
    return index + renderObject.hashCode;
  }
}
