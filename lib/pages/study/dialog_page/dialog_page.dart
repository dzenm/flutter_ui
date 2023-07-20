import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../base/res/app_theme.dart';
import '../../../base/res/local_model.dart';
import '../../../base/widgets/common_dialog.dart';
import '../../../base/widgets/menu_Item.dart';
import '../../../base/widgets/picker/picker_view.dart';

///
/// Created by a0010 on 2023/3/23 09:01
/// 快速页面创建
class DialogPage extends StatefulWidget {
  const DialogPage({super.key});

  @override
  State<StatefulWidget> createState() => _DialogPageState();
}

class _DialogPageState extends State<DialogPage> {
  String _selectedValue = '';
  List<Item> _items = [
    Item(0, title: '数据库'),
    Item(1, title: 'SharedPreference'),
    Item(2, title: '设置'),
    Item(3, title: '清空所有'),
    Item(4, title: '退出'),
  ];

  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch<LocalModel>().theme;
    return Scaffold(
      appBar: AppBar(
        title: Text('弹窗', style: TextStyle(color: Colors.white)),
        actions: [
          /// 弹出式菜单
          PopupMenuButton(
            elevation: 4.0,
            onSelected: (Item item) {
              CommonDialog.showToast(item.title ?? '');
            },
            itemBuilder: (BuildContext context) {
              return _items.map((value) {
                return PopupMenuItem(
                  value: value,
                  child: Row(children: [
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: Icon(Icons.map),
                    ),
                    Text(value.title ?? ''),
                  ]),
                );
              }).toList();
            },
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(children: [
          MaterialButton(
            textColor: Colors.white,
            color: theme.appbar,
            onPressed: () {
              CancelFunc cancel = CommonDialog.loading();
              Future.delayed(Duration(seconds: 1), () => cancel());
            },
            child: Row(children: [_text('加载弹窗(1秒后关闭)')]),
          ),
          SizedBox(height: 8),
          MaterialButton(
            textColor: Colors.white,
            color: theme.appbar,
            onPressed: () => CommonDialog.showPromptDialog(
              context,
              titleString: '立即开通',
              content: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('购买类型：', style: TextStyle(fontSize: 16)),
                  Text('应付金额：￥', style: TextStyle(fontSize: 16)),
                  Text('支付方式：(￥)', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
            child: Row(children: [_text('支付弹窗')]),
          ),
          SizedBox(height: 8),
          MaterialButton(
            textColor: Colors.white,
            color: theme.appbar,
            onPressed: () => CommonDialog.showPromptDialog(
              context,
              titleString: '昵称',
              content: Text('这是设置好的昵称'),
              onPositiveTap: () => CommonDialog.showToast('修改成功'),
            ),
            child: Row(children: [_text('提示弹窗')]),
          ),
          SizedBox(height: 8),
          MaterialButton(
            textColor: Colors.white,
            color: theme.appbar,
            onPressed: () => CommonDialog.showSelectImageBottomSheet(context),
            child: Row(children: [_text('选择图片弹窗')]),
          ),
          SizedBox(height: 8),
          MaterialButton(
            textColor: Colors.white,
            color: theme.appbar,
            onPressed: () => CommonDialog.showListBottomSheet(context, data, (int index) {
              Navigator.pop(context);
            }),
            child: Row(children: [_text('iOS底部列表弹窗')]),
          ),
          SizedBox(height: 8),
          MaterialButton(
            textColor: Colors.white,
            color: theme.appbar,
            onPressed: () => showDialog(
              context: context,
              builder: (BuildContext context) {
                return ListDialog(
                  list: list,
                  onTap: (index) {},
                );
              },
            ),
            child: Row(children: [_text('Material居中列表弹窗')]),
          ),
          SizedBox(height: 8),
          MaterialButton(
            textColor: Colors.white,
            color: theme.appbar,
            onPressed: () => CommonDialog.showAppUpgradeDialog(
              context,
              version: '12',
              desc: ['升级了'],
            ),
            child: Row(children: [_text('升级弹窗')]),
          ),
          SizedBox(height: 8),
          MaterialButton(
            textColor: Colors.white,
            color: theme.appbar,
            onPressed: () => PickerView.showLocation(context, initialItem: ['湖北', '荆门市', '京山县'], onChanged: (results) {
              CommonDialog.showToast('选中的结果: results=$results');
            }),
            child: Row(children: [_text('选择区域弹窗')]),
          ),
          SizedBox(height: 8),
          MaterialButton(
            textColor: Colors.white,
            color: theme.appbar,
            onPressed: () => PickerView.showList(
              context,
              list: ['测试一', '测试二', '测试三', '测试四', '测试五'],
              initialItem: _selectedValue,
              onChanged: (value) {
                _selectedValue = value;
                CommonDialog.showToast('选中的回调: $_selectedValue');
              },
            ),
            child: Row(children: [_text('PickerView控件')]),
          ),
        ]),
      ),
    );
  }

  Widget _text(String text) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(text)]);
  }

  List<String> list = [
    "补材料申请",
    "面签申请",
    "暂停申请",
    "提醒",
  ];

  List<String> data = [
    '设置备注和标签',
    '把她推荐给朋友',
    '设为星标好友',
    '设置朋友圈和视频动态权限',
    '加入黑名单',
    '投诉',
    '添加到桌面',
    '删除',
  ];
}
