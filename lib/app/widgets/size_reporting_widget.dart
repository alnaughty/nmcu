import 'package:flutter/material.dart';

class SizeReportingWidget extends StatefulWidget {
  const SizeReportingWidget(
      {super.key, required this.child, required this.onSizeChanged});
  final Widget child;
  final ValueChanged<Size> onSizeChanged;
  @override
  // ignore: library_private_types_in_public_api
  _SizeReportingWidgetState createState() => _SizeReportingWidgetState();
}

class _SizeReportingWidgetState extends State<SizeReportingWidget> {
  Size? size;
  final GlobalKey _key = GlobalKey();

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     final renderBox = _key.currentContext?.findRenderObject() as RenderBox?;
  //     if (renderBox != null) {
  //       final size = renderBox.size;
  //       // Call the callback with the size
  //       widget.onSizeChanged.call(size);
  //     }
  //   });
  // }

  Size _oldSize = Size(0, 0);
  void _notifySize() {
    final size = context.size;
    if (_oldSize != size && size != null) {
      _oldSize = size;
      widget.onSizeChanged(size);
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _notifySize());
    return widget.child;
  }
}
