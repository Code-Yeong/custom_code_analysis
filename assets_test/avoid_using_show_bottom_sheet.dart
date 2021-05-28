import 'widgets.dart';

void testFunc(){
  // case-1: 禁止调用
  showBottomSheet();

  // ignore: avoid_using_show_bottom_sheet
  showBottomSheet();
}