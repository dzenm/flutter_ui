import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

///
/// Created by a0010 on 2023/8/17 14:02
///
class ListConvert implements JsonConverter<List<dynamic>, dynamic> {
  const ListConvert();

  @override
  List<dynamic> fromJson(dynamic json) {
    if (json is List) return json;
    if (json is String) return jsonDecode(json) as List<dynamic>;
    return [];
  }

  @override
  dynamic toJson(List<dynamic> object) {
    try {
      return jsonEncode(object.map((e) => e.toJson()).toList());
    } catch (e) {
      return jsonEncode(object);
    }
  }
}
