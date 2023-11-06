import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../base/base.dart';
import '../study_model.dart';

/// 浮动的导航栏和PopupWindow
class FloatNavigationPage extends StatefulWidget {
  const FloatNavigationPage({super.key});

  @override
  State<StatefulWidget> createState() => _FloatNavigationPageState();
}

class _FloatNavigationPageState extends State<FloatNavigationPage> {
  final List<IconData> _nav = [
    Icons.search,
    Icons.ondemand_video,
    Icons.music_video,
    Icons.insert_comment,
    Icons.person,
  ]; // 导航项

  final List<String> _title = ['搜索', '视频', '音乐', '评论', '我的'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: const Text('导航栏', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: const ContentWidget(),
      bottomNavigationBar: FloatNavigationBar(_nav, title: _title),
    );
  }
}

class ContentWidget extends StatelessWidget {
  const ContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    Log.d('build', tag: 'ContentWidget');
    String? username = context.watch<StudyModel>().username;
    return Column(children: [
      if (username != null) const UserNameWidget(),
      const SizedBox(height: 16),
      WrapButton(
        text: '修改',
        width: 100.0,
        onTap: () {
          String? value = context.read<StudyModel>().username;
          if (value == null) {
            context.read<StudyModel>().username = 'new value';
          } else {
            context.read<StudyModel>().username = null;
          }
        },
      ),
    ]);
  }
}

class UserNameWidget extends StatelessWidget {
  const UserNameWidget({super.key});

  @override
  Widget build(BuildContext context) {
    Log.d('build', tag: 'UserNameWidget');
    String username = context.watch<StudyModel>().username!;
    return Text(username);
  }
}
