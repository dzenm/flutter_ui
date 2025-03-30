import 'dart:collection';

import 'package:fbl/fbl.dart';

import '../common/message.dart';
import 'linked_queue.dart';

/// Socket发送消息队列
final class IMessageQueue<S extends Message> with Logging {
  /// 发送消息的消息队列
  final Queue<S> _queue = Queue();

  LinkedQueue get messages => _messageQueue;

  /// 发送消息的消息队列（双向链表）
  final LinkedQueue<S> _messageQueue = LinkedQueue();

  /// 添加一条待发送的消息
  void add(S iMsg) {
    _queue.addLast(iMsg);
  }

  S? top() {
    if (_queue.isEmpty) return null;
    return _queue.first;
  }

  /// 取出一条Socket消息进行发送
  S? poll() {
    if (_queue.isEmpty) return null;
    S iMsg = _queue.removeFirst();
    // 单聊/群聊消息要处理返回结果
    if (iMsg is ChatMessage) {
      String uid = iMsg.hash;
      _messageQueue.addFirst(iMsg, id: uid);
      logDebug('准备发送消息（已插入消息链表节点）：uid=$uid，linked=${_messageQueue.toLinkedString()}');
    }
    return iMsg;
  }

  /// 移除已经发送的Socket聊天消息
  void remove(String chattingUid) {
    _messageQueue.removeById(chattingUid);
    logDebug('收到消息响应（已移除消息链表节点）：chattingUid=$chattingUid，linked=${_messageQueue.toLinkedString()}');
  }

  /// 待发送的聊天消息列表是否为空
  bool get isEmpty => _messageQueue.isEmpty;
}
