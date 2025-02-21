import 'package:flutter/rendering.dart';

abstract class ObserveDisplayingChildModel {
  /// The target sliverList.
  RenderSliver sliver;

  /// The viewport of sliver.
  RenderViewportBase viewport;

  /// The index of child widget.
  int index;

  /// The renderObject [RenderBox] of child widget.
  RenderBox renderObject;

  ObserveDisplayingChildModel({
    required this.sliver,
    required this.viewport,
    required this.index,
    required this.renderObject,
  });
}
