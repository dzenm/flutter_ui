import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;


/// signature canvas. Controller is required, other parameters are optional.
/// widget/canvas expands to maximum by default.
/// this behaviour can be overridden using width and/or height parameters.
///
/// This is from https://pub.flutter-io.cn/packages/signature
class Signature extends StatefulWidget {
  /// constructor
  const Signature({
    required this.controller,
    Key? key,
    this.backgroundColor = Colors.grey,
    this.width,
    this.height,
  }) : super(key: key);

  /// signature widget controller
  final SignatureController controller;

  /// signature widget width
  final double? width;

  /// signature widget height
  final double? height;

  /// signature widget background color
  final Color backgroundColor;

  @override
  State createState() => SignatureState();
}

/// signature widget state
class SignatureState extends State<Signature> {
  /// Helper variable indicating that user has left the canvas so we can prevent linking next point
  /// with straight line.
  bool _isOutsideDrawField = false;

  /// Active pointer to prevent multitouch drawing
  int? activePointerId;

  @override
  Widget build(BuildContext context) {
    final double maxWidth = widget.width ?? double.infinity;
    final double maxHeight = widget.height ?? double.infinity;
    final GestureDetector signatureCanvas = GestureDetector(
      onVerticalDragUpdate: (DragUpdateDetails details) {
        //NO-OP
      },
      child: Container(
        decoration: BoxDecoration(color: widget.backgroundColor),
        child: Listener(
            onPointerDown: (PointerDownEvent event) {
              if (activePointerId == null || activePointerId == event.pointer) {
                activePointerId = event.pointer;
                widget.controller.onDrawStart?.call();
                _addPoint(event, PointType.tap);
              }
            },
            onPointerUp: (PointerUpEvent event) {
              if (activePointerId == event.pointer) {
                _addPoint(event, PointType.tap);
                widget.controller.pushCurrentStateToUndoStack();
                widget.controller.onDrawEnd?.call();
                activePointerId = null;
              }
            },
            onPointerCancel: (PointerCancelEvent event) {
              if (activePointerId == event.pointer) {
                _addPoint(event, PointType.tap);
                widget.controller.pushCurrentStateToUndoStack();
                widget.controller.onDrawEnd?.call();
                activePointerId = null;
              }
            },
            onPointerMove: (PointerMoveEvent event) {
              if (activePointerId == event.pointer) {
                _addPoint(event, PointType.move);
                widget.controller.onDrawMove?.call();
              }
            },
            child: RepaintBoundary(
              child: CustomPaint(
                painter: SignaturePainter(widget.controller),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      minWidth: maxWidth,
                      minHeight: maxHeight,
                      maxWidth: maxWidth,
                      maxHeight: maxHeight),
                ),
              ),
            )),
      ),
    );

    if (widget.width != null || widget.height != null) {
      //IF DOUNDARIES ARE DEFINED, USE LIMITED BOX
      return Center(
        child: LimitedBox(
          maxWidth: maxWidth,
          maxHeight: maxHeight,
          child: signatureCanvas,
        ),
      );
    } else {
      //IF NO BOUNDARIES ARE DEFINED, RETURN THE WIDGET AS IS
      return signatureCanvas;
    }
  }

  void _addPoint(PointerEvent event, PointType type) {
    final Offset o = event.localPosition;
    //SAVE POINT ONLY IF IT IS IN THE SPECIFIED BOUNDARIES
    if ((widget.width == null || o.dx > 0 && o.dx < widget.width!) &&
        (widget.height == null || o.dy > 0 && o.dy < widget.height!)) {
      // IF USER LEFT THE BOUNDARY AND AND ALSO RETURNED BACK
      // IN ONE MOVE, RETYPE IT AS TAP, AS WE DO NOT WANT TO
      // LINK IT WITH PREVIOUS POINT

      PointType t = type;
      if (_isOutsideDrawField) {
        t = PointType.tap;
      }
      setState(() {
        //IF USER WAS OUTSIDE OF CANVAS WE WILL RESET THE HELPER VARIABLE AS HE HAS RETURNED
        _isOutsideDrawField = false;
        widget.controller.addPoint(Point(o, t, event.pointer));
      });
    } else {
      //NOTE: USER LEFT THE CANVAS!!! WE WILL SET HELPER VARIABLE
      //WE ARE NOT UPDATING IN setState METHOD BECAUSE WE DO NOT NEED TO RUN BUILD METHOD
      _isOutsideDrawField = true;
    }
  }
}

/// type of user display finger movement
enum PointType {
  /// one touch on specific place - tap
  tap,

  /// finger touching the display and moving around
  move,
}

/// one point on canvas represented by offset and type
class Point {
  /// constructor
  Point(this.offset, this.type, this.eventId);

  /// x and y value on 2D canvas
  Offset offset;

  /// type of user display finger movement
  PointType type;

  int eventId;
}

class SignaturePainter extends CustomPainter {
  SignaturePainter(this._controller)
      : _penStyle = Paint(),
        super(repaint: _controller) {
    _penStyle
      ..color = _controller.penColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = _controller.penStrokeWidth;

  }

  final SignatureController _controller;
  final Paint _penStyle;


  @override
  void paint(Canvas canvas, _) {
    final List<Point> points = _controller.value;
    if (points.isEmpty) {
      return;
    }
    //for draw [DrawStyle.mosaic]
    void paintMosaic(Offset center) {
      final ui.Paint paint = ui.Paint()..color = Colors.black26;
      final double size = _controller.mosaicWidth;
      final double halfSize = size/2;
      final ui.Rect b1 = Rect.fromCenter(center: center.translate(-halfSize, -halfSize),width: size,height: size);
      //0,0
      canvas.drawRect(b1, paint);
      paint.color = Colors.grey.withOpacity(0.5);
      //0,1
      canvas.drawRect(b1.translate(0, size), paint);
      paint.color = Colors.black38;
      //0,2
      canvas.drawRect(b1.translate(0, size*2), paint);
      paint.color = Colors.black12;
      //1,0
      canvas.drawRect(b1.translate(size, 0), paint);
      paint.color = Colors.black26;
      //1,1
      canvas.drawRect(b1.translate(size, size), paint);
      paint.color = Colors.black45;
      //1,2
      canvas.drawRect(b1.translate(size, size*2), paint);
      paint.color =  Colors.grey.withOpacity(0.5);
      //2,0
      canvas.drawRect(b1.translate(size*2, 0), paint);
      paint.color = Colors.black12;
      //2,1
      canvas.drawRect(b1.translate(size*2, size), paint);
      paint.color = Colors.black26;
      //2,2
      canvas.drawRect(b1.translate(size*2, size*2), paint);

    }

    //for draw [DrawStyle.normal]
    Path paintPath() {
      final Path path = Path();
      final Map<int, List<Point>> pathM = {};
      points.forEach((element) {
        if(pathM[element.eventId] == null)
          pathM[element.eventId] = [];
        pathM[element.eventId]!.add(element);
      });

      pathM.forEach((key, value) {
        final first = value.first;
        path.moveTo(first.offset.dx, first.offset.dy);
        if(value.length <= 3) {
          _penStyle.style = PaintingStyle.fill;
          canvas.drawCircle(first.offset, _controller.penStrokeWidth,_penStyle);
          _penStyle.style = PaintingStyle.stroke;
        } else {
          value.forEach((e) {
            path.lineTo(e.offset.dx, e.offset.dy);
          });
        }
      });
      return path;
    }

    switch(_controller.drawStyle) {
      case DrawStyle.normal:
        canvas.drawPath(paintPath(), _penStyle);
        break;
      case DrawStyle.mosaic:
      //reduce the frequency of mosaic drawing.
        for(int i=0; i < points.length; i+=2) {
          paintMosaic(points[i].offset);
        }
        break;
    }

  }

  @override
  bool shouldRepaint(CustomPainter other) => true;
}


enum DrawStyle{
  ///use penColor
  normal,
  mosaic,
}

/// class for interaction with signature widget
/// manages points representing signature on canvas
/// provides signature manipulation functions (export, clear)
class SignatureController extends ValueNotifier<List<Point>> {
  /// constructor
  SignatureController({
    List<Point>? points,
    this.penColor = Colors.black,
    this.penStrokeWidth = 3.0,
    this.exportBackgroundColor,
    this.onDrawStart,
    this.onDrawMove,
    this.onDrawEnd,
    this.mosaicWidth = 5.0
  }) : super(points ?? <Point>[]);

  /// color of a signature line
  final Color penColor;

  /// boldness of a signature line
  final double penStrokeWidth;

  /// background color to be used in exported png image
  final Color? exportBackgroundColor;

  ///mosaic pixel's width
  final double mosaicWidth;

  ///draw style
  /// * [DrawStyle.normal] : paint with some color
  DrawStyle drawStyle = DrawStyle.normal;

  /// callback to notify when drawing has started
  VoidCallback? onDrawStart;

  /// callback to notify when the pointer was moved while drawing.
  VoidCallback? onDrawMove;

  /// callback to notify when drawing has stopped
  VoidCallback? onDrawEnd;

  /// getter for points representing signature on 2D canvas
  List<Point> get points => value;

  /// stack-like list of point to save user's latest action
  final List<List<Point>> _latestActions = <List<Point>>[];

  /// stack-like list that use to save points when user undo the signature
  final List<List<Point>> _revertedActions = <List<Point>>[];

  /// setter for points representing signature on 2D canvas
  set points(List<Point> points) {
    value = points;
  }

  /// add point to point collection
  void addPoint(Point point) {
    value.add(point);
    notifyListeners();
  }

  /// REMEMBERS CURRENT CANVAS STATE IN UNDO STACK
  void pushCurrentStateToUndoStack() {
    _latestActions.add(<Point>[...points]);
    //CLEAR ANY UNDO-ED ACTIONS. IF USER UNDO-ED ANYTHING HE ALREADY MADE
    // ANOTHER CHANGE AND LEFT THAT OLD PATH.
    _revertedActions.clear();
  }

  /// check if canvas is empty (opposite of isNotEmpty method for convenience)
  bool get isEmpty {
    return value.isEmpty;
  }

  /// check if canvas is not empty (opposite of isEmpty method for convenience)
  bool get isNotEmpty {
    return value.isNotEmpty;
  }

  /// clear the canvas
  void clear() {
    value = <Point>[];
    _latestActions.clear();
    _revertedActions.clear();
  }

  /// It will remove last action from [_latestActions].
  /// The last action will be saved to [_revertedActions]
  /// that will be used to do redo-ing.
  /// Then, it will modify the real points with the last action.
  void undo() {
    if (_latestActions.isNotEmpty) {
      final List<Point> lastAction = _latestActions.removeLast();
      _revertedActions.add(<Point>[...lastAction]);
      if (_latestActions.isNotEmpty) {
        points = <Point>[..._latestActions.last];
        return;
      }
      points = <Point>[];
      notifyListeners();
    }
  }

  /// It will remove last reverted actions and add it into [_latestActions]
  /// Then, it will modify the real points with the last reverted action.
  void redo() {
    if (_revertedActions.isNotEmpty) {
      final List<Point> lastRevertedAction = _revertedActions.removeLast();
      _latestActions.add(<Point>[...lastRevertedAction]);
      points = <Point>[...lastRevertedAction];
      notifyListeners();
      return;
    }
  }

  /// convert to
  Future<ui.Image?> toImage() async {
    if (isEmpty) {
      return null;
    }

    double minX = double.infinity, minY = double.infinity;
    double maxX = 0, maxY = 0;
    for (Point point in points) {
      if (point.offset.dx < minX) {
        minX = point.offset.dx;
      }
      if (point.offset.dy < minY) {
        minY = point.offset.dy;
      }
      if (point.offset.dx > maxX) {
        maxX = point.offset.dx;
      }
      if (point.offset.dy > maxY) {
        maxY = point.offset.dy;
      }
    }

    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = Canvas(recorder)
      ..translate(-(minX - penStrokeWidth), -(minY - penStrokeWidth));
    if (exportBackgroundColor != null) {
      final ui.Paint paint = Paint()..color = exportBackgroundColor!;
      canvas.drawPaint(paint);
    }
    SignaturePainter(this).paint(canvas, Size.infinite);
    final ui.Picture picture = recorder.endRecording();
    return picture.toImage(
      (maxX - minX + penStrokeWidth * 2).toInt(),
      (maxY - minY + penStrokeWidth * 2).toInt(),
    );
  }


  /// convert canvas to dart:ui Image and then to PNG represented in Uint8List
  Future<Uint8List?> toPngBytes() async {
    if (!kIsWeb) {
      final ui.Image? image = await toImage();
      if (image == null) {
        return null;
      }
      final ByteData? bytes = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      return bytes?.buffer.asUint8List();
    } else {
      return _toPngBytesForWeb();
    }
  }

  // 'image.toByteData' is not available for web. So we are using the package
  // 'image' to create an image which works on web too
  Uint8List? _toPngBytesForWeb() {
    if (isEmpty) {
      return null;
    }
    final int pColor = img.getColor(
      penColor.red,
      penColor.green,
      penColor.blue,
    );

    final Color backgroundColor = exportBackgroundColor ?? Colors.transparent;
    final int bColor = img.getColor(backgroundColor.red, backgroundColor.green,
        backgroundColor.blue, backgroundColor.alpha.toInt());

    double minX = double.infinity;
    double maxX = 0;
    double minY = double.infinity;
    double maxY = 0;

    for (Point point in points) {
      minX = min(point.offset.dx, minX);
      maxX = max(point.offset.dx, maxX);
      minY = min(point.offset.dy, minY);
      maxY = max(point.offset.dy, maxY);
    }

    //point translation
    final List<Point> translatedPoints = <Point>[];
    for (Point point in points) {
      translatedPoints.add(Point(
          Offset(
            point.offset.dx - minX + penStrokeWidth,
            point.offset.dy - minY + penStrokeWidth,
          ),
          point.type,
        point.eventId,
      ));
    }

    final int width = (maxX - minX + penStrokeWidth * 2).toInt();
    final int height = (maxY - minY + penStrokeWidth * 2).toInt();

    // create the image with the given size
    final img.Image signatureImage = img.Image(width, height);
    // set the image background color
    img.fill(signatureImage, bColor);

    // read the drawing points list and draw the image
    // it uses the same logic as the CustomPainter Paint function
    for (int i = 0; i < translatedPoints.length - 1; i++) {
      if (translatedPoints[i + 1].type == PointType.move) {
        img.drawLine(
            signatureImage,
            translatedPoints[i].offset.dx.toInt(),
            translatedPoints[i].offset.dy.toInt(),
            translatedPoints[i + 1].offset.dx.toInt(),
            translatedPoints[i + 1].offset.dy.toInt(),
            pColor,
            thickness: penStrokeWidth);
      } else {
        // draw the point to the image
        img.fillCircle(
          signatureImage,
          translatedPoints[i].offset.dx.toInt(),
          translatedPoints[i].offset.dy.toInt(),
          penStrokeWidth.toInt(),
          pColor,
        );
      }
    }
    // encode the image to PNG
    return Uint8List.fromList(img.encodePng(signatureImage));
  }
}
































