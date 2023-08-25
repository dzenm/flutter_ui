import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'mock_binary_messenger.dart';

class MockBinding extends WidgetsFlutterBinding {
  static bool _initFlag = false;

  @override
  void initInstances() {
    _binaryMessenger = MockBinaryMessenger(this);
    super.initInstances();
    _initFlag = true;
  }

  static WidgetsBinding ensureInitialized() {
    if (!_initFlag) {
      MockBinding();
      _initFlag = true;
    }
    // if (WidgetsBinding.instance == null) MockBinding();
    return WidgetsBinding.instance;
  }

  MockBinaryMessenger? _binaryMessenger;

  @override
  BinaryMessenger get defaultBinaryMessenger {
    return _binaryMessenger != null ? _binaryMessenger! : super.defaultBinaryMessenger;
  }

  BinaryMessenger get superDefaultBinaryMessenger {
    return super.defaultBinaryMessenger;
  }
}

void runMockApp(Widget app) {
  final WidgetsBinding binding = MockBinding.ensureInitialized();
  Timer.run(() {
    binding.attachRootWidget(binding.wrapWithDefaultView(app));
  });
  binding.scheduleWarmUpFrame();
}
