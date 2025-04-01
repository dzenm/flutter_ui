import 'dart:convert';
import 'dart:typed_data';

import '../../server/service.dart';

///
/// Created by a0010 on 2025/3/26 13:58
///
abstract class Message implements IMessage {
  final MessageFlag _headFlag;

  Message({
    required MessageFlag headFlag,
    List<int> body = const [],
  })  : _headFlag = headFlag,
        _body = body;

  void setBody(List<int> body) => _body = body;

  Uint8List get body => Uint8List.fromList(_body);
  late List<int> _body;

  factory Message.decode(List<int> data) {
    String json = utf8.decode(data);
    Map<String, dynamic> result = jsonDecode(json);

    MessageFlag headFlag = MessageFlag.parse(result['headFlag']);
    Map<String, dynamic> message = result['message'];
    switch (headFlag) {
      case MessageFlag.auth:
        return AuthMessage.fromJson(message);
      case MessageFlag.chat:
        return ChatMessage.fromJson(message);
    }
  }

  Uint8List encode() {
    Map<String, dynamic> result = toJson();
    String json = jsonEncode(result);
    return utf8.encode(json);
  }

  Map<String, dynamic> toJson() => {
        'headFlag': _headFlag.value,
      };

  Map<String, dynamic> toDebugJson() => {
        'headFlag': _headFlag.value,
      };
}

class AuthMessage extends Message {
  final String sessionUid;
  final String userUid;

  AuthMessage({
    required this.sessionUid,
    required this.userUid,
  }) : super(headFlag: MessageFlag.auth);

  factory AuthMessage.fromJson(Map<String, dynamic> json) {
    return AuthMessage(
      sessionUid: json['sessionUid'],
      userUid: json['userUid'],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'message': {
          'sessionUid': sessionUid,
          'userUid': userUid,
        },
      };

  @override
  Map<String, dynamic> toDebugJson() => {
        ...super.toJson(),
        'message': {
          'sessionUid': sessionUid,
          'userUid': userUid,
        },
      };
}

class ChatMessage extends Message {
  /// 数据类型标识
  MimeFlag get flag => _flag;
  final MimeFlag _flag;

  /// 标题
  String get title => _title;
  final String _title;

  /// 内容的Hash值
  String get hash => _hash;
  final String _hash;

  /// 发送人的Uid
  String get sendUid => _sendUid;
  final String _sendUid;

  /// 接收人的Uid
  String get receiveUid => _receiveUid;
  final String _receiveUid;

  ChatMessage({
    required MimeFlag flag,
    String title = '',
    required String hash,
    required String sendUid,
    required String receiveUid,
    super.body,
  })  : _flag = flag,
        _title = title,
        _hash = hash,
        _sendUid = sendUid,
        _receiveUid = receiveUid,
        super(headFlag: MessageFlag.chat);

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    MimeFlag flag = MimeFlag.parse(json['flag']);
    String title = json['title'];
    String hash = json['hash'];
    String sendUid = json['sendUid'];
    String receiveUid = json['receiveUid'];
    switch (flag) {
      case MimeFlag.text:
        return TextMessage(
          hash: hash,
          sendUid: sendUid,
          receiveUid: receiveUid,
        );
      case MimeFlag.image:
      case MimeFlag.video:
      case MimeFlag.audio:
      case MimeFlag.file:
        return FileMessage(
          title: title,
          hash: hash,
          sendUid: sendUid,
          receiveUid: receiveUid,
        );
    }
  }

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'message': {
          'flag': _flag.value,
          'title': _title,
          'hash': _hash,
          'sendUid': _sendUid,
          'receiveUid': _receiveUid,
        },
      };

  @override
  Map<String, dynamic> toDebugJson() => {
    ...super.toJson(),
    'message': _toJson,
  };

  Map<String, dynamic> get _toJson => {
        'flag': _flag.value,
        'title': _title,
        'hash': _hash,
        'sendUid': _sendUid,
        'receiveUid': _receiveUid,
      };
}

class TextMessage extends ChatMessage {
  TextMessage({
    required super.hash,
    required super.sendUid,
    required super.receiveUid,
    super.body,
  }) : super(flag: MimeFlag.text);

  String get text {
    return utf8.decode(_body);
  }

  @override
  Map<String, dynamic> get _toJson => {
        ...super._toJson,
        'text': text,
      };
}

class FileMessage extends ChatMessage {
  FileMessage({
    required super.title,
    required super.hash,
    required super.sendUid,
    required super.receiveUid,
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

/// 消息类型的标志
enum MessageFlag {
  auth(1001),
  chat(1002);

  final int value;

  const MessageFlag(this.value);

  static MessageFlag parse(int? value) {
    for (var item in MessageFlag.values) {
      if (item.value == value) return item;
    }
    return MessageFlag.auth;
  }
}
