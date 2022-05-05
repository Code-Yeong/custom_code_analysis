import 'package:custom_code_analysis/src/logger/log.dart';

Map<String, List<String>> _existIdList = {};

void clearAllIdRecords() {
  _existIdList.clear();
}

void clearFileIdRecords(String fileName) {
  _existIdList.remove(fileName);
}

void addFileIdRecord(String fileName, String id) {
  List<String> ids = _existIdList[fileName] ?? [];
  ids.add(id);
  _existIdList[fileName] = ids;
}

bool isIdExist(String id) {
  List<String> fileList = _existIdList.keys.toList();
  // logUtil.info("id: $id");
  // logUtil.info("_existIdList: $_existIdList");
  for (final file in fileList) {
    List<String> ids = _existIdList[file] ?? [];
    if (ids.contains(id)) {
      return true;
    }
  }
  return false;
}
