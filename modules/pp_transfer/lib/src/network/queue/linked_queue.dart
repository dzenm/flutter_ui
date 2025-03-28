///
/// Created by a0010 on 2024/5/10 13:29
/// 使用双向链表实现的队列，具体实现@see [_LinkedQueue]
abstract base mixin class LinkedQueue<E> implements Iterable<E> {
  factory LinkedQueue() => _LinkedQueue<E>();

  /// Adds [value] at the beginning of the queue.
  void addFirst(E value, {String? id});

  /// Removes and returns the first element of this queue.
  ///
  /// Removes null when this queue is empty.
  E? removeFirst();

  /// Adds [value] at the end of the queue.
  void addLast(E value, {String? id});

  /// Removes and returns the last element of the queue.
  ///
  /// Removes null when this queue is empty.
  E? removeLast();

  /// Removes and returns a single instance of [value] from the queue.
  ///
  /// Returns `true` if a value was removed, or `false` if the queue
  /// contained no element equal to [value].
  bool? remove(E? value);

  /// Removes and returns a single instance of [value] from the queue by [id].
  ///
  /// Removes null if the queue contained no element equal to [value].
  E? removeById(String id);

  /// Invokes [action] on each element of this iterable by Future in iteration order.
  Future<void> forEachFuture(Future<void> Function(E element) action);

  /// Linked List to String
  String toLinkedString();

  /// Removes all elements in the queue. The size of the queue becomes zero.
  void clear();
}

/// LinkedQueue的具体实现
final class _LinkedQueue<E> extends Iterable<E> implements LinkedQueue<E> {
  /// [_head]为头节点，[_tail]为尾节点
  _Node<E>? _head, _tail;

  /// 从头节点 [_head] 插入新的节点
  @override
  void addFirst(E element, {String? id}) {
    if (id == null) return;
    _Node<E> node = _Node(id, element: element);
    _Node<E>? head = _head;
    head?._previous = node; // 从头节点插入新的节点
    node._next = head; // 将新的头节点的上一个节点指向旧的头节点
    _head = node; // 将头节点指向新的头节点
    _tail ??= _head; // 保存尾节点
  }

  /// 移除第一个节点 [_head]
  @override
  E? removeFirst() {
    _Node<E>? head = _head;
    _Node<E>? tail = _tail;
    if (head == null) return null;
    if (head == tail) {
      _head = _tail = null; // 头节点等于尾节点，说明只存在一个节点，全部置空
      return head.element;
    }
    _Node<E> next = head._next!;
    next._previous = null;
    head._next = null;
    _head = next; // 将头节点的置针指向下一个节点
    return head.element; // 返回旧的头节点
  }

  /// 从尾节点 [_tail] 插入新的节点
  @override
  void addLast(E element, {String? id}) {
    if (id == null) return;
    _Node<E> node = _Node(id, element: element);

    _Node<E>? tail = _tail;
    tail?._next = node; // 从尾节点插入新的节点
    node._previous = tail; // 将新的尾节点的上一个节点指向旧的尾节点
    _tail = node; // 将尾节点指向新的尾节点
    _head ??= _tail; // 保存头节点
  }

  /// 移除最后一个节点 [_tail]
  @override
  E? removeLast() {
    _Node<E>? head = _head;
    _Node<E>? tail = _tail;
    if (tail == null) return null;
    if (head == tail) {
      _head = _tail = null; // 尾节点等于头节点，说明只存在一个节点，全部置空
      return tail.element;
    }
    _Node<E> pre = tail._previous!;
    pre._next = null;
    tail._previous = null;
    _tail = pre; // 将尾节点的置针指向上一个节点
    return tail.element; // 返回旧的尾节点
  }

  /// 根据 [element] 从链表中移除数据
  @override
  bool? remove(E? element) {
    if (element == null) return false;
    _Node<E>? node = _head;
    while (node != null && node.element != element) {
      node = node._next;
    }
    if (node == null) return false;

    _remove(node);
    return true;
  }

  /// 根据 [id] 从链表中移除数据
  @override
  E? removeById(String id) {
    _Node<E>? node = _get(id);
    if (node == null) return null;

    _remove(node);
    return node.element;
  }

  /// 根据id从链表中查找数据（默认是从头节点遍历）
  _Node<E>? _get(String id) {
    _Node<E>? node = _head;
    while (node != null) {
      if (node.id == id) return node;
      node = node._next;
    }
    return null;
  }

  /// 将 [node] 从链表中移除
  void _remove(_Node<E> node) {
    _Node<E>? next = node._next;
    _Node<E>? pre = node._previous;
    if (pre == null) {
      // 上一个节点为空时（当前节点为头节点），头节点指向下一个节点
      next?._previous = null;
      _head = next;
    }
    if (next == null) {
      // 下一个节点为空时（当前节点为尾节点），尾节点指向上一个节点
      pre?._next = null;
      _tail = pre;
    }
    // 将找到的节点从链表中移除
    pre?._next = next;
    next?._previous = pre;
    // 当前链表的 [pre] 和 [next] 引用置空
    node._next = null;
    node._previous = null;
  }

  /// 遍历链表（默认是从头节点遍历）
  @override
  Future<void> forEachFuture(Future<void> Function(E element) action) async {
    _Node<E>? node = _head;
    while (node != null) {
      E element = node.element;
      // 执行消息处理
      node = node._next;
      await action(element);
    }
  }

  /// 将链表转为字符串（默认是从头节点遍历）
  @override
  String toLinkedString() {
    _Node? node = _head;
    StringBuffer sb = StringBuffer();
    while (node != null) {
      sb.write('${node.id} -> ');
      node = node._next;
    }
    sb.write('${node?.id}');
    return sb.toString();
  }

  /// 清空所有节点
  @override
  void clear() {
    _Node<E>? node = _head;
    while (node != null) {
      _Node<E>? temp = node._next;
      node._next = null;
      temp?._previous = null;
      node = temp;
    }
    _head = _tail = null;
  }

  @override
  Iterator<E> get iterator => _LinkedQueueIterator<E>(this);
}

/// LinkedQueue实现的迭代器
base class _LinkedQueueIterator<E> implements Iterator<E> {
  final _LinkedQueue<E> _queue;
  _Node<E>? _head;
  _Node<E>? _current;
  bool _visitedFirst;

  _LinkedQueueIterator(_LinkedQueue<E> queue)
      : _queue = queue,
        _head = queue._head,
        _current = queue._head,
        _visitedFirst = false;

  @override
  E get current => _current as E;

  @override
  bool moveNext() {
    if (_head == null || (_visitedFirst && identical(_head, _queue._head))) {
      _current = null;
      return false;
    }
    if (_head == null) return false;
    _visitedFirst = true;
    _current = _head;
    _head = _head!._next;
    return true;
  }
}

/// 链表的节点
class _Node<E> {
  String id;
  E element;
  _Node<E>? _next;
  _Node<E>? _previous;

  _Node(this.id, {required this.element});
}