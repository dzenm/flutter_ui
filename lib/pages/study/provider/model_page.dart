import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../base/base.dart';
import '../study_model.dart';
import 'update_page.dart';

///
/// Created by a0010 on 2023/8/31 16:59
/// Selector和Provider.of监听model数据变化的区别
class ModelPage extends StatelessWidget {
  const ModelPage({super.key});

  static const String _tag = 'ModelPage';

  @override
  Widget build(BuildContext context) {
    log('build');

    AppTheme theme = context.read<LocalModel>().theme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('观察Model数据的变化', style: TextStyle(color: Colors.white)),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                MaterialButton(
                  textColor: Colors.white,
                  color: Colors.blue,
                  onPressed: () => AppRouter.of(context).pushPage(const UpdatePage(id: 1)),
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('修改数据'),
                  ]),
                ),
                _buildTitle('观察使用Selector监听的数据变化', theme),
                const _SelectorWidget(),
                _buildTitle('观察使用Provider监听的数据变化', theme),
                const _ProviderWidget(),
              ]),
            )
          ]),
        ),
      ),
    );
  }

  Widget _buildTitle(String title, AppTheme theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      child: Row(children: [
        Text(title, style: TextStyle(color: theme.primaryText)),
      ]),
    );
  }

  void log(String msg) => Log.p(msg, tag: _tag);
}

/// 通过Selector监听的数据变化
class _SelectorWidget extends StatelessWidget {
  const _SelectorWidget();

  static const String _tag = 'SelectorWidget';

  @override
  Widget build(BuildContext context) {
    log('build');

    // watch 当前widget存在监听的对象有任一细微的变化都会影响build及子widget进行重建
    // 比如监听的是List或者List的其中一个item，如果List的其他item发生变化都会影响监听了List或者List的其中一个item的widget进行重建

    // Selector 只在监听的值改变后发生变化，如果该值未改变，或者对象中的其他值/List的其他index值改变，均不会受到影响

    // 日志测试
    // I/flutter (  338): 2023-09-01 14:26:34 591 P/SelectorWidget  Selector Builder
    return Selector<StudyModel, User?>(
      selector: (_, model) => model.getUser(1),
      builder: (c, user, w) {
        log('Selector Builder');
        return ContentWidget(user: user);
      },
    );
  }

  void log(String msg) => Log.p(msg, tag: _tag);
}

/// 通过Provider监听的数据变化
class _ProviderWidget extends StatelessWidget {
  const _ProviderWidget();

  static const String _tag = 'ProviderWidget';

  @override
  Widget build(BuildContext context) {
    log('build');

    // watch 当前widget存在监听的对象有任一细微的变化都会影响build及子widget进行重建
    // 比如监听的是List或者List的其中一个item，如果List的其他item发生变化都会影响监听了List或者List的其中一个item的widget进行重建

    // 日志测试
    // I/flutter (  338): 2023-09-01 14:26:34 590 P/ProviderWidget  build
    User? user = context.watch<StudyModel>().getUser(1);
    return ContentWidget(user: user);
  }

  void log(String msg) => Log.p(msg, tag: _tag);
}

class ContentWidget extends StatelessWidget {
  final User? user;

  const ContentWidget({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.read<LocalModel>().theme;
    String sex = user?.sex == 0 ? '男' : '女';
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        border: Border.all(color: Colors.blue, width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(
                '${user?.username}(${user?.age}/$sex)',
                style: TextStyle(color: theme.primaryText, fontSize: 16),
              ),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Text('${user?.phone}', style: TextStyle(color: theme.secondaryText)),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Text('${user?.address}', style: TextStyle(color: theme.secondaryText)),
            ]),
          ]),
        )
      ]),
    );
  }
}
