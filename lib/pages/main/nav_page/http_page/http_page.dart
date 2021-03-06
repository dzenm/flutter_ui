import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ui/base/http/api_client.dart';
import 'package:flutter_ui/base/res/strings.dart';
import 'package:flutter_ui/base/utils/str_util.dart';
import 'package:flutter_ui/base/widgets/common_dialog.dart';
import 'package:flutter_ui/base/widgets/wrap_button.dart';
import 'package:flutter_ui/base/widgets/single_text_layout.dart';
import 'package:flutter_ui/base/widgets/tap_layout.dart';

class HTTPListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HTTPListPageState();
}

class _HTTPListPageState extends State<HTTPListPage> {
  String _text = '';
  bool isShowDialog = true;
  bool isShowToast = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HTTP请求', style: TextStyle(color: Colors.white)),
      ),
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
            WrapButton(
              text: S.of(context).login,
              margin: EdgeInsets.only(bottom: 10.0),
              width: 100.0,
              onTap: () => {showToast('hello')},
            ),
            WrapButton(
              text: S.of(context).register,
              color: Colors.white,
              style: TextStyle(fontSize: 15.0, color: Color.fromRGBO(8, 191, 98, 1.0)),
              margin: EdgeInsets.only(top: 10.0),
              onTap: () => {},
              width: 100.0,
            ),
            TapLayout(
              width: MediaQuery.of(context).size.width,
              height: 50.0,
              isRipple: false,
              borderRadius: BorderRadius.all(Radius.circular(16)),
              background: Colors.red,
              padding: EdgeInsets.symmetric(horizontal: 16),
              onTap: () => showToast('下一级'),
              child: SingleTextLayout(
                title: '进入下一级',
                titleColor: Colors.white,
                forwardColor: Colors.white,
                isShowForward: true,
              ),
            ),
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
    ApiClient.getInstance.request(apiServices.article('0'), isShowDialog: isShowDialog, isShowToast: isShowToast, success: (data) {
      setState(() => _text = StrUtil.formatToJson(data));
    });
  }
}
