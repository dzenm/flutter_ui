import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'gridview/models/gridview_observe_displaying_child_model.dart';
import 'gridview/models/gridview_observe_model.dart';
import 'listview/models/listview_observe_displaying_child_model.dart';
import 'listview/models/listview_observe_model.dart';
import 'utils/observer_utils.dart';

class ObserverCore {
  /// Handles observation logic of a sliver similar to [SliverList].
  static ListViewObserveModel? handleListObserve({
    required BuildContext context,
    double Function()? fetchLeadingOffset,
    double? Function(BuildContext)? customOverlap,
    double toNextOverPercent = 1,
  }) {
    var myObj = ObserverUtils.findRenderObject(context);
    if (myObj is! RenderSliverMultiBoxAdaptor) return null;
    final viewport = ObserverUtils.findViewport(myObj);
    if (viewport == null) return null;
    if (kDebugMode) {
      if (viewport.debugNeedsPaint) return null;
    }
    // The geometry.visible is not absolutely reliable.
    if (!(myObj.geometry?.visible ?? false) ||
        myObj.constraints.remainingPaintExtent < 1e-10) {
      return ListViewObserveModel(
        sliverList: myObj,
        viewport: viewport,
        visible: false,
        firstChild: null,
        displayingChildModelList: [],
        displayingChildModelMap: {},
      );
    }
    final scrollDirection = myObj.constraints.axis;
    var firstChild = myObj.firstChild;
    if (firstChild == null) return null;

    final offset = fetchLeadingOffset?.call() ?? 0;
    final overlap = customOverlap?.call(context) ?? myObj.constraints.overlap;
    final rawScrollViewOffset = myObj.constraints.scrollOffset + overlap;
    var scrollViewOffset = rawScrollViewOffset + offset;
    var parentData = firstChild.parentData as SliverMultiBoxAdaptorParentData;
    var index = parentData.index ?? 0;

    // Whether the first child being displayed is not found.
    bool isNotFound = false;
    // Find out the first child which is displaying
    var targetFirstChild = firstChild;

    while (!ObserverUtils.isBelowOffsetWidgetInSliver(
      scrollViewOffset: scrollViewOffset,
      scrollDirection: scrollDirection,
      targetChild: targetFirstChild,
      toNextOverPercent: toNextOverPercent,
    )) {
      index = index + 1;
      var nextChild = myObj.childAfter(targetFirstChild);
      if (nextChild == null) {
        isNotFound = true;
        break;
      }

      if (nextChild is! RenderIndexedSemantics) {
        // It is separator
        nextChild = myObj.childAfter(nextChild);
      }
      if (nextChild == null) {
        isNotFound = true;
        break;
      }
      targetFirstChild = nextChild;
    }

    // The first child being displayed is not found, indicating that the
    // ScrollView is not visible.
    if (isNotFound) {
      return ListViewObserveModel(
        sliverList: myObj,
        viewport: viewport,
        visible: false,
        firstChild: null,
        displayingChildModelList: [],
        displayingChildModelMap: {},
      );
    }

    if (targetFirstChild is! RenderIndexedSemantics) return null;

    final firstDisplayingChildIndex = targetFirstChild.index;
    final firstDisplayingChildModel = ListViewObserveDisplayingChildModel(
      sliverList: myObj,
      viewport: viewport,
      index: firstDisplayingChildIndex,
      renderObject: targetFirstChild,
    );
    Map<int, ListViewObserveDisplayingChildModel> displayingChildModelMap = {
      firstDisplayingChildIndex: firstDisplayingChildModel,
    };
    List<ListViewObserveDisplayingChildModel> displayingChildModelList = [
      firstDisplayingChildModel,
    ];

    // Find the remaining children that are being displayed
    final showingChildrenMaxOffset =
        rawScrollViewOffset + myObj.constraints.remainingPaintExtent - overlap;
    var displayingChild = myObj.childAfter(targetFirstChild);
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
        displayingChild = myObj.childAfter(displayingChild);
        continue;
      }

      final displayingChildIndex = displayingChild.index;
      final displayingChildModel = ListViewObserveDisplayingChildModel(
        sliverList: myObj,
        viewport: viewport,
        index: displayingChildIndex,
        renderObject: displayingChild,
      );
      displayingChildModelList.add(displayingChildModel);
      displayingChildModelMap[displayingChildIndex] = displayingChildModel;
      displayingChild = myObj.childAfter(displayingChild);
    }

    return ListViewObserveModel(
      sliverList: myObj,
      viewport: viewport,
      visible: true,
      firstChild: firstDisplayingChildModel,
      displayingChildModelList: displayingChildModelList,
      displayingChildModelMap: displayingChildModelMap,
    );
  }

  /// Handles observation logic of a sliver similar to [SliverGrid].
  static GridViewObserveModel? handleGridObserve({
    required BuildContext context,
    double Function()? fetchLeadingOffset,
    double? Function(BuildContext)? customOverlap,
    double toNextOverPercent = 1,
  }) {
    final myObj = ObserverUtils.findRenderObject(context);
    if (myObj is! RenderSliverMultiBoxAdaptor) return null;
    final viewport = ObserverUtils.findViewport(myObj);
    if (viewport == null) return null;
    if (kDebugMode) {
      if (viewport.debugNeedsPaint) return null;
    }
    // The geometry.visible is not absolutely reliable.
    if (!(myObj.geometry?.visible ?? false) ||
        myObj.constraints.remainingPaintExtent < 1e-10) {
      return GridViewObserveModel(
        sliverGrid: myObj,
        viewport: viewport,
        visible: false,
        firstGroupChildList: [],
        displayingChildModelList: [],
        displayingChildModelMap: {},
      );
    }
    final scrollDirection = myObj.constraints.axis;
    var firstChild = myObj.firstChild;
    if (firstChild == null) return null;

    final offset = fetchLeadingOffset?.call() ?? 0;
    final overlap = customOverlap?.call(context) ?? myObj.constraints.overlap;
    final rawScrollViewOffset = myObj.constraints.scrollOffset + overlap;
    var scrollViewOffset = rawScrollViewOffset + offset;

    // Whether the first child being displayed is not found.
    bool isNotFound = false;
    // Find out the first child which is displaying
    var targetFirstChild = firstChild;
    var lastFirstGroupChildWidget = targetFirstChild;

    while (!ObserverUtils.isBelowOffsetWidgetInSliver(
      scrollViewOffset: scrollViewOffset,
      scrollDirection: scrollDirection,
      targetChild: targetFirstChild,
      toNextOverPercent: toNextOverPercent,
    )) {
      /// Entering here means it is not the target object
      RenderBox? nextChild = myObj.childAfter(targetFirstChild);
      if (nextChild == null) {
        isNotFound = true;
        break;
      }
      targetFirstChild = nextChild;
    }

    // The first child being displayed is not found, indicating that the
    // ScrollView is not visible.
    if (isNotFound) {
      return GridViewObserveModel(
        sliverGrid: myObj,
        viewport: viewport,
        visible: false,
        firstGroupChildList: [],
        displayingChildModelList: [],
        displayingChildModelMap: {},
      );
    }

    if (targetFirstChild is! RenderIndexedSemantics) return null;
    lastFirstGroupChildWidget = targetFirstChild;

    final firstDisplayingChildIndex = targetFirstChild.index;
    final firstModel = GridViewObserveDisplayingChildModel(
      sliverGrid: myObj,
      viewport: viewport,
      index: firstDisplayingChildIndex,
      renderObject: targetFirstChild,
    );
    Map<int, GridViewObserveDisplayingChildModel> displayingChildModelMap = {
      firstDisplayingChildIndex: firstModel,
    };
    List<GridViewObserveDisplayingChildModel> firstGroupChildModelList = [
      firstModel,
    ];

    final showingChildrenMaxOffset =
        rawScrollViewOffset + myObj.constraints.remainingPaintExtent - overlap;

    // Find out other child those have reached the specified offset.
    RenderBox? targetChild = myObj.childAfter(targetFirstChild);
    while (targetChild != null) {
      if (ObserverUtils.isReachOffsetWidgetInSliver(
        scrollViewOffset: max(scrollViewOffset, firstModel.layoutOffset),
        scrollDirection: scrollDirection,
        targetChild: targetChild,
        toNextOverPercent: toNextOverPercent,
      )) {
        if (targetChild is! RenderIndexedSemantics) break;
        final targetChildIndex = targetChild.index;
        final displayingChildModel = GridViewObserveDisplayingChildModel(
          sliverGrid: myObj,
          viewport: viewport,
          index: targetChildIndex,
          renderObject: targetChild,
        );
        firstGroupChildModelList.add(displayingChildModel);
        displayingChildModelMap[targetChildIndex] = displayingChildModel;
        lastFirstGroupChildWidget = targetChild;
      }

      RenderBox? nextChild = myObj.childAfter(targetChild);
      if (nextChild == null) break;
      targetChild = nextChild;
    }

    List<GridViewObserveDisplayingChildModel> showingChildModelList =
        List.from(firstGroupChildModelList);

    // Find the remaining children that are being displayed
    var displayingChild = myObj.childAfter(lastFirstGroupChildWidget);
    while (displayingChild != null) {
      if (ObserverUtils.isDisplayingChildInSliver(
        targetChild: displayingChild,
        showingChildrenMaxOffset: showingChildrenMaxOffset,
        scrollViewOffset: scrollViewOffset,
        scrollDirection: scrollDirection,
        toNextOverPercent: toNextOverPercent,
      )) {
        if (displayingChild is! RenderIndexedSemantics) {
          continue;
        }
        final displayingChildIndex = displayingChild.index;
        final displayingChildModel = GridViewObserveDisplayingChildModel(
          sliverGrid: myObj,
          viewport: viewport,
          index: displayingChildIndex,
          renderObject: displayingChild,
        );
        showingChildModelList.add(displayingChildModel);
        displayingChildModelMap[displayingChildIndex] = displayingChildModel;
      }
      displayingChild = myObj.childAfter(displayingChild);
    }

    return GridViewObserveModel(
      sliverGrid: myObj,
      viewport: viewport,
      visible: true,
      firstGroupChildList: firstGroupChildModelList,
      displayingChildModelList: showingChildModelList,
      displayingChildModelMap: displayingChildModelMap,
    );
  }
}
