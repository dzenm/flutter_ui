import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ui/base/db/sql_manager.dart';
import 'package:flutter_ui/base/entities/column_entity.dart';
import 'package:flutter_ui/base/widgets/state_view.dart';

/// 数据库表列表展示页面
class DBTableItemPage extends StatefulWidget {
  final String dbName;
  final String tableName;

  DBTableItemPage(
    this.dbName,
    this.tableName,
  );

  @override
  State<StatefulWidget> createState() => _DBTableItemPageState();
}

class _DBTableItemPageState extends State<DBTableItemPage> {
  List<Map<String, dynamic>> _list = [];
  List<ColumnEntity> _columns = [];
  LoadState _loadingState = LoadState.none;

  @override
  void initState() {
    super.initState();

    setState(() => _loadingState = LoadState.loading);
    Future.delayed(Duration(milliseconds: 500), getData);
  }

  Future<void> getData() async {
    _columns = await SqlManager.getInstance.getTableColumn(widget.dbName, widget.tableName);
    _list = await SqlManager.getInstance.where(widget.tableName);
    setState(() => _loadingState = LoadState.success);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tableName),
      ),
      body: StateView(
        state: _loadingState,
        child: SingleChildScrollView(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              dataRowHeight: 20,
              headingRowHeight: 32,
              horizontalMargin: 0,
              columnSpacing: 5,
              showBottomBorder: true,
              columns: _columns.map((column) => DataColumn(label: Text('${column.name}'))).toList(),
              rows: _list.map((Map<String, dynamic> item) {
                return DataRow(
                    cells: _columns.map((column) {
                  return DataCell(Text('${item[column.name].toString()}'));
                }).toList());
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
