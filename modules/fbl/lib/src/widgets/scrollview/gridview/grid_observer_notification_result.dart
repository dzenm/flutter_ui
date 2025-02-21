import '../common/models/observer_handle_contexts_result_model.dart';
import '../common/observer_notification_result.dart';
import 'models/gridview_observe_model.dart';

class GridViewOnceObserveNotificationResult
    extends CommonOnceObserveNotificationResult<GridViewObserveModel,
        ObserverHandleContextsResultModel<GridViewObserveModel>> {
  GridViewOnceObserveNotificationResult({
    required super.type,
    required ObserverHandleContextsResultModel<GridViewObserveModel>
        observeResult,
  }) : super(
          observeResult: observeResult.changeResultModel,
          observeAllResult: observeResult.changeResultMap,
        );
}
