import 'package:flutter_ui/base/base.dart';

import '../../base/fsm/base.dart';
import '../../base/fsm/machine.dart';
import 'connection.dart';
import 'transition.dart';

/*
 *    Finite States
 *    ~~~~~~~~~~~~~
 *
 *             //===============\\          (Start)          //=============\\
 *             ||               || ------------------------> ||             ||
 *             ||    Default    ||                           ||  Preparing  ||
 *             ||               || <------------------------ ||             ||
 *             \\===============//         (Timeout)         \\=============//
 *                                                               |       |
 *             //===============\\                               |       |
 *             ||               || <-----------------------------+       |
 *             ||     Error     ||          (Error)                 (Connected
 *             ||               || <-----------------------------+   or bound)
 *             \\===============//                               |       |
 *                 A       A                                     |       |
 *                 |       |            //===========\\          |       |
 *                 (Error) +----------- ||           ||          |       |
 *                 |                    ||  Expired  || <--------+       |
 *                 |       +----------> ||           ||          |       |
 *                 |       |            \\===========//          |       |
 *                 |       (Timeout)           |         (Timeout)       |
 *                 |       |                   |                 |       V
 *             //===============\\     (Sent)  |             //=============\\
 *             ||               || <-----------+             ||             ||
 *             ||  Maintaining  ||                           ||    Ready    ||
 *             ||               || ------------------------> ||             ||
 *             \\===============//       (Received)          \\=============//
 *
 */

///  Connection State Machine
///  ~~~~~~~~~~~~~~~~~~~~~~~~
class ConnectionStateMachine
    extends BaseMachine<ConnectionStateMachine, ConnectionStateTransition, ConnectionState>
    implements MachineContext {
  ConnectionStateMachine(Connection connection) : _connectionRef = WeakReference(connection) {
    // init states
    ConnectionStateBuilder builder = createStateBuilder();
    addState(builder.getDefaultState());
    addState(builder.getPreparingState());
    addState(builder.getReadyState());
    addState(builder.getExpiredState());
    addState(builder.getMaintainingState());
    addState(builder.getErrorState());
  }

  final WeakReference<Connection> _connectionRef;

  Connection? get connection => _connectionRef.target;

  @override
  ConnectionStateMachine get context => this;

  // protected
  ConnectionStateBuilder createStateBuilder() =>
      ConnectionStateBuilder(ConnectionStateTransitionBuilder());

}

///  Connection State Delegate
///  ~~~~~~~~~~~~~~~~~~~~~~~~~
///
///  callback when connection state changed
class ConnectionStateDelegate
    implements MachineDelegate<ConnectionStateMachine, ConnectionStateTransition, ConnectionState> {
  @override
  Future<void> enterState(ConnectionState? next, ConnectionStateMachine ctx, DateTime now) async {
    Log.d('进入的状态：next=${next?.name}');
  }

  @override
  Future<void> exitState(ConnectionState? previous, ConnectionStateMachine ctx, DateTime now) async {
    Log.d('退出的状态：previous=${previous?.name}');
  }

  @override
  Future<void> pauseState(ConnectionState? current, ConnectionStateMachine ctx, DateTime now) async {
  }

  @override
  Future<void> resumeState(ConnectionState? current, ConnectionStateMachine ctx, DateTime now) async {
  }

}

enum ConnectionStateOrder {
  init,  // default
  preparing,
  ready,
  maintaining,
  expired,
  error,
}

///  Connection State
///  ~~~~~~~~~~~~~~~~
///
///  Defined for indicating connection state
///
///      DEFAULT     - 'initialized', or sent timeout
///      PREPARING   - connecting or binding
///      READY       - got response recently
///      EXPIRED     - long time, needs maintaining (still connected/bound)
///      MAINTAINING - sent 'PING', waiting for response
///      ERROR       - long long time no response, connection lost
class ConnectionState extends BaseState<ConnectionStateMachine, ConnectionStateTransition> {
  ConnectionState(ConnectionStateOrder order) : super(order.index) {
    name = order.name;
  }

  late final String name;
  DateTime? _enterTime;

  DateTime? get enterTime => _enterTime;

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) {
    if (other is ConnectionState) {
      if (identical(this, other)) {
        // same object
        return true;
      }
      return index == other.index;
    } else if (other is ConnectionStateOrder) {
      return index == other.index;
    } else {
      return false;
    }
  }

  @override
  int get hashCode => index;

  @override
  Future<void> onEnter(State<ConnectionStateMachine, ConnectionStateTransition>? previous,
      ConnectionStateMachine ctx, DateTime now) async {
    _enterTime = now;
  }

  @override
  Future<void> onExit(State<ConnectionStateMachine, ConnectionStateTransition>? next,
      ConnectionStateMachine ctx, DateTime now) async {
    _enterTime = null;
  }

  @override
  Future<void> onPause(ConnectionStateMachine ctx, DateTime now) async {

  }

  @override
  Future<void> onResume(ConnectionStateMachine ctx, DateTime now) async {

  }

}

///  State Builder
///  ~~~~~~~~~~~~~
class ConnectionStateBuilder {
  ConnectionStateBuilder(this.stb);

  final ConnectionStateTransitionBuilder stb;

  // Connection not started yet
  getDefaultState() {
    ConnectionState state = ConnectionState(ConnectionStateOrder.init);
    // Default -> Preparing
    state.addTransition(stb.getDefaultPreparingTransition());
    return state;
  }

  // Connection started, preparing to connect/bind
  getPreparingState() {
    ConnectionState state = ConnectionState(ConnectionStateOrder.preparing);
    // Preparing -> Ready
    state.addTransition(stb.getPreparingReadyTransition());
    // Preparing -> Default
    state.addTransition(stb.getPreparingDefaultTransition());
    return state;
  }

  // Normal state of connection
  getReadyState() {
    ConnectionState state = ConnectionState(ConnectionStateOrder.ready);
    // Ready -> Expired
    state.addTransition(stb.getReadyExpiredTransition());
    // Ready -> Error
    state.addTransition(stb.getReadyErrorTransition());
    return state;
  }

  // Long time no response, need maintaining
  getExpiredState() {
    ConnectionState state = ConnectionState(ConnectionStateOrder.expired);
    // Expired -> Maintaining
    state.addTransition(stb.getExpiredMaintainingTransition());
    // Expired -> Error
    state.addTransition(stb.getExpiredErrorTransition());
    return state;
  }

  // Heartbeat sent, waiting response
  getMaintainingState() {
    ConnectionState state = ConnectionState(ConnectionStateOrder.maintaining);
    // Maintaining -> Ready
    state.addTransition(stb.getMaintainingReadyTransition());
    // Maintaining -> Expired
    state.addTransition(stb.getMaintainingExpiredTransition());
    // Maintaining -> Error
    state.addTransition(stb.getMaintainingErrorTransition());
    return state;
  }

  // Connection lost
  getErrorState() {
    ConnectionState state = ConnectionState(ConnectionStateOrder.error);
    // Error -> Default
    state.addTransition(stb.getErrorDefaultTransition());
    return state;
  }

}
