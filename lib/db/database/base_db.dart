abstract class BaseDB {
  BaseDB();

  BaseDB.fromJson(Map<String, dynamic> json);

  // 将map类型数据转化为实体类
  BaseDB fromJson(Map<String, dynamic> json);

  // 将实体类转化为map类型数据
  Map<String, dynamic> toJson();
}
