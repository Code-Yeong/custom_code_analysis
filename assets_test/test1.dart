class ClickableWidget {
  final String uuid;
  ClickableWidget({this.uuid});
}

class ViewModel {
  void log() {
    ClickableWidget();
    RoundButton.circle(name: '12312', uuid: 'abcde');
  }
}

class Clickable {
  final String message;

  const Clickable({this.message});
}

@Clickable()
class RoundButton {
  RoundButton({this.name, this.uuid});

  final String name;
  final String uuid;

  factory RoundButton.circle({String uuid, String name}) {
    return RoundButton(uuid: uuid);
  }
}
