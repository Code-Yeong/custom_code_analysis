class ClickableWidget {}

class ViewModle {
  void log() {
    print("objectssd");
    RoundButton.circle();
  }
}

class Clickable {
  final String name;

  const Clickable({this.name});
}

@Clickable(name: 'RoundButton')
class RoundButton {
  RoundButton();

  factory RoundButton.circle() {
    return RoundButton();
  }
}
