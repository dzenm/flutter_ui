import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../db/db.dart';

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
    _rows = await DBManager().query(widget.tableName);
    _columns = await DBManager().getTableColumns(widget.dbName, widget.tableName);
    setState(() => _init = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tableName, style: const TextStyle(color: Colors.white)),
        toolbarTextStyle: const TextStyle(color: Colors.white),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: _init
          ? SingleChildScrollView(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  dataRowMinHeight: 20,
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
                ),
              ),
            )
          : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                SizedBox(width: 56, height: 56, child: CircularProgressIndicator()),
              ]),
            ]),
    );
  }
}
