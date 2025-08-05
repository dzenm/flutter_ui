import 'dart:io';
import 'dart:math';

import 'package:bonsoir/bonsoir.dart';
import 'package:fbl/fbl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

///
/// Created by a0010 on 2025/7/2 09:59
///
class MdnsPage extends StatefulWidget {
  const MdnsPage({super.key});

  @override
  State<MdnsPage> createState() => _MdnsPageState();
}

class _MdnsPageState extends State<MdnsPage> with Logging {
  @override
  void initState() {
    super.initState();
  }

  void _createService() async {
    // Let's create our service !
    BonsoirService service = BonsoirService(
      name: 'My wonderful service',
      // Put your service name here.
      type: '_wonderful-service._tcp',
      // Put your service type here. Syntax : _ServiceType._TransportProtocolName. (see http://wiki.ros.org/zeroconf/Tutorials/Understanding%20Zeroconf%20Service%20Types).
      port: 3030, // Put your service port here.
    );
    logInfo('创建服务');

    // And now we can broadcast it :
    BonsoirBroadcast broadcast = BonsoirBroadcast(service: service);
    await broadcast.ready;
    await broadcast.start();
    logInfo('启动服务');

    // ...

    // Then if you want to stop the broadcast :
    // await broadcast.stop();
  }

  void _discoverService() async {
    // This is the type of service we're looking for :
    String type = '_wonderful-service._tcp';

    // Once defined, we can start the discovery :
    BonsoirDiscovery discovery = BonsoirDiscovery(type: type);
    await discovery.ready;
    logInfo('发现服务');

    // If you want to listen to the discovery :
    discovery.eventStream!.listen((event) {
      // `eventStream` is not null as the discovery instance is "ready" !
      if (event.type == BonsoirDiscoveryEventType.discoveryServiceFound) {
        print('Service found : ${event.service?.toJson()}');
        event.service!.resolve(discovery.serviceResolver); // Should be called when the user wants to connect to this service.
      } else if (event.type == BonsoirDiscoveryEventType.discoveryServiceResolved) {
        print('Service resolved : ${event.service?.toJson()}');
      } else if (event.type == BonsoirDiscoveryEventType.discoveryServiceLost) {
        print('Service lost : ${event.service?.toJson()}');
      }
    });

    // Start the discovery **after** listening to discovery events :
    await discovery.start();
    logInfo('启动发现服务');

    // Then if you want to stop the discovery :
//     await discovery.stop();
  }

  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch<LocalModel>().theme;
    return Scaffold(
      appBar: const CommonBar(title: 'MDNS服务'),
      backgroundColor: const Color.fromARGB(255, 100, 100, 100),
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Expanded(
          flex: 1,
          child: _buildItemView(context, '我要创建服务器', Colors.yellow, () {
            _createService();
          }),
        ),
        Expanded(
          flex: 1,
          child: _buildItemView(context, '我要加入服务器', Colors.green, () {
            _discoverService();
          }),
        ),
      ]),
    );
  }

  Widget _buildItemView(
    BuildContext context,
    String title,
    Color color,
    GestureTapCallback onTap,
  ) {
    AppTheme theme = context.watch<LocalModel>().theme;
    return TapLayout(
      background: color,
      onTap: onTap,
      child: Center(
        child: Text(
          title,
          style: TextStyle(color: theme.primaryText),
        ),
      ),
    );
  }
}

class RadarPage extends StatefulWidget {
  const RadarPage({super.key});

  @override
  State<RadarPage> createState() => _RadarPageState();
}

class _RadarPageState extends State<RadarPage> with TickerProviderStateMixin {
  final ValueNotifier<List<Device>> _devicesNotifier = ValueNotifier([]);
  String _ipResolveFailed = 'IP resolution failed';
  AnimationController? _rotationController;
  AnimationController? _expansionController;
  bool _isScanning = false;
  final _random = Random();

  BonsoirDiscovery _discovery = BonsoirDiscovery(type: '_http._tcp');

  @override
  void initState() {
    super.initState();

    // 初始化旋转控制器
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(); // 无限循环旋转

    // 初始化扩展控制器
    _expansionController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(); // 无限循环扩展
    _toggleScanning();
  }

  Future<void> _toggleScanning() async {
    setState(() {
      _isScanning = !_isScanning;
      if (_isScanning) {
        // 开始扫描：恢复动画和设备
        _rotationController?.repeat();
        _expansionController?.repeat();
        // _getLocalIpAddress();
        // _discoverDevices();
        _startDiscovery();
      } else {
        // 停止扫描：暂停动画并清空设备
        _rotationController?.stop();
        _expansionController?.stop();
        _discovery.stop();

        _devicesNotifier.value.clear();
      }
    });
  }

  void _showDevice(Device device) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('设备信息'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('设备名称：${device.name}'),
                  Row(
                    children: [
                      Text('设备ID： ${device.ip}'),
                      Visibility(
                        visible: device.ip == _ipResolveFailed,
                        child: const Icon(Icons.warning, color: Colors.red, size: 20),
                      ),
                    ],
                  ),
                  Text('设备端口：${device.port}'),
                  Text('设备详情：${device.details}'),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('取消'),
                ),
                Visibility(
                  visible: device.ip != _ipResolveFailed,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    child: const Text('确定'),
                  ),
                ),
              ],
            )).then((v) {
      if (v == true) {
        if (!mounted) return;
        Navigator.pop(context, 'http://${device.ip}:${device.port}');
      }
    });
  }

  // ignore: unused_element
  Future<void> _discoverDevices() async {
    _devicesNotifier.value.clear();
    // final MDnsClient client = MDnsClient();
    // final List<Device> list = [];
    // await client.start();
    //
    // await for (final PtrResourceRecord ptr in client.lookup<PtrResourceRecord>(
    //   ResourceRecordQuery.serverPointer('_http._tcp'),
    // )) {
    //   await for (final SrvResourceRecord srv in client.lookup<SrvResourceRecord>(
    //     ResourceRecordQuery.service(ptr.domainName),
    //   )) {
    //     await for (final IPAddressResourceRecord ip in client.lookup<IPAddressResourceRecord>(
    //       ResourceRecordQuery.addressIPv4(srv.target),
    //     )) {
    //       final double minDistance = 0.3.sw;
    //       bool overlap = true;
    //
    //       while (overlap) {
    //         final angle = _random.nextDouble() * 2 * pi;
    //         final distance = 0.1.sw + _random.nextDouble() * 0.1.sw;
    //         overlap = false;
    //         final device = Device(name: srv.target, ip: ip.address.address, angle: angle, distance: distance, port: srv.port, details: srv.name);
    //         for (Device existinDevice in list) {
    //           final d = _calculateDistance(device, existinDevice);
    //           if (d > minDistance) {
    //             overlap = true;
    //             list.add(device);
    //             break;
    //           }
    //         }
    //       }
    //     }
    //   }
    // }
    // if (list.isNotEmpty) {
    //   final seenNames = <String>{};
    //   final r = list.where((device) => seenNames.add(device.name)).toList();
    //   _devicesNotifier.value = r;
    // }
    // client.stop();
  }

// 计算两设备之间的距离
  double _calculateDistance(Device device1, Device device2) {
    //将极坐标转换为直角坐标
    double x1 = device1.distance * cos(device1.angle);
    double y1 = device1.distance * sin(device1.angle);
    double x2 = device2.distance * cos(device2.angle);
    double y2 = device2.distance * sin(device2.angle);
    return sqrt(pow(x2 - x1, 2) + pow(y2 - y1, 2));
  }

  void _startDiscovery() {
    _discovery = BonsoirDiscovery(type: '_http._tcp');
    _discovery.ready.then((_) {
      _discovery.eventStream?.listen((event) async {
        if (event.type == BonsoirDiscoveryEventType.discoveryServiceFound) {
          debugPrint('Service found : ${event.service?.toJson()}');
          event.service!.resolve(_discovery.serviceResolver); // Should be called when the user wants to connect to this service.
        } else if (event.type == BonsoirDiscoveryEventType.discoveryServiceResolved) {
          debugPrint('Service resolved : ${event.service?.toJson()}');
          if (event.service != null) {
            final service = event.service!;
            // 尝试解析 IP 地址
            final ip = await resolveIpAddress(service as ResolvedBonsoirService);
            const double minDistance = 50;
            bool overlap = true;
            Device? device;

            // 找到一个不重叠的设备位置
            while (overlap) {
              final angle = _random.nextDouble() * 2 * pi;
              final distance = 0.1 + _random.nextDouble() * 0.05;
              overlap = false;

              device = Device(
                name: service.name,
                details: service.toString(),
                port: service.port,
                ip: ip ?? _ipResolveFailed,
                angle: angle,
                distance: distance,
              );

              if (_devicesNotifier.value.isEmpty) {
                _devicesNotifier.value = [device];
                debugPrint('length1: ${_devicesNotifier.value.length}');
                break;
              } else {
                final list = _devicesNotifier.value;
                for (Device existingDevice in list) {
                  if (_calculateDistance(device, existingDevice) < minDistance) {
                    overlap = true;
                    break;
                  }
                }
                // 只有在没有重叠的情况下才添加设备
                if (!overlap) {
                  _devicesNotifier.value = [..._devicesNotifier.value, device];
                  debugPrint('length2: ${_devicesNotifier.value.length}');
                  break;
                }
              }
            }
          }
        } else if (event.type == BonsoirDiscoveryEventType.discoveryServiceLost) {
          debugPrint('Service lost : ${event.service?.toJson()}');
          if (event.service != null) {
            final list = _devicesNotifier.value;
            list.removeWhere((e) => e.name == event.service!.name);
            _devicesNotifier.value = list;
          }
        }
      });
      _discovery.start();
    });
  }

  // Future<String?> resolveIpAddress(ResolvedBonsoirService service) async {
  //   try {
  //     // 使用服务名称来解析 IP 地址（假设服务名是唯一的）
  //     List<InternetAddress> addresses = await InternetAddress.lookup(
  //         service.host!,
  //         type: InternetAddressType.IPv4);
  //     for (var address in addresses) {
  //       debugPrint("IP Address: ${address.address}");
  //       return address.address;
  //     }
  //   } catch (e) {
  //     debugPrint("Failed to resolve IP: $e");
  //   }
  //   return null;
  // }

  Future<String?> resolveIpAddress(ResolvedBonsoirService service) async {
    try {
      final attributesIp = service.attributes['CurrentIp'];
      if (attributesIp != null && attributesIp != '127.0.0.1') {
        return attributesIp;
      }

      /// 判断 host
      if (service.host == null || service.host!.isEmpty) {
        debugPrint("Resolved host is empty");
      }

      // 使用 DNS 查找
      debugPrint("Resolving IP for host: ${service.host}");
      List<InternetAddress> addresses = await InternetAddress.lookup(service.host!, type: InternetAddressType.IPv4);
      if (addresses.isNotEmpty) {
        debugPrint("Resolved IP Address: ${addresses.first.address}");
        return addresses.first.address;
      } else {
        debugPrint("No IP addresses found for host: ${service.host}");
      }
    } catch (e, stackTrace) {
      debugPrint("Failed to resolve IP: $e");
      debugPrint("Stack trace: $stackTrace");
    }
    return null;
  }

  @override
  void dispose() {
    _rotationController?.dispose();
    _expansionController?.dispose();
    _discovery.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _ipResolveFailed = 'IP解析失败';
    return Scaffold(
      appBar: AppBar(title: Text('附近的设备')),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 1,
            // height: 1.sh,
            color: Colors.grey.withOpacity(0.1),
          ),
          // 外部扩张的圆弧效果
          Visibility(
              visible: _isScanning,
              child: AnimatedBuilder(
                animation: _expansionController!,
                builder: (context, child) {
                  return CustomPaint(
                    painter: RadarArcPainter(_expansionController!.value),
                    size: Size(1, 1),
                  );
                },
              )),
          // 固定的同心圆弧
          CustomPaint(
            painter: RadarBackgroundPainter(),
            size: Size(50, 50),
            isComplex: false,
            willChange: false,
          ),

          // 旋转的扫描线
          Visibility(
              visible: _isScanning,
              child: RotationTransition(
                turns: _rotationController!,
                child: CustomPaint(
                  painter: RadarLinePainter(),
                  size: Size(50, 50),
                ),
              )),
          // 显示检测到的设备
          ValueListenableBuilder(
              valueListenable: _devicesNotifier,
              builder: (ctx, v, _) {
                debugPrint('${"-" * 100} v:${v.length}');
                return Stack(
                  children: v.map((device) => _buildDeviceWidget(device)).toList(),
                );
              }),

          // 显示设备信息
          Positioned(
            bottom: 20,
            child: Column(
              children: [
                ElevatedButton(onPressed: _toggleScanning, child: Text(_isScanning ? '挂起' : '扫描')),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  '扫描中',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 构建每个设备的 Widget
  Widget _buildDeviceWidget(Device device) {
    // 计算设备的位置
    final double x = 150 + device.distance * cos(device.angle);
    final double y = 150 + device.distance * sin(device.angle);
    // HoloMotion-on-HM20240620141200._http._tcp.local
    bool isHMDevice = device.details.contains('HoloMotion');
    return Positioned(
      left: x,
      top: y,
      child: GestureDetector(
        onTap: () => _showDevice(device),
        child: Column(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: isHMDevice ? Theme.of(context).primaryColor : Colors.grey,
              child: const Icon(Icons.devices, color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              device.name,
              style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold),
            ),
            Text(
              device.ip,
              style: const TextStyle(color: Colors.black, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

// 定义设备信息类
class Device {
  final String name;
  final String ip;
  final double angle; // 设备在雷达上的角度
  final double distance; // 设备与雷达中心的距离
  final int port;
  final String details;

  Device({
    required this.name,
    required this.ip,
    required this.angle,
    required this.distance,
    required this.port,
    required this.details,
  });
}

// 绘制扩展的圆弧效果
class RadarArcPainter extends CustomPainter {
  final double progress; // 动画的进度值

  RadarArcPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.green.withOpacity(1 - progress) // 随着进度逐渐变透明
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // 绘制多个同心扩张的完整圆
    for (double radius = size.width / 4; radius <= size.width / 2; radius += size.width / 8) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: radius * progress),
        0, // 起始角度为 0
        2 * 3.14159, // 绘制完整的 360 度圆
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant RadarArcPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// 绘制雷达的背景和同心圆弧
class RadarBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint backgroundPaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.green.shade400, Colors.green.shade800],
      ).createShader(Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: size.width / 2))
      ..style = PaintingStyle.fill;

    // 绘制绿色的雷达背景
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      backgroundPaint,
    );

    final Paint linePaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // 绘制同心的白色圆弧
    for (double radius = size.width / 5; radius < size.width / 2; radius += size.width / 6) {
      canvas.drawCircle(
        Offset(size.width / 2, size.height / 2),
        radius,
        linePaint,
      );
    }
    final Paint linePaint2 = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      linePaint2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

// 绘制旋转的扫描线
class RadarLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.fill
      ..strokeWidth = 2.0;

    // 计算中心点
    final Offset center = Offset(size.width / 2, size.height / 2);

    // 绘制扫描线
    canvas.drawLine(
      center,
      Offset(
        center.dx + size.width / 2 * cos(0), // 计算终点的 x 坐标
        center.dy + size.width / 2 * sin(0), // 计算终点的 y 坐标
      ),
      linePaint,
    );

    // 绘制覆盖扫描区域的扇形
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: size.width / 2),
      -pi / 6, // 扫描起始角度（可以调整以覆盖更多区域）
      pi / 6, // 扫描的角度范围
      true,
      linePaint..color = Colors.white.withOpacity(0.1),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
