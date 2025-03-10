part of 'nearby_service_page.dart';

class ReadyView extends StatelessWidget {
  const ReadyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ActionButton(
          onTap: context.read<NearbyModel>().discover,
          title: 'Start discover peers',
        ),
        const SizedBox(height: 10),
        if (Platform.isIOS)
          ActionButton(
            onTap: () {
              context.read<NearbyModel>().updateState(AppState.selectClientType);
            },
            title: 'Reselect client type',
            type: ActionType.warning,
          ),
      ],
    );
  }
}
