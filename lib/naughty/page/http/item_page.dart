import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ui/naughty/beans/http_bean.dart';

const String HTTP_PAGE_ROUTE = 'naughty/homePage/httpPage';

class HttpPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HttpPageState();
}

class _HttpPageState extends State<HttpPage> {

  late HttpBean _bean;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _bean = ModalRoute.of(context)?.settings.arguments as HttpBean;
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Text(_bean.method ?? ''),
          SizedBox(width: 8),
          Expanded(child: Text(_bean.path ?? '', maxLines: 1, overflow: TextOverflow.ellipsis)),
        ]),
      ),
      body: Text('hello'),
    );
  }
}
