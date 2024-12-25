import 'package:fbl/fbl.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

///
/// Created by a0010 on 2024/8/13 13:52
///
class PermissionPage extends StatefulWidget {
  final XPermission permission;
  final bool isShowPermanentlyDeniedInfo;

  const PermissionPage({
    super.key,
    required this.permission,
    this.isShowPermanentlyDeniedInfo = true,
  });

  static Future<bool> request(
    BuildContext context, {
    required XPermission permission,
    bool isShowPermanentlyDeniedInfo = true,
  }) async {
    bool? result = await Navigator.of(context).push<bool?>(_TransparentRoute<bool?>(
      builder: (context) {
        return PermissionPage(
          permission: permission,
          isShowPermanentlyDeniedInfo: isShowPermanentlyDeniedInfo,
        );
      },
    ));
    return result ?? false;
  }

  static List<Permission> get databasePermissions => [
        /// Android: External Storage
        /// iOS: Access to folders like `Documents` or `Downloads`. Implicitly
        /// granted.
        // Permission.storage,
      ];

  static List<Permission> get photoReadingPermissions => _photoReadingPermissions;
  static final List<Permission> _photoReadingPermissions = [
    /// When running on Android T and above: Read image files from external storage
    /// When running on Android < T: Nothing
    /// iOS: Photos
    /// iOS 14+ read & write access level
    if (BuildConfig.isIOS) Permission.photos,
  ];

  static List<Permission> get photoAccessingPermissions => _photoAccessingPermissions;
  static final List<Permission> _photoAccessingPermissions = [
    /// When running on Android T and above: Read image files from external storage
    /// When running on Android < T: Nothing
    /// iOS: Photos
    /// iOS 14+ read & write access level
    if (BuildConfig.isIOS) Permission.photos,

    /// Android: Nothing
    /// iOS: Photos
    /// iOS 14+ read & write access level
    if (BuildConfig.isIOS) Permission.photosAddOnly,

    /// Android: External Storage
    /// iOS: Access to folders like `Documents` or `Downloads`. Implicitly
    /// granted.
    // if (DevicePlatform.isAndroid)
    // Permission.storage,
  ];

  static List<Permission> get cameraPermissions => [
        /// Android: Camera
        /// iOS: Photos (Camera Roll and Camera)
        Permission.camera,

        // Permission.storage,
      ];

  static List<Permission> get microphonePermissions => [
        /// Android: Microphone
        /// iOS: Microphone
        Permission.microphone,
      ];

  @override
  State<PermissionPage> createState() => _PermissionPageState();
}

class _PermissionPageState extends State<PermissionPage> with Logging {
  bool _showPermissionInfo = false;

  @override
  void initState() {
    super.initState();
    _requestPermissions(widget.permission);
  }

  /// 请求权限
  void _requestPermissions(XPermission myPermission) async {
    Permission permission = myPermission.permission;
    if ((await permission.isGranted) && mounted) {
      // 已授权直接返回
      Navigator.pop(context, true);
      return;
    }

    // android端权限未授权，才弹出顶部说明弹窗
    if (BuildConfig.isAndroid) {
      // 未被永久拒绝时显示
      // var status = await permission.status;
      // bool isPermanentlyDenied = status.isPermanentlyDenied;
      // bool isDenied = status.isDenied;
      // setState(() => _showPermissionInfo = !isPermanentlyDenied);
      setState(() => _showPermissionInfo = true);
    }
    // 请求权限
    PermissionStatus status = await permission.request();
    logDebug('权限${Permission.byValue(permission.value)}请求的结果：result=${status.name}');
    // 请求权限的结果处理
    if (status.isGranted) {
      setState(() => _showPermissionInfo = false);
      // 已授予权限
      if (mounted) Navigator.pop(context, true);
      // } else if (result.isDenied) {
      // 拒绝本次授予权限
    } else {
      setState(() => _showPermissionInfo = false);
      if (widget.isShowPermanentlyDeniedInfo) {
        // 永久拒绝授予权限
        _showPermissionDialog();
      } else {
        if (mounted) Navigator.pop(context, false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_showPermissionInfo) {
      return const SizedBox.shrink();
    }
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _buildPermissionInfoView(),
    );
  }

  Widget _buildPermissionInfoView() {
    XPermission permission = widget.permission;
    String title = '${permission.title}说明';
    String text = '用于${permission.text}';
    double statusBarHeight = MediaQuery.of(context).padding.top;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: statusBarHeight),
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(8)),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 1),
            blurRadius: 10.0,
            spreadRadius: 0.0,
            color: Color(0x0D000000),
          ),
          BoxShadow(
            offset: Offset(0, 4),
            blurRadius: 4.0,
            spreadRadius: 0.0,
            color: Color(0x14000000),
          ),
        ],
      ),
      child: Row(children: [
        Expanded(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(title, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 16),
            Text(text, style: const TextStyle(color: Colors.black38)),
          ]),
        ),
      ]),
    );
  }

  void _showPermissionDialog() {
    CommonDialog.showPromptDialog(
      context,
      titleString: '开启${widget.permission.title}',
      content: Text('你还没开启${widget.permission.title}，开启后即可${widget.permission.text}'),
      negativeText: '以后再说',
      positiveText: '继续',
      positiveStyle: const TextStyle(fontWeight: FontWeight.bold),
      onPositiveTap: () {
        openAppSettings();
        if (mounted) Navigator.pop(context, false);
      },
      onNegativeTap: () {
        if (mounted) Navigator.pop(context, false);
      },
    );
  }
}

class _TransparentRoute<T> extends PageRoute<T> {
  _TransparentRoute({
    required this.builder,
  }) : super(
          settings: const RouteSettings(name: 'TransparentRoute'),
        );

  final WidgetBuilder builder;

  @override
  String? get barrierLabel => null;

  @override
  bool get opaque => false;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 0);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return builder(context);
  }

  /// 页面切换动画
  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(opacity: animation, child: child);
  }

  @override
  Color? get barrierColor => null;
}

enum XPermission {
  camera(Permission.camera, '相机权限', '扫一扫，拍摄照片、视频、视频聊天。'),
  location(Permission.location, '位置权限', '商/好友圈定位、地图展示、位置分享、路线导航。'),
  photos(Permission.photos, '相册权限', '图片或视频的上传、保存。'),
  microphone(Permission.microphone, '麦克风权限', '语音录制、语音通话。'),
  storage(Permission.storage, '存储权限', '查看、保存和发送文件、图片、视频'),
  manageExternalStorage(Permission.manageExternalStorage, '所有文件权限', '在聊天中发送文件'),
  contacts(Permission.contacts, '联系人权限', '同步联系人、通话记录，实现应用内拨打电话或快速加好友'),
  notification(Permission.notification, '通知权限', '接收云鱼聊天、系统通知'),
  phone(Permission.phone, '拨打电话权限', '拨打电话');

  final Permission permission;
  final String title;
  final String text;

  const XPermission(this.permission, this.title, this.text);
}
