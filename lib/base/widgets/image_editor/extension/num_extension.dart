import 'package:flutter/cupertino.dart';

extension EditorNum on num {
  Widget get vGap => SizedBox(height: toDouble());

  Widget get hGap => SizedBox(width: toDouble());
}
