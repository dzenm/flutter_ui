class HttpBean {
  Status? status;
  String? duration;
  String? time;
  String? size;

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
      "Request Method": method,
      "Request Url": baseUrl,
      "Request Path": path,
    };

    requestHeader?.forEach((key, value) => map[key] = value);
    requestExtra?.forEach((key, value) => map[key] = value);

    map['Body'] = requestBody;
    return map;
  }

  Map<String, dynamic> response() {
    Map<String, dynamic> map = {
      "Status Code": statusCode,
      "Response Type": responseType,
      "Response Url": realUrl,
      "Response Duration": duration,
      "Content-Length": size,
      "Max Redirects": maxRedirects,
      "List Format": listFormat,
      "Send Timeout": sendTimeout,
      "Connect Timeout": connectTimeout,
      "Receive Timeout": receiveTimeout,
      "Follow Redirects": followRedirects,
      "Is Redirect": isRedirect,
    };
    responseHeader?.forEach((key, value) => map[key] = value);
    responseExtra?.forEach((key, value) => map[key] = value);

    map['Body'] = responseBody;
    return map;
  }
}

enum Status { prepare, running, success, failed }
