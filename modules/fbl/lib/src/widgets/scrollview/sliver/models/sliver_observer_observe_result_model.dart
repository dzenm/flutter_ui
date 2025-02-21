import 'package:flutter/material.dart';

import '../../common/models/observe_model.dart';
import '../../common/models/observer_handle_contexts_result_model.dart';
import '../../scrollview_observer.dart';

class SliverObserverHandleContextsResultModel<M extends ObserveModel>
    extends ObserverHandleContextsResultModel {
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
