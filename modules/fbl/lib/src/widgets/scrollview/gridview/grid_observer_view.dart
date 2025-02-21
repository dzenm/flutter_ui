import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../common/observer_widget.dart';
import '../notification.dart';
import '../observer_core.dart';
import 'grid_observer_controller.dart';
import 'models/gridview_observe_model.dart';

class GridViewObserver extends ObserverWidget<GridObserverController,
    GridViewObserveModel, GridViewOnceObserveNotification> {
  /// The callback of getting all sliverGrid's buildContext.
  final List<BuildContext> Function()? sliverGridContexts;

  final GridObserverController? controller;

  const GridViewObserver({
    super.key,
    required super.child,
    super.tag,
    this.sliverGridContexts,
    this.controller,
    super.onObserveAll,
    super.onObserve,
    super.leadingOffset,
    super.dynamicLeadingOffset,
    super.toNextOverPercent,
    super.scrollNotificationPredicate,
    super.autoTriggerObserveTypes,
    super.triggerOnObserveType,
    super.customHandleObserve,
    super.customTargetRenderSliverType,
  }) : super(
          sliverContexts: sliverGridContexts,
          sliverController: controller,
        );

  @override
  State<GridViewObserver> createState() => GridViewObserverState();

  static GridViewObserverState? maybeOf(
    BuildContext context, {
    String? tag,
  }) {
    final state = ObserverWidget.maybeOf<
        GridObserverController,
        GridViewObserveModel,
        GridViewOnceObserveNotification,
        GridViewObserver>(
      context,
      tag: tag,
    );
    if (state is! GridViewObserverState) return null;
    return state;
  }

  static GridViewObserverState of(
    BuildContext context, {
    String? tag,
  }) {
    final state = ObserverWidget.of<
        GridObserverController,
        GridViewObserveModel,
        GridViewOnceObserveNotification,
        GridViewObserver>(
      context,
      tag: tag,
    );
    return state as GridViewObserverState;
  }
}

class GridViewObserverState extends ObserverWidgetState<GridObserverController,
    GridViewObserveModel, GridViewOnceObserveNotification, GridViewObserver> {
  @override
  GridViewObserveModel? handleObserve(BuildContext ctx) {
    if (widget.customHandleObserve != null) {
      return widget.customHandleObserve?.call(ctx);
    }
    return ObserverCore.handleGridObserve(
      context: ctx,
      fetchLeadingOffset: fetchLeadingOffset,
      toNextOverPercent: widget.toNextOverPercent,
    );
  }

  /// Determine whether it is the type of the target sliver.
  @override
  bool isTargetSliverContextType(RenderObject? obj) {
    if (widget.customTargetRenderSliverType != null) {
      return widget.customTargetRenderSliverType!.call(obj);
    }
    return obj is RenderSliverGrid;
  }
}
