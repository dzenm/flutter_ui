import 'package:fbl/fbl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../../../config/configs.dart';
import '../../../../entities/medicine.dart';
import '../../../../generated/l10n.dart';
import '../../../../http/api_services.dart';

///
/// Created by a0010 on 2022/4/15 16:23
///
class MedicinePage extends StatefulWidget {
  final String medicineName;

  const MedicinePage({super.key, required this.medicineName});

  @override
  State<StatefulWidget> createState() => _MedicinePageState();
}

class _MedicinePageState extends State<MedicinePage> {
  final String _key = Configs.apiUrlKey;
  List<MedicineEntity> _list = [];

  @override
  void initState() {
    super.initState();

    _getZhongyao();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonBar(
        title: S.of(context).chineseMedicine,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView.builder(
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
    return Html(data: html);
  }

  Future<void> _getZhongyao() async {
    await Future.delayed(const Duration(milliseconds: 300));
    await HttpsClient().request(ApiServices.api(index: 1).getZhongYao(_key, widget.medicineName), success: (data) async {
      _list = (data['newslist'] as List<dynamic>).map((e) => MedicineEntity.fromJson(e)).toList();
      setState(() {});
    });
  }
}
