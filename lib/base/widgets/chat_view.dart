import 'package:flutter/material.dart';

import 'scrollview_observer/chat/chat_observer_scroll_physics.dart';
import 'scrollview_observer/chat/chat_scroll_observer.dart';
import 'scrollview_observer/listview/list_observer_controller.dart';
import 'scrollview_observer/listview/list_observer_view.dart';

///
/// Created by a0010 on 2023/11/27 16:22
///
class ChatView extends StatelessWidget {
  final ScrollController scrollerController;
  final ListObserverController controller;
  final ChatScrollObserver observer;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  final bool reverse;
  final int itemCount;
  final NullableIndexedWidgetBuilder itemBuilder;

  const ChatView({
    super.key,
    required this.scrollerController,
    required this.controller,
    required this.observer,
    this.physics,
    this.padding,
    this.reverse = false,
    required this.itemCount,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        ScrollPhysics myPhysics = ChatObserverClampingScrollPhysics(
          observer: observer,
        );
        if (physics != null) {
          myPhysics = physics!.applyTo(myPhysics);
        }
        Widget resultWidget = ListView.builder(
          physics: observer.isShrinkWrap ? const NeverScrollableScrollPhysics() : myPhysics,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          shrinkWrap: observer.isShrinkWrap,
          reverse: reverse,
          controller: scrollerController,
          itemBuilder: itemBuilder,
          itemCount: itemCount,
        );
        if (observer.isShrinkWrap) {
          resultWidget = SingleChildScrollView(
            reverse: true,
            physics: myPhysics,
            child: Container(
              alignment: Alignment.topCenter,
              height: constraints.maxHeight + 0.001,
              child: resultWidget,
            ),
          );
        }
        resultWidget = ListViewObserver(
          controller: controller,
          child: resultWidget,
        );
        resultWidget = Align(
          alignment: Alignment.topCenter,
          child: resultWidget,
        );
        return resultWidget;
      },
    );
  }
}
