import 'package:fsm/fsm.dart';

import 'connection.dart';
import 'transition.dart';

///
///   Finite States
///
///            //===============\\          (Start)          //=============\\
///            ||               || ------------------------> ||             ||
///            ||    Default    ||                           ||  Preparing  ||
///            ||               || <------------------------ ||             ||
///            \\===============//         (Timeout)         \\=============//
///                                                              |       |
///            //===============\\                               |       |
///            ||               || <-----------------------------+       |
///            ||     Error     ||          (Error)                 (Connected
///            ||               || <-----------------------------+   or bound)
///            \\===============//                               |       |
///                A       A                                     |       |
///                |       |            //===========\\          |       |
///                (Error) +----------- ||           ||          |       |
///                |                    ||  Expired  || <--------+       |
///                |       +----------> ||           ||          |       |
///                |       |            \\===========//          |       |
///                |       (Timeout)           |         (Timeout)       |
///                |       |                   |                 |       V
///            //===============\\     (Sent)  |             //=============\\
///            ||               || <-----------+             ||             ||
///            ||  Maintaining  ||                           ||    Ready    ||
///            ||               || ------------------------> ||             ||
///            \\===============//       (Received)          \\=============//
///
/// Created by a0010 on 2024/6/21 09:21
/// Socket Connection Machine
class IMStateMachine
    extends BaseMachine<IMStateMachine, IMStateTransition, IMState>
    implements MachineContext {

  IMStateMachine(Connection connection) : _connectionRef = WeakReference(connection) {
    // init states
    IMStateBuilder builder = createStateBuilder();
    addState(builder.getDefault());
    addState(builder.getPreparing());
    addState(builder.getReady());
    addState(builder.getExpired());
    addState(builder.getMaintaining());
    addState(builder.getError());
  }

  final WeakReference<Connection> _connectionRef;
  Connection? get connection => _connectionRef.target;

  @override
  IMStateMachine get context => this;

  // protected
  IMStateBuilder createStateBuilder() =>
      IMStateBuilder(IMStateTransitionBuilder());
}

///  Connection State
///
///  Defined for indicating connection state
///
///      DEFAULT     - 'initialized', or sent timeout
///      PREPARING   - connecting or binding
///      READY       - got response recently
///      EXPIRED     - long time, needs maintaining (still connected/bound)
///      MAINTAINING - sent 'PING', waiting for response
///      ERROR       - long long time no response, connection lost
class IMState extends BaseState<IMStateMachine, IMStateTransition> {
  IMState(IMStateOrder order) : super(order.index) {
    name = order.name;
  }

  late final String name;
  DateTime? _enterTime;

  DateTime? get enterTime => _enterTime;

  @override
  Future<void> onEnter(FiniteState<IMStateMachine, IMStateTransition>? previous,
      IMStateMachine ctx, DateTime now) async {
    _enterTime = now;
  }

  @override
  Future<void> onExit(FiniteState<IMStateMachine, IMStateTransition>? next,
      IMStateMachine ctx, DateTime now) async {
    _enterTime = null;
  }

  @override
  Future<void> onPause(IMStateMachine ctx, DateTime now) async {
  }

  @override
  Future<void> onResume(IMStateMachine ctx, DateTime now) async {
  }

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) {
    if (other is IMState) {
      if (identical(this, other)) {
        // same object
        return true;
      }
      return index == other.index;
    } else if (other is IMStateOrder) {
      return index == other.index;
    } else {
      return false;
    }
  }

  @override
  int get hashCode => index;
}

///  State Builder
class IMStateBuilder {
  IMStateBuilder(this.stb);

  final IMStateTransitionBuilder stb;

  // Connection not started yet
  IMState getDefault() {
    IMState state = IMState(IMStateOrder.init);
    // Default -> Preparing
    state.addTransition(stb.getDefaultPreparingTransition());
    return state;
  }
  // Connection started, preparing to connect/bind
  IMState getPreparing() {
    IMState state = IMState(IMStateOrder.preparing);
    // Preparing -> Ready
    state.addTransition(stb.getPreparingConnectingTransition());
    // Preparing -> Default
    state.addTransition(stb.getPreparingDefaultTransition());
    return state;
  }
  // Normal state of connection
  IMState getReady() {
    IMState state = IMState(IMStateOrder.ready);
    // Ready -> Expired
    state.addTransition(stb.getConnectingConnectedTransition());
    // Ready -> Error
    state.addTransition(stb.getReadyErrorTransition());
    return state;
  }
  // Long time no response, need maintaining
  IMState getExpired() {
    IMState state = IMState(IMStateOrder.expired);
    // Expired -> Maintaining
    state.addTransition(stb.getExpiredMaintainingTransition());
    // Expired -> Error
    state.addTransition(stb.getExpiredErrorTransition());
    return state;
  }
  // Heartbeat sent, waiting response
  IMState getMaintaining() {
    IMState state = IMState(IMStateOrder.maintaining);
    // Maintaining -> Ready
    state.addTransition(stb.getMaintainingReadyTransition());
    // Maintaining -> Error
    state.addTransition(stb.getMaintainingErrorTransition());
    return state;
  }
  // Connection lost
  IMState getError() {
    IMState state = IMState(IMStateOrder.error);
    // Error -> Default
    state.addTransition(stb.getErrorDefaultTransition());
    return state;
  }
}

enum IMStateOrder {
  init,  // default
  preparing,
  ready,
  maintaining,
  expired,
  error,
}
