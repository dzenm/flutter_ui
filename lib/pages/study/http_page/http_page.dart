import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ui/base/res/strings.dart';
import 'package:flutter_ui/base/utils/str_util.dart';
import 'package:flutter_ui/base/widgets/common_dialog.dart';
import 'package:flutter_ui/base/widgets/single_text_layout.dart';
import 'package:flutter_ui/base/widgets/tap_layout.dart';
import 'package:flutter_ui/base/widgets/wrap_button.dart';
import 'package:flutter_ui/entities/article_entity.dart';
import 'package:flutter_ui/http/http_manager.dart';
import 'package:flutter_ui/models/article_model.dart';
import 'package:provider/provider.dart';

class HTTPListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HTTPListPageState();
}

class _HTTPListPageState extends State<HTTPListPage> {
  bool isShowDialog = true;
  bool isShowToast = true;

  @override
  Widget build(BuildContext context) {
    List<ArticleEntity> list = context.watch<ArticleModel>().allArticles;
    String text = StrUtil.formatToJson(list);
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
                  onPressed: () => context.read<ArticleModel>().clear(),
                  child: Text('清空数据', style: TextStyle(color: Colors.white)),
                  color: Colors.blueGrey,
                ),
                flex: 1,
              ),
            ]),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                WrapButton(
                  text: S.of(context).login,
                  width: 100.0,
                  onTap: () => {CommonDialog.showToast('hello')},
                ),
                WrapButton(
                  text: S.of(context).register,
                  color: Colors.white,
                  style: TextStyle(fontSize: 15.0, color: Color.fromRGBO(8, 191, 98, 1.0)),
                  onTap: () => {},
                  width: 100.0,
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Center(child: Text(text)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  void _getArticle() {
    HttpManager.instance.getArticleList(
      page: 0,
      isShowDialog: isShowDialog,
      isShowToast: isShowToast,
      success: (list, pageCount) {
        context.read<ArticleModel>().updateArticles(list);
      },
    );
  }
}
