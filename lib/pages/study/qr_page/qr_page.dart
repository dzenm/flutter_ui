import 'package:flutter/material.dart';
import 'package:flutter_ui/base/res/strings.dart';
import 'package:flutter_ui/base/router/route_manager.dart';
import 'package:flutter_ui/base/widgets/common_dialog.dart';
import 'package:flutter_ui/base/widgets/tap_layout.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scan/scan.dart';

/// 二维码扫描页面, 在进入页面之前先请求权限
class QRPage extends StatefulWidget {
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
        title: Text(S.of(context).qr, style: TextStyle(color: Colors.white)),
      ),
      body: Stack(children: [
        ScanView(
          controller: controller,
          scanAreaScale: .7,
          scanLineColor: Color(0xFF4759DA),
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
                  padding: EdgeInsets.all(8),
                  child: Icon(lightIcon, size: 32, color: Color(0xFF4759DA)),
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
            SizedBox(width: 16),
            TapLayout(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.image, size: 32, color: Color(0xFF4759DA)),
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
    showToast(result);
    RouteManager.pop(context);
  }
}
