import '../common/models/observer_handle_contexts_result_model.dart';
import '../common/observer_notification_result.dart';
import 'models/listview_observe_model.dart';

class ListViewOnceObserveNotificationResult
    extends CommonOnceObserveNotificationResult<ListViewObserveModel,
        ObserverHandleContextsResultModel<ListViewObserveModel>> {
  ListViewOnceObserveNotificationResult({
    required super.type,
    required ObserverHandleContextsResultModel<ListViewObserveModel>
        observeResult,
  }) : super(
          observeResult: observeResult.changeResultModel,
          observeAllResult: observeResult.changeResultMap,
        );
}
