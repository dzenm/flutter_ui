import 'dart:convert';
import 'dart:typed_data';

import '../../server/service.dart';

///
/// Created by a0010 on 2025/3/26 13:58
///
abstract class Message implements IMessage {
  MimeFlag get flag => _flag;
  final MimeFlag _flag;

  String get title => _title;
  final String _title;

  final List<int> _body;

  Message({
    MimeFlag flag = MimeFlag.text,
    String title = '',
    List<int> body = const [],
  })  : _flag = flag,
        _title = title,
        _body = body;

  factory Message.build({
    MimeFlag flag = MimeFlag.text,
    String title = '',
    List<int> body = const [],
  }) {
    switch (flag) {
      case MimeFlag.text:
        return TextMessage(body: body);
      case MimeFlag.image:
      case MimeFlag.video:
      case MimeFlag.audio:
      case MimeFlag.file:
        return FileMessage(title: title, body: body);
    }
  }

  Uint8List get body => Uint8List.fromList(_body);

  Uint8List get titleData => Uint8List.fromList(utf8.encode(_title));

  Map<String, dynamic> toJson() => {
    'flag': _flag,
    'title': _title,
    'body': _body,
  };
}

class TextMessage extends Message {
  TextMessage({
    super.body,
  }) : super(flag: MimeFlag.text);

  String get text {
    return utf8.decode(_body);
  }
}

class FileMessage extends Message {
  FileMessage({
    super.title,
    super.body,
  }) : super(flag: MimeFlag.file);
}

/// 传输的类型标志
enum MimeFlag {
  text(0x01),
  image(0x02),
  video(0x03),
  audio(0x04),
  file(0x05);

  final int value;

  const MimeFlag(this.value);

  static MimeFlag parse(int? value) {
    for (var item in MimeFlag.values) {
      if (item.value == value) return item;
    }
    return MimeFlag.text;
  }
}
