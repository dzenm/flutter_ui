abstract interface class Processor {
  ///  Do the job
  ///
  /// @return false on nothing to do
  Future<bool> process();
}

abstract interface class Handler {
  ///  Prepare for handling
  Future<void> setup();

  ///  Handling run loop
  Future<void> handle();

  ///  Cleanup after handled
  Future<void> finish();
}

abstract interface class Runnable {
  ///  Run in a thread
  Future<void> run();
}

abstract class Runner implements Runnable, Handler, Processor {

  // Frames Per Second
  // ~~~~~~~~~~~~~~~~~
  // (1) The human eye can process 10-12 still images per second,
  //     and the dynamic compensation function can also deceive us.
  // (2) At a frame rate of 12fps or lower, we can quickly distinguish between
  //     a pile of still images and not animations.
  // (3) Once the playback rate (frames per second) of the images reaches 16-24 fps,
  //     our brain will assume that these images are a continuously moving scene
  //     and will appear like the effect of a movie.
  // (4) At 24fps, there is a feeling of 'motion blur',
  //     while at 60fps, the image is the smoothest and cleanest.
  static int intervalSlow   = Duration.millisecondsPerSecond ~/ 10;  // 100 ms
  static int intervalNormal = Duration.millisecondsPerSecond ~/ 25;  //  40 ms
  static int intervalFast   = Duration.millisecondsPerSecond ~/ 60;  //  16 ms

  Runner(int millis) {
    assert(millis > 0, 'interval error: $millis');
    interval = millis;
  }

  late final int interval;

  bool _running = false;

  bool get isRunning => _running;

  Future<void> stop() async => _running = false;

  @override
  Future<void> run() async {
    await setup();
    try {
      await handle();
    } finally {
      await finish();
    }
  }

  @override
  Future<void> setup() async {
    _running = true;
  }

  @override
  Future<void> finish() async {
    _running = false;
  }

  @override
  Future<void> handle() async {
    while (isRunning) {
      if (await process()) {
        // process() return true,
        // means this thread is busy,
        // so process next task immediately
      } else {
        // nothing to do now,
        // have a rest ^_^
        await idle();
      }
    }
  }

  // protected
  Future<void> idle() async =>
      await sleep(milliseconds: interval);  // Duration.millisecondsPerSecond ~/ 60

  static Future<void> sleep({required int milliseconds}) async =>
      await Future.delayed(Duration(milliseconds: milliseconds));
}
