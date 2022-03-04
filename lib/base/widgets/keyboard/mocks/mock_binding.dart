import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'mock_binary_messenger.dart';

class MockBinding extends WidgetsFlutterBinding {
  @override
  void initInstances() {
    // TODO: implement initInstances
    super.initInstances();
    _binaryMessenger = MockBinaryMessenger(super.defaultBinaryMessenger);
  }

  static WidgetsBinding ensureInitialized() {
    if (WidgetsBinding.instance == null) MockBinding();
    return WidgetsBinding.instance!;
  }

  MockBinaryMessenger? _binaryMessenger;

  @override
  BinaryMessenger get defaultBinaryMessenger {
    return _binaryMessenger != null ? _binaryMessenger! : super.defaultBinaryMessenger;
  }
}

runMockApp(Widget app) {
  MockBinding.ensureInitialized()
    ..scheduleAttachRootWidget(app)
    ..scheduleWarmUpFrame();
}
