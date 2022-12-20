import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_ui/base/log/log.dart';
import 'package:flutter_ui/base/widgets/tap_layout.dart';

import 'common_widget.dart';

abstract class OnPhotoPickerClickListener {
//  void onCameraClick();
//  void onGallaryClick();
  void onAddClick();

  void onImageClick(int index);

  void onDeleteClick(int index);
}

//九宫格图片选择布局
class PhotoGridPicker extends StatefulWidget {
  final List<dynamic> _images; //图片列表
  final int maxNum; //最多可选择图片数量
  final bool withAdd; //布局最后一个是否为添加
  final OnPhotoPickerClickListener? onImageGridClickListener;
  final GlobalKey<GridPickerState>? key;
  final bool videoSingle; //视频是否只有一个
  final double marginHorizontal;
  final double marginTop;
  final double marginBottom;
  final double itemSpace; //每张图片的间距
  final double screenWidth;
  final int columnCount;
  final bool addCircle; //添加布局是否为圆形
  final bool addStroke; //添加布局是否描边
  final bool linkVoice; //是否关联图片（朋友圈使用）

  PhotoGridPicker(
    this._images, {
    this.key,
    this.maxNum = 3,
    this.withAdd = false,
    this.marginHorizontal = 0,
    this.marginTop = 0,
    this.marginBottom = 10,
    this.columnCount = 3,
    this.itemSpace = 10,
    this.screenWidth = 0,
    this.onImageGridClickListener,
    this.addCircle = false,
    this.addStroke = true,
    this.linkVoice = false,
    this.videoSingle = false,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return GridPickerState();
  }
}

class GridPickerState extends State<PhotoGridPicker> {
//  double itemSpace = 10.0;
//  double space = 5.0; //上下左右间距
  double deleBtnWH = 20.0;

//  var length;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var kScreenWidth = widget.screenWidth == 0 ? MediaQuery.of(context).size.width : widget.screenWidth;
    var ninePictureW = (kScreenWidth -
//        space * 2 -
        2 * widget.itemSpace -
        2 * widget.marginHorizontal);
//    var itemWH = ninePictureW / widget.columnCount;
    var actualCount = widget.columnCount; //l 4张图片采用三列的图片大小

    var itemWH = ninePictureW / actualCount; //4张图片的单张宽度与三列的图片布局相同
    int columnCount = (getCount() % actualCount != 0) ? (getCount() ~/ actualCount) + 1 : (getCount() ~/ actualCount);
//    getCount() > 6 ? 3 : getCount() <= 3 ? 1 : 2;

    return Container(
        width: (widget._images.length == 4 && !widget.withAdd) ? kScreenWidth * 2 / 3 : kScreenWidth, //l 四张按两列宽度算
        height: columnCount == 0
            ? 0
            : columnCount * itemWH +
//            space * 2 +
                (columnCount - 1) * widget.itemSpace,
        margin: EdgeInsets.only(left: widget.marginHorizontal, right: widget.marginHorizontal, top: widget.marginTop, bottom: widget.marginBottom),
        child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              //可以直接指定每行（列）显示多少个Item
              //一行的Widget数量
              crossAxisCount: (widget._images.length == 4 && !widget.withAdd) ? 2 : widget.columnCount, //l 四张按2列算
              crossAxisSpacing: widget.itemSpace, //水平间距
              mainAxisSpacing: widget.itemSpace, //垂直间距
              childAspectRatio: 1.0, //子Widget宽高比例
            ),
            physics: NeverScrollableScrollPhysics(),
//            padding: EdgeInsets.all(space), //GridView内边距
            itemCount: getCount(),
            itemBuilder: (context, index) {
              return GestureDetector(
                child: _gridView(index),
                onTap: () {
                  if (widget.withAdd && isShowAddItem(index)) {
                    _onAddTap();
                  } else {
                    widget.onImageGridClickListener!.onImageClick(index);
                  }
                },
              );
            }));
  }

  Widget _gridView(int index) {
    return (widget.withAdd && isShowAddItem(index)) ? _getAddChild() : _getImgItem(index);
  }

  bool isShowAddItem(int index) {
    return index == widget._images.length;
  }

  _onAddTap() {
    widget.onImageGridClickListener!.onAddClick();
  }

  Widget _getAddChild() {
    return Container(
      decoration: BoxDecoration(
        color: widget.addStroke ? Colors.transparent : Colors.grey,
        border: widget.addStroke ? Border.all(width: 1.0, color: Colors.grey) : null,
        shape: widget.addCircle ? BoxShape.circle : BoxShape.rectangle,
      ),
      child: Icon(
        Icons.add,
        size: 30,
        color: widget.addStroke ? Colors.black : Colors.grey,
      ),
    );
  }

  Widget _getImgItem(int index) {
    return Container(
      color: Colors.transparent,
      child: Stack(alignment: Alignment.topRight, children: <Widget>[
        ConstrainedBox(
          child: _getImgChild(index),
          constraints: BoxConstraints.expand(),
        ),
        Offstage(
          offstage: !widget.withAdd,
          child: TapLayout(
            child: Icon(
              Icons.cancel,
              size: 20,
              color: Colors.black,
            ),
            onTap: () {
              widget.onImageGridClickListener!.onDeleteClick(index);
            },
          ),
        ),
        Positioned(
            bottom: 0,
            left: 0,
            child: Offstage(
              offstage: !widget.linkVoice,
              child: RotatedBox(
                quarterTurns: 2,
                child: Image.asset(
                  'record/record_v_anim3',
                  width: 20,
                  height: 20,
                  color: Colors.white,
                ),
              ),
            )),
        Positioned(
          bottom: 0,
          left: 0,
          child: Offstage(
            offstage: !durationOffstage(index),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.transparent, Colors.grey],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: Text(
                '${getDuration(index)}',
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
          ),
        )
      ]),
    );
  }

  int getDuration(int index) {
    // var item = widget._images[index];
    // if (item is MomentImage) {
    //   if (item.type == AssetType.video) {
    //     return item.duration ?? 0;
    //   }
    // }
    return 0;
  }

  bool durationOffstage(int index) {
    // var item = widget._images[index];
    // if (item is MomentImage) {
    //   if (item.type == AssetType.video) {
    //     return true;
    //   }
    // }
    return false;
  }

/*  _getImgChildOld(int index) {
    Widget placeholder = ImagePlaceholder(width: 90);
    var item = widget._images[index];
    String path;
    if(item is File){
      return Image(
        image: FileImageEx(item),  //加载本地图片
        fit: BoxFit.cover,
      );
    }else if (item is String) {
      path = widget._images[index];
      return imgChild(path, placeholder);
    } else if (item is MomentImage) {
      path = item.path!;
      if (item.type == AssetType.video) {
        */ /*return Image.memory(
          item.videoThumb!,
          fit: BoxFit.cover,
        );*/ /*
        return Image(
          image: FileImageEx(File(item.videoThumbPath ?? "")),
          fit: BoxFit.cover,
        ); //视频 - 展示视频缩略图
      } else {
        return imgChild(path, placeholder);
      }
    }
  }*/

  final Widget _placeholder = imagePlaceholder(width: 90);

  _getImgChild(int index) {
    try {
      String path;
      var item = widget._images[index];
      // if (item is MomentImage) {
      //   path = (item.type == AssetType.video) ? ChatUtils.getVidoeThumbPath(item.path ?? "") : (item.path ?? ""); //只针对朋友圈草稿箱 - 视频-缩略图路径；图片-图片路径
      // } else
      if (item is File) {
        path = item.path;
      } else {
        path = item; //不可能出现.mp4
      }
//      Log.d(path,tag:"显示的文件路径:");

      File? localFile = File(path);
      if (!localFile.existsSync()) {
        localFile = null;
      }

      return Container(
          child: path.startsWith('http')
              ? networkImage(path, fit: BoxFit.cover, placeholder: _placeholder) //网络图片
              : localFile != null
                  ? Image(
                      image: FileImageExt(File(path)), //本地图片
                      fit: BoxFit.cover,
                    )
                  : null); //本地图片不存在则为空

    } catch (e) {
      Log.e(e.toString(), tag: "PhotoGridPicker-getImgChild:");
    }
    return Container(child: _placeholder);
    //图片 path
    //视频 videoThumbPath
    //音频 不可能是音频

    /*var item = widget._images[index];
    String path;
    if(item is File){
      return Image(
        image: FileImageEx(item),  //加载本地图片
        fit: BoxFit.cover,
      );
    }else if (item is String) {
      path = widget._images[index];
      return imgChild(path, placeholder);
    } else if (item is MomentImage) {
      path = item.path!;
      if (item.type == AssetType.video) {
        */ /*return Image.memory(
          item.videoThumb!,
          fit: BoxFit.cover,
        );*/ /*
        return Image(
          image: FileImageEx(File(item.videoThumbPath ?? "")),
          fit: BoxFit.cover,
        ); //视频 - 展示视频缩略图
      } else {
        return imgChild(path, placeholder);
      }
    }*/
  }

  /* final AsyncMemoizer _memoizer = AsyncMemoizer();

  Future getThumb(String path) {
    return _memoizer.runOnce(() async {
      return VideoThumbnail.thumbnailData(video: path)
          .timeout(Duration(seconds: 15));
    });
  }*/

  /*Widget imgChild(String path, Widget placeholder) {
    return path.endsWith('.mp4') || path.endsWith('.MOV')
        ? FutureBuilder(
            future: getThumb(path),
            builder: (context, AsyncSnapshot snapshot) {
              print('child $path');
              if (snapshot.connectionState == ConnectionState.done) {
                Uint8List data = snapshot.data;

                return data != null
                    ? Image.memory(
                        data,
                        fit: BoxFit.cover,
                      )
                    : placeholder;
              } else {
                return placeholder;
              }
            },
          )
        : Container(  //网络图片
            child: path.startsWith('http')
                ? NetworkImageWidget(path,
        fit: BoxFit.cover,placeholder: placeholder)
//            TransitionToImage(
//                    image: AdvancedNetworkImage(
//                      path ?? '',
//                    ),
//                    fit: BoxFit.cover,
//                    placeholder: placeholder,
//                    loadingWidget: placeholder,
//                  )
                : Image(
                    image: FileImageEx(File(path)),
                    fit: BoxFit.cover,
                  ));
  }*/
  //isCalculate:true 计算widget宽高时使用
  int getCount() {
    if (widget.videoSingle) {
      return 1;
    } else if (widget.withAdd && widget._images.length < widget.maxNum) //发布页面九宫格展示
      return widget._images.length + 1;
    else
      return widget._images.length; //朋友圈九宫格展示
  }
}
