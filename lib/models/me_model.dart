import 'package:flutter/widgets.dart';
import 'package:flutter_ui/main.dart';
import 'package:provider/provider.dart';

class MeModel extends ChangeNotifier {
  static MeModel get of =>
      Provider.of<MeModel>(navigator.currentContext!, listen: false);
}
