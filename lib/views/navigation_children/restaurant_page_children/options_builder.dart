import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:nomnom/app/extensions/string_ext.dart';
import 'package:nomnom/app/mixins/color_palette.dart';
import 'package:nomnom/app/widgets/custom_radio_button.dart';
import 'package:nomnom/models/merchant/option.dart';
import 'package:nomnom/models/merchant/variation.dart';

class OptionsBuilder extends StatefulWidget {
  const OptionsBuilder(
      {super.key, required this.callback, required this.option});
  final ValueChanged<OptionSelection> callback;
  final Option option;
  @override
  State<OptionsBuilder> createState() => _OptionsBuilderState();
}

class _OptionsBuilderState extends State<OptionsBuilder> with ColorPalette {
  Variation? selectedVariant;
  // late final List<Map<int, int>> _selectedOptions = List.generate(widget.option.variations.length, (i) => Se);
  // bool contains(int i) {
  //   final bool containsKey = _selectedOptions.any((map) => map.containsKey(i));
  //   return containsKey;
  // }
  bool isSelected(int index) =>
      selectedVariant?.id == widget.option.variations[index].id;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      selectedVariant = widget.option.variations.first;
      if (selectedVariant != null) {
        widget.callback(
          OptionSelection(
            optionId: widget.option.id,
            variation: selectedVariant!,
            optionName: widget.option.name,
          ),
        );
      }
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // decoration: BoxDecoration(
      //   color: orangePalette.withOpacity(.1),
      //   borderRadius: BorderRadius.circular(10),
      // ),
      // padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              "Choose your ${widget.option.name}",
            ),
            titleTextStyle: TextStyle(
                fontFamily: "Poppins",
                color: Colors.black,
                fontWeight: FontWeight.w500,
                fontSize: 15),
            subtitle: Text(
              "Choose one",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 85,
              ),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  color: textField.withOpacity(.7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "1 Required",
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          const Gap(10),
          ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.all(0),
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (__, ix) {
                final Variation variation = widget.option.variations[ix];
                return Row(
                  children: [
                    Expanded(
                      child: CustomRadioButton(
                          withSplash: false,
                          currentState: selectedVariant?.id ==
                              widget.option.variations[ix].id,
                          callback: (bool f) {
                            // final bool isContained = contains(i);
                            selectedVariant = widget.option.variations[ix];
                            if (selectedVariant != null) {
                              widget.callback(OptionSelection(
                                  optionId: widget.option.id,
                                  variation: selectedVariant!,
                                  optionName: widget.option.name));
                            }
                            if (mounted) setState(() {});
                          },
                          label: widget.option.variations[ix].title
                              .capitalizeWords()),
                    ),
                    const Gap(10),
                    Text(
                        variation.price <= 0
                            ? "Free"
                            : "+₱ ${variation.price.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontFamily: "",
                        ))
                  ],
                );
              },
              separatorBuilder: (_, i) => const Gap(10),
              itemCount: widget.option.variations.length),
          const Gap(20),
          // Text(
          //   option.name.capitalize(),
          //   style: TextStyle(
          //     fontSize: 17,
          //     fontWeight: FontWeight.w500,
          //   ),
          // ),
          // Text(option.description,)
        ],
      ),
    );
  }
}

// extension PARSE on Variation {}
class OptionSelection {
  final int optionId;
  final String optionName;
  final Variation variation;
  const OptionSelection(
      {required this.optionId,
      required this.variation,
      required this.optionName});
  Map<String, dynamic> toJson() => {
        "name": optionName,
        "option_id": optionId,
        "variation": variation.toJson(),
      };
  @override
  String toString() => "${toJson()}";
  // factory OptionSelection.fromVariation(Variation variation) =>
  //     OptionSelection(optionId: variation.optionId, variationId: variation.id);
}
