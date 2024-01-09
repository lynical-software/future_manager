import 'dart:async';
import 'dart:collection';
import 'dart:developer';

import 'package:flutter/material.dart';

import 'future_manager_builder.dart';
import 'future_manager_value.dart';
import 'manager_cache.dart';
import 'type.dart';

///[FutureManager] is a wrap around [Future] and [ChangeNotifier]
///
///[FutureManager] use [FutureManagerBuilder] instead of FutureBuilder to handle data
///
///[FutureManager] provide a method [execute] to handle or call async function
class FutureManager<T extends Object>
    extends ValueNotifier<FutureManagerValue<T>> {
  ///A future function that return the type of T
  final FutureFunction<T>? futureFunction;

  ///A function that call after [execute] is success and you want to manipulate data before
  ///adding it to manager
  final SuccessCallBack<T>? onSuccess;

  ///A function that call after everything is done
  final VoidCallback? onDone;

  /// A function that call after there is an error in our [execute]
  final ErrorCallBack? onError;

  /// if [reloading] is true, every time there's a new data, FutureManager will reset it's state to loading
  /// default value is [false]
  final bool reloading;

  /// if [reportError] is true, every time there's an error, We will call a manager error callback
  final bool reportError;

  ///An option to cache Manager's data
  ///This is not a storage cache or memory cache.
  ///Data is cache within lifetime of FutureManager only
  final ManagerCacheOption cacheOption;

  ///Create a FutureManager instance, You can define a [futureFunction] here then [execute] will be call immediately
  FutureManager({
    this.futureFunction,
    this.reloading = true,
    this.reportError = true,
    this.cacheOption = const ManagerCacheOption.non(),
    this.onSuccess,
    this.onDone,
    this.onError,
  }) : super(FutureManagerValue<T>.initial()) {
    if (futureFunction != null) {
      execute(
        futureFunction!,
        reloading: reloading,
        onSuccess: onSuccess,
        onDone: onDone,
        onError: onError,
      );
    }
  }

  ///The Future that this class is doing in [execute]
  ///Sometime you want to use [FutureManager] class with FutureBuilder, so you can use this field
  Future<T>? future;

  ///Manager's data
  T? get data => value.data;
  FutureManagerError? get error => value.error;

  //A field for checking state of Manager
  bool get isRefreshing =>
      hasDataOrError && value.processState == ProcessState.processing;
  bool get hasDataOrError => (hasData || hasError);
  bool get hasData => data != null;
  bool get hasError => error != null;
  bool _disposed = false;

  ///
  bool _reload = false;

  ///Indicate if manager is doing reloading before view state or process state is updating
  bool get preReload => _reload;
  //
  final Queue<int> _builderHashCode = Queue();

  //Cache option
  int? _lastCacheDuration;

  ///Short method for FutureManagerBuilder
  Widget when({
    required Widget Function(T data) ready,
    void Function(T data)? onReadyOnce,
    Widget? loading,
    ManagerErrorBuilder? error,
    ManagerErrorListener? onError,
  }) {
    return FutureManagerBuilder<T>(
      futureManager: this,
      onReadyOnce: onReadyOnce,
      ready: (context, data) => ready(data),
      loading: loading,
      error: error,
      onError: onError,
    );
  }

  ///Display nothing on `loading` and `error`
  Widget listen({
    required Widget Function(T data) ready,
    Widget loading = const SizedBox(),
    Widget Function(FutureManagerError error) error = EmptyErrorFunction,
  }) {
    return FutureManagerBuilder<T>(
      futureManager: this,
      ready: (context, data) => ready(data),
      loading: loading,
      error: error,
    );
  }

  ///Always display child even `loading` or `error`
  Widget build(Widget Function(T? data) builder) {
    return AnimatedBuilder(
      animation: this,
      builder: (context, child) {
        return builder(data);
      },
    );
  }

  ///refresh is a function that call [execute] again,
  ///but doesn't reserve configuration
  ///return null if [futureFunction] hasn't been initialize
  late Future<T?> Function({
    bool? reloading,
    SuccessCallBack<T>? onSuccess,
    VoidCallback? onDone,
    ErrorCallBack? onError,
    bool throwError,
    bool useCache,
  }) refresh = _emptyRefreshFunction;

  Future<T?> _emptyRefreshFunction(
      {reloading, onSuccess, onDone, onError, throwError, useCache}) async {
    log("refresh() is depend on execute(),"
        " You need to call execute() once before you can call refresh()");
    return null;
  }

  Future<T?> execute(
    FutureFunction<T> futureFunction, {
    bool? reloading,
    SuccessCallBack<T>? onSuccess,
    VoidCallback? onDone,

    ///A callback called after exception is caught
    ///You can return `FutureManagerError` to override existing error
    ///Or return `false` to ignore the error and keep the current state
    ErrorCallBack? onError,

    ///Throw error instead of catching it
    bool throwError = false,
    bool useCache = true,
  }) async {
    refresh = ({
      reloading,
      onSuccess,
      onDone,
      onError,
      throwError = false,
      useCache = false,
    }) async {
      bool shouldReload = reloading ?? this.reloading;
      SuccessCallBack<T>? successCallBack = onSuccess ?? this.onSuccess;
      ErrorCallBack? errorCallBack = onError ?? this.onError;
      VoidCallback? onOperationDone = onDone ?? this.onDone;
      bool shouldThrowError = throwError;
      //useCache is always default to `false` if we call refresh directly
      if (_enableCache && useCache) {
        return data;
      }
      //
      bool triggerError = true;
      if (hasDataOrError) {
        triggerError = shouldReload;
        _reload = shouldReload;
      }
      try {
        await resetData(updateViewState: shouldReload);
        future = futureFunction.call();
        T result = await future!;
        if (successCallBack != null) {
          result = await successCallBack.call(result);
        }
        updateData(result);
        return result;
      } catch (exception, stackTrace) {
        var error = FutureManagerError(
          exception: exception,
          stackTrace: stackTrace,
        );

        var errorCallbackResult = await errorCallBack?.call(error);

        if (errorCallbackResult is FutureManagerError) {
          error = errorCallbackResult;
        }

        ///Only add error if result isn't false
        if (errorCallbackResult != false) {
          ///Only update viewState if [triggerError] is true
          addError(error, updateViewState: triggerError);
          if (shouldThrowError) {
            rethrow;
          }
        } else if (hasData) {
          updateData(data);
        }
        return null;
      } finally {
        _reload = false;
        onOperationDone?.call();
      }
    };
    return refresh(
      reloading: reloading,
      onSuccess: onSuccess,
      onDone: onDone,
      onError: onError,
      throwError: throwError,
      useCache: useCache,
    );
  }

  bool get _enableCache {
    if (_lastCacheDuration == null) return false;

    bool lastCacheIsExpired() {
      int now = DateTime.now().millisecondsSinceEpoch;
      int expiredTime =
          _lastCacheDuration! + cacheOption.cacheTime.inMilliseconds;
      return now > expiredTime;
    }

    return cacheOption.useCache && hasData && !lastCacheIsExpired();
  }

  ///Similar to [updateData] but provide current current [data] in Manager as param.
  ///return updated [data] result once completed.
  Future<T?> modifyData(FutureOr<T> Function(T? data) onChange) async {
    T? data = await onChange(value.data);
    return updateData(data);
  }

  ///Update current data in our Manager.
  ///Ignore if data is null.
  ///Use [resetData] instead if you want to reset to [loading] state
  T? updateData(T? data, {bool useMicrotask = false}) {
    if (_disposed) return null;
    if (data != null) {
      if (useMicrotask) {
        Future.microtask(() => value = value.addData(data));
      } else {
        value = value.addData(data);
      }
      _updateLastCacheDuration();
      return data;
    }
    return null;
  }

  void _updateLastCacheDuration() {
    if (cacheOption.useCache) {
      _lastCacheDuration = DateTime.now().millisecondsSinceEpoch;
    }
  }

  ///Clear the error on this manager
  ///Only work when ViewState isn't error
  ///Best use case with Pagination when there is an error and you want to clear the error to show loading again
  void clearError() {
    if (_disposed) return;
    if (value.viewState != ViewState.error) {
      value = value.clearError();
    }
  }

  ///Add [error] to manager, show an error widget if [updateViewState] is true
  void addError(
    Object error, {
    bool updateViewState = true,
    bool useMicrotask = false,
  }) {
    FutureManagerError err = error is! FutureManagerError
        ? FutureManagerError(exception: error)
        : error;
    if (_disposed) return;
    if (useMicrotask) {
      Future.microtask(() => value = value.addError(err, updateViewState));
    } else {
      value = value.addError(err, updateViewState);
    }
  }

  ///Reset all [data] and [error] to [loading] state if [updateViewState] is true only.
  ///if [updateViewState] is false, only notifyListener and update ManagerProcessState.
  Future<void> resetData({bool updateViewState = true}) async {
    Future.microtask(() {
      if (_disposed) return;
      value = value.reset(updateViewState);
    });
  }

  void addCustomListener(VoidCallback listener, int builderHashCode) {
    _builderHashCode.addFirst(builderHashCode);
    super.addListener(listener);
  }

  void removeCustomListener(VoidCallback listener, int builderHashCode) {
    _builderHashCode.remove(builderHashCode);
    super.removeListener(listener);
  }

  ///Add a listener that return a remove listener function
  VoidCallback eventListener(void Function(T? data) fn) {
    void listener() {
      fn.call(this.data);
    }

    super.addListener(listener);
    return () => super.removeListener(listener);
  }

  bool canThisWidgetCallErrorListener(int hashCode) {
    return _builderHashCode.first == hashCode;
  }

  @override
  String toString() {
    String logContent =
        "Data: $data, Error: $error, ViewState: ${value.viewState}, ProcessState: ${value.processState}";
    if (_lastCacheDuration != null) {
      logContent +=
          ", cacheDuration: ${DateTime.fromMillisecondsSinceEpoch(_lastCacheDuration!)}";
    }
    return logContent;
  }

  @override
  void dispose() {
    _lastCacheDuration = null;
    _disposed = true;
    super.dispose();
  }
}
