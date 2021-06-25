import 'package:dio/dio.dart';
import 'package:flutter_ui/base/beans/data_bean.dart';
import 'package:retrofit/http.dart';

part 'api_services.g.dart';

@RestApi()
abstract class ApiServices {
  factory ApiServices(Dio dio, {String? baseUrl}) = _ApiServices;

  // 登录请求
  @POST('user/login')
  Future<DataBean> login(
    @Query('username') String username, // 用户名/手机号
    @Query('password') String password, // 密码
  );

  @POST('user/register')
  Future<DataBean> register(
    @Query('username') String username, // 用户名/手机号
    @Query('password') String password, // 密码
    @Query('repassword') String repassword, // 密码
  );

  @GET('user/logout/json')
  Future<DataBean> logout();

  @GET('article/list/{pageNumber}/json')
  Future<DataBean> article(
    @Path("pageNumber") String pageNumber,
  );

  @GET('banner/json')
  Future<DataBean> banner();
}
