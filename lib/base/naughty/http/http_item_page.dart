import 'package:flutter/material.dart';

import '../../utils/str_util.dart';
import '../../widgets/common_dialog.dart';
import '../../widgets/common_widget.dart';
import '../../widgets/tap_layout.dart';
import '../http_entity.dart';

/// 一个Http请求数据展示页面
class HTTPItemPage extends StatefulWidget {
  final HTTPEntity entity;

  const HTTPItemPage(this.entity, {super.key});

  @override
  State<StatefulWidget> createState() => _HTTPItemPageState();
}

class _HTTPItemPageState extends State<HTTPItemPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _titles = ['RESPONSE', 'REQUEST'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _titles.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Text('${widget.entity.method}'),
          const SizedBox(width: 8),
          Expanded(
            child: Text('${widget.entity.path}', maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ]),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          isScrollable: true,
          labelPadding: const EdgeInsets.all(8),
          indicatorSize: TabBarIndicatorSize.label,
          unselectedLabelColor: Colors.grey.shade300,
          tabs: _titles.map((title) {
            return Text(title, style: const TextStyle(fontSize: 14));
          }).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          SingleChildScrollView(child: _listView(widget.entity.response())),
          SingleChildScrollView(child: _listView(widget.entity.request())),
        ],
      ),
    );
  }

  // 列表布局
  Widget _listView(Map<String, dynamic> data) {
    List<Widget> list = [];
    Widget interval = const SizedBox(height: 8);
    list.add(titleView('  Headers'));
    list.add(interval);
    list.add(CommonWidget.divider());
    list.add(interval);
    data.forEach((key, value) {
      if (key != 'Body') {
        list.add(const SizedBox(height: 4));
        list.add(_pairView(key, value.toString()));
        list.add(const SizedBox(height: 4));
      }
    });
    list.add(interval);
    list.add(titleView('  Body'));
    list.add(interval);
    list.add(CommonWidget.divider());
    list.add(interval);
    list.add(Text(data['Body'].toString()));
    return Container(
      margin: const EdgeInsets.all(16),
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
            style: const TextStyle(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: TapLayout(
            alignment: Alignment.centerLeft,
            onTap: () {
              StrUtil.copy(value);
              CommonDialog.showToast('复制成功: $value');
            },
            child: Text(value),
          ),
        ),
      ],
    );
  }

  // 标题布局
  Widget titleView(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
  }
}
