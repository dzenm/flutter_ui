import 'package:fbl/src/config/notification.dart' as ln;
import 'package:flutter/material.dart';

import '../core/shared/notify.dart';
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

class _UploadProgressViewState extends State<UploadProgressView> //
    with
        StateObserver {
  double _progress = 0;
  bool _show = false;

  @override
  void initState() {
    super.initState();
    addObserver(UploadNames.kFileUploading);
    addObserver(UploadNames.kFileUploadCancel);
    addObserver(UploadNames.kFileUploadSuccess);
    addObserver(UploadNames.kFileUploadFailure);
  }

  @override
  void dispose() {
    super.dispose();
    removeObserver(UploadNames.kFileUploading);
    removeObserver(UploadNames.kFileUploadCancel);
    removeObserver(UploadNames.kFileUploadSuccess);
    removeObserver(UploadNames.kFileUploadFailure);
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
    var name = notification.name;
    var userInfo = notification.userInfo;
    String? taskUid = userInfo?['taskUid'];
    if (taskUid == null || taskUid != widget.taskUid) {
      return;
    }
    if (name == UploadNames.kFileUploading) {
      _show = true;
      double? progress = userInfo?['progress'];
      _progress = progress ?? 0.0;
      setState(() {});
    } else if (name == UploadNames.kFileUploading) {
      _show = false;
      setState(() {});
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
  static const kFileUploading = 'FileUploading';
  static const kFileUploadCancel = 'FileUploadCancel';
  static const kFileUploadSuccess = 'FileUploadSuccess';
  static const kFileUploadFailure = 'FileUploadFailure';
}
