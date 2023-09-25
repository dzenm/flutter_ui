import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scan/scan.dart';

import '../../../base/base.dart';

/// 二维码扫描页面, 在进入页面之前先请求权限
class QRPage extends StatefulWidget {
  const QRPage({super.key});

  @override
  State<StatefulWidget> createState() => _QRPageState();
}

class _QRPageState extends State<QRPage> {
  StateSetter? stateSetter;
  IconData lightIcon = Icons.flash_on;
  ScanController? controller = ScanController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('二维码', style: TextStyle(color: Colors.white)),
      ),
      body: Stack(children: [
        ScanView(
          controller: controller,
          scanAreaScale: .7,
          scanLineColor: const Color(0xFF4759DA),
          onCapture: (data) {
            _getResult(data);
          },
        ),
        Positioned(
          width: MediaQuery.of(context).size.width,
          bottom: 32,
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            StatefulBuilder(
              builder: (BuildContext context, StateSetter state) {
                stateSetter = state;
                return TapLayout(
                  padding: const EdgeInsets.all(8),
                  child: Icon(lightIcon, size: 32, color: const Color(0xFF4759DA)),
                  onTap: () {
                    controller?.toggleTorchMode();
                    if (lightIcon == Icons.flash_on) {
                      lightIcon = Icons.flash_off;
                    } else {
                      lightIcon = Icons.flash_on;
                    }
                    stateSetter!(() {});
                  },
                );
              },
            ),
            const SizedBox(width: 16),
            TapLayout(
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.image, size: 32, color: Color(0xFF4759DA)),
              onTap: () async {
                XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
                if (image != null) {
                  String? result = await Scan.parse(image.path);
                  if (result != null) {
                    setState(() => _getResult(result));
                  }
                }
              },
            )
          ]),
        ),
      ]),
    );
  }

  void _getResult(String result) {
    CommonDialog.showToast(result);
    Navigator.pop(context);
  }
}
