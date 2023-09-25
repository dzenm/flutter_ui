import 'package:flutter/material.dart';

import '../widgets/widget.dart';
import 'http_entity.dart';
import 'http_item_page.dart';
import 'naughty.dart';

/// naughty 主页
class HTTPListWidget extends StatelessWidget {
  final List<HTTPEntity> list;
  final RefreshCallback onRefresh;

  const HTTPListWidget({
    super.key,
    required this.list,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        itemBuilder: _buildItem,
        itemCount: list.length,
      ),
    );
  }

  /// 列表item布局
  Widget _buildItem(BuildContext context, int index) {
    HTTPEntity entity = list[index];
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
          onTap: () => Naughty.instance.push(context, HTTPItemPage(entity)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildStatusView(entity),
              _buildContentView(entity),
            ],
          ),
        ),
      ),
    );
  }

  /// 请求状态布局
  Widget _buildStatusView(HTTPEntity entity) {
    Widget child;
    if (entity.status == Status.running) {
      String text = entity.status == Status.running
          ? 'Running'
          : entity.status == Status.success
              ? 'Success'
              : entity.status == Status.failed
                  ? 'Failed'
                  : 'None';
      child = Text(text, style: const TextStyle(color: Colors.white));
      child = const SizedBox(
        width: 8,
        height: 8,
        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
      );
    } else {
      child = _buildStatusCodeView(entity);
    }
    child = Row(mainAxisAlignment: MainAxisAlignment.center, children: [child]);
    return Container(
      height: 18,
      width: 56,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: _stateColor(entity.status),
        shape: BoxShape.rectangle,
        borderRadius: const BorderRadius.only(topRight: Radius.circular(7), bottomLeft: Radius.circular(7)),
      ),
      child: child,
    );
  }

  /// 请求的内容布局
  Widget _buildContentView(HTTPEntity entity) {
    return Container(
      padding: const EdgeInsets.only(left: 16.0, top: 8.0, right: 16.0, bottom: 16.0),
      child: Row(children: [
        Expanded(
          child: Column(children: [
            _buildMethodView(entity),
            const SizedBox(height: 16),
            _buildDetailView(entity),
          ]),
        ),
      ]),
    );
  }

  /// 请求状态码布局
  Widget _buildStatusCodeView(HTTPEntity entity) {
    return Text(
      entity.statusCode.toString(),
      style: const TextStyle(color: Colors.white),
    );
  }

  /// 请求方法和请求路径布局
  Widget _buildMethodView(HTTPEntity entity) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        entity.method ?? '',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      const SizedBox(width: 8),
      Expanded(
          child: Text(
        '${entity.path ?? ''}(第${entity.index}次)',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.bold),
      )),
    ]);
  }

  /// 请求的详细信息布局
  Widget _buildDetailView(HTTPEntity entity) {
    return Row(
      children: [
        SizedBox(width: 80, child: Text(entity.duration)),
        Expanded(child: Text(entity.time)),
        Text(entity.size),
      ],
    );
  }

  /// 根据请求状态显示不同的颜色
  Color _stateColor(Status status) {
    return status == Status.running
        ? Colors.blue
        : status == Status.success
            ? Colors.green
            : status == Status.failed
                ? Colors.red
                : Colors.yellow;
  }
}
