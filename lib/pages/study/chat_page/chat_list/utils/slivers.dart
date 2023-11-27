import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class SliverObserveContextToBoxAdapter extends SliverToBoxAdapter {
  final void Function(BuildContext) onObserve;

  const SliverObserveContextToBoxAdapter({
    super.key,
    required super.child,
    required this.onObserve,
  });

  @override
  RenderSliverToBoxAdapter createRenderObject(BuildContext context) {
    onObserve.call(context);
    return super.createRenderObject(context);
  }
}
