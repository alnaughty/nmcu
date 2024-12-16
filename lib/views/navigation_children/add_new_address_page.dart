import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:nomnom/app/mixins/color_palette.dart';
import 'package:nomnom/app/widgets/custom_loader.dart';
import 'package:nomnom/app/widgets/map_picker.dart';
import 'package:nomnom/models/geocoder/geoaddress.dart';
import 'package:nomnom/models/user/user_address.dart';
import 'package:nomnom/models/user/user_model.dart';
import 'package:nomnom/providers/app_providers.dart';
import 'package:nomnom/providers/user_providers.dart';
import 'package:nomnom/services/api/auth.dart';
import 'package:nomnom/services/geocoder_services/geocoder.dart';

class AddNewAddressPage extends ConsumerStatefulWidget {
  const AddNewAddressPage({super.key});

  @override
  ConsumerState<AddNewAddressPage> createState() => _AddNewAddressPageState();
}

class _AddNewAddressPageState extends ConsumerState<AddNewAddressPage>
    with ColorPalette {
  final AuthApi _api = AuthApi();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _city = TextEditingController();
  final TextEditingController _brgy = TextEditingController();
  final TextEditingController _state = TextEditingController();
  final TextEditingController _country = TextEditingController();
  final TextEditingController _region = TextEditingController();
  final TextEditingController _street = TextEditingController();
  GeoPoint? coordinates;
  bool editableField = false;
  int selectedTitleID = 1;
  String selectedTitle = "Home";
  final GlobalKey<FormState> _kForm = GlobalKey<FormState>();
  Future<void> saveAndUpdate() async {
    setState(() {
      isLoading = true;
    });
    final UserAddress? newAddress = await _api.saveNewAddress(
      address: _address.text,
      brgy: _brgy.text,
      state: _state.text,
      city: _city.text,
      country: _country.text,
      coordinates: coordinates!,
      title: selectedTitle,
      region: _region.text,
      street: _street.text,
    );
    if (newAddress != null) {
      final List<UserAddress> _prvAddresses =
          ref.read(addressChoiceProvider) ?? [];
      _prvAddresses.add(newAddress);
      ref.read(addressChoiceProvider.notifier).update((r) => _prvAddresses);
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      isLoading = false;
    });
    // final UserModel? user = await _api.getUserDetails();
    // print("USER : $user");
    // if (user != null) {
    //   ref.read(addressChoiceProvider.notifier).update((r) => user.addresses);
    //   ref.read(currentUserProvider.notifier).update((r) => user);
    // }
  }

  Future<void> checkLocation(GeoPoint point) async {
    final List<GeoAddress> addresses =
        await Geocoder.google().findAddressesFromGeoPoint(point);
    print(addresses);
    final GeoAddress first = addresses.first;
    setState(() {
      _address.text = first.addressLine ?? "";
      _brgy.text = first.subLocality ?? "";
      _city.text = first.locality ?? "";
      _country.text = first.countryName ?? "";
      _state.text = first.subAdminArea ?? "";
      _region.text = first.adminArea ?? '';
      _street.text = first.thoroughfare ?? "";
      editableField = true;
    });
  }

  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    final UserAddress? myLocation = ref.watch(currentLocationProvider);
    late final List<Map<String, dynamic>> _titleChoice = [
      {
        "id": 1,
        "name": "Home",
        "value": "Home",
        "icon": ImageIcon(
          AssetImage("assets/icons/home.png"),
          color: selectedTitleID == 1 ? Colors.white : grey,
          size: 15,
        ),
      },
      {
        "id": 2,
        "name": "Work",
        "value": "Work",
        "icon": ImageIcon(
          AssetImage("assets/icons/work.png"),
          color: selectedTitleID == 2 ? Colors.white : grey,
          size: 15,
        ),
      },
      {
        "id": 3,
        "name": "Other",
        "value": "Other",
        "icon": Icon(
          Icons.add,
          color: selectedTitleID == 3 ? Colors.white : grey,
          size: 15,
        )
      },
    ];
    return PopScope(
      canPop: !isLoading,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            Positioned.fill(
              child: Scaffold(
                appBar: AppBar(
                  centerTitle: true,
                  title: Hero(
                    tag: "add-address",
                    child: Text(
                      "Add new address",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  backgroundColor: Colors.white,
                ),
                body: Column(
                  children: [
                    Expanded(
                      child: Form(
                        key: _kForm,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                          child: Column(
                            children: [
                              if (coordinates == null) ...{
                                Text(
                                  "Before you can edit any fields, you need to choose/pinpoint the location from the map first",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: red,
                                  ),
                                ),
                                const Gap(15),
                              },
                              MaterialButton(
                                height: 50,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    side: BorderSide(
                                        color: orangePalette, width: 1.5)),
                                onPressed: myLocation == null
                                    ? null
                                    : () async {
                                        await Navigator.push(
                                          context,
                                          PageRouteBuilder(
                                              pageBuilder: (context, a1, a2) =>
                                                  NomNomMapPicker(
                                                      initLocation: myLocation
                                                          .coordinates,
                                                      geoPointCallback:
                                                          (geo) async {
                                                        setState(() {
                                                          coordinates = geo;
                                                        });

                                                        // setState(() {
                                                        //   myPosition = geo;
                                                        // });
                                                        await checkLocation(
                                                            geo);
                                                      })),
                                        );
                                      },
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ImageIcon(
                                        AssetImage("assets/icons/location.png"),
                                        color: orangePalette,
                                      ),
                                      const Gap(10),
                                      Text(
                                        coordinates == null
                                            ? "Select location"
                                            : "Re-select location",
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: orangePalette,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              if (coordinates != null) ...{
                                const Gap(5),
                                Text(
                                  "${coordinates!.latitude}, ${coordinates!.longitude}",
                                  style: TextStyle(
                                      color: grey,
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic),
                                )
                              },
                              const Gap(15),
                              TextFormField(
                                enabled: editableField,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                                validator: (text) {
                                  if (text == null || text.isEmpty) {
                                    return "This field is required";
                                  }
                                  return null;
                                },
                                controller: _address,
                                decoration: const InputDecoration(
                                  labelText: "Address",
                                  hintText: "Street name, Building, House no.",
                                ),
                              ),
                              const Gap(15),
                              TextFormField(
                                enabled: editableField,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                                validator: (text) {
                                  if (text == null || text.isEmpty) {
                                    return "This field is required";
                                  }
                                  return null;
                                },
                                controller: _street,
                                decoration: const InputDecoration(
                                  labelText: "Street",
                                  hintText: "Street name etc.",
                                ),
                              ),
                              const Gap(15),
                              TextFormField(
                                enabled: editableField,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                                validator: (text) {
                                  if (text == null || text.isEmpty) {
                                    return "This field is required";
                                  }
                                  return null;
                                },
                                controller: _brgy,
                                decoration: const InputDecoration(
                                  labelText: "Barangay",
                                  hintText: "Barangay",
                                ),
                              ),
                              const Gap(15),
                              TextFormField(
                                enabled: false,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                                validator: (text) {
                                  if (text == null || text.isEmpty) {
                                    return "This field is required";
                                  }
                                  return null;
                                },
                                controller: _city,
                                decoration: const InputDecoration(
                                  labelText: "City",
                                  hintText: "City",
                                ),
                              ),
                              const Gap(15),
                              TextFormField(
                                enabled: false,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                                validator: (text) {
                                  if (text == null || text.isEmpty) {
                                    return "This field is required";
                                  }
                                  return null;
                                },
                                controller: _state,
                                decoration: const InputDecoration(
                                  labelText: "State",
                                  hintText: "State",
                                ),
                              ),
                              const Gap(15),
                              TextFormField(
                                enabled: false,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                                validator: (text) {
                                  if (text == null || text.isEmpty) {
                                    return "This field is required";
                                  }
                                  return null;
                                },
                                controller: _region,
                                decoration: const InputDecoration(
                                  labelText: "Region",
                                  hintText: "Region",
                                ),
                              ),
                              const Gap(15),
                              TextFormField(
                                enabled: false,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                                validator: (text) {
                                  if (text == null || text.isEmpty) {
                                    return "This field is required";
                                  }
                                  return null;
                                },
                                controller: _country,
                                decoration: const InputDecoration(
                                  labelText: "Country",
                                  hintText: "Country",
                                ),
                              ),
                              const Gap(20),
                              Row(
                                children: [
                                  ..._titleChoice.map((e) => Row(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              setState(() {
                                                selectedTitleID = e['id'];
                                                selectedTitle = e['value'];
                                              });
                                            },
                                            child: Column(
                                              children: [
                                                Container(
                                                  width: 50,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: selectedTitleID ==
                                                              e['id']
                                                          ? orangePalette
                                                          : textField),
                                                  padding:
                                                      const EdgeInsets.all(13),
                                                  child: Center(
                                                    child: e['icon'],
                                                  ),
                                                ),
                                                const Gap(5),
                                                Text(
                                                  e['name'],
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    color: selectedTitleID ==
                                                            e['id']
                                                        ? Colors.black
                                                        : grey,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          if ((e['id']) <
                                              _titleChoice.length) ...{
                                            const Gap(10)
                                          }
                                        ],
                                      ))
                                ],
                              ),
                              const Gap(20),
                              SizedBox(
                                width: double.infinity,
                                child: Text(
                                  """Please note that Nom Nom - Food Delivery does not use your location and trusts that you input your location  as accurately as possible\n\nThis is to protect the privacy of your exact physical location from internal or external abuse. We are always committed to protect your privacy""",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(fontSize: 12),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: MaterialButton(
                          elevation: 0,
                          onPressed: () async {
                            FocusScope.of(context).unfocus();
                            if (_kForm.currentState!.validate()) {
                              await saveAndUpdate();
                              // setState(() {
                              //   isLoading = true;
                              // });
                            }
                          },
                          color: orangePalette,
                          height: 50,
                          child: Center(
                            child: Text(
                              "Confirm",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            if (isLoading) ...{
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(.5),
                  child: Center(
                    child: CustomLoader(
                      // color: darkGrey,
                      label: "",
                    ),
                  ),
                ),
              ),
            }
          ],
        ),
      ),
    );
  }
}
