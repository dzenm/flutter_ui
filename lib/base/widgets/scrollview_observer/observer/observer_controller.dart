import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../listview/list_observer_view.dart';
import '../observe_notification.dart';
import '../observer_utils.dart';
import '../sliver/sliver_observer_controller.dart';
import 'models/observe_model.dart';
import 'observer_notification_result.dart';

/// This allows a value of type T or T?
/// to be treated as a value of type T?.
///
/// We use this so that APIs that have become
/// non-nullable can still be used with `!` and `?`
/// to support older versions of the API as well.
T? ambiguate<T>(T? value) => value;

/// Signature for the callback when scrolling to the specified index location
/// with offset.
/// For example, return the height of the sticky widget.
///
/// The [targetOffset] property is the offset of the planned locate.
typedef ObserverLocateIndexOffsetCallback = double Function(double targetOffset);

class ObserverController {
  ObserverController({this.controller});

  /// Target scroll controller.
  ScrollController? controller;

  /// The map which stores the offset of child in the sliver
  Map<BuildContext, Map<int, ObserveScrollChildModel>> indexOffsetMap = {};

  /// Target sliver [BuildContext]
  List<BuildContext> sliverContexts = [];

  /// Whether to forbid the onObserve callback and onObserveAll callback.
  bool isForbidObserveCallback = false;

  /// A flag used to ignore unnecessary calculations during scrolling.
  bool innerIsHandlingScroll = false;

  /// The callback to call [ObserverWidget]'s [_handleContexts] method.
  Function()? innerNeedOnceObserveCallBack;

  /// The callback to call [ObserverWidget]'s [_setupSliverController] method.
  Function()? innerReattachCallBack;

  /// Reset all data
  void innerReset() {
    indexOffsetMap = {};
    innerIsHandlingScroll = false;
  }

  /// Get the target sliver [BuildContext]
  BuildContext? fetchSliverContext({BuildContext? sliverContext}) {
    BuildContext? myContext = sliverContext;
    if (myContext == null && sliverContexts.isNotEmpty) {
      myContext = sliverContexts.first;
    }
    return myContext;
  }

  /// Get the latest target sliver [BuildContext] and reset some of the old data.
  void reattach() {
    if (innerReattachCallBack == null) return;
    ambiguate(WidgetsBinding.instance)?.addPostFrameCallback((timeStamp) {
      innerReattachCallBack!();
    });
  }
}

mixin ObserverControllerForNotification<M extends ObserveModel, R extends ObserverHandleContextsResultModel<M>, S extends CommonOnceObserveNotificationResult<M, R>> on ObserverController {
  /// A completer for dispatch once observation
  Completer<S>? innerDispatchOnceObserveCompleter;

  /// Dispatch a observation notification
  Future<S> innerDispatchOnceObserve({
    BuildContext? sliverContext,
    required Notification notification,
  }) {
    Completer<S> completer = Completer();
    innerDispatchOnceObserveCompleter = completer;
    BuildContext? mySliverContext = fetchSliverContext(
      sliverContext: sliverContext,
    );
    notification.dispatch(mySliverContext);
    return completer.future;
  }

  /// Complete the observation notification
  void innerHandleDispatchOnceObserveComplete({
    required R? resultModel,
  }) {
    final completer = innerDispatchOnceObserveCompleter;
    if (completer == null) return;
    if (!completer.isCompleted) {
      final isSuccess = resultModel != null;
      final resultType = isSuccess ? ObserverWidgetObserveResultType.success : ObserverWidgetObserveResultType.interrupted;
      final result = innerCreateOnceObserveNotificationResult(
        resultType: resultType,
        resultModel: resultModel,
      );
      completer.complete(result);
    }
    innerDispatchOnceObserveCompleter = null;
  }

  /// Create a observation notification result.
  S innerCreateOnceObserveNotificationResult({
    required ObserverWidgetObserveResultType resultType,
    required R? resultModel,
  }) {
    // The class being mixed in will implement it and will not return null.
    throw UnimplementedError();
  }
}

mixin ObserverControllerForInfo on ObserverController {
  /// Find out the current first child in sliver
  RenderIndexedSemantics? findCurrentFirstChild(
    RenderSliverMultiBoxAdaptor obj,
  ) {
    RenderIndexedSemantics? child;
    final firstChild = obj.firstChild;
    if (firstChild == null) return null;
    if (firstChild is RenderIndexedSemantics) {
      child = firstChild;
    } else {
      final nextChild = obj.childAfter(firstChild);
      if (nextChild is RenderIndexedSemantics) {
        child = nextChild;
      }
    }
    return child;
  }

  /// Find out the next child in sliver
  RenderIndexedSemantics? findNextChild({
    required RenderSliverMultiBoxAdaptor obj,
    RenderBox? currentChild,
  }) {
    RenderIndexedSemantics? child;
    if (currentChild == null) return null;
    var nextChild = obj.childAfter(currentChild);
    if (nextChild == null) return null;
    if (nextChild is RenderIndexedSemantics) {
      child = nextChild;
    } else {
      nextChild = obj.childAfter(nextChild);
      if (nextChild is RenderIndexedSemantics) {
        child = nextChild;
      }
    }
    return child;
  }

  /// Find out the current last child in sliver
  RenderIndexedSemantics? findCurrentLastChild(RenderSliverMultiBoxAdaptor obj) {
    RenderIndexedSemantics? child;
    final lastChild = obj.lastChild;
    if (lastChild == null) return null;
    if (lastChild is RenderIndexedSemantics) {
      child = lastChild;
    } else {
      final previousChild = obj.childBefore(lastChild);
      if (previousChild is RenderIndexedSemantics) {
        child = previousChild;
      }
    }
    return child;
  }

  /// Find out the child widget info for specified index in sliver.
  ObserveFindChildModel? findChildInfo({
    required int index,
    BuildContext? sliverContext,
  }) {
    final ctx = fetchSliverContext(sliverContext: sliverContext);
    var obj = ObserverUtils.findRenderObject(ctx);
    if (obj is! RenderSliverMultiBoxAdaptor) return null;
    final viewport = ObserverUtils.findViewport(obj);
    if (viewport == null) return null;
    var targetChild = findCurrentFirstChild(obj);
    if (targetChild == null) return null;
    while (targetChild != null && (targetChild.index != index)) {
      targetChild = findNextChild(obj: obj, currentChild: targetChild);
    }
    if (targetChild == null) return null;
    return ObserveFindChildModel(
      sliver: obj,
      viewport: viewport,
      index: targetChild.index,
      renderObject: targetChild,
    );
  }

  /// Find out the first child widget info in sliver.
  ObserveFindChildModel? findCurrentFirstChildInfo({
    BuildContext? sliverContext,
  }) {
    final ctx = fetchSliverContext(sliverContext: sliverContext);
    var obj = ObserverUtils.findRenderObject(ctx);
    if (obj == null || obj is! RenderSliverMultiBoxAdaptor) return null;
    final targetChild = findCurrentFirstChild(obj);
    if (targetChild == null) return null;
    final index = targetChild.index;
    return findChildInfo(index: index, sliverContext: sliverContext);
  }

  /// Find out the viewport
  RenderViewportBase? _findViewport(RenderSliverMultiBoxAdaptor obj) {
    return ObserverUtils.findViewport(obj);
  }

  /// Getting [maxScrollExtent] of viewport
  double viewportMaxScrollExtent(RenderViewportBase viewport) {
    final offset = viewport.offset;
    if (offset is! ScrollPosition) {
      return 0;
    }
    return offset.maxScrollExtent;
  }

  /// Getting the extreme scroll extent of viewport.
  /// The [maxScrollExtent] will be returned when growthDirection is forward.
  /// The [minScrollExtent] will be returned when growthDirection is reverse.
  double viewportExtremeScrollExtent({
    required RenderViewportBase viewport,
    required RenderSliverMultiBoxAdaptor obj,
  }) {
    final offset = viewport.offset;
    if (offset is! ScrollPosition) {
      return 0;
    }
    return obj.isForwardGrowthDirection ? offset.maxScrollExtent : offset.minScrollExtent;
  }
}

mixin ObserverControllerForScroll on ObserverControllerForInfo {
  static const Duration _findingDuration = Duration(milliseconds: 1);
  static const Curve _findingCurve = Curves.ease;

  /// Whether to cache the offset when jump to a specified index position.
  /// Defaults to true.
  bool cacheJumpIndexOffset = true;

  /// The initial index position of the scrollView.
  ///
  /// Defaults to zero.
  int get initialIndex => initialIndexModel.index;

  set initialIndex(int index) {
    initialIndexModel = ObserverIndexPositionModel(index: index);
  }

  /// The initial index position model of the scrollView.
  ///
  /// Defaults to ObserverIndexPositionModel(index: 0, sliverContext: null).
  ObserverIndexPositionModel initialIndexModel = ObserverIndexPositionModel(
    index: 0,
  );

  /// The block to return [ObserverIndexPositionModel] which to init index
  /// position.
  ObserverIndexPositionModel Function()? initialIndexModelBlock;

  /// Clear the offset cache that jumping to a specified index location.
  void clearScrollIndexCache({BuildContext? sliverContext}) {
    final ctx = fetchSliverContext(sliverContext: sliverContext);
    if (ctx == null) return;
    indexOffsetMap[ctx]?.clear();
  }

  /// Init index position for scrollView.
  void innerInitialIndexPosition() {
    final model = initialIndexModelBlock?.call() ?? initialIndexModel;
    if (model.sliverContext == null && model.index <= 0) return;
    innerJumpTo(
      index: model.index,
      sliverContext: model.sliverContext,
      isFixedHeight: model.isFixedHeight,
      alignment: model.alignment,
      padding: model.padding,
      offset: model.offset,
    );
  }

  /// Jump to the specified index position without animation.
  ///
  /// If the height of the child widget and the height of the separator are
  /// fixed, please pass the [isFixedHeight] parameter and the
  /// [renderSliverType] parameter.
  ///
  /// If you do not pass the [isFixedHeight] parameter, the package will
  /// automatically gradually scroll around the target location before
  /// locating, which will produce an animation.
  ///
  /// The [renderSliverType] parameter is used to specify the type of sliver.
  /// If you do not pass the [renderSliverType] parameter, the sliding position
  /// will be calculated based on the actual type of obj, and there may be
  /// deviations in the calculation of elements for third-party libraries.
  ///
  /// The [alignment] specifies the desired position for the leading edge of the
  /// child widget. It must be a value in the range [0.0, 1.0].
  Future innerJumpTo({
    required int index,
    BuildContext? sliverContext,
    bool isFixedHeight = false,
    double alignment = 0,
    EdgeInsets padding = EdgeInsets.zero,
    ObserverLocateIndexOffsetCallback? offset,
    ObserverRenderSliverType? renderSliverType,
  }) {
    Completer completer = Completer();
    _scrollToIndex(
      completer: completer,
      index: index,
      isFixedHeight: isFixedHeight,
      alignment: alignment,
      padding: padding,
      sliverContext: sliverContext,
      offset: offset,
      renderSliverType: renderSliverType,
    );
    return completer.future;
  }

  /// Jump to the specified index position with animation.
  ///
  /// If the height of the child widget and the height of the separator are
  /// fixed, please pass the [isFixedHeight] parameter and the
  /// [renderSliverType] parameter.
  ///
  /// The [renderSliverType] parameter is used to specify the type of sliver.
  /// If you do not pass the [renderSliverType] parameter, the sliding position
  /// will be calculated based on the actual type of obj, and there may be
  /// deviations in the calculation of elements for third-party libraries.
  ///
  /// The [alignment] specifies the desired position for the leading edge of the
  /// child widget. It must be a value in the range [0.0, 1.0].
  Future innerAnimateTo({
    required int index,
    required Duration duration,
    required Curve curve,
    EdgeInsets padding = EdgeInsets.zero,
    BuildContext? sliverContext,
    bool isFixedHeight = false,
    double alignment = 0,
    ObserverLocateIndexOffsetCallback? offset,
    ObserverRenderSliverType? renderSliverType,
  }) {
    Completer completer = Completer();
    _scrollToIndex(
      completer: completer,
      index: index,
      isFixedHeight: isFixedHeight,
      alignment: alignment,
      padding: padding,
      sliverContext: sliverContext,
      duration: duration,
      curve: curve,
      offset: offset,
      renderSliverType: renderSliverType,
    );
    return completer.future;
  }

  void _scrollToIndex({
    required Completer completer,
    required int index,
    required bool isFixedHeight,
    required double alignment,
    required EdgeInsets padding,
    BuildContext? sliverContext,
    Duration? duration,
    Curve? curve,
    ObserverLocateIndexOffsetCallback? offset,
    ObserverRenderSliverType? renderSliverType,
  }) async {
    assert(alignment.clamp(0, 1) == alignment, 'The [alignment] is expected to be a value in the range [0.0, 1.0]');
    assert(controller != null);
    var myController = controller;
    final ctx = fetchSliverContext(sliverContext: sliverContext);
    if (ctx == null) {
      _handleScrollInterruption(context: ctx, completer: completer);
      return;
    }

    if (myController == null || !myController.hasClients) {
      _handleScrollInterruption(context: ctx, completer: completer);
      return;
    }

    var obj = ObserverUtils.findRenderObject(ctx);
    if (obj is! RenderSliverMultiBoxAdaptor) {
      _handleScrollInterruption(context: ctx, completer: completer);
      return;
    }

    final viewport = _findViewport(obj);
    if (viewport == null) {
      _handleScrollInterruption(context: ctx, completer: completer);
      return;
    }

    // Start executing scrolling task.
    _handleScrollStart(context: ctx);

    bool isAnimateTo = (duration != null) && (curve != null);

    // Before the next sliver is shown, it may have an incorrect value for
    // precedingScrollExtent, so we need to scroll around to get
    // precedingScrollExtent correctly.
    final objVisible = obj.geometry?.visible ?? false;
    if (!objVisible && viewport.offset.hasPixels) {
      final maxScrollExtent = viewportMaxScrollExtent(viewport);
      // If the target sliver does not paint any child because it is too far
      // away, we need to let the ScrollView scroll near it first.
      // https://github.com/LinXunFeng/flutter_scrollview_observer/issues/45
      if (obj.firstChild == null) {
        final constraints = obj.constraints;
        final precedingScrollExtent = constraints.precedingScrollExtent;
        double paintScrollExtent = precedingScrollExtent + (obj.geometry?.maxPaintExtent ?? 0);
        double targetScrollExtent = precedingScrollExtent;
        if (myController.position.pixels > paintScrollExtent) {
          targetScrollExtent = paintScrollExtent;
        }
        if (targetScrollExtent > maxScrollExtent) {
          targetScrollExtent = maxScrollExtent;
        }
        await myController.animateTo(
          targetScrollExtent,
          duration: _findingDuration,
          curve: _findingCurve,
        );
        await WidgetsBinding.instance.endOfFrame;
      } else {
        final precedingScrollExtent = obj.constraints.precedingScrollExtent;
        final viewportOffset = viewport.offset.pixels;
        final isHorizontal = obj.constraints.axis == Axis.horizontal;
        final viewportSize = isHorizontal ? viewport.size.width : viewport.size.height;
        final viewportBoundaryExtent = viewportSize * 0.5 + (viewport.cacheExtent ?? 0);
        if (precedingScrollExtent > (viewportOffset + viewportBoundaryExtent)) {
          double targetOffset = precedingScrollExtent - viewportBoundaryExtent;
          if (targetOffset > maxScrollExtent) targetOffset = maxScrollExtent;
          await myController.animateTo(
            targetOffset,
            duration: _findingDuration,
            curve: _findingCurve,
          );
          await WidgetsBinding.instance.endOfFrame;
        }
      }
    }

    var targetScrollChildModel = indexOffsetMap[ctx]?[index];
    // There is a cache offset, scroll to the offset directly.
    if (targetScrollChildModel != null) {
      _handleScrollDecision(context: ctx);
      var targetOffset = _calculateTargetLayoutOffset(
        obj: obj,
        childLayoutOffset: targetScrollChildModel.layoutOffset,
        childSize: targetScrollChildModel.size,
        alignment: alignment,
        padding: padding,
        offset: offset,
      );
      if (isAnimateTo) {
        await myController.animateTo(
          targetOffset,
          duration: duration,
          curve: curve,
        );
      } else {
        myController.jumpTo(targetOffset);
      }
      _handleScrollEnd(context: ctx, completer: completer);
      return;
    }

    // Because it is fixed height, the offset can be directly calculated for
    // locating.
    if (isFixedHeight) {
      _handleScrollToIndexForFixedHeight(
        completer: completer,
        ctx: ctx,
        obj: obj,
        index: index,
        alignment: alignment,
        padding: padding,
        duration: duration,
        curve: curve,
        offset: offset,
        renderSliverType: renderSliverType,
      );
      return;
    }

    // Find the index of the first [RenderIndexedSemantics] child in viewport
    var firstChildIndex = 0;
    var lastChildIndex = 0;
    final firstChild = findCurrentFirstChild(obj);
    final lastChild = findCurrentLastChild(obj);
    if (firstChild == null || lastChild == null) {
      _handleScrollInterruption(context: ctx, completer: completer);
      return;
    }
    firstChildIndex = firstChild.index;
    lastChildIndex = lastChild.index;

    _handleScrollToIndex(
      completer: completer,
      ctx: ctx,
      obj: obj,
      index: index,
      alignment: alignment,
      firstChildIndex: firstChildIndex,
      lastChildIndex: lastChildIndex,
      padding: padding,
      duration: duration,
      curve: curve,
      offset: offset,
    );
  }

  /// Scrolling to the specified index location when the child widgets have a
  /// fixed height.
  void _handleScrollToIndexForFixedHeight({
    required Completer completer,
    required BuildContext ctx,
    required RenderSliverMultiBoxAdaptor obj,
    required int index,
    required double alignment,
    required EdgeInsets padding,
    Duration? duration,
    Curve? curve,
    ObserverLocateIndexOffsetCallback? offset,
    ObserverRenderSliverType? renderSliverType,
  }) async {
    assert(controller != null);
    var myController = controller;
    if (myController == null || !myController.hasClients) {
      _handleScrollInterruption(context: ctx, completer: completer);
      return;
    }
    bool isAnimateTo = (duration != null) && (curve != null);

    final targetChild = findCurrentFirstChild(obj);
    if (targetChild == null) {
      _handleScrollInterruption(context: ctx, completer: completer);
      return;
    }
    ObserveScrollToIndexFixedHeightResultModel resultModel;
    if (ListViewObserver.isSupportRenderSliverType(obj) || renderSliverType == ObserverRenderSliverType.list) {
      // ListView
      resultModel = _calculateScrollToIndexForFixedHeightResultForList(
        obj: obj,
        targetChild: targetChild,
        index: index,
      );
    } else if (obj is RenderSliverGrid || renderSliverType == ObserverRenderSliverType.grid) {
      // GirdView
      resultModel = _calculateScrollToIndexForFixedHeightResultForGrid(
        obj: obj,
        targetChild: targetChild,
        index: index,
      );
    } else {
      // Other
      _handleScrollInterruption(context: ctx, completer: completer);
      return;
    }
    _handleScrollDecision(context: ctx);

    double childMainAxisSize = resultModel.childMainAxisSize;
    double childLayoutOffset = resultModel.targetChildLayoutOffset;

    _updateIndexOffsetMap(
      ctx: ctx,
      index: index,
      childLayoutOffset: childLayoutOffset,
      childSize: childMainAxisSize,
    );

    // Getting safety layout offset.
    childLayoutOffset = _calculateTargetLayoutOffset(
      obj: obj,
      childLayoutOffset: childLayoutOffset,
      childSize: childMainAxisSize,
      alignment: alignment,
      padding: padding,
      offset: offset,
    );
    if (isAnimateTo) {
      Duration myDuration = isAnimateTo ? duration : const Duration(milliseconds: 1);
      Curve myCurve = isAnimateTo ? curve : Curves.linear;
      await myController.animateTo(
        childLayoutOffset,
        duration: myDuration,
        curve: myCurve,
      );
    } else {
      myController.jumpTo(childLayoutOffset);
    }
    _handleScrollEnd(context: ctx, completer: completer);
  }

  /// Scrolling to the specified index location by gradually scrolling around
  /// the target index location.
  void _handleScrollToIndex({
    required Completer completer,
    required BuildContext ctx,
    required RenderSliverMultiBoxAdaptor obj,
    required int index,
    required double alignment,
    required int firstChildIndex,
    required int lastChildIndex,
    required EdgeInsets padding,
    Duration? duration,
    Curve? curve,
    ObserverLocateIndexOffsetCallback? offset,
    double? lastPageTurningOffset,
  }) async {
    var myController = controller;
    if (myController == null || !myController.hasClients) {
      _handleScrollInterruption(context: ctx, completer: completer);
      return;
    }

    final viewport = _findViewport(obj);
    if (viewport == null) {
      _handleScrollInterruption(context: ctx, completer: completer);
      return;
    }
    final maxScrollExtent = viewportMaxScrollExtent(viewport);

    final isHorizontal = obj.constraints.axis == Axis.horizontal;
    bool isAnimateTo = (duration != null) && (curve != null);
    final precedingScrollExtent = obj.constraints.precedingScrollExtent;

    if (index < firstChildIndex) {
      final sliverSize = isHorizontal ? obj.paintBounds.width : obj.paintBounds.height;
      double childLayoutOffset = 0;
      final firstChild = findCurrentFirstChild(obj);
      final parentData = firstChild?.parentData;
      if (parentData is SliverMultiBoxAdaptorParentData) {
        childLayoutOffset = parentData.layoutOffset ?? 0;
      }
      var targetLeadingOffset = childLayoutOffset - sliverSize;
      if (targetLeadingOffset < 0) {
        targetLeadingOffset = 0;
      }
      double prevPageOffset = targetLeadingOffset + precedingScrollExtent;
      prevPageOffset = prevPageOffset < 0 ? 0 : prevPageOffset;
      // The offset of this page turning is the same as the previous one,
      // which means the [index] is wrong.
      if (lastPageTurningOffset == prevPageOffset) {
        debugPrint('The child corresponding to the index cannot be found.\n'
            'Please make sure the index is correct.');
        _handleScrollInterruption(context: ctx, completer: completer);
        return;
      }
      lastPageTurningOffset = prevPageOffset;
      if (isAnimateTo) {
        await myController.animateTo(
          prevPageOffset,
          duration: _findingDuration,
          curve: _findingCurve,
        );
      } else {
        myController.jumpTo(prevPageOffset);
      }

      ambiguate(WidgetsBinding.instance)?.addPostFrameCallback((_) {
        final firstChild = findCurrentFirstChild(obj);
        final lastChild = findCurrentLastChild(obj);
        if (firstChild == null || lastChild == null) {
          _handleScrollInterruption(context: ctx, completer: completer);
          return;
        }
        firstChildIndex = firstChild.index;
        lastChildIndex = lastChild.index;
        _handleScrollToIndex(
          completer: completer,
          ctx: ctx,
          obj: obj,
          index: index,
          alignment: alignment,
          firstChildIndex: firstChildIndex,
          lastChildIndex: lastChildIndex,
          padding: padding,
          duration: duration,
          curve: curve,
          offset: offset,
          lastPageTurningOffset: lastPageTurningOffset,
        );
      });
    } else if (index > lastChildIndex) {
      final lastChild = findCurrentLastChild(obj);
      final childSize = (isHorizontal ? lastChild?.paintBounds.width : lastChild?.paintBounds.height) ?? 0;
      double childLayoutOffset = 0;
      final parentData = lastChild?.parentData;
      if (parentData is SliverMultiBoxAdaptorParentData) {
        childLayoutOffset = parentData.layoutOffset ?? 0;
      }
      double nextPageOffset = childLayoutOffset + childSize + precedingScrollExtent;
      nextPageOffset = nextPageOffset > maxScrollExtent ? maxScrollExtent : nextPageOffset;
      // The offset of this page turning is the same as the previous one,
      // which means the [index] is wrong.
      if (lastPageTurningOffset == nextPageOffset) {
        debugPrint('The child corresponding to the index cannot be found.\n'
            'Please make sure the index is correct.');
        _handleScrollInterruption(context: ctx, completer: completer);
        return;
      }
      lastPageTurningOffset = nextPageOffset;
      if (isAnimateTo) {
        await myController.animateTo(
          nextPageOffset,
          duration: _findingDuration,
          curve: _findingCurve,
        );
      } else {
        myController.jumpTo(nextPageOffset);
      }

      ambiguate(WidgetsBinding.instance)?.addPostFrameCallback((_) {
        final firstChild = findCurrentFirstChild(obj);
        final lastChild = findCurrentLastChild(obj);
        if (firstChild == null || lastChild == null) {
          _handleScrollInterruption(context: ctx, completer: completer);
          return;
        }
        firstChildIndex = firstChild.index;
        lastChildIndex = lastChild.index;
        _handleScrollToIndex(
          completer: completer,
          ctx: ctx,
          obj: obj,
          index: index,
          alignment: alignment,
          firstChildIndex: firstChildIndex,
          lastChildIndex: lastChildIndex,
          padding: padding,
          duration: duration,
          curve: curve,
          offset: offset,
          lastPageTurningOffset: lastPageTurningOffset,
        );
      });
    } else {
      // Target index child is already in viewport
      var targetChild = obj.firstChild;
      while (targetChild != null) {
        if (targetChild is! RenderIndexedSemantics) {
          targetChild = obj.childAfter(targetChild);
          continue;
        }
        final currentChildIndex = targetChild.index;
        double childLayoutOffset = 0;
        final parentData = targetChild.parentData;
        if (parentData is SliverMultiBoxAdaptorParentData) {
          childLayoutOffset = parentData.layoutOffset ?? 0;
        }
        final isHorizontal = obj.constraints.axis == Axis.horizontal;
        final childPaintBounds = targetChild.paintBounds;
        final childSize = isHorizontal ? childPaintBounds.width : childPaintBounds.height;
        _updateIndexOffsetMap(
          ctx: ctx,
          index: currentChildIndex,
          childLayoutOffset: childLayoutOffset,
          childSize: childSize,
        );
        if (currentChildIndex != index) {
          targetChild = obj.childAfter(targetChild);
          continue;
        } else {
          _handleScrollDecision(context: ctx);

          var targetOffset = _calculateTargetLayoutOffset(
            obj: obj,
            childLayoutOffset: childLayoutOffset,
            childSize: childSize,
            alignment: alignment,
            padding: padding,
            offset: offset,
          );
          if (isAnimateTo) {
            Duration myDuration = isAnimateTo ? duration : const Duration(milliseconds: 1);
            Curve myCurve = isAnimateTo ? curve : Curves.linear;
            await myController.animateTo(
              targetOffset,
              duration: myDuration,
              curve: myCurve,
            );
          } else {
            myController.jumpTo(targetOffset);
          }

          _handleScrollEnd(context: ctx, completer: completer);
        }
        break;
      }
    }
  }

  /// Getting target safety layout offset for scrolling to index.
  /// This can avoid jitter.
  double _calculateTargetLayoutOffset({
    required RenderSliverMultiBoxAdaptor obj,
    required double childLayoutOffset,
    required double childSize,
    required double alignment,
    required EdgeInsets padding,
    ObserverLocateIndexOffsetCallback? offset,
  }) {
    final precedingScrollExtent = obj.constraints.precedingScrollExtent;
    double targetItemLeadingPadding = childSize * alignment;
    var targetOffset = childLayoutOffset + precedingScrollExtent + targetItemLeadingPadding;
    double scrollOffset = 0;
    double remainingBottomExtent = 0;
    double needScrollExtent = 0;

    if (this is SliverObserverController) {
      final viewport = _findViewport(obj);
      if (viewport != null && viewport.offset.hasPixels) {
        scrollOffset = viewport.offset.pixels;
        final maxScrollExtent = viewportMaxScrollExtent(viewport);
        remainingBottomExtent = maxScrollExtent - scrollOffset;
        needScrollExtent = childLayoutOffset + precedingScrollExtent + targetItemLeadingPadding - scrollOffset;
      }
    } else {
      final constraints = obj.constraints;
      final isVertical = constraints.axis == Axis.vertical;
      final trailingPadding = isVertical ? padding.bottom : padding.right;
      final viewportExtent = constraints.viewportMainAxisExtent;
      final geometry = obj.geometry;
      // The (estimated) total scrollable extent of this sliver.
      double scrollExtent = geometry?.scrollExtent ?? 0;
      scrollOffset = obj.constraints.scrollOffset;
      remainingBottomExtent = scrollExtent + precedingScrollExtent + trailingPadding - scrollOffset - viewportExtent;
      needScrollExtent = childLayoutOffset + precedingScrollExtent + targetItemLeadingPadding - scrollOffset;
    }

    final outerOffset = offset?.call(targetOffset) ?? 0;
    needScrollExtent = needScrollExtent - outerOffset;
    // The bottom remaining distance is satisfied to go completely scrolling.
    bool isEnoughScroll = remainingBottomExtent >= needScrollExtent;
    if (!isEnoughScroll) {
      targetOffset = remainingBottomExtent + scrollOffset;
    } else {
      targetOffset = needScrollExtent + scrollOffset;
    }
    // The remainingBottomExtent may be negative when the scrollView has too
    // few items.
    targetOffset = targetOffset.clamp(0, double.maxFinite);
    return targetOffset;
  }

  /// Calculate the information about scrolling to the specified index location
  /// when the type is ObserverRenderSliverType.list.
  ObserveScrollToIndexFixedHeightResultModel _calculateScrollToIndexForFixedHeightResultForList({
    required RenderSliverMultiBoxAdaptor obj,
    required RenderIndexedSemantics targetChild,
    required int index,
  }) {
    final childPaintBounds = targetChild.paintBounds;
    final isHorizontal = obj.constraints.axis == Axis.horizontal;
    // The separator size between items on the main axis.
    double itemSeparatorHeight = 0;

    /// The size of item on the main axis.
    final childMainAxisSize = isHorizontal ? childPaintBounds.width : childPaintBounds.height;

    var nextChild = obj.childAfter(targetChild);
    nextChild ??= obj.childBefore(targetChild);
    if (nextChild != null && nextChild is! RenderIndexedSemantics) {
      // It is separator
      final nextChildPaintBounds = nextChild.paintBounds;
      itemSeparatorHeight = isHorizontal ? nextChildPaintBounds.width : nextChildPaintBounds.height;
    }
    // Calculate the offset of the target child widget on the main axis.
    double targetChildLayoutOffset = (childMainAxisSize + itemSeparatorHeight) * index;

    return ObserveScrollToIndexFixedHeightResultModel(
      childMainAxisSize: childMainAxisSize,
      itemSeparatorHeight: itemSeparatorHeight,
      indexOfLine: index,
      targetChildLayoutOffset: targetChildLayoutOffset,
    );
  }

  /// Calculate the information about scrolling to the specified index location
  /// when the type is ObserverRenderSliverType.grid.
  ObserveScrollToIndexFixedHeightResultModel _calculateScrollToIndexForFixedHeightResultForGrid({
    required RenderSliverMultiBoxAdaptor obj,
    required RenderIndexedSemantics targetChild,
    required int index,
  }) {
    final childPaintBounds = targetChild.paintBounds;
    final isHorizontal = obj.constraints.axis == Axis.horizontal;
    // The separator size between items on the main axis.
    double itemSeparatorHeight = 0;
    // The number of rows for the target item.
    int indexOfLine = index;

    /// The size of item on the main axis.
    final childMainAxisSize = isHorizontal ? childPaintBounds.width : childPaintBounds.height;

    double crossAxisSpacing = 0;
    bool isHaveSetCrossAxisSpacing = false;
    var nextChild = obj.childAfter(targetChild);
    // Find the next child that is not on the same line and calculate the
    // mainAxisSpacing.
    var nextChildOrigin = nextChild?.localToGlobal(Offset.zero) ?? Offset.zero;
    final targetChildOrigin = targetChild.localToGlobal(Offset.zero);
    while (nextChild != null && (isHorizontal ? nextChildOrigin.dx == targetChildOrigin.dx : nextChildOrigin.dy == targetChildOrigin.dy)) {
      if (!isHaveSetCrossAxisSpacing) {
        // Find the next child on the same line and calculate the
        // crossAxisSpacing.
        if (isHorizontal) {
          crossAxisSpacing = (nextChildOrigin.dy - targetChildOrigin.dy).abs() - childPaintBounds.height;
        } else {
          crossAxisSpacing = (nextChildOrigin.dx - targetChildOrigin.dx).abs() - childPaintBounds.width;
        }
        isHaveSetCrossAxisSpacing = true;
      }
      nextChild = obj.childAfter(nextChild);
      nextChildOrigin = nextChild?.localToGlobal(Offset.zero) ?? Offset.zero;
    }
    if (nextChild != null) {
      if (isHorizontal) {
        itemSeparatorHeight = (nextChildOrigin.dx - targetChildOrigin.dx).abs() - childPaintBounds.width;
      } else {
        itemSeparatorHeight = (nextChildOrigin.dy - targetChildOrigin.dy).abs() - childPaintBounds.height;
      }
    } else {
      // Can't find the next child that is not on the same line.
      // Find the before child that is not on the same line and calculate the
      // mainAxisSpacing.
      var previousChild = obj.childBefore(targetChild);
      var previousChildOrigin = previousChild?.localToGlobal(Offset.zero) ?? Offset.zero;
      while (previousChild != null && (isHorizontal ? previousChildOrigin.dx == targetChildOrigin.dx : previousChildOrigin.dy == targetChildOrigin.dy)) {
        if (!isHaveSetCrossAxisSpacing) {
          // Find two child on the same line and calculate the
          // crossAxisSpacing.
          double firstBeforeCrossAxisOrigin = isHorizontal ? previousChildOrigin.dy : previousChildOrigin.dx;
          previousChild = obj.childBefore(previousChild);
          previousChildOrigin = previousChild?.localToGlobal(Offset.zero) ?? Offset.zero;
          if (previousChild != null) {
            double secondBeforeCrossAxisOrigin = isHorizontal ? previousChildOrigin.dy : previousChildOrigin.dx;
            crossAxisSpacing = (firstBeforeCrossAxisOrigin - secondBeforeCrossAxisOrigin).abs() - (isHorizontal ? childPaintBounds.height : childPaintBounds.width);
            isHaveSetCrossAxisSpacing = true;
          }
        } else {
          previousChild = obj.childBefore(previousChild);
          previousChildOrigin = previousChild?.localToGlobal(Offset.zero) ?? Offset.zero;
        }
      }
      if (previousChild != null) {
        if (isHorizontal) {
          itemSeparatorHeight = (targetChildOrigin.dx - previousChildOrigin.dx).abs() - childPaintBounds.width;
        } else {
          itemSeparatorHeight = (targetChildOrigin.dy - previousChildOrigin.dy).abs() - childPaintBounds.height;
        }
      }
    }
    final childCrossAxisSize = isHorizontal ? childPaintBounds.height : childPaintBounds.width;
    // Calculate the number of lines.
    // round() for avoiding precision errors.
    int itemsPerLine = ((obj.constraints.crossAxisExtent + crossAxisSpacing) / (childCrossAxisSize + crossAxisSpacing)).round();
    // Calculate the number of lines.
    indexOfLine = (index / itemsPerLine).floor();
    // Calculate the offset of the target child widget on the main axis.
    double targetChildLayoutOffset = (childMainAxisSize + itemSeparatorHeight) * indexOfLine;

    return ObserveScrollToIndexFixedHeightResultModel(
      childMainAxisSize: childMainAxisSize,
      itemSeparatorHeight: itemSeparatorHeight,
      indexOfLine: indexOfLine,
      targetChildLayoutOffset: targetChildLayoutOffset,
    );
  }

  /// Update the [indexOffsetMap] property.
  void _updateIndexOffsetMap({
    required BuildContext ctx,
    required int index,
    required double childLayoutOffset,
    required double childSize,
  }) {
    // No need to cache
    if (!cacheJumpIndexOffset) return;
    // To cache offset
    final map = indexOffsetMap[ctx] ?? {};
    map[index] = ObserveScrollChildModel(
      layoutOffset: childLayoutOffset,
      size: childSize,
    );
    indexOffsetMap[ctx] = map;
  }

  /// Called when starting the scrolling task.
  void _handleScrollStart({
    required BuildContext? context,
  }) {
    innerIsHandlingScroll = true;
    ObserverScrollStartNotification().dispatch(context);
  }

  /// Called when the scrolling task is interrupted.
  ///
  /// For example, the conditions are not met, or the item with the specified
  /// index cannot be found, etc.
  void _handleScrollInterruption({
    required BuildContext? context,
    required Completer completer,
  }) {
    innerIsHandlingScroll = false;
    completer.complete();
    ObserverScrollInterruptionNotification().dispatch(context);
  }

  /// Called when the item with the specified index has been found.
  void _handleScrollDecision({
    required BuildContext? context,
  }) {
    ObserverScrollDecisionNotification().dispatch(context);
  }

  /// Called after completing the scrolling task.
  void _handleScrollEnd({
    required BuildContext? context,
    required Completer completer,
  }) {
    if (innerNeedOnceObserveCallBack != null) {
      ambiguate(WidgetsBinding.instance)?.addPostFrameCallback((_) {
        innerIsHandlingScroll = false;
        innerNeedOnceObserveCallBack!();
        completer.complete();
        ObserverScrollEndNotification().dispatch(context);
      });
    } else {
      innerIsHandlingScroll = false;
      completer.complete();
      ObserverScrollEndNotification().dispatch(context);
    }
  }
}

class ObserverIndexPositionModel {
  ObserverIndexPositionModel({
    required this.index,
    this.sliverContext,
    this.isFixedHeight = false,
    this.alignment = 0,
    this.offset,
    this.padding = EdgeInsets.zero,
  });

  /// The index position of the scrollView.
  int index;

  /// The target sliver [BuildContext].
  BuildContext? sliverContext;

  /// If the height of the child widget and the height of the separator are
  /// fixed, please pass [true] to this property.
  bool isFixedHeight;

  /// The [alignment] specifies the desired position for the leading edge of the
  /// child widget.
  ///
  /// It must be a value in the range [0.0, 1.0].
  double alignment;

  /// Use this property when locating position needs an offset.
  ObserverLocateIndexOffsetCallback? offset;

  /// This value is required when the scrollView is wrapped in the
  /// [SliverPadding].
  ///
  /// For example:
  /// 1. ListView.separated(padding: _padding, ...)
  /// 2. GridView.builder(padding: _padding, ...)
  EdgeInsets padding;
}

class ObserveScrollToIndexFixedHeightResultModel {
  /// The size of item on the main axis.
  double childMainAxisSize;

  /// The separator size between items on the main axis.
  double itemSeparatorHeight;

  /// The number of rows for the target item.
  int indexOfLine;

  /// The offset of the target child widget on the main axis.
  double targetChildLayoutOffset;

  ObserveScrollToIndexFixedHeightResultModel({
    required this.childMainAxisSize,
    required this.itemSeparatorHeight,
    required this.indexOfLine,
    required this.targetChildLayoutOffset,
  });
}

/// Define type of the observed render sliver.
enum ObserverRenderSliverType {
  /// listView
  list,

  /// gridView
  grid,
}

extension ObserverDouble on double {
  /// Rectify the value according to the current growthDirection of sliver.
  ///
  /// If the growthDirection is [GrowthDirection.forward], the value is
  /// returned directly, otherwise the opposite value is returned.
  double rectify(
    RenderSliver obj,
  ) {
    return obj.isForwardGrowthDirection ? this : -this;
  }
}

extension ObserverRenderSliverMultiBoxAdaptor on RenderSliver {
  /// Determine whether the current growthDirection of sliver is
  /// [GrowthDirection.forward].
  bool get isForwardGrowthDirection {
    return GrowthDirection.forward == constraints.growthDirection;
  }
}
