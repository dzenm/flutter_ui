import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

import 'contact_util.dart';

///
/// Created by a0010 on 2023/1/31 11:48
///
class LocalContactModel with ChangeNotifier {
  List<Contact> _contacts = [];

  Future<List<Contact>?> getContacts() async {
    await ContactUtil().getAllContacts((contacts) {
      _contacts = contacts;
      notifyListeners();
    });
    return _contacts;
  }

  Future<Contact> updateContact(Contact contact) async {
    int index = _contacts.indexOf(contact);
    Contact res = contact;
    if (index != -1) {
      _contacts[index] = contact;
      res = await contact.update();
    }
    notifyListeners();
    return res;
  }

  Future<void> deleteContact(Contact contact) async {
    int index = _contacts.indexOf(contact);
    if (index != -1) {
      _contacts.remove(contact);
      await contact.delete();
    }
    notifyListeners();
  }

  Future<Contact?> getContactByName(String name) async {
    if (_contacts.isEmpty) {
      await getContacts();
    }
    var res = _contacts.where((element) => element.name.last == name);
    if (res.isNotEmpty) {
      return res.first;
    }
    return null;
  }

  Future<bool> existContactPhone(String name, String phone) async {
    Contact? contact = await getContactByName(name);
    List<Phone> phones = contact?.phones ?? [];
    for (int i = 0; i < phones.length; i++) {
      if (phones[i].number == phone) return true;
    }
    return false;
  }

}
