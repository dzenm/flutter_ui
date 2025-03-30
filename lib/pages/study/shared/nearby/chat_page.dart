import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:fbl/fbl.dart';
import 'package:fbl/src/config/notification.dart' as ln;
import 'package:flutter/material.dart';
import 'package:pp_transfer/pp_transfer.dart';
import 'package:provider/provider.dart';

import 'nearby_page.dart';
import 'pp_model.dart';

class DeviceChatPage extends StatefulWidget {
  const DeviceChatPage({super.key});

  @override
  State<DeviceChatPage> createState() => _DeviceChatPageState();
}

class _DeviceChatPageState extends State<DeviceChatPage> {
  final ScrollController _scrollerController = ScrollController();
  late ListObserverController _controller;
  late ChatScrollObserver _chatObserver;

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

    Future.delayed(const Duration(seconds: 1), addUnreadTipView);
  }

  @override
  void dispose() {
    _controller.controller?.dispose();
    editViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WifiP2pConnection? connection = Provider.of<PPModel>(context).connection;
    WifiP2pGroup? group = connection?.group;
    String title = group?.networkName == null ? 'Chat' : group?.networkName ?? 'Chat';
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 100, 100, 100),
      appBar: CommonBar(
        title: title,
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
        const SizedBox(height: 12),
        Selector0<List<SocketAddress>>(
          selector: (context) => Provider.of<PPModel>(context).connectionDevices,
          builder: (c, devices, w) {
            return PeersView(
              devices: devices,
              size: 52,
              onTap: (device) {},
            );
          },
        ),
        const SizedBox(height: 12),
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
            onPressed: () => _sendMessage(),
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
            _scrollerController.animateTo(
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

  Widget _buildListView({ScrollPhysics? physics}) {
    return Selector0<int>(
      selector: (context) => Provider.of<PPModel>(context).length,
      builder: (c, itemCount, w) {
        return ChatView(
          physics: physics,
          itemCount: itemCount,
          scrollerController: _scrollerController,
          controller: _controller,
          observer: _chatObserver,
          reverse: true,
          itemBuilder: (context, index) {
            return ChatItemWidget(
              index: index,
              itemCount: itemCount,
              onRemove: () {
                _chatObserver.standby(isRemove: true);
                Provider.of<PPModel>(context, listen: false).deleteMsg(index);
              },
            );
          },
        );
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

  void _sendMessage() {
    String text = editViewController.text;
    if (text.isEmpty) return;
    editViewController.text = '';
    _chatObserver.standby(changeCount: 1);

    WifiP2pDevice? self = context.read<PPModel>().self;
    List<int> data = utf8.encode(text);
    TextMessage message = TextMessage(
      hash: md5.convert(data).toString(),
      sendUid: self!.deviceAddress,
      receiveUid: '',
    );
    Log.d('测试：${message.toJson()}');
    Provider.of<PPModel>(context, listen: false).insertMsg(message);
    var nc = ln.NotificationCenter();
    nc.postNotification(WifiDirectNames.kSendTextData, this, {
      'message': message,
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
    if (_scrollerController.offset < 50) {
      updateUnreadMsgCount(isReset: true);
    }
  }
}

class ChatItemWidget extends StatelessWidget {
  const ChatItemWidget({
    super.key,
    required this.index,
    required this.itemCount,
    this.onRemove,
  });

  final int index;
  final int itemCount;
  final Function? onRemove;

  @override
  Widget build(BuildContext context) {
    WifiP2pDevice? self = context.watch<PPModel>().self;
    if (self == null) {
      return const SizedBox.shrink();
    }
    return Selector0<ChatMessage?>(
      selector: (context) => Provider.of<PPModel>(context).getMsg(index),
      builder: (c, message, w) {
        if (message == null) return const SizedBox.shrink();
        bool isSender = self.deviceAddress == message.sendUid;
        final isOwn = !isSender;
        // final nickName = message.userName;
        String text = message is TextMessage ? message.text : '';
        Widget resultWidget = Row(
          textDirection: isOwn ? TextDirection.ltr : TextDirection.rtl,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Selector0(
              builder: (c, nickName, w) {
                return Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: isOwn ? Colors.blue : Colors.white30,
                  ),
                  child: Center(
                    child: Text(
                      nickName,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              },
              selector: (context) => Provider.of<PPModel>(context).getName(message.sendUid),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isOwn ? const Color.fromARGB(255, 21, 125, 200) : const Color.fromARGB(255, 39, 39, 38),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '------------ ${itemCount - index} ------------ \n $text',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 50),
          ],
        );
        resultWidget = Column(
          children: [
            resultWidget,
            const SizedBox(height: 15),
          ],
        );
        resultWidget = Dismissible(
          key: UniqueKey(),
          child: resultWidget,
          onDismissed: (_) {
            onRemove?.call();
          },
        );
        return resultWidget;
      },
    );
  }
}

class ChatUnreadTipView extends StatelessWidget {
  ChatUnreadTipView({
    super.key,
    required this.unreadMsgCount,
    this.onTap,
  });

  final int unreadMsgCount;

  final Color primaryColor = Colors.green[100]!;

  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (unreadMsgCount == 0) return const SizedBox.shrink();
    Widget resultWidget = Stack(
      children: [
        const Icon(
          Icons.mode_comment,
          size: 50,
          color: Colors.white,
        ),
        Container(
          margin: const EdgeInsets.only(top: 12),
          width: 50,
          child: Center(
            child: Text(
              '$unreadMsgCount',
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
    resultWidget = GestureDetector(
      onTap: onTap,
      child: resultWidget,
    );
    return resultWidget;
  }
}
