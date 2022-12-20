import 'package:flutter/material.dart';
import 'package:flutter_ui/base/model/local_model.dart';
import 'package:flutter_ui/base/res/colors.dart';
import 'package:flutter_ui/base/router/route_manager.dart';
import 'package:flutter_ui/base/widgets/tap_layout.dart';
import 'package:provider/provider.dart';

///
/// Created by a0010 on 2022/3/28 16:28
///
class UpgradeDialog extends StatelessWidget {
  final String version; // 展示的新版本号
  final List<String> desc; // 展示新版本更新的描述信息
  final GestureTapCallback? onTap;

  UpgradeDialog({
    Key? key,
    required this.version,
    required this.desc,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch<LocalModel>().appTheme;
    return Container(
      decoration: BoxDecoration(
        color: theme.white,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 16),
        // 版本号
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Flexible(
            child: RichText(
              text: TextSpan(
                text: '新版本',
                style: TextStyle(color: theme.primaryText, fontSize: 18),
                children: [TextSpan(text: version)],
              ),
            ),
          )
        ]),
        const SizedBox(height: 16),

        // 更新的具体内容
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: desc.map((value) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(value, style: TextStyle(color: theme.secondaryText, height: 2)),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        // 分割线
        Container(
          height: 0.5,
          color: theme.hintText,
        ),

        // 取消和升级按钮
        Row(children: [
          Expanded(
            child: TapLayout(
              height: 48,
              child: Text('关闭', style: TextStyle(color: theme.secondaryText)),
              onTap: () => RouteManager.pop(context),
            ),
            flex: 1,
          ),
          Expanded(
            child: TapLayout(
              height: 48,
              background: theme.primary,
              child: Text('立即升级', style: TextStyle(color: theme.white)),
              onTap: onTap,
            ),
            flex: 1,
          ),
        ]),
      ]),
    );
  }
}
