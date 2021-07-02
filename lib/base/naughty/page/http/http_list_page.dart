import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ui/base/naughty/entities/http_entity.dart';
import 'package:flutter_ui/base/naughty/naughty.dart';
import 'package:flutter_ui/base/naughty/page/db/db_list_page.dart';
import 'package:flutter_ui/base/naughty/page/http/http_item_page.dart';
import 'package:flutter_ui/base/router/route_manager.dart';
import 'package:flutter_ui/base/widgets/menu_Item.dart';
import 'package:flutter_ui/base/widgets/tap_layout.dart';

/// naughty 主页
class HTTPListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HTTPListPageState();
}

class _HTTPListPageState extends State<HTTPListPage> {
  List<HTTPEntity> _list = [];
  List<Item> _items = [
    Item(0, title: 'Database'),
    Item(1, title: 'SharedPreference'),
    Item(2, title: 'Setting'),
    Item(3, title: 'Clear'),
    Item(4, title: 'Quit'),
  ];

  @override
  void initState() {
    super.initState();
    Naughty.getInstance.dismiss();
    getData();
  }

  //列表要展示的数据
  Future getData() async {
    await Future.delayed(Duration(seconds: 0), () {
      setState(() => _list = Naughty.getInstance.data);
    });
  }

  @override
  void dispose() {
    Naughty.getInstance.show();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Debug Mode'),
        actions: [
          PopupMenuButton<Item>(
            elevation: 4.0,
            onSelected: (Item item) {
              if (item.index == 0) {
                Navigation.push(DBListPage());
              }
            },
            itemBuilder: (BuildContext context) {
              return _items
                  .map((value) => PopupMenuItem<Item>(
                      value: value, child: Text(value.title ?? '')))
                  .toList();
            },
          )
        ],
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
          onTap: () => Navigation.push(HTTPItemPage(_list[index])),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _statusView(index),
              Container(
                padding: EdgeInsets.only(
                    left: 16.0, top: 8.0, right: 16.0, bottom: 16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _statusCodeView(index),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        children: [
                          _methodView(index),
                          SizedBox(height: 8),
                          SizedBox(height: 8),
                          _detail(index),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 请求状态
  Widget _statusView(int index) {
    String text = _list[index].status == Status.running
        ? 'Running'
        : _list[index].status == Status.success
            ? 'Success'
            : _list[index].status == Status.failed
                ? 'Failed'
                : 'None';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: _stateColor(index),
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(7), bottomLeft: Radius.circular(7)),
      ),
      child: Text(text, style: TextStyle(color: Colors.white)),
    );
  }

  // 请求状态码布局
  Widget _statusCodeView(int index) {
    return Text(
      _list[index].statusCode.toString(),
      style: TextStyle(fontWeight: FontWeight.bold, color: _stateColor(index)),
    );
  }

  // 请求方法和请求路径布局
  Widget _methodView(int index) {
    return Row(children: [
      Text(
        _list[index].method ?? '',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      SizedBox(width: 8),
      Expanded(
          child: Text(_list[index].path ?? '',
              maxLines: 1, overflow: TextOverflow.ellipsis)),
    ]);
  }

  Widget _detail(int index) {
    return Row(
      children: [
        SizedBox(width: 80, child: Text(_list[index].duration)),
        Expanded(child: Text(_list[index].time)),
        Text(_list[index].size),
      ],
    );
  }

  // 根据请求状态显示不同的颜色
  Color _stateColor(int index) {
    return _list[index].status == Status.running
        ? Colors.blue
        : _list[index].status == Status.success
            ? Colors.green
            : _list[index].status == Status.failed
                ? Colors.red
                : Colors.yellow;
  }

  // 下拉刷新方法,为_list重新赋值
  Future<Null> _onRefresh() async {
    await getData();
  }
}
