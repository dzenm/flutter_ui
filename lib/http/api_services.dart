import 'package:dio/dio.dart';
import 'package:flutter_ui/base/models/data_bean.dart';
import 'package:retrofit/http.dart';

part 'api_services.g.dart';

@RestApi()
abstract class ApiServices {
  factory ApiServices(Dio dio, {String? baseUrl}) = _ApiServices;

  @POST('user/login')
  Future<DataBean> login(String username, String password);

  @POST('user/register')
  Future<DataBean> register(String username, String password, String repassword);

  @GET('user/logout/json')
  Future<DataBean> logout(String username, String password);

  @GET('article/list/{pageNumber}/json')
  Future<DataBean> article(@Path("pageNumber") String pageNumber);
}
