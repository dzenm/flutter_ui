import 'package:flutter/material.dart';

import '../res/strings.dart';
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
      offstage: widget.controller.none,
      child: widget.controller.init && widget.child != null
          ? widget.child
          : TapLayout(
              onTap: widget.controller.load ? null : widget.onTap,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: _stateView(context, widget.controller, 56, widget.title, image: widget.image),
              ),
            ),
    );
  }

  static List<Widget> _stateView(
    BuildContext context,
    StateController controller,
    double size,
    Widget? title, {
    Widget? image,
  }) {
    return [
      // 加载进度提示
      Offstage(
        offstage: !controller.load,
        child: Container(
          width: size,
          height: size,
          child: CircularProgressIndicator(),
        ),
      ),
      // 加载不成功的图片展示
      Offstage(
        offstage: !(!controller.more && (controller.empty || controller.failed)),
        child: image,
      ),
      SizedBox(width: 16, height: 32),
      // 加载展示的文本信息
      title ?? Text(controller.stateText(context)),
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
    // 未初始化/为空 不展示底部状态
    bool offstage = !widget.controller.init || widget.controller.none;
    return Offstage(
      offstage: offstage,
      child: TapLayout(
        height: 56,
        onTap: widget.onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: _StateViewState._stateView(
            context,
            widget.controller,
            widget.loadingProgressSize,
            widget.title,
          ),
        ),
      ),
    );
  }
}

/// 状态控制器
class StateController with ChangeNotifier {
  LoadState initialState;
  bool isShowFooterState;
  bool _isInit = false;
  bool _isMore = false;

  StateController({
    this.initialState = LoadState.loading,
    this.isShowFooterState = true,
  });

  void loadNone() {
    initialState = LoadState.none;
    notifyListeners();
  }

  void loading() {
    initialState = LoadState.loading;
    notifyListeners();
  }

  void loadEmpty() {
    initialState = _isMore && isShowFooterState ? LoadState.end : LoadState.empty;
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
    if (_isInit) return;
    _isInit = true;
    initialState = LoadState.complete;
    notifyListeners();
  }

  void loadMore() {
    if (!_isInit) return;
    _isMore = true;
    initialState = LoadState.more;
    notifyListeners();
  }

  void reset() {
    _isInit = false;
    _isMore = false;
    notifyListeners();
  }

  String stateText(BuildContext context) {
    switch (initialState) {
      case LoadState.none:
        return S.of(context).none;
      case LoadState.loading:
        return S.of(context).loading;
      case LoadState.empty:
        return S.of(context).loadEmpty;
      case LoadState.success:
        return S.of(context).loadSuccess;
      case LoadState.complete:
        return S.of(context).loadComplete;
      case LoadState.failed:
        return S.of(context).loadFailed;
      case LoadState.more:
        return S.of(context).loadMore;
      case LoadState.end:
        return S.of(context).loadEnd;
    }
  }

  LoadState get state => initialState;

  bool get none => initialState == LoadState.none;

  bool get init => _isInit;

  bool get load => initialState == LoadState.loading;

  bool get empty => initialState == LoadState.empty;

  bool get failed => initialState == LoadState.failed;

  bool get more => _isMore;
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
