import 'package:flutter/material.dart';

class DateUtilsHelper {
  static Future<DateTime?> selectBirthDate(BuildContext context) async {
    return await showDatePicker(
      context: context,
      lastDate: DateTime.now().subtract(Duration(days: 6570)),
      initialDate: DateTime.now().subtract(Duration(days: 6570)),
      firstDate: DateTime(1940),
    );
  }
}
