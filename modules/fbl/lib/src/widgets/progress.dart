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
    nc.addObserver(this, UploadNames.kFileUploadSuccess);
    nc.addObserver(this, UploadNames.kFileUploading);
    nc.addObserver(this, UploadNames.kFileUploadFailure);
  }

  @override
  void dispose() {
    super.dispose();
    var nc = ln.NotificationCenter();
    nc.removeObserver(this, UploadNames.kFileUploadSuccess);
    nc.removeObserver(this, UploadNames.kFileUploading);
    nc.removeObserver(this, UploadNames.kFileUploadFailure);
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
    if (name == UploadNames.kFileUploading) {
      _show = true;
      String? taskUid = notification.userInfo?['taskUid'];
      if (taskUid != null && taskUid == widget.taskUid) {
        double? progress = notification.userInfo?['progress'];
        _progress = progress ?? 0.0;
        setState(() {});
      }
    } else if (name == UploadNames.kFileUploadSuccess) {
      _show = false;
      setState(() {});
    } else if (name == UploadNames.kFileUploadFailure) {
      _show = false;
      setState(() {});
    }
  }
}

abstract class UploadNames {
  static const kFileUploadSuccess = 'FileUploadSuccess';
  static const kFileUploading = 'FileUploading';
  static const kFileUploadFailure = 'FileUploadFailure';
}