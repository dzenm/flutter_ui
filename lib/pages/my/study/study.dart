import 'package:fbl/fbl.dart';
import 'convert_study.dart';
import 'euclidean_study.dart';
import 'future_study.dart';
import 'math_study.dart';
import 'custom_list_sort_study.dart';
import 'url_study.dart';

class Study {
  static const String _tag = 'Study';

  /// main 方法
  static void main() {
    log('\n');
    ConvertStudy.main();
    log('\n');
    EuclideanStudy.main();
    log('\n');
    FutureStudy.main();
    log('\n');
    MathStudy.main();
    log('\n');
    CustomListSortStudy.main();
    log('\n');
    ConvertStudy.main();
    log('\n');
    UrlStudy.main();
    log('\n');
  }

  static void log(dynamic msg, {String prefix = ''}) {
    StringBuffer sb = StringBuffer();
    if (msg is List<int>) {
      sb.write(prefix);
      int length = msg.length;
      StringBuffer list = StringBuffer();
      for (int i = 0; i < length; i++) {
        list
          ..write(msg[i])
          ..write(i == length - 1 ? '' : ', ');
      }
      sb.write('[${list.toString()}]');
    } else if (msg is String) {
      sb.write(msg);
    } else if (msg is num) {
      sb.write(msg);
    }
    Log.d(sb.toString(), tag: _tag);
  }
}

class StudyExample {
  static void main() {
    StudyExample study = StudyExample();
    study.run();
  }

  void run() {}
}
