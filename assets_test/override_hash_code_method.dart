import 'widgets.dart';

// case-1: height字段没有hashCode
class ClazzPicture extends ReduxViewModel {
  ClazzPicture({this.height, this.width, this.picture});

  final String? picture;
  final int? width;
  final int? height;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClazzPicture && runtimeType == other.runtimeType && picture == other.picture && width == other.width && height == other.height;

  @override
  int get hashCode => picture.hashCode ^ width.hashCode;
}

// case-2: 缺少hashCode
class ClazzBook extends ReduxViewModel {
  ClazzBook({this.height, this.width, this.picture});

  final String? picture;
  final int? width;
  final int? height;
}

// ignore: override_hash_code_method
class ClazzCar extends ReduxViewModel {
  ClazzCar({this.height, this.width, this.picture});

  final String? picture;
  final int? width;
  final int? height;
}

class ClazzHouse extends ReduxViewModel {
  ClazzHouse({this.height, this.width, this.picture});

  final String? picture;
  final int? width;
  final int? height;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClazzHouse && runtimeType == other.runtimeType && picture == other.picture && width == other.width && height == other.height;

  @override
  int get hashCode => picture.hashCode ^ width.hashCode ^ height.hashCode;
}
