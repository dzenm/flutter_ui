import 'package:flutter/material.dart';
import 'package:flutter_ui/entities/banner_entity.dart';

///
/// Created by a0010 on 2022/10/25 11:25
///
class BannerModel extends ChangeNotifier {
  BannerEntity _entity = BannerEntity();

  BannerModel() {
    // _titles.add('''近日，北大全校教师干部大会刚刚召开，63岁的林建华卸任北大校长；原北大党委书记郝平接替林建华，成为新校长。曾在北京任职多年、去年担任山西高院院长的邱水平回到北大，担任党委书记。图为2018年5月4日，北京大学举行建校120周年纪念大会，时任北京大学校长林建华（右）与时任北京大学党委书记郝平（左）''');
    // _titles.add('''邱水平、郝平、林建华均为“老北大人”，都曾离开北大，又重归北大任职。图为2018年5月4日，北京大学举行建校120周年纪念大会，时任北京大学党委书记郝平讲话''');
    // _titles.add('''此番卸任的林建华，亦是北大出身，历任重庆大学、浙江大学、北京大学三所“双一流”高校校长。图为2018年5月4日，北京大学举行建校120周年纪念大会，时任北京大学校长林建华讲话。''');
    // _titles.add('''书记转任校长的郝平，为十九届中央委员会候补委员。从北大毕业后留校，后离开北大，历任北京外国语大学校长、教育部副部长。2016年12月，时隔11年，郝平再回北大，出任北大党委书记。''');
    // _images.add("http://n.sinaimg.cn/news/1_img/vcg/2b0c102b/64/w1024h640/20181024/wBkr-hmuuiyw6863395.jpg");
    // _images.add("http://n.sinaimg.cn/news/1_img/vcg/2b0c102b/99/w1024h675/20181024/FGXD-hmuuiyw6863401.jpg");
    // _images.add("http://n.sinaimg.cn/news/1_img/vcg/2b0c102b/107/w1024h683/20181024/kZj2-hmuuiyw6863420.jpg");
    // _images.add("http://n.sinaimg.cn/news/1_img/vcg/2b0c102b/105/w1024h681/20181024/tOiL-hmuuiyw6863462.jpg");

    getAllBanners();
  }

  void getAllBanners() async {
    List list = await _entity.where(_entity);
    List<BannerEntity> banners = list.map((e) => e as BannerEntity).toList();
    _banners = banners;
  }

  List<BannerEntity> _banners = [];
  List<String> _titles = [];
  List<String> _images = [];
  List<String> _urls = [];

  List<String> get titles => _titles;

  List<String> get images => _images;

  List<String> get urls => _urls;

  void updateBanner(List<BannerEntity> list) {
    /// 处理banner数据
    List<String> titles = [], images = [], urls = [];
    list.forEach((element) async {
      titles.add(element.title ?? '');
      images.add(element.imagePath ?? '');
      urls.add(element.url ?? '');
    });
    // 重置banner数据
    _titles.clear();
    _titles.addAll(titles);
    _images.clear();
    _images.addAll(images);
    _urls.clear();
    _urls.addAll(urls);
    // 保存banner到数据库
    _entity.insert(list);
    notifyListeners();
  }

  void clear() {
    _banners.clear();
    _titles.clear();
    _images.clear();
    _urls.clear();
    notifyListeners();
  }
}