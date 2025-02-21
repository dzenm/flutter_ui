import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../common/observer_typedef.dart';
import '../../common/typedefs.dart';
import '../../sliver/sliver_observer_controller.dart';
import 'observer_utils.dart';

enum NestedScrollUtilPosition {
  /// Corresponds to the headerSliver in [NestedScrollView].
  header,

  /// Corresponds to the body in [NestedScrollView].
  body,
}

class NestedScrollUtil {
  /// Record the [BuildContext] corresponding to all header slivers of
  /// NestedScrollView.
  List<BuildContext> headerSliverContexts = [];

  /// Record the [BuildContext] corresponding to all body slivers of
  /// NestedScrollView.
  List<BuildContext> bodySliverContexts = [];

  /// Record the [BuildContext] of [SliverFillRemaining].
  BuildContext? remainingSliverContext;

  /// Record the [RenderObject] of [SliverFillRemaining].
  RenderSliverSingleBoxAdapter? remainingSliverRenderObj;

  /// The outer [ScrollController] of a NestedScrollView.
  ScrollController? outerScrollController;

  /// The inner [ScrollController] in the body of a NestedScrollView.
  ScrollController? bodyScrollController;

  /// Calculate the overlap for the body sliver.
  double? calcOverlap({
    required GlobalKey nestedScrollViewKey,
    required BuildContext sliverContext,
  }) {
    final nestedScrollViewCtx = nestedScrollViewKey.currentContext;
    if (nestedScrollViewCtx == null) return null;

    // If the sliver of ctx is headerSliver, just return null and use the
    // default overlap.
    if (!bodySliverContexts.contains(sliverContext)) return null;

    // Get SliverFillRemaining
    final remainingSliverContext = fetchRemainingSliverContext(
      nestedScrollViewKey: nestedScrollViewKey,
    );
    if (remainingSliverContext == null || remainingSliverRenderObj == null) {
      return null;
    }

    /// Calculate the offset of the sliver corresponding to sliverContext
    /// relative to SliverFillRemaining.
    final offset = ObserverUtils.localToGlobal(
      context: sliverContext,
      point: Offset.zero,
      ancestor: remainingSliverContext,
    );
    if (offset == null) return null;

    final remainingContextOverlap =
        remainingSliverRenderObj!.constraints.overlap;
    final sliverContextExtraOverlap =
        (remainingContextOverlap - offset.dy).clamp(0, double.infinity);

    var myObj = ObserverUtils.findRenderObject(sliverContext);
    if (myObj is! RenderSliverMultiBoxAdaptor) return null;
    return sliverContextExtraOverlap + myObj.constraints.overlap;
  }

  /// Calculate the [precedingScrollExtent] for [sliverContext].
  double? calcPrecedingScrollExtent({
    required GlobalKey nestedScrollViewKey,
    required BuildContext sliverContext,
  }) {
    double precedingScrollExtent = 0;
    var myObj = ObserverUtils.findRenderObject(sliverContext);
    if (myObj is! RenderSliverMultiBoxAdaptor) return null;
    precedingScrollExtent = myObj.constraints.precedingScrollExtent;

    // Get SliverFillRemaining
    final remainingSliverContext = fetchRemainingSliverContext(
      nestedScrollViewKey: nestedScrollViewKey,
    );
    if (remainingSliverContext == null || remainingSliverRenderObj == null) {
      return null;
    }
    precedingScrollExtent +=
        remainingSliverRenderObj?.constraints.precedingScrollExtent ?? 0;
    return precedingScrollExtent;
  }

  /// Reset all data.
  reset() {
    headerSliverContexts.clear();
    bodySliverContexts.clear();
    remainingSliverContext = null;
    remainingSliverRenderObj = null;
    outerScrollController = null;
    bodyScrollController = null;
  }

  /// Get SliverFillRemaining
  BuildContext? fetchRemainingSliverContext({
    required GlobalKey nestedScrollViewKey,
  }) {
    // Find out SliverFillRemaining
    final nestedScrollViewCtx = nestedScrollViewKey.currentContext;
    if (nestedScrollViewCtx == null) return null;
    remainingSliverContext ??= ObserverUtils.findChildContext(
      context: nestedScrollViewCtx,
      isTargetType: (ctx) {
        final obj = ctx.findRenderObject();
        if (obj is RenderSliverSingleBoxAdapter) {
          remainingSliverRenderObj = obj;
          return true;
        }
        return false;
      },
    );
    return remainingSliverContext;
  }

  /// Jump to the specified index position.
  jumpTo({
    required GlobalKey nestedScrollViewKey,
    required SliverObserverController observerController,
    required NestedScrollUtilPosition position,
    required int index,
    required BuildContext? sliverContext,
    bool isFixedHeight = false,
    double alignment = 0,
    EdgeInsets padding = EdgeInsets.zero,
    ObserverLocateIndexOffsetCallback? offset,
    ObserverRenderSliverType? renderSliverType,
  }) {
    assert(outerScrollController != null, 'outerScrollController is null');
    assert(bodyScrollController != null, 'bodyScrollController is null');
    if (outerScrollController == null) return;
    if (bodyScrollController == null) return;
    switchScrollController(
      observerController: observerController,
      position: position,
    );

    observerController.jumpTo(
      index: index,
      sliverContext: sliverContext,
      isFixedHeight: isFixedHeight,
      alignment: alignment,
      padding: padding,
      offset: offset,
      renderSliverType: renderSliverType,
      onPrepareScrollToIndex: handleOnPrepareScrollToIndex(
        nestedScrollViewKey: nestedScrollViewKey,
        position: position,
        outerScrollController: outerScrollController!,
        offset: offset,
      ),
    );
  }

  /// Animate to the specified index position.
  animateTo({
    required GlobalKey nestedScrollViewKey,
    required SliverObserverController observerController,
    required NestedScrollUtilPosition position,
    required int index,
    required Duration duration,
    required Curve curve,
    required BuildContext? sliverContext,
    bool isFixedHeight = false,
    double alignment = 0,
    EdgeInsets padding = EdgeInsets.zero,
    ObserverLocateIndexOffsetCallback? offset,
    ObserverRenderSliverType? renderSliverType,
  }) {
    assert(outerScrollController != null, 'outerScrollController is null');
    assert(bodyScrollController != null, 'bodyScrollController is null');
    if (outerScrollController == null) return;
    if (bodyScrollController == null) return;
    switchScrollController(
      observerController: observerController,
      position: position,
    );

    observerController.animateTo(
      index: index,
      duration: duration,
      curve: curve,
      sliverContext: sliverContext,
      isFixedHeight: isFixedHeight,
      alignment: alignment,
      padding: padding,
      offset: offset,
      renderSliverType: renderSliverType,
      onPrepareScrollToIndex: handleOnPrepareScrollToIndex(
        nestedScrollViewKey: nestedScrollViewKey,
        position: position,
        outerScrollController: outerScrollController!,
        duration: duration,
        curve: curve,
        offset: offset,
      ),
    );
  }

  /// Switch the [ScrollController] of [observerController] according to the
  /// [NestedScrollUtilPosition].
  switchScrollController({
    required SliverObserverController observerController,
    required NestedScrollUtilPosition position,
  }) {
    assert(outerScrollController != null, 'outerScrollController is null');
    assert(bodyScrollController != null, 'bodyScrollController is null');
    if (outerScrollController == null) return;
    if (bodyScrollController == null) return;

    switch (position) {
      case NestedScrollUtilPosition.header:
        observerController.controller = outerScrollController;
        break;
      case NestedScrollUtilPosition.body:
        observerController.controller = bodyScrollController;
        break;
    }
  }

  /// Handle the [onPrepareScrollToIndex] callback.
  ObserverOnPrepareScrollToIndex? handleOnPrepareScrollToIndex({
    required GlobalKey nestedScrollViewKey,
    required NestedScrollUtilPosition position,
    required ScrollController outerScrollController,
    Duration? duration,
    Curve? curve,
    ObserverLocateIndexOffsetCallback? offset,
  }) {
    switch (position) {
      case NestedScrollUtilPosition.header:
        return null;
      case NestedScrollUtilPosition.body:
        return (calcResult) async {
          if (calcResult.calculateTargetLayoutOffset > 0) {
            // Here we can get the item's offset accurately.
            return false;
          }
          // The item is located relatively top, and the accurate item
          // offset cannot be obtained.
          // So here we jump through outerScrollController.
          final remainingSliverContext = fetchRemainingSliverContext(
            nestedScrollViewKey: nestedScrollViewKey,
          );
          var remainingSliverContextObj = ObserverUtils.findRenderObject(
            remainingSliverContext,
          );
          if (remainingSliverContextObj is! RenderSliverSingleBoxAdapter) {
            return false;
          }
          double targetOffset =
              remainingSliverContextObj.constraints.precedingScrollExtent;
          targetOffset -= offset?.call(targetOffset) ?? 0;
          targetOffset += calcResult.targetChildLayoutOffset;
          if (duration != null && curve != null) {
            outerScrollController.animateTo(
              targetOffset,
              duration: duration,
              curve: curve,
            );
          } else {
            outerScrollController.jumpTo(targetOffset);
          }
          return true;
        };
    }
  }
}
