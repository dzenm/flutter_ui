import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ui/base/naughty/entities/http_entity.dart';
import 'package:flutter_ui/base/naughty/utils/str_util.dart';
import 'package:flutter_ui/base/widgets/common_dialog.dart';
import 'package:flutter_ui/base/widgets/common_widget.dart';
import 'package:flutter_ui/base/widgets/tap_layout.dart';

const String ITEM_PAGE_ROUTE = 'naughty/httpPage/itemPage';

/// 一个Http请求数据展示页面
class ItemPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> with SingleTickerProviderStateMixin {
  late HTTPEntity _bean;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    _bean = ModalRoute.of(context)?.settings.arguments as HTTPEntity;
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Text(_bean.method ?? ''),
          SizedBox(width: 8),
          Expanded(child: Text(_bean.path ?? '', maxLines: 1, overflow: TextOverflow.ellipsis)),
        ]),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          tabs: [Tab(text: 'RESPONSE'), Tab(text: 'REQUEST')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          SingleChildScrollView(child: _listView(_bean.response())),
          SingleChildScrollView(child: _listView(_bean.request())),
        ],
      ),
    );
  }

  // 列表布局
  Widget _listView(Map<String, dynamic> data) {
    List<Widget> list = [];
    Widget interval = SizedBox(height: 8);
    list.add(_titleView('  Headers'));
    list.add(interval);
    list.add(divider());
    list.add(interval);
    data.forEach((key, value) {
      if (key != 'Body') {
        list.add(SizedBox(height: 4));
        list.add(_pairView(key, value.toString()));
        list.add(SizedBox(height: 4));
      }
    });
    list.add(interval);
    list.add(_titleView('  Body'));
    list.add(interval);
    list.add(divider());
    list.add(interval);
    list.add(Text(data['Body'].toString()));
    return Container(
      margin: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: list,
      ),
    );
  }

  // 键值对布局
  Widget _pairView(String key, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            key,
            style: TextStyle(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: TapLayout(
            child: Text(value),
            alignment: Alignment.centerLeft,
            onTap: () {
              StrUtil.copy(value);
              showToast('复制成功: $value');
            },
          ),
        ),
      ],
    );
  }

  // 标题布局
  Widget _titleView(String title) {
    return Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
  }
}
