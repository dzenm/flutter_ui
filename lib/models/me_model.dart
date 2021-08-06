import 'package:flutter/widgets.dart';
import 'package:flutter_ui/main.dart';
import 'package:provider/provider.dart';

class MeModel with ChangeNotifier {
  static MeModel get of =>
      Provider.of<MeModel>(Application.getContext, listen: false);
}
