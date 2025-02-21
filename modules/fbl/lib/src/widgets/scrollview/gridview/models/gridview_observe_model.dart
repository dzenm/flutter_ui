import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import '../../common/models/observe_model.dart';
import '../..//gridview/models/gridview_observe_displaying_child_model.dart';

class GridViewObserveModel extends ObserveModel {
  GridViewObserveModel({
    required this.sliverGrid,
    required super.viewport,
    required this.firstGroupChildList,
    required this.displayingChildModelList,
    required this.displayingChildModelMap,
    required super.visible,
  }) : super(
          sliver: sliverGrid,
          innerDisplayingChildModelList: displayingChildModelList,
          innerDisplayingChildModelMap: displayingChildModelMap,
        );

  /// The target sliverGrid.
  RenderSliverMultiBoxAdaptor sliverGrid;

  /// The first group child widgets those are displaying.
  final List<GridViewObserveDisplayingChildModel> firstGroupChildList;

  /// Stores observing model list of displaying children widgets.
  final List<GridViewObserveDisplayingChildModel> displayingChildModelList;

  /// Stores observing model map of displaying children widgets.
  final Map<int, GridViewObserveDisplayingChildModel> displayingChildModelMap;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is GridViewObserveModel) {
      return listEquals(firstGroupChildList, other.firstGroupChildList) &&
          listEquals(
              displayingChildModelList, other.displayingChildModelList) &&
          mapEquals(displayingChildModelMap, other.displayingChildModelMap);
    } else {
      return false;
    }
  }

  @override
  int get hashCode {
    return firstGroupChildList.hashCode +
        displayingChildModelList.hashCode +
        displayingChildModelMap.hashCode;
  }
}
