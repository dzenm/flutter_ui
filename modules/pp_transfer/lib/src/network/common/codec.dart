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
const kHeaderLen = 12;

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
    Uint8List json = input.encode();
    int jsonLength = json.length;
    Uint8List body = input.body;
    int bodyLength = body.length;

    Uint8List head = Uint8List(kHeaderLen);
    ByteData byteData = ByteData.view(head.buffer);
    byteData.setInt16(0, kMagicCode);
    byteData.setInt16(2, kVersionCode);
    byteData.setInt32(4, jsonLength);
    byteData.setInt32(8, bodyLength); // 总长度
    List<int> buffer = head + json + body;
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
    int jsonLength = byteData.getInt32(4);
    int bodyLength = byteData.getInt32(8);
    List<int> json = input.sublist(
      kHeaderLen,
      kHeaderLen + jsonLength,
    );
    List<int> body = input.sublist(
      kHeaderLen + jsonLength,
      kHeaderLen + jsonLength + bodyLength,
    );
    return Message.decode(json)..setBody(body);
  }
}

bool isFullMessage(List<int> data) {
  VerifyPacketData verify = VerifyPacketData();
  if (!verify.isFull(data)) {
    return false;
  }
  if (!verify.isCorrectHeader) {
    return false;
  }
  return true;
}

/// 校验包数据
class VerifyPacketData {
  int _magicCode = kMagicCode; // 2 byte，客户端口令
  int _version = kVersionCode; // 2 byte，版本号
  int _jsonLength = 0; // 4 byte，json数据长度
  int _bodyLength = 0; // 4 byte，消息体数据长度

  int _length = 0; // 消息体总长度

  /// 是否是完整的数据
  bool isFull(List<int> data) {
    // 长度比规定的包头更短，则无法解析包头
    if (data.length < kHeaderLen) return false;
    // 解析包头，获取数据长度
    Int8List cacheData = Int8List.fromList(data);
    ByteData byteData = cacheData.buffer.asByteData();
    int magicCode = byteData.getInt16(0);
    _magicCode = magicCode;
    int version = byteData.getInt16(2);
    _version = version;
    int jsonLength = byteData.getInt32(4);
    _jsonLength = jsonLength;
    int bodyLength = byteData.getInt32(8);
    _bodyLength = bodyLength;
    _length = jsonLength + bodyLength;

    // 长度比指定的消息长度小
    if (kHeaderLen + _length > data.length) return false;
    return true;
  }

  /// 是否是正确的Header
  bool get isCorrectHeader {
    return _magicCode == kMagicCode && _version == kVersionCode;
  }
}
