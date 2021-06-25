import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ui/base/http/api_client.dart';
import 'package:flutter_ui/base/log/log.dart';
import 'package:flutter_ui/base/widgets/banner_view.dart';
import 'package:flutter_ui/base/widgets/common_dialog.dart';
import 'package:flutter_ui/beans/article_bean.dart';
import 'package:flutter_ui/beans/banner_bean.dart';

//子页面
//代码中设置了一个内部的_title变量，这个变量是从主页面传递过来的，然后根据传递过来的具体值显示在APP的标题栏和屏幕中间。
class HomePage extends StatefulWidget {
  final String _title;

  HomePage(this._title);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> _titles = [];
  List<String> _images = [];
  List<String> _urls = [];

  @override
  void initState() {
    super.initState();

    // titles.add(
    //     '''近日，北大全校教师干部大会刚刚召开，63岁的林建华卸任北大校长；原北大党委书记郝平接替林建华，成为新校长。曾在北京任职多年、去年担任山西高院院长的邱水平回到北大，担任党委书记。图为2018年5月4日，北京大学举行建校120周年纪念大会，时任北京大学校长林建华（右）与时任北京大学党委书记郝平（左）''');
    // titles.add('''邱水平、郝平、林建华均为“老北大人”，都曾离开北大，又重归北大任职。图为2018年5月4日，北京大学举行建校120周年纪念大会，时任北京大学党委书记郝平讲话''');
    // titles.add('''此番卸任的林建华，亦是北大出身，历任重庆大学、浙江大学、北京大学三所“双一流”高校校长。图为2018年5月4日，北京大学举行建校120周年纪念大会，时任北京大学校长林建华讲话。''');
    // titles.add('''书记转任校长的郝平，为十九届中央委员会候补委员。从北大毕业后留校，后离开北大，历任北京外国语大学校长、教育部副部长。2016年12月，时隔11年，郝平再回北大，出任北大党委书记。''');
    // images.add("http://n.sinaimg.cn/news/1_img/vcg/2b0c102b/64/w1024h640/20181024/wBkr-hmuuiyw6863395.jpg");
    // images.add("http://n.sinaimg.cn/news/1_img/vcg/2b0c102b/99/w1024h675/20181024/FGXD-hmuuiyw6863401.jpg");
    // images.add("http://n.sinaimg.cn/news/1_img/vcg/2b0c102b/107/w1024h683/20181024/kZj2-hmuuiyw6863420.jpg");
    // images.add("http://n.sinaimg.cn/news/1_img/vcg/2b0c102b/105/w1024h681/20181024/tOiL-hmuuiyw6863462.jpg");
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(brightness: Brightness.dark, title: Text(widget._title, style: TextStyle(color: Colors.white))),
      body: Container(
        child: Column(children: [
          BannerView(
            titles: _titles,
            children: _images.map((value) => Image.network(value, fit: BoxFit.cover)).toList(),
            onTap: (index) {
              showToast(index.toString());
            },
          ),
        ]),
      ),
    );
  }

  void _getData() async {
    await _getBanner();
    await _getArticle('3');
  }

  // 登录按钮点击事件
  Future<void> _getBanner() async {
    ApiClient.getInstance.request(apiServices.banner(), success: (data) async {
      BannerBean bean = BannerBean();
      List<BannerBean?> list = (data as List<dynamic>).map((e) => bean.fromJson(e)).toList();
      list.forEach((element) async {
        //   _titles.add(element!.title ?? '');
        //   _images.add(element.imagePath ?? '');
        //   _urls.add(element.url ?? '');
        await bean.insertItem(element);
      });
      await bean.queryItems(bean);
    });
  }

  Future<void> _getArticle(String number) async {
    ApiClient.getInstance.request(apiServices.article(number), success: (data) async {
      ArticleBean bean = ArticleBean();
      List<ArticleBean?> list = (data["datas"] as List<dynamic>).map((e) => bean.fromJson(e)).toList();
      list.forEach((element) async {
        await bean.insertItem(element);
      });
      await ArticleBean().queryItems(ArticleBean());
    });
  }
}
