import 'package:flutter/material.dart';

import 'models/observe_model.dart';

class ObserverHandleContextsResultModel<M extends ObserveModel> {
  /// Observation result for first sliver.
  /// Corresponding to [onObserve] in [ObserverWidget].
  final M? changeResultModel;

  /// Observation result map.
  /// Corresponding to [onObserveAll] in [ObserverWidget].
  final Map<BuildContext, M> changeResultMap;

  ObserverHandleContextsResultModel({
    this.changeResultModel,
    this.changeResultMap = const {},
  });
}

class CommonOnceObserveNotificationResult<M extends ObserveModel, R extends ObserverHandleContextsResultModel<M>> {
  bool get isSuccess => ObserverWidgetObserveResultType.success == type;

  /// Observation result type.
  final ObserverWidgetObserveResultType type;

  /// Observation result for first sliver.
  /// Corresponding to [onObserve] in [ObserverWidget].
  final M? observeResult;

  /// Observation result map.
  /// Corresponding to [onObserveAll] in [ObserverWidget].
  final Map<BuildContext, M> observeAllResult;

  CommonOnceObserveNotificationResult({
    required this.type,
    required this.observeResult,
    required this.observeAllResult,
  });
}

/// Observation result types in ObserverView.
enum ObserverWidgetObserveResultType {
  success,
  interrupted,
}
