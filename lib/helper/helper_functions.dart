/*
These are some helpful functions used across the app
*/

import 'package:intl/intl.dart';

// convert string to a double
double convertStringToDouble(String string) {
  double? amount = double.tryParse(string);
  return amount ?? 0;
}

//format double amount into dollars & cents
String formatAmount(double amount) {
  final format = NumberFormat.currency(locale: 'en_NG', name: 'NGN', decimalDigits: 2);
  return format.format(amount);
}

// calculate the number of months since the start month
int calculateMonthCount(int startYear, startMonth, currentYear, currentMonth){
  int monthCount = (currentYear - startMonth) * 12 - currentMonth - startMonth + 1;
  return monthCount;
}