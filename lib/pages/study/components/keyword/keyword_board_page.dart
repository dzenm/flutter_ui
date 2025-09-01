import 'package:extended_text_field/extended_text_field.dart';
import 'package:fbl/fbl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../widgets/widgets.dart';

/// 自定义键盘
class KeywordBoardPage extends StatefulWidget {
  const KeywordBoardPage({super.key});

  @override
  State<StatefulWidget> createState() => _KeywordBoardPageState();
}

class _KeywordBoardPageState extends State<KeywordBoardPage> //
    with
        Logging,
        SingleTickerProviderStateMixin {
  final List<String> _license = ['', '', '', '', '', '', ''];
  final LicenseController _licenseController = LicenseController();
  final TextEditingController _textController = TextEditingController(text: "初始化");

  AnimationController? _controller; // 底部Sheet动画进入控制器
  Animation? _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      reverseDuration: const Duration(milliseconds: 250),
      vsync: this,
    );

    Future.delayed(const Duration(seconds: 5), () {
      var data = MediaQuery.maybeOf(context);
      data ??= MediaQueryData.fromView(View.of(context));
      var bottom = data.viewInsets.bottom;
      logDebug("获取抬高键盘的高度：bottom=$bottom");
    });
  }

  double _size = 0.0;
  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch<LocalModel>().theme;

    var data = MediaQuery.maybeOf(context);
    data ??= MediaQueryData.fromView(View.of(context));
    var bottom = data.viewInsets.bottom;
    logDebug("抬高键盘的高度：bottom=$bottom");
    return Scaffold(
      appBar: const CommonBar(
        title: '自定义键盘',
      ),
      resizeToAvoidBottomInset: false,
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            LicenseView(list: _license, controller: _licenseController),
            MaterialButton(
              textColor: Colors.white,
              color: theme.button,
              onPressed: () {
                if (_size >= 0) {
                  double begin = _size;
                  double end = _size + 32;
                  _forward(begin: begin, end: end);
                  _size = end;
                }
              },
              child: _text('放大变化'),
            ),
            const SizedBox(height: 32),
            MaterialButton(
              textColor: Colors.white,
              color: theme.button,
              onPressed: () {
                if (_size > 0) {
                  double begin = _size;
                  double end = _size - 32;
                  _forward(begin: begin, end: end);
                  _size = end;
                }
              },
              child: _text('缩小变化'),
            ),
            const SizedBox(height: 32),
            Container(
              width: _animation?.value,
              height: _animation?.value,
              color: Colors.red,
            ),
            const Expanded(child: SizedBox.shrink()),
            ExtendedTextField(
              controller: _textController,
              specialTextSpanBuilder: MySpecialTextSpanBuilder(showAtBackground: true, type: BuilderType.extendedTextField),
              onChanged: (s) {},
              onEditingComplete: () {},
              onSubmitted: (s) {},
            ),
            const SizedBox(height: 32),
            SizedBox(height: bottom),
          ],
        ),
      ),
    );
  }

  void _forward({required double begin, required double end}) {
    AnimationController? controller = _controller;
    if (controller != null) {
      controller.dispose();
    }
    controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      reverseDuration: const Duration(milliseconds: 250),
      vsync: this,
    );
    CurvedAnimation curvedAnimation = CurvedAnimation(
      parent: controller,
      curve: Curves.linear,
      reverseCurve: Curves.linear,
    );
    _animation = Tween(begin: begin, end: end).animate(curvedAnimation);
    controller.addListener(() => setState(() {}));
    controller.forward();
    _controller = controller;
  }


  Widget _text(String text) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(text)]);
  }
}
