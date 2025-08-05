import 'dart:io';

import 'package:fbl/fbl.dart';
import 'package:get_ip_address/get_ip_address.dart';
import 'package:path_provider/path_provider.dart';

///
/// Created by a0010 on 2023/11/29 16:27
///
class StudyMain {
  static const String _tag = 'StudyMain';

  static void main() async {
    await _pathProviderTest();
    _implementsTest();
    _getIP();
  }

  static Future<void> _pathProviderTest() async {
    // Android：/data/user/0/com.dzenm.flutter_ui/cache
    // iOS：/var/mobile/Containers/Data/Application/3A0617A0-0774-401A-98E8-4713AF0CDCB6/Library/Caches
    // macOS：/Users/a0010/Library/Containers/com.dzenm.flutterUi/Data/Library/Caches
    Directory? temp = await getTemporaryDirectory();
    _log('获取文件路径：temp=${temp.path}');

    // Android：/data/user/0/com.dzenm.flutter_ui/files
    // iOS：/var/mobile/Containers/Data/Application/3A0617A0-0774-401A-98E8-4713AF0CDCB6/Library/Application Support
    // macOS：/Users/a0010/Library/Containers/com.dzenm.flutterUi/Data/Library/Application Support/com.dzenm.flutterUi
    Directory? support = await getApplicationSupportDirectory();
    _log('获取文件路径：support=${support.path}');

    // Android：/data/user/0/com.dzenm.flutter_ui/app_flutter
    // iOS：/var/mobile/Containers/Data/Application/3A0617A0-0774-401A-98E8-4713AF0CDCB6/Documents
    // macOS：/Users/a0010/Library/Containers/com.dzenm.flutterUi/Data/Documents
    Directory? document = await getApplicationDocumentsDirectory();
    _log('获取文件路径：document=${document.path}');

    // Android：/data/user/0/com.dzenm.flutter_ui/cache
    // iOS：/var/mobile/Containers/Data/Application/3A0617A0-0774-401A-98E8-4713AF0CDCB6/Library/Caches
    // macOS：/Users/a0010/Library/Containers/com.dzenm.flutterUi/Data/Library/Caches/com.dzenm.flutterUi
    Directory? cache = await getApplicationCacheDirectory();
    _log('获取文件路径：cache=${cache.path}');

    if (BuildConfig.isAndroid) {
      // Android：/storage/emulated/0/Android/data/com.dzenm.flutter_ui/files
      Directory? externalStorage = await getExternalStorageDirectory();
      _log('获取文件路径：externalStorage=${externalStorage?.path}');

      // Android：/storage/emulated/0/Android/data/com.dzenm.flutter_ui
      List<Directory>? externalCaches = await getExternalCacheDirectories();
      _log('获取文件路径：externalCaches=${externalCaches?.firstOrNull?.parent}');

      // Android：/storage/emulated/0/Android/data/com.dzenm.flutter_ui
      List<Directory>? externalStorages = await getExternalStorageDirectories();
      _log('获取文件路径：externalStorages=${externalStorages?.firstOrNull?.parent}');
    }

    if (BuildConfig.isIOS || BuildConfig.isMacOS) {
      // iOS：/var/mobile/Containers/Data/Application/3A0617A0-0774-401A-98E8-4713AF0CDCB6/Library
      // macOS：/Users/a0010/Library/Containers/com.dzenm.flutterUi/Data/Library
      Directory? library = await getLibraryDirectory();
      _log('获取文件路径：library=${library.path}');
    }
  }

  static void _implementsTest() {
    Friend friend = BusinessFriend();
    _log('测试：friend is GoodFriend=${friend is GoodFriend}');
    _log('测试：friend is BusinessFriend=${friend is BusinessFriend}');
    _log('测试：friend is Child=${friend is Child}');
    _log('测试：friend is NameMixin=${friend is NameMixin}');
    _log('测试：friend is Good=${friend is Good}');
    _log('测试：friend is Business=${friend is Business}');
    _log('测试：friend=${friend.toJson()}');

    Map<String, dynamic> json = {
      'userUid': '7i21g1n1j23u1g1',
      'userName': '玉皇大帝',
    };
    Data user = User.fromJson(json);
    user.userUid = '17601487212';
    if (user is User) {
      user.userName = 'dingzhenyan';
    }
    _log('测试：user=${user.toJson()}');

    Map<String, dynamic> map = {
      'name': '清华大学'
    };
    School school = School.fromJson(map);
    _log('测试：school=${school.toJson()}');

  }

  static void _getIP() async {
    try {
      /// Initialize Ip Address
      var ipAddress = IpAddress(type: RequestType.json);

      /// Get the IpAddress based on requestType.
      dynamic data = await ipAddress.getIpAddress();
      _log(data.toString());
    } on IpAddressException catch (exception) {
      /// Handle the exception.
      _log(exception.message);
    }

    Uri uri = Uri.parse('https://dart.dev/guides/libraries/library-tour#utility-classes');
    _log(uri.toString());
  }

  static void _log(String msg) {
    Log.d(msg, tag: _tag);
  }
}

abstract interface class Child {}

abstract interface class Student {}

abstract interface class Business {}

abstract interface class Good {}

abstract class People implements Student {}

abstract class Friend extends People {
  String name = 'hello';
  int age = 0;

  Map<String, dynamic> toJson() => {
        'name': name,
        'age': 32,
      };
}

class GoodFriend extends Friend {
  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'age': 24,
      };
}

class BusinessFriend extends Friend with NameMixin, AddressMixin implements Business {
  @override
  String address = 'my address';

  BusinessFriend({String? address});

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'age': 24,
        'address': address,
      };
}

mixin AddressMixin {
  String address = 'hello address';
}

mixin NameMixin on Friend {
  @override
  String get name => 'modify name';
}

abstract class Data {
  late String userUid;

  Data({required this.userUid});

  // Data.fromJson(Map<String, dynamic> json) : this(userUid: json['userUid']);

  Data.fromJson(Map<String, dynamic> json) {
    userUid = '';
  }

  Map<String, dynamic> toJson() => {
        'userUid': userUid,
      };
}

class User extends Data {
  late String userName;

  User({required super.userUid, required this.userName});

  User.fromJson(super.json)
      : userName = json['userName'],
        super.fromJson();

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'userName': userName,
      };
}

class School {
  String get name => _name;
  late final String _name;

  School({String? name}) : _name = name ?? '';

  School.fromJson(Map<String, dynamic> json) {
    _name = json['name'];
  }

  Map<String, dynamic> toJson() => {
        'name': _name,
      };
}

class SocketAddress {
  final String ip;
  SocketAddress(this.ip);
}