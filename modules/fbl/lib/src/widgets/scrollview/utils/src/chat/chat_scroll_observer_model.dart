import 'package:flutter/material.dart';

import '../../../common/models/observe_displaying_child_model_mixin.dart';

import 'chat_scroll_observer.dart';
import 'chat_scroll_observer_typedefs.dart';

class ChatScrollObserverHandlePositionResultModel {
  /// The type of processing location.
  final ChatScrollObserverHandlePositionType type;

  /// The mode of processing.
  final ChatScrollObserverHandleMode mode;

  /// The number of messages added.
  final int changeCount;

  ChatScrollObserverHandlePositionResultModel({
    required this.type,
    required this.mode,
    required this.changeCount,
  });
}

class ChatScrollObserverCustomAdjustPositionDeltaModel {
  /// The old position.
  final ScrollMetrics oldPosition;

  /// The new position.
  final ScrollMetrics newPosition;

  /// Whether the ScrollView is scrolling.
  final bool isScrolling;

  /// The current velocity of the scroll position.
  final double velocity;

  /// The scroll position should be given for new viewport dimensions.
  final double adjustPosition;

  /// The [ChatScrollObserver] instance.
  final ChatScrollObserver observer;

  /// The observation result of the current item.
  final ObserveDisplayingChildModelMixin currentItemModel;

  ChatScrollObserverCustomAdjustPositionDeltaModel({
    required this.oldPosition,
    required this.newPosition,
    required this.isScrolling,
    required this.velocity,
    required this.adjustPosition,
    required this.observer,
    required this.currentItemModel,
  });
}

class ChatScrollObserverCustomAdjustPositionModel {
  /// The old position.
  final ScrollMetrics oldPosition;

  /// The new position.
  final ScrollMetrics newPosition;

  /// Whether the ScrollView is scrolling.
  final bool isScrolling;

  /// The current velocity of the scroll position.
  final double velocity;

  /// The scroll position should be given for new viewport dimensions.
  final double adjustPosition;

  /// The [ChatScrollObserver] instance.
  final ChatScrollObserver observer;

  ChatScrollObserverCustomAdjustPositionModel({
    required this.oldPosition,
    required this.newPosition,
    required this.isScrolling,
    required this.velocity,
    required this.adjustPosition,
    required this.observer,
  });
}
