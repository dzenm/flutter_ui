import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_ui/pages/study/shared/view/nearby_model.dart';
import 'package:provider/provider.dart';

part 'step.dart';
part 'idle_view.dart';
part 'permissions_view.dart';
part 'check_service_view.dart';
part 'select_client_type_view.dart';
part 'ready_view.dart';
part 'discovery_view.dart';
part 'streaming_peers_view.dart';
part 'connected_view.dart';
part 'communication_view.dart';

///
/// Created by a0010 on 2025/3/10 10:54
///
class NearbyServicePage extends StatefulWidget {
  const NearbyServicePage({super.key});

  @override
  State<NearbyServicePage> createState() => _NearbyServicePageState();
}

class _NearbyServicePageState extends State<NearbyServicePage> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
