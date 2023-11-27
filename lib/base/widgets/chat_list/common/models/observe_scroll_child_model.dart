import 'package:flutter/material.dart';

import '../observer_controller.dart';

class ObserveScrollChildModel {
  /// The size of child widget.
  double size;

  /// The layout offset of child widget.
  double layoutOffset;

  ObserveScrollChildModel({
    required this.size,
    required this.layoutOffset,
  });
}

class ObserveScrollToIndexFixedHeightResultModel {
  /// The size of item on the main axis.
  double childMainAxisSize;

  /// The separator size between items on the main axis.
  double itemSeparatorHeight;

  /// The number of rows for the target item.
  int indexOfLine;

  /// The offset of the target child widget on the main axis.
  double targetChildLayoutOffset;

  ObserveScrollToIndexFixedHeightResultModel({
    required this.childMainAxisSize,
    required this.itemSeparatorHeight,
    required this.indexOfLine,
    required this.targetChildLayoutOffset,
  });
}

class ObserverIndexPositionModel {
  ObserverIndexPositionModel({
    required this.index,
    this.sliverContext,
    this.isFixedHeight = false,
    this.alignment = 0,
    this.offset,
    this.padding = EdgeInsets.zero,
  });

  /// The index position of the scrollView.
  int index;

  /// The target sliver [BuildContext].
  BuildContext? sliverContext;

  /// If the height of the child widget and the height of the separator are
  /// fixed, please pass [true] to this property.
  bool isFixedHeight;

  /// The [alignment] specifies the desired position for the leading edge of the
  /// child widget.
  ///
  /// It must be a value in the range [0.0, 1.0].
  double alignment;

  /// Use this property when locating position needs an offset.
  ObserverLocateIndexOffsetCallback? offset;

  /// This value is required when the scrollView is wrapped in the
  /// [SliverPadding].
  ///
  /// For example:
  /// 1. ListView.separated(padding: _padding, ...)
  /// 2. GridView.builder(padding: _padding, ...)
  EdgeInsets padding;
}
