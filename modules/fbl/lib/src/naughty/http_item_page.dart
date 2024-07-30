import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/widget.dart';
import 'http_entity.dart';

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
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Text('${widget.entity.method}', style: const TextStyle(color: Colors.white)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${widget.entity.path}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ]),
        systemOverlayStyle: SystemUiOverlayStyle.light,
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
          SingleChildScrollView(child: _TabWidget(data: widget.entity.response)),
          SingleChildScrollView(child: _TabWidget(data: widget.entity.request)),
        ],
      ),
    );
  }
}

class _TabWidget extends StatefulWidget {
  final Map<String, dynamic> data;

  const _TabWidget({required this.data});

  @override
  State<StatefulWidget> createState() => _TabWidgetState();
}

class _TabWidgetState extends State<_TabWidget> {
  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> data = widget.data;
    Widget interval = const SizedBox(height: 8);

    List<Widget> list = [];
    list.add(_buildTitleView('  Headers'));
    list.add(interval);
    list.add(const Divider(height: 0.1, color: Color(0xFFEFEFEF)));
    list.add(interval);
    data.forEach((key, value) {
      if (key != 'Body') {
        list.add(const SizedBox(height: 4));
        list.add(_buildPairView(key, value.toString()));
        list.add(const SizedBox(height: 4));
      }
    });
    list.add(interval);
    list.add(_buildTitleView('  Body'));
    list.add(interval);
    list.add(const Divider(height: 0.1, color: Color(0xFFEFEFEF)));
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

  /// 键值对布局
  Widget _buildPairView(String key, String value) {
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
              if (value.isNotEmpty) {
                Clipboard.setData(ClipboardData(text: value));
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('复制成功: $value')),
              );
            },
            child: Text(value),
          ),
        ),
      ],
    );
  }

  /// 标题布局
  Widget _buildTitleView(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}
