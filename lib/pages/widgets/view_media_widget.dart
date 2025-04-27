import 'package:flutter/material.dart';

import 'package:fbl/fbl.dart';

///
/// Created by a0010 on 2024/1/11 11:55
///
class ViewMediaWidget extends StatefulWidget {
  final List<MediaEntity> medias;
  final int initialItem;

  const ViewMediaWidget({
    super.key,
    required this.medias,
    this.initialItem = 0,
  });

  @override
  State<ViewMediaWidget> createState() => _ViewMediaWidgetState();
}

class _ViewMediaWidgetState extends State<ViewMediaWidget> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _builtToolbar(),
      Expanded(
        child: ViewMedia(
          medias: widget.medias,
          initialItem: widget.initialItem,
          initialScale: _scale,
          delegate: (url) {
            if (url.isEmpty || url.startsWith('http')) return Container();
            PathInfo path = PathInfo.parse(url);
            if (path.mimeType == MimeType.image) {
              return ImageCacheView(
                url: url,
                width: MediaQuery.of(context).size.width,
                isOrigin: true,
              );
            } else if (path.mimeType == MimeType.video) {

            }
            return Container();
          },
          decoration: const BoxDecoration(color: Colors.white),
        ),
      ),
    ]);
  }

  Widget _builtToolbar() {
    return Container(
      height: 32,
      color: Colors.grey,
      child: Row(children: [
        const SizedBox(width: 20),
        const Expanded(child: SizedBox.shrink()),
        TapLayout(
          width: 32,
          height: 32,
          isCircle: true,
          foreground: Colors.transparent,
          onTap: () {
            _scale += 0.5;
            setState(() {});
          },
          child: const Icon(
            Icons.zoom_in_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
        const SizedBox(width: 8),
        TapLayout(
          width: 32,
          height: 32,
          foreground: Colors.transparent,
          isCircle: true,
          onTap: () {
            _scale -= 0.5;
            setState(() {});
          },
          child: const Icon(
            Icons.zoom_out_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
        const SizedBox(width: 8),
        TapLayout(
          width: 32,
          height: 32,
          isCircle: true,
          foreground: Colors.transparent,
          onTap: () {
            Navigator.of(context).pop();
          },
          child: const Icon(
            Icons.close_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
        const SizedBox(width: 20),
      ]),
    );
  }
}
