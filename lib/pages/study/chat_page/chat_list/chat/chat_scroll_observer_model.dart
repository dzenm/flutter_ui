class ChatScrollObserverHandlePositionResultModel {
  /// The type of processing location.
  final ChatScrollObserverHandlePositionType type;

  /// The mode of processing.
  final ChatScrollObserverHandleMode mode;

  /// The number of messages added.
  final int changeCount;

  ChatScrollObserverHandlePositionResultModel({
    required this.type,
    required this.mode,
    required this.changeCount,
  });
}

enum ChatScrollObserverHandlePositionType {
  /// Nothing will be done.
  none,

  /// Keep the current chat location.
  keepPosition,
}

enum ChatScrollObserverHandleMode {
  /// Regular mode
  /// Such as inserting or deleting messages.
  normal,

  /// Generative mode
  /// Such as ChatGPT streaming messages.
  generative,

  /// Specified mode
  /// You can specify the index of the reference message in this mode.
  specified,
}
