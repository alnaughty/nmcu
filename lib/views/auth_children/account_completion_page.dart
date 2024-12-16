import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:intl/intl.dart';
import 'package:nomnom/app/extensions/color_ext.dart';
import 'package:nomnom/app/extensions/string_ext.dart';
import 'package:nomnom/app/mixins/color_palette.dart';
import 'package:nomnom/app/routes.dart';
import 'package:nomnom/app/widgets/custom_loader.dart';
import 'package:nomnom/models/user/user_model.dart';
import 'package:nomnom/providers/app_providers.dart';
import 'package:nomnom/providers/user_providers.dart';
import 'package:nomnom/services/api/auth.dart';
import 'package:nomnom/services/data_cacher.dart';
import 'package:nomnom/views/auth_children/camera_page.dart';
import 'package:permission_handler/permission_handler.dart';

class AccountCompletionPage extends ConsumerStatefulWidget {
  const AccountCompletionPage({super.key, required this.toUpdate});
  final UserModel? toUpdate;
  @override
  ConsumerState<AccountCompletionPage> createState() =>
      _AccountCompletionPageState();
}

class _AccountCompletionPageState extends ConsumerState<AccountCompletionPage>
    with ColorPalette {
  final AuthApi _api = AuthApi();
  final GlobalKey<FormState> _kForm = GlobalKey<FormState>();
  late final TextEditingController _name = TextEditingController()
    ..text = widget.toUpdate?.firstname ?? "";
  late final TextEditingController _middleName = TextEditingController()
    ..text = widget.toUpdate?.middlename ?? "";
  late final TextEditingController _lastName = TextEditingController()
    ..text = widget.toUpdate?.lastname ?? "";
  late final TextEditingController _email = TextEditingController()
    ..text = widget.toUpdate?.email ?? "";
  late final TextEditingController _phone = TextEditingController()
    ..text = widget.toUpdate?.phoneNumber ?? "";
  final TextEditingController _birthday = TextEditingController();
  final TextEditingController _landmark = TextEditingController();
  final TextEditingController _street = TextEditingController();
  final TextEditingController _referralCode = TextEditingController();
  final List<String> gender = ['Male', 'Female', 'LGBTQIA+', 'Rather not say'];
  final DataCacher _cacher = DataCacher.instance;
  int? chosenRegionIndex;
  int? chosenProvinceIndex;
  int? chosenCityIndex;
  String? chosenBrgy;
  DateTime? birthday;
  late String? chosenGender = widget.toUpdate?.gender;
  bool isLoading = false;
  File? file;
  int? signInMethod;
  String? signInVal;
  // String?
  void checkSavedValue() {
    final String? val = _cacher.loginValue();
    if (val == null) return;
    final int method = _cacher.getSignInMethod();
    print("SIGNING METHOD: $method");
    setState(() {
      signInVal = val;
      signInMethod = method;
    });
    if (method == 0) {
      // phone number
      _phone.text = val;
      if (val[0] == "0") {
        _phone.text = val.replaceFirst("0", "");
      }
    } else {
      // email
      _email.text = val;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      checkSavedValue();
    });
    super.initState();
  }

  late final CameraPage selfiePage = CameraPage(onCapture: (image) async {
    File imageFile = File(image.path);

    final CroppedFile? newFile = await ImageCropper().cropImage(
      sourcePath: image.path,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
    );
    if (newFile != null) {
      imageFile = File(newFile.path);
    }
    setState(() {
      file = imageFile;
    });
    print(file?.path);
  });
  @override
  void dispose() {
    _name.dispose();
    _middleName.dispose();
    _lastName.dispose();
    _email.dispose();
    _phone.dispose();
    _birthday.dispose();
    _landmark.dispose();
    _street.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isLoading,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            Positioned.fill(
              child: Scaffold(
                appBar: AppBar(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                ),
                body: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "You're almost there",
                        style: TextStyle(
                            fontSize: 26, fontWeight: FontWeight.w600),
                      ),
                      const Text(
                        "Complete your profile",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      const Gap(30),
                      Center(
                        child: Column(
                          children: [
                            InkWell(
                              onTap: () async {
                                final bool hasCamera =
                                    await Permission.camera.isGranted;
                                if (!hasCamera) {
                                  await Permission.camera.onGrantedCallback(() {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (_) => selfiePage));
                                  }).request();
                                } else {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (_) => selfiePage));
                                }
                              },
                              child: file != null
                                  ? Image.file(
                                      file!,
                                      height: 220,
                                    )
                                  : Image.asset(
                                      "assets/images/face_cam.png",
                                      height: 220,
                                    ),
                            ),
                            const Gap(20),
                            Text(
                              file == null
                                  ? "please take a selfie"
                                  : "click the image to retake selfie",
                              style: TextStyle(
                                  color: Colors.black.withOpacity(.3)),
                            )
                          ],
                        ),
                      ),
                      const Gap(30),
                      Form(
                        key: _kForm,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    validator: (text) {
                                      if (text == null || text.isEmpty) {
                                        return "This field is required";
                                      }
                                      return null;
                                    },
                                    controller: _name,
                                    decoration: const InputDecoration(
                                      labelText: "First name",
                                      hintText: "First name",
                                    ),
                                  ),
                                ),
                                const Gap(15),
                                Expanded(
                                  child: TextFormField(
                                    validator: (text) {
                                      if (text == null || text.isEmpty) {
                                        return "This field is required";
                                      }
                                      return null;
                                    },
                                    controller: _lastName,
                                    decoration: const InputDecoration(
                                      labelText: "Last name",
                                      hintText: "Last name",
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Gap(15),
                            TextFormField(
                              controller: _email,
                              enabled: signInMethod != null &&
                                      signInMethod! > 0 &&
                                      signInVal != null
                                  ? false
                                  : true,
                              validator: (text) {
                                if (text == null || text.isEmpty) {
                                  return "This field is required";
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                labelText: "Email",
                                hintText: "@mail.com",
                              ),
                            ),
                            const Gap(15),
                            TextFormField(
                              keyboardType: TextInputType.number,
                              validator: (text) => text == null || text.isEmpty
                                  ? "Field cannot be empty"
                                  : !text.isValidPhoneNumber()
                                      ? "Must be a valid phone number"
                                      : null,
                              onChanged: (text) {
                                if (text[0] == "0") {
                                  if (text.length >= 11) {
                                    _phone.text = text.replaceFirst("0", "");
                                  }
                                }
                              },
                              controller: _phone,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                  hintText: "Enter your number",
                                  hintStyle: TextStyle(
                                      color:
                                          Colors.grey.shade800.withOpacity(.4)),
                                  labelText: "Phone number",
                                  prefix: Padding(
                                    padding: const EdgeInsets.only(right: 7),
                                    child: Text("+63"),
                                  ),
                                  prefixStyle: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  )),
                            ),
                            const Gap(15),
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButtonFormField<String>(
                                      validator: (text) {
                                        if (text == null) {
                                          return "This field is required";
                                        }
                                        return null;
                                      },
                                      isExpanded: true,
                                      hint: Text(
                                        "Choose Gender",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color:
                                                Colors.black.withOpacity(.2)),
                                      ),
                                      value: chosenGender,
                                      items: gender
                                          .map((e) => DropdownMenuItem<String>(
                                                value: e,
                                                child: Text(e),
                                              ))
                                          .toList(),
                                      onChanged: (String? value) {
                                        if (value == null) return;
                                        chosenGender = value;
                                        if (mounted) setState(() {});
                                      },
                                    ),
                                  ),
                                ),
                                const Gap(15),
                                Expanded(
                                  child: TextFormField(
                                    controller: _birthday,
                                    validator: (text) {
                                      if (text == null || text.isEmpty) {
                                        return "This field is required";
                                      }
                                      return null;
                                    },
                                    readOnly: true,
                                    decoration: const InputDecoration(
                                        labelText: "Birthday",
                                        hintText: "mm/dd/yyyy",
                                        suffixIcon: Icon(
                                          Icons.calendar_today,
                                          size: 15,
                                        )),
                                    onTap: () async {
                                      await showDatePicker(
                                        context: context,
                                        lastDate:
                                            DateTime.now().subtract(5844.days),
                                        firstDate:
                                            DateTime.now().subtract(29220.days),
                                      ).then((v) {
                                        if (v != null) {
                                          birthday = v;
                                          _birthday.text =
                                              DateFormat('MM/dd/yyyy')
                                                  .format(v);
                                          if (mounted) setState(() {});
                                        }
                                      });
                                    },
                                  ),
                                )
                              ],
                            ),
                            const Gap(15),
                            TextField(
                              controller: _referralCode,
                              decoration: const InputDecoration(
                                labelText: "Referral code (Optional)",
                                hintText: "Referral code",
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Gap(25),
                      MaterialButton(
                        color: orangePalette,
                        height: 50,
                        elevation: 0,
                        onPressed: () async {
                          await register();
                        },
                        child: Center(
                          child: Text(
                            "Sign up",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const Gap(10),
                      MaterialButton(
                        color: Colors.transparent,
                        height: 50,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color: textField.darken(),
                            ),
                            borderRadius: BorderRadius.circular(6)),
                        onPressed: () async {
                          await _cacher.logout();
                          context.go('/main-login-page');
                          // await register();
                        },
                        child: Center(
                          child: Text(
                            "Use another account",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),
                      ),
                      const SafeArea(
                        child: SizedBox(
                          height: 10,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            if (isLoading) ...{
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(.5),
                  child: Center(
                    child: CustomLoader(
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

  Future<void> register() async {
    try {
      if (_kForm.currentState!.validate()) {
        setState(() {
          isLoading = true;
        });
        final String? firebaseUID = _cacher.getUID();
        if (firebaseUID == null) {
          print("ADSASD");
          setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(msg: "No UID Found!");
          return;
        }

        final signInMethod = _cacher.getSignInMethod();
        UserModel user = UserModel(
            id: widget.toUpdate?.id ?? 0,
            profilePic: "",
            email: _email.text,
            firstname: _name.text,
            lastname: _lastName.text,
            firebaseId: firebaseUID,
            phoneNumber: _phone.text,
            birthday: birthday,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            isBlocked: false,
            points: 0,
            gender: chosenGender,
            fullname: '${_name.text} ${_lastName.text}'.capitalizeWords(),
            addresses: []);

        if (widget.toUpdate == null) {
          String? s = await _api.createUserProfile(user);
          if (s != null) {
            await _cacher.setUserToken(s);
            final UserModel? user = await _api.getUserDetails();
            if (user == null) {
              print("NO USER");
              setState(() {
                isLoading = false;
              });
              return;
            } else if (user.firstname.isEmpty ||
                user.lastname.isEmpty ||
                (user.phoneNumber == null || user.phoneNumber!.isEmpty)) {
              Fluttertoast.showToast(msg: "Something went wrong");
              setState(() {
                isLoading = false;
              });
              return;
            }
            ref
                .read(addressChoiceProvider.notifier)
                .update((r) => user.addresses);
            ref.read(currentUserProvider.notifier).update((r) => user);
            // ignore: use_build_context_synchronously
            context.go('/navigation-page');
          }
        } else {
          print("UPDATE USER: $user");
          final bool fs = await _api.updateProfile(user);
          if (fs) {
            print("UPDATED!");
            final UserModel? user = await _api.getUserDetails();
            if (user != null) {
              ref
                  .read(addressChoiceProvider.notifier)
                  .update((r) => user.addresses);
              ref.read(currentUserProvider.notifier).update((r) => user);
              // ignore: use_build_context_synchronously
              context.go('/navigation-page');
            }
          }
        }

        if (file != null) {
          await _api.updatePicture(file!);
        }

        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      } else {
        print("ADSASD");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e, s) {
      print("ERROR: $e $s");
    }
  }
}
