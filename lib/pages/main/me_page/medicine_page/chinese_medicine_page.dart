import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ui/base/db/db_base_model.dart';
import 'package:flutter_ui/base/http/api_client.dart';
import 'package:flutter_ui/base/log/log.dart';

///
/// Created by a0010 on 2022/4/15 16:23
///
class ChineseMedicinePage extends StatefulWidget {
  final String medicineName;

  ChineseMedicinePage({required this.medicineName});

  @override
  State<StatefulWidget> createState() => _ChineseMedicinePageState();
}

class _ChineseMedicinePageState extends State<ChineseMedicinePage> {
  final String _key = 'e5c1639a4fc97a080daaff94e08bd1ca';
  List<MedicineEntity> _list = [];

  @override
  void initState() {
    super.initState();

    getZhongyao();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('中药药方', style: TextStyle(color: Colors.white)),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _list.length,
          itemBuilder: (BuildContext context, int index) {
            MedicineEntity medicine = _list[index];
            return _buildMedicineContent(medicine.content ?? '');
          },
        ),
      ),
    );
  }

  Widget _buildMedicineContent(String html) {
    return Text(html);
    // return Html(data: html);
  }

  void getZhongyao() {
    ApiClient.getInstance.request(api(1).getZhongYao(_key, widget.medicineName), success: (data) {
      Log.i('len=${_list.length}');
      _list = (data as List<dynamic>).map((e) => MedicineEntity.fromJson(e)).toList();
      setState(() {});
    });
  }
}

class MedicineEntity extends DBBaseModel {
  String? title;
  String? content;

  MedicineEntity();

  MedicineEntity.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    content = json['content'];
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'content': content,
      };

  @override
  MedicineEntity fromJson(Map<String, dynamic> json) => MedicineEntity.fromJson(json);
}
