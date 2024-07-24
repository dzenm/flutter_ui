import 'package:fbl/fbl.dart';
import 'study.dart';

///
/// Created by a0010 on 2023/8/10 09:51
///
class ConvertStudy {
  static void main() {
    Study.log('字符串转换：');
    ConvertStudy().string2Num();
  }

  void string2Num() {
    List<String?> list = ['a', '189', '8u', 'null', '98', '', '7', '汉'];

    for (var item in list) {
      int value = StrUtil.parseInt(item);
      Study.log('字符串转数字： value=$item, convert=$value');
    }
  }
}
