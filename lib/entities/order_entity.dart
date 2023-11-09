import 'package:json_annotation/json_annotation.dart';

import '../base/db/db.dart';

part 'order_entity.g.dart';

///
/// Created by a0010 on 2023/2/23 14:26
/// 导航
@JsonSerializable()
class OrderEntity extends DBBaseEntity {
  String? orderUid; // 订单编号
  String? sender; // 发货人
  String? sendPhone; // 发货人手机号
  String? sendAddress; // 发货地址
  String? sendTime; // 发货时间
  String? receiver; // 收获人
  String? receivePhone; // 收获人手机号
  String? receiveAddress; // 收获地址
  String? receiveTime; // 收获时间
  String? trackingNumber; // 快递单号
  double freight = 0.0; // 运费
  OrderStatus status = OrderStatus.create; // 订单状态
  int piece = 0; // 件数
  int weight = 0; // 重量(kg)
  double estimatedPrice = 0.0; // 预估价格
  double actualPrice = 0.0; // 实际卖出的价格
  PayMethod payMethod = PayMethod.toBePaid; // 支付方式（默认为0）：0=待支付；1=已支付
  int isDelete = 0; // 是否删除

  OrderEntity();

  factory OrderEntity.fromJson(Map<String, dynamic> json) => _$OrderEntityFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$OrderEntityToJson(this);

  @override
  String get createTableSql => '''$tableName(
    orderUid TEXT PRIMARY KEY NOT NULL, 
    sender TEXT, 
    sendPhone TEXT, 
    sendAddress TEXT, 
    sendTime TEXT, 
    receiver TEXT, 
    receivePhone TEXT, 
    receiveAddress TEXT, 
    receiveTime TEXT, 
    trackingNumber TEXT, 
    freight DOUBLE, 
    status INTEGER, 
    piece INTEGER, 
    weight INTEGER, 
    estimatedPrice DOUBLE, 
    actualPrice DOUBLE, 
    toBePaid INTEGER, 
    isDelete INTEGER
  );''';

  Future<List<OrderEntity>> query() async {
    List<dynamic> list = await DBManager().query(tableName);
    return list.map((e) => OrderEntity.fromJson(e)).toList();
  }

  Future<int> insert(OrderEntity order) async {
    return await DBManager().insert(tableName, order.toJson());
  }

  Future<int> update(OrderEntity order) async {
    return await DBManager().update(tableName, order.toJson(), where: 'orderUid = ?', whereArgs: [order.orderUid]);
  }
}

/// 订单状态
enum OrderStatus {
  @JsonValue(0)
  create, // 订单已创建
  @JsonValue(1)
  waiting, // 等待接单
  @JsonValue(2)
  receivedOrder, // 已接单
  @JsonValue(3)
  shipped, // 已发货
  @JsonValue(4)
  receivedShip, // 已收货
  @JsonValue(5)
  finish, // 已完成
}

/// 支付方式
enum PayMethod {
  @JsonValue(0)
  toBePaid, // 待支付
  @JsonValue(1)
  paid, // 已支付
}
