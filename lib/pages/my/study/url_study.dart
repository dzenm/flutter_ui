import 'study.dart';

///
/// Created by a0010 on 2024/3/18 11:23
///
class UrlStudy {
  static void main() {
    UrlStudy study = UrlStudy();
    study.parse();
  }

  void parse() {
    String path = 'https://192.168.0.104/images/app/chat/20231120101757039.mp4?size=100*320';
    Study.log('path=$path');
    Uri uri = Uri.parse(path);
    Study.log('path=${uri.path}');
    Study.log('pathSegments=${uri.pathSegments}');
    Study.log('query=${uri.query}');
    Study.log('queryParameters=${uri.queryParameters}');
    Study.log('queryParametersAll=${uri.queryParametersAll}');
    Study.log('data=${uri.data}');
    Study.log('authority=${uri.authority}');
    Study.log('fragment=${uri.fragment}');
    Study.log('userInfo=${uri.userInfo}');
    Study.log('scheme=${uri.scheme}');
    Study.log('port=${uri.port}');
    Study.log('origin=${uri.origin}');
  }
}
