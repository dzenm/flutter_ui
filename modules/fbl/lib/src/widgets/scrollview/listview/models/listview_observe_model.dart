import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import '../../common/models/observe_model.dart';
import 'listview_observe_displaying_child_model.dart';

class ListViewObserveModel extends ObserveModel {
  ListViewObserveModel({
    required this.sliverList,
    required super.viewport,
    required this.firstChild,
    required this.displayingChildModelList,
    required this.displayingChildModelMap,
    required super.visible,
  }) : super(
          sliver: sliverList,
          innerDisplayingChildModelList: displayingChildModelList,
          innerDisplayingChildModelMap: displayingChildModelMap,
        );

  /// The target sliverList.
  /// It would be [RenderSliverList] or [RenderSliverFixedExtentList].
  RenderSliverMultiBoxAdaptor sliverList;

  /// The observing data of the first child widget that is displaying.
  final ListViewObserveDisplayingChildModel? firstChild;

  /// Stores observing model list of displaying children widgets.
  final List<ListViewObserveDisplayingChildModel> displayingChildModelList;

  /// Stores observing model map of displaying children widgets.
  final Map<int, ListViewObserveDisplayingChildModel> displayingChildModelMap;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is ListViewObserveModel) {
      return firstChild == other.firstChild &&
          listEquals(
              displayingChildModelList, other.displayingChildModelList) &&
          mapEquals(displayingChildModelMap, other.displayingChildModelMap);
    } else {
      return false;
    }
  }

  @override
  int get hashCode {
    return firstChild.hashCode +
        displayingChildModelList.hashCode +
        displayingChildModelMap.hashCode;
  }
}
