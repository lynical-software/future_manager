import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:future_manager/future_manager.dart';

///Find more test at example folder
void main() {
  FutureManager<int> futureManager = FutureManager();

  test("Test future manger with value", () async {
    late int value;
    await futureManager.execute(() async {
      await Future.delayed(const Duration(seconds: 2));
      return 10;
    }, onSuccess: (data) {
      value = data;
      return value;
    });
    expect(value, 10);
  });

  test("Test future manger with error", () async {
    int? value;
    await futureManager.execute(() async {
      await Future.delayed(const Duration(seconds: 2));
      throw const HttpException("Unable to process");
    }, onSuccess: (data) {
      value = data;
      return value!;
    });
    expect(value, null);
    expect(futureManager.error!.runtimeType, FutureManagerError);
    expect(futureManager.error!.exception.runtimeType, HttpException);
  });
}
