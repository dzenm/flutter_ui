import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ui/base/log/log.dart';
import 'package:flutter_ui/base/res/assets.dart';
import 'package:flutter_ui/base/res/strings.dart';
import 'package:flutter_ui/base/router/route_manager.dart';
import 'package:flutter_ui/base/widgets/badge_view.dart';
import 'package:flutter_ui/base/widgets/common_dialog.dart';
import 'package:flutter_ui/base/widgets/common_widget.dart';
import 'package:flutter_ui/base/widgets/keyboard/custom_keyword_board.dart';
import 'package:flutter_ui/base/widgets/keyboard/keyboard_media_query.dart';
import 'package:flutter_ui/base/widgets/menu_Item.dart';
import 'package:flutter_ui/base/widgets/single_edit_layout.dart';
import 'package:flutter_ui/base/widgets/single_text_layout.dart';
import 'package:flutter_ui/base/widgets/tap_layout.dart';
import 'package:flutter_ui/base/widgets/will_pop_view.dart';
import 'package:flutter_ui/pages/main/me_page/me_model.dart';
import 'package:flutter_ui/pages/main/nav_page/setting_page/setting_page.dart';

class TextPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TextPageState();
}

class _TextPageState extends State<TextPage> {
  static const String _TAG = 'TextPage';
  TextEditingController _controller = new TextEditingController(text: "初始化");
  String text = '';
  String newText = '';
  bool switchState = true;
  bool isChanged = false;
  List<Item> _items = [
    Item(0, title: '数据库'),
    Item(1, title: 'SharedPreference'),
    Item(2, title: '设置'),
    Item(3, title: '清空所有'),
    Item(4, title: '退出'),
  ];

  @override
  void initState() {
    super.initState();

    Log.d('initState', tag: _TAG);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Log.d('didChangeDependencies', tag: _TAG);
  }

  @override
  void didUpdateWidget(covariant TextPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    Log.d('didUpdateWidget', tag: _TAG);
  }

  @override
  void deactivate() {
    super.deactivate();
    Log.d('deactivate', tag: _TAG);
  }

  @override
  void dispose() {
    super.dispose();
    Log.d('dispose', tag: _TAG);
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardMediaQuery(
      //用于键盘弹出的时候页面可以滚动到输入框的位置
      child: WillPopView(
        onWillPop: () => promptBack(context, isChanged: text != newText, builder: buildPromptBackDialog),
        child: Scaffold(
          appBar: AppBar(
            title: Text('文本和输入框', style: TextStyle(color: Colors.white)),
            actions: [
              PopupMenuButton(
                elevation: 4.0,
                onSelected: (Item item) {
                  showToast(item.title ?? '');
                },
                itemBuilder: (BuildContext context) {
                  return _items.map((value) {
                    return PopupMenuItem(
                      value: value,
                      child: Row(children: [
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: Icon(Icons.map),
                        ),
                        Text(value.title ?? ''),
                      ]),
                    );
                  }).toList();
                },
              )
            ],
          ),
          body: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleView('无边框带字数控制的输入框: '),
                    SingleEditLayout(
                      '账户',
                      onChanged: (value) => setState(() => newText = value),
                      controller: _controller,
                      maxLength: 12,
                      fontSize: 14,
                      horizontalPadding: 0,
                      keyboardType: CustomKeywordBoard.license,
                    ),
                    Container(
                      color: Colors.blue,
                      padding: EdgeInsets.all(8),
                      height: 80,
                      alignment: Alignment.topLeft,
                      child: Row(children: [Text(newText, maxLines: 4, style: TextStyle(color: Colors.white))]),
                    ),
                    SizedBox(height: 8),
                    divider(),
                    SizedBox(height: 24),
                    titleView('自适应宽度使用: '),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Flexible(child: Text('Row包含一个文本，两个图标，给所有子widget设置Expand的，这是长文本的效果', maxLines: 1, overflow: TextOverflow.ellipsis)),
                        Icon(Icons.add_photo_alternate_outlined),
                        Icon(Icons.info),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Flexible(child: Text('短文本和图标', maxLines: 1, overflow: TextOverflow.ellipsis)),
                        Icon(Icons.add_photo_alternate_outlined),
                        Icon(Icons.info),
                      ],
                    ),
                    SizedBox(height: 8),
                    divider(),
                    SizedBox(height: 24),
                    titleView('设置页面常用单行布局: '),
                    TapLayout(
                      height: 50.0,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      onTap: () => RouteManager.push(SettingPage()),
                      child: SingleTextLayout(title: S.of(context).setting, isShowForward: true, prefix: BadgeView(count: 10)),
                    ),
                    TapLayout(
                      height: 50.0,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      onTap: () => MeModel.of.setValue('new value'),
                      child: SingleTextLayout(title: S.of(context).phone, text: '17601487212', isTextLeft: false, isShowForward: true),
                    ),
                    TapLayout(
                      height: 50.0,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      onTap: () => showPromptDialog(
                        context,
                        titleString: '立即开通',
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('购买类型：', style: TextStyle(fontSize: 16)),
                            Text('应付金额：￥', style: TextStyle(fontSize: 16)),
                            Text('支付方式：(￥)', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                      child: SingleTextLayout(icon: Icons.date_range_outlined, title: '生日', text: '1997/2/12', isTextLeft: false, isShowForward: true),
                    ),
                    TapLayout(
                      height: 50.0,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      onTap: () {
                        CancelFunc cancel = loadingDialog();
                        Future.delayed(Duration(seconds: 1), () => cancel());
                        setState(() => isChanged = true);
                      },
                      child: SingleTextLayout(
                        icon: Icons.adb,
                        title: '关于',
                        isTextLeft: false,
                        isShowForward: true,
                        badgeCount: 0,
                      ),
                    ),
                    TapLayout(
                      height: 50.0,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      // onTap: () => showPromptDialog(context, titleString: '确定要退出系统了吗？', onPositiveTap: () => showToast('修改成功')),
                      onTap: () => showPromptDialog(context, titleString: '昵称', content: Text('这是设置好的昵称'), onPositiveTap: () => showToast('修改成功')),
                      child: SingleTextLayout(
                        icon: Icons.person,
                        title: S.of(context).avatar,
                        isTextLeft: false,
                        suffix: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(Assets.image('a.jpg'), fit: BoxFit.cover, width: 24, height: 24),
                        ),
                        isShowForward: true,
                      ),
                    ),
                    TapLayout(
                      height: 50.0,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: SingleTextLayout(title: S.of(context).notificationSwitch, suffix: CupertinoSwitch(value: switchState, onChanged: (value) => setState(() => switchState = value))),
                    ),
                    TapLayout(
                      height: 50.0,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      onTap: () => showSelectImageBottomSheet(context),
                      child: SingleTextLayout(title: S.of(context).notificationSwitch, text: '查看通知内容'),
                    ),
                    TapLayout(
                      height: 60.0,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      onTap: () => showListBottomSheet(context, data, (int index) {
                        Navigator.pop(context);
                      }),
                      child: SingleTextLayout(title: S.of(context).loginRecord, summary: '查看最近所有的登录记录', badgeCount: 0, isShowForward: true),
                    ),
                    SizedBox(height: 8),
                    Text(MeModel.of.value),
                    SizedBox(height: 8),
                    TapLayout(
                      height: 48.0,
                      isRipple: false,
                      background: Colors.red,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      onTap: () => showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return ListDialog(
                              list: list,
                              onTap: (index) {},
                            );
                          }),
                      child: Row(
                        children: [Text(S.of(context).login)],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<String> list = [
    "补材料申请",
    "面签申请",
    "暂停申请",
    "提醒",
  ];

  List<String> data = [
    '设置备注和标签',
    '把她推荐给朋友',
    '设为星标好友',
    '设置朋友圈和视频动态权限',
    '加入黑名单',
    '投诉',
    '添加到桌面',
    '删除',
  ];
}
