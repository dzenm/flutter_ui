# [flutter_ui](https://github.com/dzenm/flutter_ui)

A new Flutter application.

# 使用

  * #### 1.执行命令，拉取相关的依赖

    > flutter pub get

  * #### 2.生成相关的文件
  
    > dart run build_runner build --delete-conflicting-outputs
  
    * #### 国际化

      l10n` 文件夹是国际化语言的文本文件，`generated` 文件夹是根据语言生成的调用文件（需安装IDEA插件 `flutter intl` ）

    * #### 实体类

      实体类生成.g文件使用IDEA插件 `FlutterJsonBeanFactory` ，创建实体类格式
        ```
        import 'package:json_annotation/json_annotation.dart';
        import '../base/db/db.dart';
        part 'tool_entity.g.dart';
        /// Created by a0010 on 2023/8/9 16:27
        /// 工具实体类
        @JsonSerializable()
        class ToolEntity extends DBBaseEntity {
          int? id;
          String? name;
          ToolEntity() : super();
          factory ToolEntity.fromJson(Map<String, dynamic> json) => _$ToolEntityFromJson(json);
          @override
          Map<String, dynamic> toJson() => _$ToolEntityToJson(this);
        }
        ```

  * #### 3.运行

    > // debug模式
    >
    > flutter run --debug
    >
    > // release模式
    >
    > flutter run --release
    >
    > // profile模式
    >
    > flutter run --profile

# 一、Windows

## 打包：

* ### 打包zip压缩文件

  #### 1. 通过命令行 `flutter build windows` 生成文件（ 生成的打包文件位于 `build/windows/x64/runner/Release/` ）

  #### 2. 将 `documents/windows_dll/` 文件夹里的所有文件复制到上一步生成的 `Release` 文件夹中 （如果还使用了其它第三方依赖需要添加dll文件，都复制到 `Release` 文件夹）

  #### 3. 压缩 `Release` 文件夹生成zip

* ### 打包exe安装包：

  #### 1. 通过命令行 `flutter build windows` 生成文件

  #### 2. 参考 [flutter开发windows桌面软件，使用Inno Setup打包成安装程序，支持中文](https://blog.csdn.net/weixin_44786530/article/details/135643352) 填写好信息即可打包生成exe可安装文件

# 二、MacOS

# 三、Linux

* #### `hotkey_manager` 依赖 `keybinder-3.0`，运行以下命令

  > sudo apt-get install keybinder-3.0

# 四、Android

## 打包：

* #### 通过命令行打包

  > flutter build apk --target-platform android-arm,android-arm64,android-x64 --split-per-abi --no-sound-null-safety

# 五、iOS

# 六、Web

# 项目结构

  ```
  ├── main.dart                                   // flutter程序main函数入口
  ├── application.dart                            // 初始化/全局配置信息，见base说明
  ├── app_page.dart                               // 最顶层页面，和页面相关的全局配置信息
  ├── base                                        // 封装的基本组件，以下内容不相互调用
  │   ├── config                                  // 封装的日志打印和错误信息收集工具(不依赖config以外文件，可直接复制文件夹)
  │   ├── db                                      // 封装的数据库工具(不依赖db以外文件，可直接复制文件夹)
  │   ├── http                                    // 封装的HTTP请求工具(不依赖http以外文件，可直接复制文件夹)
  │   ├── naughty                                 // 封装的Debug信息在手机可以查看的工具(依赖base下的db、widgets、utils)
  │   ├── resource                                // 封装的国际化工具(包含语言/主题)(依赖base下的utils)
  │   ├── router                                  // 封装的路由工具(不依赖router以外文件，可直接复制文件夹)
  │   ├── utils                                   // 封装的工具类(未处理好)
  │   └── widgets                                 // 封装的组件库(常用的UI组件)
  ├── config                                      // 项目的配置信息(第三方API URL)
  ├── entities                                    // 数据库实体类(数据库表和实体类合并，依赖db文件)
  ├── generated                                   // 国际化语言包生成的代码(生成的代码)
  ├── http                                        // retrofit接口信息，http拦截器，cookie缓存等和http相关的(Retrofit Restful API)
  ├── l10n                                        // 国际化语言包(使用flutter_intl自动生成S文件)
  ├── models                                      // 数据库表对应的provider model，数据表单独放在这里(只处理数据库相关的数据，页面相关的跟Page放在一起)
  └── pages                                       // 页面(按页面结构的模块区分)
      ├── common                                  // 公共页面
      ├── login                                   // 登录页面(包含注册，登录，Splash，轮播图等)
      ├── main                                    // 主页面
      │   ├── home_page                           // 主页面的bottomBar显示的第一个页面
      │   ├── me_page                             // 主页面的bottomBar显示的第三个页面
      │   │   ├── article                         // 文章页面
      │   │   ├── coin                            // 积分页面
      │   │   ├── collect                         // 收藏页面
      │   │   ├── info                            // 个人信息页面
      │   │   ├── medicine                        // 中药数据页面
      │   │   ├── rank                            // 积分排行榜页面
      │   │   └── setting_page                    // 设置页面
      │   ├── nav_page                            // 主页面的bottomBar显示的第二个页面
      │   ├── main_model.dart                     // 主页对应的model
      │   ├── main_page.dart                      // 主页面(全平台，处理跟平台无关的主页数据)
      │   ├── main_page_desktop.dart              // 主页面(桌面端)
      │   ├── main_page_web.dart                  // 主页面(移动端)
      │   └── system_tray.dart                    // 桌面端的托盘管理
      ├── my                                      // 这是我的学习dart基础的测试页面(在AppPage控制进入)
      └── study                                   // 这个是封装的一些功能的测试页面(在MePage控制进入)
          ├── chat_page
          ├── city_page
          ├── convert_page
          ├── dialog_page
          ├── drag_list_page
          ├── float_navigation_page
          ├── http_page
          ├── image_editor
          ├── keyword_board
          ├── list_page
          ├── load_image_page
          ├── popup_page
          ├── provider_page
          ├── qr_page
          ├── router_page
          ├── slider_page
          ├── state_page
          ├── text_page
          ├── window_page
          └── video_page
  ```

  * ### 1. 程序入口main，
  * ### 2. 从main进入application，类似于Android原生的Application，主要用于初始化第三方依赖配置
  * ### 3. 从application进入app_page，是页面相关的初始化，比如model、国际化、主题、路由等
  * ### 4. 然后是进入pages文件夹的页面

## 联系我

  #### 微信：zreolop
