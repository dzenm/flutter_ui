/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/LinXunFeng/flutter_scrollview_observer
 * @Date: 2023-05-20 15:38:28
 */
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'listview/models/listview_observe_displaying_child_model.dart';
import 'listview/models/listview_observe_model.dart';
import 'utils/observer_utils.dart';

class ObserverCore {
  /// Handles observation logic of a sliver similar to [SliverList].
  static ListViewObserveModel? handleListObserve({
    required BuildContext context,
    double Function()? fetchLeadingOffset,
    double toNextOverPercent = 1,
  }) {
    var _obj = ObserverUtils.findRenderObject(context);
    if (_obj is! RenderSliverMultiBoxAdaptor) return null;
    final viewport = ObserverUtils.findViewport(_obj);
    if (viewport == null) return null;
    if (kDebugMode) {
      if (viewport.debugNeedsPaint) return null;
    }
    if (!(_obj.geometry?.visible ?? true)) {
      return ListViewObserveModel(
        sliverList: _obj,
        viewport: viewport,
        visible: false,
        firstChild: null,
        displayingChildModelList: [],
      );
    }
    final scrollDirection = _obj.constraints.axis;
    var firstChild = _obj.firstChild;
    if (firstChild == null) return null;

    final offset = fetchLeadingOffset?.call() ?? 0;
    final rawScrollViewOffset = _obj.constraints.scrollOffset + _obj.constraints.overlap;
    var scrollViewOffset = rawScrollViewOffset + offset;
    var parentData = firstChild.parentData as SliverMultiBoxAdaptorParentData;
    var index = parentData.index ?? 0;

    // Find out the first child which is displaying
    var targetFirstChild = firstChild;

    while (!ObserverUtils.isBelowOffsetWidgetInSliver(
      scrollViewOffset: scrollViewOffset,
      scrollDirection: scrollDirection,
      targetChild: targetFirstChild,
      toNextOverPercent: toNextOverPercent,
    )) {
      index = index + 1;
      var nextChild = _obj.childAfter(targetFirstChild);
      if (nextChild == null) break;

      if (nextChild is! RenderIndexedSemantics) {
        // It is separator
        nextChild = _obj.childAfter(nextChild);
      }
      if (nextChild == null) break;
      targetFirstChild = nextChild;
    }
    if (targetFirstChild is! RenderIndexedSemantics) return null;

    List<ListViewObserveDisplayingChildModel> displayingChildModelList = [
      ListViewObserveDisplayingChildModel(
        sliverList: _obj,
        viewport: viewport,
        index: targetFirstChild.index,
        renderObject: targetFirstChild,
      ),
    ];

    // Find the remaining children that are being displayed
    final showingChildrenMaxOffset = rawScrollViewOffset + _obj.constraints.remainingPaintExtent - _obj.constraints.overlap;
    var displayingChild = _obj.childAfter(targetFirstChild);
    while (ObserverUtils.isDisplayingChildInSliver(
      targetChild: displayingChild,
      showingChildrenMaxOffset: showingChildrenMaxOffset,
      scrollViewOffset: scrollViewOffset,
      scrollDirection: scrollDirection,
      toNextOverPercent: toNextOverPercent,
    )) {
      if (displayingChild == null) {
        break;
      }
      if (displayingChild is! RenderIndexedSemantics) {
        // It is separator
        displayingChild = _obj.childAfter(displayingChild);
        continue;
      }
      displayingChildModelList.add(ListViewObserveDisplayingChildModel(
        sliverList: _obj,
        viewport: viewport,
        index: displayingChild.index,
        renderObject: displayingChild,
      ));
      displayingChild = _obj.childAfter(displayingChild);
    }

    return ListViewObserveModel(
      sliverList: _obj,
      viewport: viewport,
      visible: true,
      firstChild: ListViewObserveDisplayingChildModel(
        sliverList: _obj,
        viewport: viewport,
        index: targetFirstChild.index,
        renderObject: targetFirstChild,
      ),
      displayingChildModelList: displayingChildModelList,
    );
  }
}
