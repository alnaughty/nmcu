import 'package:flutter/material.dart';

extension Checker on DateTime {
  bool isSameDay(DateTime date) =>
      day == date.day && year == date.year && month == date.month;

  TimeOfDay toTimeOfDay() {
    return TimeOfDay.fromDateTime(this);
  }
}
