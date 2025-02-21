import 'package:flutter/material.dart';

import '../notification.dart';
import 'models/observe_model.dart';
import 'observer_controller.dart';
import 'observer_widget.dart';

class ObserverWidgetScope<
    C extends ObserverController,
    M extends ObserveModel,
    N extends ScrollViewOnceObserveNotification,
    T extends ObserverWidget<C, M, N>> extends InheritedWidget {
  const ObserverWidgetScope({
    super.key,
    required super.child,
    required this.observerWidgetState,
    required this.onCreateElement,
  });

  /// The [ObserverWidgetState] instance.
  final ObserverWidgetState<C, M, N, T> observerWidgetState;

  /// The callback of [createElement].
  final Function(BuildContext) onCreateElement;

  @override
  InheritedElement createElement() {
    final element = super.createElement();
    onCreateElement.call(element);
    return element;
  }

  @override
  bool updateShouldNotify(covariant ObserverWidgetScope oldWidget) {
    return observerWidgetState != oldWidget.observerWidgetState;
  }
}
