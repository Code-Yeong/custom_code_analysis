import 'widgets.dart';

void testFunc(){
  // case-1: 禁止调用原生API
  showSearch();

  // ignore: avoid_using_show_search
  showSearch();
}