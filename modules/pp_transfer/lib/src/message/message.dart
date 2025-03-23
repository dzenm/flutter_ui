abstract class IMessage {
  final String chattingUid;
  final String sessionUid;
  final String userUid;
  final String receiveUid;

  IMessage({
    required this.chattingUid,
    required this.sessionUid,
    required this.userUid,
    required this.receiveUid,
    String? text,
  }) : _text = text ?? '';

  String get text => _text;
  String _text;
  void setText(String text) => _text = text;
}
