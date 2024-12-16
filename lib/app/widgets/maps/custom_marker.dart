import 'package:flutter/material.dart';
import 'package:nomnom/app/mixins/color_palette.dart';
import 'package:nomnom/app/widgets/maps/image_builder.dart';

class CustomMarkerNom extends StatefulWidget {
  const CustomMarkerNom(
      {super.key,
      this.size = 65,
      this.color = Colors.red,
      this.fullname,
      this.avatar});
  final double size;
  final Color color;
  final String? avatar;
  final String? fullname;
  @override
  State<CustomMarkerNom> createState() => _CustomMarkerNomState();
}

class _CustomMarkerNomState extends State<CustomMarkerNom> with ColorPalette {
  late final double size = widget.size;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Positioned(
            child: Image.asset(
              "assets/icons/location-pin.png",
              fit: BoxFit.fitHeight,
              color: widget.color,
              height: size,
            ),
            // child: SvgPicture.asset(
            //   "assets/icons/location.svg",
            //   color: widget.color,
            //   height: size,
            //   fit: BoxFit.fitHeight,
            // ),
          ),
          if (widget.avatar != null && widget.fullname != null) ...{
            Positioned(
              top: size * .09,
              child: CustomImageBuilder(
                avatar: widget.avatar,
                placeHolderName: widget.fullname![0],
                size: size * .6,
              ),
            ),
          },
          // Positioned(
          //   top: 11,
          //   child: CustomImageBuilder(
          //     avatar: widget.networkImage,
          //     placeHolderName: widget.fullname[0],
          //     size: 40,
          //   ),
          // ),
        ],
      ),
    );
  }
}
