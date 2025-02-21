import 'dart:convert';

import '../../transfer/src/transfer.dart';

///
/// Created by a0010 on 2025/1/25 13:47
///
class SenderText extends BufferTransfer implements Sender {
  final String text;

  SenderText({required this.text});

  @override
  List<int> get data => utf8.encode(text);

  @override
  List<int> create() {
    return data;
  }
}

class ReceiveText extends BufferTransfer implements Receiver {

  @override
  List<int> get data => throw UnimplementedError();

  @override
  void distribute(List<int> data) {
    String text = utf8.decode(data);
  }
}
