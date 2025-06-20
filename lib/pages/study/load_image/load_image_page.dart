import 'package:fbl/fbl.dart';
import 'package:flutter/material.dart';

/// 加载图片
class LoadImagePage extends StatefulWidget {
  const LoadImagePage({super.key});

  @override
  State<StatefulWidget> createState() => _LoadImagePageState();
}

class _LoadImagePageState extends State<LoadImagePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonBar(
        title: '加载图片',
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              CommonWidget.titleView('Image.network'),
              const SizedBox(height: 8),
              Image.network(
                'https://www.wanandroid.com/blogimgs/62c1bd68-b5f3-4a3c-a649-7ca8c7dfabe6.png',
                loadingBuilder: (context, widget, event) => const CircularProgressIndicator(),
              ),
              const SizedBox(height: 8),
              CommonWidget.titleView('FadeInImage.assetNetwork'),
              const SizedBox(height: 8),
              FadeInImage.assetNetwork(
                placeholder: Assets.icVNote,
                image: 'https://www.wanandroid.com/blogimgs/62c1bd68-b5f3-4a3c-a649-7ca8c7dfabe6.png',
              ),
              const SizedBox(height: 8),
              CommonWidget.titleView('CachedNetworkImage'),
              const SizedBox(height: 8),
              const ImageCacheView(
                url: 'https://www.wanandroid.com/blogimgs/62c1bd68-b5f3-4a3c-a649-7ca8c7dfabe6.png',
              ),
              const SizedBox(height: 16),
              TapLayout(
                height: 50.0,
                isCircle: true,
                background: Colors.blue,
                onTap: () {},
                child: const Text('VIP', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
