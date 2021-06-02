import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ui/base/res/colors.dart';
import 'package:flutter_ui/base/res/local_model.dart';
import 'package:flutter_ui/base/widgets/common_widget.dart';
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
    _colorKey = LocalModel().themeColor;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: leadingView(),
        title: Text('设置主题', style: TextStyle(color: Colors.white)),
      ),
      body: ListView(
        children: [
          ExpansionTile(
            leading: Icon(Icons.color_lens),
            title: Text('主题'),
            initiallyExpanded: true,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: themeColorModel.keys.map((key) {
                    Color? value = themeColorModel[key]!['primaryColor'];
                    return InkWell(
                      onTap: () {
                        setState(() => _colorKey = key);
                        ProviderManager.localModel(context).setTheme(key);
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        color: value,
                        child: _colorKey == key ? Icon(Icons.done, color: Colors.white) : null,
                      ),
                    );
                  }).toList(),
                ),
              )
            ],
          ),
          ListTile(
            leading: Icon(Icons.language),
            title: Text('多语言'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('跟随系统', style: TextStyle(fontSize: 14.0, color: Colors.grey)),
                Icon(Icons.keyboard_arrow_right),
              ],
            ),
          )
        ],
      ),
    );
  }
}
