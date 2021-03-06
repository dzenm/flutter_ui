import 'dart:convert';

import 'package:azlistview/azlistview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ui/base/res/assets.dart';
import 'package:flutter_ui/base/res/strings.dart';
import 'package:flutter_ui/base/widgets/common_dialog.dart';
import 'package:flutter_ui/base/widgets/state_view.dart';
import 'package:lpinyin/lpinyin.dart';

class CitySelectedPage extends StatefulWidget {
  CitySelectedPage();

  @override
  State<StatefulWidget> createState() => _CitySelectedPageState();
}

class _CitySelectedPageState extends State<CitySelectedPage> {
  static const String _TOP = '↑';
  static const String _STAR = '★';
  static const String _END = '#';

  List<CityModel> _cityList = [];
  List<CityModel> _hotCityList = [
    CityModel(name: '北京市', tagIndex: _STAR),
    CityModel(name: '广州市', tagIndex: _STAR),
    CityModel(name: '成都市', tagIndex: _STAR),
    CityModel(name: '深圳市', tagIndex: _STAR),
    CityModel(name: '杭州市', tagIndex: _STAR),
    CityModel(name: '武汉市', tagIndex: _STAR),
  ];
  StateController _controller = StateController();

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(milliseconds: 500), () {
      loadData();
    });
  }

  void loadData() async {
    //加载城市列表
    await rootBundle.loadString(Assets.file('china.json')).then((value) {
      _cityList.clear();
      Map countyMap = json.decode(value);
      List list = countyMap['china'];
      list.forEach((v) => _cityList.add(CityModel.fromJson(v)));
      _handleCityPinyin(_cityList);
      setState(() => _controller.loadComplete());
    });
  }

  void _handleCityPinyin(List<CityModel> list) {
    if (list.isEmpty) return;
    for (int i = 0, length = list.length; i < length; i++) {
      String pinyin = PinyinHelper.getPinyinE(list[i].name);
      String tag = pinyin.substring(0, 1).toUpperCase();
      list[i].namePinyin = pinyin;
      list[i].tagIndex = RegExp('[A-Z]').hasMatch(tag) ? tag : _END;
    }
    // A-Z sort.
    SuspensionUtil.sortListBySuspensionTag(list);

    // add hot_cityList.
    _cityList.insertAll(0, _hotCityList);

    // show sus tag.
    SuspensionUtil.setShowSuspensionStatus(_cityList);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text(S.of(context).citySelected, style: TextStyle(color: Colors.white))),
      body: SafeArea(
        child: StateView(
          controller: _controller,
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 15.0),
                height: 50.0,
                child: Text("当前城市: 成都市"),
              ),
              Expanded(
                child: AzListView(
                  data: _cityList,
                  itemCount: _cityList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return getListItem(_cityList[index]);
                  },
                  padding: EdgeInsets.zero,
                  susItemBuilder: (BuildContext context, int index) {
                    CityModel model = _cityList[index];
                    if (_TOP == model.getSuspensionTag()) {
                      return Container();
                    }
                    return getSusItem(_cityList[index].getSuspensionTag());
                  },
                  physics: BouncingScrollPhysics(),
                  indexBarData: [_TOP, _STAR, ...kIndexBarData],
                  indexBarOptions: IndexBarOptions(
                    needRebuild: true,
                    ignoreDragCancel: true,
                    downTextStyle: TextStyle(fontSize: 12, color: Colors.white),
                    downItemDecoration: BoxDecoration(shape: BoxShape.circle, color: Colors.green),
                    indexHintWidth: 120 / 2,
                    indexHintHeight: 100 / 2,
                    indexHintDecoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(Assets.icon('ic_bubble_gray.png')),
                        fit: BoxFit.contain,
                      ),
                    ),
                    indexHintAlignment: Alignment.centerRight,
                    indexHintChildAlignment: Alignment(-0.25, 0.0),
                    indexHintOffset: Offset(-20, 0),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget getSusItem(String tag, {double susHeight = 40}) {
    if (tag == _STAR) {
      tag = '$_STAR 热门城市';
    }
    return Container(
      height: susHeight,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(left: 16.0),
      color: Color(0xFFF3F4F5),
      alignment: Alignment.centerLeft,
      child: Text(
        tag,
        softWrap: false,
        style: TextStyle(fontSize: 14.0, color: Color(0xFF666666)),
      ),
    );
  }

  Widget getListItem(CityModel model) {
    return ListTile(
      title: Text(model.name),
      onTap: () {
        showToast('onItemClick : ${model.toString()}');
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
