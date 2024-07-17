import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ui/base/a_router/misc/extensions.dart';

import '../../../../base/base.dart';
import '../../../../generated/l10n.dart';
import '../../../main/me/me_router.dart';

/// 文本展示测试页面
class TextPage extends StatefulWidget {
  const TextPage({super.key});

  @override
  State<StatefulWidget> createState() => _TextPageState();
}

class _TextPageState extends State<TextPage> {
  static const String _tag = 'TextPage';
  final TextEditingController _controller = TextEditingController(text: "初始化");
  String text = '';
  String newText = '';
  bool switchState = true;
  bool isChanged = false;

  @override
  void initState() {
    super.initState();

    log('initState');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    log('didChangeDependencies');
  }

  @override
  void didUpdateWidget(covariant TextPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    log('didUpdateWidget');
  }

  @override
  void deactivate() {
    super.deactivate();
    log('deactivate');
  }

  @override
  void dispose() {
    super.dispose();
    log('dispose');

    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardMediaQuery(
      //用于键盘弹出的时候页面可以滚动到输入框的位置
      child: WillPopView(
        onPopInvoked: (didPop) => WillPopView.promptBack(context, isChanged: text != newText),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('文本和输入框', style: TextStyle(color: Colors.white)),
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CommonWidget.titleView('无边框带字数控制的输入框: '),
                SingleEditView(
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
                  padding: const EdgeInsets.all(8),
                  height: 80,
                  alignment: Alignment.topLeft,
                  child: Row(children: [Text(newText, maxLines: 4, style: const TextStyle(color: Colors.white))]),
                ),
                const SizedBox(height: 8),
                CommonWidget.titleView('输入框的特殊表情: '),
                const Text(
                  '特殊小技巧，试试输入\'[a]\', \'[b]\', \'[c]\', \'[d]\', \'[e]\'',
                  style: TextStyle(fontSize: 10),
                ),
                ExtendedTextField(
                  specialTextSpanBuilder: MySpecialTextSpanBuilder(showAtBackground: true, type: BuilderType.extendedTextField),
                ),
                CommonWidget.divider(),
                const SizedBox(height: 24),
                CommonWidget.titleView('输入框的特殊表情: '),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: SlideVerifyView(
                    slideColor: Colors.green,
                    backgroundColor: const Color(0xFFE5E5E5),
                    borderColor: const Color(0xFFE5E5E5),
                    onChanged: () async => CommonDialog.showToast('验证成功'),
                  ),
                ),
                const SizedBox(height: 24),
                CommonWidget.titleView('自适应宽度使用: '),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Flexible(child: Text('Row包含一个文本，两个图标，给所有子widget设置Expand的，这是长文本的效果', maxLines: 1, overflow: TextOverflow.ellipsis)),
                    Icon(Icons.add_photo_alternate_outlined),
                    Icon(Icons.info),
                  ],
                ),
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Flexible(child: Text('短文本和图标', maxLines: 1, overflow: TextOverflow.ellipsis)),
                    Icon(Icons.add_photo_alternate_outlined),
                    Icon(Icons.info),
                  ],
                ),
                const SizedBox(height: 8),
                CommonWidget.divider(),
                const SizedBox(height: 24),
                CommonWidget.titleView('设置页面常用单行布局: '),
                TapLayout(
                  height: 50.0,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  onTap: () => context.pushNamed(MeRouter.setting),
                  child: SingleTextView(
                    title: S.of(context).setting,
                    isShowForward: true,
                    prefix: const BadgeTag(count: 10),
                  ),
                ),
                TapLayout(
                  height: 50.0,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SingleTextView(
                    title: S.of(context).phone,
                    text: '17601487212',
                    textAlign: TextAlign.right,
                    isShowForward: true,
                  ),
                ),
                TapLayout(
                  height: 50.0,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: const SingleTextView(
                    icon: Icons.date_range_outlined,
                    title: '生日',
                    text: '1997/2/12',
                    textAlign: TextAlign.right,
                    isShowForward: true,
                  ),
                ),
                TapLayout(
                  height: 50.0,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: const SingleTextView(
                    icon: Icons.adb,
                    title: '关于',
                    textAlign: TextAlign.right,
                    isShowForward: true,
                    badgeCount: 0,
                  ),
                ),
                TapLayout(
                  height: 50.0,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SingleTextView(
                    icon: Icons.person,
                    title: S.of(context).avatar,
                    textAlign: TextAlign.right,
                    suffix: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        Assets.a,
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
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SingleTextView(
                    title: '通知切换',
                    suffix: CupertinoSwitch(
                      value: switchState,
                      onChanged: (value) => setState(() => switchState = value),
                    ),
                  ),
                ),
                TapLayout(
                  height: 50.0,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: const SingleTextView(title: '通知切换', text: '查看通知内容'),
                ),
                TapLayout(
                  height: 60.0,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: const SingleTextView(
                    title: '登陆记录',
                    summary: '查看最近所有的登录记录',
                    badgeCount: 0,
                    isShowForward: true,
                  ),
                ),
                const SizedBox(height: 24),
                CommonWidget.titleView('自适应文字大小: '),
                const AdapterSizeText(
                  '道可道，非常道。名可名，非常名。',
                  style: TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 8),
                const AdapterSizeText(
                  '无名，天地之始，有名，万物之母。',
                  style: TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 8),
                const AdapterSizeText(
                  '故常无欲，以观其妙，常有欲，以观其徼。',
                  style: TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 8),
                const AdapterSizeText(
                  '此两者，同出而异名，同谓之玄，玄之又玄，众妙之门。',
                  style: TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  void log(String msg) => Log.p(msg, tag: _tag);
}
