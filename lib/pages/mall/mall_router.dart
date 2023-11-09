import '../../base/base.dart';
import 'mall_page.dart';
import 'order/add_order_page.dart';
import 'order/order_page.dart';

class MallRouter {
  static const String mall = '/mall';
  static const String orders = '$mall/orders';
  static const String addOrder = '$mall/addOrder';

  static List<AppRoutePage> get routers => [
        AppRoutePage(
          name: mall,
          builder: (settings) {
            return const MallPage();
          },
        ),
        AppRoutePage(
          name: orders,
          builder: (settings) {
            return const OrderPage();
          },
        ),
        AppRoutePage(
          name: addOrder,
          builder: (settings) {
            return const AddOrderPage();
          },
        ),
        AppRoutePage(
          name: orders,
          builder: (settings) {
            return const OrderPage();
          },
        ),
      ];
}
