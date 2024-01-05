import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../observe_notification.dart';
import 'models/observe_model.dart';
import 'observer_controller.dart';
import 'observer_notification_result.dart';

class ObserverView<C extends ObserverController, M extends ObserveModel, N extends ScrollViewOnceObserveNotification> extends StatefulWidget {
  final Widget child;

  /// An object that can be used to dispatch a [ListViewOnceObserveNotification]
  /// or [GridViewOnceObserveNotification].
  final C? sliverController;

  /// The callback of getting all sliver's buildContext.
  final List<BuildContext> Function()? sliverContexts;

  /// The callback of getting observed result map.
  final Function(Map<BuildContext, M>)? onObserveAll;

  /// The callback of getting observed result for first sliver.
  final Function(M)? onObserve;

  /// Calculate offset.
  final double leadingOffset;

  /// Calculate offset dynamically
  /// If this callback is implemented, the [leadingOffset] property will be
  /// invalid.
  final double Function()? dynamicLeadingOffset;

  /// After the internal logic figure out the first child widget, if the
  /// proportion of the size of the child widget blocked to its own size exceeds
  /// the value [toNextOverPercent], the next child widget will be the first
  /// child widget.
  final double toNextOverPercent;

  /// Used to set types those can trigger observe automatically.
  ///
  /// Defaults to [.scrollStart, .scrollUpdate, .scrollEnd]
  final List<ObserverAutoTriggerObserveType>? autoTriggerObserveTypes;

  /// Used to set the prerequisite for triggering the [onObserve] callback.
  ///
  /// Defaults to [ObserverTriggerOnObserveType.displayingItemsChange].
  final ObserverTriggerOnObserveType triggerOnObserveType;

  /// Used to find the target RenderSliver.
  ///
  /// The default is to find [RenderSliverList], [RenderSliverFixedExtentList]
  /// and [RenderSliverGrid].
  final bool Function(RenderObject?)? customTargetRenderSliverType;

  /// It allows you to customize observation logic when original logic doesn't
  /// fit your needs.
  final M? Function(BuildContext)? customHandleObserve;

  const ObserverView({
    Key? key,
    required this.child,
    this.sliverController,
    this.sliverContexts,
    this.onObserveAll,
    this.onObserve,
    this.leadingOffset = 0,
    this.dynamicLeadingOffset,
    this.toNextOverPercent = 1,
    this.autoTriggerObserveTypes,
    this.triggerOnObserveType = ObserverTriggerOnObserveType.displayingItemsChange,
    this.customHandleObserve,
    this.customTargetRenderSliverType,
  })  : assert(toNextOverPercent > 0 && toNextOverPercent <= 1),
        super(key: key);

  @override
  State<ObserverView> createState() => ObserverViewState<C, M, N, ObserverView<C, M, N>>();
}

class ObserverViewState<C extends ObserverController, M extends ObserveModel, N extends ScrollViewOnceObserveNotification, T extends ObserverView<C, M, N>> extends State<T> {
  /// Target sliver [BuildContext]
  List<BuildContext> targetSliverContexts = [];

  /// The last observation result
  Map<BuildContext, M> lastResultMap = {};

  /// Default values for the widget's autoTriggerObserveTypes property.
  List<ObserverAutoTriggerObserveType> get innerAutoTriggerObserveTypes =>
      widget.autoTriggerObserveTypes ?? [ObserverAutoTriggerObserveType.scrollStart, ObserverAutoTriggerObserveType.scrollUpdate, ObserverAutoTriggerObserveType.scrollEnd];

  /// Mapping [ObserverAutoTriggerObserveType] to [ScrollNotification].
  List<Type> get innerAutoTriggerObserveScrollNotifications => innerAutoTriggerObserveTypes.map((type) {
    switch (type) {
      case ObserverAutoTriggerObserveType.scrollStart:
        return ScrollStartNotification;
      case ObserverAutoTriggerObserveType.scrollUpdate:
        return ScrollUpdateNotification;
      case ObserverAutoTriggerObserveType.scrollEnd:
        return ScrollEndNotification;
    }
  }).toList();

  @override
  void initState() {
    super.initState();
    _setupSliverController(isInitState: true);
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<N>(
      onNotification: (notification) {
        final result = handleContexts(
          isForceObserve: notification.isForce,
          isFromObserveNotification: true,
          isDependObserveCallback: notification.isDependObserveCallback,
        );
        final sliverController = widget.sliverController;
        if (sliverController is ObserverControllerForNotification) {
          sliverController.innerHandleDispatchOnceObserveComplete(
            resultModel: result,
          );
        }
        return true;
      },
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (innerAutoTriggerObserveScrollNotifications.contains(notification.runtimeType)) {
            if (kIsWeb || Platform.isWindows || Platform.isMacOS) {
              // Getting bad observation result because scrolling in Flutter Web
              // with mouse wheel is not smooth.
              // https://github.com/flutter/flutter/issues/78708
              // https://github.com/flutter/flutter/issues/78634
              //
              // issue
              // https://github.com/LinXunFeng/flutter_scrollview_observer/issues/31
              WidgetsBinding.instance.addPostFrameCallback((_) => handleContexts());
            } else {
              handleContexts();
            }
          }
          return false;
        },
        child: widget.child,
      ),
    );
  }

  /// Setup sliver controller
  _setupSliverController({bool isInitState = false}) {
    final sliverController = widget.sliverController;
    if (sliverController == null) return;
    sliverController.innerReset();
    sliverController.innerNeedOnceObserveCallBack = () {
      handleContexts();
    };
    sliverController.innerReattachCallBack = () {
      targetSliverContexts.clear();
      _setupSliverController();
    };
    ambiguate(WidgetsBinding.instance)?.addPostFrameCallback((timeStamp) {
      targetSliverContexts = fetchTargetSliverContexts();
      sliverController.sliverContexts = targetSliverContexts;
      if (isInitState && sliverController is ObserverControllerForScroll) {
        sliverController.innerInitialIndexPosition();
      }
    });
  }

  /// Fetch target sliver [BuildContext]s
  List<BuildContext> fetchTargetSliverContexts() {
    List<BuildContext> sliverContexts = targetSliverContexts;
    if (sliverContexts.isEmpty) {
      final sliverListContexts = widget.sliverContexts;
      if (sliverListContexts != null) {
        sliverContexts = sliverListContexts();
      } else {
        List<BuildContext> contexts = [];
        void visitor(Element element) {
          if (isTargetSliverContextType(element.renderObject)) {
            /// Find the target sliver context
            contexts.add(element);
            return;
          }
          element.visitChildren(visitor);
        }

        try {
          // https://github.com/LinXunFeng/flutter_scrollview_observer/issues/35
          context.visitChildElements(visitor);
        } catch (e) {
          debugPrint(
            'This widget has been unmounted, so the State no longer has a context (and should be considered defunct). \n'
                'Consider canceling any active work during "dispose" or using the "mounted" getter to determine if the State is still active.',
          );
        }

        sliverContexts = contexts;
      }
    }
    return sliverContexts;
  }

  /// Fetch offset from [leadingOffset] or [dynamicLeadingOffset].
  double fetchLeadingOffset() {
    var offset = widget.leadingOffset;
    if (widget.dynamicLeadingOffset != null) {
      offset = widget.dynamicLeadingOffset!();
    }
    return offset;
  }

  /// Determine whether it is the type of the target sliver.
  bool isTargetSliverContextType(RenderObject? obj) {
    if (widget.customTargetRenderSliverType != null) {
      return widget.customTargetRenderSliverType!.call(obj);
    }
    return obj is RenderSliverList;
  }

  /// Handle all buildContext
  ObserverHandleContextsResultModel<M>? handleContexts({
    bool isForceObserve = false,
    bool isFromObserveNotification = false,
    bool isDependObserveCallback = true,
  }) {
    final isForbidObserveCallback =
        widget.sliverController?.isForbidObserveCallback ?? false;
    final onObserve = isForbidObserveCallback ? null : widget.onObserve;
    final onObserveAll = isForbidObserveCallback ? null : widget.onObserveAll;
    if (isDependObserveCallback) {
      if (onObserve == null && onObserveAll == null) return null;
    }

    final isHandlingScroll = widget.sliverController?.innerIsHandlingScroll ?? false;
    if (isHandlingScroll) return null;

    List<BuildContext> contexts = fetchTargetSliverContexts();

    Map<BuildContext, M> resultMap = {};
    Map<BuildContext, M> changeResultMap = {};
    M? changeResultModel;
    for (var i = 0; i < contexts.length; i++) {
      final ctx = contexts[i];
      final targetObserveModel = handleObserve(ctx);
      if (targetObserveModel == null) continue;
      resultMap[ctx] = targetObserveModel;

      if (isForceObserve || widget.triggerOnObserveType == ObserverTriggerOnObserveType.directly) {
        changeResultMap[ctx] = targetObserveModel;
      } else {
        final lastResultModel = lastResultMap[ctx];
        if (lastResultModel == null) {
          changeResultMap[ctx] = targetObserveModel;
        } else if (lastResultModel != targetObserveModel) {
          changeResultMap[ctx] = targetObserveModel;
        }
      }

      // Getting observed result for first listView.
      if (i == 0 && changeResultMap[ctx] != null) {
        changeResultModel = changeResultMap[ctx];
      }
    }

    lastResultMap = resultMap;

    if (isDependObserveCallback && onObserve != null && changeResultModel != null) {
      onObserve(changeResultModel);
    }

    if (isDependObserveCallback && onObserveAll != null && changeResultMap.isNotEmpty) {
      onObserveAll(changeResultMap);
    }

    return ObserverHandleContextsResultModel(
      changeResultModel: changeResultModel,
      changeResultMap: changeResultMap,
    );
  }

  M? handleObserve(BuildContext ctx) {
    if (widget.customHandleObserve != null) {
      return widget.customHandleObserve?.call(ctx);
    }
    return null;
  }
}

/// Define type that auto trigger observe.
enum ObserverAutoTriggerObserveType {
  scrollStart,
  scrollUpdate,
  scrollEnd,
}

/// Define type that trigger [onObserve] callback.
enum ObserverTriggerOnObserveType {
  directly,
  displayingItemsChange,
}
