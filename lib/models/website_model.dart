import 'package:flutter/material.dart';

import '../entities/website_entity.dart';

///
/// Created by a0010 on 2022/7/28 10:56
/// Provider中共享的网站数据
class WebsiteModel with ChangeNotifier {
  final WebsiteEntity _entity = WebsiteEntity();

  /// 数据库对应的所有数据
  List<WebsiteEntity> _websites = [];

  /// 初始化网站数据，从数据库获取所有的网站数据
  Future<void> init() async {
    List list = await _entity.where(_entity);
    List<WebsiteEntity> articles = list.map((e) => e as WebsiteEntity).toList();
    _websites = articles;
    notifyListeners();
  }

  /// 所有的网站数据
  List<WebsiteEntity> get websites => _websites;

  /// 根据索引获取网站数据
  WebsiteEntity? getWebsite(int index) => websites.isEmpty ? null : websites[index];

  /// 更新网站列表数据
  void updateWebsites(List<WebsiteEntity> websites) {
    for (var website in websites) {
      _handleWebsite(website);
    }
    notifyListeners();
  }

  /// 更新单个网站数据
  void updateWebsite(WebsiteEntity website) {
    _handleWebsite(website);
    notifyListeners();
  }

  /// 处理网站数据
  void _handleWebsite(WebsiteEntity website) {
    int index = _websites.indexWhere((web) => web.id == website.id);
    if (index == -1) {
      _websites.add(website);
      _entity.insert(website); // 保存为DB中的website数据
    } else {
      _websites[index] = website;
      _entity.update(website); // 更新DB中的website数据
    }
  }

  /// 清空数据
  void clear() {
    _websites.clear();
    notifyListeners();
  }
}
