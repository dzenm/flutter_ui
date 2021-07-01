import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ui/base/db/sql_manager.dart';
import 'package:flutter_ui/base/entities/table_entity.dart';
import 'package:flutter_ui/base/naughty/page/db/db_table_item_page.dart';
import 'package:flutter_ui/base/utils/str_util.dart';
import 'package:flutter_ui/base/widgets/tap_layout.dart';

/// 数据库表列表展示页面
class DBTableListPage extends StatefulWidget {
  final String dbName;

  DBTableListPage(this.dbName);

  @override
  State<StatefulWidget> createState() => _DBTableListPageState();
}

class _DBTableListPageState extends State<DBTableListPage> {
  List<TableEntity> _list = [];

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    String title = StrUtil.getFileName(widget.dbName);
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
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
      _list = await SqlManager.getInstance.getTableList(dbName: widget.dbName);
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
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DBTableItemPage(widget.dbName, _list[index].name ?? ''))),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _list[index].name ?? '',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 18.0),
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
  Future<Null> _onRefresh() async {
    await getData();
  }
}
