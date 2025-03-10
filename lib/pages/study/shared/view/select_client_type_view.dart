part of 'nearby_service_page.dart';

class SelectClientTypeView extends StatelessWidget {
  const SelectClientTypeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ActionButton(
          title: 'Yes',
          onTap: () {
            context.read<NearbyModel>().setIsBrowser(value: true);
          },
        ),
        const SizedBox(width: 10),
        ActionButton(
          title: 'No',
          onTap: () {
            context.read<NearbyModel>().setIsBrowser(value: false);
          },
        ),
      ],
    );
  }
}
