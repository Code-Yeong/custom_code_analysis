import 'package:uuid/uuid.dart';

var a = ClickableWidget();

class ViewModel {
  void log() {
    RoundButton.circle(name: '12312', uuid: 'abcde');

    RoundButton.circle(name: 'fdsfds1', uuid: null);

    RoundButton.circle(name: 'fdsfds2', uuid: 'c7361597492c4184a56a8b8d4e5e6ae9');

    RoundButton.circle(
      name: 'fdsfds3',
      uuid: '',
    );
  }
}

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
  RoundButton({this.name, this.uuid});

  final String name;
  final String uuid;

  factory RoundButton.circle({String uuid, String name}) {
    return RoundButton(uuid: uuid);
  }
}
