import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ui/base/utils/sp_util.dart';
import 'package:flutter_ui/base/utils/str_util.dart';
import 'package:flutter_ui/base/widgets/common_widget.dart';
import 'package:flutter_ui/entities/user_entity.dart';

class ConvertPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ConvertPageState();
}

class _ConvertPageState extends State<ConvertPage> {
  Map<String, dynamic> data = {
    "admin": false,
    "chapterTops": [],
    "coinCount": 0,
    "collectIds": [11344],
    "email": "",
    "icon": "",
    "id": 4824,
    "nickname": "FreedomEden",
    "password": "",
    "publicName": "FreedomEden",
    "token": "",
    "type": 0,
    "username": "FreedomEden"
  };

  String listStr = '';
  String listToJsonStr = '';
  String listToBeanStr = '';

  @override
  Widget build(BuildContext context) {
    UserEntity user = UserEntity.fromJson(data);
    List<UserEntity> users = [user, user, user];
    return Scaffold(
      appBar: AppBar(
        title: Text('字符转化', style: TextStyle(color: Colors.white)),
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Row(children: [
                MaterialButton(
                  color: Colors.blue,
                  textColor: Colors.white,
                  child: Text('存储字符数组到SP'),
                  onPressed: () => SpUtil.setUserInfo(jsonEncode(users)),
                ),
              ]),
              SizedBox(height: 8),
              multipleTextView('通过jsonEncode编码为字符串, 然后通过SharedPreferences保存\njsonEncode(users)'),
              SizedBox(height: 8),
              divider(),
              SizedBox(height: 16),
              Row(children: [
                MaterialButton(
                  color: Colors.blue,
                  textColor: Colors.white,
                  child: Text('从SP取出字符数组'),
                  onPressed: () {
                    String string = SpUtil.getUserInfo();
                    if (string.length > 0) {
                      List<UserEntity> list = (jsonDecode(string) as List<dynamic>).map((e) => UserEntity.fromJson((e as Map<String, dynamic>))).toList();
                      setState(() {
                        listStr = jsonEncode(list);
                        listToJsonStr = StrUtil.formatToJson(list);
                        listToBeanStr = jsonDecode(listStr).toString();
                      });
                    }
                  },
                ),
              ]),
              SizedBox(height: 8),
              multipleTextView(
                  '先通过SharedPreferences取出字符, 再通过jsonDecode解码并强制转化为List<dynamic>, 遍历数组将dynamic转化为Bean对应的Map对象\n(jsonDecode(string) as List<dynamic>).map((e) => User.fromJson((e as Map<String, dynamic>))).toList()'),
              SizedBox(height: 8),
              divider(),
              titleView('Map', top: 16),
              multipleTextView(data.toString()),
              SizedBox(height: 8),
              divider(),
              titleView('Map转字符串并格式化', top: 16),
              multipleTextView(StrUtil.formatToJson(user.toJson())),
              SizedBox(height: 8),
              divider(),
              titleView('List', top: 16),
              multipleTextView(listStr),
              SizedBox(height: 8),
              divider(),
              titleView('List转字符串并格式化', top: 16),
              multipleTextView(listToJsonStr),
              SizedBox(height: 8),
              divider(),
              titleView('字符串转Bean', top: 16),
              multipleTextView(listToBeanStr),
              SizedBox(height: 8),
              divider(),
            ],
          ),
        ),
      ),
    );
  }
}
