// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_services.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

class _ApiServices implements ApiServices {
  _ApiServices(this._dio, {this.baseUrl});

  final Dio _dio;

  String? baseUrl;

  @override
  Future<DataEntity<dynamic>> login(username, password) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'username': username,
      r'password': password
    };
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<DataEntity<dynamic>>(
            Options(method: 'POST', headers: <String, dynamic>{}, extra: _extra)
                .compose(_dio.options, 'user/login',
                    queryParameters: queryParameters, data: _data)
                .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = DataEntity<dynamic>.fromJson(_result.data!);
    return value;
  }

  @override
  Future<DataEntity<dynamic>> register(username, password, repassword) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'username': username,
      r'password': password,
      r'repassword': repassword
    };
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<DataEntity<dynamic>>(
            Options(method: 'POST', headers: <String, dynamic>{}, extra: _extra)
                .compose(_dio.options, 'user/register',
                    queryParameters: queryParameters, data: _data)
                .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = DataEntity<dynamic>.fromJson(_result.data!);
    return value;
  }

  @override
  Future<DataEntity<dynamic>> logout() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<DataEntity<dynamic>>(
            Options(method: 'GET', headers: <String, dynamic>{}, extra: _extra)
                .compose(_dio.options, 'user/logout/json',
                    queryParameters: queryParameters, data: _data)
                .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = DataEntity<dynamic>.fromJson(_result.data!);
    return value;
  }

  @override
  Future<DataEntity<dynamic>> article(pageNumber) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<DataEntity<dynamic>>(
            Options(method: 'GET', headers: <String, dynamic>{}, extra: _extra)
                .compose(_dio.options, 'article/list/$pageNumber/json',
                    queryParameters: queryParameters, data: _data)
                .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = DataEntity<dynamic>.fromJson(_result.data!);
    return value;
  }

  @override
  Future<DataEntity<dynamic>> banner() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<DataEntity<dynamic>>(
            Options(method: 'GET', headers: <String, dynamic>{}, extra: _extra)
                .compose(_dio.options, 'banner/json',
                    queryParameters: queryParameters, data: _data)
                .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = DataEntity<dynamic>.fromJson(_result.data!);
    return value;
  }

  RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }
    return requestOptions;
  }
}
