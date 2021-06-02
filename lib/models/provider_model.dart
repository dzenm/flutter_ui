import 'package:flutter/widgets.dart';
import 'package:flutter_ui/base/res/local_model.dart';
import 'package:provider/provider.dart';

class ProviderManager {
  static LocalModel localModel(BuildContext context, {bool listen = false}) {
    return Provider.of<LocalModel>(context, listen: listen);
  }
}
