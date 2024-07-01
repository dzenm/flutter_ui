import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ui/pages/utils/pick_files_helper.dart';
import 'package:provider/provider.dart';

import '../../base/base.dart';
import '../../generated/l10n.dart';
import '../main/main_model.dart';
import '../widgets/widgets.dart';
import 'study_main.dart';
import 'study_router.dart';
import 'package:crypto/crypto.dart';

///
/// Created by a0010 on 2022/11/3 16:03
///
class StudyPage extends StatefulWidget {
  const StudyPage({super.key});

  @override
  State<StatefulWidget> createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> with Logging {
  @override
  void initState() {
    super.initState();
    StudyMain.main();
  }

  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch<LocalModel>().theme;
    return NestedScrollView(
      floatHeaderSlivers: true,
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return [
          SliverAppBar(
            //当此值为true时 SliverAppBar 会固定在页面顶部，为false时 SliverAppBar 会随着滑动向上滑动
            pinned: true,
            //滚动是是否拉伸图片
            stretch: true,
            //展开区域的高度
            expandedHeight: 300,
            //当snap配置为true时，向下滑动页面，SliverAppBar（以及其中配置的flexibleSpace内容）会立即显示出来，
            //反之当snap配置为false时，向下滑动时，只有当ListView的数据滑动到顶部时，SliverAppBar才会下拉显示出来。
            snap: false,
            //阴影
            elevation: 0,
            //背景颜色
            // backgroundColor: headerWhite ? Colors.white : Color(0xFFF4F5F7),
            //一个显示在 AppBar 下方的控件，高度和 AppBar 高度一样， // 可以实现一些特殊的效果，该属性通常在 SliverAppBar 中使用
            flexibleSpace: FlexibleSpaceBar(
              title: Text(S.of(context).studyMainPage('(自定义语言)'), style: TextStyle(color: theme.background)),
              background: const ImageView(
                url: 'http://img.haote.com/upload/20180918/2018091815372344164.jpg',
                fit: BoxFit.cover,
              ),
            ),
            systemOverlayStyle: SystemUiOverlayStyle.light,
          ),
        ];
      },
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(AppTheme theme) {
    return Container(
      color: theme.background,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        child: Column(children: _buildChildrenButtons()),
      ),
    );
  }

  List<Widget> _buildChildrenButtons() {
    AppTheme theme = context.watch<LocalModel>().theme;
    return [
      const SizedBox(height: 8),
      // 组件
      MaterialButton(
        textColor: Colors.white,
        color: theme.button,
        onPressed: () => AppRouter.of(context).push(StudyRouter.components),
        child: _text('组件'),
      ),
      const SizedBox(height: 8),
      // 字符转化
      MaterialButton(
        textColor: Colors.white,
        color: theme.button,
        onPressed: () => AppRouter.of(context).push(StudyRouter.convert),
        child: _text('字符转化'),
      ),
      const SizedBox(height: 8),
      // 桌面端
      MaterialButton(
        textColor: Colors.white,
        color: theme.button,
        onPressed: () => AppRouter.of(context).push(StudyRouter.desktop),
        child: _text('桌面端处理'),
      ),
      const SizedBox(height: 8),
      const SizedBox(height: 8),
      // HTTP请求
      MaterialButton(
        textColor: Colors.white,
        color: theme.button,
        onPressed: () => AppRouter.of(context).push(StudyRouter.http),
        child: _text('HTTP请求'),
      ),
      const SizedBox(height: 8),
      // 加载图片
      MaterialButton(
        textColor: Colors.white,
        color: theme.button,
        onPressed: () => AppRouter.of(context).push(StudyRouter.loadImage),
        child: _text('加载图片'),
      ),
      const SizedBox(height: 8),

      // Provider
      MaterialButton(
        textColor: Colors.white,
        color: theme.button,
        onPressed: () => AppRouter.of(context).push(StudyRouter.provider),
        child: _text('Provider'),
      ),
      const SizedBox(height: 8),

      const SizedBox(height: 8),
      // 路由测试
      MaterialButton(
        textColor: Colors.white,
        color: theme.button,
        onPressed: () => AppRouter.of(context).push(StudyRouter.router),
        child: _text('路由测试'),
      ),
      const SizedBox(height: 8),

      // 视频播放
      MaterialButton(
        textColor: Colors.white,
        color: theme.button,
        onPressed: () => AppRouter.of(context).push(StudyRouter.video),
        child: _text('视频播放'),
      ),
      // 多窗口测试
      const SizedBox(height: 8),
      MaterialButton(
        textColor: Colors.white,
        color: theme.button,
        onPressed: () => AppRouter.of(context).push(StudyRouter.multiWindow),
        child: _text('多窗口测试'),
      ),
      const SizedBox(height: 8),
      MaterialButton(
        textColor: Colors.white,
        color: theme.button,
        onPressed: () {
          context.read<MainModel>().selectedTab = MainTab.nav;
          AppRouter.of(context).pop('这是回调的数据');
        },
        child: _text('返回并传递数据'),
      ),
      const SizedBox(height: 8),
      MaterialButton(
        textColor: Colors.white,
        color: theme.button,
        onPressed: () {
          _pickFiles((files) async {
            for (var file in files) {
              String path = file.path;
              String md5 = await calculateFileMd5(path);
              logDebug('文件md5：$md5');
            }
          });
        },
        child: _text('选择文件并计算md5'),
      ),
    ];
  }

  Future<String> calculateFileMd5(String filePath) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    return md5.convert(bytes).toString();
  }

  void _pickFiles(void Function(List<XFile> files)? onTap) {
    PickFilesHelper.pickFile(success: (files) {
      CommonDialog.showCustomDialog(
        context,
        barrierDismissible: false,
        child: EnsureSendFileWidget(
          title: '',
          logo: '',
          files: files,
          onTap: onTap,
        ),
      );
    });
  }

  Widget _text(String text) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(text)]);
  }
}