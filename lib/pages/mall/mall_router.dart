import 'package:fbl/fbl.dart';

import 'mall_page.dart';
import 'order/add_order_page.dart';
import 'order/order_page.dart';

class MallRouter {
  static const String mall = 'mall';
  static const String orders = 'orders';
  static const String addOrder = 'addOrder';

  static List<RouteBase> get routers => [
        ARoute(
          name: mall,
          path: '/mall',
          builder: (context, state) {
            return const MallPage();
          },
          routes: [
            ARoute(
              name: orders,
              path: '/orders',
              builder: (context, state) {
                return const OrderPage();
              },
            ),
            ARoute(
              name: addOrder,
              path: '/addOrder',
              builder: (context, state) {
                return const AddOrderPage();
              },
            ),
          ]
        ),
      ];
}
