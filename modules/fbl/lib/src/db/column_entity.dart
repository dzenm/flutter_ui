/// 数据库表列名
/// {
///   cid: 0,
///   name: id,
///   type: INTEGER,
///   notnull: 1,
///   dflt_value: null,
///   pk: 1
/// },
class ColumnEntity {
  int? cid;
  String? name;
  String? type;
  int? notnull;
  String? dFltValue;
  int? pk;

  ColumnEntity.fromJson(Map<String, dynamic> json) {
    cid = json['cid'];
    name = json['name'];
    type = json['type'];
    notnull = json['notnull'];
    dFltValue = json['dflt_value'];
    pk = json['pk'];
  }

  Map<String, dynamic> toJson() => {
        'cid': cid,
        'name': name,
        'type': type,
        'notnull': notnull,
        'dflt_value': dFltValue,
        'pk': pk,
      };
}
