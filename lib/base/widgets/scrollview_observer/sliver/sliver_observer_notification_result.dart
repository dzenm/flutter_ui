import 'package:flutter/material.dart';

import '../observer/models/observe_model.dart';
import '../observer/observer_notification_result.dart';
import 'models/sliver_viewport_observe_model.dart';

class SliverObserverHandleContextsResultModel<M extends ObserveModel> extends ObserverHandleContextsResultModel {
  /// Getting all slivers those are displayed in viewport.
  ///
  /// Corresponding to [onObserveViewport] in [SliverViewObserver].
  final SliverViewportObserveModel? observeViewportResultModel;

  SliverObserverHandleContextsResultModel({
    M? changeResultModel,
    Map<BuildContext, M> changeResultMap = const {},
    this.observeViewportResultModel,
  }) : super(
          changeResultModel: changeResultModel,
          changeResultMap: changeResultMap,
        );
}

class ScrollViewOnceObserveNotificationResult extends CommonOnceObserveNotificationResult<ObserveModel, SliverObserverHandleContextsResultModel<ObserveModel>> {
  ScrollViewOnceObserveNotificationResult({
    required super.type,
    required SliverObserverHandleContextsResultModel<ObserveModel> observeResult,
  }) : super(
          observeResult: observeResult.changeResultModel,
          observeAllResult: observeResult.changeResultMap,
        );
}
