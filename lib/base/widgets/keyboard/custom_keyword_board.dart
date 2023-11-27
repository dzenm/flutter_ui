import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tap_layout.dart';
import 'keyboard_controller.dart';
import 'keyboard_manager.dart';

/// 自定义键盘
class CustomKeywordBoard {
  static const CKTextInputType license = CKTextInputType(name: 'CKLicenseKeyboard');
  static const CKTextInputType number = CKTextInputType(name: 'CKNumberKeyboard');

  // 在main中执行runApp之前调用
  static void register() {
    CoolKeyboard.addKeyboard(
      license,
      KeyboardConfig(
        getHeight: getLicenseHeight,
        builder: (context, controller, params) => LicenseKeyboard(controller: controller),
      ),
    );

    CoolKeyboard.addKeyboard(
      number,
      KeyboardConfig(
        getHeight: getNumberHeight,
        builder: (context, controller, params) => NumberKeyboard(controller: controller),
      ),
    );
  }

  static double getLicenseHeight(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    double itemWidth = (mediaQuery.size.width - 6 * 11) / 10;
    double height = 5.6 * itemWidth + 66;
    return height;
  }

  static double getNumberHeight(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    return (mediaQuery.size.width / 3 * 2) / 5 * 4;
  }
}

/// 数字键盘
class NumberKeyboard extends StatelessWidget {
  final KeyboardController controller;
  final bool withDot;

  const NumberKeyboard({super.key, required this.controller, this.withDot = false});

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);

    return Container(
      height: CustomKeywordBoard.getNumberHeight(context),
      width: mediaQuery.size.width,
      decoration: const BoxDecoration(
        color: Colors.grey,
      ),
      child: GridView.count(childAspectRatio: 5 / 2, mainAxisSpacing: 0.5, crossAxisSpacing: 0.5, padding: const EdgeInsets.all(0.0), crossAxisCount: 3, children: [
        buildButton('1'),
        buildButton('2'),
        buildButton('3'),
        buildButton('4'),
        buildButton('5'),
        buildButton('6'),
        buildButton('7'),
        buildButton('8'),
        buildButton('9'),
        withDot ? buildButton('.') : Container(color: Colors.grey),
        buildButton('0'),
        buildButton(
          null,
          icon: const Icon(Icons.label, size: 25),
          color: Colors.blueGrey,
          onTap: () => controller.deleteOne(),
        )
      ]),
    );
  }

  Widget buildButton(String? text, {Widget? icon, Color? color, Function()? onTap}) {
    return TapLayout(
      alignment: Alignment.center,
      background: color ?? Colors.white,
      onTap: onTap ?? () => controller.addText(text ?? ''),
      child: icon ?? Text(text ?? '', style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black, fontSize: 23.0)),
    );
  }
}

/// 车牌号键盘
class LicenseKeyboard extends StatefulWidget {
  final KeyboardController controller;

  const LicenseKeyboard({super.key, required this.controller});

  @override
  State<StatefulWidget> createState() => _LicenseKeyboardState();
}

class _LicenseKeyboardState extends State<LicenseKeyboard> {
  final List<List<String>> _provinces = [
    ['京', '津', '冀', '鲁', '晋', '蒙', '辽', '吉', '黑', '沪'],
    ['苏', '浙', '皖', '闽', '赣', '豫', '鄂', '湘', '粤', '桂'],
    ['渝', '川', '贵', '云', '藏', '陕', '甘', '青'],
    ['ABC', '琼', '新', '宁', '港', '澳', '台', '删除']
  ];
  final List<List<String>> _characters = [
    ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'],
    ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
    ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
    ['省份', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', '删除']
  ];
  double _itemWidth = 0, _itemHeight = 0;

  bool _showProvinces = true;

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    _itemWidth = (mediaQuery.size.width - 6 * 11) / 10;
    _itemHeight = _itemWidth * 1.4;
    return Container(
      height: _itemHeight * 4 + 4 * 6 + 40,
      width: mediaQuery.size.width,
      padding: const EdgeInsets.only(left: 6),
      decoration: const BoxDecoration(color: Color(0xffd9d9d9)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          TapLayout(
            height: 40,
            width: 50,
            padding: const EdgeInsets.only(right: 10),
            alignment: Alignment.centerRight,
            onTap: () => widget.controller.doneAction(),
            child: const RotatedBox(
              quarterTurns: 3,
              child: Icon(Icons.west_sharp, size: 20),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _buildRow(_showProvinces ? _provinces[index] : _characters[index]),
                );
              },
              itemCount: 4,
            ),
          )
        ],
      ),
    );
  }

  List<Widget> _buildRow(List<String> list) {
    return list.map((text) {
      if (text == 'ABC' || text == '省份') {
        return _buildItem(
          width: _itemWidth * 1.4,
          onTap: () => setState(() => _showProvinces = !_showProvinces),
          child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 18.0)),
        );
      } else if (text == '删除') {
        return _buildItem(
          width: _itemWidth * 1.4,
          onTap: () => widget.controller.deleteOne(),
          child: const Icon(Icons.close_sharp, size: 25, color: Colors.white),
        );
      } else {
        return _buildItem(
          width: _itemWidth,
          onTap: () => widget.controller.addText(text),
          child: Text(text, style: const TextStyle(color: Colors.black, fontSize: 18.0)),
        );
      }
    }).toList();
  }

  Widget _buildItem({double? width, Widget? child, GestureTapCallback? onTap}) {
    return TapLayout(
      height: _itemHeight,
      width: width,
      margin: const EdgeInsets.only(right: 6, bottom: 6),
      borderRadius: BorderRadius.circular(5),
      onTap: onTap,
      child: child,
    );
  }
}

/// 单个字符输入框
class CellInput extends StatefulWidget {
  final int cellCount;
  final InputType inputType;
  final ValueChanged<String>? onChanged;
  final bool autofocus;
  final BorderRadiusGeometry? borderRadius;
  final Color? solidColor;
  final Color strokeColor;
  final Color? textColor;
  final double fontSize;
  final double? cellHeight;
  final double? cellWidth;
  final EdgeInsetsGeometry? margin;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final int? verifyCodeType;

  const CellInput({
    super.key,
    this.cellCount = 4,
    this.inputType = InputType.number,
    this.autofocus = true,
    this.onChanged,
    this.borderRadius,
    this.solidColor,
    this.strokeColor = Colors.blue,
    this.textColor,
    this.margin,
    this.cellWidth,
    this.cellHeight,
    this.focusNode,
    this.controller,
    this.fontSize = 22,
    this.verifyCodeType = 0,
  });

  @override
  State<StatefulWidget> createState() => _CellInputState();
}

class _CellInputState extends State<CellInput> {
  String inputStr = "";
  final bool _autofocus = false;

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: getCells(),
          ),
          SizedBox(
            height: 80, //l 48 增加触发面积
            width: double.infinity,
            child: TextField(
              focusNode: widget.focusNode,
              keyboardType: keyboardType(),
              inputFormatters: [LengthLimitingTextInputFormatter(widget.cellCount)],
              decoration: const InputDecoration(border: InputBorder.none),
              cursorWidth: 0,
              style: const TextStyle(color: Colors.transparent),
              controller: widget.controller ?? _controller,
              autofocus: _autofocus,
              onChanged: (value) {
                setState(() {
                  inputStr = value;
                  if (value.length == widget.cellCount) {
                    if (widget.onChanged != null) {
                      widget.onChanged!(value);
                    }
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  String getIndexShowText(int index) {
    if (inputStr.isEmpty) return "";
    return inputStr.length < index
        ? ""
        : [InputType.payment, InputType.password].contains(widget.inputType)
            ? "●"
            : inputStr[index];
  }

  TextInputType keyboardType() {
    if (widget.inputType == InputType.payment) {
      return CustomKeywordBoard.number;
    } else if (widget.inputType == InputType.license) {
      return CustomKeywordBoard.license;
    } else if (widget.inputType == InputType.number) {
      return TextInputType.number;
    } else if (widget.inputType == InputType.password) {
      return TextInputType.number;
    } else {
      return TextInputType.text;
    }
  }

  List<Widget> getCells() {
    List<Widget> cells = [];
    for (int i = 0; i < widget.cellCount; i++) {
      cells.add(getCell(i));
    }
    return cells;
  }

  Widget getCell(int i) {
    return Expanded(
      flex: 1,
      child: Center(
        child: Container(
          width: widget.cellWidth ?? 55,
          height: widget.cellHeight ?? 70,
          margin: widget.margin ?? const EdgeInsets.only(left: 6, right: 6),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            border: widget.verifyCodeType == 1
                ? Border(bottom: BorderSide(width: 1, color: widget.solidColor ?? widget.strokeColor))
                : widget.margin == EdgeInsets.zero
                    ? getBorder(i)
                    : Border.all(width: 1, color: getBoarderColor(i)),
            borderRadius: widget.borderRadius,
          ),
          child: Text(
            getIndexShowText(i),
            style: TextStyle(fontSize: widget.fontSize, color: widget.textColor, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  BoxBorder getBorder(int index) {
    if (index == widget.cellCount - 1) {
      return Border.all(width: 1, color: getBoarderColor(index));
    } else {
      BorderSide side = BorderSide(width: 1, color: getBoarderColor(index));
      return Border(top: side, left: side, bottom: side);
    }
  }

  Color getBoarderColor(int index) {
    if (inputStr.isEmpty) {
      return index == 0 ? widget.strokeColor : widget.solidColor ?? widget.strokeColor;
    } else {
      return index == inputStr.length ? widget.strokeColor : widget.solidColor ?? widget.strokeColor;
    }
  }
}

enum InputType { password, number, text, license, payment }
