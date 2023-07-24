import 'package:flutter_ui/base/log/log.dart';

import 'future_study.dart';
import 'math_study.dart';
import 'sort_study.dart';

class Study {
  static const String _tag = 'Study';

  /// main 方法
  static void main() {
    FutureStudy.main();
    SortStudy.main();
    MathStudy.main();
  }

  static void log(String msg) {
    Log.d(msg, tag: _tag);
  }
}
