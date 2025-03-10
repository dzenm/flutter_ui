part of 'nearby_service_page.dart';

class PermissionsView extends StatelessWidget {
  const PermissionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ActionButton(
          onTap: context.read<NearbyModel>().requestPermissions,
          title: 'Request permissions',
        ),
      ],
    );
  }
}
