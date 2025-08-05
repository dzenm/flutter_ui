///
/// Created by a0010 on 2022/3/22 09:38
/// HTTP返回时最外层数据对应的实体类
class DataEntity<T> {
  bool get isSuccessful => errorCode == 0 || errorCode == 200; // 请求成功
  bool get isUnsuccessful => errorCode != 200; // 请求未成功
  bool get isNotLoggedIn => errorCode == 403; // 未登录
  bool get isError => errorCode == 500; // 请求失败
  int? errorCode;
  String? errorMsg;
  T? data;

  DataEntity({this.errorCode = 200, this.errorMsg, this.data});

  DataEntity.fromJson(Map<String, dynamic> json) {
    errorCode = json['errorCode'] ?? json['code'] ?? json['status'];
    errorMsg = json['errorMsg'] ?? json['message'] ?? json['msg'];
    data = json['data'];
  }

  Map<String, dynamic> toJson() => {
    'errorCode': errorCode,
    'errorMsg': errorMsg,
    'data': data,
  };
}
