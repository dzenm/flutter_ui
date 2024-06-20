import '../../base/fsm/base.dart';
import 'connection.dart';
import 'state.dart';

///  Connection State Transition
class ConnectionStateTransition extends BaseTransition<ConnectionStateMachine> {
  ConnectionStateTransition(ConnectionStateOrder order, this.eval) : super(order.index);

  final ConnectionStateEvaluate eval;

  @override
  bool evaluate(ConnectionStateMachine ctx, DateTime now) => eval(ctx, now);

}

typedef ConnectionStateEvaluate = bool Function(ConnectionStateMachine ctx, DateTime now);

///  Transition Builder
class ConnectionStateTransitionBuilder {

  // Default -> Preparing
  getDefaultPreparingTransition() => ConnectionStateTransition(
    ConnectionStateOrder.preparing, (ctx, now) {
      Connection? conn = ctx.connection;
      // connection started? change state to 'preparing'
      return !(conn == null || conn.isClosed);
    },
  );

  // Preparing -> Ready
  getPreparingReadyTransition() => ConnectionStateTransition(
    ConnectionStateOrder.ready, (ctx, now) {
      Connection? conn = ctx.connection;
      // connected or bound, change state to 'ready'
      return conn != null && conn.isAlive;
    },
  );

  // Preparing -> Default
  getPreparingDefaultTransition() => ConnectionStateTransition(
    ConnectionStateOrder.init, (ctx, now) {
      Connection? conn = ctx.connection;
      // connection stopped, change state to 'not_connect'
      return conn == null || conn.isClosed;
    },
  );

  // Ready -> Expired
  getReadyExpiredTransition() => ConnectionStateTransition(
    ConnectionStateOrder.expired, (ctx, now) {
      Connection? conn = ctx.connection;
      if (conn == null || !conn.isAlive) {
        return false;
      }
      TimedConnection timed = conn as TimedConnection;
      // connection still alive, but
      // long time no response, change state to 'maintain_expired'
      return !timed.isReceivedRecently(now);
    },
  );

  // Ready -> Error
  getReadyErrorTransition() => ConnectionStateTransition(
    ConnectionStateOrder.error, (ctx, now) {
      Connection? conn = ctx.connection;
      // connection lost, change state to 'error'
      return conn == null || !conn.isAlive;
    },
  );

  // Expired -> Maintaining
  getExpiredMaintainingTransition() => ConnectionStateTransition(
    ConnectionStateOrder.maintaining, (ctx, now) {
      Connection? conn = ctx.connection;
      if (conn == null || !conn.isAlive) {
        return false;
      }
      TimedConnection timed = conn as TimedConnection;
      // connection still alive, and
      // sent recently, change state to 'maintaining'
      return timed.isSentRecently(now);
    },
  );

  // Expired -> Error
  getExpiredErrorTransition() => ConnectionStateTransition(
    ConnectionStateOrder.error, (ctx, now) {
      Connection? conn = ctx.connection;
      if (conn == null || !conn.isAlive) {
        return true;
      }
      TimedConnection timed = conn as TimedConnection;
      // connection lost, or
      // long long time no response, change state to 'error'
      return timed.isNotReceivedLongTimeAgo(now);
    },
  );

  // Maintaining -> Ready
  getMaintainingReadyTransition() => ConnectionStateTransition(
    ConnectionStateOrder.ready, (ctx, now) {
      Connection? conn = ctx.connection;
      if (conn == null || !conn.isAlive) {
        return false;
      }
      TimedConnection timed = conn as TimedConnection;
      // connection still alive, and
      // received recently, change state to 'ready'
      return timed.isReceivedRecently(now);
    },
  );

  // Maintaining -> Expired
  getMaintainingExpiredTransition() => ConnectionStateTransition(
    ConnectionStateOrder.expired, (ctx, now) {
      Connection? conn = ctx.connection;
      if (conn == null || !conn.isAlive) {
        return false;
      }
      TimedConnection timed = conn as TimedConnection;
      // connection still alive, but
      // long time no sending, change state to 'maintain_expired'
      return !timed.isSentRecently(now);
    },
  );

  // Maintaining -> Error
  getMaintainingErrorTransition() => ConnectionStateTransition(
    ConnectionStateOrder.error, (ctx, now) {
      Connection? conn = ctx.connection;
      if (conn == null || !conn.isAlive) {
        return true;
      }
      TimedConnection timed = conn as TimedConnection;
      // connection lost, or
      // long long time no response, change state to 'error'
      return timed.isNotReceivedLongTimeAgo(now);
    },
  );

  // Error -> Default
  getErrorDefaultTransition() => ConnectionStateTransition(
    ConnectionStateOrder.init, (ctx, now) {
      Connection? conn = ctx.connection;
      if (conn == null || !conn.isAlive) {
        return false;
      }
      TimedConnection timed = conn as TimedConnection;
      // connection still alive, and
      // can receive data during this state
      ConnectionState? current = ctx.currentState;
      DateTime? enter = current?.enterTime;
      DateTime? last = timed.lastReceivedTime;
      if (enter == null) {
        assert(false, 'should not happen');
        return true;
      }
      return last != null && enter.isBefore(last);
    },
  );

}
