import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import 'tap_layout.dart';

/// 状态展示
class StateView extends StatelessWidget {
  final Widget? child;
  final Color? color;
  final StateController controller;
  final GestureTapCallback? onTap;
  final Widget? title;
  final Widget? image;

  const StateView({
    super.key,
    this.child,
    this.color,
    required this.controller,
    this.onTap,
    this.title,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    if (controller.none) return Container();
    if (controller.init && child != null) return child!;
    return TapLayout(
      onTap: controller.load ? null : onTap,
      background: color,
      child: LinearStateView(
        controller: controller,
        size: 56,
        title: title,
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
  final Widget? image;
  final double loadingProgressSize;

  const FooterStateView({
    super.key,
    required this.controller,
    this.onTap,
    this.title,
    this.image,
    this.loadingProgressSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    // 未初始化/为空 不展示底部状态
    bool offstage = !controller.init || controller.none;
    return Offstage(
      offstage: offstage,
      child: TapLayout(
        height: 56,
        onTap: onTap,
        child: LinearStateView(
          controller: controller,
          size: loadingProgressSize,
          title: title,
          isVertical: true,
        ),
      ),
    );
  }
}

/// 主要控制的状态展示
class LinearStateView extends StatelessWidget {
  final StateController controller;
  final double size;
  final Widget? title;
  final Widget? image;
  final bool isVertical;

  const LinearStateView({super.key,
    required this.controller,
    required this.size,
    this.title,
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
    if (controller.load) {
      widgets.add(SizedBox(
        width: size,
        height: size,
        child: const CircularProgressIndicator(),
      ));
    }
    // 加载不成功的图片展示，只展示空白和失败的时候的图片
    if (!controller.more && (controller.empty || controller.failed) && image != null) {
      widgets.add(image!);
    }
    // 图片和文本之间的间距
    widgets.add(const SizedBox(width: 16, height: 32));
    // 加载展示的文本信息
    widgets.add(title ?? Text(controller.stateText(context)));
    return widgets;
  }
}

/// 状态控制器
class StateController with ChangeNotifier {
  LoadState initialState;
  bool isShowFooterState;
  bool _isInit = false;
  bool _isMore = false;

  LoadState _state = LoadState.loading;

  StateController({
    this.initialState = LoadState.loading,
    this.isShowFooterState = true,
  }) {
    _state = initialState;
  }

  void loadNone() {
    _state = LoadState.none;
    notifyListeners();
  }

  void loading() {
    _state = LoadState.loading;
    notifyListeners();
  }

  void loadEmpty() {
    _state = _isMore && isShowFooterState ? LoadState.end : LoadState.empty;
    notifyListeners();
  }

  void loadSuccess() {
    _state = LoadState.success;
    notifyListeners();
  }

  void loadFailed() {
    _state = LoadState.failed;
    notifyListeners();
  }

  void loadComplete() {
    if (_isInit) return;
    _isInit = true;
    _state = LoadState.complete;
    notifyListeners();
  }

  void loadMore() {
    if (!_isInit) return;
    _isMore = true;
    _state = LoadState.more;
    notifyListeners();
  }

  void reset() {
    _isInit = false;
    _isMore = false;
    notifyListeners();
  }

  String stateText(BuildContext context) {
    switch (_state) {
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

  LoadState get state => _state;

  bool get none => _state == LoadState.none;

  bool get init => _isInit;

  bool get load => _state == LoadState.loading;

  bool get empty => _state == LoadState.empty;

  bool get failed => _state == LoadState.failed;

  bool get more => _isMore;
}

/// 加载数据的状态
enum LoadState {
  none(0), // 什么都不做
  loading(1), // 加载中，正在请求数据
  empty(2), // 加载为空数据
  failed(3), // 加载错误
  success(4), // 加载成功
  complete(5), // 加载完成
  more(6), // 底部显示，加载部分页数，还有更多页面可以加载
  end(7); // 底部显示，加载数据完成，没有数据可以加载

  final int value;

  const LoadState(this.value);
}
