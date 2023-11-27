import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../common/observer_widget.dart';
import '../utils/observer_utils.dart';
import 'list_observer_controller.dart';
import 'models/listview_observe_displaying_child_model.dart';
import 'models/listview_observe_model.dart';

class ListViewObserver extends ObserverWidget<ListObserverController,
    ListViewObserveModel, ListViewOnceObserveNotification> {
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

class ListViewObserverState extends ObserverWidgetState<ListObserverController,
    ListViewObserveModel, ScrollViewOnceObserveNotification, ListViewObserver> {
  @override
  ListViewObserveModel? handleObserve(BuildContext ctx) {
    if (widget.customHandleObserve != null) {
      return widget.customHandleObserve?.call(ctx);
    }
    return handleListObserve(
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

  /// Handles observation logic of a sliver similar to [SliverList].
  ListViewObserveModel? handleListObserve({
    required BuildContext context,
    double Function()? fetchLeadingOffset,
    double toNextOverPercent = 1,
  }) {
    var obj = ObserverUtils.findRenderObject(context);
    if (obj is! RenderSliverMultiBoxAdaptor) return null;
    final viewport = ObserverUtils.findViewport(obj);
    if (viewport == null) return null;
    if (kDebugMode) {
      if (viewport.debugNeedsPaint) return null;
    }
    if (!(obj.geometry?.visible ?? true)) {
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
    final rawScrollViewOffset = obj.constraints.scrollOffset + obj.constraints.overlap;
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
    final showingChildrenMaxOffset = rawScrollViewOffset + obj.constraints.remainingPaintExtent - obj.constraints.overlap;
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


/// The Notification for Triggering an ListView observation
class ListViewOnceObserveNotification
    extends ScrollViewOnceObserveNotification {
  ListViewOnceObserveNotification({
    super.isForce,
    super.isDependObserveCallback,
  });
}
