import 'widgets.dart';

void testFunc(){
  // case-1: 禁止调用原生API
  showGeneralDialog();

  // ignore: avoid_using_show_general_dialog
  showGeneralDialog();
}