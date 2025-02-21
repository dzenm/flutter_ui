import 'dart:collection';

import 'package:flutter/material.dart';

import '../common/observer_typedef.dart';

final class SliverObserverListenerEntry
    extends LinkedListEntry<SliverObserverListenerEntry> {
  SliverObserverListenerEntry({
    required this.context,
    required this.onObserveViewport,
  });

  /// The context of the listener.
  final BuildContext? context;

  /// The callback of getting all slivers those are displayed in viewport.
  final OnObserveViewportCallback? onObserveViewport;
}
