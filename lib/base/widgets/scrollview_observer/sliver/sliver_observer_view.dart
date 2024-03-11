import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../observe_notification.dart';
import '../observer/models/observe_model.dart';
import '../observer/observer_view.dart';
import '../observer_utils.dart';
import 'models/sliver_viewport_observe_displaying_child_model.dart';
import 'models/sliver_viewport_observe_model.dart';
import 'sliver_observer_controller.dart';
import 'sliver_observer_notification_result.dart';

class SliverViewObserver extends ObserverView<SliverObserverController, ObserveModel, ScrollViewOnceObserveNotification> {
  /// The callback of getting all slivers those are displayed in viewport.
  final Function(SliverViewportObserveModel)? onObserveViewport;

  /// It's used to handle the observation logic for other types of Sliver
  /// besides [RenderSliverList], [RenderSliverFixedExtentList] and
  /// [RenderSliverGrid].
  final ObserveModel? Function(BuildContext context)? extendedHandleObserve;

  /// The callback that specifies a custom overlap corresponds to sliverContext.
  ///
  /// If null is returned then use the overlap of sliverContext.
  final double? Function(BuildContext sliverContext)? customOverlap;

  final SliverObserverController? controller;

  const SliverViewObserver({
    super.key,
    required super.child,
    this.controller,
    super.sliverContexts,
    super.onObserveAll,
    super.onObserve,
    this.onObserveViewport,
    super.leadingOffset,
    super.dynamicLeadingOffset,
    this.customOverlap,
    super.toNextOverPercent,
    super.autoTriggerObserveTypes,
    super.triggerOnObserveType,
    super.customHandleObserve,
    this.extendedHandleObserve,
  }) : super(
          sliverController: controller,
        );

  @override
  State<SliverViewObserver> createState() => MixViewObserverState();
}

class MixViewObserverState extends ObserverViewState<SliverObserverController, ObserveModel, ScrollViewOnceObserveNotification, SliverViewObserver> {
  /// The last viewport observation result.
  SliverViewportObserveModel? lastViewportObserveResultModel;

  @override
  SliverObserverHandleContextsResultModel<ObserveModel>? handleContexts({
    bool isForceObserve = false,
    bool isFromObserveNotification = false,
    bool isDependObserveCallback = true,
  }) {
    // Viewport
    final observeViewportResult = handleObserveViewport(
      isForceObserve: isForceObserve,
      isDependObserveCallback: isDependObserveCallback,
    );

    // Slivers（SliverList, GridView etc.）
    final handleContextsResult = super.handleContexts(
      isForceObserve: isForceObserve,
      isFromObserveNotification: isFromObserveNotification,
      isDependObserveCallback: isDependObserveCallback,
    );

    if (observeViewportResult == null && handleContextsResult == null) {
      return null;
    }
    return SliverObserverHandleContextsResultModel(
      changeResultModel: handleContextsResult?.changeResultModel,
      changeResultMap: handleContextsResult?.changeResultMap ?? {},
      observeViewportResultModel: observeViewportResult,
    );
  }

  @override
  ObserveModel? handleObserve(BuildContext ctx) {
    if (widget.customHandleObserve != null) {
      return widget.customHandleObserve?.call(ctx);
    }
    final renderObject = ObserverUtils.findRenderObject(ctx);
    if (renderObject is RenderSliverList || renderObject is RenderSliverFixedExtentList) {
      return ObserverUtils.handleListObserve(
        context: ctx,
        fetchLeadingOffset: fetchLeadingOffset,
        customOverlap: widget.customOverlap,
        toNextOverPercent: widget.toNextOverPercent,
      );
    }
    return widget.extendedHandleObserve?.call(ctx);
  }

  /// To observe the viewport.
  SliverViewportObserveModel? handleObserveViewport({
    bool isForceObserve = false,
    bool isDependObserveCallback = true,
  }) {
    final isForbidObserveViewportCallback = widget.sliverController?.isForbidObserveViewportCallback ?? false;
    final onObserveViewport = isForbidObserveViewportCallback ? null : widget.onObserveViewport;
    if (isDependObserveCallback && onObserveViewport == null) return null;

    final isHandlingScroll = widget.sliverController?.innerIsHandlingScroll ?? false;
    if (isHandlingScroll) return null;

    final myContexts = fetchTargetSliverContexts();
    final objList = myContexts.map((e) => ObserverUtils.findRenderObject(e)).toList();
    if (objList.isEmpty) return null;
    final firstObj = objList.first;
    if (firstObj == null) return null;
    final viewport = ObserverUtils.findViewport(firstObj);
    if (viewport == null) return null;
    final viewportOffset = viewport.offset;
    if (viewportOffset is! ScrollPosition) return null;

    var targetChild = viewport.firstChild;
    if (targetChild == null) return null;
    var offset = widget.leadingOffset;
    if (widget.dynamicLeadingOffset != null) {
      offset = widget.dynamicLeadingOffset!();
    }
    final pixels = viewportOffset.pixels;
    final startCalcPixels = pixels + offset;

    int indexOfTargetChild = objList.indexOf(targetChild);

    // Find out the first sliver which is displayed in viewport.
    final dimension = viewportOffset.viewportDimension;
    final viewportBottomOffset = pixels + dimension;

    while (!ObserverUtils.isValidListIndex(indexOfTargetChild) ||
        !ObserverUtils.isDisplayingSliverInViewport(
          sliver: targetChild,
          viewportPixels: startCalcPixels,
          viewportBottomOffset: viewportBottomOffset,
        )) {
      if (targetChild == null) break;
      final nextChild = viewport.childAfter(targetChild);
      if (nextChild == null) break;
      targetChild = nextChild;
      indexOfTargetChild = objList.indexOf(targetChild);
    }

    if (targetChild == null || !ObserverUtils.isValidListIndex(indexOfTargetChild)) return null;
    final targetCtx = myContexts[indexOfTargetChild];
    final firstChild = SliverViewportObserveDisplayingChildModel(
      sliverContext: targetCtx,
      sliver: targetChild,
    );

    List<SliverViewportObserveDisplayingChildModel> displayingChildModelList = [firstChild];

    // Find the remaining children that are being displayed.
    targetChild = viewport.childAfter(targetChild);
    while (targetChild != null) {
      // The current targetChild is not displayed, so the later children don't
      // need to be check
      if (!ObserverUtils.isDisplayingSliverInViewport(
        sliver: targetChild,
        viewportPixels: startCalcPixels,
        viewportBottomOffset: viewportBottomOffset,
      )) break;

      indexOfTargetChild = objList.indexOf(targetChild);
      if (ObserverUtils.isValidListIndex(indexOfTargetChild)) {
        // The current targetChild is target.
        final context = myContexts[indexOfTargetChild];
        displayingChildModelList.add(SliverViewportObserveDisplayingChildModel(
          sliverContext: context,
          sliver: targetChild,
        ));
      }
      // continue to check next child.
      targetChild = viewport.childAfter(targetChild);
    }
    var model = SliverViewportObserveModel(
      viewport: viewport,
      firstChild: firstChild,
      displayingChildModelList: displayingChildModelList,
    );
    bool canReturnResult = false;
    if (isForceObserve || widget.triggerOnObserveType == ObserverTriggerOnObserveType.directly) {
      canReturnResult = true;
    } else if (model != lastViewportObserveResultModel) {
      canReturnResult = true;
    }
    if (canReturnResult && isDependObserveCallback && onObserveViewport != null) {
      onObserveViewport(model);
    }

    // Record it for the next comparison.
    lastViewportObserveResultModel = model;

    return canReturnResult ? model : null;
  }
}

class SliverObserveContextToBoxAdapter extends SliverToBoxAdapter {
  final void Function(BuildContext) onObserve;

  const SliverObserveContextToBoxAdapter({
    super.key,
    required super.child,
    required this.onObserve,
  });

  @override
  RenderSliverToBoxAdapter createRenderObject(BuildContext context) {
    onObserve.call(context);
    return super.createRenderObject(context);
  }
}
