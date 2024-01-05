import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../observe_notification.dart';
import '../observer/observer_view.dart';
import '../observer_utils.dart';
import 'list_observer_controller.dart';
import 'models/listview_observe_model.dart';

class ListViewObserver extends ObserverView<ListObserverController, ListViewObserveModel, ListViewOnceObserveNotification> {
  /// The callback of getting all sliverList's buildContext.
  final List<BuildContext> Function()? sliverListContexts;

  final ListObserverController? controller;

  const ListViewObserver({
    super.key,
    required super.child,
    this.controller,
    this.sliverListContexts,
    super.onObserveAll,
    super.onObserve,
    super.leadingOffset,
    super.dynamicLeadingOffset,
    super.toNextOverPercent,
    super.autoTriggerObserveTypes,
    super.triggerOnObserveType,
    super.customHandleObserve,
    super.customTargetRenderSliverType,
  }) : super(
          sliverController: controller,
          sliverContexts: sliverListContexts,
        );

  @override
  State<ListViewObserver> createState() => ListViewObserverState();
}

class ListViewObserverState extends ObserverViewState<ListObserverController, ListViewObserveModel, ListViewOnceObserveNotification, ListViewObserver> {
  @override
  ListViewObserveModel? handleObserve(BuildContext ctx) {
    if (widget.customHandleObserve != null) {
      return widget.customHandleObserve?.call(ctx);
    }
    return ObserverUtils.handleListObserve(
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
    return obj is RenderSliverList || obj is RenderSliverFixedExtentList;
  }
}
