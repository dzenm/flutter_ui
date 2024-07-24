class HTTPEntity {
  Status status = Status.prepare;
  String duration = '0 ms';
  String time = '';
  String size = '0 B';
  int index = 0;

  // request
  String? method = 'Unknown';
  String? url = 'Unknown';
  String? baseUrl = 'Unknown';
  String? path = 'Unknown';
  String? responseType = 'Unknown';
  int? maxRedirects = 0;
  String? listFormat = 'Unknown';
  Duration? sendTimeout;
  Duration? connectTimeout;
  Duration? receiveTimeout;
  bool? followRedirects = true;
  bool? receiveDataWhenStatusError = true;
  Map<String, dynamic>? requestQueryParameters;
  Map<String, dynamic>? requestHeader;
  Map<String, dynamic>? requestExtra;
  dynamic requestBody;

  // response
  int? statusCode = -1;
  String? realUrl = 'Unknown';
  bool? isRedirect = true;
  Map<String, dynamic>? responseHeader;
  Map<String, dynamic>? responseExtra;
  dynamic responseBody;

  Map<String, dynamic> request() {
    Map<String, dynamic> map = {
      "request time": time,
      "method": method,
      "url": url,
      "baseUrl": baseUrl,
      "path": path,
      "responseType": responseType,
      "maxRedirects": maxRedirects,
      "listFormat": listFormat,
      "sendTimeout": sendTimeout,
      "connectTimeout": connectTimeout,
      "receiveTimeout": receiveTimeout,
      "followRedirects": followRedirects,
      "receiveDataWhenStatusError": receiveDataWhenStatusError,
    };

    requestQueryParameters?.forEach((key, value) => map[key] = value);
    requestHeader?.forEach((key, value) => map[key] = value);
    requestExtra?.forEach((key, value) => map[key] = value);

    map['Body'] = requestBody;
    return map;
  }

  Map<String, dynamic> response() {
    Map<String, dynamic> map = {
      "statusCode": statusCode,
      "url": realUrl,
      "duration": duration,
      "content-length": size,
      "isRedirect": isRedirect,
    };
    responseHeader?.forEach((key, value) => map[key] = value);
    responseExtra?.forEach((key, value) => map[key] = value);

    map['Body'] = responseBody;
    return map;
  }
}

enum Status {
  prepare(0),
  running(1),
  success(2),
  failed(3);

  final int status;

  const Status(this.status);
}
