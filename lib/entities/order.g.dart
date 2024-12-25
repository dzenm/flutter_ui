// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderEntity _$OrderEntityFromJson(Map<String, dynamic> json) => OrderEntity()
  ..orderUid = json['orderUid'] as String?
  ..productUid = json['productUid'] as String?
  ..addressUid = json['addressUid'] as String?
  ..status = $enumDecode(_$OrderStatusEnumMap, json['status'])
  ..trackingNumber = json['trackingNumber'] as String?
  ..freight = (json['freight'] as num).toDouble()
  ..piece = (json['piece'] as num).toInt()
  ..weight = (json['weight'] as num).toDouble()
  ..estimatedPrice = (json['estimatedPrice'] as num).toDouble()
  ..actualPrice = (json['actualPrice'] as num).toDouble()
  ..isDelete = (json['isDelete'] as num).toInt();

Map<String, dynamic> _$OrderEntityToJson(OrderEntity instance) =>
    <String, dynamic>{
      'orderUid': instance.orderUid,
      'productUid': instance.productUid,
      'addressUid': instance.addressUid,
      'status': _$OrderStatusEnumMap[instance.status]!,
      'trackingNumber': instance.trackingNumber,
      'freight': instance.freight,
      'piece': instance.piece,
      'weight': instance.weight,
      'estimatedPrice': instance.estimatedPrice,
      'actualPrice': instance.actualPrice,
      'isDelete': instance.isDelete,
    };

const _$OrderStatusEnumMap = {
  OrderStatus.create: 0,
  OrderStatus.paid: 1,
  OrderStatus.waiting: 2,
  OrderStatus.receivedOrder: 3,
  OrderStatus.shipped: 5,
  OrderStatus.receivedShip: 6,
  OrderStatus.finish: 7,
};

AddressEntity _$AddressEntityFromJson(Map<String, dynamic> json) =>
    AddressEntity()
      ..id = json['id'] as String?
      ..belongsUid = json['belongsUid'] as String?
      ..name = json['name'] as String?
      ..phone = json['phone'] as String?
      ..province = json['province'] as String?
      ..city = json['city'] as String?
      ..county = json['county'] as String?
      ..address = json['address'] as String?
      ..tag = json['tag'] as String?;

Map<String, dynamic> _$AddressEntityToJson(AddressEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'belongsUid': instance.belongsUid,
      'name': instance.name,
      'phone': instance.phone,
      'province': instance.province,
      'city': instance.city,
      'county': instance.county,
      'address': instance.address,
      'tag': instance.tag,
    };
