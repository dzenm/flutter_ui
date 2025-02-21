import '../common/models/observe_model.dart';
import '../common/observer_notification_result.dart';
import 'models/sliver_observer_observe_result_model.dart';
import 'models/sliver_viewport_observe_model.dart';

class ScrollViewOnceObserveNotificationResult
    extends CommonOnceObserveNotificationResult<ObserveModel,
        SliverObserverHandleContextsResultModel<ObserveModel>> {
  ScrollViewOnceObserveNotificationResult({
    required super.type,
    required SliverObserverHandleContextsResultModel<ObserveModel>
        observeResult,
  }) : super(
          observeResult: observeResult.changeResultModel,
          observeAllResult: observeResult.changeResultMap,
        ) {
    observeViewportResultModel = observeResult.observeViewportResultModel;
  }

  /// Getting all slivers those are displayed in viewport.
  ///
  /// Corresponding to [onObserveViewport] in [SliverViewObserver].
  SliverViewportObserveModel? observeViewportResultModel;
}
