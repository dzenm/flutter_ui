import 'runner.dart';

abstract interface class Ticker {
  ///  Drive current thread forward
  ///
  /// @param now     - current time
  /// @param elapsed - milliseconds from previous tick
  Future<void> tick(DateTime now, int elapsed);
}

class Metronome extends Runner {
  // at least wait 1/60 of a second
  static int minInterval = Duration.millisecondsPerSecond ~/ 60;  //  16 ms

  Metronome(super.millis) : _lastTime = 0 {
    _allTickers = Set.identity();
  }

  int _lastTime;

  late final Set<Ticker> _allTickers;

  void addTicker(Ticker ticker) => _allTickers.add(ticker);

  void removeTicker(Ticker ticker) => _allTickers.remove(ticker);

  Future<void> start() async {
    if (isRunning) {
      await stop();
      await idle();
    }
    /*await */run();
  }

  @override
  Future<void> setup() async {
    await super.setup();
    _lastTime = DateTime.now().millisecondsSinceEpoch;
  }

  @override
  Future<bool> process() async {
    Set<Ticker> tickers = _allTickers.toSet();
    if (tickers.isEmpty) {
      // nothing to do now,
      // return false to have a rest ^_^
      return false;
    }
    // 1. check time
    DateTime now = DateTime.now();
    int current = now.millisecondsSinceEpoch;
    int elapsed = current - _lastTime;
    int waiting = interval - elapsed;
    if (waiting < minInterval) {
      waiting = minInterval;
    }
    await Runner.sleep(milliseconds: waiting);
    now = now.add(Duration(milliseconds: waiting));
    elapsed += waiting;
    // 2. drive tickers
    for (Ticker item in tickers) {
      try {
        await item.tick(now, elapsed);
      } catch (e, st) {
        await onError(e, st, item);
      }
    }
    // 3. update last time
    _lastTime = now.millisecondsSinceEpoch;
    return true;
  }

  // protected
  Future<void> onError(dynamic error, dynamic stacktrace, Ticker ticker) async {}
}

class PrimeMetronome {
  factory PrimeMetronome() => _instance;
  static final PrimeMetronome _instance = PrimeMetronome._internal();
  PrimeMetronome._internal() {
    _metronome = Metronome(Runner.intervalSlow);
    /*await */_metronome.start();
  }

  late final Metronome _metronome;

  void addTicker(Ticker ticker) => _metronome.addTicker(ticker);

  void removeTicker(Ticker ticker) => _metronome.removeTicker(ticker);
}
