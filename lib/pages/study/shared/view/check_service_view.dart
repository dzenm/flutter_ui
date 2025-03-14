part of 'nearby_service_page.dart';

class CheckServiceView extends StatefulWidget {
  const CheckServiceView({super.key});

  @override
  State<CheckServiceView> createState() => _CheckServiceViewState();
}

class _CheckServiceViewState extends State<CheckServiceView> {
  bool showEnableButton = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ActionButton(
          onTap: () {
            context.read<NearbyModel>().checkWifiService().then((value) {
              if (!value) {
                setState(() {
                  showEnableButton = true;
                });
                if (context.mounted) {
                  // AppShackBar.show(
                  //   context,
                  //   'Please enable Wi-fi',
                  //   actionType: ActionType.warning,
                  // );
                }
              }
            });
          },
          title: 'Check Wi-fi service',
        ),
        if (showEnableButton)
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: ActionButton(
              onTap: context.read<NearbyModel>().openServicesSettings,
              title: 'Open settings',
            ),
          ),
      ],
    );
  }
}
