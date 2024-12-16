import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CustomImageBuilder extends StatefulWidget {
  const CustomImageBuilder({
    super.key,
    required this.avatar,
    required this.placeHolderName,
    this.size = 45,
  });
  final String? avatar;
  final String placeHolderName;
  final double size;
  @override
  State<CustomImageBuilder> createState() => _CustomImageBuilderState();
}

class _CustomImageBuilderState extends State<CustomImageBuilder> {
  late final double size = widget.size;
  @override
  Widget build(BuildContext context) {
    // print(widget.placeHolderName);
    return ClipRRect(
      borderRadius: BorderRadius.circular(size),
      child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300, width: 2.5)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(200),
            child: widget.avatar == null
                ? Center(
                    child: Text(
                      widget.placeHolderName.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : CachedNetworkImage(
                    imageUrl: widget.avatar!,
                    height: size,
                    width: size,
                    fit: BoxFit.cover,
                  ),
          )),
    );
  }
}
