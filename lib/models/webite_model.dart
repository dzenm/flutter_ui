
import 'package:flutter/material.dart';
import 'package:flutter_ui/entities/website_entity.dart';

class WebsiteModel extends ChangeNotifier {
  WebsiteEntity _entity = WebsiteEntity();

  /// 数据库对应的所有数据
  List<WebsiteEntity> _allWebsiteList = [];

  WebsiteModel() {
    _getAllWebsites();
  }

  /// 获取所有的网站数据
  void _getAllWebsites() async {
    List list = await _entity.where(_entity);
    List<WebsiteEntity> articles = list.map((e) => e as WebsiteEntity).toList();
    _allWebsiteList = articles;
    notifyListeners();
  }

  /// 所有的网站数据
  List<WebsiteEntity> get allWebsite => _allWebsiteList;

  WebsiteEntity? getWebsite(int index) => allWebsite.isEmpty ? null : allWebsite[index];

  void updateWebsites(List<WebsiteEntity> websites) {
    websites.forEach((website) => _handleWebsite(website));
    notifyListeners();
  }

  void updateWebsite(WebsiteEntity website) {
    _handleWebsite(website);
    notifyListeners();
  }

  /// 处理网站数据
  Future<void> _handleWebsite(WebsiteEntity website) async {
    int index = _allWebsiteList.indexOf(website);
    if (index != -1) {
      _allWebsiteList.insert(index, website);
      _entity.update(website); // 更新DB中的website数据
    } else {
      _allWebsiteList.add(website);
      _entity.insert(website); // 保存为DB中的website数据
    }
  }

  void clear() {
    _allWebsiteList.clear();
    notifyListeners();
  }
}
