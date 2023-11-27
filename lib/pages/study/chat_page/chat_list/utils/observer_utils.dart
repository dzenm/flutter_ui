import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../common/models/observe_model.dart';
import '../listview/models/listview_observe_model.dart';

class ObserverUtils {
  ObserverUtils._();

  /// Calculate current extent of [RenderSliverPersistentHeader] base on
  /// target layout offset.
  /// Such as [SliverAppBar]
  ///
  /// You must pass either [key] or [context]
  static double calcPersistentHeaderExtent({
    GlobalKey? key,
    BuildContext? context,
    required double offset,
  }) {
    assert(key != null || context != null);
    final ctx = key?.currentContext ?? context;
    final obj = ObserverUtils.findRenderObject(ctx);
    if (obj is! RenderSliverPersistentHeader) return 0;
    final maxExtent = obj.maxExtent;
    final minExtent = obj.minExtent;
    final currentExtent = math.max(minExtent, maxExtent - offset);
    return currentExtent;
  }

  /// Calculate the anchor tab index.
  static int calcAnchorTabIndex({
    required ObserveModel observeModel,
    required List<int> tabIndexes,
    required int currentTabIndex,
  }) {
    if (currentTabIndex >= tabIndexes.length) {
      return currentTabIndex;
    }
    if (observeModel is ListViewObserveModel) {
      final topIndex = observeModel.firstChild?.index ?? 0;
      final index = tabIndexes.indexOf(topIndex);
      if (isValidListIndex(index)) {
        return index;
      }
      var targetTabIndex = currentTabIndex - 1;
      if (targetTabIndex < 0 || targetTabIndex >= tabIndexes.length) {
        return currentTabIndex;
      }
      var curIndex = tabIndexes[currentTabIndex];
      var lastIndex = tabIndexes[currentTabIndex - 1];
      if (curIndex > topIndex && lastIndex < topIndex) {
        final lastTabIndex = tabIndexes.indexOf(lastIndex);
        if (isValidListIndex(lastTabIndex)) {
          return lastTabIndex;
        }
      }
    }
    return currentTabIndex;
  }

  /// Determines whether the offset at the bottom of the target child widget
  /// is below the specified offset.
  static bool isBelowOffsetWidgetInSliver({
    required double scrollViewOffset,
    required Axis scrollDirection,
    required RenderBox targetChild,
    double toNextOverPercent = 1,
  }) {
    if (!targetChild.hasSize) return false;
    final parentData = targetChild.parentData;
    if (parentData is! SliverMultiBoxAdaptorParentData) {
      return false;
    }
    final targetFirstChildOffset = parentData.layoutOffset ?? 0;
    final double targetFirstChildSize;
    try {
      // In some cases, getting size may throw an exception.
      targetFirstChildSize = scrollDirection == Axis.vertical ? targetChild.size.height : targetChild.size.width;
    } catch (_) {
      return false;
    }
    return scrollViewOffset < targetFirstChildSize * toNextOverPercent + targetFirstChildOffset;
  }

  /// Determines whether the target child widget has reached the specified
  /// offset
  static bool isReachOffsetWidgetInSliver({
    required double scrollViewOffset,
    required Axis scrollDirection,
    required RenderBox targetChild,
    double toNextOverPercent = 1,
  }) {
    if (!isBelowOffsetWidgetInSliver(
      scrollViewOffset: scrollViewOffset,
      scrollDirection: scrollDirection,
      targetChild: targetChild,
      toNextOverPercent: toNextOverPercent,
    )) return false;
    final parentData = targetChild.parentData;
    if (parentData is! SliverMultiBoxAdaptorParentData) {
      return false;
    }
    final targetFirstChildOffset = parentData.layoutOffset ?? 0;
    return scrollViewOffset >= targetFirstChildOffset;
  }

  /// Determines whether the target child widget is being displayed
  static bool isDisplayingChildInSliver({
    required RenderBox? targetChild,
    required double showingChildrenMaxOffset,
    required double scrollViewOffset,
    required Axis scrollDirection,
    double toNextOverPercent = 1,
  }) {
    if (targetChild == null) {
      return false;
    }
    if (!isBelowOffsetWidgetInSliver(
      scrollViewOffset: scrollViewOffset,
      scrollDirection: scrollDirection,
      targetChild: targetChild,
      toNextOverPercent: toNextOverPercent,
    )) {
      return false;
    }
    final parentData = targetChild.parentData;
    if (parentData is! SliverMultiBoxAdaptorParentData) {
      return false;
    }
    final targetChildLayoutOffset = parentData.layoutOffset ?? 0;
    return targetChildLayoutOffset < showingChildrenMaxOffset;
  }

  /// Find out the viewport
  static RenderViewportBase? findViewport(RenderObject obj) {
    int maxCycleCount = 10;
    int currentCycleCount = 1;
    // Starting from flutter version 3.13.0, the type of parent received
    // is RenderObject, while the type of the previous version is AbstractNode,
    // but RenderObject is a subclass of AbstractNode, so for compatibility,
    // we can use RenderObject.
    var parent = obj.parent;
    if (parent is! RenderObject) {
      return null;
    }
    while (parent != null && currentCycleCount <= maxCycleCount) {
      if (parent is RenderViewportBase) {
        return parent;
      }
      parent = parent.parent;
      currentCycleCount++;
    }
    return null;
  }

  /// For viewport
  ///
  /// Determines whether the offset at the bottom of the target child widget
  /// is below the specified offset.
  static bool isBelowOffsetSliverInViewport({
    required double viewportPixels,
    RenderSliver? sliver,
  }) {
    if (sliver == null) return false;
    final layoutOffset = sliver.constraints.precedingScrollExtent;
    final size = sliver.geometry?.maxPaintExtent ?? 0;
    return viewportPixels <= layoutOffset + size;
  }

  /// For viewport
  ///
  /// Determines whether the target sliver is being displayed
  static bool isDisplayingSliverInViewport({
    required RenderSliver? sliver,
    required double viewportPixels,
    required double viewportBottomOffset,
  }) {
    if (sliver == null) {
      return false;
    }
    if (!isBelowOffsetSliverInViewport(
      viewportPixels: viewportPixels,
      sliver: sliver,
    )) {
      return false;
    }
    return sliver.constraints.precedingScrollExtent < viewportBottomOffset;
  }

  /// Determines whether it is a valid list index.
  static bool isValidListIndex(int index) {
    return index != -1;
  }

  /// Safely call findRenderObject method.
  static RenderObject? findRenderObject(BuildContext? context) {
    try {
      // It throws an exception when getting renderObject of inactive element.
      return context?.findRenderObject();
    } catch (e) {
      debugPrint('Cannot get renderObject of inactive element.\n'
          'Please call the reattach method of ObserverController to re-record '
          'BuildContext.');
      return null;
    }
  }
}
