import 'package:fbl/fbl.dart';
import 'package:go_router/go_router.dart';

import '../routers.dart';
import 'mall_page.dart';
import 'order/add_address_page.dart';
import 'order/add_order_page.dart';
import 'order/order_page.dart';

class MallRouter {
  static const String mall = 'mall';
  static const String orders = 'orders';
  static const String addOrder = 'addOrder';
  static const String addAddress = 'addAddress';

  static List<RouteBase> get routers => BuildConfig.isMobile //
      ? _MallRouterMobile.routers
      : _MallRouterDesktop.routers;
}

class _MallRouterMobile {
  static List<RouteBase> get routers => [
        GoRoute(
          name: MallRouter.mall,
          path: '/mall',
          builder: (context, state) {
            return const MallPage();
          },
          routes: [
            GoRoute(
              name: MallRouter.orders,
              path: '/orders',
              builder: (context, state) {
                return const OrderPage();
              },
            ),
            GoRoute(
              name: MallRouter.addOrder,
              path: '/addOrder',
              builder: (context, state) {
                return const AddOrderPage();
              },
              routes: [
                GoRoute(
                  name: MallRouter.addAddress,
                  path: '/addAddress',
                  builder: (context, state) {
                    return const AddAddressPage();
                  },
                ),
              ],
            ),
          ],
        ),
      ];
}

class _MallRouterDesktop {
  static List<RouteBase> get routers => [
        GoRoute(
          name: MallRouter.mall,
          path: '/mall',
          builder: (context, state) {
            return const MallPage();
          },
          routes: [
            GoRoute(
              name: MallRouter.orders,
              path: '/orders',
              builder: (context, state) {
                return const OrderPage();
              },
            ),
            GoRoute(
              name: MallRouter.addOrder,
              path: '/addOrder',
              builder: (context, state) {
                return const AddOrderPage();
              },
              routes: [
                GoRoute(
                  name: MallRouter.addAddress,
                  path: '/addAddress',
                  builder: (context, state) {
                    return const AddAddressPage();
                  },
                  routes: [CommonRouters.citySelected],
                ),
              ],
            ),
          ],
        ),
      ];
}
