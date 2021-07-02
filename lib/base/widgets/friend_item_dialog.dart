import 'package:flutter/material.dart';

typedef ConfirmCallback = void Function(dynamic value);

friendItemDialog(BuildContext context, {String? userId, ConfirmCallback? callback}) {
  action(v) {
    Navigator.of(context).pop();
    if (v == '删除') {
      // confirmAlert(
      //   context,
      //   (bool) {
      //     if (bool) delFriend(userId, context, callback: (v) => callback(v));
      //   },
      //   tips: '你确定要删除此联系人吗',
      //   okBtn: '删除',
      //   warmStr: '删除联系人',
      //   isWarm: true,
      //   style: TextStyle(fontWeight: FontWeight.w500),
      // );
    } else {
      // showToast(context, '删除功能是好的');
    }
  }

  Widget item(item) {
    return new Container(
      decoration: BoxDecoration(
        border: item != '删除'
            ? Border(
                bottom: BorderSide(color: Colors.grey, width: 0.2),
              )
            : null,
      ),
      child: FlatButton(
        color: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 15.0),
        onPressed: () => action(item),
        child: Text(item),
      ),
    );
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      List data = [
        '设置备注和标签',
        '把她推荐给朋友',
        '设为星标好友',
        '设置朋友圈和视频动态权限',
        '加入黑名单',
        '投诉',
        '添加到桌面',
        '删除',
      ];
      return Center(
        child: Material(
          type: MaterialType.transparency,
          child: Column(
            children: [
              Expanded(
                child: Container(
                  color: Colors.transparent,
                  child: InkWell(
                    child: Container(),
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.all(
                  Radius.circular(10.0),
                ),
                child: Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      Column(children: data.map(item).toList()),
                      FlatButton(
                        padding: EdgeInsets.symmetric(vertical: 15.0),
                        color: Colors.white,
                        onPressed: () => Navigator.of(context).pop(),
                        child: Container(
                          alignment: Alignment.center,
                          child: Text('取消'),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      );
    },
  );
}
