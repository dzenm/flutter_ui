class HttpBean {
  Status status = Status.prepare;
  String duration = '0 ms';
  String time = '';
  String size = '0 B';

  // request
  String? method;
  String? url;
  String? baseUrl;
  String? path;

  Map<String, dynamic>? requestExtra;
  Map<String, dynamic>? requestQueryParameters;
  Map<String, dynamic>? requestHeader;
  Map<String, dynamic>? requestBody;

  // response
  int? statusCode;
  String? realUrl;
  String? responseType;
  int? maxRedirects;
  String? listFormat;
  int? sendTimeout;
  int? connectTimeout;
  int? receiveTimeout;
  bool? followRedirects;
  bool? receiveDataWhenStatusError;
  bool? isRedirect;

  Map<String, dynamic>? responseExtra;
  Map<String, dynamic>? responseHeader;
  Map<String, dynamic>? responseBody;

  Map<String, dynamic> request() {
    Map<String, dynamic> map = {
      "method": method,
      "baseUrl": baseUrl,
      "path": path,
    };

    requestHeader?.forEach((key, value) => map[key] = value);
    requestExtra?.forEach((key, value) => map[key] = value);

    map['Body'] = requestBody;
    return map;
  }

  Map<String, dynamic> response() {
    Map<String, dynamic> map = {
      "statusCode": statusCode,
      "responseType": responseType,
      "url": realUrl,
      "duration": duration,
      "content-length": size,
      "maxRedirects": maxRedirects,
      "listFormat": listFormat,
      "sendTimeout": sendTimeout,
      "connectTimeout": connectTimeout,
      "receiveTimeout": receiveTimeout,
      "followRedirects": followRedirects,
      "isRedirect": isRedirect,
    };
    responseHeader?.forEach((key, value) => map[key] = value);
    responseExtra?.forEach((key, value) => map[key] = value);

    map['Body'] = responseBody;
    return map;
  }
}

enum Status { prepare, running, success, failed }
