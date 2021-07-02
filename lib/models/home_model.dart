import 'package:flutter/widgets.dart';
import 'package:flutter_ui/main.dart';
import 'package:provider/provider.dart';

class HomeModel extends ChangeNotifier {
  static HomeModel get of =>
      Provider.of<HomeModel>(navigator.currentContext!, listen: false);
}
