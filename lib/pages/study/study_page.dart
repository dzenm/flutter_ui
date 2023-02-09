import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ui/base/channels/native_channels.dart';
import 'package:flutter_ui/base/log/log.dart';
import 'package:flutter_ui/base/model/local_model.dart';
import 'package:flutter_ui/base/res/strings.dart';
import 'package:flutter_ui/base/res/theme/app_theme.dart';
import 'package:flutter_ui/base/router/route_manager.dart';
import 'package:flutter_ui/base/widgets/common_dialog.dart';
import 'package:flutter_ui/base/widgets/picker_list_view.dart';
import 'package:flutter_ui/base/widgets/custom_popup_dialog.dart';
import 'package:flutter_ui/base/widgets/tap_layout.dart';
import 'package:provider/provider.dart';

import 'city_page/city_page.dart';
import 'convert_page/convert_page.dart';
import 'drag_list_page/drag_list_page.dart';
import 'float_navigation_page/float_navigation_page.dart';
import 'http_page/http_page.dart';
import 'image_editor/image_editor_page.dart';
import 'keyword_board/keyword_board_page.dart';
import 'list_page/list_page.dart';
import 'load_image_page/load_image_page.dart';
import 'qr_page/qr_page.dart';
import 'router/router_page.dart';
import 'setting_page/setting_page.dart';
import 'state_page/state_page.dart';
import 'text_page/text_page.dart';
import 'video_page/video_page.dart';

///
/// Created by a0010 on 2022/11/3 16:03
///
class StudyPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> {
  String? _selectedItem;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: Text(S.of(context).studyMainPage),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(children: childrenButtons()),
        ),
      ),
    );
  }

  List<Widget> childrenButtons() {
    AppTheme appTheme = context.watch<LocalModel>().appTheme;
    return [
      SizedBox(height: 16),
      CustomPopupView(
        direction: PopupDirection.top,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        width: 160,
        elevation: 5,
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5.0, offset: Offset(2.0, 2.0))],
        barrierColor: const Color(0x01FFFFFF),
        child: Container(
          width: 200,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: appTheme.primary,
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          child: Text('展示Dialog'),
        ),
        popupDialogBuilder: (context) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text('PopupWindow 测试'),
          );
        },
      ),
      SizedBox(height: 8),
      MaterialButton(
        child: _text(S.of(context).textAndInput),
        textColor: Colors.white,
        color: appTheme.primary,
        onPressed: () => RouteManager.push(context, TextPage()),
      ),
      SizedBox(height: 8),
      MaterialButton(
        child: _text(S.of(context).navigationBar),
        textColor: Colors.white,
        color: appTheme.primary,
        onPressed: () => RouteManager.push(context, FloatNavigationPage()),
      ),
      SizedBox(height: 8),
      MaterialButton(
        child: _text(S.of(context).charConvert),
        textColor: Colors.white,
        color: appTheme.primary,
        onPressed: () => RouteManager.push(context, ConvertPage()),
      ),
      SizedBox(height: 8),
      MaterialButton(
        child: _text(S.of(context).httpRequest),
        textColor: Colors.white,
        color: appTheme.primary,
        onPressed: () => RouteManager.push(context, HTTPListPage()),
      ),
      SizedBox(height: 8),
      MaterialButton(
        child: _text(S.of(context).listAndRefresh),
        textColor: Colors.white,
        color: appTheme.primary,
        onPressed: () => RouteManager.push(context, ListPage()),
      ),
      SizedBox(height: 8),
      MaterialButton(
        child: _text(S.of(context).dragList),
        textColor: Colors.white,
        color: appTheme.primary,
        onPressed: () => RouteManager.push(context, DragListPage()),
      ),
      SizedBox(height: 8),
      MaterialButton(
        child: _text(S.of(context).videoPlay),
        textColor: Colors.white,
        color: appTheme.primary,
        onPressed: () => RouteManager.push(context, VideoPage()),
      ),
      SizedBox(height: 8),
      MaterialButton(
        child: _text(S.of(context).qr),
        textColor: Colors.white,
        color: appTheme.primary,
        onPressed: () => RouteManager.push(context, QRPage()),
      ),
      SizedBox(height: 8),
      MaterialButton(
        child: _text(S.of(context).citySelected),
        textColor: Colors.white,
        color: appTheme.primary,
        onPressed: () => RouteManager.push(context, CitySelectedPage()),
      ),
      SizedBox(height: 8),
      MaterialButton(
        child: _text(S.of(context).setting),
        textColor: Colors.white,
        color: appTheme.primary,
        onPressed: () => RouteManager.push(context, SettingPage()),
      ),
      SizedBox(height: 8),
      MaterialButton(
        child: _text(S.of(context).state),
        textColor: Colors.white,
        color: appTheme.primary,
        onPressed: () => RouteManager.push(context, StatePage()),
      ),
      SizedBox(height: 8),
      MaterialButton(
        child: _text(S.of(context).keyword),
        textColor: Colors.white,
        color: appTheme.primary,
        onPressed: () => RouteManager.push(context, KeywordBoardPage()),
      ),
      SizedBox(height: 8),
      MaterialButton(
        child: _text(S.of(context).nav),
        textColor: Colors.white,
        color: appTheme.primary,
        onPressed: () => NativeChannels.startHomeActivity(),
      ),
      SizedBox(height: 8),
      MaterialButton(
        child: _text(S.of(context).loadImage),
        textColor: Colors.white,
        color: appTheme.primary,
        onPressed: () => RouteManager.push(context, LoadImagePage()),
      ),
      SizedBox(height: 8),
      MaterialButton(
        child: _text(S.of(context).userContact),
        textColor: Colors.white,
        color: appTheme.primary,
        onPressed: () => {},
        // onPressed: () => RouteManager.push(context, PeopleListPage()),
      ),
      SizedBox(height: 8),
      MaterialButton(
        child: _text(S.of(context).listDialog),
        textColor: Colors.white,
        color: appTheme.primary,
        onPressed: () => showListDialog(
          context: context,
          selectedItem: _selectedItem,
          data: ['测试一', '测试二', '测试三', '测试四', '测试五'],
          onSelectedChanged: (item) {
            _selectedItem = item;
            Log.d('选中的回调: $_selectedItem');
          },
        ),
      ),
      SizedBox(height: 8),
      MaterialButton(
        child: _text(S.of(context).upgradeDialog),
        textColor: Colors.white,
        color: appTheme.primary,
        onPressed: () => showAppUpgradeDialog(
          context,
          version: '12',
          desc: ['升级了'],
        ),
      ),
      SizedBox(height: 8),
      MaterialButton(
        child: _text(S.of(context).router),
        textColor: Colors.white,
        color: appTheme.primary,
        onPressed: () => RouteManager.push(context, RouterPage()),
      ),
      SizedBox(height: 16),
    ];
  }

  Widget _text(String text) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(text)]);
  }
}
