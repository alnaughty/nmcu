import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:intl/intl.dart';
import 'package:nomnom/app/extensions/color_ext.dart';
import 'package:nomnom/app/extensions/string_ext.dart';
import 'package:nomnom/app/mixins/color_palette.dart';
import 'package:nomnom/app/widgets/custom_loader.dart';
import 'package:nomnom/app/widgets/pick_image.dart';
import 'package:nomnom/models/user/user_model.dart';
import 'package:nomnom/providers/app_providers.dart';
import 'package:nomnom/providers/user_providers.dart';
import 'package:nomnom/services/api/auth.dart';

class PersonalInformationPage extends ConsumerStatefulWidget {
  const PersonalInformationPage({super.key});

  @override
  ConsumerState<PersonalInformationPage> createState() =>
      _PersonalInformationPageState();
}

class _PersonalInformationPageState
    extends ConsumerState<PersonalInformationPage> with ColorPalette {
  final DateTime now = DateTime.now();
  late final Size size = MediaQuery.of(context).size;
  final TextStyle contentStyle = TextStyle(
    fontWeight: FontWeight.w500,
    color: Colors.black,
  );
  late final InputDecoration _defaultDecoration = InputDecoration(
    hintStyle: contentStyle.copyWith(
      color: grey,
      fontSize: 13,
    ),
    alignLabelWithHint: true,
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: textField),
    ),
    border: UnderlineInputBorder(
      borderSide: BorderSide(color: textField),
    ),
    errorBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: textField),
    ),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: textField),
    ),
    disabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: textField.darken()),
    ),
  );
  final TextEditingController _name = TextEditingController();
  final TextEditingController _lastname = TextEditingController();
  // final TextEditingController
  DateTime? birthday;
  String? selectedGender;
  final TextEditingController _birthday = TextEditingController();
  bool isUploadingImage = false;
  final List<String> genderChoice = [
    'Male',
    'Female',
    'LGBTQIA+',
    'Rather not say',
  ];
  final DateFormat format = DateFormat('dd MMM yyyy');
  contentBuilder({required String label, required Widget child}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: size.width * .25,
              child: Text(
                label,
                style: TextStyle(fontSize: 12, color: grey),
              ),
            ),
            const Gap(10),
            Expanded(
              child: Container(
                alignment: Alignment.centerLeft,
                child: child,
              ),
            )
            // ConstrainedBox(
            //   constraints: BoxConstraints(
            //     maxWidth: size.width * .35,
            //   ),
            // )
          ],
        ),
      );
  // final DataCacher _cacher = DataCacher.instance;
  final AuthApi _api = AuthApi();
  bool isEditing = false;
  Future<void> refetch() async {
    final UserModel? user = await _api.getUserDetails();
    if (user == null) return;
    ref.read(addressChoiceProvider.notifier).update((r) => user.addresses);
    ref.read(currentUserProvider.notifier).update((r) => user);
  }

  Future<void> update() async {
    setState(() {
      isLoading = true;
    });
    final currentUser = ref.watch(currentUserProvider);
    if (currentUser == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }
    final UserModel user = currentUser.copyWith(
      firstname: _name.text,
      lastname: _lastname.text,
      birthday: birthday,
      gender: selectedGender,
    );
    final bool isUpdated = await _api.updateProfile(user);
    if (isUpdated) {
      await refetch();
      initializeValue();
    }
    setState(() {
      isEditing = false;
      isLoading = false;
    });
  }

  final GlobalKey<FormState> _kForm = GlobalKey<FormState>();
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeValue();
    });
    // TODO: implement initState
    super.initState();
  }

  bool isLoading = false;
  @override
  void dispose() {
    _name.dispose();
    _lastname.dispose();
    _birthday.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  initializeValue() async {
    final currentUser = ref.watch(currentUserProvider);
    if (currentUser == null) return;
    _name.text = currentUser.firstname;
    _lastname.text = currentUser.lastname;

    _birthday.text = currentUser.birthday == null
        ? ""
        : format.format(currentUser.birthday!);
    birthday = currentUser.birthday;
    selectedGender = currentUser.gender;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    if (currentUser == null) return Container();
    return PopScope(
      canPop: !isEditing || !isUploadingImage,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            Positioned.fill(
              child: Scaffold(
                body: Column(
                  children: [
                    Container(
                      color: orangePalette,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.asset(
                              "assets/images/vector_background.png",
                              fit: BoxFit.cover,
                              color: Colors.white.withOpacity(.5),
                            ),
                          ),
                          Column(
                            children: [
                              PreferredSize(
                                preferredSize: Size.fromHeight(56),
                                child: AppBar(
                                  iconTheme: IconThemeData(color: Colors.white),
                                  elevation: 0,
                                  backgroundColor: Colors.transparent,
                                  centerTitle: true,
                                  title: Text(
                                    "Personal Information",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () async {
                                        if (!isEditing) {
                                          setState(() {
                                            isEditing = true;
                                          });
                                        } else {
                                          await update();
                                        }
                                        // setState(() {
                                        //   isEditing = !isEditing;
                                        // });
                                      },
                                      child: Text(
                                        isEditing ? "Save" : "Update",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Form(
                          key: _kForm,
                          child: Column(
                            children: [
                              contentBuilder(
                                label: "Photo",
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: size.width * .42,
                                      height: size.width * .42,
                                      child: Stack(
                                        children: [
                                          Positioned.fill(
                                            child: CachedNetworkImage(
                                              imageUrl: currentUser.profilePic,
                                              width: size.width * .42,
                                              height: size.width * .42,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          if (isUploadingImage) ...{
                                            Positioned.fill(
                                              child: Container(
                                                color: Colors.black
                                                    .withOpacity(.3),
                                                child: Center(
                                                  child: CustomLoader(
                                                    label: "",
                                                  ),
                                                ),
                                              ),
                                            )
                                          },
                                        ],
                                      ),
                                    ),
                                    // Container(

                                    //   color: Colors.red,
                                    // ),
                                    TextButton(
                                      onPressed: isUploadingImage
                                          ? null
                                          : () async {
                                              await showModalBottomSheet(
                                                context: context,
                                                isDismissible: true,
                                                backgroundColor:
                                                    Colors.transparent,
                                                barrierColor: Colors.black
                                                    .withOpacity(.5),
                                                builder: (_) => SafeArea(
                                                  top: false,
                                                  child: PickImage(
                                                    aspectRatio:
                                                        CropAspectRatio(
                                                            ratioX: 1,
                                                            ratioY: 1),
                                                    onFilePicked:
                                                        (image) async {
                                                      setState(() {
                                                        isUploadingImage = true;
                                                      });
                                                      final bool f = await _api
                                                          .updatePicture(image);
                                                      if (f) {
                                                        await refetch();
                                                      }
                                                      setState(() {
                                                        isUploadingImage =
                                                            false;
                                                      });
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                ),
                                              );
                                            },
                                      child: Text(
                                        "Upload Image",
                                        style: TextStyle(
                                            color: isUploadingImage
                                                ? grey
                                                : orangePalette),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              const Gap(10),
                              contentBuilder(
                                label: "Name",
                                child: isEditing
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          TextFormField(
                                              validator: (text) {
                                                if (text == null ||
                                                    text.isEmpty) {
                                                  return "This field is required";
                                                }
                                                return null;
                                              },
                                              controller: _name,
                                              style: contentStyle.copyWith(
                                                  height: 1, fontSize: 13),
                                              decoration:
                                                  _defaultDecoration.copyWith(
                                                hintText: currentUser.firstname,
                                              )),
                                          TextFormField(
                                              controller: _lastname,
                                              validator: (text) {
                                                if (text == null ||
                                                    text.isEmpty) {
                                                  return "This field is required";
                                                }
                                                return null;
                                              },
                                              style: contentStyle.copyWith(
                                                  height: 1, fontSize: 13),
                                              decoration:
                                                  _defaultDecoration.copyWith(
                                                hintText: currentUser.lastname,
                                              )),
                                        ],
                                      )
                                    : Text(
                                        "${currentUser.firstname} ${currentUser.lastname}"
                                            .capitalizeWords(),
                                        style: contentStyle,
                                      ),
                              ),
                              const Gap(10),
                              contentBuilder(
                                label: "Email",
                                child: Text(
                                  currentUser.email,
                                  style: contentStyle,
                                ),
                              ),
                              const Gap(10),
                              contentBuilder(
                                label: "Gender",
                                child: isEditing
                                    ? DropdownButtonFormField(
                                        style: contentStyle.copyWith(
                                            height: 1, fontSize: 13),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 0),
                                        decoration: _defaultDecoration.copyWith(
                                          hintText: "Choose gender",
                                        ),
                                        items: genderChoice
                                            .map(
                                              (e) => DropdownMenuItem(
                                                  value: e, child: Text(e)),
                                            )
                                            .toList(),
                                        onChanged: (s) {
                                          setState(() {
                                            selectedGender = s;
                                          });
                                        })
                                    : Text(
                                        currentUser.gender ?? "Unset",
                                        style: contentStyle,
                                      ),
                              ),
                              const Gap(10),
                              contentBuilder(
                                label: "Birthday",
                                child: isEditing
                                    ? TextFormField(
                                        readOnly: true,
                                        style: contentStyle.copyWith(
                                            height: 1, fontSize: 13),
                                        controller: _birthday,
                                        onTap: () async {
                                          final DateTime? date =
                                              await showDatePicker(
                                            context: context,
                                            currentDate:
                                                currentUser.birthday ?? now,
                                            firstDate: DateTime(
                                                now.subtract(21915.days).year),
                                            lastDate: DateTime(
                                                now.subtract(4383.days).year),
                                          );
                                          if (date == null) return;
                                          setState(() {
                                            birthday = date;
                                            _birthday.text =
                                                format.format(date);
                                          });
                                        },
                                        decoration: _defaultDecoration.copyWith(
                                            hintText:
                                                currentUser.birthday == null
                                                    ? "Select Birthday"
                                                    : format.format(
                                                        currentUser.birthday!)),
                                      )
                                    : Text(
                                        currentUser.birthday == null
                                            ? "Unset"
                                            : format
                                                .format(currentUser.birthday!),
                                        style: contentStyle,
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextButton(
                          onPressed: () {},
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.delete,
                                color: orangePalette,
                              ),
                              const Gap(10),
                              Text(
                                "Request account delete",
                                style: TextStyle(
                                  color: orangePalette,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              )
                            ],
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
                child: Material(
                  color: Colors.transparent,
                  elevation: 0,
                  child: Container(
                    color: Colors.black.withOpacity(.5),
                    child: Center(
                      child: CustomLoader(
                        label: "Updating data",
                      ),
                    ),
                  ),
                ),
              )
            }
          ],
        ),
      ),
    );
  }
}
