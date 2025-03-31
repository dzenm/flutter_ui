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

  /// Preparing -> Connecting
  IMStateTransition getPreparingConnectingTransition() => IMStateTransition(
    IMStateOrder.ready, (machine, now) {
    Connection? connection = machine.connection;
    // connected or bound, change state to 'ready'
    return connection != null && connection.isConnecting;
  });
  /// Preparing -> Default
  IMStateTransition getPreparingDefaultTransition() => IMStateTransition(
    IMStateOrder.init, (machine, now) {
    Connection? connection = machine.connection;
    // connection stopped, change state to 'not_connect'
    return connection == null || connection.isClosed;
  });

  /// Connecting -> Connected
  IMStateTransition getConnectingConnectedTransition() => IMStateTransition(
    IMStateOrder.expired, (machine, now) {
    Connection? connection = machine.connection;
    return connection != null && connection.isConnected;
  });
  /// Connecting -> Error
  IMStateTransition getReadyErrorTransition() => IMStateTransition(
    IMStateOrder.error, (machine, now) {
    Connection? connection = machine.connection;
    // connection lost, change state to 'error'
    return connection == null || !connection.isConnected;
  });

  /// Connected -> isTransiting
  IMStateTransition getExpiredMaintainingTransition() => IMStateTransition(
    IMStateOrder.maintaining, (machine, now) {
    Connection? connection = machine.connection;
    if (connection == null || !connection.isAlive) {
      return false;
    }
    // connection still alive, and
    // sent recently, change state to 'maintaining'
    return connection.isTransiting;
  });
  /// Connected -> Error
  IMStateTransition getExpiredErrorTransition() => IMStateTransition(
    IMStateOrder.error, (machine, now) {
    Connection? connection = machine.connection;
    if (connection == null || !connection.isAlive) {
      return true;
    }
    // connection lost, or
    // long long time no response, change state to 'error'
    return connection.isConnecting;
  });

  /// isTransiting -> Connected
  IMStateTransition getMaintainingReadyTransition() => IMStateTransition(
    IMStateOrder.ready, (machine, now) {
    Connection? connection = machine.connection;
    if (connection == null || !connection.isAlive) {
      return false;
    }
    return connection.isConnecting;
  });
  /// isTransiting -> Error
  IMStateTransition getMaintainingErrorTransition() => IMStateTransition(
    IMStateOrder.error, (machine, now) {
    Connection? connection = machine.connection;
    if (connection == null || !connection.isAlive) {
      return true;
    }
    return connection.isConnecting;
  });

  /// Error -> Default
  IMStateTransition getErrorDefaultTransition() => IMStateTransition(
    IMStateOrder.init, (machine, now) {
    Connection? connection = machine.connection;
    if (connection == null || !connection.isAlive) {
      return false;
    }
    return connection.isConnecting;
  });
}
