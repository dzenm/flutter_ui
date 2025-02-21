import 'dart:collection';

import 'package:flutter/material.dart';

import 'models/observe_model.dart';
import 'observer_typedef.dart';

final class ObserverListenerEntry<M extends ObserveModel>
    extends LinkedListEntry<ObserverListenerEntry<M>> {
  ObserverListenerEntry({
    required this.context,
    required this.onObserve,
    required this.onObserveAll,
  });

  /// The context of the listener.
  final BuildContext? context;

  /// The callback of getting observed result.
  final OnObserveCallback<M>? onObserve;

  /// The callback of getting observed result map.
  final OnObserveAllCallback<M>? onObserveAll;
}
