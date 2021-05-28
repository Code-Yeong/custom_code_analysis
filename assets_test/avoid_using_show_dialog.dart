import 'widgets.dart';

void testFunc(){
  // case-1: 禁止调用原生API
  showDialog();

  // ignore: avoid_using_show_dialog
  showDialog();
}