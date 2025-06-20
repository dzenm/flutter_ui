import 'db_manager.dart';

/// 数据的基类，数据和实体类的转换，数据库表的信息
abstract class DBBaseEntity {

  /// 将实体类转化为map类型数据
  Map<String, dynamic> toJson();

  /// 创建表sql语句
  String get createTableSql => '';

  /// 表名，获取运行时的当前文件名称，转成小写字母，并将entity后缀删除
  String get tableName {
    String className = runtimeType.toString().replaceAll('Entity', '');
    StringBuffer sb = StringBuffer();
    for (int i = 0; i < className.length; i++) {
      String s = className[i];
      if (s == s.toUpperCase()) sb.write('_');
      sb.write(s.toLowerCase());
    }
    return 't${sb.toString()}';
  }

  Future<String?> getRecentDate({String attr = 'updateDate'}) async {
    List<Map<String, dynamic>> list = await DBManager().query(
      tableName,
      where: 'isDelete = ?',
      whereArgs: [0],
      orderBy: '$attr DESC',
      limit: 1,
    );
    if (list.isNotEmpty) {
      return list.first[attr];
    }
    return null;
  }

  Future<int> clear() async {
    String sql = 'DELETE FROM $tableName';
    return await DBManager().rawDelete(sql, null);
  }
}
