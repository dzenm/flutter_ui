import 'package:fbl/fbl.dart';
import 'package:flutter/material.dart';

import '../../../widgets/rich_text_field.dart';

///
/// Created by a0010 on 2025/12/24 10:50
///
class LinkedPage extends StatefulWidget {
  const LinkedPage({super.key});

  @override
  State<LinkedPage> createState() => _LinkedPageState();
}

class _LinkedPageState extends State<LinkedPage> {
  final RichTextEditingController _controller = RichTextEditingController();
  late InlineTextFactory _factory;

  @override
  void initState() {
    super.initState();
    _factory = InlineTextFactory(controller: _controller);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonBar(
        title: '链表测试',
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: ListView(children: [
          _buildRichTextView(),
        ]),
      ),
    );
  }

  Widget _buildRichTextView() {
    String text = _factory.toString();
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue, width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("控制台输出结果：", style: TextStyle(color: Colors.black)),
        const SizedBox(height: 12),
        Text(text),
        RichTextField(
          controller: _controller,
          onChanged: (s) {
          },
        ),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          ElevatedButton(
            onPressed: () {},
            child: const Text("插入文本"),
          ),
          ElevatedButton(
            onPressed: () {
              _factory.addEmoji("[皱眉]");
              setState(() {});
            },
            child: const Text("插入表情"),
          ),
          ElevatedButton(
            onPressed: () {
              _factory.addAlta("@所有人 ");
              setState(() {});
            },
            child: const Text("插入@人"),
          ),
        ]),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          ElevatedButton(
            onPressed: () {},
            child: const Text("删除"),
          ),
        ]),
      ]),
    );
  }
}

/// 特殊类型的片段
abstract class SpecialInlineText {
  SpecialInlineText({required String text}) : _text = StringBuffer(text);

  String get text => _text.toString();
  final StringBuffer _text; // 文本的内容

  InlineSpan get span; // 节点对应的字符片段渲染

  SpecialInlineText? get previous => _previous;
  SpecialInlineText? _previous; // 上一个节点
  SpecialInlineText? get next => _next;
  SpecialInlineText? _next; // 下一个节点

  bool get isNotEmpty => text.isNotEmpty; // 是否不为空文本
  bool get isEmpty => text.isEmpty; // 是否为空文本
  int get length => text.length; // 文本长度

  void reset(String text) {
    _text.clear();
    _text.write(text);
  }
}

class InlineText extends SpecialInlineText {
  final TextStyle? textStyle;

  InlineText({required super.text, this.textStyle}) : super();

  @override
  TextSpan get span => TextSpan(text: text, style: textStyle);
}

class InlineEmoji extends SpecialInlineText {
  InlineEmoji({required super.text});

  @override
  InlineSpan get span => throw UnimplementedError();
}

class InlineAlta extends SpecialInlineText {
  final TextStyle? textStyle;

  InlineAlta({required super.text, this.textStyle}) : super();

  @override
  TextSpan get span => TextSpan(text: text, style: textStyle);
}

/// 特殊类型的片段构建器
abstract class SpecialInlineFactory {
  final RichTextEditingController controller;

  SpecialInlineFactory({required this.controller});

  int get length;
}

class InlineTextFactory extends SpecialInlineFactory {
  InlineTextFactory({required super.controller});

  SpecialInlineText? _head; // 节点的头部
  SpecialInlineText? _tail; // 节点的尾部

  @override
  int get length => 0;

  /// 添加普通文本
  void addText(String text) {}

  /// 添加 @user
  void addAlta(String text) {
    InlineAlta alta = InlineAlta(text: text);
    _insert(alta);
  }

  /// 添加表情
  void addEmoji(String text) {
    InlineEmoji emoji = InlineEmoji(text: text);
    _insert(emoji);
  }

  /// 解析文本
  void parse(String text) {

  }

  /// 删除文本
  void delete() {
    TextSelection selection = controller.selection;
  }

  /// 插入一个新的节点
  void _insert(SpecialInlineText current) {
    int index = controller.selection.extentOffset;

    SpecialInlineText? head = _head;
    SpecialInlineText? tail = _tail;
    int start = 0;
    while (true) {
      if (head == null) {
        // 从尾部插入
        if (tail == null) {
          // 链表为空
          _head = _tail = current;
        } else {
          // 链表不为空
          tail._next = current;
          current._previous = tail;
          _tail = current;
        }
        _merge();
        return;
      }
      SpecialInlineText? temp = head;
      head = head.next;
      int left = start;
      int right = start + temp.length;
      start = right;
      if (0 < index && right < index) continue; // 未找到，继续查找
      // 找到插入的位置
      SpecialInlineText? previous = temp.previous;
      SpecialInlineText? next = temp.next;
      if (temp is InlineText) {
        // 找到的是文本类型
        String s = temp.text;
        String s1 = s.substring(left, index);
        String s2 = s.substring(index + 1, right);
        SpecialInlineText? ls = InlineText(text: s1);
        previous?._next = ls;
        ls._previous = previous;
        ls._next = current;
        current._previous = ls;
        SpecialInlineText? rs = InlineText(text: s2);
        next?._previous = rs;
        rs._next = next;
        rs._previous = current;
        current._next = rs;

        temp._previous = null;
        temp._next = null;
        return;
      }
      temp._next = current;
      current._previous = temp;
      if (next == null) return;
      next._previous = current;
      current._next = next;
      return;
    }
  }

  /// 合并节点
  void _merge() {
    SpecialInlineText? head = _head;
    while (head != null && head.next != null) {
      SpecialInlineText? current = head;
      SpecialInlineText? next = head.next;
      if (current is! InlineText || next is! InlineText) {
        head = head.next;
        continue;
      }
      // linked：A -> B -> C -> D
      // current：B
      // next：C
      // B + C => B1
      // linked：A -> B1 -> D
      SpecialInlineText inline = InlineText(text: current.text + next.text);
      SpecialInlineText? previous = head.previous;
      // A -> B1
      previous?._next = inline;
      inline._previous = previous;
      // B1 -> D
      inline._next = next.next;
      next.next?._previous = inline;
      // B and C release
      current._previous = null;
      next._next = null;
      head = inline;
    }
  }

  @override
  String toString() {
    StringBuffer sb = StringBuffer();
    SpecialInlineText? head = _head;
    while (head != null) {
      sb.write(head.text);
      head = head.next;
      if (head != null) sb.write(" -> ");
    }
    return sb.toString();
  }
}

class InlineSpanFactory extends SpecialInlineFactory {
  InlineSpanFactory({required super.controller});

  TextSpan buildTextSpan(String text) {
    int oldLen = length;
    int newLen = text.length;
    int index = controller.selection.extentOffset;
    if (newLen == oldLen) {
      // 长度相等，检测内容是否发生变化
    } else if ((newLen - oldLen).abs() == 1) {
      // 变化前后相差一个字符，只能是纯文本发生变化
    } else if (newLen < oldLen) {
      // 删除变化
    } else if (newLen > oldLen) {
      // 新增变化
    }
    return const TextSpan();
  }

  @override
  int get length => throw UnimplementedError();
}
