import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../common/models/observe_model.dart';
import '../common/observer_typedef.dart';
import '../common/observer_widget.dart';
import '../listview/list_observer_view.dart';
import '../notification.dart';
import '../observer_core.dart';
import '../utils/src/observer_utils.dart';
import 'models/sliver_observer_observe_result_model.dart';
import 'models/sliver_viewport_observe_displaying_child_model.dart';
import 'models/sliver_viewport_observe_model.dart';
import 'sliver_observer_controller.dart';
import 'sliver_observer_listener.dart';

class SliverViewObserver extends ObserverWidget<SliverObserverController,
    ObserveModel, ScrollViewOnceObserveNotification> {
  /// The callback of getting all slivers those are displayed in viewport.
  final OnObserveViewportCallback? onObserveViewport;

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
    super.tag,
    this.controller,
    @Deprecated(
        'It will be removed in version 2, please use [sliverContexts] instead')
    List<BuildContext> Function()? sliverListContexts,
    List<BuildContext> Function()? sliverContexts,
    super.onObserveAll,
    super.onObserve,
    this.onObserveViewport,
    super.leadingOffset,
    super.dynamicLeadingOffset,
    this.customOverlap,
    super.toNextOverPercent,
    super.scrollNotificationPredicate,
    super.autoTriggerObserveTypes,
    super.triggerOnObserveType,
    super.customHandleObserve,
    this.extendedHandleObserve,
  }) : super(
          sliverController: controller,
          sliverContexts: sliverContexts ?? sliverListContexts,
        );

  @override
  State<SliverViewObserver> createState() => MixViewObserverState();

  /// Returning the closest instance of this class that encloses the given
  /// context.
  ///
  /// If you give a tag, it will give priority find the corresponding instance
  /// of this class with the given tag and return it.
  ///
  /// If there is no [SliverViewObserver] widget, then null is returned.
  ///
  /// Calling this method will create a dependency on the closest
  /// [SliverViewObserver] in the [context], if there is one.
  ///
  /// See also:
  ///
  /// * [SliverViewObserver.of], which is similar to this method, but asserts
  ///   if no [SliverViewObserver] instance is found.
  static MixViewObserverState? maybeOf(
    BuildContext context, {
    String? tag,
  }) {
    final state = ObserverWidget.maybeOf<SliverObserverController,
        ObserveModel, ScrollViewOnceObserveNotification, SliverViewObserver>(
      context,
      tag: tag,
    );
    if (state is! MixViewObserverState) return null;
    return state;
  }

  /// Returning the closest instance of this class that encloses the given
  /// context.
  ///
  /// If you give a tag, it will give priority find the corresponding instance
  /// of this class with the given tag and return it.
  ///
  /// If no instance is found, this method will assert in debug mode, and throw
  /// an exception in release mode.
  ///
  /// Calling this method will create a dependency on the closest
  /// [ObserverWidget] in the [context].
  ///
  /// See also:
  ///
  /// * [ObserverWidget.maybeOf], which is similar to this method, but returns
  ///   null if no [ObserverWidget] instance is found.
  static MixViewObserverState of(
    BuildContext context, {
    String? tag,
  }) {
    final state = ObserverWidget.of<SliverObserverController, ObserveModel,
        ScrollViewOnceObserveNotification, SliverViewObserver>(
      context,
      tag: tag,
    );
    return state as MixViewObserverState;
  }
}

class MixViewObserverState extends ObserverWidgetState<SliverObserverController,
    ObserveModel, ScrollViewOnceObserveNotification, SliverViewObserver> {
  /// The last viewport observation result.
  SliverViewportObserveModel? lastViewportObserveResultModel;

  /// The listener list state for a [SliverViewObserver] returned by
  /// [SliverViewObserver.of].
  ///
  /// It supports a listener list instead of just a single observation
  /// callback (such as onObserveViewport).
  @protected
  @visibleForTesting
  LinkedList<SliverObserverListenerEntry>? innerSliverListeners =
      LinkedList<SliverObserverListenerEntry>();

  bool _debugAssertNotDisposed() {
    assert(() {
      if (innerSliverListeners == null) {
        throw FlutterError(
          'A $runtimeType was used after being disposed.\n'
          'Once you have called dispose() on a $runtimeType, it can no longer be used.',
        );
      }
      return true;
    }());
    return true;
  }

  @override
  void dispose() {
    assert(_debugAssertNotDisposed());
    innerSliverListeners?.clear();
    innerSliverListeners = null;
    super.dispose();
  }

  @override
  SliverObserverHandleContextsResultModel<ObserveModel>? handleContexts({
    bool isForceObserve = false,
    bool isFromObserveNotification = false,
    bool isDependObserveCallback = true,
    bool isIgnoreInnerCanHandleObserve = true,
  }) {
    if (!isIgnoreInnerCanHandleObserve) {
      if (!innerCanHandleObserve) return null;
      updateInnerCanHandleObserve();
    }

    // Viewport
    final observeViewportResult = handleObserveViewport(
      isForceObserve: isForceObserve,
      isDependObserveCallback: isDependObserveCallback,
    );
    _notifySliverListeners(observeViewportResult);

    // Slivers（SliverList, GridView etc.）
    final handleContextsResult = super.handleContexts(
      isForceObserve: isForceObserve,
      isFromObserveNotification: isFromObserveNotification,
      isDependObserveCallback: isDependObserveCallback,
      // It has been processed by the currently rewritten handleContexts method
      isIgnoreInnerCanHandleObserve: true,
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
    final myObj = ObserverUtils.findRenderObject(ctx);
    if (ListViewObserver.isSupportRenderSliverType(myObj)) {
      return ObserverCore.handleListObserve(
        context: ctx,
        fetchLeadingOffset: fetchLeadingOffset,
        customOverlap: widget.customOverlap,
        toNextOverPercent: widget.toNextOverPercent,
      );
    } else if (myObj is RenderSliverGrid) {
      return ObserverCore.handleGridObserve(
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
    final isForbidObserveViewportCallback =
        widget.sliverController?.isForbidObserveViewportCallback ?? false;
    final onObserveViewport =
        isForbidObserveViewportCallback ? null : widget.onObserveViewport;
    if (isDependObserveCallback &&
        onObserveViewport == null &&
        (innerSliverListeners?.isEmpty ?? true)) {
      return null;
    }

    final isHandlingScroll =
        widget.sliverController?.innerIsHandlingScroll ?? false;
    if (isHandlingScroll) return null;

    final ctxs = fetchTargetSliverContexts();
    final objList = ctxs.map((e) => ObserverUtils.findRenderObject(e)).toList();
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

    if (targetChild == null ||
        !ObserverUtils.isValidListIndex(indexOfTargetChild)) {
      return null;
    }
    final targetCtx = ctxs[indexOfTargetChild];
    final firstChild = SliverViewportObserveDisplayingChildModel(
      sliverContext: targetCtx,
      sliver: targetChild,
    );

    List<SliverViewportObserveDisplayingChildModel> displayingChildModelList = [
      firstChild
    ];

    // Find the remaining children that are being displayed.
    targetChild = viewport.childAfter(targetChild);
    while (targetChild != null) {
      // The current targetChild is not displayed, so the later children don't
      // need to be check
      if (!ObserverUtils.isDisplayingSliverInViewport(
        sliver: targetChild,
        viewportPixels: startCalcPixels,
        viewportBottomOffset: viewportBottomOffset,
      )) {
        break;
      }

      indexOfTargetChild = objList.indexOf(targetChild);
      if (ObserverUtils.isValidListIndex(indexOfTargetChild)) {
        // The current targetChild is target.
        final context = ctxs[indexOfTargetChild];
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
    if (isForceObserve ||
        widget.triggerOnObserveType == ObserverTriggerOnObserveType.directly) {
      canReturnResult = true;
    } else if (model != lastViewportObserveResultModel) {
      canReturnResult = true;
    }
    if (canReturnResult &&
        isDependObserveCallback &&
        onObserveViewport != null) {
      onObserveViewport(model);
    }

    // Record it for the next comparison.
    lastViewportObserveResultModel = model;

    return canReturnResult ? model : null;
  }

  @override
  void addListener({
    BuildContext? context,
    OnObserveCallback<ObserveModel>? onObserve,
    OnObserveAllCallback<ObserveModel>? onObserveAll,
    OnObserveViewportCallback? onObserveViewport,
  }) {
    assert(_debugAssertNotDisposed());
    assert(
      onObserve != null || onObserveAll != null || onObserveViewport != null,
      'At least one callback must be provided.',
    );
    super.addListener(
      context: context,
      onObserve: onObserve,
      onObserveAll: onObserveAll,
    );
    // Add the listener for the viewport observation.
    if (onObserveViewport != null) {
      innerSliverListeners?.add(SliverObserverListenerEntry(
        context: context,
        onObserveViewport: onObserveViewport,
      ));
    }
  }

  @override
  void removeListener({
    BuildContext? context,
    OnObserveCallback<ObserveModel>? onObserve,
    OnObserveAllCallback<ObserveModel>? onObserveAll,
    OnObserveViewportCallback? onObserveViewport,
  }) {
    assert(_debugAssertNotDisposed());
    assert(
      onObserve != null || onObserveAll != null || onObserveViewport != null,
      'At least one callback must be provided.',
    );
    super.removeListener(
      context: context,
      onObserve: onObserve,
      onObserveAll: onObserveAll,
    );
    // Remove the listener for the viewport observation.
    final listeners = innerSliverListeners;
    if (listeners == null) return;
    for (final SliverObserverListenerEntry entry in listeners) {
      if (entry.context == context &&
          entry.onObserveViewport == onObserveViewport) {
        entry.unlink();
        return;
      }
    }
  }

  void _notifySliverListeners(
    SliverViewportObserveModel? observeViewportResult,
  ) {
    assert(_debugAssertNotDisposed());
    if (observeViewportResult == null) return;
    final listeners = innerSliverListeners;
    if (listeners == null || listeners.isEmpty) return;

    final List<SliverObserverListenerEntry> localListeners =
        List<SliverObserverListenerEntry>.of(listeners);
    for (final SliverObserverListenerEntry entry in localListeners) {
      try {
        if (entry.list != null) {
          entry.onObserveViewport?.call(observeViewportResult);
        }
      } catch (exception, stack) {
        FlutterError.reportError(FlutterErrorDetails(
          exception: exception,
          stack: stack,
          library: 'scrollview_observer',
          context:
              ErrorDescription('while dispatching result for $runtimeType'),
          informationCollector: () => <DiagnosticsNode>[
            DiagnosticsProperty<ObserverWidgetState>(
              'The $runtimeType sending result was',
              this,
              style: DiagnosticsTreeStyle.errorProperty,
            ),
          ],
        ));
      }
    }
  }
}
