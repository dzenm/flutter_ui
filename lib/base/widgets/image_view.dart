import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

///
/// Created by a0010 on 2023/8/15 15:23
///
class ImageView extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit? fit;

  const ImageView({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      // 加载网络图片过程中显示的内容 , 这里显示进度条
      placeholder: (context, url) => const Center(
        child: SizedBox(
          width: 42,
          height: 42,
          child: CircularProgressIndicator(),
        ),
      ),
      width: width,
      height: height,
      fit: fit,
      // 网络图片地址
      imageUrl: url,
    );
  }
}
