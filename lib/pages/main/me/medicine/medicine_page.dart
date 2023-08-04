import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../../../base/http/https_client.dart';
import '../../../../base/log/build_config.dart';
import '../../../../base/widgets/common_bar.dart';
import '../../../../entities/medicine_entity.dart';
import '../../../../generated/l10n.dart';

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
  final String _key = BuildConfig.medicineKey;
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

  void _getZhongyao() {
    HttpsClient.instance.request(api(index: 1).getZhongYao(_key, widget.medicineName), success: (data) {
      _list = (data['newslist'] as List<dynamic>).map((e) => MedicineEntity.fromJson(e)).toList();
      setState(() {});
    });
  }
}
