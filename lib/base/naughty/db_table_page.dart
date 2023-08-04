import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../db/db_manager.dart';
import '../widgets/tap_layout.dart';
import 'db_column_page.dart';
import 'naughty.dart';

/// 数据库表列表展示页面
class DBTablePage extends StatefulWidget {
  final String dbName;

  const DBTablePage(this.dbName, {super.key});

  @override
  State<StatefulWidget> createState() => _DBTablePageState();
}

class _DBTablePageState extends State<DBTablePage> {
  List _list = [];

  @override
  void initState() {
    super.initState();
    getData();
  }

  //列表要展示的数据
  Future getData() async {
    await Future.delayed(Duration.zero, () async {
      _list = await DBManager().getTableList(dbName: widget.dbName);
      setState(() => {});
    });
  }

  @override
  Widget build(BuildContext context) {
    String title = Naughty.instance.getFileName(widget.dbName);
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView.builder(
          itemBuilder: _buildItem,
          itemCount: _list.length,
        ),
      ),
    );
  }

  // 列表 item 布局
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
          onTap: () => Naughty.instance.push(context, DBColumnPage(widget.dbName, _list[index].name ?? '')),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _list[index].name ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 18.0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 下拉刷新方法,为_list重新赋值
  Future<void> _onRefresh() async {
    await getData();
  }
}
