import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ui/base/widgets/keyboard/custom_keyword_board.dart';
import 'package:flutter_ui/base/widgets/tap_layout.dart';

typedef DefaultView = Widget Function(int index);

Widget _defaultView(int index, int len) {
  // if (index < len - 1) {
  //   return Column(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: [
  //       Offstage(
  //         offstage: !showEnergy,
  //         child: Icon(Icons.error, color: Color(0xFF649DAD)),
  //       ),
  //       Text(
  //         isEnergyEmpty ? '新能源' : widget.list[index],
  //         style: TextStyle(
  //           fontSize: isEnergyEmpty ? 10 : 14,
  //           color: showEnergy ? Color(0xFF649DAD) : Colors.grey.shade400,
  //         ),
  //       ),
  //     ],
  //   );
  // }
  return Container(
    child: Text(''),
  );
}

class LicenseView extends StatefulWidget {
  final List<String> list;
  final LicenseController controller;
  final DefaultView? defaultView;

  LicenseView({
    required this.list,
    required this.controller,
    this.defaultView,
  });

  @override
  State<StatefulWidget> createState() => _LicenseViewState();
}

class _LicenseViewState extends State<LicenseView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: Stack(
        children: [
          TextField(
            textAlign: TextAlign.center,
            keyboardType: CustomKeywordBoard.license,
            cursorWidth: 0,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              textBaseline: TextBaseline.alphabetic,
            ),
            onChanged: (v) {
              setState(() {});
            },
          ),
          ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.list.length,
            itemBuilder: (context, index) {
              return _buildItem(index);
            },
          )
        ],
      ),
    );
  }

  Widget _buildItem(int index) {
    int len = widget.list.length;
    bool showEnergy = (index == len - 1);
    return TapLayout(
      width: 36,
      height: 50,
      foreground: Colors.transparent,
      borderRadius: BorderRadius.all(Radius.circular(8)),
      background: widget.controller.select == index ? Colors.grey.shade200 : Colors.white,
      border: Border.all(color: Colors.grey.shade300, width: 0.5),
      margin: EdgeInsets.symmetric(horizontal: 2),
      onTap: () {
        if (widget.controller.select < widget.list.length) {
          setState(() => widget.controller.setSelect(index));
        }
      },
      child: Text(widget.list[index], style: TextStyle(color: Colors.grey.shade400)),
    );
  }
}

class LicenseController extends ChangeNotifier {
  int _select = 0;

  int get select => _select;

  void setSelect(int select) {
    _select = select;
    notifyListeners();
  }
}
