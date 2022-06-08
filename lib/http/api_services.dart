import 'package:dio/dio.dart';
import 'package:flutter_ui/base/entities/data_entity.dart';
import 'package:retrofit/http.dart';

part 'api_services.g.dart';

@RestApi()
abstract class ApiServices {
  factory ApiServices(Dio dio, {String? baseUrl}) = _ApiServices;

  // 登录请求
  @POST('user/login')
  Future<DataEntity> login(
    @Query('username') String username, // 用户名/手机号
    @Query('password') String password, // 密码
  );

  @POST('user/register')
  Future<DataEntity> register(
    @Query('username') String username, // 用户名/手机号
    @Query('password') String password, // 密码
    @Query('repassword') String repassword, // 密码
  );

  @GET('user/logout/json')
  Future<DataEntity> logout();

  @GET('article/list/{pageNumber}/json')
  Future<DataEntity> article(
    @Path("pageNumber") String pageNumber,
  );

  @GET('banner/json')
  Future<DataEntity> banner();

  @GET('zhongyao/index')
  Future<DataEntity> getZhongYao(@Query('key') String key, @Query('word') String word, );
}
