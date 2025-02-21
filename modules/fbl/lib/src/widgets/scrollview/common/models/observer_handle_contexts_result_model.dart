import 'package:flutter/material.dart';

import 'observe_model.dart';

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
