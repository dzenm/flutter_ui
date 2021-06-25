class DataBean<T> {
  int? errorCode;
  String? errorMsg;
  T? data;

  DataBean({this.errorCode = 200, this.errorMsg, this.data});

  DataBean.fromJson(Map<String, dynamic> json) {
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
