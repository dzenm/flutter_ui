import 'package:flutter/material.dart';

import '../db/db_manager.dart';

/// 数据库表列表展示页面
class DBColumnPage extends StatefulWidget {
  final String dbName;
  final String tableName;

  const DBColumnPage(this.dbName, this.tableName, {super.key});

  @override
  State<StatefulWidget> createState() => _DBColumnPageState();
}

class _DBColumnPageState extends State<DBColumnPage> {
  List<Map<String, dynamic>> _rows = [];
  List _columns = [];
  bool _init = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 500), getData);
  }

  Future<void> getData() async {
    _rows = await DBManager().where(widget.tableName);
    _columns = await DBManager().getTableColumn(widget.dbName, widget.tableName);
    setState(() => _init = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tableName),
      ),
      body: SingleChildScrollView(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: _init
              ? DataTable(
                  dataRowHeight: 20,
                  headingRowHeight: 32,
                  horizontalMargin: 0,
                  columnSpacing: 5,
                  showBottomBorder: true,
                  columns: _columns.map((column) => DataColumn(label: Text('${column.name}'))).toList(),
                  rows: _rows.map((Map<String, dynamic> item) {
                    return DataRow(
                        cells: _columns.map((column) {
                      return DataCell(Text(item[column.name].toString()));
                    }).toList());
                  }).toList(),
                )
              : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    SizedBox(width: 56, height: 56, child: CircularProgressIndicator()),
                  ]),
                ]),
        ),
      ),
    );
  }
}
