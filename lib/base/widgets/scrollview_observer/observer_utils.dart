import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'listview/models/listview_observe_displaying_child_model.dart';
import 'listview/models/listview_observe_model.dart';
import 'observer/models/observe_model.dart';

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
    bool isMounted = context?.mounted ?? false;
    if (!isMounted) {
      return null;
    }
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

  /// Walks the children of this context.
  static BuildContext? findChildContext({
    required BuildContext context,
    required bool Function(Element) isTargetType,
  }) {
    BuildContext? childContext;
    void visitor(Element element) {
      if (isTargetType(element)) {
        /// Find the target child BuildContext
        childContext = element;
        return;
      }
      element.visitChildren(visitor);
    }

    try {
      // https://github.com/fluttercandies/flutter_scrollview_observer/issues/35
      context.visitChildElements(visitor);
    } catch (e) {
      debugPrint(
        'This widget has been unmounted, so the State no longer has a context (and should be considered defunct). \n'
        'Consider canceling any active work during "dispose" or using the "mounted" getter to determine if the State is still active.',
      );
    }
    return childContext;
  }

  /// Convert the given point from the local coordinate system for this context
  /// to the global coordinate system in logical pixels.
  ///
  /// If `ancestor` is non-null, this function converts the given point to the
  /// coordinate system of `ancestor` (which must be an ancestor of this render
  /// object of context) instead of to the global coordinate system.
  ///
  /// This method is implemented in terms of [getTransformTo]. If the transform
  /// matrix puts the given `point` on the line at infinity (for instance, when
  /// the transform matrix is the zero matrix), this method returns (NaN, NaN).
  static Offset? localToGlobal({
    required BuildContext context,
    required Offset point,
    BuildContext? ancestor,
  }) {
    final renderObject = findRenderObject(context);
    if (renderObject == null) return null;
    return MatrixUtils.transformPoint(
      renderObject.getTransformTo(findRenderObject(ancestor)),
      point,
    );
  }

  /// Handles observation logic of a sliver similar to [SliverList].
  static ListViewObserveModel? handleListObserve({
    required BuildContext context,
    double Function()? fetchLeadingOffset,
    double? Function(BuildContext)? customOverlap,
    double toNextOverPercent = 1,
  }) {
    var obj = ObserverUtils.findRenderObject(context);
    if (obj is! RenderSliverMultiBoxAdaptor) return null;
    final viewport = ObserverUtils.findViewport(obj);
    if (viewport == null) return null;
    if (kDebugMode) {
      if (viewport.debugNeedsPaint) return null;
    }
    // The geometry.visible is not absolutely reliable.
    if (!(obj.geometry?.visible ?? false) || obj.constraints.remainingPaintExtent < 1e-10) {
      return ListViewObserveModel(
        sliverList: obj,
        viewport: viewport,
        visible: false,
        firstChild: null,
        displayingChildModelList: [],
      );
    }
    final scrollDirection = obj.constraints.axis;
    var firstChild = obj.firstChild;
    if (firstChild == null) return null;

    final offset = fetchLeadingOffset?.call() ?? 0;
    final overlap = customOverlap?.call(context) ?? obj.constraints.overlap;
    final rawScrollViewOffset = obj.constraints.scrollOffset + overlap;
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
      var nextChild = obj.childAfter(targetFirstChild);
      if (nextChild == null) break;

      if (nextChild is! RenderIndexedSemantics) {
        // It is separator
        nextChild = obj.childAfter(nextChild);
      }
      if (nextChild == null) break;
      targetFirstChild = nextChild;
    }
    if (targetFirstChild is! RenderIndexedSemantics) return null;

    List<ListViewObserveDisplayingChildModel> displayingChildModelList = [
      ListViewObserveDisplayingChildModel(
        sliverList: obj,
        viewport: viewport,
        index: targetFirstChild.index,
        renderObject: targetFirstChild,
      ),
    ];

    // Find the remaining children that are being displayed
    final showingChildrenMaxOffset = rawScrollViewOffset + obj.constraints.remainingPaintExtent - overlap;
    var displayingChild = obj.childAfter(targetFirstChild);
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
        displayingChild = obj.childAfter(displayingChild);
        continue;
      }
      displayingChildModelList.add(ListViewObserveDisplayingChildModel(
        sliverList: obj,
        viewport: viewport,
        index: displayingChild.index,
        renderObject: displayingChild,
      ));
      displayingChild = obj.childAfter(displayingChild);
    }

    return ListViewObserveModel(
      sliverList: obj,
      viewport: viewport,
      visible: true,
      firstChild: ListViewObserveDisplayingChildModel(
        sliverList: obj,
        viewport: viewport,
        index: targetFirstChild.index,
        renderObject: targetFirstChild,
      ),
      displayingChildModelList: displayingChildModelList,
    );
  }
}
