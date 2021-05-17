import 'package:dio/dio.dart';
import 'package:flutter_ui/models/user.dart';
import 'package:retrofit/http.dart';

part 'api_services.g.dart';

const String baseUrl = "https://www.wanandroid.com";

// baseUrl必须使用 "", 不能使用 ''
@RestApi(baseUrl: baseUrl)
abstract class ApiServices {
  factory ApiServices(Dio dio, {String? baseUrl}) = _ApiServices;

  @POST('user/login')
  Future<User> login(String username, String password);

  @POST('user/register')
  Future<User> register(String username, String password, String repassword);

  @GET('user/logout/json')
  Future<User> logout(String username, String password);


}
