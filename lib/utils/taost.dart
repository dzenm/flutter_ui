import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// toast工具类
showToast(String text, {int seconds = 2}) {
  BotToast.showText(
    text: text,
    onlyOne: true,
    duration: Duration(seconds: seconds),
    textStyle: TextStyle(fontSize: 14, color: Colors.white),
  );
}
