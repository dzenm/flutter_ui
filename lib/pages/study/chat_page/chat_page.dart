import 'dart:math';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';

import 'chat_item_widget.dart';
import 'chat_list/chat/chat_observer_scroll_physics.dart';
import 'chat_list/chat/chat_scroll_observer.dart';
import 'chat_list/chat/chat_scroll_observer_model.dart';
import 'chat_list/listview/list_observer_controller.dart';
import 'chat_list/listview/list_observer_view.dart';
import 'chat_model.dart';
import 'chat_unread_tip_view.dart';

///
/// Created by a0010 on 2023/10/30 16:27
///
class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _controller = ScrollController();

  late ListObserverController observerController;

  late ChatScrollObserver chatObserver;

  List<ChatModel> chatModels = [];

  ValueNotifier<int> unreadMsgCount = ValueNotifier<int>(0);

  bool needIncrementUnreadMsgCount = false;

  bool editViewReadOnly = false;

  TextEditingController editViewController = TextEditingController();

  BuildContext? pageOverlayContext;

  final LayerLink layerLink = LayerLink();

  bool isShowClassicHeaderAndFooter = false;

  @override
  void initState() {
    super.initState();

    chatModels = createChatModels();
    _controller.addListener(scrollControllerListener);
    observerController = ListObserverController(controller: _controller)..cacheJumpIndexOffset = false;
    chatObserver = ChatScrollObserver(observerController)
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

    Future.delayed(const Duration(seconds: 1), addUnreadTipView);
  }

  @override
  void dispose() {
    observerController.controller?.dispose();
    editViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 100, 100, 100),
      appBar: AppBar(
        title: const Text("Chat"),
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

  Widget _buildBody() {
    Widget resultWidget = Column(
      children: [
        Expanded(child: _buildListView()),
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

  Widget _buildEditView() {
    return Container(
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
            onPressed: () {
              editViewController.text = '';
              _addMessage(genInt(min: 1, max: 3));
            },
            icon: const Icon(Icons.send_sharp),
          ),
        ],
      ),
    );
  }

  Widget _buildUnreadTipView() {
    return ValueListenableBuilder<int>(
      builder: (context, value, child) {
        return ChatUnreadTipView(
          unreadMsgCount: unreadMsgCount.value,
          onTap: () {
            _controller.animateTo(
              0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
            updateUnreadMsgCount(isReset: true);
          },
        );
      },
      valueListenable: unreadMsgCount,
    );
  }

  Widget _buildListView() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        Widget resultWidget = EasyRefresh.builder(
          header: isShowClassicHeaderAndFooter ? const ClassicHeader() : const MaterialHeader(),
          footer: isShowClassicHeaderAndFooter
              ? const ClassicFooter(
                  position: IndicatorPosition.above,
                  infiniteOffset: null,
                )
              : const MaterialFooter(),
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 2));
          },
          onLoad: () async {
            await Future.delayed(const Duration(seconds: 2));
          },
          childBuilder: (context, physics) {
            var scrollViewPhysics = physics.applyTo(ChatObserverClampingScrollPhysics(
              observer: chatObserver,
            ));
            Widget resultWidget = ListView.builder(
              physics: chatObserver.isShrinkWrap ? const NeverScrollableScrollPhysics() : scrollViewPhysics,
              padding: const EdgeInsets.only(
                left: 10,
                right: 10,
                top: 15,
                bottom: 15,
              ),
              shrinkWrap: chatObserver.isShrinkWrap,
              reverse: true,
              controller: _controller,
              itemBuilder: ((context, index) {
                return ChatItemWidget(
                  chatModel: chatModels[index],
                  index: index,
                  itemCount: chatModels.length,
                  onRemove: () {
                    chatObserver.standby(isRemove: true);
                    setState(() {
                      chatModels.removeAt(index);
                    });
                  },
                );
              }),
              itemCount: chatModels.length,
            );
            if (chatObserver.isShrinkWrap) {
              resultWidget = SingleChildScrollView(
                reverse: true,
                physics: scrollViewPhysics,
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
          controller: observerController,
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
            // color: Colors.green,
            child: _buildUnreadTipView(),
          ),
        ),
      ),
    ));
  }

  List<ChatModel> createChatModels({int num = 3}) {
    return Iterable<int>.generate(num).map((e) => createChatModel()).toList();
  }

  _addMessage(int count) {
    chatObserver.standby(changeCount: count);
    setState(() {
      needIncrementUnreadMsgCount = true;
      for (var i = 0; i < count; i++) {
        chatModels.insert(0, createChatModel());
      }
    });
  }

  updateUnreadMsgCount({
    bool isReset = false,
    int changeCount = 1,
  }) {
    needIncrementUnreadMsgCount = false;
    if (isReset) {
      unreadMsgCount.value = 0;
    } else {
      unreadMsgCount.value += changeCount;
    }
  }

  scrollControllerListener() {
    if (_controller.offset < 50) {
      updateUnreadMsgCount(isReset: true);
    }
  }

  int genInt({int min = 0, int max = 100}) {
    var x = Random().nextInt(max) + min;
    return x.floor();
  }

  List<String> chatContents = [
    'My name is LinXunFeng',
    'Twitter: https://twitter.com/xunfenghellolo'
        'Github: https://github.com/LinXunFeng',
    'Blog: https://fullstackaction.com/',
    'Juejin: https://juejin.cn/user/1820446984512392/posts',
    'Artile: Flutter-获取ListView当前正在显示的Widget信息\nhttps://juejin.cn/post/7103058155692621837',
    'Artile: Flutter-列表滚动定位超强辅助库，墙裂推荐！🔥\nhttps://juejin.cn/post/7129888644290068487',
    'A widget for observing data related to the child widgets being displayed in a scrollview.\nhttps://github.com/LinXunFeng/flutter_scrollview_observer',
    '📱 Swifty screen adaptation solution (Support Objective-C and Swift)\nhttps://github.com/LinXunFeng/SwiftyFitsize'
  ];

  ChatModel createChatModel({
    bool? isOwn,
  }) {
    final random = Random();
    final content = chatContents[random.nextInt(chatContents.length)];
    return ChatModel(
      isOwn: isOwn ?? random.nextBool(),
      content: content,
    );
  }
}
