import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class GifCache {
  final Map<String, List<ImageInfo>> caches = {};

  void clear() {
    caches.clear();
  }

  bool evict(Object key) {
    final List<ImageInfo>? pendingImage = caches.remove(key)!;
    if (pendingImage != null) {
      return true;
    }
    return false;
  }
}

class GifController extends AnimationController {
  GifController({
    required super.vsync,
    super.value,
    super.reverseDuration = const Duration(milliseconds: 1000),
    super.duration = const Duration(milliseconds: 2000),
    AnimationBehavior? animationBehavior,
  }) : super.unbounded(animationBehavior: animationBehavior ?? AnimationBehavior.normal);

  int _frames = 0;

  bindValues(int len) {
    _frames = len;
  }

  int get frames => _frames;

  int get frame => value.toInt();

  int get playCount => _playCount;

  int _playCount = 0;

  void play() {
    repeat(min: 0, max: frames.toDouble(), period: duration);
  }
}

class GifImage extends StatefulWidget {
  const GifImage({
    super.key,
    this.image,
    required this.controller,
    this.semanticLabel,
    this.imagPath,
    this.width,
    this.height,
    this.onFetchCompleted,
    this.color,
    this.colorBlendMode,
    this.fit,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.centerSlice,
    this.matchTextDirection = false,
    this.initPlay = true,
  });

  final VoidCallback? onFetchCompleted;
  final GifController? controller;
  final String? imagPath; //l 图片路径
  final ImageProvider? image;
  final double? width;
  final bool? initPlay;
  final double? height;
  final Color? color;
  final BlendMode? colorBlendMode;
  final BoxFit? fit;
  final AlignmentGeometry alignment;
  final ImageRepeat repeat;
  final Rect? centerSlice;
  final bool matchTextDirection;
  final String? semanticLabel;

  @override
  State<StatefulWidget> createState() {
    return GifImageState();
  }

  static GifCache cache = GifCache();
}

class GifImageState extends State<GifImage> {
  List<ImageInfo?>? _infos;
  final ValueNotifier<int> _curIndex = ValueNotifier(0);
  bool _fetchComplete = false;

  ImageInfo? get _imageInfo {
    // if (!_fetchComplete) return null;
    return _infos == null ? null : _infos![_curIndex.value];
  }

  @override
  void initState() {
    super.initState();

    // if(widget.controller == null) return;

    if (widget.controller != null) {
      widget.controller!.addListener(_listener);
      _curIndex.addListener(() {
        if (widget.controller!.frame == widget.controller!.frames - 1) {
          widget.controller!._playCount++;
        }
      });
    }

    // if(widget.image == null) return;
    fetchGif(widget.imagPath != null ? AssetImage(widget.imagPath ?? '') : widget.image!).then((imageInfos) {
      if (mounted) {
        setState(() {
          _infos = imageInfos;
          _fetchComplete = true;
        });

        if (widget.onFetchCompleted != null) {
          widget.onFetchCompleted!();
        }

        if (widget.controller != null) {
          widget.controller!.bindValues(_infos!.length);
          _curIndex.value = widget.controller!.value.toInt();
          if (widget.initPlay == true) {
            widget.controller!.play();
          }
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    widget.controller?.removeListener(_listener);
  }

  @override
  void didUpdateWidget(GifImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_listener);
      widget.controller?.addListener(_listener);
    }
  }

  void _listener() {
    if (widget.controller != null && _curIndex.value != widget.controller!.value && _fetchComplete) {
      _curIndex.value = widget.controller!.value.toInt();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    ;
    return ValueListenableBuilder(
      valueListenable: _curIndex,
      builder: (context, index, w) {
        return Semantics(
          container: widget.semanticLabel != null,
          image: true,
          label: widget.semanticLabel ?? '',
          child:
              // widget.imagPath != null ?
              // Image.asset(widget.imagPath ?? '',width: widget.width,height: widget.height,fit:widget.fit,centerSlice:widget.centerSlice,alignment: widget.alignment,matchTextDirection: widget.matchTextDirection,) :   // png图片显示
              RawImage(
            image: _imageInfo?.image,
            width: widget.width,
            height: widget.height,
            /*scale: _imageInfo?.scale ?? 1.0,
          color: widget.color,
          colorBlendMode: widget.colorBlendMode,*/
            fit: widget.fit,
            /*alignment: widget.alignment,
          repeat: widget.repeat,
          centerSlice: widget.centerSlice,
          matchTextDirection: widget.matchTextDirection,*/
          ),
        );
      },
    );
  }
}

final HttpClient _sharedHttpClient = HttpClient()..autoUncompress = false;

HttpClient get _httpClient {
  HttpClient client = _sharedHttpClient;
  assert(() {
    if (debugNetworkImageHttpClientProvider != null) client = debugNetworkImageHttpClientProvider!();
    return true;
  }());
  return client;
}

Future<List<ImageInfo>> fetchGif(ImageProvider provider) async {
  List<ImageInfo> infos = [];
  dynamic data;
  String key = provider is NetworkImage
      ? provider.url
      : provider is AssetImage
          ? provider.assetName
          : provider is MemoryImage
              ? provider.bytes.toString()
              : "";
  if (GifImage.cache.caches.containsKey(key)) {
    infos = GifImage.cache.caches[key]!;
    return infos;
  }
  if (provider is NetworkImage) {
    final Uri resolved = Uri.base.resolve(provider.url);
    final HttpClientRequest request = await _httpClient.getUrl(resolved);
    provider.headers?.forEach((String name, String value) {
      request.headers.add(name, value);
    });
    final HttpClientResponse response = await request.close();
    data = await consolidateHttpClientResponseBytes(
      response,
    );
  } else if (provider is AssetImage) {
    AssetBundleImageKey key = await provider.obtainKey(const ImageConfiguration());
    data = await key.bundle.load(key.name);
  } else if (provider is FileImage) {
    data = await provider.file.readAsBytes();
  } else if (provider is MemoryImage) {
    data = provider.bytes;
  }

  // ui.Codec codec = await PaintingBinding.instance.instantiateImageCodec(data.buffer.asUint8List());
  infos = [];
  // for (int i = 0; i < codec.frameCount; i++) {
  //   FrameInfo frameInfo = await codec.getNextFrame();
  //   infos.add(ImageInfo(image: frameInfo.image));
  // }
  GifImage.cache.caches.putIfAbsent(key, () => infos);
  return infos;
}
