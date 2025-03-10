part of 'nearby_service_page.dart';

class StreamingPeersView extends StatelessWidget {
  const StreamingPeersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ActionButton(
          type: ActionType.warning,
          onTap: context.read<NearbyModel>().stopListeningPeers,
          title: 'Stop stream peers',
        ),
        const SizedBox(height: 10),
        const _PeersBody(),
      ],
    );
  }
}

class _PeersBody extends StatelessWidget {
  const _PeersBody();

  @override
  Widget build(BuildContext context) {
    return Selector<NearbyModel, bool>(
      selector: (context, service) => service.isIOSBrowser,
      builder: (context, isIOSBrowser, _) {
        return Selector<NearbyModel, List<NearbyDevice>?>(
          selector: (context, service) => service.peers,
          builder: (context, peers, _) {
            return (peers != null && peers.isNotEmpty)
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ...peers.map(
                        (e) {
                          return Container(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: DevicePreview(device: e),
                          );
                        },
                      ),
                    ],
                  )
                : Text(
                    Platform.isAndroid || isIOSBrowser
                        ? 'No one here ('
                        : "Wait until someone invites you!",
                    textAlign: TextAlign.center,
                  );
          },
        );
      },
    );
  }
}
