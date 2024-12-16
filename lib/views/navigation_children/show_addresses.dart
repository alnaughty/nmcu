import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:nomnom/app/extensions/string_ext.dart';
import 'package:nomnom/app/mixins/color_palette.dart';
import 'package:nomnom/app/widgets/custom_loader.dart';
import 'package:nomnom/app/widgets/custom_radio_button.dart';
import 'package:nomnom/models/user/user_address.dart';
import 'package:nomnom/providers/app_providers.dart';
import 'package:nomnom/providers/user_providers.dart';
import 'package:nomnom/views/navigation_children/add_new_address_page.dart';

class ShowAddresses extends ConsumerStatefulWidget {
  const ShowAddresses({super.key, this.onSelect});
  final ValueChanged<UserAddress>? onSelect;
  @override
  ConsumerState<ShowAddresses> createState() => _ShowAddressesState();
}

class _ShowAddressesState extends ConsumerState<ShowAddresses>
    with ColorPalette {
  @override
  Widget build(BuildContext context) {
    final UserAddress? myLocation = ref.watch(currentLocationProvider);
    final UserAddress? selectedLocation = ref.watch(selectedLocationProvider);
    final List<UserAddress>? addresses = ref.watch(addressChoiceProvider);
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 60,
                  height: 5,
                  decoration: BoxDecoration(
                    color: textField,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              const Gap(20),
              ListTile(
                onTap: () {
                  Navigator.of(context).pop();
                  ref
                      .read(selectedLocationProvider.notifier)
                      .update((r) => myLocation);
                  if (widget.onSelect != null) {
                    widget.onSelect!(myLocation!);
                  }
                },
                leading: ImageIcon(
                  AssetImage("assets/icons/navigation.png"),
                  color: orangePalette,
                ),
                title: Text(
                  "Use my current location",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  myLocation?.city ?? "Enable location Permission",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                  ),
                ),
              ),
              if (addresses == null) ...{
                SizedBox(
                  height: 56,
                  width: double.infinity,
                  child: CustomLoader(
                    color: darkGrey,
                    label: "Loading addresses",
                  ),
                )
              } else ...{
                if (addresses.isEmpty) ...{
                  SizedBox(
                      height: 56,
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/images/rider.png",
                            height: 40,
                          ),
                          const Gap(10),
                          Text(
                            "No saved address found",
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w500),
                          )
                        ],
                      ))
                } else ...{
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (_, i) {
                      final UserAddress address = addresses[i];
                      return Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                width: 1.5,
                                color: selectedLocation?.id == address.id
                                    ? orangePalette
                                    : Colors.transparent),
                            color: selectedLocation?.id == address.id
                                ? orangePalette.withOpacity(.3)
                                : Colors.transparent),
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            CustomRadioButton(
                              currentState: selectedLocation?.id == address.id,
                              callback: (state) {
                                if (state) {
                                  ref
                                      .read(selectedLocationProvider.notifier)
                                      .update((r) => address);
                                  if (widget.onSelect != null) {
                                    widget.onSelect!(address);
                                  }
                                } else {
                                  ref
                                      .read(selectedLocationProvider.notifier)
                                      .update((r) => myLocation);
                                  if (widget.onSelect != null) {
                                    widget.onSelect!(myLocation!);
                                  }
                                }
                                // selectedLocation = address;
                                Navigator.of(context).pop();
                              },
                              label: "",
                            ),
                            const Gap(10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    address.title.capitalize(),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    address.addressLine.capitalizeWords(),
                                    maxLines: 2,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (_, i) => const Gap(10),
                    itemCount: addresses.length,
                  ),
                },
                const Gap(10),
                MaterialButton(
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AddNewAddressPage(),
                      ),
                    );
                  },
                  height: 50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                    side: BorderSide(color: orangePalette, width: 1.5),
                  ),
                  child: Center(
                    child: Hero(
                      tag: "add-address",
                      child: Text(
                        "Add new address",
                        style: TextStyle(
                            fontFamily: "Poppins",
                            color: orangePalette,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                )
              },
            ],
          ),
        ),
      ),
    );
  }
}
