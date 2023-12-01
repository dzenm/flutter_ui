import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../base/base.dart';
import '../../../entities/article_entity.dart';
import '../../../generated/l10n.dart';
import '../../../http/http_manager.dart';
import '../../../models/article_model.dart';

/// HTTP请求
class HTTPListPage extends StatefulWidget {
  const HTTPListPage({super.key});

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
        title: const Text('HTTP请求', style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(children: [
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            child: Container(
              color: Colors.blueGrey,
              child: Column(children: [
                TapLayout(
                  width: MediaQuery.of(context).size.width,
                  height: 50.0,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SingleTextLayout(
                    title: '显示加载框',
                    titleColor: Colors.white,
                    suffix: CupertinoSwitch(value: isShowDialog, onChanged: (value) => setState(() => isShowDialog = value)),
                  ),
                ),
                TapLayout(
                  width: MediaQuery.of(context).size.width,
                  height: 50.0,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SingleTextLayout(
                    title: '显示错误提示框',
                    titleColor: Colors.white,
                    suffix: CupertinoSwitch(value: isShowToast, onChanged: (value) => setState(() => isShowToast = value)),
                  ),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
                flex: 1,
                child: MaterialButton(
                  onPressed: _getArticle,
                  color: Colors.blueGrey,
                  child: const Text('重新请求', style: TextStyle(color: Colors.white)),
                )),
            const SizedBox(width: 16),
            Expanded(
              flex: 1,
              child: MaterialButton(
                onPressed: () => context.read<ArticleModel>().clear(),
                color: Colors.blueGrey,
                child: const Text('清空数据', style: TextStyle(color: Colors.white)),
              ),
            ),
          ]),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              WrapButton(
                text: S.of(context).login,
                width: 100.0,
                onTap: () => CommonDialog.showToast('hello'),
              ),
              WrapButton(
                text: S.of(context).register,
                color: Colors.white,
                style: const TextStyle(fontSize: 15.0, color: Color.fromRGBO(8, 191, 98, 1.0)),
                onTap: () => {},
                width: 100.0,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Center(child: Text(text)),
            ),
          ),
        ]),
      ),
    );
  }

  void _getArticle() {
    HttpManager().getArticles(
      page: 0,
      isShowDialog: isShowDialog,
      isShowToast: isShowToast,
      success: (list, pageCount) {
        context.read<ArticleModel>().updateArticles(list);
      },
    );
  }
}
