import '../../../base/route/app_router.dart';
import '../../common/example_page.dart';
import 'article/article_page.dart';
import 'coin/coin_page.dart';
import 'collect/collect_page.dart';
import 'info/edit_info_page.dart';
import 'info/view_info_page.dart';
import 'medicine/medicine_page.dart';
import 'rank/rank_page.dart';
import 'setting_page/setting_page.dart';

///
/// Created by a0010 on 2023/5/23 14:50
///

///
/// Created by a0010 on 2023/5/6 13:32
///
class MeRouter extends IRouter {
  static final String example = '/example';
  static final String article = '/me/article';
  static final String coin = '/me/coin';
  static final String collect = '/me/collect';
  static final String medicine = '/me/medicine';
  static final String rank = '/me/rank';
  static final String setting = '/me/setting';
  static final String editInfo = '/me/editInfo';
  static final String viewInfo = '/me/viewInfo';

  @override
  void initRouter(AppRouter router) {
    router.define(example, pagerBuilder: (context) {
      return ExamplePage();
    });
    router.define(article, pagerBuilder: (context) {
      return ArticlePage();
    });
    router.define(coin, pagerBuilder: (context) {
      return CoinPage();
    });
    router.define(collect, pagerBuilder: (context) {
      return CollectPage();
    });
    router.define(medicine, pagerBuilder: (context) {
      return MedicinePage(medicineName: '');
    });
    router.define(rank, pagerBuilder: (context) {
      return RankPage();
    });
    router.define(setting, pagerBuilder: (context) {
      return SettingPage();
    });
    router.define(editInfo, pagerBuilder: (context) {
      return EditInfoPage();
    });
    router.define(viewInfo, pagerBuilder: (context) {
      return ViewInfoPage();
    });
  }
}
