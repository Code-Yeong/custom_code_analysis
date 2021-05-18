
class ClickableWidget {
  final String uuid;

  ClickableWidget({this.uuid});
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

  factory RoundButton.circle({String uuid, String name,
    String testUuid}) {
    return RoundButton(uuid: uuid);
  }
}
