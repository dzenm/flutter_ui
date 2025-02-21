import 'package:flutter/material.dart';

import '../common/models/observe_model.dart';
import '../common/observer_controller.dart';
import '../common/observer_typedef.dart';
import '../common/typedefs.dart';
import '../notification.dart';
import 'models/sliver_observer_observe_result_model.dart';
import 'sliver_observer_notification_result.dart';

class SliverObserverController extends ObserverController
    with
        ObserverControllerForInfo,
        ObserverControllerForScroll,
        ObserverControllerForNotification<
            ObserveModel,
            SliverObserverHandleContextsResultModel<ObserveModel>,
            ScrollViewOnceObserveNotificationResult> {
  /// Whether to forbid the onObserveViewport callback.
  bool isForbidObserveViewportCallback = false;

  SliverObserverController({
    super.controller,
  });

  /// Dispatch a [ScrollViewOnceObserveNotification]
  Future<ScrollViewOnceObserveNotificationResult> dispatchOnceObserve({
    required BuildContext sliverContext,
    bool isForce = false,
    bool isDependObserveCallback = true,
  }) {
    return innerDispatchOnceObserve(
      sliverContext: sliverContext,
      notification: ScrollViewOnceObserveNotification(
        isForce: isForce,
        isDependObserveCallback: isDependObserveCallback,
      ),
    );
  }

  /// Create a observation notification result.
  @override
  ScrollViewOnceObserveNotificationResult
      innerCreateOnceObserveNotificationResult({
    required ObserverWidgetObserveResultType resultType,
    required SliverObserverHandleContextsResultModel<ObserveModel>? resultModel,
  }) {
    return ScrollViewOnceObserveNotificationResult(
      type: resultType,
      observeResult: resultModel ?? SliverObserverHandleContextsResultModel(),
    );
  }

  /// Jump to the specified index position with animation.
  ///
  /// If the height of the child widget and the height of the separator are
  /// fixed, please pass the [isFixedHeight] parameter and the
  /// [renderSliverType] parameter .
  ///
  /// The [alignment] specifies the desired position for the leading edge of the
  /// child widget. It must be a value in the range [0.0, 1.0].
  Future animateTo({
    required int index,
    required Duration duration,
    required Curve curve,
    EdgeInsets padding = EdgeInsets.zero,
    BuildContext? sliverContext,
    bool isFixedHeight = false,
    double alignment = 0,
    ObserverLocateIndexOffsetCallback? offset,
    ObserverRenderSliverType? renderSliverType,
    ObserverOnPrepareScrollToIndex? onPrepareScrollToIndex,
  }) {
    return innerAnimateTo(
      index: index,
      duration: duration,
      curve: curve,
      padding: padding,
      sliverContext: sliverContext,
      isFixedHeight: isFixedHeight,
      alignment: alignment,
      offset: offset,
      renderSliverType: renderSliverType,
      onPrepareScrollToIndex: onPrepareScrollToIndex,
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
  Future jumpTo({
    required int index,
    BuildContext? sliverContext,
    bool isFixedHeight = false,
    double alignment = 0,
    EdgeInsets padding = EdgeInsets.zero,
    ObserverLocateIndexOffsetCallback? offset,
    ObserverRenderSliverType? renderSliverType,
    ObserverOnPrepareScrollToIndex? onPrepareScrollToIndex,
  }) {
    return innerJumpTo(
      index: index,
      sliverContext: sliverContext,
      isFixedHeight: isFixedHeight,
      alignment: alignment,
      padding: padding,
      offset: offset,
      renderSliverType: renderSliverType,
      onPrepareScrollToIndex: onPrepareScrollToIndex,
    );
  }
}
