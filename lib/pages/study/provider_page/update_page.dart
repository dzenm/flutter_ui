import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ui/base/log/log.dart';
import 'package:flutter_ui/base/route/route_manager.dart';
import 'package:flutter_ui/base/utils/str_util.dart';
import 'package:flutter_ui/base/widgets/single_edit_layout.dart';
import 'package:flutter_ui/base/widgets/single_text_layout.dart';
import 'package:flutter_ui/base/widgets/tap_layout.dart';
import 'package:flutter_ui/pages/study/study_model.dart';
import 'package:provider/provider.dart';

import '../../../base/widgets/picker/picker_view.dart';

///
/// Created by a0010 on 2023/8/31 17:00
///

class UpdatePage extends StatefulWidget {
  final int? id;

  const UpdatePage({super.key, required this.id});

  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
   User? _user;

  @override
  void initState() {
    super.initState();
    _user = context.read<StudyModel>().getUser(widget.id);
    Log.d('获取user=${_user?.toJson()}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('修改数据', style: TextStyle(color: Colors.white)),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SingleEditLayout(
                  title: '用户名',
                  initialText: '${_user?.username}',
                  onChanged: (value) {
                    _user?.username = value;
                  },
                ),
                SingleEditLayout(
                  title: '年龄',
                  initialText: '${_user?.age}',
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _user?.age = StrUtil.parseInt(value);
                  },
                ),
                TapLayout(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  onTap: () => PickerView.showList(
                    context,
                    list: ['男', '女'],
                    initialItem: _user?.sex == 1 ? '男' : '女',
                    onChanged: (value) {
                      _user?.sex = value == '男' ? 1 : 0;
                    },
                  ),
                  child: SingleTextLayout(
                    title: '性别',
                    fontSize: 16,
                    text: _user?.sex == 1 ? '男' : '女',
                  ),
                ),
                SingleEditLayout(
                  title: '地址',
                  initialText: '${_user?.address}',
                  onChanged: (value) {
                    _user?.address = value;
                  },
                ),
                SingleEditLayout(
                  title: '手机号',
                  initialText: '${_user?.phone}',
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _user?.phone = value;
                  },
                ),
                MaterialButton(
                  textColor: Colors.white,
                  color: Colors.blue,
                  onPressed: () {
                    context.read<StudyModel>().updateUser(User.fromJson(_user!.toJson()));
                    RouteManager.pop(context);
                  },
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('保存'),
                  ]),
                ),
              ]),
            )
          ]),
        ),
      ),
    );
  }
}
