import 'study.dart';

///
/// Created by a0010 on 2024/3/18 11:01
///
class EuclideanStudy {
  static void main() {
    Study.log('辗转相除法：');
    EuclideanStudy study = EuclideanStudy();
    study.gcd(36, 78);
  }

  int gcd(int a, int b) {
    int m = a, n = b;
    Study.log('初始：m=$m, n=$n');
    // 保证m > n;
    if (m < n) {
      int tmp = m;
      m = n;
      n = tmp;
      Study.log('初始调整：m=$m, n=$n');
    }
    // 计算 大数除以小数的余数

    int r = m % n;
    while (r != 0) {
      Study.log('调整：m=$m, n=$n, r=$r');
      m = n;
      n = r;
      r = m % n;
    }
    Study.log('调整：m=$m, n=$n, r=$r');

    Study.log('辗转相除法 m=$a, n=$b 的最大公约数为 r=$n');
    return n;
  }
}
