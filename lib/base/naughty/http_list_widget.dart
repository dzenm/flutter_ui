import 'package:flutter/material.dart';

import '../widgets/tap_layout.dart';
import 'http_entity.dart';
import 'http_item_page.dart';
import 'naughty.dart';

/// naughty 主页
class HTTPListWidget extends StatefulWidget {
  const HTTPListWidget({super.key});

  @override
  State<StatefulWidget> createState() => _HTTPListWidgetState();
}

class _HTTPListWidgetState extends State<HTTPListWidget> {
  List<HTTPEntity> _list = [];

  @override
  void initState() {
    super.initState();

    _getData();
  }

  //列表要展示的数据
  Future _getData() async {
    Future.delayed(Duration.zero, () {
      setState(() => _list = Naughty.instance.httpRequests);
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _getData,
      child: ListView.builder(
        shrinkWrap: true,
        itemBuilder: _buildItem,
        itemCount: _list.length,
      ),
    );
  }

  /// 列表单item布局
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
          onTap: () => Naughty.instance.push(context, HTTPItemPage(_list[index])),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildStatusView(index),
              _buildContentView(index),
            ],
          ),
        ),
      ),
    );
  }

  /// 请求状态布局
  Widget _buildStatusView(int index) {
    String text = _list[index].status == Status.running
        ? 'Running'
        : _list[index].status == Status.success
            ? 'Success'
            : _list[index].status == Status.failed
                ? 'Failed'
                : 'None';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: _stateColor(index),
        shape: BoxShape.rectangle,
        borderRadius: const BorderRadius.only(topRight: Radius.circular(7), bottomLeft: Radius.circular(7)),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white)),
    );
  }

  /// 请求的内容布局
  Widget _buildContentView(int index) {
    return Container(
      padding: const EdgeInsets.only(left: 16.0, top: 8.0, right: 16.0, bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusCodeView(index),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              children: [
                _buildMethodView(index),
                const SizedBox(height: 8),
                const SizedBox(height: 8),
                _buildDetailView(index),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 请求状态码布局
  Widget _buildStatusCodeView(int index) {
    return Text(
      _list[index].statusCode.toString(),
      style: TextStyle(fontWeight: FontWeight.bold, color: _stateColor(index)),
    );
  }

  /// 请求方法和请求路径布局
  Widget _buildMethodView(int index) {
    return Row(children: [
      Text(
        _list[index].method ?? '',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      const SizedBox(width: 8),
      Expanded(child: Text(_list[index].path ?? '', maxLines: 1, overflow: TextOverflow.ellipsis)),
    ]);
  }

  /// 请求的详细信息布局
  Widget _buildDetailView(int index) {
    return Row(
      children: [
        SizedBox(width: 80, child: Text(_list[index].duration)),
        Expanded(child: Text(_list[index].time)),
        Text(_list[index].size),
      ],
    );
  }

  /// 根据请求状态显示不同的颜色
  Color _stateColor(int index) {
    return _list[index].status == Status.running
        ? Colors.blue
        : _list[index].status == Status.success
            ? Colors.green
            : _list[index].status == Status.failed
                ? Colors.red
                : Colors.yellow;
  }
}
