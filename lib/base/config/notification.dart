import 'log.dart';

///  Notification observer
abstract class Observer {

  Future<void> onReceive(Message message);
}

///  Message object with name, sender and extra info
class Message {
  Message(this.name, {this.sender, this.extras});

  final String name;
  final dynamic sender;
  final Map? extras;

  @override
  String toString() {
    return '$runtimeType={'
        'name=$name, '
        'sender=$sender, '
        'extras=$extras}';
  }

}

///  Notification center
class NotificationCenter {
  factory NotificationCenter() => _instance;
  static final NotificationCenter _instance = NotificationCenter._internal();
  NotificationCenter._internal();

  var center = _BaseCenter();

  ///  Add observer with notification name
  ///
  /// @param observer - who will receive notification
  /// @param name     - notification name
  void addObserver(Observer observer, String name) {
    center.addObserver(observer, name);
  }

  ///  Remove observer for notification name
  ///
  /// @param observer - who will receive notification
  /// @param name     - notification name
  void removeObserver(Observer observer, [String? name]) {
    center.removeObserver(observer, name);
  }

  ///  Post a notification with extra info
  ///
  /// @param name   - notification name
  /// @param sender - who post this message
  /// @param info   - extra info
  Future<void> postNotification(String name, dynamic sender, [Map? info]) async {
    await center.postNotification(name, sender, info);
  }

  ///  Post a notification
  ///
  /// @param message - message object
  Future<void> post(Message message) async {
    await center.post(message);
  }

}

class _BaseCenter with Logging {

  // name => WeakSet<Observer>
  final Map<String, Set<Observer>> _observers = {};

  ///  Add observer with notification name
  ///
  /// @param observer - listener
  /// @param name     - notification name
  void addObserver(Observer observer, String name) {
    Set<Observer>? listeners = _observers[name];
    if (listeners == null) {
      listeners = {};
      listeners.add(observer);
      _observers[name] = listeners;
    } else {
      listeners.add(observer);
    }
  }

  ///  Remove observer from notification center
  ///
  /// @param observer - listener
  /// @param name     - notification name
  void removeObserver(Observer observer, [String? name]) {
    if (name == null) {
      // 1. remove from all observer set
      _observers.forEach((key, listeners) {
        listeners.remove(observer);
      });
      // 2. remove empty set
      _observers.removeWhere((key, listeners) => listeners.isEmpty);
    } else {
      // 3. get listeners by name
      Set<Observer>? listeners = _observers[name];
      if (listeners != null && listeners.remove(observer)) {
        // observer removed
        if (listeners.isEmpty) {
          _observers.remove(name);
        }
      }
    }
  }

  ///  Post notification with name
  ///
  /// @param name     - notification name
  /// @param sender   - notification sender
  /// @param info     - extra info
  Future<void> postNotification(String name, dynamic sender, [Map? extras]) async {
    return await post(Message(name, sender: sender, extras: extras));
  }

  Future<void> post(Message message) async {
    Set<Observer>? listeners = _observers[message.name]?.toSet();
    if (listeners == null) {
      logDebug('No listeners for notification: ${message.name}');
      return;
    }
    List<Future> tasks = [];
    for (Observer item in listeners) {
      try {
        tasks.add(item.onReceive(message).onError((error, st) =>
            Log.e('Observer error: $error, $st, $message')
        ));
      } catch (ex, stackTrace) {
        logError('Observer error: $ex, $stackTrace, $message');
      }
    }
    // wait all tasks finished
    await Future.wait(tasks);
  }

}
