import 'widgets.dart';

void testFunc(){
  // case-1: 禁止调用原生API
  showTimePicker();

  // ignore: avoid_using_show_time_picker
  showTimePicker();
}