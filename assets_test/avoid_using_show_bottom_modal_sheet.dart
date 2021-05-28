import 'widgets.dart';

void testFunc(){
  // case-1: 禁止调用
  showModalBottomSheet();

  // ignore: avoid_using_show_bottom_modal_sheet
  showModalBottomSheet();
}