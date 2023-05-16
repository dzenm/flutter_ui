import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ui/pages/routers.dart';
import 'package:provider/provider.dart';

import '../../base/log/log.dart';
import '../../base/res/app_theme.dart';
import '../../base/res/local_model.dart';
import '../../base/widgets/common_dialog.dart';
import '../../base/widgets/custom_popup_window.dart';
import '../../base/widgets/picker/picker_view.dart';
import '../../generated/l10n.dart';

///
/// Created by a0010 on 2022/11/3 16:03
///
class StudyPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> {
  String _selectedValue = '';
  GlobalKey _targetKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: Text(S.of(context).studyMainPage('(自定义语言)')),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(children: _buildChildrenButtons()),
        ),
      ),
    );
  }

  List<Widget> _buildChildrenButtons() {
    AppTheme theme = context.watch<LocalModel>().appTheme;
    return [
      SizedBox(height: 16),
      // 城市选择
      MaterialButton(
        child: _text('城市选择'),
        textColor: Colors.white,
        color: theme.appbarColor,
        onPressed: () => Navigator.pushNamed(context, Routers.study.city),
      ),
      SizedBox(height: 8),
      // 字符转化
      MaterialButton(
        child: _text('字符转化'),
        textColor: Colors.white,
        color: theme.appbarColor,
        onPressed: () => Navigator.pushNamed(context, Routers.study.convert),
      ),
      SizedBox(height: 8),
      // 可拖动ListView
      MaterialButton(
        child: _text('可拖动ListView'),
        textColor: Colors.white,
        color: theme.appbarColor,
        onPressed: () => Navigator.pushNamed(context, Routers.study.dragList),
      ),
      SizedBox(height: 8),
      // 快速页面创建
      MaterialButton(
        child: _text('快速页面创建'),
        textColor: Colors.white,
        color: theme.appbarColor,
        onPressed: () => Navigator.pushNamed(context, Routers.example),
      ),
      SizedBox(height: 8),
      // 浮动的导航栏和PopupWindow
      MaterialButton(
        child: _text('浮动的导航栏和PopupWindow'),
        textColor: Colors.white,
        color: theme.appbarColor,
        onPressed: () => Navigator.pushNamed(context, Routers.study.floatNavigation),
      ),
      SizedBox(height: 8),
      // HTTP请求
      MaterialButton(
        child: _text('HTTP请求'),
        textColor: Colors.white,
        color: theme.appbarColor,
        onPressed: () => Navigator.pushNamed(context, Routers.study.http),
      ),
      SizedBox(height: 8),
      // 自定义键盘
      MaterialButton(
        child: _text('自定义键盘'),
        textColor: Colors.white,
        color: theme.appbarColor,
        onPressed: () => Navigator.pushNamed(context, Routers.study.keyword),
      ),
      SizedBox(height: 8),
      // 刷新和底部加载的列表
      MaterialButton(
        child: _text('刷新和底部加载的列表'),
        textColor: Colors.white,
        color: theme.appbarColor,
        onPressed: () => Navigator.pushNamed(context, Routers.study.list),
      ),
      SizedBox(height: 8),
      // 加载图片
      MaterialButton(
        child: _text('加载图片'),
        textColor: Colors.white,
        color: theme.appbarColor,
        onPressed: () => Navigator.pushNamed(context, Routers.study.loadImage),
      ),
      SizedBox(height: 8),
      // Provider
      MaterialButton(
        child: _text('Provider'),
        textColor: Colors.white,
        color: theme.appbarColor,
        onPressed: () => Navigator.pushNamed(context, Routers.study.provider),
      ),
      SizedBox(height: 8),
      // 二维码扫描
      MaterialButton(
        child: _text('二维码扫描'),
        textColor: Colors.white,
        color: theme.appbarColor,
        onPressed: () => Navigator.pushNamed(context, Routers.study.qr),
      ),
      SizedBox(height: 8),
      // 路由测试
      MaterialButton(
        child: _text('路由测试'),
        textColor: Colors.white,
        color: theme.appbarColor,
        onPressed: () => Navigator.pushNamed(context, Routers.study.routers),
      ),
      SizedBox(height: 8),
      // 设置
      MaterialButton(
        child: _text(S.of(context).setting),
        textColor: Colors.white,
        color: theme.appbarColor,
        onPressed: () => Navigator.pushNamed(context, Routers.study.city),
      ),
      SizedBox(height: 8),
      // 加载状态
      MaterialButton(
        child: _text(S.of(context).state),
        textColor: Colors.white,
        color: theme.appbarColor,
        onPressed: () => Navigator.pushNamed(context, Routers.study.state),
      ),
      SizedBox(height: 8),
      // 文本展示
      MaterialButton(
        child: _text('文本展示'),
        textColor: Colors.white,
        color: theme.appbarColor,
        onPressed: () => Navigator.pushNamed(context, Routers.study.text),
      ),
      SizedBox(height: 8),
      // 视频播放
      MaterialButton(
        child: _text('视频播放'),
        textColor: Colors.white,
        color: theme.appbarColor,
        onPressed: () => Navigator.pushNamed(context, Routers.study.video),
      ),
      SizedBox(height: 8),
      // 自定义PopupView控件
      MaterialButton(
        key: _targetKey,
        child: _text('PopupWindow测试'),
        textColor: Colors.white,
        color: theme.appbarColor,
        onPressed: () => CustomPopupWindow.showList(
          context,
          targetKey: _targetKey,
          titles: ['全选', '复制', '粘贴', '测试'],
          direction: PopupDirection.bottomLeft,
          onItemTap: (index) {
            CommonDialog.showToast('第${index + 1}个Item');
          },
        ),
      ),
      SizedBox(height: 8),
      // PickerListView控件
      MaterialButton(
        child: _text('PickerListView控件'),
        textColor: Colors.white,
        color: theme.appbarColor,
        onPressed: () => PickerView.showList(
          context,
          list: ['测试一', '测试二', '测试三', '测试四', '测试五'],
          initialItem: _selectedValue,
          onChanged: (value) {
            _selectedValue = value;
            Log.i('选中的回调: $_selectedValue');
          },
        ),
      ),
      SizedBox(height: 8),
      // 升级dialog
      MaterialButton(
        child: _text('升级dialog'),
        textColor: Colors.white,
        color: theme.appbarColor,
        onPressed: () => CommonDialog.showAppUpgradeDialog(
          context,
          version: '12',
          desc: ['升级了'],
        ),
      ),
      SizedBox(height: 8),
      // 选择区域
      MaterialButton(
        child: _text('选择区域'),
        textColor: Colors.white,
        color: theme.appbarColor,
        onPressed: () => PickerView.showLocation(context, initialItem: ['湖北', '荆门市', '京山县'], onChanged: (results) {
          Log.d('选中的结果: results=$results');
        }),
      ),
      SizedBox(height: 16),
    ];
  }

  Widget _text(String text) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(text)]);
  }
}
