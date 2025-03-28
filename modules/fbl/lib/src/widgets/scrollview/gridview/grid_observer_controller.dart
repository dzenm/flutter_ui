import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../common/models/observer_handle_contexts_result_model.dart';
import '../common/observer_controller.dart';
import '../common/observer_typedef.dart';
import '../common/typedefs.dart';
import '../notification.dart';
import 'grid_observer_notification_result.dart';
import 'models/gridview_observe_displaying_child_model.dart';
import 'models/gridview_observe_model.dart';

class GridObserverController extends ObserverController
    with
        ObserverControllerForInfo,
        ObserverControllerForScroll,
        ObserverControllerForNotification<
            GridViewObserveModel,
            ObserverHandleContextsResultModel<GridViewObserveModel>,
            GridViewOnceObserveNotificationResult> {
  GridObserverController({
    super.controller,
  });

  /// Dispatch a [GridViewOnceObserveNotification]
  Future<GridViewOnceObserveNotificationResult> dispatchOnceObserve({
    BuildContext? sliverContext,
    bool isForce = false,
    bool isDependObserveCallback = true,
  }) {
    return innerDispatchOnceObserve(
      sliverContext: sliverContext,
      notification: GridViewOnceObserveNotification(
        isForce: isForce,
        isDependObserveCallback: isDependObserveCallback,
      ),
    );
  }

  /// Observe the child which is specified index in sliver.
  GridViewObserveDisplayingChildModel? observeItem({
    required int index,
    BuildContext? sliverContext,
  }) {
    final model = findChildInfo(index: index, sliverContext: sliverContext);
    if (model == null) return null;
    return GridViewObserveDisplayingChildModel(
      sliverGrid: model.sliver as RenderSliverGrid,
      viewport: model.viewport,
      index: model.index,
      renderObject: model.renderObject,
    );
  }

  /// Observe the first child in sliver.
  ///
  /// Note that the first child here is not the first child being displayed in
  /// sliver, and it may not be displayed.
  GridViewObserveDisplayingChildModel? observeFirstItem({
    BuildContext? sliverContext,
  }) {
    final model = findCurrentFirstChildInfo(sliverContext: sliverContext);
    if (model == null) return null;
    return GridViewObserveDisplayingChildModel(
      sliverGrid: model.sliver as RenderSliverGrid,
      viewport: model.viewport,
      index: model.index,
      renderObject: model.renderObject,
    );
  }

  /// Create a observation notification result.
  @override
  GridViewOnceObserveNotificationResult
      innerCreateOnceObserveNotificationResult({
    required ObserverWidgetObserveResultType resultType,
    required ObserverHandleContextsResultModel<GridViewObserveModel>?
        resultModel,
  }) {
    return GridViewOnceObserveNotificationResult(
      type: resultType,
      observeResult: resultModel ?? ObserverHandleContextsResultModel(),
    );
  }

  /// Jump to the specified index position with animation.
  ///
  /// If the height of the child widget and the height of the separator are
  /// fixed, please pass the [isFixedHeight] parameter.
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
      renderSliverType: ObserverRenderSliverType.grid,
    );
  }

  /// Jump to the specified index position without animation.
  ///
  /// If the height of the child widget and the height of the separator are
  /// fixed, please pass the [isFixedHeight] parameter.
  ///
  /// If you do not pass the [isFixedHeight] parameter, the package will
  /// automatically gradually scroll around the target location before
  /// locating, which will produce an animation.
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
  }) {
    return innerJumpTo(
      index: index,
      sliverContext: sliverContext,
      isFixedHeight: isFixedHeight,
      alignment: alignment,
      padding: padding,
      offset: offset,
      renderSliverType: ObserverRenderSliverType.grid,
    );
  }
}
