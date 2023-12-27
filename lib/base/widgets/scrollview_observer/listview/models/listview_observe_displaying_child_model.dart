import 'package:flutter/rendering.dart';

import '../../observer/models/observe_displaying_child_model.dart';

class ListViewObserveDisplayingChildModel extends ObserveDisplayingChildModel with ObserveDisplayingChildModelMixin {
  ListViewObserveDisplayingChildModel({
    required this.sliverList,
    required super.viewport,
    required super.index,
    required super.renderObject,
  }) : super(
    sliver: sliverList,
  );

  /// The target sliverList.
  /// It would be [RenderSliverList] or [RenderSliverFixedExtentList].
  RenderSliverMultiBoxAdaptor sliverList;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is ListViewObserveDisplayingChildModel) {
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
