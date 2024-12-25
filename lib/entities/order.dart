import 'package:fbl/fbl.dart';
import 'package:json_annotation/json_annotation.dart';

part 'order.g.dart';

///
/// Created by a0010 on 2023/2/23 14:26
/// 订单表
@JsonSerializable()
class OrderEntity extends DBBaseEntity {
  String? orderUid; // 订单编号
  String? productUid; // 商品编号
  String? addressUid; // 收获地址编号
  OrderStatus status = OrderStatus.create; // 订单状态
  String? trackingNumber; // 快递单号
  double freight = 0.0; // 运费
  int piece = 0; // 件数
  double weight = 0.0; // 重量(kg)
  double estimatedPrice = 0.0; // 预估价格
  double actualPrice = 0.0; // 实际卖出的价格
  int isDelete = 0; // 是否删除

  OrderEntity();

  factory OrderEntity.fromJson(Map<String, dynamic> json) => _$OrderEntityFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$OrderEntityToJson(this);

  @override
  String get createTableSql => '''$tableName(
    orderUid TEXT PRIMARY KEY NOT NULL COMMENT "主键，订单编号", 
    productUid TEXT NOT NULL COMMENT "商品编号", 
    addressUid TEXT NOT NULL COMMENT "收获地址编号", 
    status INTEGER DEFAULT 0 COMMENT "订单状态", 
    trackingNumber TEXT COMMENT "快递单号", 
    freight DOUBLE COMMENT "运费", 
    piece INTEGER DEFAULT 1 COMMENT "件数", 
    weight INTEGER COMMENT "重量(kg)", 
    estimatedPrice DOUBLE COMMENT "预估价格", 
    actualPrice DOUBLE COMMENT "实际卖出的价格", 
    isDelete INTEGER DEFAULT 0 COMMENT "是否删除"
  );''';

  Future<List<OrderEntity>> query() async {
    List<dynamic> list = await DBManager().query(tableName);
    return list.map((e) => OrderEntity.fromJson(e)).toList();
  }

  Future<List<OrderEntity>> queryProductByOrder(String orderUid) async {
    List<dynamic> list = await DBManager().query(
      tableName,
      where: 'orderUid = ?',
      whereArgs: [orderUid],
    );
    return list.map((e) => OrderEntity.fromJson(e)).toList();
  }

  Future<int> insert(OrderEntity order) async {
    return await DBManager().insert(tableName, order.toJson());
  }

  Future<int> update(OrderEntity order) async {
    return await DBManager().update(
      tableName,
      order.toJson(),
      where: 'orderUid = ?',
      whereArgs: [order.orderUid],
    );
  }
}

/// 订单状态
enum OrderStatus {
  @JsonValue(0)
  create, // 订单已创建
  @JsonValue(1)
  paid, // 订单已付款
  @JsonValue(2)
  waiting, // 等待接单
  @JsonValue(3)
  receivedOrder, // 已接单
  @JsonValue(5)
  shipped, // 已发货
  @JsonValue(6)
  receivedShip, // 已收货
  @JsonValue(7)
  finish, // 已完成
}

/// 地址表
@JsonSerializable()
class AddressEntity extends DBBaseEntity {
  String? id;
  String? belongsUid;
  String? name;
  String? phone;
  String? province;
  String? city;
  String? county;
  String? address;
  String? tag;

  AddressEntity();

  factory AddressEntity.fromJson(Map<String, dynamic> json) => _$AddressEntityFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AddressEntityToJson(this);

  @override
  String get createTableSql => '''$tableName(
    id int PRIMARY KEY AUTO_INCREMENT COMMENT "主键", 
    belongsUid TEXT NOT NULL COMMENT "所属用户的ID", 
    name TEXT NOT NULL COMMENT "用户名", 
    phone TEXT NOT NULL COMMENT "手机号", 
    province TEXT NOT NULL COMMENT "省份", 
    city TEXT NOT NULL COMMENT "城市", 
    county TEXT NOT NULL COMMENT "县/区", 
    address TEXT NOT NULL COMMENT "地址", 
    tag TEXT NOT NULL COMMENT "地址所属标签"
  );''';

  Future<List<AddressEntity>> query() async {
    List<dynamic> list = await DBManager().query(tableName);
    return list.map((e) => AddressEntity.fromJson(e)).toList();
  }

  Future<int> insert(AddressEntity address) async {
    return await DBManager().insert(tableName, address.toJson());
  }

  Future<int> update(AddressEntity address) async {
    return await DBManager().update(
      tableName,
      address.toJson(),
      where: 'belongsUid = ?',
      whereArgs: [address.belongsUid],
    );
  }
}
