# flutter_ui

A new Flutter application.

## Getting Started


## 使用

* 1.执行命令，拉取相关的依赖
> flutter pub get

* 2.生成相关的文件
> flutter pub run build_runner build --delete-conflicting-outputs


## 项目结构

```
├── main.dart                                   // flutter程序main函数入口
├── application.dart                            // 初始化/全局配置信息，见base说明
├── app_page.dart                               // 最顶层页面，和页面相关的全局配置信息
├── base                                        // 封装的基本组件，以下内容不相互调用
│   ├── db                                      // 封装的数据库工具
│   ├── http                                    // 封装的HTTP请求工具
│   ├── log                                     // 封装的日志打印和错误信息收集工具
│   ├── naughty                                 // 封装的Debug信息在手机可以查看的工具
│   ├── res                                     // 封装的国际化工具(包含语言/主题)
│   ├── route                                   // 封装的路由工具(未完善)
│   ├── utils                                   // 封装的工具类
│   └── widgets                                 // 封装的组件库
├── entities                                    // 实体类，数据库
├── generated                                   // 国际化语言包生成的代码
├── http                                        // retrofit接口信息，http拦截器，cookie缓存等和http相关的
├── l10n                                        // 国际化语言包(使用flutter_intl自动生成S文件)
├── models                                      // 数据库表对应的provider model，数据表单独放在这里
└── pages                                       // 页面
    ├── common                                  // 公共页面
    ├── login                                   // 登录页面(包含注册，登录，Splash，轮播图等)
    ├── main                                    // 主页面
    │   ├── home_page                           // 主页面的bottomBar显示的第一个页面
    │   ├── me_page                             // 主页面的bottomBar显示的第三个页面
    │   │   ├── article
    │   │   ├── coin
    │   │   ├── collect 
    │   │   ├── info
    │   │   ├── medicine
    │   │   ├── rank
    │   │   └── setting_page
    │   └── nav_page                            // 主页面的bottomBar显示的第二个页面
    ├── my                                      // 这是我的学习dart基础的测试页面(在AppPage控制进入)
    ├── study                                   // 这个是封装的一些功能的测试页面
    │   ├── city_page
    │   ├── convert_page
    │   ├── drag_list_page
    │   ├── float_navigation_page
    │   ├── http_page
    │   ├── image_editor
    │   ├── keyword_board
    │   ├── list_page
    │   ├── load_image_page
    │   ├── provider_page
    │   ├── qr_page
    │   ├── router
    │   ├── state_page
    │   ├── text_page
    │   └── video_page
    └── utils                                   // 页面相关的工具类
```

* base文件夹里的可以选择性复制，封装的时候尽量让它们不相互依赖。
* 程序入口主要在application，类似于Android原生，初始化第三方依赖配置，app_page是页面相关的初始化，比如model、国际化、主题、路由

## 必要的依赖

```
  ########################################## BASE ########################################
  flutter_localizations:
    sdk: flutter
  flutter_web_plugins:                          # 让 Flutter 使用 path 策略
    sdk: flutter
  # The following adds the Cupertino Icons font to your application.
  # Use with the CupertinoIcons class for iOS style icons.
  cupertino_icons: 1.0.5                        # 图片 https://pub.flutter-io.cn/packages/cupertino_icons
  sqflite_common_ffi: 2.3.0                     # sql https://pub.dev/packages/sqflite_common_ffi
  path_provider: 2.0.15                         # 路径选择 https://pub.dev/packages/path_provider
  shared_preferences: 2.2.0                     # 本地化存储 https://pub.dev/packages/shared_preferences
  bot_toast: 4.0.4                              # Toast https://pub.flutter-io.cn/packages/bot_toast
  retrofit: 4.0.1                               # HTTP请求 https://pub.flutter-io.cn/packages/retrofit
#  dio_cookie_manager: 2.0.0                     # cookie管理 https://pub.flutter-io.cn/packages/dio_cookie_manager
#  cookie_jar: 3.0.1                             # cookie持久化 https://pub.flutter-io.cn/packages/cookie_jar
  package_info_plus: 4.1.0                      # 获取版本信息 https://pub.dev/packages/package_info_plus
  device_info_plus: 9.0.3                       # 获取设备信息 https://pub.flutter-io.cn/packages/device_info_plus
  flutter_local_notifications: 15.1.0+1         # 通知栏通知提醒 https://pub.flutter-io.cn/packages/flutter_local_notifications
  cached_network_image: 3.2.3                   # 图片缓存 https://pub.flutter-io.cn/packages/cached_network_image
  extended_text_field: 12.0.1                   # 输入框扩展 https://pub.flutter-io.cn/packages/extended_text_field
  back_button_interceptor: 6.0.2                # 返回按钮拦截 https://pub.flutter-io.cn/packages/back_button_interceptor
  provider: 6.0.5                               # 状态管理 https://pub.dev/packages/provider
  json_annotation: 4.8.1                        # Json序列化 https://pub.dev/packages/json_annotation
```



## 程序运行流程

* 文件

```
main.dart ---> application.dart ---> app_page.dart ---> login_page.dart/main_page.dart
```

* 函数

```
void main() ---> Application().main() ---> Application()._initApp() ---> LoginPage()/MainPage()
```

## 联系我

#### 微信：zreolop