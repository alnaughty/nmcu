import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:nomnom/app/extensions/color_ext.dart';
import 'package:nomnom/app/extensions/date_ext.dart';
import 'package:nomnom/app/extensions/time_ext.dart';
import 'package:nomnom/app/mixins/color_palette.dart';
import 'package:nomnom/views/auth_children/account_completion_page.dart';
import 'package:nomnom/views/navigation_children/restaurant_page_children/cart_page_children/cart_menu_listing.dart';

class ChangeTypeModal extends StatefulWidget {
  const ChangeTypeModal(
      {super.key,
      required this.onDateChanged,
      required this.onTimeChanged,
      required this.initDate,
      required this.initDeliveryType,
      required this.initTime,
      required this.onTypeChanged});
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<TimeOfDay> onTimeChanged;
  final ValueChanged<DeliveryType> onTypeChanged;
  final DateTime initDate;
  final TimeOfDay initTime;
  final DeliveryType initDeliveryType;
  @override
  State<ChangeTypeModal> createState() => _ChangeTypeModalState();
}

class _ChangeTypeModalState extends State<ChangeTypeModal>
    with ColorPalette, SingleTickerProviderStateMixin {
  final EasyDatePickerController _datePickerController =
      EasyDatePickerController();
  final DateFormat format = DateFormat('EEE, dd MMM');
  late final TabController controller = TabController(
      length: deliveryType.length,
      vsync: this,
      initialIndex: selectedType.id - 1);
  late DateTime date = widget.initDate;
  late TimeOfDay time = widget.initTime;
  late TimeOfDay tempTime = widget.initTime;
  late DeliveryType selectedType = widget.initDeliveryType;
  final List<DeliveryType> deliveryType = [
    DeliveryType(
      id: 1,
      photoPath: "assets/images/food_delivery.png",
      title: "Food Delivery",
    ),
    DeliveryType(
      id: 2,
      photoPath: "assets/images/food_pick-up.png",
      title: "Food Pick-up",
    ),
  ];
  int showState = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Column(
          children: [
            Center(
              child: Container(
                width: 80,
                height: 5,
                decoration: BoxDecoration(
                    color: textField.darken(),
                    borderRadius: BorderRadius.circular(6)),
              ),
            ),
            const Gap(10),
            TabBar(
                labelColor: orangePalette,
                indicatorColor: orangePalette,
                indicatorWeight: 4,
                indicatorSize: TabBarIndicatorSize.tab,
                controller: controller,
                dividerColor: Colors.transparent,
                onTap: (int index) {
                  setState(() {
                    selectedType = deliveryType[index];
                  });
                  // widget.onTypeChanged(selectedType);
                },
                tabs: deliveryType
                    .map((e) => Tab(
                          text: e.title,
                        ))
                    .toList()),
            const Gap(10),
            AnimatedSwitcher(
              duration: 600.ms,
              child: showState == 0
                  ? Column(
                      children: [
                        titler(
                          title: "Delivery date",
                          icon: Icon(Icons.calendar_today_rounded),
                          val: format.format(date),
                          onPressed: () {
                            setState(() {
                              showState = 1;
                            });
                          },
                        ),
                        const Gap(10),
                        titler(
                          onPressed: () {
                            setState(() {
                              showState = 2;
                            });
                          },
                          title: "Delivery time",
                          icon: Icon(Icons.access_time),
                          val: time.format(context),
                        )
                      ],
                    )
                  : AnimatedContainer(
                      height: showState == 2 ? 260 : 220,
                      duration: 800.ms,
                      child: AnimatedSwitcher(
                        duration: 600.ms,
                        child: showState == 1
                            ? EasyDateTimeLinePicker(
                                controller: _datePickerController,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(30.days),
                                focusedDate: date,
                                currentDate: date,
                                onDateChange: (DateTime d) {
                                  setState(() {
                                    date = d;
                                    showState = 0;
                                  });
                                },
                              )
                            : Column(
                                children: [
                                  Expanded(
                                    child: CupertinoDatePicker(
                                      use24hFormat: false,
                                      minimumDate: DateTime.now(),
                                      initialDateTime: time.toDateTime(),
                                      mode: CupertinoDatePickerMode.time,
                                      onDateTimeChanged: (n) {
                                        setState(() {
                                          tempTime = n.toTimeOfDay();
                                        });
                                      },
                                    ),
                                  ),
                                  const Gap(5),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        time = tempTime;
                                        showState = 0;
                                      });
                                    },
                                    child: Text("Submit"),
                                  )
                                ],
                              ),
                      ),
                    ),
            ),
            const Gap(20),
            MaterialButton(
              height: 50,
              color: orangePalette,
              onPressed: () {
                widget.onDateChanged(date);
                widget.onTimeChanged(time);
                widget.onTypeChanged(selectedType);
                Navigator.of(context).pop();
              },
              child: Center(
                child: Text(
                  "Update",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            // CupertinoDatePicker(onDateTimeChanged: (date) {}),
            const SafeArea(
              child: SizedBox(),
            )
          ],
        ),
      ),
    );
  }

  Widget titler(
          {required String title,
          required Widget icon,
          required String val,
          Function()? onPressed}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: grey,
            ),
          ),
          MaterialButton(
            onPressed: onPressed,
            elevation: 0,
            splashColor: grey.withOpacity(.1),
            padding: EdgeInsets.zero,
            color: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    icon,
                    const Gap(10),
                    Text(
                      val,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ],
                ),
                Icon(
                  Icons.chevron_right_outlined,
                  color: Colors.black,
                )
              ],
            ),
          )
        ],
      );
}
