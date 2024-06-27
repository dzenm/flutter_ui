import 'package:flutter/material.dart';

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
