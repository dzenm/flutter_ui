import 'package:flutter/material.dart';

import 'chat_model.dart';

class ChatItemWidget extends StatelessWidget {
  const ChatItemWidget({
    super.key,
    required this.chatModel,
    required this.index,
    required this.itemCount,
    this.onRemove,
  });

  final ChatModel chatModel;
  final int index;
  final int itemCount;
  final Function? onRemove;

  @override
  Widget build(BuildContext context) {
    final isOwn = chatModel.isOwn;
    final nickName = isOwn ? 'LXF' : 'LQR';
    Widget resultWidget = Row(
      textDirection: isOwn ? TextDirection.ltr : TextDirection.rtl,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
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
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isOwn
                  ? const Color.fromARGB(255, 21, 125, 200)
                  : const Color.fromARGB(255, 39, 39, 38),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '------------ ${itemCount - index} ------------ \n ${chatModel.content}',
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
  }
}
