import 'widgets.dart';

void anyWidget() {
  // case-1: 禁止直接调用
  Color(0xFFFFFF);

  // case-2: 禁止直接调用
  MockWidget(color: Color(0xFFFFFF));

  // ignore: avoid_using_color
  MockWidget(color: Color(0xFFFFFF));

  // ignore: avoid_using_color
  Color(0xFFFFFF);
}
