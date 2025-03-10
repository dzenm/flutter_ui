part of 'nearby_service_page.dart';

class DiscoveryView extends StatelessWidget {
  const DiscoveryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ActionButton(
          onTap: context.read<NearbyModel>().startListeningPeers,
          title: 'Tap to get peers!',
        ),
        const SizedBox(height: 10),
        ActionButton(
          type: ActionType.warning,
          onTap: context.read<NearbyModel>().stopDiscovery,
          title: 'Stop discovery',
        ),
      ],
    );
  }
}
