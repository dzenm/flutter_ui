import 'package:fbl/fbl.dart';
import 'package:flutter/material.dart';

import '../../../widgets/scan_qr_widget.dart';

/// 二维码扫描页面, 在进入页面之前先请求权限
class QRPage extends StatelessWidget {

  const QRPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScanQRWidget(
        flashLightText: '调节扫码距离和角度，避免反光',
        onDetect: (capture) {
          CommonDialog.showToast('识别的二维码：${capture.barcodes.firstOrNull?.displayValue}');
        },
      ),
    );
  }
}
