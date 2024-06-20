import 'package:flutter_ui/base/base.dart';

import 'machine.dart';

///  Transition with the index of target state
abstract class BaseTransition<C extends MachineContext>
    implements StateTransition<C> {
  final int target; // target state index
  BaseTransition(this.target);
}

///  State with transitions
abstract class BaseState<C extends MachineContext, T extends StateTransition<C>>
    implements State<C, T> {

  BaseState(this.index);

  final int index;
  final List<T> _transitions = [];

  void addTransition(T trans) {
    assert(!_transitions.contains(trans), 'transition exists: $trans');
    _transitions.add(trans);
  }

  @override
  T? evaluate(C ctx, DateTime now) {
    for (T trans in _transitions) {
      if (trans.evaluate(ctx, now)) {
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

abstract class BaseMachine<C extends MachineContext, T extends BaseTransition<C>, S extends BaseState<C, T>>
    implements Machine<C, T, S> {

  final List<S?> _states = [];
  int _current = -1;  // current state index

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
    assert(index >= 0, 'state index error: $index');
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

  // private
  set currentState(S? newState) => _current = newState?.index ?? -1;

  ///  Exit current state, and enter new state
  ///
  /// @param newState - next state
  /// @param now     - current time (milliseconds, from Jan 1, 1970 UTC)
  Future<bool> _changeState(S? newState, DateTime now) async {
    Log.d('改变状态：newState=$newState');
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

    C ctx = context;
    MachineDelegate<C, T, S>? callback = delegate;

    //  Events before state changed
    if (callback != null) {
      // prepare for changing current state to the new one,
      // the delegate can get old state via ctx if need
      await callback.enterState(newState, ctx, now);
    }
    if (oldState != null) {
      await oldState.onExit(newState, ctx, now);
    }

    //  Change current state
    currentState = newState;
    //  Events after state changed
    if (newState != null) {
      await newState.onEnter(oldState, ctx, now);
    }
    if (callback != null) {
      // handle after the current state changed,
      // the delegate can get new state via ctx if need
      await callback.exitState(oldState, ctx, now);
    }
    return true;
  }

  //  Actions
  @override
  Future<void> start() async {
    ///  start machine from default state
    DateTime now = DateTime.now();
    bool ok = await _changeState(defaultState, now);
    assert(ok, 'failed to change default state');
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
    C ctx = context;
    S? current = currentState;
    //  Events before state paused
    await current?.onPause(ctx, now);
    //  Pause current state
    _status = _Status.paused;
    //  Events after state paused
    await delegate?.pauseState(current, ctx, now);
  }

  @override
  Future<void> resume() async {
    ///  resume machine with current state
    DateTime now = DateTime.now();
    C ctx = context;
    S? current = currentState;
    //  Events before state resumed
    await delegate?.resumeState(current, ctx, now);
    //  Resume current state
    _status = _Status.running;
    //  Events after state resumed
    await current?.onResume(ctx, now);
  }

  //  Ticker
  @override
  Future<void> tick(DateTime now, int elapsed) async {
    ///  Drive the machine running forward
    C ctx = context;
    S? state = currentState;
    if (state != null && _status == _Status.running) {
      T? trans = state.evaluate(ctx, now);
      if (trans != null) {
        state = getTargetState(trans);
        assert(state != null, 'target state error: $trans');
        await _changeState(state, now);
      }
    }
  }
}
