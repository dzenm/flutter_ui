import '../../base/base.dart';
import 'mall_page.dart';
import 'order/add_order_page.dart';
import 'order/order_page.dart';

class MallRouter {
  static const String mall = '/mall';
  static const String orders = '$mall/orders';
  static const String addOrder = '$mall/addOrder';

  static List<AppPageConfig> get routers => [
        AppPageConfig(mall, builder: (settings) {
          return const MallPage();
        }),
        AppPageConfig(orders, builder: (settings) {
          return const OrderPage();
        }),
        AppPageConfig(addOrder, builder: (settings) {
          return const AddOrderPage();
        }),
        AppPageConfig(orders, builder: (settings) {
          return const OrderPage();
        }),
      ];
}
