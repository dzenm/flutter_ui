import 'dart:convert';

import 'package:azlistview/azlistview.dart';
import 'package:fbl/fbl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lpinyin/lpinyin.dart';

///
/// Created by a0010 on 2024/12/25 14:57
/// 城市选择页面
class CitySelectedPage extends StatelessWidget {
  const CitySelectedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: const CommonBar(title: '城市选择'),
      body: SafeArea(
        child: FutureBuilder<List<CityModel>>(
          future: CitySelectedView.loadAssetsData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            return CitySelectedView(
              cities: snapshot.requireData,
              onTap: (model) {
                Navigator.pop(context, model);
              },
            );
          },
        ),
      ),
    );
  }
}

/// 城市选择布局
class CitySelectedView extends StatefulWidget {
  final List<CityModel> cities;
  final List<String>? hotCities;
  final ValueChanged<CityModel>? onTap;

  const CitySelectedView({
    super.key,
    required this.cities,
    this.hotCities,
    this.onTap,
  });

  /// 加载assets的数据
  static Future<List<CityModel>> loadAssetsData() async {
    List<CityModel> cityList = [];
    //加载城市列表
    String jsonString = await rootBundle.loadString(Assets.chinaJson);
    Map countyMap = json.decode(jsonString);
    List list = countyMap['china'];
    for (var map in list) {
      cityList.add(CityModel.fromJson(map));
    }
    return cityList;
  }

  @override
  State<StatefulWidget> createState() => _CitySelectedViewState();
}

class _CitySelectedViewState extends State<CitySelectedView> {
  static const String _top = '↑';
  static const String _star = '★';
  static const String _end = '#';

  /// 城市列表
  final List<CityModel> _cities = [];

  @override
  void initState() {
    super.initState();

    _cities.addAll(widget.cities);
    _handleCityPinyin();
  }

  /// 处理城市列表，按拼音首字母排序
  void _handleCityPinyin() {
    if (_cities.isEmpty) return;
    for (int i = 0, length = _cities.length; i < length; i++) {
      String pinyin = PinyinHelper.getPinyinE(_cities[i].name);
      String tag = pinyin.substring(0, 1).toUpperCase();
      _cities[i].namePinyin = pinyin;
      _cities[i].tagIndex = RegExp('[A-Z]').hasMatch(tag) ? tag : _end;
    }
    // A-Z sort.
    SuspensionUtil.sortListBySuspensionTag(_cities);

    List<String> hotList = widget.hotCities ?? ['北京市', '广州市', '成都市', '深圳市', '杭州市', '武汉市'];
    // add hot_cityList.
    List<CityModel> hotCities = hotList.map((city) => CityModel(name: city, tagIndex: _star)).toList();
    _cities.insertAll(0, hotCities);

    // show sus tag.
    SuspensionUtil.setShowSuspensionStatus(_cities);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 15.0),
        height: 50.0,
        child: const Text("当前城市: 成都市"),
      ),
      Expanded(
        child: AzListView(
          data: _cities,
          itemCount: _cities.length,
          itemBuilder: (BuildContext context, int index) {
            return _buildListItem(_cities[index]);
          },
          padding: EdgeInsets.zero,
          susItemBuilder: (BuildContext context, int index) {
            CityModel model = _cities[index];
            if (_top == model.getSuspensionTag()) {
              return Container();
            }
            return _buildSusItem(_cities[index].getSuspensionTag());
          },
          physics: const BouncingScrollPhysics(),
          indexBarData: const [_top, _star, ...kIndexBarData],
          indexBarOptions: const IndexBarOptions(
            needRebuild: true,
            ignoreDragCancel: true,
            downTextStyle: TextStyle(fontSize: 12, color: Colors.white),
            downItemDecoration: BoxDecoration(shape: BoxShape.circle, color: Colors.green),
            indexHintWidth: 120 / 2,
            indexHintHeight: 100 / 2,
            indexHintDecoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(Assets.icBubbleGray),
                fit: BoxFit.contain,
              ),
            ),
            indexHintAlignment: Alignment.centerRight,
            indexHintChildAlignment: Alignment(-0.25, 0.0),
            indexHintOffset: Offset(-20, 0),
          ),
        ),
      )
    ]);
  }

  Widget _buildSusItem(String tag, {double susHeight = 40}) {
    if (tag == _star) {
      tag = '$_star 热门城市';
    }
    return Container(
      height: susHeight,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.only(left: 16.0),
      color: const Color(0xFFF3F4F5),
      alignment: Alignment.centerLeft,
      child: Text(
        tag,
        softWrap: false,
        style: const TextStyle(fontSize: 14.0, color: Color(0xFF666666)),
      ),
    );
  }

  Widget _buildListItem(CityModel model) {
    return ListTile(
      title: Text(model.name),
      onTap: () {
        if (widget.onTap != null) {
          widget.onTap!(model);
        }
      },
    );
  }
}

class CityModel extends ISuspensionBean {
  String name;
  String? tagIndex;
  String? namePinyin;

  CityModel({
    required this.name,
    this.tagIndex,
    this.namePinyin,
  });

  CityModel.fromJson(Map<String, dynamic> json) : name = json['name'];

  Map<String, dynamic> toJson() => {'name': name};

  @override
  String getSuspensionTag() => tagIndex ?? '*';

  @override
  String toString() => json.encode(this);
}
