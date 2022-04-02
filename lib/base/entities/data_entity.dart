///
/// Created by a0010 on 2022/3/22 09:38
/// HTTP返回时最外层数据对应的实体类
///
class DataEntity<T> {
  int? errorCode;
  String? errorMsg;
  T? data;

  DataEntity({this.errorCode = 200, this.errorMsg, this.data});

  DataEntity.fromJson(Map<String, dynamic> json) {
    errorCode = json['errorCode'];
    errorMsg = json['errorMsg'];
    data = json['data'];
  }

  Map<String, dynamic> toJson() => {
        'errorCode': errorCode,
        'errorMsg': errorMsg,
        'data': data,
      };
}
