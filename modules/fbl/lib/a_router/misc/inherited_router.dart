import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../router.dart';

/// ARouter implementation of InheritedWidget.
///
/// Used for to find the current ARouter in the widget tree. This is useful
/// when routing from anywhere in your app.
class InheritedARouter extends InheritedWidget {
  /// Default constructor for the inherited go router.
  const InheritedARouter({
    required super.child,
    required this.router,
    super.key,
  });

  /// The [ARouter] that is made available to the widget tree.
  final ARouter router;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ARouter>('router', router));
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}
