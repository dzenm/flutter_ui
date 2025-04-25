import 'dart:math';

import 'package:fbl/fbl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ui/pages/study/study_model.dart';
import 'package:provider/provider.dart';

import 'chat_item_widget.dart';
import 'chat_model.dart';

///
/// Created by a0010 on 2023/10/30 16:27
///
class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool isShowClassicHeaderAndFooter = false;
  BuildContext? pageOverlayContext;
  final LayerLink layerLink = LayerLink();
  bool editViewReadOnly = false;
  TextEditingController editViewController = TextEditingController();

  @override
  void initState() {
    super.initState();

    Provider.of<StudyModel>(context, listen: false).initModels();
    Future.delayed(const Duration(seconds: 1), addUnreadTipView);
  }

  @override
  void dispose() {
    editViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 100, 100, 100),
      appBar: CommonBar(
        title: 'Chat',
        backgroundColor: const Color.fromARGB(255, 19, 19, 19),
        actions: [
          TextButton(
            onPressed: () {
              isShowClassicHeaderAndFooter = !isShowClassicHeaderAndFooter;
              setState(() {});
            },
            child: Text(
              isShowClassicHeaderAndFooter ? "Classic" : "Material",
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    var list = Provider.of<StudyModel>(context).chatModels;
    Widget child;
    if (list.isEmpty) {
      child = Container();
    } else {
      child = const _MessageListView();
    }
    Widget resultWidget = Column(
      children: [
        Expanded(child: child),
        CompositedTransformTarget(
          link: layerLink,
          child: Container(),
        ),
        _buildEditView(),
        const SafeArea(top: false, child: SizedBox.shrink()),
      ],
    );
    resultWidget = Stack(children: [
      resultWidget,
      _buildPageOverlay(),
    ]);
    return resultWidget;
  }

  Widget _buildPageOverlay() {
    return Overlay(initialEntries: [
      OverlayEntry(
        builder: (context) {
          pageOverlayContext = context;
          return Container();
        },
      )
    ]);
  }

  Widget _buildEditView() {
    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.enter): SendMsgIntent(),
      },
      child: Actions(
        actions: {
          SendMsgIntent: CallbackAction<SendMsgIntent>(onInvoke: (intent) => _sendMessage()),
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 0.5),
            borderRadius: BorderRadius.circular(4),
            // color: Colors.white,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isCollapsed: true,
                  ),
                  style: const TextStyle(color: Colors.white),
                  maxLines: 4,
                  minLines: 1,
                  showCursor: true,
                  readOnly: editViewReadOnly,
                  controller: editViewController,
                ),
              ),
              IconButton(
                onPressed: () => _sendMessage(),
                icon: const Icon(Icons.send_sharp),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _sendMessage() {
    editViewController.text = '';
    Provider.of<StudyModel>(context, listen: false).insert();
    setState(() {});
  }

  addUnreadTipView() {
    Overlay.of(pageOverlayContext!).insert(OverlayEntry(
      builder: (BuildContext context) => UnconstrainedBox(
        child: CompositedTransformFollower(
          link: layerLink,
          followerAnchor: Alignment.bottomRight,
          targetAnchor: Alignment.topRight,
          offset: const Offset(-20, 0),
          child: Material(
            type: MaterialType.transparency,
            color: Colors.green,
            // child: _buildUnreadTipView(),
          ),
        ),
      ),
    ));
  }

// Widget _buildUnreadTipView() {
//   return ValueListenableBuilder<int>(
//     builder: (context, value, child) {
//       return ChatUnreadTipView(
//         unreadMsgCount: unreadMsgCount.value,
//         onTap: () {
//           _scrollerController.animateTo(
//             0,
//             duration: const Duration(milliseconds: 300),
//             curve: Curves.easeInOut,
//           );
//           updateUnreadMsgCount(isReset: true);
//         },
//       );
//     },
//     valueListenable: unreadMsgCount,
//   );
// }
}

class _MessageListView extends StatefulWidget {
  final ScrollPhysics? physics;

  const _MessageListView({
    super.key,
    this.physics,
  });

  @override
  State<_MessageListView> createState() => _MessageListViewState();
}

class _MessageListViewState extends State<_MessageListView> with WidgetsBindingObserver {
  final ScrollController _scrollerController = ScrollController();
  late ListObserverController _controller;
  late ChatScrollObserver _chatObserver;

  ValueNotifier<int> unreadMsgCount = ValueNotifier<int>(0);
  bool needIncrementUnreadMsgCount = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    _scrollerController.addListener(scrollControllerListener);
    _controller = ListObserverController(controller: _scrollerController)..cacheJumpIndexOffset = false;
    _chatObserver = ChatScrollObserver(_controller)
      ..fixedPositionOffset = 5
      ..toRebuildScrollViewCallback = () {
        setState(() {});
      }
      ..onHandlePositionResultCallback = (result) {
        if (!needIncrementUnreadMsgCount) return;
        switch (result.type) {
          case ChatScrollObserverHandlePositionType.keepPosition:
            updateUnreadMsgCount(changeCount: result.changeCount);
            break;
          case ChatScrollObserverHandlePositionType.none:
            updateUnreadMsgCount(isReset: true);
            break;
        }
      };
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    // Update shrinkWrap in real time as the keyboard pops up or closes.
    _chatObserver.observeSwitchShrinkWrap();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        if (MediaQuery.of(context).viewInsets.bottom == 0) {
          // Keyboard closes
        } else {
          // Keyboard pops up
          _scrollerController.jumpTo(0);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildListView(physics: widget.physics);
  }

  Widget _buildListView({ScrollPhysics? physics}) {
    return Selector0<List<ChatModel>>(
      selector: (context) => Provider.of<StudyModel>(context).chatModels,
      builder: (c, chatModels, w) {
        if (chatModels.isEmpty) {
          return Container();
        }
        return ChatView(
          scrollerController: _scrollerController,
          controller: _controller,
          observer: _chatObserver,
          physics: physics,
          reverse: true,
          itemCount: chatModels.length,
          itemBuilder: (context, index) {
            return ChatItemWidget(
              chatModel: chatModels[index],
              index: index,
              itemCount: chatModels.length,
              onRemove: () {
                _chatObserver.standby(isRemove: true);
                setState(() {
                  chatModels.removeAt(index);
                });
              },
            );
          },
        );
      },
    );
  }

  updateUnreadMsgCount({
    bool isReset = false,
    int changeCount = 1,
  }) {
    // needIncrementUnreadMsgCount = false;
    if (isReset) {
      unreadMsgCount.value = 0;
    } else {
      unreadMsgCount.value += changeCount;
    }
  }

  scrollControllerListener() {
    if (_scrollerController.offset < 50) {
      updateUnreadMsgCount(isReset: true);
    }
  }

  void _sendMessage() {
    _chatObserver.standby(changeCount: 1);
    needIncrementUnreadMsgCount = true;
  }

  int genInt({int min = 0, int max = 100}) {
    var x = Random().nextInt(max) + min;
    return x.floor();
  }
}

/// 发送消息快捷键创建 Intent
class SendMsgIntent extends Intent {}
