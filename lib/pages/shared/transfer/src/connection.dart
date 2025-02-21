///
/// Created by a0010 on 2025/1/25 13:07
///
abstract interface class Connection {}

abstract interface class SocketConnection extends Connection {}

abstract interface class BleConnection extends SocketConnection {}

abstract interface class WifiConnection extends SocketConnection {}
