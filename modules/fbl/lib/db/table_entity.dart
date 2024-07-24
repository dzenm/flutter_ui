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
  String? tblName;
  int? rootPage;
  String? sql;

  TableEntity.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    name = json['name'];
    tblName = json['tbl_name'];
    rootPage = json['rootpage'];
    sql = json['sql'];
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'name': name,
        'tbl_name': tblName,
        'rootpage': rootPage,
        'sql': sql,
      };
}
