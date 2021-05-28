class ClickableWidget {
  final String uuid;
  final String name;

  ClickableWidget({this.uuid, this.name});
}

class Clickable {
  final String message;

  const Clickable({this.message});
}

@Clickable()
class RoundButton {
  RoundButton({this.name, this.uuid, this.testUuid});

  final String name;
  final String uuid;
  final String testUuid;

  factory RoundButton.circle({String uuid, String name, String testUuid}) {
    return RoundButton(uuid: uuid);
  }
}

class BaseColor {}

class Colors extends BaseColor {
  static Colors red = Colors();
  static Colors white = Colors();
}

class Color extends BaseColor {
  Color(int value);
}

class MockWidget {
  MockWidget({this.color});

  final BaseColor color;
}

void showModalBottomSheet() {}

void showBottomSheet() {}

void showDatePicker() {}

void showDateRangePicker() {}

void showDialog() {}

void showGeneralDialog() {}

void showMenu() {}

void showSearch() {}

void showTimePicker() {}

class ReduxViewModel {}
