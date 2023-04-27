import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../widgets/tap_layout.dart';
import 'db_table_page.dart';
import 'naughty.dart';

/// 数据库显示页面
class DBPage extends StatefulWidget {
  const DBPage({super.key});

  @override
  State<StatefulWidget> createState() => _DBPageState();
}

class _DBPageState extends State<DBPage> {
  List<String> _list = [];

  @override
  void initState() {
    super.initState();
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database'),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView.builder(
          shrinkWrap: true,
          itemBuilder: _buildItem,
          itemCount: _list.length,
        ),
      ),
    );
  }

  /// 列表要展示的数据
  Future _getData() async {
    await Future.delayed(const Duration(seconds: 0), () async {
      _list = await Naughty.instance.getDBFiles();
      setState(() => {});
    });
  }

  /// 列表item 布局
  Widget _buildItem(BuildContext context, int index) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(8.0)),
      child: Container(
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          border: Border.all(color: Colors.black12, width: 1),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 2.0, //阴影模糊程度
              spreadRadius: 1.0, //阴影扩散程度
            ),
          ],
        ),
        child: TapLayout(
          borderRadius: const BorderRadius.all(Radius.circular(7)),
          onTap: () => Naughty.instance.push(context, DBTablePage(_list[index])),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildItemDetail(index),
            ),
          ),
        ),
      ),
    );
  }

  /// 列表item详细信息布局
  List<Widget> _buildItemDetail(int index) {
    String path = _list[index];
    String name = Naughty.instance.getFileName(path);
    File file = File(path);
    int len = file.lengthSync();
    String size = Naughty.instance.formatSize(len);
    String modifyTime = DateFormat("yyyy-MM-dd HH:mm:ss").format(file.lastModifiedSync());
    return [
      Text(
        name,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 18.0),
      ),
      const SizedBox(height: 8),
      Text(path),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(child: Text('文件大小: $size', style: const TextStyle(fontSize: 13))),
          Text('最后修改: $modifyTime', style: const TextStyle(fontSize: 13)),
        ],
      ),
    ];
  }

  /// 下拉刷新方法,为_list重新赋值
  Future<void> _onRefresh() async {
    await _getData();
  }
}