import 'package:flutter/material.dart';

import '../../../../../base/widgets/common_bar.dart';

///
/// Created by a0010 on 2023/7/19 11:24
///
class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<StatefulWidget> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(children: [
          CommonBar(title: '关于', centerTitle: true),
        ]),
      ),
    );
  }
}
