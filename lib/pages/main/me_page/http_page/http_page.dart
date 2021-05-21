import 'package:flutter/material.dart';
import 'package:flutter_ui/http/api_client.dart';
import 'package:flutter_ui/models/data_bean.dart';
import 'package:flutter_ui/utils/str_util.dart';
import 'package:flutter_ui/utils/taost.dart';
import 'package:flutter_ui/widgets/tap_layout.dart';

class HTTPPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HTTPPageState();
}

class _HTTPPageState extends State<HTTPPage> {
  String _text = '点击请求http数据';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('HTTP请求')),
      body: TapLayout(
        onTap: _getArticle,
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Center(child: Text(_text)),
        ),
      ),
    );
  }

  void _getArticle() {
    ApiClient.instance.request(ApiClient.instance.apiServices.article('0'), (data) {
      setState(() {
        _text = StrUtil.formatToJson(data);
      });
    }, (e) {
      showToast(e.message);
    });
  }
}
