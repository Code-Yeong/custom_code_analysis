class ClickableWidget {}

class ViewModle {
  void log() {
    print("object");
    ClickableWidget();
    RoundButton();
  }
}


class Clickable{
  final String name;
  const Clickable({this.name});
}

@Clickable(name: 'RoundButton')
class RoundButton {}