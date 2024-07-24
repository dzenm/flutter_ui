import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

///
/// Created by a0010 on 2023/12/7 14:01
///
const maxItemLength = 2048;

class RegistryKeyValuePair {
  final String key;
  final String value;

  const RegistryKeyValuePair(this.key, this.value);
}

class RegistryUtil {
  /// 根据键名获取注册表的值
  static String? getRegeditForKey(String regPath, String key, {int hKeyValue = HKEY_LOCAL_MACHINE}) {
    var res = getRegedit(regPath, hKeyValue: hKeyValue);
    return res[key];
  }

  /// 设置注册表值
  static setRegeditValue(String regPath, String key, String value, {int hKeyValue = HKEY_CURRENT_USER}) {
    final phKey = calloc<HANDLE>();
    final lpKeyPath = regPath.toNativeUtf16();
    final lpKey = key.toNativeUtf16();
    final lpValue = value.toNativeUtf16();
    try {
      if (RegSetKeyValue(hKeyValue, lpKeyPath, lpKey, REG_VALUE_TYPE.REG_SZ, lpValue, lpValue.length * 2) != WIN32_ERROR.ERROR_SUCCESS) {
        throw Exception("Can't set registry key");
      }
      return phKey.value;
    } finally {
      free(phKey);
      free(lpKeyPath);
      free(lpKey);
      free(lpValue);
      RegCloseKey(HKEY_CURRENT_USER);
    }
  }

  /// 获取注册表所有子项
  static List<String>? getRegeditKeys(String regPath, {int hKeyValue = HKEY_LOCAL_MACHINE}) {
    final hKey = _getRegistryKeyHandle(hKeyValue, regPath);
    var dwIndex = 0;
    String? key;
    List<String>? keysList;
    key = _enumerateKeyList(hKey, dwIndex);
    while (key != null) {
      keysList ??= [];
      keysList.add(key);
      dwIndex++;
      key = _enumerateKeyList(hKey, dwIndex);
    }
    RegCloseKey(hKey);
    return keysList;
  }

  /// 删除注册表的子项
  static bool deleteRegistryKey(String regPath, String subPath, {int hKeyValue = HKEY_LOCAL_MACHINE}) {
    final subKeyForPath = subPath.toNativeUtf16();
    final hKey = _getRegistryKeyHandle(hKeyValue, regPath);
    try {
      final status = RegDeleteKey(hKey, subKeyForPath);
      switch (status) {
        case WIN32_ERROR.ERROR_SUCCESS:
          return true;
        case WIN32_ERROR.ERROR_MORE_DATA:
          throw Exception('An item required more than $maxItemLength bytes.');
        case WIN32_ERROR.ERROR_NO_MORE_ITEMS:
          return false;
        default:
          throw Exception('unknown error');
      }
    } finally {
      RegCloseKey(hKey);
      free(subKeyForPath);
    }
  }

  /// 根据项的路径获取所有值
  static Map<String, String> getRegedit(String regPath, {int hKeyValue = HKEY_CURRENT_USER}) {
    final hKey = _getRegistryKeyHandle(hKeyValue, regPath);
    final Map<String, String> portsList = <String, String>{};

    /// The index of the value to be retrieved.
    var dwIndex = 0;
    RegistryKeyValuePair? item;
    item = _enumerateKey(hKey, dwIndex);
    while (item != null) {
      portsList[item.key] = item.value;
      dwIndex++;
      item = _enumerateKey(hKey, dwIndex);
    }
    RegCloseKey(hKey);
    return portsList;
  }

  static int _getRegistryKeyHandle(int hive, String key) {
    final phKey = calloc<HANDLE>();
    final lpKeyPath = key.toNativeUtf16();
    try {
      final res = RegOpenKeyEx(hive, lpKeyPath, 0, REG_SAM_FLAGS.KEY_READ, phKey);
      if (res != WIN32_ERROR.ERROR_SUCCESS) {
        throw Exception("Can't open registry key");
      }
      return phKey.value;
    } finally {
      free(phKey);
      free(lpKeyPath);
    }
  }

  static RegistryKeyValuePair? _enumerateKey(int hKey, int index) {
    final lpValueName = wsalloc(MAX_PATH);
    final lpcchValueName = calloc<DWORD>()..value = MAX_PATH;
    final lpType = calloc<DWORD>();
    final lpData = calloc<BYTE>(maxItemLength);
    final lpcbData = calloc<DWORD>()..value = maxItemLength;
    try {
      final status = RegEnumValue(hKey, index, lpValueName, lpcchValueName, nullptr, lpType, lpData, lpcbData);
      switch (status) {
        case WIN32_ERROR.ERROR_SUCCESS:
          {
            // if (lpType.value != REG_SZ) throw Exception('Non-string content.');
            if (lpType.value == REG_VALUE_TYPE.REG_DWORD) {
              return RegistryKeyValuePair(lpValueName.toDartString(), lpData.cast<Uint32>().value.toString());
            }
            if (lpType.value == REG_VALUE_TYPE.REG_SZ) {
              return RegistryKeyValuePair(lpValueName.toDartString(), lpData.cast<Utf16>().toDartString());
            }
            break;
          }
        case WIN32_ERROR.ERROR_MORE_DATA:
          throw Exception('An item required more than $maxItemLength bytes.');
        case WIN32_ERROR.ERROR_NO_MORE_ITEMS:
          return null;
        default:
          throw Exception('unknown error');
      }
    } finally {
      free(lpValueName);
      free(lpcchValueName);
      free(lpType);
      free(lpData);
      free(lpcbData);
    }
    return null;
  }

  static String? _enumerateKeyList(int hKey, int index) {
    final lpValueName = wsalloc(MAX_PATH);
    final lpcchValueName = calloc<DWORD>()..value = MAX_PATH;
    try {
      final status = RegEnumKeyEx(hKey, index, lpValueName, lpcchValueName, nullptr, nullptr, nullptr, nullptr);
      switch (status) {
        case WIN32_ERROR.ERROR_SUCCESS:
          return lpValueName.toDartString();
        case WIN32_ERROR.ERROR_MORE_DATA:
          throw Exception('An item required more than $maxItemLength bytes.');
        case WIN32_ERROR.ERROR_NO_MORE_ITEMS:
          return null;
        default:
          throw Exception('unknown error');
      }
    } finally {
      free(lpValueName);
      free(lpcchValueName);
    }
  }
}
