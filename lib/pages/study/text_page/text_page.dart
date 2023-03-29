import 'package:bot_toast/bot_toast.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ui/base/log/log.dart';
import 'package:flutter_ui/base/res/assets.dart';
import 'package:flutter_ui/base/router/route_manager.dart';
import 'package:flutter_ui/base/widgets/badge_view.dart';
import 'package:flutter_ui/base/widgets/common_dialog.dart';
import 'package:flutter_ui/base/widgets/common_widget.dart';
import 'package:flutter_ui/base/widgets/extend_text/my_special_text_span_builder.dart';
import 'package:flutter_ui/base/widgets/keyboard/custom_keyword_board.dart';
import 'package:flutter_ui/base/widgets/keyboard/keyboard_media_query.dart';
import 'package:flutter_ui/base/widgets/menu_Item.dart';
import 'package:flutter_ui/base/widgets/single_edit_layout.dart';
import 'package:flutter_ui/base/widgets/single_text_layout.dart';
import 'package:flutter_ui/base/widgets/slide_verify_view.dart';
import 'package:flutter_ui/base/widgets/tap_layout.dart';
import 'package:flutter_ui/base/widgets/will_pop_view.dart';
import 'package:flutter_ui/pages/study/setting_page/setting_page.dart';

import '../../../generated/l10n.dart';

/// 文本展示测试页面
class TextPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TextPageState();
}

class _TextPageState extends State<TextPage> {
  static const String _tag = 'TextPage';
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

    Log.i('initState', tag: _tag);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Log.i('didChangeDependencies', tag: _tag);
  }

  @override
  void didUpdateWidget(covariant TextPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    Log.i('didUpdateWidget', tag: _tag);
  }

  @override
  void deactivate() {
    super.deactivate();
    Log.i('deactivate', tag: _tag);
  }

  @override
  void dispose() {
    super.dispose();
    Log.i('dispose', tag: _tag);

    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardMediaQuery(
      //用于键盘弹出的时候页面可以滚动到输入框的位置
      child: WillPopView(
        onWillPop: () => WillPopView.promptBack(context, isChanged: text != newText),
        child: Scaffold(
          appBar: AppBar(
            title: Text('文本和输入框', style: TextStyle(color: Colors.white)),
            actions: [
              /// 弹出式菜单
              PopupMenuButton(
                elevation: 4.0,
                onSelected: (Item item) {
                  CommonDialog.showToast(item.title ?? '');
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
                    CommonWidget.titleView('无边框带字数控制的输入框: '),
                    SingleEditLayout(
                      title: '账户',
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
                    CommonWidget.titleView('输入框的特殊表情: '),
                    Text(
                      '特殊小技巧，试试输入\'[a]\', \'[b]\', \'[c]\', \'[d]\', \'[e]\'',
                      style: TextStyle(fontSize: 10),
                    ),
                    ExtendedTextField(
                      specialTextSpanBuilder: MySpecialTextSpanBuilder(showAtBackground: true, type: BuilderType.extendedTextField),
                    ),
                    CommonWidget.divider(),
                    SizedBox(height: 24),
                    CommonWidget.titleView('输入框的特殊表情: '),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: SlideVerifyView(
                        slideColor: Colors.green,
                        backgroundColor: Color(0xFFE5E5E5),
                        borderColor: Color(0xFFE5E5E5),
                        onChanged: () async => CommonDialog.showToast('验证成功'),
                      ),
                    ),
                    SizedBox(height: 24),
                    CommonWidget.titleView('自适应宽度使用: '),
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
                    CommonWidget.divider(),
                    SizedBox(height: 24),
                    CommonWidget.titleView('设置页面常用单行布局: '),
                    TapLayout(
                      height: 50.0,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      onTap: () => RouteManager.push(context, SettingPage()),
                      child: SingleTextLayout(title: S.of(context).setting, isShowForward: true, prefix: BadgeView(count: 10)),
                    ),
                    TapLayout(
                      height: 50.0,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      // onTap: () => MeModel.of.setValue('new value'),
                      child: SingleTextLayout(title: S.of(context).phone, text: '17601487212', isTextLeft: false, isShowForward: true),
                    ),
                    TapLayout(
                      height: 50.0,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      onTap: () => CommonDialog.showPromptDialog(
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
                        CancelFunc cancel = CommonDialog.loading();
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
                      // onTap: () => CommonDialog.showPromptDialog(context, titleString: '确定要退出系统了吗？', onPositiveTap: () => CommonDialog.CommonDialog.showToast('修改成功')),
                      onTap: () => CommonDialog.showPromptDialog(context, titleString: '昵称', content: Text('这是设置好的昵称'), onPositiveTap: () => CommonDialog.showToast('修改成功')),
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
                      child: SingleTextLayout(title: '通知切换', suffix: CupertinoSwitch(value: switchState, onChanged: (value) => setState(() => switchState = value))),
                    ),
                    TapLayout(
                      height: 50.0,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      onTap: () => CommonDialog.showSelectImageBottomSheet(context),
                      child: SingleTextLayout(title: '通知切换', text: '查看通知内容'),
                    ),
                    TapLayout(
                      height: 60.0,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      onTap: () => CommonDialog.showListBottomSheet(context, data, (int index) {
                        RouteManager.pop(context);
                      }),
                      child: SingleTextLayout(title: '登陆记录', summary: '查看最近所有的登录记录', badgeCount: 0, isShowForward: true),
                    ),
                    SizedBox(height: 8),
                    // Text(MeModel.of.value),
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
