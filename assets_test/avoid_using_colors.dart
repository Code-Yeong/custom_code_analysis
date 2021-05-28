import 'widgets.dart';

void anyWidget(){

  // case-1: 禁止直接调用
  Colors.red;

  // case-2: 禁止直接调用
  Colors();

  // case-3: 禁止直接调用
  MockWidget(color: Colors.red);

  // ignore: avoid_using_colors
  MockWidget(color: Colors.red);

  // ignore: avoid_using_colors
  Colors.white;
}