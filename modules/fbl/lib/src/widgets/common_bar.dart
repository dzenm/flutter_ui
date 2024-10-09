import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tap_layout.dart';

/// AppBar封装
class CommonBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Color? titleColor;
  final bool? centerTitle;
  final String? subTitle;
  final Color? subTitleColor;
  final Color? backgroundColor;
  final bool showLeading;
  final Widget? leading;
  final Function? onBackTap;
  final double? elevation;
  final double toolbarHeight;
  final PreferredSizeWidget? bottom;
  final SystemUiOverlayStyle systemOverlayStyle;
  final List<Widget>? actions;
  final double? titleSpacing;

  const CommonBar({
    super.key,
    this.title,
    this.titleColor = Colors.white,
    this.centerTitle = true,
    this.subTitle,
    this.subTitleColor,
    this.backgroundColor,
    this.showLeading = true,
    this.leading,
    this.onBackTap,
    this.elevation = 0.0,
    this.toolbarHeight = kToolbarHeight,
    this.bottom,
    this.systemOverlayStyle = SystemUiOverlayStyle.light,
    this.actions,
    this.titleSpacing = NavigationToolbar.kMiddleSpacing,
  });

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      titleSpacing: titleSpacing,
      leading: _buildLeading(
        context,
        titleColor,
        leading: leading,
        onBackTap: onBackTap,
      ),
      backgroundColor: backgroundColor,
      foregroundColor: titleColor,
      bottom: bottom,
      title: Text.rich(
        TextSpan(
          text: title,
          children: [
            TextSpan(
              text: subTitle ?? '',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      titleTextStyle: TextStyle(
        fontSize: 18.0,
        color: titleColor,
        fontWeight: FontWeight.bold,
      ),
      centerTitle: centerTitle,
      elevation: elevation,
      toolbarHeight: toolbarHeight,
      systemOverlayStyle: systemOverlayStyle,
      actions: actions,
    );
  }

  Widget? _buildLeading(
    BuildContext context,
    Color? titleColor, {
    Widget? leading,
    Function? onBackTap,
  }) {
    if (showLeading) return null;
    return TapLayout(
      width: 40,
      height: 40,
      isCircle: true,
      padding: const EdgeInsets.only(left: 12),
      child: leading ?? const BackButtonIcon(),
      onTap: () {
        if (onBackTap == null) {
          Navigator.pop(context);
        } else {
          onBackTap();
        }
      },
    );
  }

// Widget _buildToolbar(BuildContext context) {
//   return Semantics(
//     container: true,
//     child: AnnotatedRegion<SystemUiOverlayStyle>(
//       value: systemOverlayStyle,
//       child: Material(
//         color: backgroundColor,
//         child: Semantics(
//           explicitChildNodes: true,
//           child: Container(
//             color: backgroundColor,
//             child: Column(children: [
//               Container(height: 24, color: backgroundColor),
//               Container(
//                 height: kToolbarHeight,
//                 padding: const EdgeInsets.symmetric(horizontal: 24),
//                 child: Row(children: [
//                   TapLayout(
//                     isCircle: true,
//                     width: 40,
//                     height: 40,
//                     onTap: () {
//                       if (Navigator.canPop(context)) {
//                         Navigator.pop(context);
//                       }
//                     },
//                     child: BackButton(),
//                   ),
//                   const SizedBox(width: 32),
//                   Expanded(
//                     flex: 1,
//                     child: Row(mainAxisAlignment: centerTitle ?? false ? MainAxisAlignment.center : MainAxisAlignment.start, children: [
//                       Text.rich(
//                         TextSpan(text: title, children: [
//                           TextSpan(
//                             text: subTitle ?? '',
//                             style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
//                           ),
//                         ]),
//                       ),
//                     ]),
//                   ),
//                   const SizedBox(width: 32),
//                 ]),
//               )
//             ]),
//           ),
//         ),
//       ),
//     ),
//   );
// }
}
