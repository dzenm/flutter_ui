import 'package:flutter/material.dart';
import 'chat_observer_scroll_physics_mixin.dart';
import 'chat_scroll_observer.dart';

@Deprecated(
    'It will be removed in version 2, please use [ChatObserverClampingScrollPhysics] instead')
class ChatObserverClampinScrollPhysics
    extends ChatObserverClampingScrollPhysics {
  ChatObserverClampinScrollPhysics({
    required super.observer,
  });
}

class ChatObserverClampingScrollPhysics extends ClampingScrollPhysics
    with ChatObserverScrollPhysicsMixin {
  ChatObserverClampingScrollPhysics({
    super.parent,
    required ChatScrollObserver observer,
  }) {
    this.observer = observer;
  }

  @override
  ChatObserverClampingScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return ChatObserverClampingScrollPhysics(
      parent: buildParent(ancestor),
      observer: observer,
    );
  }
}

class ChatObserverBouncingScrollPhysics extends BouncingScrollPhysics
    with ChatObserverScrollPhysicsMixin {
  ChatObserverBouncingScrollPhysics({
    super.parent,
    required ChatScrollObserver observer,
  }) {
    this.observer = observer;
  }

  @override
  ChatObserverBouncingScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return ChatObserverBouncingScrollPhysics(
      parent: buildParent(ancestor),
      observer: observer,
    );
  }
}
