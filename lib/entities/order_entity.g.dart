// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderEntity _$OrderEntityFromJson(Map<String, dynamic> json) => OrderEntity()
  ..orderUid = json['orderUid'] as String?
  ..sender = json['sender'] as String?
  ..sendPhone = json['sendPhone'] as String?
  ..sendAddress = json['sendAddress'] as String?
  ..sendTime = json['sendTime'] as String?
  ..receiver = json['receiver'] as String?
  ..receivePhone = json['receivePhone'] as String?
  ..receiveAddress = json['receiveAddress'] as String?
  ..receiveTime = json['receiveTime'] as String?
  ..payMethod = $enumDecode(_$PayMethodEnumMap, json['payMethod'])
  ..isDelete = json['isDelete'] as int;

Map<String, dynamic> _$OrderEntityToJson(OrderEntity instance) =>
    <String, dynamic>{
      'orderUid': instance.orderUid,
      'sender': instance.sender,
      'sendPhone': instance.sendPhone,
      'sendAddress': instance.sendAddress,
      'sendTime': instance.sendTime,
      'receiver': instance.receiver,
      'receivePhone': instance.receivePhone,
      'receiveAddress': instance.receiveAddress,
      'receiveTime': instance.receiveTime,
      'payMethod': _$PayMethodEnumMap[instance.payMethod]!,
      'isDelete': instance.isDelete,
    };

const _$PayMethodEnumMap = {
  PayMethod.toBePaid: 0,
  PayMethod.paid: 1,
};

ProductEntity _$ProductEntityFromJson(Map<String, dynamic> json) =>
    ProductEntity()
      ..productUid = json['productUid'] as String?
      ..orderUid = json['orderUid'] as String?
      ..status = $enumDecode(_$OrderStatusEnumMap, json['status'])
      ..trackingNumber = json['trackingNumber'] as String?
      ..freight = (json['freight'] as num).toDouble()
      ..piece = json['piece'] as int
      ..weight = json['weight'] as int
      ..estimatedPrice = (json['estimatedPrice'] as num).toDouble()
      ..actualPrice = (json['actualPrice'] as num).toDouble()
      ..isDelete = json['isDelete'] as int;

Map<String, dynamic> _$ProductEntityToJson(ProductEntity instance) =>
    <String, dynamic>{
      'productUid': instance.productUid,
      'orderUid': instance.orderUid,
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
  OrderStatus.waiting: 1,
  OrderStatus.receivedOrder: 2,
  OrderStatus.shipped: 3,
  OrderStatus.receivedShip: 4,
  OrderStatus.finish: 5,
};
