import 'package:flutter/material.dart';

import '../entities/banner_entity.dart';

///
/// Created by a0010 on 2022/10/25 11:25
/// Provider中共享的Banner数据
class BannerModel with ChangeNotifier {
  final BannerEntity _entity = BannerEntity();

  /// 初始化Banner数据，从数据库获取所有的Banner数据
  Future<void> init() async {
    // _titles.add('''近日，北大全校教师干部大会刚刚召开，63岁的林建华卸任北大校长；原北大党委书记郝平接替林建华，成为新校长。曾在北京任职多年、去年担任山西高院院长的邱水平回到北大，担任党委书记。图为2018年5月4日，北京大学举行建校120周年纪念大会，时任北京大学校长林建华（右）与时任北京大学党委书记郝平（左）''');
    // _titles.add('''邱水平、郝平、林建华均为“老北大人”，都曾离开北大，又重归北大任职。图为2018年5月4日，北京大学举行建校120周年纪念大会，时任北京大学党委书记郝平讲话''');
    // _titles.add('''此番卸任的林建华，亦是北大出身，历任重庆大学、浙江大学、北京大学三所“双一流”高校校长。图为2018年5月4日，北京大学举行建校120周年纪念大会，时任北京大学校长林建华讲话。''');
    // _titles.add('''书记转任校长的郝平，为十九届中央委员会候补委员。从北大毕业后留校，后离开北大，历任北京外国语大学校长、教育部副部长。2016年12月，时隔11年，郝平再回北大，出任北大党委书记。''');
    // _images.add("http://n.sinaimg.cn/news/1_img/vcg/2b0c102b/64/w1024h640/20181024/wBkr-hmuuiyw6863395.jpg");
    // _images.add("http://n.sinaimg.cn/news/1_img/vcg/2b0c102b/99/w1024h675/20181024/FGXD-hmuuiyw6863401.jpg");
    // _images.add("http://n.sinaimg.cn/news/1_img/vcg/2b0c102b/107/w1024h683/20181024/kZj2-hmuuiyw6863420.jpg");
    // _images.add("http://n.sinaimg.cn/news/1_img/vcg/2b0c102b/105/w1024h681/20181024/tOiL-hmuuiyw6863462.jpg");
    List list = await _entity.where(_entity);
    List<BannerEntity> banners = list.map((e) => e as BannerEntity).toList();
    _banners = banners;
  }

  /// 数据库对应的所有数据
  List<BannerEntity> _banners = [];

  /// 获取所有Banner数据
  List<BannerEntity> get banners => List.generate(_banners.length, (index) => _banners[index]);

  /// 更新所有Banner数据
  set banners(List<BannerEntity> list) {
    for (var banner in list) {
      _handleBanner(banner);
    }
    notifyListeners();
  }

  /// 处理banner数据，如果存在就更新，不存在就新增
  void _handleBanner(BannerEntity banner) {
    int index = _banners.indexWhere((e) => e.id == banner.id);
    if (index == -1) {
      // 保存banner
      _entity.insert(banner);
      _banners.add(banner);
    } else {
      // 更新banner
      _entity.update(banner);
      _banners[index] = banner;
    }
  }

  /// 清空数据
  void clear() {
    _banners.clear();
    notifyListeners();
  }
}
