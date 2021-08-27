import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ui/base/res/strings.dart';

import 'tap_layout.dart';

/// 状态展示
class FooterView extends StatefulWidget {
  final FooterState state;
  final GestureTapCallback? onTap;
  final Widget? title;
  final Widget? image;
  final double loadingProgressSize;

  FooterView({
    Key? key,
    this.state = FooterState.none,
    this.onTap,
    this.title,
    this.image,
    this.loadingProgressSize = 24,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FooterViewState();
}

class _FooterViewState extends State<FooterView> {
  @override
  Widget build(BuildContext context) {
    return Offstage(
      offstage: widget.state == FooterState.none,
      child: TapLayout(
        height: 56,
        onTap: widget.onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: _stateView(widget.loadingProgressSize),
        ),
      ),
    );
  }

  List<Widget> _stateView(double size) {
    FooterState state = widget.state;
    return [
      Offstage(
        offstage: state != FooterState.loading,
        child: Container(
          width: size,
          height: size,
          child: CircularProgressIndicator(),
        ),
      ),
      SizedBox(width: 16, height: 32),
      widget.title == null ? Text(footerText(state)) : widget.title!,
    ];
  }

  String footerText(FooterState state) {
    switch (state) {
      case FooterState.none:
        return S.of.none;
      case FooterState.loading:
        return S.of.loading;
      case FooterState.more:
        return S.of.loadMore;
      case FooterState.failed:
        return S.of.loadFailed;
      case FooterState.end:
        return S.of.loadEnd;
    }
  }
}

/// 底部数据的状态
enum FooterState {
  none,
  loading,
  failed,
  more, // 底部显示，加载部分页数，还有更多页面可以加载
  end, // 底部显示，加载数据完成，没有数据可以加载
}
