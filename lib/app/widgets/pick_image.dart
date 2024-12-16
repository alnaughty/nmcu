// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nomnom/app/mixins/color_palette.dart';
import 'package:permission_handler/permission_handler.dart';

// ignore: must_be_immutable
class PickImage extends StatefulWidget {
  PickImage(
      {super.key,
      this.onImagePicked,
      this.onFilePicked,
      this.disableCropper = false,
      this.aspectRatio = const CropAspectRatio(ratioX: 1, ratioY: 1)});
  ValueChanged<String>? onImagePicked;
  ValueChanged<File>? onFilePicked;
  final CropAspectRatio aspectRatio;
  final bool disableCropper;
  @override
  State<PickImage> createState() => _PickImageState();
}

class _PickImageState extends State<PickImage> with ColorPalette {
  Future<void> pickImage(ImageSource source) async {
    await ImagePicker().pickImage(source: source).then((image) async {
      if (image != null) {
        CroppedFile? file;
        if (!widget.disableCropper) {
          file = await ImageCropper().cropImage(
            sourcePath: image.path,
            aspectRatio: widget.aspectRatio,
          );
        }

        // Convert the picked file to Base64
        File imageFile = File(file?.path ?? image.path);
        if (widget.onFilePicked != null) {
          widget.onFilePicked!(imageFile);
          if (widget.onImagePicked == null) return;
        }
        List<int> imageBytes = await imageFile.readAsBytes();
        String base64String = base64Encode(imageBytes);

        // Determine the MIME type based on the file extension
        String mimeType = 'image/jpeg'; // Default to JPEG
        if (image.path.endsWith('.png')) {
          mimeType = 'image/png';
        } else if (image.path.endsWith('.gif')) {
          mimeType = 'image/gif';
        } else if (image.path.endsWith('.bmp')) {
          mimeType = 'image/bmp';
        }
        // if (widget.onFileExtPicked != null) {
        //   widget.onFileExtPicked!(Tuple(x: imageFile, y: mimeType));
        // }

        // Construct the full Base64 string with prefix
        String dataUri = 'data:$mimeType;base64,$base64String';
        if (widget.onImagePicked != null) {
          widget.onImagePicked!(dataUri);
        }
        Navigator.of(context).pop();
        // setState(() {
        //   base64Image = dataUri; // Store the Base64 string with prefix
        // });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: scaffoldColor,
        // image: const DecorationImage(
        //   fit: BoxFit.cover,
        //   image: AssetImage(
        //     "assets/images/vector_background.png",
        //   ),
        // ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            ListTile(
              leading: Icon(
                Icons.photo_album_outlined,
                color: Colors.black,
              ),
              contentPadding: EdgeInsets.all(0),
              title: Text(
                "Gallery",
                style: TextStyle(color: Colors.black),
              ),
              onTap: () async {
                final bool isGranted = await Permission.photos.isGranted;
                if (isGranted) {
                  await pickImage(ImageSource.gallery);
                } else {
                  await Permission.photos.onGrantedCallback(() async {
                    await pickImage(ImageSource.gallery);
                  }).request();
                }
              },
            ),
            ListTile(
              leading: Icon(
                Icons.camera_alt_outlined,
                color: Colors.black,
              ),
              contentPadding: EdgeInsets.all(0),
              onTap: () async {
                final bool isGranted = await Permission.camera.isGranted;
                if (isGranted) {
                  await pickImage(ImageSource.camera);
                } else {
                  await Permission.camera.onGrantedCallback(() async {
                    await pickImage(ImageSource.camera);
                  }).request();
                }
              },
              title: Text(
                "Camera",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
