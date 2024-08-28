import 'package:fbl/fbl.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

///
/// Created by a0010 on 2024/8/28 09:27
///
/// 扫描二维码布局
class ScanQRWidget extends StatefulWidget {
  final String flashLightText;
  final void Function(BarcodeCapture barcodes)? onDetect;
  final List<Widget> children;

  const ScanQRWidget({
    super.key,
    required this.flashLightText,
    this.onDetect,
    this.children = const [],
  });

  @override
  State<ScanQRWidget> createState() => _ScanQRWidgetState();
}

class _ScanQRWidgetState extends State<ScanQRWidget> {
  final MobileScannerController _controller = MobileScannerController(
    torchEnabled: false,
  );

  BarcodeCapture? _barcodes;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _barcodes = null;
    _controller.start();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      MobileScanner(
        controller: _controller,
        onDetect: (capture) {
          if (_barcodes != null) {
            return;
          }
          _barcodes = capture;
          if (widget.onDetect != null) {
            widget.onDetect!(capture);
          }
        },
        errorBuilder: (context, error, child) {
          return ScannerErrorWidget(error: error);
        },
        fit: BoxFit.fitHeight,
      ),
      Positioned(
        top: 48,
        left: 20,
        child: _buildCloseView(),
      ),
      Positioned(
        top: 48,
        right: 20,
        child: DecodeQRFromPickImageButton(
          controller: _controller,
        ),
      ),
      Align(
        alignment: Alignment.bottomCenter,
        child: _buildFlashLightView(),
      ),
      ...widget.children,
    ]);
  }

  /// 闪光灯和t提示文本布局
  Widget _buildFlashLightView() {
    return Container(
      color: Colors.black,
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            margin: const EdgeInsets.all(20),
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: ToggleFlashlightButton(controller: _controller),
          ),
          SizedBox(
            height: 30,
            child: Text(
              widget.flashLightText,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          )
        ],
      ),
    );
  }

  /// 关闭页面按钮布局
  Widget _buildCloseView() {
    return IconButton(
      icon: const Icon(
        Icons.close,
        color: Colors.white,
        size: 32,
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    await _controller.dispose();
  }
}

/// 选择图片解析二维码布局
class DecodeQRFromPickImageButton extends StatelessWidget {
  final MobileScannerController controller;
  final void Function(BarcodeCapture barcodes)? onDetect;

  const DecodeQRFromPickImageButton({
    super.key,
    required this.controller,
    this.onDetect,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      color: Colors.white,
      icon: const Icon(Icons.image),
      iconSize: 32.0,
      onPressed: () async {
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(
          source: ImageSource.gallery,
        );

        if (image == null) {
          return;
        }

        final BarcodeCapture? barcodes = await controller.analyzeImage(
          image.path,
        );

        if (barcodes == null) {
          CommonDialog.showToast('未识别到二维码');
          return;
        }

        if (onDetect != null) {
          onDetect!(barcodes);
        }
      },
    );
  }
}

/// 切换闪光灯按钮布局
class ToggleFlashlightButton extends StatelessWidget {
  const ToggleFlashlightButton({required this.controller, super.key});

  final MobileScannerController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, state, child) {
        if (!state.isInitialized || !state.isRunning) {
          return const SizedBox.shrink();
        }
        switch (state.torchState) {
          case TorchState.auto:
            return IconButton(
              color: Colors.white,
              icon: const Icon(Icons.flash_auto, size: 30),
              onPressed: () async {
                await controller.toggleTorch();
              },
            );
          case TorchState.off:
            return IconButton(
              icon: const Icon(Icons.flash_off, size: 30),
              onPressed: () async {
                await controller.toggleTorch();
              },
            );
          case TorchState.on:
            return IconButton(
              color: Colors.blue,
              icon: const Icon(Icons.flash_on, size: 30),
              onPressed: () async {
                await controller.toggleTorch();
              },
            );
          case TorchState.unavailable:
            return const Icon(
              Icons.no_flash,
              color: Colors.grey,
              size: 30,
            );
        }
      },
    );
  }
}

/// 二维码识别加载错误布局
class ScannerErrorWidget extends StatelessWidget {
  const ScannerErrorWidget({super.key, required this.error});

  final MobileScannerException error;

  @override
  Widget build(BuildContext context) {
    String errorMessage;

    switch (error.errorCode) {
      case MobileScannerErrorCode.controllerUninitialized:
        errorMessage = 'Controller not ready.';
      case MobileScannerErrorCode.permissionDenied:
        errorMessage = 'Permission denied';
      case MobileScannerErrorCode.unsupported:
        errorMessage = 'Scanning is unsupported on this device';
      default:
        errorMessage = 'Generic Error';
        break;
    }

    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Icon(Icons.error, color: Colors.white),
            ),
            Text(
              errorMessage,
              style: const TextStyle(color: Colors.white),
            ),
            Text(
              error.errorDetails?.message ?? '',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
