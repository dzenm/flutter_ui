import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';

import 'chat/chat_observer_scroll_physics.dart';
import 'chat/chat_scroll_observer.dart';
import 'listview/list_observer_controller.dart';
import 'listview/list_observer_view.dart';

///
/// Created by a0010 on 2023/11/27 16:22
///
class ChatView extends StatelessWidget {
  final ScrollController scrollerController;
  final ListObserverController controller;
  final ChatScrollObserver observer;
  final NullableIndexedWidgetBuilder itemBuilder;
  final int itemCount;
  final bool isMaterialRefresh;

  const ChatView({
    super.key,
    required this.itemBuilder,
    required this.itemCount,
    required this.scrollerController,
    required this.controller,
    required this.observer,
    this.isMaterialRefresh = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        Widget resultWidget = EasyRefresh.builder(
          header: isMaterialRefresh ? const MaterialHeader() : const ClassicHeader(),
          footer: isMaterialRefresh
              ? const MaterialFooter()
              : const ClassicFooter(
                  position: IndicatorPosition.above,
                  infiniteOffset: null,
                ),
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 2));
          },
          onLoad: () async {
            await Future.delayed(const Duration(seconds: 2));
          },
          childBuilder: (context, physics) {
            var myPhysics = physics.applyTo(ChatObserverClampingScrollPhysics(
              observer: observer,
            ));
            Widget resultWidget = ListView.builder(
              physics: observer.isShrinkWrap ? const NeverScrollableScrollPhysics() : myPhysics,
              padding: const EdgeInsets.only(
                left: 10,
                right: 10,
                top: 15,
                bottom: 15,
              ),
              shrinkWrap: observer.isShrinkWrap,
              reverse: true,
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
            return resultWidget;
          },
        );

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
