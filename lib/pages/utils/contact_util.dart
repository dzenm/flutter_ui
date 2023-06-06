

///
/// Created by a0010 on 2023/1/31 10:54
///
class ContactUtil {
  /// 获取所有联系人数据并监听
//   Future<void> getAllContacts(void Function(List<Contact> contacts) callback) async {
//     if (!await FlutterContacts.requestPermission()) {
//       callback([]);
//       return;
//     }
//
//     await _fetchContacts(callback);
//
//     // Listen to DB changes
//     FlutterContacts.addListener(() async {
//       Log.d('Contacts DB changed, fetching contacts');
//       await _fetchContacts(callback);
//     });
//   }
//
//   /// 获取联系人数据（对异常进行捕获）
//   Future<void> _fetchContacts(void Function(List<Contact>) callback) async {
//     try {
//       // First load all contacts without photo
//       // await _loadContacts(false);
//
//       // Next with photo
//       List<Contact> list = await _loadContacts(true);
//       Log.d('fetching contacts success: len=${list.length}');
//       callback(list);
//     } catch (e) {
//       Log.d('fetching contacts failed');
//       callback([]);
//     }
//   }
//
//   /// 加载本地联系人数据
//   Future<List<Contact>> _loadContacts(bool withPhotos) async {
//     if (withPhotos) {
//       return (await FlutterContacts.getContacts(withThumbnail: true)).toList();
//     }
//     return (await FlutterContacts.getContacts()).toList();
//   }
}
