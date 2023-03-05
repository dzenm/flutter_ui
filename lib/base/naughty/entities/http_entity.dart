class HTTPEntity {
  Status status = Status.prepare;
  String duration = '0 ms';
  String time = '';
  String size = '0 B';

  // request
  String? method = 'Unknown';
  String? url = 'Unknown';
  String? baseUrl = 'Unknown';
  String? path = 'Unknown';

  Map<String, dynamic>? requestExtra;
  Map<String, dynamic>? requestQueryParameters;
  Map<String, dynamic>? requestHeader;
  dynamic requestBody;

  // response
  int? statusCode = -1;
  String? realUrl  = 'Unknown';
  String? responseType = 'Unknown';
  int? maxRedirects = 0;
  String? listFormat = 'Unknown';
  Duration? sendTimeout;
  Duration? connectTimeout;
  Duration? receiveTimeout;
  bool? followRedirects = true;
  bool? receiveDataWhenStatusError = true;
  bool? isRedirect = true;

  Map<String, dynamic>? responseExtra;
  Map<String, dynamic>? responseHeader;
  dynamic responseBody;

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
