import 'widgets.dart';

class Test {
  void log() {
    // case-1: uuid不能为null
    RoundButton.circle(uuid: null);

    // case-2: uuid不能为空字符串
    RoundButton.circle(uuid: '');

    // case-3: testUuid不能为空字符串
    RoundButton.circle(uuid: '1231', testUuid: '');

    // case-4: uuid不能重复
    RoundButton.circle( uuid: '1231', testUuid: '1231');

    // case-5: 没有以uuid结尾的字段名
    ClickableWidget(name: '123');

    // case-6: uuid不能为空字符串
    ClickableWidget(uuid: '');

    // case-7: uuid不能为null
    ClickableWidget(uuid: null);

    // 正常
    ClickableWidget(uuid: '4312');

    // case-8: uuid不能重复
    ClickableWidget(uuid: '4312');

    // ignore: clickable_widget_uuid_missing
    ClickableWidget(uuid: null);
  }
}
