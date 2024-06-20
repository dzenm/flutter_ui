import 'base.dart';
import 'machine.dart';
import 'ticker.dart';

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
