import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:intl/intl.dart';
import 'package:nomnom/app/extensions/color_ext.dart';
import 'package:nomnom/app/extensions/date_ext.dart';
import 'package:nomnom/app/extensions/string_ext.dart';
import 'package:nomnom/app/mixins/color_palette.dart';
import 'package:nomnom/app/widgets/custom_loader.dart';
import 'package:nomnom/app/widgets/pick_image.dart';
import 'package:nomnom/models/chatroom.dart';
import 'package:nomnom/providers/user_providers.dart';
import 'package:nomnom/services/api/notification.dart';
import 'package:nomnom/services/firebase/firebase_firestore_support.dart';

class ChatroomPage extends ConsumerStatefulWidget {
  const ChatroomPage(
      {super.key, required this.reference, required this.receiverID});
  final String reference;
  final int receiverID;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatroomPageState();
}

class _ChatroomPageState extends ConsumerState<ChatroomPage> with ColorPalette {
  final FirebaseFirestoreSupport _firestore = FirebaseFirestoreSupport();
  late final Stream<List<Chat>> _stream;
  final NotificationConfig _notification = NotificationConfig();
  List<String> receiverTokens = [];
  late final StreamSubscription<List<Chat>> _streamSubscription;
  List<Chat>? chats;
  initStream() {
    _stream = _firestore.fetchMessages(refcode: widget.reference);
    _streamSubscription = _stream.listen((r) {
      setState(() {
        chats = r;
        chats!.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      });
    });
  }

  Future<void> getReceiverTokens() async {
    receiverTokens = await _firestore.getTokens(widget.receiverID);
    print("RECEIVER TOKENS: $receiverTokens");
    setState(() {});
  }

  File? photo;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      initStream();
      await getReceiverTokens();
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    _message.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  late final TextEditingController _message = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: subScaffoldColor,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(widget.reference,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ),
        body: chats == null
            ? Center(
                child: CustomLoader(
                  color: darkGrey,
                  label: "Loading messages",
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: chats!.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/images/rider.png",
                                  height: 80,
                                ),
                                const Gap(10),
                                Text(
                                  "No conversation yet,\nyou can start by saying 'Hi'.",
                                  textAlign: TextAlign.center,
                                )
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(20),
                            itemBuilder: (_, i) {
                              final Chat chat = chats![i];
                              final bool iamSender =
                                  currentUser!.id == chat.userId;
                              final Color textColor = darkGrey;
                              final DateFormat format = DateFormat(chat
                                      .timestamp
                                      .toDate()
                                      .isSameDay(DateTime.now())
                                  ? "hh:mm a"
                                  : "MMM dd, hh:mm a");
                              return Row(
                                mainAxisAlignment: iamSender
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                                children: [
                                  if (chat.userId != currentUser.id) ...{
                                    Tooltip(
                                      message: chat.senderName,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(60),
                                        child: CachedNetworkImage(
                                          imageUrl: chat.senderAvatar,
                                          height: 45,
                                          width: 45,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    const Gap(10),
                                  },
                                  ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth: size.width *
                                          0.55, // Max width constraint for the bubble
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      // constraints: BoxConstraints(
                                      //     maxWidth: size.width * .55,
                                      //     minWidth: 20),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                        color: chat.userId == currentUser.id
                                            ? orangePalette.withOpacity(.3)
                                            : grey.withOpacity(.3),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            chat.userId == currentUser.id
                                                ? CrossAxisAlignment.end
                                                : CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            chat.message,
                                            textAlign: iamSender
                                                ? TextAlign.right
                                                : TextAlign.left,
                                            style: TextStyle(
                                              color: textColor,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14,
                                            ),
                                          ),
                                          if (chat.photoUrl != null) ...{
                                            CachedNetworkImage(
                                              imageUrl: chat.photoUrl!,
                                            ),
                                            const Gap(5)
                                          },
                                          Text(
                                            format.format(
                                                chat.timestamp.toDate()),
                                            style: TextStyle(
                                              color: textColor.withOpacity(.5),
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              );
                            },
                            reverse: true,
                            separatorBuilder: (_, i) => const Gap(10),
                            itemCount: chats!.length,
                          ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    color: Colors.white,
                    child: SafeArea(
                      top: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (photo != null) ...{
                            Image.file(
                              photo!,
                              height: 60,
                            ),
                            const Gap(5)
                          },
                          Row(
                            children: [
                              IconButton(
                                  onPressed: () async {
                                    await showModalBottomSheet(
                                      context: context,
                                      isDismissible: true,
                                      backgroundColor: Colors.transparent,
                                      barrierColor:
                                          Colors.black.withOpacity(.5),
                                      builder: (_) => SafeArea(
                                        top: false,
                                        child: PickImage(
                                          disableCropper: true,
                                          aspectRatio: CropAspectRatio(
                                              ratioX: 1, ratioY: 1),
                                          onFilePicked: (image) async {
                                            setState(() {
                                              photo = image;
                                            });
                                            // setState(() {
                                            //   isUploadingImage = true;
                                            // });
                                            // final bool f =
                                            //     await _api.updatePicture(image);
                                            // if (f) {
                                            //   await refetch();
                                            // }
                                            // setState(() {
                                            //   isUploadingImage = false;
                                            // });
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                  icon: Icon(Icons.camera_alt_outlined)),
                              const Gap(10),
                              Expanded(
                                child: TextField(
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  controller: _message,
                                  decoration: InputDecoration(
                                      hintText: "Type your message",
                                      hintStyle: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: grey,
                                      )),
                                ),
                              ),
                              const Gap(10),
                              IconButton.filled(
                                onPressed: () async {
                                  if (_message.text.isEmpty && photo == null) {
                                    Fluttertoast.showToast(
                                        msg: "Write a message");
                                    return;
                                  }
                                  print("ADADS");
                                  Uint8List? photoByte;
                                  if (photo != null) {
                                    photoByte = await photo!.readAsBytes();
                                  }
                                  _firestore.addNewMessage(
                                    senderAvatar: currentUser!.profilePic,
                                    message: _message.text,
                                    refcode: widget.reference,
                                    senderID: currentUser.id,
                                    photo: photo,
                                    senderName: currentUser.fullname,
                                  );
                                  final tempMessage =
                                      _message.text.isEmpty && photoByte != null
                                          ? "Sent an image"
                                          : _message.text;
                                  _message.clear();
                                  photo = null;
                                  setState(() {});
                                  if (receiverTokens.isEmpty) return;
                                  await _notification.sendPushMessage(
                                      registrationTokens: receiverTokens,
                                      title: currentUser.fullname
                                          .capitalizeWords()
                                          .capitalizeWords(),
                                      body: tempMessage);
                                },
                                style: ButtonStyle(
                                    backgroundColor:
                                        WidgetStatePropertyAll(orangePalette)),
                                icon: ImageIcon(
                                  AssetImage("assets/icons/navigation.png"),
                                  size: 15,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
      ),
    );
  }
}
