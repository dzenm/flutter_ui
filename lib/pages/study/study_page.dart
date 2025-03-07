import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:fbl/fbl.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ui/pages/study/provider.dart';
import 'package:flutter_ui/pages/widgets/widgets.dart';
import 'package:provider/provider.dart';

import '../../generated/l10n.dart';
import '../common/permission.dart';
import '../main/main_model.dart';
import '../utils/pick_files_helper.dart';
import 'study_main.dart';
import 'study_router.dart';

///
/// Created by a0010 on 2022/11/3 16:03
///
class StudyPage extends StatefulWidget {
  const StudyPage({super.key});

  @override
  State<StatefulWidget> createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> with Logging {
  late StudyProviderModel _model;

  @override
  void initState() {
    super.initState();
    StudyMain.main();
    Friend friend = BusinessFriend();
    logInfo('测试：${friend is GoodFriend}');
    logInfo('测试：${friend is BusinessFriend}');
    logInfo('测试：${friend is Child}');
    logInfo('测试：${friend is NameMixin}');
    logInfo('测试：${friend.toJson()}');
    _model = StudyProviderModel();

    Map<String, dynamic> json = {
      'userUid': '7i21g1n1j23u1g1',
      'userName': '玉皇大帝',
    };
    User user = User.fromJson(json);
    logInfo('测试：${user.toJson()}');
  }

  @override
  Widget build(BuildContext context) {
    return ProviderModel(
      notifier: _model,
      child: Material(
        child: Builder(builder: (context) {
          return _buildPage(context);
        }),
      ),
    );
  }

  Widget _buildPage(BuildContext context) {
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
      body: _buildBody(context, theme),
    );
  }

  Widget _buildBody(BuildContext context, AppTheme theme) {
    return Container(
      color: theme.background,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        child: Column(children: _buildChildrenButtons(context)),
      ),
    );
  }

  List<Widget> _buildChildrenButtons(BuildContext context) {
    AppTheme theme = context.watch<LocalModel>().theme;
    return [
      const SizedBox(height: 8),
      // 组件
      MaterialButton(
        textColor: Colors.white,
        color: theme.button,
        onPressed: () => context.pushNamed(StudyRouter.components),
        child: _text('组件'),
      ),
      const SizedBox(height: 8),
      // 字符转化
      MaterialButton(
        textColor: Colors.white,
        color: theme.button,
        onPressed: () => context.pushNamed(StudyRouter.convert),
        child: _text('字符转化'),
      ),
      const SizedBox(height: 8),
      // 桌面端
      MaterialButton(
        textColor: Colors.white,
        color: theme.button,
        onPressed: () => context.pushNamed(StudyRouter.desktop),
        child: _text('桌面端处理'),
      ),
      const SizedBox(height: 8),
      // HTTP请求
      MaterialButton(
        textColor: Colors.white,
        color: theme.button,
        onPressed: () => context.pushNamed(StudyRouter.http),
        child: _text('HTTP请求'),
      ),
      const SizedBox(height: 8),
      // 加载图片
      MaterialButton(
        textColor: Colors.white,
        color: theme.button,
        onPressed: () => context.pushNamed(StudyRouter.loadImage),
        child: _text('加载图片'),
      ),
      const SizedBox(height: 8),
      // Provider
      MaterialButton(
        textColor: Colors.white,
        color: theme.button,
        onPressed: () => context.pushNamed(StudyRouter.provider),
        child: _text('Provider'),
      ),
      const SizedBox(height: 8),
      // 路由测试
      MaterialButton(
        textColor: Colors.white,
        color: theme.button,
        onPressed: () => context.pushNamed(StudyRouter.router),
        child: _text('路由测试'),
      ),
      const SizedBox(height: 8),
      // 视频播放
      MaterialButton(
        textColor: Colors.white,
        color: theme.button,
        onPressed: () => context.pushNamed(StudyRouter.video),
        child: _text('视频播放'),
      ),
      const SizedBox(height: 8),
      // WI-FI热点
      MaterialButton(
        textColor: Colors.white,
        color: theme.button,
        onPressed: () => context.pushNamed(StudyRouter.wifi),
        // onPressed: () => PluginManager.openWifiHotspot(),
        child: _text('WI-FI热点'),
      ),
      // 多窗口测试
      const SizedBox(height: 8),
      MaterialButton(
        textColor: Colors.white,
        color: theme.button,
        onPressed: () => context.pushNamed(StudyRouter.window),
        child: _text('多窗口测试'),
      ),
      const SizedBox(height: 8),
      MaterialButton(
        textColor: Colors.white,
        color: theme.button,
        onPressed: () {
          context.read<MainModel>().setSelectedTab(MainTab.nav);
          context.pop('这是回调的数据');
        },
        child: _text('返回并传递数据'),
      ),
      const SizedBox(height: 8),
      MaterialButton(
        textColor: Colors.white,
        color: theme.button,
        onPressed: () async {
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
      const SizedBox(height: 8),
      MaterialButton(
        textColor: Colors.white,
        color: theme.button,
        onPressed: () async {
          bool? result = await PermissionPage.request(context, permission: XPermission.location);
          CommonDialog.showToast('返回结果：$result');
        },
        child: _text('请求位置权限'),
      ),
      const SizedBox(height: 8),
      MaterialButton(
        textColor: Colors.white,
        color: theme.button,
        onPressed: () async {
          bool? result = await PermissionPage.request(context, permission: XPermission.microphone);
          CommonDialog.showToast('返回结果：$result');
        },
        child: _text('请求麦克风权限'),
      ),
      const SizedBox(height: 8),
      MaterialButton(
        textColor: Colors.white,
        color: theme.button,
        onPressed: () async {
          ProviderModel.read(context).add();
        },
        child: _text('更改数据'),
      ),
      const SizedBox(height: 8),
      MaterialButton(
        textColor: Colors.white,
        color: theme.button,
        onPressed: () async {
          ProviderModel.read(context).reset();
        },
        child: _text('重置数据'),
      ),
      const SizedBox(height: 8),
      Selector0<String>(
        builder: (c, text, w) {
          return Text(text);
        },
        selector: (context) => ProviderModel.of(context).value.toString(),
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

abstract class People implements Student {}

abstract class Friend extends People {
  String name = 'hello';
  int age = 0;

  Map<String, dynamic> toJson() => {
        'name': name,
        'age': 32,
      };
}

class GoodFriend extends Friend {
  @override
  Map<String, dynamic> toJson() => super.toJson()
    ..addAll({
      'age': 24,
    });
}

class BusinessFriend extends Friend with NameMixin, AddressMixin {
  @override
  String address = 'my address';

  BusinessFriend({String? address});

  @override
  Map<String, dynamic> toJson() => super.toJson()
    ..addAll({
      'age': 24,
      'address': address,
    });
}

mixin AddressMixin {
  String address = 'hello address';
}

mixin NameMixin on Friend {
  @override
  String get name => 'modify name';
}

abstract interface class Child {}

abstract interface class Student {}

abstract class Data {
  late String userUid;

  Data({required this.userUid});

  // Data.fromJson(Map<String, dynamic> json) : this(userUid: json['userUid']);

  Data.fromJson(Map<String, dynamic> json) {
    userUid = '';
  }

  Map<String, dynamic> toJson() => {
        'userUid': userUid,
      };
}

class User extends Data {
  late String userName;

  User({required super.userUid, required this.userName});

  User.fromJson(super.json)
      : userName = '',
        super.fromJson();

  @override
  Map<String, dynamic> toJson() => super.toJson()
    ..addAll({
      'userName': userName,
    });
}
