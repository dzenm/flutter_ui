import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../main.dart';

class HomeModel with ChangeNotifier {
  static HomeModel get of => Provider.of<HomeModel>(navigator.currentContext!, listen: false);
}
