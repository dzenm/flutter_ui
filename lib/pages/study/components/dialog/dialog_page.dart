import 'package:bot_toast/bot_toast.dart';
import 'package:fbl/fbl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  final List<Item> _items = [
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
      appBar: CommonBar(
        title: '弹窗',
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
                    const SizedBox(
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
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(children: [
            MaterialButton(
              textColor: Colors.white,
              color: theme.appbar,
              onPressed: () {
                CancelFunc cancel = CommonDialog.loading();
                Future.delayed(const Duration(seconds: 1), () => cancel());
              },
              child: Row(children: [_text('加载弹窗(1秒后关闭)')]),
            ),
            const SizedBox(height: 8),
            MaterialButton(
              textColor: Colors.white,
              color: theme.appbar,
              onPressed: () => CommonDialog.showPromptDialog(
                context,
                titleString: '立即开通',
                content: const Column(
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
            const SizedBox(height: 8),
            MaterialButton(
              textColor: Colors.white,
              color: theme.appbar,
              onPressed: () => CommonDialog.showCustomDialog(
                context,
                child: Container(
                  padding: const EdgeInsets.all(32),
                  child: const Column(
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
              ),
              child: Row(children: [_text('自定义弹窗')]),
            ),
            const SizedBox(height: 8),
            MaterialButton(
              textColor: Colors.white,
              color: theme.appbar,
              onPressed: () => CommonDialog.showPromptDialog(
                context,
                titleString: '昵称',
                content: const Text('这是设置好的昵称'),
                onPositiveTap: () {
                  CommonDialog.showPromptDialog(
                    context,
                    titleString: '昵称',
                    content: const Text('这是设置好的昵称'),
                    onPositiveTap: () {
                      CommonDialog.showToast('修改成功');
                    },
                  );
                  CommonDialog.showToast('修改成功');
                },
              ),
              child: Row(children: [_text('提示弹窗')]),
            ),
            const SizedBox(height: 8),
            MaterialButton(
              textColor: Colors.white,
              color: theme.appbar,
              onPressed: () => CommonDialog.showSelectImageBottomSheet(context),
              child: Row(children: [_text('选择图片弹窗')]),
            ),
            const SizedBox(height: 8),
            MaterialButton(
              textColor: Colors.white,
              color: theme.appbar,
              onPressed: () => CommonDialog.showListBottomSheet(context, data, (int index) {
                Navigator.pop(context);
              }),
              child: Row(children: [_text('iOS底部列表弹窗')]),
            ),
            const SizedBox(height: 8),
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
            const SizedBox(height: 8),
            MaterialButton(
              textColor: Colors.white,
              color: theme.appbar,
              onPressed: () {
                AppVersionEntity version = AppVersionEntity(
                  upgradeUid: '1',
                  title: '测试',
                  content: '不知道更新了什么',
                  url: 'https://ucdl.25pp.com/fs08/2023/08/14/6/110_612a0e357913d43e504044debbddff35.apk?cc=850312032&nrd=0&f'
                      'name=%E7%99%BE%E5%BA%A6%E5%9C%B0%E5%9B%BE&productid=&packageid=601220125&pkg=com.baidu.BaiduMap&vcode=1'
                      '277&yingid=pp_wap_ppcn&vh=7641e6ccaaae10b280b634ba8e225deb&sf=133168324&sh=10&appid=29805&apprd=',
                  newVersion: '1.2.0',
                );
                UpgradeView.show(context, version: version);
              },
              child: Row(children: [_text('升级弹窗')]),
            ),
            const SizedBox(height: 8),
            MaterialButton(
              textColor: Colors.white,
              color: theme.appbar,
              onPressed: () => PickerView.showLocation(context, initialItem: ['湖北', '荆门市', '京山县'], onChanged: (results) {
                CommonDialog.showToast('选中的结果: results=$results');
              }),
              child: Row(children: [_text('选择区域弹窗')]),
            ),
            const SizedBox(height: 8),
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
            const SizedBox(height: 8),
            MaterialButton(
              textColor: Colors.white,
              color: theme.appbar,
              onPressed: () => CommonDialog.showCustomDialog(
                context,
                transitionType: TransitionType.left,
                pageBuilder: (c, a, s) => AlertDialog(
                  title: const Text('Dialog Show'),
                  content: const Text('this is a dialog'),
                  actions: [
                    InkWell(
                      child: const Text('confirm'),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    InkWell(
                      child: const Text('cancel'),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              child: Row(children: [_text('从左边进从左边出的动画')]),
            ),
            const SizedBox(height: 8),
            MaterialButton(
              textColor: Colors.white,
              color: theme.appbar,
              onPressed: () => CommonDialog.showCustomDialog(
                context,
                transitionType: TransitionType.top,
                pageBuilder: (c, a, s) => AlertDialog(
                  title: const Text('Dialog Show'),
                  content: const Text('this is a dialog'),
                  actions: [
                    InkWell(
                      child: const Text('confirm'),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    InkWell(
                      child: const Text('cancel'),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              child: Row(children: [_text('从上面进从上面出的动画')]),
            ),
            const SizedBox(height: 8),
            MaterialButton(
              textColor: Colors.white,
              color: theme.appbar,
              onPressed: () => CommonDialog.showCustomDialog(
                context,
                transitionType: TransitionType.right,
                pageBuilder: (c, a, s) => AlertDialog(
                  title: const Text('Dialog Show'),
                  content: const Text('this is a dialog'),
                  actions: [
                    InkWell(
                      child: const Text('confirm'),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    InkWell(
                      child: const Text('cancel'),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              child: Row(children: [_text('从右边进从右边出的动画')]),
            ),
            const SizedBox(height: 8),
            MaterialButton(
              textColor: Colors.white,
              color: theme.appbar,
              onPressed: () => CommonDialog.showCustomDialog(
                context,
                transitionType: TransitionType.bottom,
                pageBuilder: (c, a, s) => AlertDialog(
                  title: const Text('Dialog Show'),
                  content: const Text('this is a dialog'),
                  actions: [
                    InkWell(
                      child: const Text('confirm'),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    InkWell(
                      child: const Text('cancel'),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              child: Row(children: [_text('从下面进从下面出的动画')]),
            ),
            const SizedBox(height: 8),
            MaterialButton(
              textColor: Colors.white,
              color: theme.appbar,
              onPressed: () => CommonDialog.showCustomDialog(
                context,
                transitionType: TransitionType.inLeftOutRight,
                pageBuilder: (c, a, s) => AlertDialog(
                  title: const Text('Dialog Show'),
                  content: const Text('this is a dialog'),
                  actions: [
                    InkWell(
                      child: const Text('confirm'),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    InkWell(
                      child: const Text('cancel'),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              child: Row(children: [_text('从左边进从右边出的动画')]),
            ),
            const SizedBox(height: 8),
            MaterialButton(
              textColor: Colors.white,
              color: theme.appbar,
              onPressed: () => CommonDialog.showCustomDialog(
                context,
                transitionType: TransitionType.inTopOutBottom,
                pageBuilder: (c, a, s) => AlertDialog(
                  title: const Text('Dialog Show'),
                  content: const Text('this is a dialog'),
                  actions: [
                    InkWell(
                      child: const Text('confirm'),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    InkWell(
                      child: const Text('cancel'),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              child: Row(children: [_text('从上面进从下面出的动画')]),
            ),
            const SizedBox(height: 8),
            MaterialButton(
              textColor: Colors.white,
              color: theme.appbar,
              onPressed: () => CommonDialog.showCustomDialog(
                context,
                transitionType: TransitionType.inRightOutLeft,
                pageBuilder: (c, a, s) => AlertDialog(
                  title: const Text('Dialog Show'),
                  content: const Text('this is a dialog'),
                  actions: [
                    InkWell(
                      child: const Text('confirm'),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    InkWell(
                      child: const Text('cancel'),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              child: Row(children: [_text('从右边进从左边出的动画')]),
            ),
            const SizedBox(height: 8),
            MaterialButton(
              textColor: Colors.white,
              color: theme.appbar,
              onPressed: () => CommonDialog.showCustomDialog(
                context,
                transitionType: TransitionType.inBottomOutTop,
                pageBuilder: (c, a, s) => AlertDialog(
                  title: const Text('Dialog Show'),
                  content: const Text('this is a dialog'),
                  actions: [
                    InkWell(
                      child: const Text('confirm'),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    InkWell(
                      child: const Text('cancel'),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              child: Row(children: [_text('从下面进从上面出的动画')]),
            ),
            const SizedBox(height: 8),
            MaterialButton(
              textColor: Colors.white,
              color: theme.appbar,
              onPressed: () => CommonDialog.showCustomDialog(
                context,
                transitionType: TransitionType.scale,
                pageBuilder: (c, a, s) => AlertDialog(
                  title: const Text('Dialog Show'),
                  content: const Text('this is a dialog'),
                  actions: [
                    InkWell(
                      child: const Text('confirm'),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    InkWell(
                      child: const Text('cancel'),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              child: Row(children: [_text('从小缩放到正常比例动画')]),
            ),
            const SizedBox(height: 8),
            MaterialButton(
              textColor: Colors.white,
              color: theme.appbar,
              onPressed: () => CommonDialog.showCustomDialog(
                context,
                transitionType: TransitionType.fade,
                pageBuilder: (c, a, s) => AlertDialog(
                  title: const Text('Dialog Show'),
                  content: const Text('this is a dialog'),
                  actions: [
                    InkWell(
                      child: const Text('confirm'),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    InkWell(
                      child: const Text('cancel'),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              child: Row(children: [_text('透明度变化动画')]),
            ),
            const SizedBox(height: 8),
            MaterialButton(
              textColor: Colors.white,
              color: theme.appbar,
              onPressed: () => CommonDialog.showCustomDialog(
                context,
                transitionType: TransitionType.rotation,
                pageBuilder: (c, a, s) => AlertDialog(
                  title: const Text('Dialog Show'),
                  content: const Text('this is a dialog'),
                  actions: [
                    InkWell(
                      child: const Text('confirm'),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    InkWell(
                      child: const Text('cancel'),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              child: Row(children: [_text('旋转动画')]),
            ),
            const SizedBox(height: 8),
            MaterialButton(
              textColor: Colors.white,
              color: theme.appbar,
              onPressed: () => CommonDialog.showCustomDialog(
                context,
                transitionType: TransitionType.size,
                pageBuilder: (c, a, s) => AlertDialog(
                  title: const Text('Dialog Show'),
                  content: const Text('this is a dialog'),
                  actions: [
                    InkWell(
                      child: const Text('confirm'),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    InkWell(
                      child: const Text('cancel'),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              child: Row(children: [_text('Size')]),
            ),
          ]),
        ),
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
