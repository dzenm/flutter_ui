library fsm;

export 'src/machine.dart';
export 'src/runner.dart';

/// [Machine] 是一个有限状态机，它实现了 [Ticker]，把它加入到线程中，可以
/// 根据当前的状态条件进行改变，它也可以控制状态机的 [start] 和 [stop]，
/// 也可以 [pause] 和 [resume]，它的基本实现是 [BaseMachine]，将
/// [BaseState] 和 [BaseTransition] 进行关联，你可以通过 [addState]
/// 将要转化的 [BaseState] 添加到状态机，它会根据你对每一个状态，以及该状
/// 态进入的条件进行处理，保证进入到预期的状态。
///
/// [StateTransition] 是上一个状态进入下一个状态的控制条件，它的基本实现
/// 是 [BaseTransition]，你可以通过实现它，自定义状态的转换条件
/// [FiniteState] 根据上一个状态进入下一个状态的实施计划，它的基本实现是
/// [BaseState]，你可以通过实现它，对每一个状态添加它的控制条件。

/// [Runner] 是一个简易的线程，可以通过继承 [Runner]，并实现 [process]
/// 方法，处理线程需要处理的任务。也可以通过实现 [Ticker] 接口，并添加到
/// [Metronome] 任务中。
/// [sleep] 是让线程休眠一段时间的办法，执行的任务 [process] 如果返回结
/// 果为true，它会再次执行 [process]，如果返回的结果为false，它会休眠一
/// 段时间
