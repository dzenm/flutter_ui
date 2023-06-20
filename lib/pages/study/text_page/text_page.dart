import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ui/pages/main/me_page/me_router.dart';

import '../../../base/log/log.dart';
import '../../../base/res/assets.dart';
import '../../../base/route/app_route_delegate.dart';
import '../../../base/widgets/adapter_size_text.dart';
import '../../../base/widgets/badge_tag.dart';
import '../../../base/widgets/common_dialog.dart';
import '../../../base/widgets/common_widget.dart';
import '../../../base/widgets/extend_text/my_special_text_span_builder.dart';
import '../../../base/widgets/keyboard/custom_keyword_board.dart';
import '../../../base/widgets/keyboard/keyboard_media_query.dart';
import '../../../base/widgets/single_edit_layout.dart';
import '../../../base/widgets/single_text_layout.dart';
import '../../../base/widgets/slide_verify_view.dart';
import '../../../base/widgets/tap_layout.dart';
import '../../../base/widgets/will_pop_view.dart';
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
          ),
          body: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                  onTap: () => AppRouteDelegate.of(context).push(MeRouter.setting),
                  child: SingleTextLayout(
                    title: S.of(context).setting,
                    isShowForward: true,
                    prefix: BadgeTag(count: 10),
                  ),
                ),
                TapLayout(
                  height: 50.0,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SingleTextLayout(
                    title: S.of(context).phone,
                    text: '17601487212',
                    isTextLeft: false,
                    isShowForward: true,
                  ),
                ),
                TapLayout(
                  height: 50.0,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SingleTextLayout(
                    icon: Icons.date_range_outlined,
                    title: '生日',
                    text: '1997/2/12',
                    isTextLeft: false,
                    isShowForward: true,
                  ),
                ),
                TapLayout(
                  height: 50.0,
                  padding: EdgeInsets.symmetric(horizontal: 16),
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
                  child: SingleTextLayout(
                    icon: Icons.person,
                    title: S.of(context).avatar,
                    isTextLeft: false,
                    suffix: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        Assets.image('a.jpg'),
                        fit: BoxFit.cover,
                        width: 24,
                        height: 24,
                      ),
                    ),
                    isShowForward: true,
                  ),
                ),
                TapLayout(
                  height: 50.0,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SingleTextLayout(
                    title: '通知切换',
                    suffix: CupertinoSwitch(
                      value: switchState,
                      onChanged: (value) => setState(() => switchState = value),
                    ),
                  ),
                ),
                TapLayout(
                  height: 50.0,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SingleTextLayout(title: '通知切换', text: '查看通知内容'),
                ),
                TapLayout(
                  height: 60.0,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SingleTextLayout(
                    title: '登陆记录',
                    summary: '查看最近所有的登录记录',
                    badgeCount: 0,
                    isShowForward: true,
                  ),
                ),
                SizedBox(height: 24),
                CommonWidget.titleView('自适应文字大小: '),
                Container(
                  child: AdapterSizeText(
                    '道可道，非常道。名可名，非常名。',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  child: AdapterSizeText(
                    '无名，天地之始，有名，万物之母。',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  child: AdapterSizeText(
                    '故常无欲，以观其妙，常有欲，以观其徼。',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  child: AdapterSizeText(
                    '此两者，同出而异名，同谓之玄，玄之又玄，众妙之门。',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                SizedBox(height: 24),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
