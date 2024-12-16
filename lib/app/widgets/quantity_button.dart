import 'package:flutter/material.dart';

// ignore: must_be_immutable
class QuantityButton extends StatefulWidget {
  const QuantityButton(
      {super.key, required this.callback, required this.value, this.limit});
  final int value;
  final int? limit;
  final ValueChanged<int> callback;
  @override
  State<QuantityButton> createState() => _QuantityButtonState();
}

class _QuantityButtonState extends State<QuantityButton> {
  late int value = widget.value;
  add() {
    if (widget.limit == null) {
      setState(() {
        value += 1;
      });
    } else {
      if (value < widget.limit!) {
        value += 1;
      }
    }
    setState(() {});
    widget.callback(value);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: value == 1
              ? null
              : () {
                  setState(() {
                    if (value > 1) {
                      value -= 1;
                    }
                  });
                  widget.callback(value);
                },
          icon: Icon(Icons.remove),
        ),
        Text(
          value.toString(),
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w500),
        ),
        IconButton(
          onPressed: widget.limit == null
              ? add
              : value < widget.limit!
                  ? add
                  : null,
          icon: Icon(Icons.add),
        ),
      ],
    );
  }
}
