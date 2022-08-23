/// 查询表结构
/// {
///   type: table,
///   name: android_metadata,
///   tbl_name: android_metadata,
///   rootpage: 3,
///   sql: CREATE TABLE android_metadata (locale TEXT)
/// }
class TableEntity {
  String? type;
  String? name;
  String? tbl_name;
  int? rootpage;
  String? sql;

  TableEntity.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    name = json['name'];
    tbl_name = json['tbl_name'];
    rootpage = json['rootpage'];
    sql = json['sql'];
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'name': name,
        'tbl_name': tbl_name,
        'rootpage': rootpage,
        'sql': sql,
      };
}
