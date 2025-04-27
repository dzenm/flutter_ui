import 'package:fbl/src/config/notification.dart' as ln;
import 'package:flutter/material.dart';

import 'indicators.dart';

///
/// Created by a0010 on 2024/9/27 09:46
///
class UploadProgressView extends StatefulWidget {
  final String taskUid;

  const UploadProgressView({super.key, required this.taskUid});

  @override
  State<UploadProgressView> createState() => _UploadProgressViewState();
}

class _UploadProgressViewState extends State<UploadProgressView> implements ln.Observer {
  double _progress = 0;
  bool _show = false;

  @override
  void initState() {
    super.initState();
    var nc = ln.NotificationCenter();
    nc.addObserver(this, UploadName.kFileUploadSuccess);
    nc.addObserver(this, UploadName.kFileUploading);
    nc.addObserver(this, UploadName.kFileUploadFailure);
  }

  @override
  void dispose() {
    super.dispose();
    var nc = ln.NotificationCenter();
    nc.removeObserver(this, UploadName.kFileUploadSuccess);
    nc.removeObserver(this, UploadName.kFileUploading);
    nc.removeObserver(this, UploadName.kFileUploadFailure);
  }

  @override
  Widget build(BuildContext context) {
    if (!_show) {
      return const SizedBox.shrink();
    }
    return LinearPercentIndicator(
      backgroundColor: const Color(0xFFd3d6da),
      percent: _progress,
      progressColor: Colors.red,
    );
  }

  @override
  Future<void> onReceiveNotification(ln.Notification notification) async {
    String name = notification.name;
    Map? info = notification.userInfo;
    if (name == UploadName.kFileUploading) {
      _show = true;
      String? taskUid = info?['taskUid'];
      if (taskUid != null && taskUid == widget.taskUid) {
        double? progress = info?['progress'];
        _progress = progress ?? 0.0;
        setState(() {});
      }
    } else if (name == UploadName.kFileUploadSuccess) {
      _show = false;
      setState(() {});
    } else if (name == UploadName.kFileUploadFailure) {
      _show = false;
      setState(() {});
    }
  }
}

abstract class UploadName {
  static const String kFileUploadSuccess = 'FileUploadSuccess';
  static const String kFileUploading = 'FileUploading';
  static const String kFileUploadFailure = 'FileUploadFailure';
}