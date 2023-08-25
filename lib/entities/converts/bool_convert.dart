import 'package:json_annotation/json_annotation.dart';

///
/// Created by a0010 on 2023/8/17 13:45
///
class BoolConvert implements JsonConverter<bool?, dynamic> {
  const BoolConvert();
  @override
  bool? fromJson(dynamic json) {
    if (json is bool) return json;
    if (json is int) return json == 1;
    return false;
  }

  @override
  dynamic toJson(bool? object) {
    return (object ?? false) ? 1 : 0;
  }
}
