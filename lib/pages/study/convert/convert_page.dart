import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_ui/entities/user_entity.dart';

import '../../../base/base.dart';

/// 字符转化
class ConvertPage extends StatefulWidget {
  const ConvertPage({super.key});

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
      appBar: const CommonBar(
        title: '字符转化',
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(children: [
                MaterialButton(
                  color: Colors.blue,
                  textColor: Colors.white,
                  child: const Text('存储字符数组到SP(model转string)'),
                  onPressed: () => SPManager.setUserInfo(jsonEncode(users)),
                ),
              ]),
              const SizedBox(height: 8),
              CommonWidget.multipleTextView('通过jsonEncode转为字符串, 然后通过SharedPreferences保存\n\njsonEncode(users)'),
              const SizedBox(height: 8),
              CommonWidget.divider(),
              const SizedBox(height: 16),
              Row(children: [
                MaterialButton(
                  color: Colors.blue,
                  textColor: Colors.white,
                  child: const Text('从SP取出字符数组(string转model)'),
                  onPressed: () {
                    String json = SPManager.getUserInfo();
                    if (json.isNotEmpty) {
                      List<UserEntity> users = (jsonDecode(json) as List<dynamic>).map((e) => UserEntity.fromJson((e as Map<String, dynamic>))).toList();
                      setState(() {
                        listStr = jsonEncode(users);
                        listToJsonStr = StrUtil.formatToJson(users);
                        listToBeanStr = jsonDecode(listStr).toString();
                      });
                    }
                  },
                ),
              ]),
              const SizedBox(height: 8),
              CommonWidget.multipleTextView(
                  '先通过SharedPreferences取出字符, 再通过jsonDecode解码并强制转化为List<dynamic>, 遍历数组将dynamic转化为Bean对应的Map对象\n\n(jsonDecode(string) as List<dynamic>).map((e) => User.fromJson((e as Map<String, dynamic>))).toList()'),
              const SizedBox(height: 8),
              CommonWidget.divider(),
              CommonWidget.titleView('Map', top: 16),
              CommonWidget.multipleTextView(data.toString()),
              const SizedBox(height: 8),
              CommonWidget.divider(),
              CommonWidget.titleView('Map转字符串并格式化', top: 16),
              CommonWidget.multipleTextView(StrUtil.formatToJson(user.toJson())),
              const SizedBox(height: 8),
              CommonWidget.divider(),
              CommonWidget.titleView('List', top: 16),
              CommonWidget.multipleTextView(listStr),
              const SizedBox(height: 8),
              CommonWidget.divider(),
              CommonWidget.titleView('List转字符串并格式化', top: 16),
              CommonWidget.multipleTextView(listToJsonStr),
              const SizedBox(height: 8),
              CommonWidget.divider(),
              CommonWidget.titleView('字符串转Bean', top: 16),
              CommonWidget.multipleTextView(listToBeanStr),
              const SizedBox(height: 8),
              CommonWidget.divider(),
            ],
          ),
        ),
      ),
    );
  }
}
