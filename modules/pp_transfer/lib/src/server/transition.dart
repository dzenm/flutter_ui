import 'package:fsm/fsm.dart';
import 'connection.dart';
import 'state.dart';

typedef IMStateEvaluate = bool Function(IMStateMachine ctx, DateTime now);

///
/// Created by a0010 on 2024/6/21 09:22
///
///  Connection State Transition
class IMStateTransition extends BaseTransition<IMStateMachine> {
  IMStateTransition(IMStateOrder order, this.eval) : super(order.index);

  final IMStateEvaluate eval;

  @override
  bool evaluate(IMStateMachine ctx, DateTime now) => eval(ctx, now);
}

/// [IMStateOrder] Current State，[IMStateTransition] next State
/// Transition Builder
class IMStateTransitionBuilder {

  /// Default -> Preparing
  IMStateTransition  getDefaultPreparingTransition() => IMStateTransition(
    IMStateOrder.preparing, (machine, now) {
    Connection? connection = machine.connection;
    // connection started? change state to 'preparing'
    return connection != null && !connection.isClosed;
  });

  /// Preparing -> Ready
  IMStateTransition getPreparingReadyTransition() => IMStateTransition(
    IMStateOrder.ready, (machine, now) {
    Connection? connection = machine.connection;
    // connected or bound, change state to 'ready'
    return connection != null && connection.isAlive;
  });
  /// Preparing -> Default
  IMStateTransition getPreparingDefaultTransition() => IMStateTransition(
    IMStateOrder.init, (machine, now) {
    Connection? connection = machine.connection;
    // connection stopped, change state to 'not_connect'
    return connection == null || connection.isClosed;
  });

  /// Ready -> Expired
  IMStateTransition getReadyExpiredTransition() => IMStateTransition(
    IMStateOrder.expired, (machine, now) {
    Connection? connection = machine.connection;
    if (connection == null || !connection.isAlive) {
      return false;
    }
    TimedConnection timed = connection as TimedConnection;
    // connection still alive, but
    // long time no response, change state to 'maintain_expired'
    return !timed.isReceivedRecently(now);
  });
  /// Ready -> Error
  IMStateTransition getReadyErrorTransition() => IMStateTransition(
    IMStateOrder.error, (machine, now) {
    Connection? connection = machine.connection;
    // connection lost, change state to 'error'
    return connection == null || !connection.isAlive;
  });

  /// Expired -> Maintaining
  IMStateTransition getExpiredMaintainingTransition() => IMStateTransition(
    IMStateOrder.maintaining, (machine, now) {
    Connection? connection = machine.connection;
    if (connection == null || !connection.isAlive) {
      return false;
    }
    TimedConnection timed = connection as TimedConnection;
    // connection still alive, and
    // sent recently, change state to 'maintaining'
    return timed.isSentRecently(now);
  });
  /// Expired -> Error
  IMStateTransition getExpiredErrorTransition() => IMStateTransition(
    IMStateOrder.error, (machine, now) {
    Connection? connection = machine.connection;
    if (connection == null || !connection.isAlive) {
      return true;
    }
    TimedConnection timed = connection as TimedConnection;
    // connection lost, or
    // long long time no response, change state to 'error'
    return timed.isNotReceivedLongTimeAgo(now);
  });

  /// Maintaining -> Ready
  IMStateTransition getMaintainingReadyTransition() => IMStateTransition(
    IMStateOrder.ready, (machine, now) {
    Connection? connection = machine.connection;
    if (connection == null || !connection.isAlive) {
      return false;
    }
    TimedConnection timed = connection as TimedConnection;
    // connection still alive, and
    // received recently, change state to 'ready'
    return timed.isReceivedRecently(now);
  });
  /// Maintaining -> Expired
  IMStateTransition getMaintainingExpiredTransition() => IMStateTransition(
    IMStateOrder.expired, (machine, now) {
    Connection? connection = machine.connection;
    if (connection == null || !connection.isAlive) {
      return false;
    }
    TimedConnection timed = connection as TimedConnection;
    // connection still alive, but
    // long time no sending, change state to 'maintain_expired'
    return !timed.isSentRecently(now);
  });
  /// Maintaining -> Error
  IMStateTransition getMaintainingErrorTransition() => IMStateTransition(
    IMStateOrder.error, (machine, now) {
    Connection? connection = machine.connection;
    if (connection == null || !connection.isAlive) {
      return true;
    }
    TimedConnection timed = connection as TimedConnection;
    // connection lost, or
    // long long time no response, change state to 'error'
    return timed.isNotReceivedLongTimeAgo(now);
  });

  /// Error -> Default
  IMStateTransition getErrorDefaultTransition() => IMStateTransition(
    IMStateOrder.init, (machine, now) {
    Connection? connection = machine.connection;
    if (connection == null || !connection.isAlive) {
      return false;
    }
    TimedConnection timed = connection as TimedConnection;
    // connection still alive, and
    // can receive data during this state
    IMState? current = machine.currentState;
    DateTime? enter = current?.enterTime;
    DateTime? last = timed.lastReceivedTime;
    if (enter == null) {
      assert(false, 'should not happen');
      return true;
    }
    return last != null && enter.isBefore(last);
  });
}
