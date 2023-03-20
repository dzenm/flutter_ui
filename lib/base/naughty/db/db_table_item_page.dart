import 'package:flutter/material.dart';

import '../../db/column_entity.dart';
import '../../db/db_manager.dart';
import '../../widgets/state_view.dart';

/// 数据库表列表展示页面
class DBTableItemPage extends StatefulWidget {
  final String dbName;
  final String tableName;

  const DBTableItemPage(this.dbName, this.tableName, {super.key});

  @override
  State<StatefulWidget> createState() => _DBTableItemPageState();
}

class _DBTableItemPageState extends State<DBTableItemPage> {
  List<Map<String, dynamic>> _list = [];
  List<ColumnEntity> _columns = [];
  final StateController _controller = StateController();

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 500), getData);
  }

  Future<void> getData() async {
    _columns = await DBManager().getTableColumn(widget.dbName, widget.tableName);
    _list = await DBManager().where(widget.tableName);
    setState(() => _controller.loadComplete());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tableName),
      ),
      body: StateView(
        controller: _controller,
        child: SingleChildScrollView(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: _controller.init
                ? DataTable(
                    dataRowHeight: 20,
                    headingRowHeight: 32,
                    horizontalMargin: 0,
                    columnSpacing: 5,
                    showBottomBorder: true,
                    columns: _columns.map((column) => DataColumn(label: Text('${column.name}'))).toList(),
                    rows: _list.map((Map<String, dynamic> item) {
                      return DataRow(
                          cells: _columns.map((column) {
                        return DataCell(Text(item[column.name].toString()));
                      }).toList());
                    }).toList(),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
