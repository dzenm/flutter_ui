import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ui/base/http/api_client.dart';
import 'package:flutter_ui/base/utils/str_util.dart';
import 'package:flutter_ui/base/widgets/common_dialog.dart';
import 'package:flutter_ui/base/widgets/common_widget.dart';
import 'package:flutter_ui/base/widgets/single_text_layout.dart';
import 'package:flutter_ui/base/widgets/tap_layout.dart';

class HTTPPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HTTPPageState();
}

class _HTTPPageState extends State<HTTPPage> {
  String _text = '';
  bool isShowDialog = true;
  bool isShowToast = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(title: 'HTTP请求'),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(children: [
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              child: Container(
                color: Colors.blueGrey,
                child: Column(children: [
                  TapLayout(
                    width: MediaQuery.of(context).size.width,
                    height: 50.0,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: SingleTextLayout(
                      title: '显示加载框',
                      titleColor: Colors.white,
                      suffix: CupertinoSwitch(value: isShowDialog, onChanged: (value) => setState(() => isShowDialog = value)),
                    ),
                  ),
                  TapLayout(
                    width: MediaQuery.of(context).size.width,
                    height: 50.0,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: SingleTextLayout(
                      title: '显示错误提示框',
                      titleColor: Colors.white,
                      suffix: CupertinoSwitch(value: isShowToast, onChanged: (value) => setState(() => isShowToast = value)),
                    ),
                  ),
                  TapLayout(
                    width: MediaQuery.of(context).size.width,
                    height: 50.0,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    onTap: () => showToast('下一级'),
                    child: SingleTextLayout(
                      title: '进入下一级',
                      titleColor: Colors.white,
                      forwardColor: Colors.white,
                      isShowForward: true,
                    ),
                  ),
                ]),
              ),
            ),
            SizedBox(height: 16),
            Row(children: [
              Expanded(
                  child: MaterialButton(
                    onPressed: _getArticle,
                    child: Text('重新请求', style: TextStyle(color: Colors.white)),
                    color: Colors.blueGrey,
                  ),
                  flex: 1),
              SizedBox(width: 16),
              Expanded(
                child: MaterialButton(
                  onPressed: () => setState(() => _text = ''),
                  child: Text('清空数据', style: TextStyle(color: Colors.white)),
                  color: Colors.blueGrey,
                ),
                flex: 1,
              ),
            ]),
            SizedBox(height: 16),
            Expanded(
                child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Center(child: Text(_text)),
            )),
          ]),
        ),
      ),
    );
  }

  void _getArticle() {
    ApiClient.instance.request(apiServices.article('0'), isShowDialog: isShowDialog, isShowToast: isShowToast, success: (data) {
      setState(() => _text = StrUtil.formatToJson(data));
    });
  }
}
