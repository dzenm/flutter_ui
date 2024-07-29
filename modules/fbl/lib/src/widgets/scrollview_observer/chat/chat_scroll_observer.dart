import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../listview/list_observer_controller.dart';
import '../listview/models/listview_observe_displaying_child_model.dart';
import '../observer/observer_controller.dart';
import '../observer_utils.dart';
import 'chat_scroll_observer_model.dart';

class ChatScrollObserver {
  ChatScrollObserver(this.observerController) {
    // Ensure isShrinkWrap is correct at the end of this frame.
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      observeSwitchShrinkWrap();
    });
  }

  /// Used to obtain the necessary child widget information.
  final ListObserverController observerController;

  /// Whether a fixed position is required.
  bool get isNeedFixedPosition => innerIsNeedFixedPosition;
  bool innerIsNeedFixedPosition = false;

  /// The index of the reference.
  int get refItemIndex => innerRefItemIndex;
  int innerRefItemIndex = 0;

  /// The index of the reference after ScrollView children update.
  int get refItemIndexAfterUpdate => innerRefItemIndexAfterUpdate;
  int innerRefItemIndexAfterUpdate = 0;

  /// The [layoutOffset] of the reference.
  double get refItemLayoutOffset => innerRefItemLayoutOffset;
  double innerRefItemLayoutOffset = 0;

  /// Control the [shrinkWrap] properties of the external scroll view.
  bool get isShrinkWrap => innerIsShrinkWrap;
  bool innerIsShrinkWrap = true;

  /// Whether is remove chat data.
  bool isRemove = false;

  /// The number of messages added.
  int changeCount = 1;

  /// The current chat location is retained when the scrollView offset is
  /// greater than [fixedPositionOffset].
  double fixedPositionOffset = 0;

  /// The callback that tells the outside to rebuild the scroll view.
  ///
  /// Such as call [setState] method.
  Function? toRebuildScrollViewCallback;

  /// The result callback for processing chat location.
  ///
  /// This callback will be called when handling in [ClampingScrollPhysics]'s
  /// [adjustPositionForNewDimensions].
  void Function(ChatScrollObserverHandlePositionResultModel)? onHandlePositionResultCallback;

  /// The mode of processing.
  ChatScrollObserverHandleMode innerMode = ChatScrollObserverHandleMode.normal;

  /// Observation result of reference subParts after ScrollView children update.
  ListViewObserveDisplayingChildModel? observeRefItem() {
    return observerController.observeItem(
      index: refItemIndexAfterUpdate,
    );
  }

  /// Prepare to adjust position for sliver.
  ///
  /// The [changeCount] parameter is used only when [isRemove] parameter is
  /// false.
  ///
  /// The [mode] parameter is used to specify the processing mode.
  ///
  /// [refItemRelativeIndex] parameter and [refItemRelativeIndexAfterUpdate]
  /// parameter are only used when the mode is
  /// [ChatScrollObserverHandleMode.specified].
  /// Usage: When you insert a new message, assign the index of the reference
  /// message before insertion to [refItemIndex], and assign the index of the
  /// reference message after insertion to [refItemIndexAfterUpdate].
  /// Note that they should refer to the index of the same message.
  void standby({
    BuildContext? sliverContext,
    bool isRemove = false,
    int changeCount = 1,
    ChatScrollObserverHandleMode mode = ChatScrollObserverHandleMode.normal,
    ChatScrollObserverRefIndexType refIndexType =
        ChatScrollObserverRefIndexType.relativeIndexStartFromCacheExtent,
    @Deprecated(
        'It will be removed in version 2, please use [refItemIndex] instead')
    int refItemRelativeIndex = 0,
    @Deprecated(
        'It will be removed in version 2, please use [refItemIndexAfterUpdate] instead')
    int refItemRelativeIndexAfterUpdate = 0,
    int refItemIndex = 0,
    int refItemIndexAfterUpdate = 0,
  }) async {
    innerMode = mode;
    this.isRemove = isRemove;
    this.changeCount = changeCount;
    observeSwitchShrinkWrap();

    final firstItemModel = observerController.observeFirstItem(
      sliverContext: sliverContext,
    );
    if (firstItemModel == null) return;
    int myInnerRefItemIndex;
    int myInnerRefItemIndexAfterUpdate;
    double myInnerRefItemLayoutOffset;
    switch (mode) {
      case ChatScrollObserverHandleMode.normal:
        myInnerRefItemIndex = firstItemModel.index;
        myInnerRefItemIndexAfterUpdate = myInnerRefItemIndex + changeCount;
        myInnerRefItemLayoutOffset = firstItemModel.layoutOffset;
        break;
      case ChatScrollObserverHandleMode.generative:
        int index = firstItemModel.index + changeCount;
        final model = observerController.observeItem(
          sliverContext: sliverContext,
          index: index,
        );
        if (model == null) return;
        myInnerRefItemIndex = index;
        myInnerRefItemIndexAfterUpdate = index;
        myInnerRefItemLayoutOffset = model.layoutOffset;
        break;
      case ChatScrollObserverHandleMode.specified:
      // Prioritize the values ​​of [refItemIndex] and [refItemIndexAfterUpdate]
        int myRefItemIndex =
        refItemIndex != 0 ? refItemIndex : refItemRelativeIndex;
        int myRefItemIndexAfterUpdate = refItemIndexAfterUpdate != 0
            ? refItemIndexAfterUpdate
            : refItemRelativeIndexAfterUpdate;

        switch (refIndexType) {
          case ChatScrollObserverRefIndexType.relativeIndexStartFromCacheExtent:
            int index = firstItemModel.index + myRefItemIndex;
            final model = observerController.observeItem(
              sliverContext: sliverContext,
              index: index,
            );
            if (model == null) return;
            myInnerRefItemIndex = index;
            myInnerRefItemIndexAfterUpdate =
                firstItemModel.index + myRefItemIndexAfterUpdate;
            myInnerRefItemLayoutOffset = model.layoutOffset;
            break;
          case ChatScrollObserverRefIndexType.relativeIndexStartFromDisplaying:
            final observeResult = await observerController.dispatchOnceObserve(
              isForce: true,
              isDependObserveCallback: false,
            );
            if (!observeResult.isSuccess) return;
            final currentFirstDisplayingChildIndex =
                observeResult.observeResult?.firstChild?.index ?? 0;
            int index = currentFirstDisplayingChildIndex + myRefItemIndex;
            if (sliverContext == null || !sliverContext.mounted) return;
            final model = observerController.observeItem(
              sliverContext: sliverContext,
              index: index,
            );
            if (model == null) return;
            myInnerRefItemIndex = index;
            myInnerRefItemIndexAfterUpdate =
                currentFirstDisplayingChildIndex + myRefItemIndexAfterUpdate;
            myInnerRefItemLayoutOffset = model.layoutOffset;
            break;
          case ChatScrollObserverRefIndexType.itemIndex:
            final model = observerController.observeItem(
              sliverContext: sliverContext,
              index: myRefItemIndex,
            );
            if (model == null) return;
            myInnerRefItemIndex = myRefItemIndex;
            myInnerRefItemIndexAfterUpdate = myRefItemIndexAfterUpdate;
            myInnerRefItemLayoutOffset = model.layoutOffset;
            break;
        }
    }
    // Record value.
    innerIsNeedFixedPosition = true;
    innerRefItemIndex = myInnerRefItemIndex;
    innerRefItemIndexAfterUpdate = myInnerRefItemIndexAfterUpdate;
    innerRefItemLayoutOffset = myInnerRefItemLayoutOffset;

    // When the heights of items are similar, the viewport will not call
    // [performLayout], In this case, the [adjustPositionForNewDimensions] of
    // [ScrollPhysics] will not be called, which makes the function of keeping
    // position invalid.
    //
    // So here let it record a layout-time correction to the scroll offset, and
    // call [markNeedsLayout] to prompt the viewport to be re-layout to solve
    // the above problem.
    //
    // Related issue
    // https://github.com/fluttercandies/flutter_scrollview_observer/issues/64
    final mySliverContext = observerController.fetchSliverContext();
    if (mySliverContext == null || !mySliverContext.mounted) return;
    final obj = ObserverUtils.findRenderObject(mySliverContext);
    if (obj == null) return;
    final viewport = ObserverUtils.findViewport(obj);
    if (viewport == null) return;
    if (!viewport.offset.hasPixels) return;
    viewport.offset.correctBy(0);
    viewport.markNeedsLayout();
  }

  void observeSwitchShrinkWrap() {
    ambiguate(WidgetsBinding.instance)?.addPostFrameCallback((_) {
      final ctx = observerController.fetchSliverContext();
      if (ctx == null) return;
      final obj = ObserverUtils.findRenderObject(ctx);
      if (obj is! RenderSliver) return;
      final constraints = ObserverUtils.sliverConstraints(obj);
      if (constraints == null) return;
      final viewportMainAxisExtent = constraints.viewportMainAxisExtent;
      final scrollExtent = obj.geometry?.scrollExtent ?? 0;
      if (viewportMainAxisExtent >= scrollExtent) {
        if (innerIsShrinkWrap) return;
        innerIsShrinkWrap = true;
        observerController.reattach();
        toRebuildScrollViewCallback?.call();
      } else {
        if (!innerIsShrinkWrap) return;
        innerIsShrinkWrap = false;
        observerController.reattach();
        toRebuildScrollViewCallback?.call();
      }
    });
  }
}
