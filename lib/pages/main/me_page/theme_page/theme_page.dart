import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ui/base/res/colors.dart';
import 'package:flutter_ui/base/res/local_model.dart';
import 'package:flutter_ui/models/provider_model.dart';

class ThemePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ThemePageState();
}

class _ThemePageState extends State<ThemePage> {
  String? _colorKey;

  @override
  void initState() {
    super.initState();
    _colorKey = ProviderManager.localModel(context).theme;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('设置主题', style: TextStyle(color: Colors.white)),
      ),
      body: Center(),
    );
  }
}
