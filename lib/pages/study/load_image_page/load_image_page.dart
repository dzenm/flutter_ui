import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ui/base/res/assets.dart';
import 'package:flutter_ui/base/res/strings.dart';
import 'package:flutter_ui/base/widgets/common_widget.dart';
import 'package:transparent_image/transparent_image.dart';

class LoadImagePage extends StatefulWidget {
  LoadImagePage();

  @override
  State<StatefulWidget> createState() => _LoadImagePageState();
}

class _LoadImagePageState extends State<LoadImagePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).loadImage, style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8),
              titleView('Image.network'),
              SizedBox(height: 8),
              Image.network(
                'https://www.wanandroid.com/blogimgs/62c1bd68-b5f3-4a3c-a649-7ca8c7dfabe6.png',
              ),
              SizedBox(height: 8),
              titleView('FadeInImage.assetNetwork'),
              SizedBox(height: 8),
              FadeInImage.assetNetwork(
                placeholder: Assets.image(('ic_vnote.png')),
                image: 'https://www.wanandroid.com/blogimgs/62c1bd68-b5f3-4a3c-a649-7ca8c7dfabe6.png',
              ),
              SizedBox(height: 8),
              titleView('CachedNetworkImage'),
              SizedBox(height: 8),
              CachedNetworkImage(
                imageUrl: 'https://www.wanandroid.com/blogimgs/62c1bd68-b5f3-4a3c-a649-7ca8c7dfabe6.png',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imageWrapper(String imageUrl) {
    return SizedBox(
      width: 150,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        placeholder: (context, url) => Image.asset('images/image-default.png'),
        errorWidget: (context, url, error) => Image.asset('images/image-failed.png'),
      ),
    );
  }
}
