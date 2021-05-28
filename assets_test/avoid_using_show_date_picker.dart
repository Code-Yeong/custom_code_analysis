import 'widgets.dart';

void testFunc() {

  // case-1: 禁止调用原生API
  showDatePicker();

  // ignore: avoid_using_show_date_picker
  showDatePicker();
}