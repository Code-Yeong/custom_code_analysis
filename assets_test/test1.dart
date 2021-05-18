import 'test2.dart';

var a = ClickableWidget();

class Test {
  void log() {

    RoundButton.circle(name: 'fdsfds1', uuid: null, testUuid: '');

    RoundButton.circle(name: 'fdsfds2', uuid: '123');

    RoundButton.circle(
      name: 'fdsfds3',
      uuid: '',
      testUuid: '',
    );

    showDialog();
    // ignore: avoid-using-show-dialog
    showDialog();
  }


}

void showDialog(){}
//
// class ClickableWidget {
//   final String uuid;
//
//   ClickableWidget({this.uuid});
// }
//
// class Clickable {
//   final String message;
//
//   const Clickable({this.message});
// }
//
// @Clickable()
// class RoundButton {
//   RoundButton({this.name, this.uuid, this.testUuid});
//
//   final String name;
//   final String uuid;
//   final String testUuid;
//
//   factory RoundButton.circle({String uuid, String name, String testUuid}) {
//     return RoundButton(uuid: uuid);
//   }
// }
