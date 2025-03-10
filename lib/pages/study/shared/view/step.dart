part of 'nearby_service_page.dart';

///
/// Created by a0010 on 2025/3/10 10:53
///
class AppStepViewBuilder {
  const AppStepViewBuilder({required this.state});

  final AppState state;

  Widget buildContent({
    required GlobalKey<ScaffoldState> scaffoldKey,
  }) {
    return switch (state) {
      (AppState.idle) => const IdleView(),
      (AppState.permissions) => const PermissionsView(),
      (AppState.checkServices) => const CheckServiceView(),
      (AppState.selectClientType) => const SelectClientTypeView(),
      (AppState.readyToDiscover) => const ReadyView(),
      (AppState.discoveringPeers) => const DiscoveryView(),
      (AppState.streamingPeers) => const StreamingPeersView(),
      (AppState.loadingConnection) => const Center(
          child: CircularProgressIndicator.adaptive(),
        ),
      (AppState.connected) => ConnectedView(
          scaffoldKey: scaffoldKey,
        ),
      (AppState.communicationChannelCreated) => const CommunicationView(),
    };
  }

  Widget buildTitle() {
    return Text(
      switch (state) {
        AppState.idle => "Let's start!",
        AppState.permissions => "Provide permissions",
        AppState.checkServices => "Check services",
        AppState.selectClientType => 'Do you want to find your friend from this device?',
        AppState.readyToDiscover => "Ready to discover!",
        AppState.discoveringPeers => "Discovering devices...",
        AppState.streamingPeers => "Peers stream got!",
        AppState.loadingConnection => "Loading your connection",
        AppState.connected => "Connected!",
        AppState.communicationChannelCreated => "You can communicate!",
      },
      style: const TextStyle(fontSize: 14),
    );
  }

  Widget? buildSubtitle() {
    final subtitle = switch (state) {
      AppState.selectClientType => 'Click "Yes" if you will search, click "No" if you will wait for your friend to connect',
      _ => null,
    };
    return subtitle != null ? Text(subtitle) : null;
  }
}

enum AppState {
  idle,
  permissions,
  checkServices,
  selectClientType,
  readyToDiscover,
  discoveringPeers,
  streamingPeers,
  loadingConnection,
  connected,
  communicationChannelCreated;

  static final List<AppState> androidSteps = [
    AppState.idle,
    AppState.permissions,
    AppState.checkServices,
    AppState.readyToDiscover,
    AppState.discoveringPeers,
    AppState.streamingPeers,
    AppState.loadingConnection,
    AppState.connected,
    AppState.communicationChannelCreated,
  ];
  static final List<AppState> iosSteps = [
    AppState.idle,
    AppState.selectClientType,
    AppState.readyToDiscover,
    AppState.discoveringPeers,
    AppState.streamingPeers,
    AppState.loadingConnection,
    AppState.connected,
    AppState.communicationChannelCreated,
  ];

  static final List<AppState> steps = [
    if (Platform.isAndroid) ...androidSteps,
    if (Platform.isIOS) ...iosSteps,
  ];

  int get step {
    return steps.indexOf(this);
  }
}

const kPinkColor = Color(0xFFC80099);
const kBlueColor = Color(0xFF0043D5);
const kWhiteColor = Color(0xFFFFFFFF);
const kGreyColor = Color(0xFF607D8B);
const kGreenColor = Color(0xFF07B988);

enum ActionType {
  idle(kBlueColor),
  warning(kPinkColor),
  success(kGreenColor);

  const ActionType(this.color);

  final Color color;
}

class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    required this.onTap,
    required this.title,
    this.type = ActionType.idle,
  });

  final VoidCallback onTap;
  final String title;
  final ActionType type;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.white,
        maximumSize: const Size(150, 50),
        minimumSize: const Size(70, 50),
        elevation: 2,
        surfaceTintColor: type.color.withOpacity(0.05),
      ),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: type.color,
          height: 1,
        ),
      ),
    );
  }
}