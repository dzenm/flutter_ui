import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart';

/// How to auto start the gif.
enum Autostart {
  /// Don't start.
  no,

  /// Run once everytime a new gif is loaded.
  once,

  /// Loop playback.
  loop,
}

class GifView extends StatefulWidget {
  /// Rendered gifs cache.
  static final _GifCache _cache = _GifCache();

  /// [ImageProvider] of this gif. Like [NetworkImage], [AssetImage], [MemoryImage]
  final ImageProvider image;

  /// This playback controller.
  final AnimationController? controller;

  /// Frames per second at which this runs.
  final int? fps;

  /// Whole playback duration.
  final Duration? duration;

  /// If and how to start this gif.
  final Autostart autostart;

  /// Rendered when gif frames fetch is still not completed.
  final Widget Function(BuildContext context)? placeholder;

  /// Called when gif frames fetch is completed.
  final VoidCallback? onFetchCompleted;

  final double? width;
  final double? height;
  final Color? color;
  final BlendMode? colorBlendMode;
  final BoxFit? fit;
  final AlignmentGeometry alignment;
  final ImageRepeat repeat;
  final Rect? centerSlice;
  final bool matchTextDirection;
  final String? semanticLabel;
  final bool excludeFromSemantics;
  final bool useCache;

  const GifView({
    super.key,
    required this.image,
    this.controller,
    this.fps,
    this.duration,
    this.autostart = Autostart.no,
    this.placeholder,
    this.onFetchCompleted,
    this.semanticLabel,
    this.excludeFromSemantics = false,
    this.width,
    this.height,
    this.color,
    this.colorBlendMode,
    this.fit,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.centerSlice,
    this.matchTextDirection = false,
    this.useCache = true,
  });

  @override
  State<StatefulWidget> createState() => _GifViewState();
}

class _GifViewState extends State<GifView> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  /// List of [ImageInfo] of every frame of this gif.
  List<ImageInfo> _frames = [];

  int _frameIndex = 0;

  /// Current rendered frame.
  ImageInfo? get _frame => _frames.length > _frameIndex ? _frames[_frameIndex] : null;

  @override
  Widget build(BuildContext context) {
    final RawImage image = RawImage(
      image: _frame?.image,
      width: widget.width,
      height: widget.height,
      scale: _frame?.scale ?? 1.0,
      color: widget.color,
      colorBlendMode: widget.colorBlendMode,
      fit: widget.fit,
      alignment: widget.alignment,
      repeat: widget.repeat,
      centerSlice: widget.centerSlice,
      matchTextDirection: widget.matchTextDirection,
    );
    return widget.placeholder != null && _frame == null
        ? widget.placeholder!(context)
        : widget.excludeFromSemantics
            ? image
            : Semantics(
                container: widget.semanticLabel != null,
                image: true,
                label: widget.semanticLabel ?? '',
                child: image,
              );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadFrames().then((value) => _autostart());
  }

  @override
  void didUpdateWidget(GifView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_listener);
      _initAnimation();
    }
    if ((widget.image != oldWidget.image) || (widget.fps != oldWidget.fps) || (widget.duration != oldWidget.duration)) {
      _loadFrames().then((value) {
        if (widget.image != oldWidget.image) {
          _autostart();
        }
      });
    }
    if ((widget.autostart != oldWidget.autostart)) {
      _autostart();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_listener);
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _initAnimation() {
    _controller = widget.controller ?? AnimationController(vsync: this);
    _controller.addListener(_listener);
  }

  @override
  void initState() {
    super.initState();
    _initAnimation();
  }

  /// Start this gif according to [widget.autostart] and [widget.loop].
  void _autostart() {
    if (mounted && widget.autostart != Autostart.no) {
      _controller.reset();
      if (widget.autostart == Autostart.loop) {
        _controller.repeat();
      } else {
        _controller.forward();
      }
    }
  }

  /// Get unique image string from [ImageProvider]
  String _getImageKey(ImageProvider provider) {
    return provider is NetworkImage
        ? provider.url
        : provider is AssetImage
            ? provider.assetName
            : provider is FileImage
                ? provider.file.path
                : provider is MemoryImage
                    ? provider.bytes.toString()
                    : "";
  }

  /// Calculates the [_frameIndex] based on the [AnimationController] value.
  ///
  /// The calculation is based on the frames of the gif
  /// and the [Duration] of [AnimationController].
  void _listener() {
    if (_frames.isNotEmpty && mounted) {
      setState(() {
        _frameIndex = _frames.isEmpty ? 0 : ((_frames.length - 1) * _controller.value).floor();
      });
    }
  }

  /// Fetches the frames with [_fetchFrames] and saves them into [_frames].
  ///
  /// When [_frames] is updated [onFetchCompleted] is called.
  Future<void> _loadFrames() async {
    if (!mounted) return;

    _GifInfo gif = widget.useCache
        ? GifView._cache.caches.containsKey(_getImageKey(widget.image))
            ? GifView._cache.caches[_getImageKey(widget.image)]!
            : await _fetchFrames(widget.image)
        : await _fetchFrames(widget.image);

    if (!mounted) return;

    if (widget.useCache) GifView._cache.caches.putIfAbsent(_getImageKey(widget.image), () => gif);

    setState(() {
      _frames = gif.frames;
      _controller.duration = widget.fps != null ? Duration(milliseconds: (_frames.length / widget.fps! * 1000).round()) : widget.duration ?? gif.duration;
      if (widget.onFetchCompleted != null) {
        widget.onFetchCompleted!();
      }
    });
  }

  /// Fetches the single gif frames and saves them into the [_GifCache] of [GifView]
  static Future<_GifInfo> _fetchFrames(ImageProvider provider) async {
    late final Uint8List bytes;

    if (provider is NetworkImage) {
      final Uri resolved = Uri.base.resolve(provider.url);
      final Client client = Client();
      final Response response = await client.get(
        resolved,
        headers: provider.headers,
      );
      bytes = response.bodyBytes;
    } else if (provider is AssetImage) {
      AssetBundleImageKey key = await provider.obtainKey(const ImageConfiguration());
      bytes = (await key.bundle.load(key.name)).buffer.asUint8List();
    } else if (provider is FileImage) {
      bytes = await provider.file.readAsBytes();
    } else if (provider is MemoryImage) {
      bytes = provider.bytes;
    }

    final buffer = await ImmutableBuffer.fromUint8List(bytes);
    Codec codec = await PaintingBinding.instance.instantiateImageCodecWithSize(
      buffer,
    );
    List<ImageInfo> images = [];
    Duration duration = const Duration();

    for (int i = 0; i < codec.frameCount; i++) {
      FrameInfo frameInfo = await codec.getNextFrame();
      images.add(ImageInfo(image: frameInfo.image));
      duration += frameInfo.duration;
    }

    return _GifInfo(frames: images, duration: duration);
  }
}

class _GifCache {
  final Map<String, _GifInfo> caches = {};

  /// Clears all the stored gifs from the cache.
  void clear() => caches.clear();

  /// Removes single gif from the cache.
  bool evict(Object key) => caches.remove(key) != null ? true : false;
}

class _GifInfo {
  final List<ImageInfo> frames;
  final Duration duration;

  _GifInfo({
    required this.frames,
    required this.duration,
  });
}
