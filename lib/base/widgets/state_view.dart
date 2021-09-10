import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ui/base/res/strings.dart';

import 'tap_layout.dart';

/// 状态展示
class StateView extends StatefulWidget {
  final Widget? child;
  final StateController controller;
  final GestureTapCallback? onTap;
  final Widget? title;
  final Widget? image;

  StateView({
    Key? key,
    this.child,
    required this.controller,
    this.onTap,
    this.title,
    this.image,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _StateViewState();
}

class _StateViewState extends State<StateView> {
  @override
  Widget build(BuildContext context) {
    return Offstage(
      offstage: widget.controller.state == LoadState.none,
      child: widget.controller.isLoadMore() && widget.child != null
          ? widget.child
          : TapLayout(
              onTap: widget.controller.isLoading() ? null : widget.onTap,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: _stateView(56),
              ),
            ),
    );
  }

  List<Widget> _stateView(double size) {
    return [
      Offstage(
        offstage: !widget.controller.isLoading(),
        child: Container(
          width: size,
          height: size,
          child: CircularProgressIndicator(),
        ),
      ),
      Offstage(
        offstage: widget.controller.state != LoadState.empty && widget.controller.state != LoadState.failed,
        child: widget.image,
      ),
      SizedBox(width: 16, height: 32),
      widget.title == null ? Text(widget.controller.stateText()) : widget.title!,
    ];
  }
}

/// 底部状态展示
class FooterStateView extends StatefulWidget {
  final StateController controller;
  final GestureTapCallback? onTap;
  final Widget? title;
  final Widget? image;
  final double loadingProgressSize;

  FooterStateView({
    Key? key,
    required this.controller,
    this.onTap,
    this.title,
    this.image,
    this.loadingProgressSize = 24,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FooterViewState();
}

class _FooterViewState extends State<FooterStateView> {
  @override
  Widget build(BuildContext context) {
    return Offstage(
      offstage: widget.controller.state == LoadState.none || !widget.controller.isLoadMore(),
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
    return [
      Offstage(
        offstage: !widget.controller.isLoading(),
        child: Container(
          width: size,
          height: size,
          child: CircularProgressIndicator(),
        ),
      ),
      SizedBox(width: 16, height: 32),
      widget.title == null ? Text(widget.controller.stateText()) : widget.title!,
    ];
  }
}

/// 状态控制器
class StateController extends ChangeNotifier {
  LoadState initialState;
  bool _isInit = false;
  bool isShowFooterState;

  StateController({
    this.initialState = LoadState.loading,
    this.isShowFooterState = true,
  });

  LoadState get state => initialState;

  void loadNone() {
    initialState = LoadState.none;
    notifyListeners();
  }

  void loading() {
    initialState = LoadState.loading;
    notifyListeners();
  }

  void loadEmpty() {
    if (isShowFooterState) {
      initialState = !_isInit ? LoadState.empty : LoadState.end;
    } else {
      initialState = LoadState.empty;
    }
    notifyListeners();
  }

  void loadSuccess() {
    initialState = LoadState.success;
    notifyListeners();
  }

  void loadFailed() {
    initialState = LoadState.failed;
    notifyListeners();
  }

  void loadComplete() {
    if (initialState != LoadState.complete && !_isInit) {
      initialState = LoadState.complete;
      _isInit = true;
    }
    notifyListeners();
  }

  void loadMore() {
    initialState = LoadState.more;
    notifyListeners();
  }

  String stateText() {
    switch (initialState) {
      case LoadState.none:
        return S.of.none;
      case LoadState.loading:
        return S.of.loading;
      case LoadState.empty:
        return S.of.loadEmpty;
      case LoadState.success:
        return S.of.loadSuccess;
      case LoadState.complete:
        return S.of.loadComplete;
      case LoadState.failed:
        return S.of.loadFailed;
      case LoadState.more:
        return S.of.loadMore;
      case LoadState.end:
        return S.of.loadEnd;
    }
  }

  bool isLoadMore() => _isInit;

  bool isLoading() => initialState == LoadState.loading;
}

/// 加载数据的状态
enum LoadState {
  none, // 什么都不做
  loading, // 加载中，正在请求数据
  empty, // 加载为空数据
  success, // 加载成功
  complete, // 加载完成
  failed, // 加载错误
  more, // 底部显示，加载部分页数，还有更多页面可以加载
  end, // 底部显示，加载数据完成，没有数据可以加载
}
