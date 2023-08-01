import 'study.dart';

///
/// Created by a0010 on 2022/9/20 14:47
///
class MathStudy {
  static void main() {
    MathStudy()._mergeSortTest();
  }

  void _mergeSortTest() {
    List<int> arr = [19, 85, 27, 68, 41, 65, 59, 82, 74, 41, 32, 70];
    List<int> temp = [];
    Study.log('归并排序前： arr=$arr');
    _mergeSort(arr, temp, 0, arr.length - 1);
    Study.log('归并排序后： arr=$arr');
  }

  void _mergeSort(List<int> arr, List<int> temp, int lo, int hi) {
    if (lo < hi) {
      int mid = lo + (hi - lo) ~/ 2;
      _mergeSort(arr, temp, lo, mid);
      _mergeSort(arr, temp, mid + 1, hi);
      _merge(arr, temp, lo, hi, mid + 1);
    }
  }

  void _merge(List<int> arr, List<int> temp, int lo, int hi, int mid) {
    int len = hi - lo + 1;
    int p = lo, i = lo, j = mid;
    while (i <= mid - 1 && j <= hi) {
      temp[p++] = arr[i] < arr[j] ? arr[i++] : arr[j++];
    }
    while (i <= mid - 1) {
      temp[p++] = arr[i++];
    }
    while (j <= hi) {
      temp[p++] = arr[j++];
    }
    for (int k = 0; k < len; k++, hi--) {
      arr[hi] = temp[hi];
    }
  }
}
