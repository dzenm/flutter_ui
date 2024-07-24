import 'package:flutter/material.dart';

import 'tap_layout.dart';

///
/// 状态展示
/// 使用 [StateController] 控制状态的展示
/// StateView(
///   controller: _controller,
///   image: Image.asset(_image, fit: BoxFit.cover, width: 96, height: 96),
///   child: const Center(
///      child: Text('展示成功页面'),
///   ),
/// )
/// 使用 [LoadState] 控制状态的展示
/// StateView(
///   color: isEmpty ? ColorConst.white : ColorConst.toolbar_color,
///   image: Image.asset(Assets.noMsg, width: 128, height: 128),
///   text: const Text('暂无任何消息~', style: TextStyle(color: ColorConst.txt_gray)),
///   state: isEmpty ? LoadState.empty : LoadState.complete,
/// )
class StateView extends StatelessWidget {
  final Widget? child;
  final StateController? controller;
  final LoadState state;
  final Color? color;
  final GestureTapCallback? onTap;
  final Widget? text;
  final Widget? image;

  StateView({
    super.key,
    this.child,
    this.controller,
    LoadState? state,
    this.color,
    this.onTap,
    this.text,
    this.image,
  })  : assert(state == null || controller == null, 'You can only pass state or controller, not both.'),
        state = state ?? controller!.state;

  static String getStateText(BuildContext context, LoadState state) {
    return state.name;
    // switch (state) {
    //   case LoadState.none:
    //     return S.of(context).none;
    //   case LoadState.loading:
    //     return S.of(context).loading;
    //   case LoadState.empty:
    //     return S.of(context).loadEmpty;
    //   case LoadState.success:
    //     return S.of(context).loadSuccess;
    //   case LoadState.complete:
    //     return S.of(context).loadComplete;
    //   case LoadState.failed:
    //     return S.of(context).loadFailed;
    //   case LoadState.sliding:
    //     return S.of(context).keepSliding;
    //   case LoadState.more:
    //     return '${S.of(context).releaseFinger}, ${S.of(context).loadMore}';
    //   case LoadState.end:
    //     return S.of(context).loadEnd;
    // }
  }

  @override
  Widget build(BuildContext context) {
    LoadState state = controller?.state ?? this.state;
    bool showChild = false;
    if (controller != null) {
      showChild = controller!.isInit || controller!.isMore;
    } else {
      showChild = [LoadState.complete, LoadState.success].contains(state);
    }
    if (showChild && child != null) {
      return child!;
    }
    return TapLayout(
      onTap: state == LoadState.loading ? null : onTap,
      background: color,
      foreground: Colors.transparent,
      child: LinearStateView(
        state: state,
        size: 56,
        text: text,
        image: image,
        isVertical: false,
      ),
    );
  }
}

/// 底部状态展示
class FooterStateView extends StatelessWidget {
  final StateController controller;
  final GestureTapCallback? onTap;
  final Widget? title;
  final Widget? text;
  final double loadingProgressSize;

  const FooterStateView({
    super.key,
    required this.controller,
    this.onTap,
    this.title,
    this.text,
    this.loadingProgressSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    // 展示底部状态只在以下四种情况展示，否则不予展示
    bool showFooter = [
      LoadState.sliding,
      LoadState.loading,
      LoadState.more,
      LoadState.failed,
      LoadState.end,
    ].contains(controller.state);
    bool offstage = controller.isInit && showFooter;
    return Offstage(
      offstage: !offstage,
      child: TapLayout(
        height: 56,
        onTap: onTap,
        child: LinearStateView(
          state: controller.state,
          size: loadingProgressSize,
          text: text,
          isVertical: true,
        ),
      ),
    );
  }
}

/// 主要控制的状态展示
class LinearStateView extends StatelessWidget {
  final LoadState state;
  final double size;
  final Widget? text;
  final Widget? image;
  final bool isVertical;

  const LinearStateView({
    super.key,
    required this.state,
    required this.size,
    this.text,
    this.image,
    required this.isVertical,
  });

  @override
  Widget build(BuildContext context) {
    if (isVertical) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: _buildStateView(context),
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: _buildStateView(context),
    );
  }

  List<Widget> _buildStateView(BuildContext context) {
    List<Widget> widgets = [];
    // 加载进度提示
    if (state == LoadState.loading) {
      widgets.add(SizedBox(
        width: size,
        height: size,
        child: const CircularProgressIndicator(),
      ));
    }
    // 不是底部加载时，展示提示图片
    if (state != LoadState.more && image != null) {
      if ([LoadState.empty, LoadState.failed, LoadState.complete, LoadState.success].contains(state)) {
        widgets.add(image!);
      }
    }
    // 图片和文本之间的间距
    widgets.add(const SizedBox(width: 16, height: 32));
    // 加载展示的文本信息
    widgets.add(text ?? Text(StateView.getStateText(context, state)));
    return widgets;
  }
}

/// 状态控制器，初始化 [LoadState] 使用 [initialState] ，需要不想通过 [StateController] 的其他方法
/// 改变状态直接初始化请将 [isInit] 设置为true
class StateController {
  bool _isMore = false;
  bool _isInit = false;

  LoadState _state = LoadState.loading;

  StateController({
    LoadState initialState = LoadState.loading,
  }) : _state = initialState;

  void loadNone() {
    _state = LoadState.none;
  }

  void loading() {
    _state = LoadState.loading;
  }

  void loadEmpty() {
    _state = _isMore ? LoadState.end : LoadState.empty;
  }

  void loadSuccess() {
    _isInit = true;
    _state = LoadState.success;
  }

  void loadFailed() {
    _state = LoadState.failed;
  }

  void loadComplete() {
    if (_isInit) return;
    _isInit = true;
    _state = LoadState.complete;
  }

  void loadSliding() {
    if (!_isInit || !_isMore) return;
    _state = LoadState.sliding;
  }

  void loadMore() {
    _isInit = true;
    _isMore = true;
    _state = LoadState.more;
  }

  LoadState get state => _state;

  bool get isNone => _state == LoadState.none;

  bool get isInit => _isInit;

  bool get isLoading => _state == LoadState.loading;

  bool get isEmpty => _state == LoadState.empty;

  bool get isMore => _isMore;
}

/// 加载数据的状态
enum LoadState {
  none(0), // 什么都不做
  loading(1), // 加载中，正在请求数据
  empty(2), // 加载为空数据
  failed(3), // 加载错误
  success(4), // 加载成功
  complete(5), // 加载完成
  sliding(6), // 滑动正在进行时
  more(7), // 底部显示，加载部分页数，还有更多页面可以加载
  end(8); // 底部显示，加载数据完成，没有数据可以加载

  final int value;

  const LoadState(this.value);
}