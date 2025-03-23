import '../../server/connection.dart';

///
/// Created by a0010 on 2025/2/26 11:26
///
class WifiConnectionClient implements Connection {
  @override
  bool get isConnected => throw UnimplementedError();

  @override
  bool get isTransiting => throw UnimplementedError();

  @override
  // TODO: implement isPrepare
  bool get isPrepare => throw UnimplementedError();
}
