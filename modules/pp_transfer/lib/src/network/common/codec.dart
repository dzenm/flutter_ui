import 'dart:convert';
import 'dart:typed_data';

import 'package:pp_transfer/pp_transfer.dart';

import 'message.dart';

///
/// Created by a0010 on 2025/3/26 13:12
///
/// 魔数，可以通过配置获取
const kMagicCode = 0x11;

/// 版本号
const kVersionCode = 0x01;

/// 协议头长度
const kHeaderLen = 14;

const MessageCodec mc = MessageCodec();

/// 消息编码解码器
final class MessageCodec extends Codec<Message, List<int>> {
  const MessageCodec();

  @override
  Converter<List<int>, Message> get decoder => BytesConvertMessage();

  @override
  Converter<Message, List<int>> get encoder => MessageConvertBytes();
}

/// 消息转化为字节数据
class MessageConvertBytes extends Converter<Message, List<int>> {
  @override
  List<int> convert(Message input) {
    Uint8List title = input.titleData;
    int titleLength = title.length;
    Uint8List body = input.body;
    int bodyLength = body.length;
    int mimeFlag = input.flag.value;

    Uint8List head = Uint8List(kHeaderLen);
    ByteData byteData = ByteData.view(head.buffer);
    byteData.setInt16(0, kMagicCode);
    byteData.setInt16(2, kVersionCode);
    byteData.setInt16(4, mimeFlag);
    byteData.setInt16(6, titleLength);
    byteData.setInt32(10, bodyLength); // 总长度
    List<int> buffer = head + title + body;
    return buffer;
  }
}

/// 字节数据转化为消息
class BytesConvertMessage extends Converter<List<int>, Message> {
  @override
  Message convert(List<int> input) {
    Int8List cacheData = Int8List.fromList(input);
    ByteData byteData = cacheData.buffer.asByteData();
    int magicCode = byteData.getInt16(0);
    int version = byteData.getInt16(2);
    int mimeFlag = byteData.getInt16(4);
    int titleLength = byteData.getInt32(6);
    int bodyLength = byteData.getInt32(10);
    List<int> title = input.sublist(
      kHeaderLen,
      kHeaderLen + titleLength,
    );
    List<int> body = input.sublist(
      kHeaderLen + titleLength,
      kHeaderLen + titleLength + bodyLength,
    );

    return Message.build(
      flag: MimeFlag.parse(mimeFlag),
      title: utf8.decode(title),
      body: body,
    );
  }
}

/// 校验包数据
class VerifyPacketData {
  int _magicCode = kMagicCode; // 2 byte，客户端口令
  int _version = kVersionCode; // 2 byte，版本号
  int _mimeFlag = 0; // 2 byte，传输的类型
  int _fileNameLength = 0; // 4 byte，文件名称长度
  int _fileLength = 0; // 4 byte，消息体长度
  int _length = 0; // 4 byte，消息体长度

  /// 是否是完整的数据
  bool isFull(List<int> data) {
    // 长度比规定的头长度小
    if (data.length < kHeaderLen) return false;
    // 解析包头，获取数据长度
    Int8List cacheData = Int8List.fromList(data);
    ByteData byteData = cacheData.buffer.asByteData();
    int magicCode = byteData.getInt16(0);
    _magicCode = magicCode;
    int version = byteData.getInt16(2);
    _version = version;
    int mimeFlag = byteData.getInt16(4);
    _mimeFlag = mimeFlag;
    int fileNameLength = byteData.getInt32(6);
    _fileNameLength = fileNameLength;
    int fileLength = byteData.getInt32(10);
    _fileLength = fileLength;
    _length = fileNameLength + fileLength;

    // 长度比指定的消息长度小
    if (kHeaderLen + _length > data.length) return false;
    return true;
  }

  /// 是否是正确的Header
  bool get isCorrectHeader {
    return _magicCode == kMagicCode && _version == kVersionCode;
  }
}