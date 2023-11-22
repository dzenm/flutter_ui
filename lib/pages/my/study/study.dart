import '../../../base/base.dart';
import 'convert_study.dart';
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
    ConvertStudy.main();
    String path = 'https://192.168.0.104/images/app/chat/20231120101757039.mp4?size=100*320';
    log('path=$path');
    Uri uri = Uri.parse(path);
    log('path=${uri.path}');
    log('pathSegments=${uri.pathSegments}');
    log('query=${uri.query}');
    log('queryParameters=${uri.queryParameters}');
    log('queryParametersAll=${uri.queryParametersAll}');
    log('data=${uri.data}');
    log('authority=${uri.authority}');
    log('fragment=${uri.fragment}');
    log('userInfo=${uri.userInfo}');
    log('scheme=${uri.scheme}');
    log('port=${uri.port}');
    log('origin=${uri.origin}');
  }

  static void log(String msg) {
    Log.d(msg, tag: _tag);
  }
}
