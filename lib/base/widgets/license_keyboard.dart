import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ui/base/widgets/tap_layout.dart';

typedef GetKeyboardHeight = double Function(BuildContext context);

typedef KeyboardBuilder = Widget Function(BuildContext context, KeyboardController controller, String? param);

class LicenseKeyboard extends StatefulWidget {
  static const CKTextInputType inputType = const CKTextInputType(name: 'CKLicenseKeyboard');

  static double getHeight(BuildContext ctx) {
    MediaQueryData mediaQuery = MediaQuery.of(ctx);
    double itemWidth = (mediaQuery.size.width - 6 * 11) / 10;
    double height = 5.6 * itemWidth + 66;

    return height;
  }

  final KeyboardController controller;

  LicenseKeyboard({required this.controller});

  static register() {
    CoolKeyboard.addKeyboard(
      LicenseKeyboard.inputType,
      KeyboardConfig(
        getHeight: LicenseKeyboard.getHeight,
        builder: (context, controller, params) {
          return LicenseKeyboard(controller: controller);
        },
      ),
    );
  }

  @override
  State<StatefulWidget> createState() => _LicenseKeyboardState();
}

class _LicenseKeyboardState extends State<LicenseKeyboard> {
  List<List<String>> _provinces = [
    ['京', '津', '冀', '鲁', '晋', '蒙', '辽', '吉', '黑', '沪'],
    ['苏', '浙', '皖', '闽', '赣', '豫', '鄂', '湘', '粤', '桂'],
    ['渝', '川', '贵', '云', '藏', '陕', '甘', '青'],
    ['ABC', '琼', '新', '宁', '港', '澳', '台', '删除']
  ];
  List<List<String>> _characters = [
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
      padding: EdgeInsets.only(left: 6),
      decoration: BoxDecoration(
        color: Color(0xffd9d9d9),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          TapLayout(
            height: 40,
            width: 50,
            padding: EdgeInsets.only(right: 10),
            alignment: Alignment.centerRight,
            onTap: () => widget.controller.doneAction(),
            child: RotatedBox(
              quarterTurns: 3,
              child: Icon(Icons.west_sharp, size: 20),
            ),
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
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
          child: Text(text, style: TextStyle(color: Colors.white, fontSize: 18.0)),
        );
      } else if (text == '删除') {
        return _buildItem(
          width: _itemWidth * 1.4,
          onTap: () => widget.controller.deleteOne(),
          child: Icon(Icons.close_sharp, size: 25, color: Colors.white),
        );
      } else {
        return _buildItem(
          width: _itemWidth,
          onTap: () => widget.controller.addText(text),
          child: Text(text, style: TextStyle(color: Colors.black, fontSize: 18.0)),
        );
      }
    }).toList();
  }

  Widget _buildItem({double? width, Widget? child, GestureTapCallback? onTap}) {
    return TapLayout(
      height: _itemHeight,
      width: width,
      margin: EdgeInsets.only(right: 6, bottom: 6),
      borderRadius: BorderRadius.circular(5),
      onTap: onTap,
      child: child,
    );
  }
}

class KeyboardController extends ValueNotifier<TextEditingValue> {
  final InputClient client;

  KeyboardController({
    TextEditingValue? value,
    required this.client,
  }) : super(value == null ? TextEditingValue.empty : value);

  /// The current string the user is editing.
  String get text => value.text;

  /// Setting this will notify all the listeners of this [TextEditingController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this value should only be set between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  set text(String newText) {
    value = value.copyWith(
      text: newText,
      selection: const TextSelection.collapsed(offset: -1),
      composing: TextRange.empty,
    );
  }

  /// The currently selected [text].
  ///
  /// If the selection is collapsed, then this property gives the offset of the
  /// cursor within the text.
  TextSelection get selection => value.selection;

  /// Setting this will notify all the listeners of this [TextEditingController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this value should only be set between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  set selection(TextSelection newSelection) {
    if (newSelection.start > text.length || newSelection.end > text.length) throw FlutterError('invalid text selection: $newSelection');
    value = value.copyWith(
      selection: newSelection,
      composing: TextRange.empty,
    );
  }

  set value(TextEditingValue newValue) {
    newValue = newValue.copyWith(
      // 修正由于默认值导致的Bug
      composing: TextRange(
        start: newValue.composing.start < 0 ? 0 : newValue.composing.start,
        end: newValue.composing.end < 0 ? 0 : newValue.composing.end,
      ),
      selection: newValue.selection.copyWith(
        baseOffset: newValue.selection.baseOffset < 0 ? 0 : newValue.selection.baseOffset,
        extentOffset: newValue.selection.extentOffset < 0 ? 0 : newValue.selection.extentOffset,
      ),
    );

    super.value = newValue;
  }

  /// Set the [value] to empty.
  ///
  /// After calling this function, [text] will be the empty string and the
  /// selection will be invalid.
  ///
  /// Calling this will notify all the listeners of this [TextEditingController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this method should only be called between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  void clear() {
    value = TextEditingValue.empty;
  }

  /// Set the composing region to an empty range.
  ///
  /// The composing region is the range of text that is still being composed.
  /// Calling this function indicates that the user is done composing that
  /// region.
  ///
  /// Calling this will notify all the listeners of this [TextEditingController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this method should only be called between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  clearComposing() {
    value = value.copyWith(composing: TextRange.empty);
  }

  ///删除一个字符,一般用于键盘的删除键
  deleteOne() {
    if (selection.baseOffset == 0) return;
    String newText = '';
    if (selection.baseOffset != selection.extentOffset) {
      newText = selection.textBefore(text) + selection.textAfter(text);
      value = TextEditingValue(
        text: newText,
        selection: selection.copyWith(
          baseOffset: selection.baseOffset,
          extentOffset: selection.baseOffset,
        ),
      );
    } else {
      newText = text.substring(0, selection.baseOffset - 1) + selection.textAfter(text);
      value = TextEditingValue(
        text: newText,
        selection: selection.copyWith(
          baseOffset: selection.baseOffset - 1,
          extentOffset: selection.baseOffset - 1,
        ),
      );
    }
  }

  /// 在光标位置添加文字,一般用于键盘输入
  addText(String insertText) {
    String newText = selection.textBefore(text) + insertText + selection.textAfter(text);
    value = TextEditingValue(
      text: newText,
      selection: selection.copyWith(
        baseOffset: selection.baseOffset + insertText.length,
        extentOffset: selection.baseOffset + insertText.length,
      ),
    );
  }

  /// 完成
  doneAction() {
    CoolKeyboard.sendPerformAction(TextInputAction.done);
  }

  /// 下一个
  nextAction() {
    CoolKeyboard.sendPerformAction(TextInputAction.next);
  }

  /// 换行
  newLineAction() {
    CoolKeyboard.sendPerformAction(TextInputAction.newline);
  }

  ///发送其他Action
  sendPerformAction(TextInputAction action) {
    CoolKeyboard.sendPerformAction(action);
  }
}

class CoolKeyboard {
  static JSONMethodCodec _codec = const JSONMethodCodec();
  static KeyboardConfig? _currentKeyboard;
  static Map<CKTextInputType, KeyboardConfig> _keyboards = {};
  static KeyboardRootState? _root;
  static BuildContext? _context;
  static KeyboardController? _keyboardController;
  static GlobalKey<KeyboardPageState>? _pageKey;
  static bool isInterceptor = false;

  static ValueNotifier<double> _keyboardHeightNotifier = ValueNotifier(0)..addListener(updateKeyboardHeight);

  static String? _keyboardParam;

  static Timer? clearTask;

  static init(KeyboardRootState root, BuildContext context) {
    _root = root;
    _context = context;
    interceptorInput();
  }

  static interceptorInput() {
    if (isInterceptor) return;
    isInterceptor = true;
    ServicesBinding.instance!.defaultBinaryMessenger.setMockMessageHandler("flutter/textinput", (ByteData? data) async {
      var methodCall = _codec.decodeMethodCall(data);
      switch (methodCall.method) {
        case 'TextInput.show':
          if (_currentKeyboard != null) {
            if (clearTask != null) {
              clearTask!.cancel();
              clearTask = null;
            }
            openKeyboard();
            return _codec.encodeSuccessEnvelope(null);
          } else {
            if (data != null) {
              return await _sendPlatformMessage("flutter/textinput", data);
            }
          }
          break;
        case 'TextInput.hide':
          if (_currentKeyboard != null) {
            if (clearTask == null) {
              clearTask = new Timer(Duration(milliseconds: 16), () => hideKeyboard(animation: true));
            }
            return _codec.encodeSuccessEnvelope(null);
          } else {
            if (data != null) {
              return await _sendPlatformMessage("flutter/textinput", data);
            }
          }
          break;
        case 'TextInput.setEditingState':
          var editingState = TextEditingValue.fromJSON(methodCall.arguments);
          if (_keyboardController != null) {
            _keyboardController!.value = editingState;
            return _codec.encodeSuccessEnvelope(null);
          }
          break;
        case 'TextInput.clearClient':
          if (clearTask == null) {
            clearTask = new Timer(Duration(milliseconds: 16), () => hideKeyboard(animation: true));
          }
          clearKeyboard();
          break;
        case 'TextInput.setClient':
          var setInputType = methodCall.arguments[1]['inputType'];
          InputClient? client;
          _keyboards.forEach((inputType, keyboardConfig) {
            if (inputType.name == setInputType['name']) {
              client = InputClient.fromJSON(methodCall.arguments);

              _keyboardParam = (client!.configuration.inputType as CKTextInputType).params;

              clearKeyboard();
              _currentKeyboard = keyboardConfig;
              _keyboardController = KeyboardController(client: client!)
                ..addListener(() {
                  var callbackMethodCall = MethodCall("TextInputClient.updateEditingState", [_keyboardController!.client.connectionId, _keyboardController!.value.toJSON()]);
                  ServicesBinding.instance!.defaultBinaryMessenger.handlePlatformMessage("flutter/textinput", _codec.encodeMethodCall(callbackMethodCall), (data) {});
                });
              if (_pageKey != null) {
                _pageKey!.currentState?.update();
              }
            }
          });

          if (client != null) {
            await _sendPlatformMessage("flutter/textinput", _codec.encodeMethodCall(MethodCall('TextInput.hide')));
            return _codec.encodeSuccessEnvelope(null);
          } else {
            if (clearTask == null) {
              hideKeyboard(animation: false);
            }
            clearKeyboard();
          }
          break;
      }
      if (data != null) {
        ByteData response = await _sendPlatformMessage("flutter/textinput", data);
        return response;
      }
      return null;
    });
  }

  static Future<ByteData> _sendPlatformMessage(String channel, ByteData message) {
    final Completer<ByteData> completer = Completer<ByteData>();
    ui.window.sendPlatformMessage(channel, message, (ByteData? reply) {
      try {
        if (reply != null) {
          completer.complete(reply);
        }
      } catch (exception, stack) {
        FlutterError.reportError(FlutterErrorDetails(
          exception: exception,
          stack: stack,
          library: 'services library',
          context: ErrorDescription('during a platform message response callback'),
        ));
      }
    });
    return completer.future;
  }

  static addKeyboard(CKTextInputType inputType, KeyboardConfig config) {
    _keyboards[inputType] = config;
  }

  static openKeyboard() {
    var keyboardHeight = _currentKeyboard!.getHeight(_context!);
    _keyboardHeightNotifier.value = keyboardHeight;
    if (_root!.hasKeyboard && _pageKey != null) return;
    _pageKey = GlobalKey<KeyboardPageState>();
    // KeyboardMediaQueryState queryState = _context
    //         .ancestorStateOfType(const TypeMatcher<KeyboardMediaQueryState>())
    //     as KeyboardMediaQueryState;
    // queryState.update();

    var tempKey = _pageKey;
    _root!.setKeyboard((ctx) {
      if (_currentKeyboard != null && _keyboardHeightNotifier.value != null) {
        return KeyboardPage(
            key: tempKey,
            builder: (ctx) {
              return _currentKeyboard!.builder(ctx, _keyboardController!, _keyboardParam);
            },
            height: _keyboardHeightNotifier.value);
      } else {
        return Container();
      }
    });

//    BackButtonInterceptor.add((_, _2) {
//      CoolKeyboard.sendPerformAction(TextInputAction.done);
//      return true;
//    }, zIndex: 1, name: 'CustomKeyboard');
  }

  static hideKeyboard({bool animation = true}) {
    if (clearTask != null) {
      if (clearTask!.isActive) {
        clearTask!.cancel();
      }
      clearTask = null;
    }
//    BackButtonInterceptor.removeByName('CustomKeyboard');
    if (_root!.hasKeyboard && _pageKey != null) {
      // _pageKey.currentState.animationController
      //     .addStatusListener((AnimationStatus status) {
      //   if (status == AnimationStatus.dismissed ||
      //       status == AnimationStatus.completed) {
      //     if (_root.hasKeyboard) {
      //       _keyboardEntry.remove();
      //       _keyboardEntry = null;
      //     }
      //   }
      // });
      if (animation) {
        _pageKey!.currentState!.exitKeyboard();
        Future.delayed(Duration(milliseconds: 116)).then((_) {
          _root!.clearKeyboard();
        });
      } else {
        _root!.clearKeyboard();
      }
    }
    _pageKey = null;
    _keyboardHeightNotifier.value = 0;
    try {
      // KeyboardMediaQueryState queryState = _context
      //     .ancestorStateOfType(const TypeMatcher<KeyboardMediaQueryState>())
      // as KeyboardMediaQueryState;
      // queryState.update();
    } catch (_) {}
  }

  static clearKeyboard() {
    _currentKeyboard = null;
    if (_keyboardController != null) {
      _keyboardController!.dispose();
      _keyboardController = null;
    }
  }

  static sendPerformAction(TextInputAction action) {
    var callbackMethodCall = MethodCall("TextInputClient.performAction", [_keyboardController!.client.connectionId, action.toString()]);
    ServicesBinding.instance!.defaultBinaryMessenger.handlePlatformMessage("flutter/textinput", _codec.encodeMethodCall(callbackMethodCall), (data) {});
  }

  static updateKeyboardHeight() {
    if (_pageKey != null && _pageKey!.currentState != null && clearTask == null) {
      _pageKey!.currentState!.updateHeight(_keyboardHeightNotifier.value);
    }
  }
}

class InputClient {
  final int connectionId;
  final TextInputConfiguration configuration;

  const InputClient({required this.connectionId, required this.configuration});

  factory InputClient.fromJSON(List<dynamic> encoded) {
    return InputClient(
      connectionId: encoded[0],
      configuration: TextInputConfiguration(
        inputType: CKTextInputType.fromJSON(encoded[1]['inputType']),
        obscureText: encoded[1]['obscureText'],
        autocorrect: encoded[1]['autocorrect'],
        actionLabel: encoded[1]['actionLabel'],
        inputAction: _toTextInputAction(encoded[1]['inputAction']),
        textCapitalization: _toTextCapitalization(encoded[1]['textCapitalization']),
        keyboardAppearance: _toBrightness(
          encoded[1]['keyboardAppearance'],
        ),
      ),
    );
  }

  static TextInputAction _toTextInputAction(String action) {
    switch (action) {
      case 'TextInputAction.none':
        return TextInputAction.none;
      case 'TextInputAction.unspecified':
        return TextInputAction.unspecified;
      case 'TextInputAction.go':
        return TextInputAction.go;
      case 'TextInputAction.search':
        return TextInputAction.search;
      case 'TextInputAction.send':
        return TextInputAction.send;
      case 'TextInputAction.next':
        return TextInputAction.next;
      case 'TextInputAction.previuos':
        return TextInputAction.previous;
      case 'TextInputAction.continue_action':
        return TextInputAction.continueAction;
      case 'TextInputAction.join':
        return TextInputAction.join;
      case 'TextInputAction.route':
        return TextInputAction.route;
      case 'TextInputAction.emergencyCall':
        return TextInputAction.emergencyCall;
      case 'TextInputAction.done':
        return TextInputAction.done;
      case 'TextInputAction.newline':
        return TextInputAction.newline;
    }
    throw FlutterError('Unknown text input action: $action');
  }

  static TextCapitalization _toTextCapitalization(String capitalization) {
    switch (capitalization) {
      case 'TextCapitalization.none':
        return TextCapitalization.none;
      case 'TextCapitalization.characters':
        return TextCapitalization.characters;
      case 'TextCapitalization.sentences':
        return TextCapitalization.sentences;
      case 'TextCapitalization.words':
        return TextCapitalization.words;
    }

    throw FlutterError('Unknown text capitalization: $capitalization');
  }

  static Brightness _toBrightness(String brightness) {
    switch (brightness) {
      case 'Brightness.dark':
        return Brightness.dark;
      case 'Brightness.light':
        return Brightness.light;
    }

    throw FlutterError('Unknown Brightness: $brightness');
  }
}

class KeyboardPage extends StatefulWidget {
  final WidgetBuilder builder;
  final double height;

  const KeyboardPage({
    Key? key,
    required this.builder,
    this.height = 0,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => KeyboardPageState();
}

class KeyboardPageState extends State<KeyboardPage> {
  Widget? _lastBuildWidget;
  bool _isClose = false;
  double _height = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _height = widget.height;
      setState(() => {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      child: IntrinsicHeight(child: Builder(
        builder: (ctx) {
          _lastBuildWidget = widget.builder(ctx);
          return ConstrainedBox(
            child: _lastBuildWidget,
            constraints: BoxConstraints(
              minHeight: 0,
              minWidth: 0,
              maxHeight: _height,
              maxWidth: MediaQuery.of(context).size.width,
            ),
          );
        },
      )),
      left: 0,
      width: MediaQuery.of(context).size.width,
      bottom: _height * (_isClose ? -1 : 0),
      height: _height,
      duration: Duration(milliseconds: 100),
    );
  }

  @override
  void dispose() {
    // if (animationController.status == AnimationStatus.forward ||
    //     animationController.status == AnimationStatus.reverse) {
    //   animationController.notifyStatusListeners(AnimationStatus.dismissed);
    // }
    // animationController.dispose();
    super.dispose();
  }

  exitKeyboard() {
    _isClose = true;
  }

  update() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      setState(() => {});
    });
  }

  updateHeight(double height) {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      this._height = height;
      setState(() => {});
    });
  }
}

class KeyboardRootWidget extends StatefulWidget {
  final Widget child;

  /// The text direction for this subtree.
  final TextDirection textDirection;

  const KeyboardRootWidget({
    Key? key,
    required this.child,
    this.textDirection = TextDirection.ltr,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => KeyboardRootState();
}

class KeyboardRootState extends State<KeyboardRootWidget> {
  WidgetBuilder? _builder;

  bool get hasKeyboard => _builder != null;

  // List<OverlayEntry> _initialEntries = [];

  @override
  void initState() {
    super.initState();
    // _initialEntries.add(this.initChild());
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return KeyboardMediaQuery(child: Builder(builder: (context) {
      CoolKeyboard.init(this, context);

      List<Widget> children = [widget.child];
      if (_builder != null) {
        children.add(Builder(
          builder: _builder!,
        ));
      }
      return Directionality(
          textDirection: widget.textDirection,
          child: Stack(
            children: children,
          ));
    }));
  }

  setKeyboard(WidgetBuilder builder) {
    this._builder = builder;
    setState(() {});
  }

  clearKeyboard() {
    if (this._builder != null) {
      this._builder = null;
      setState(() {});
    }
  }
}

class KeyboardMediaQuery extends StatefulWidget {
  final Widget child;

  KeyboardMediaQuery({required this.child});

  @override
  State<StatefulWidget> createState() => KeyboardMediaQueryState();
}

class KeyboardMediaQueryState extends State<KeyboardMediaQuery> {
  double keyboardHeight = 0;
  ValueNotifier<double> keyboardHeightNotifier = CoolKeyboard._keyboardHeightNotifier;

  @override
  void initState() {
    super.initState();
    CoolKeyboard._keyboardHeightNotifier.addListener(onUpdateHeight);
  }

  @override
  Widget build(BuildContext context) {
    var data = MediaQuery.maybeOf(context);
    if (data == null) {
      data = MediaQueryData.fromWindow(WidgetsBinding.instance!.window);
    }
    var bottom = CoolKeyboard._keyboardHeightNotifier.value != 0 ? CoolKeyboard._keyboardHeightNotifier.value : data.viewInsets.bottom;
    return MediaQuery(
      child: widget.child,
      data: data.copyWith(
        viewInsets: data.viewInsets.copyWith(bottom: bottom),
      ),
    );
  }

  onUpdateHeight() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      setState(() => {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    CoolKeyboard._keyboardHeightNotifier.removeListener(onUpdateHeight);
  }
}

/// 键盘配置
class KeyboardConfig {
  final KeyboardBuilder builder;
  final GetKeyboardHeight getHeight;

  const KeyboardConfig({
    required this.builder,
    required this.getHeight,
  });
}

/// 键盘输入类型
class CKTextInputType extends TextInputType {
  final String name;
  final String? params;

  const CKTextInputType({
    required this.name,
    bool? signed,
    bool? decimal,
    this.params,
  }) : super.numberWithOptions(signed: signed, decimal: decimal);

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{'name': name, 'signed': signed, 'decimal': decimal, 'params': params};
  }

  @override
  String toString() {
    return '$runtimeType('
        'name: $name, '
        'signed: $signed, '
        'decimal: $decimal, '
        'params: $params)';
  }

  bool operator ==(Object target) {
    if (target is CKTextInputType) {
      if (this.name == target.toString()) {
        return true;
      }
    }
    return false;
  }

  @override
  int get hashCode => this.toString().hashCode;

  factory CKTextInputType.fromJSON(Map<String, dynamic> encoded) {
    return CKTextInputType(name: encoded['name'], signed: encoded['signed'], decimal: encoded['decimal'], params: encoded['params']);
  }
}
