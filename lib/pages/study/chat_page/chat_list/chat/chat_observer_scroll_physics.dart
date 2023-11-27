import 'package:flutter/material.dart';
import '../common/observer_controller.dart';
import 'chat_scroll_observer.dart';
import 'chat_scroll_observer_model.dart';

class ChatObserverClampingScrollPhysics extends ClampingScrollPhysics
    with ChatObserverScrollPhysicsMixin {
  ChatObserverClampingScrollPhysics({
    super.parent,
    required ChatScrollObserver observer,
  }) {
    this.observer = observer;
  }

  @override
  ChatObserverClampingScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return ChatObserverClampingScrollPhysics(
      parent: buildParent(ancestor),
      observer: observer,
    );
  }
}

class ChatObserverBouncingScrollPhysics extends BouncingScrollPhysics
    with ChatObserverScrollPhysicsMixin {
  ChatObserverBouncingScrollPhysics({
    super.parent,
    required ChatScrollObserver observer,
  }) {
    this.observer = observer;
  }

  @override
  ChatObserverBouncingScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return ChatObserverBouncingScrollPhysics(
      parent: buildParent(ancestor),
      observer: observer,
    );
  }
}

mixin ChatObserverScrollPhysicsMixin on ScrollPhysics {
  late final ChatScrollObserver observer;

  @override
  double adjustPositionForNewDimensions({
    required ScrollMetrics oldPosition,
    required ScrollMetrics newPosition,
    required bool isScrolling,
    required double velocity,
  }) {
    final isNeedFixedPosition = observer.innerIsNeedFixedPosition;
    observer.innerIsNeedFixedPosition = false;

    var adjustPosition = super.adjustPositionForNewDimensions(
      oldPosition: oldPosition,
      newPosition: newPosition,
      isScrolling: isScrolling,
      velocity: velocity,
    );

    if (newPosition.extentBefore <= observer.fixedPositionOffset ||
        !isNeedFixedPosition ||
        observer.isRemove) {
      _handlePositionCallback(ChatScrollObserverHandlePositionResultModel(
        type: ChatScrollObserverHandlePositionType.none,
        mode: observer.innerMode,
        changeCount: observer.changeCount,
      ));
      return adjustPosition;
    }
    final model = observer.observeRefItem();
    if (model == null) {
      _handlePositionCallback(ChatScrollObserverHandlePositionResultModel(
        type: ChatScrollObserverHandlePositionType.none,
        mode: observer.innerMode,
        changeCount: observer.changeCount,
      ));
      return adjustPosition;
    }

    _handlePositionCallback(ChatScrollObserverHandlePositionResultModel(
      type: ChatScrollObserverHandlePositionType.keepPosition,
      mode: observer.innerMode,
      changeCount: observer.changeCount,
    ));
    final delta = model.layoutOffset - observer.innerRefItemLayoutOffset;
    return adjustPosition + delta;
  }

  @override
  bool shouldAcceptUserOffset(ScrollMetrics position) => true;

  /// Calling observer's [onHandlePositionResultCallback].
  _handlePositionCallback(ChatScrollObserverHandlePositionResultModel result) {
    ambiguate(WidgetsBinding.instance)?.addPostFrameCallback((timeStamp) {
      observer.onHandlePositionResultCallback?.call(result);
    });
  }
}
