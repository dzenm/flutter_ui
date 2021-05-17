import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_ui/http/log.dart';

class MediaService {
  static const MEDIA_SERVICE = 'android/media/service';

  static void startService() async {
    if (Platform.isAndroid) {
      MethodChannel channel = MethodChannel(MEDIA_SERVICE);
      String data = await channel.invokeMethod('startService');
      Log.d(data, tag: 'MediaService');
    }
  }
}
