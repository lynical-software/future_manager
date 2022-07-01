import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

typedef FutureFunction<T> = Future<T> Function();
typedef SuccessCallBack<T> = FutureOr<T> Function(T);
typedef ErrorCallBack = void Function(FutureManagerError);
typedef ManagerProcessListener<T> = void Function(ProcessState, T?);
//
typedef OnManagerError = void Function(FutureManagerError, BuildContext);
typedef ManagerErrorBuilder = Widget Function(
    FutureManagerError, AsyncCallback?);

Widget _emptyErrorFn(_) {
  return const SizedBox();
}

// ignore: constant_identifier_names
const EmptyErrorFunction = _emptyErrorFn;

///A state that control the state of our manager's UI
enum ViewState {
  loading,
  ready,
  error,
}

///A state that indicate the state of our manager, doesn't reflect on UI
enum ProcessState {
  idle,
  processing,
  ready,
  error,
}

class FutureManagerError {
  final Object exception;
  final StackTrace? stackTrace;

  const FutureManagerError({required this.exception, this.stackTrace});

  @override
  String toString() {
    return exception.toString();
  }
}
