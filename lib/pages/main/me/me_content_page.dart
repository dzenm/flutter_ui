import 'package:fbl/fbl.dart';
import 'package:flutter/material.dart';

typedef ContentPageBuilder = Widget Function(PageController controller);

///
/// Created by a0010 on 2024/4/3 14:14
///
class MeContentPage extends StatefulWidget {
  final StatefulNavigationShell navigationShell;
  final List<Widget> children;
  final ContentPageBuilder builder;

  const MeContentPage({
    super.key,
    required this.navigationShell,
    required this.children,
    required this.builder,
  });

  @override
  State<MeContentPage> createState() => _MeContentPageState();
}

class _MeContentPageState extends State<MeContentPage> with SingleTickerProviderStateMixin {
  late final PageController _controller = PageController(
    initialPage: widget.navigationShell.currentIndex,
  );

  @override
  Widget build(BuildContext context) {
    return widget.builder(_controller);
  }
}
