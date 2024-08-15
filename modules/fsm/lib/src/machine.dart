import 'runner.dart';

/// Abstract design

///  State Machine Context
abstract interface class MachineContext {

}

///  State Transition
///
/// @param <C> - context
abstract interface class StateTransition<C extends MachineContext> {

  ///  Evaluate the current state
  ///
  /// @param context - context (machine)
  /// @param now     - current time
  /// @return true when current state should be changed
  bool evaluate(C context, DateTime now);
}

///  Finite State
///
/// @param <C> - context
/// @param <T> - transition
abstract interface class FiniteState<C extends MachineContext, T extends StateTransition<C>> {

  ///  Called by machine.tick() to evaluate each transitions
  ///
  /// @param context - context (machine)
  /// @param now     - current time
  /// @return success transition, or null to stay the current state
  T? evaluate(C context, DateTime now);

  //-------- events

  ///  Called after new state entered
  ///
  /// @param previous - old state
  /// @param context  - context (machine)
  /// @param now      - current time
  Future<void> onEnter(FiniteState<C, T>? previous, C context, DateTime now);

  ///  Called before old state exited
  ///
  /// @param next    - new state
  /// @param context - context (machine)
  /// @param now     - current time
  Future<void> onExit(FiniteState<C, T>? next, C context, DateTime now);

  ///  Called before current state paused
  ///
  /// @param context - context (machine)
  /// @param now     - current time
  Future<void> onPause(C context, DateTime now);

  ///  Called after current state resumed
  ///
  /// @param context - context (machine)
  /// @param now     - current time
  Future<void> onResume(C context, DateTime now);
}

///  State Machine Delegate
///
/// @param <S> - state
/// @param <C> - context
/// @param <T> - transition
abstract interface class MachineDelegate<C extends MachineContext, T extends StateTransition<C>, S extends FiniteState<C, T>> {

  ///  Called before new state entered
  ///  (get current state from context)
  ///
  /// @param next     - new state
  /// @param context  - context (machine)
  /// @param now      - current time (milliseconds, from Jan 1, 1970 UTC)
  Future<void> enterState(S? next, C context, DateTime now);

  ///  Called after old state exited
  ///  (get current state from context)
  ///
  /// @param previous - old state
  /// @param context  - context (machine)
  /// @param now      - current time (milliseconds, from Jan 1, 1970 UTC)
  Future<void> exitState(S? previous, C context, DateTime now);

  ///  Called after current state paused
  ///
  /// @param current  - current state
  /// @param context  - context (machine)
  /// @param now      - current time (milliseconds, from Jan 1, 1970 UTC)
  Future<void> pauseState(S? current, C context, DateTime now);

  ///  Called before current state resumed
  ///
  /// @param current  - current state
  /// @param context  - context (machine)
  /// @param now      - current time (milliseconds, from Jan 1, 1970 UTC)
  Future<void> resumeState(S? current, C context, DateTime now);
}

///  Finite [FiniteState] machine
///
/// @param <S> - state
/// @param <C> - context
/// @param <T> - transition
abstract interface class Machine<C extends MachineContext, T extends StateTransition<C>, S extends FiniteState<C, T>>
    implements Ticker {

  S? get currentState;

  ///  Change current state to 'default'
  Future<void> start();

  ///  Change current state to null
  Future<void> stop();

  ///  Pause machine, current state not change
  Future<void> pause();

  ///  Resume machine with current state
  Future<void> resume();

}


//// Base design

///  Transition with the index of target state
abstract class BaseTransition<C extends MachineContext>
    implements StateTransition<C> {
  final int target; // target state index
  BaseTransition(this.target);
}

///  State with transitions
abstract class BaseState<C extends MachineContext, T extends StateTransition<C>>
    implements FiniteState<C, T> {

  BaseState(this.index);

  final int index;
  final List<T> _transitions = [];

  void addTransition(T trans) {
    assert(!_transitions.contains(trans), 'Transition exists: $trans');
    _transitions.add(trans);
  }

  @override
  T? evaluate(C context, DateTime now) {
    for (T trans in _transitions) {
      if (trans.evaluate(context, now)) {
        // OK, get target state from this transition
        return trans;
      }
    }
    return null;
  }
}

///  Machine Status
enum _Status {
  stopped,
  running,
  paused,
}

/// [Machine] handle [FiniteState]
abstract class BaseMachine<C extends MachineContext, T extends BaseTransition<C>, S extends BaseState<C, T>>
    implements Machine<C, T, S> {

  final List<S?> _states = [];

  _Status _status = _Status.stopped;

  WeakReference<MachineDelegate<C, T, S>>? _delegateRef;
  MachineDelegate<C, T, S>? get delegate => _delegateRef?.target;
  set delegate(MachineDelegate<C, T, S>? handler) =>
      _delegateRef = handler == null ? null : WeakReference(handler);

  // protected
  C get context;  // the machine itself

  //  States
  S? addState(S newState) {
    int index = newState.index;
    assert(index >= 0, 'FiniteState index error: index=$index');
    if (index < _states.length) {
      // WARNING: return old state that was replaced
      S? old = _states[index];
      _states[index] = newState;
      return old;
    }
    // filling empty spaces
    int spaces = index - _states.length;
    for (int i = 0; i < spaces; ++i) {
      _states.add(null);
    }
    // append the new state to the tail
    _states.add(newState);
    return null;
  }

  S? getState(int index) => _states[index];

  // protected
  S? get defaultState => _states[0];

  // protected
  S? getTargetState(T trans) =>
      _states[trans.target];  // Get target state of this transition

  @override
  S? get currentState => _current < 0 ? null : _states[_current];
  int _current = -1;  // current state index
  set currentState(S? newState) => _current = newState?.index ?? -1;

  ///  Exit current state, and enter new state
  ///
  /// @param newState - next state
  /// @param now     - current time (milliseconds, from Jan 1, 1970 UTC)
  Future<bool> _changeState(S? newState, DateTime now) async {
    S? oldState = currentState;
    if (oldState == null) {
      if (newState == null) {
        // state not changed
        return false;
      }
    } else if (oldState == newState) {
      // state not change
      return false;
    }

    C myContext = context;
    MachineDelegate<C, T, S>? callback = delegate;

    //  Events before state changed
    if (callback != null) {
      // prepare for changing current state to the new one,
      // the delegate can get old state via ctx if need
      await callback.enterState(newState, myContext, now);
    }
    if (oldState != null) {
      await oldState.onExit(newState, myContext, now);
    }

    //  Change current state
    currentState = newState;
    //  Events after state changed
    if (newState != null) {
      await newState.onEnter(oldState, myContext, now);
    }
    if (callback != null) {
      // handle after the current state changed,
      // the delegate can get new state via ctx if need
      await callback.exitState(oldState, myContext, now);
    }
    return true;
  }

  //  Actions
  @override
  Future<void> start() async {
    ///  start machine from default state
    DateTime now = DateTime.now();
    bool ok = await _changeState(defaultState, now);
    assert(ok, 'Failed to change default state');
    _status = _Status.running;
  }

  @override
  Future<void> stop() async {
    ///  stop machine and set current state to null
    _status = _Status.stopped;
    DateTime now = DateTime.now();
    await _changeState(null, now);  // force current state to null
  }

  @override
  Future<void> pause() async {
    ///  pause machine, current state not change
    DateTime now = DateTime.now();
    C myContext = context;
    S? current = currentState;
    //  Events before state paused
    await current?.onPause(myContext, now);
    //  Pause current state
    _status = _Status.paused;
    //  Events after state paused
    await delegate?.pauseState(current, myContext, now);
  }

  @override
  Future<void> resume() async {
    ///  resume machine with current state
    DateTime now = DateTime.now();
    C myContext = context;
    S? current = currentState;
    //  Events before state resumed
    await delegate?.resumeState(current, myContext, now);
    //  Resume current state
    _status = _Status.running;
    //  Events after state resumed
    await current?.onResume(myContext, now);
  }

  //  Ticker
  @override
  Future<void> tick(DateTime now, int elapsed) async {
    ///  Drive the machine running forward
    C myContext = context;
    S? state = currentState;
    if (state != null && _status == _Status.running) {
      T? trans = state.evaluate(myContext, now);
      if (trans != null) {
        state = getTargetState(trans);
        assert(state != null, 'Target state error: $trans');
        await _changeState(state, now);
      }
    }
  }
}


/// [Machine] handle [FiniteState] with auto [Ticker]
abstract class AutoMachine<C extends MachineContext, T extends BaseTransition<C>, S extends BaseState<C, T>>
    extends BaseMachine<C, T, S> {

  @override
  Future<void> start() async {
    await super.start();
    PrimeMetronome timer = PrimeMetronome();
    timer.addTicker(this);
  }

  @override
  Future<void> stop() async {
    PrimeMetronome timer = PrimeMetronome();
    timer.removeTicker(this);
    await super.stop();
  }

  @override
  Future<void> pause() async {
    PrimeMetronome timer = PrimeMetronome();
    timer.removeTicker(this);
    await super.pause();
  }

  @override
  Future<void> resume() async {
    await super.resume();
    PrimeMetronome timer = PrimeMetronome();
    timer.addTicker(this);
  }
}