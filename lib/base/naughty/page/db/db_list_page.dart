import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ui/base/naughty/page/db/db_table_list_page.dart';
import 'package:flutter_ui/base/utils/file_util.dart';
import 'package:flutter_ui/base/utils/route_manager.dart';
import 'package:flutter_ui/base/utils/str_util.dart';
import 'package:flutter_ui/base/widgets/tap_layout.dart';
import 'package:intl/intl.dart';

/// 数据库显示页面
class DBListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DBListPageState();
}

class _DBListPageState extends State<DBListPage> {
  List<String> _list = [];

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Database'),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView.builder(
          shrinkWrap: true,
          itemBuilder: _renderRow,
          itemCount: _list.length,
        ),
      ),
    );
  }

  //列表要展示的数据
  Future getData() async {
    await Future.delayed(Duration(seconds: 0), () async {
      _list = await FileUtil.getInstance.getDBFiles();
      setState(() => {});
    });
  }

  // 列表单item
  Widget _renderRow(BuildContext context, int index) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
      child: Container(
        margin: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          border: Border.all(color: Colors.black12, width: 1),
          borderRadius: BorderRadius.all(Radius.circular(8)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 2.0, //阴影模糊程度
              spreadRadius: 1.0, //阴影扩散程度
            ),
          ],
        ),
        child: TapLayout(
          borderRadius: BorderRadius.all(Radius.circular(7)),
          onTap: () => RouteManager.push(DBTableListPage(_list[index])),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _listChildWidget(index),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _listChildWidget(int index) {
    String path = _list[index];
    String name = StrUtil.getFileName(path);
    File file = File(path);
    int len = file.lengthSync();
    String size = StrUtil.formatSize(len);
    String modifyTime = DateFormat("yyyy-MM-dd HH:mm:ss").format(file.lastModifiedSync());
    return [
      Text(
        name,
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 18.0),
      ),
      SizedBox(height: 8),
      Text(path),
      SizedBox(height: 8),
      Row(
        children: [
          Expanded(child: Text('文件大小: $size', style: TextStyle(fontSize: 13))),
          Text('最后修改: $modifyTime', style: TextStyle(fontSize: 13)),
        ],
      ),
    ];
  }

  // 下拉刷新方法,为_list重新赋值
  Future<Null> _onRefresh() async {
    await getData();
  }
}
