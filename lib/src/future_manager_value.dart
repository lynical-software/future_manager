import 'package:future_manager/future_manager.dart';

class FutureManagerValue<T> {
  final T? data;
  final FutureManagerError? error;
  final ViewState viewState;
  final ProcessState processState;

  FutureManagerValue({
    required this.data,
    required this.error,
    required this.viewState,
    required this.processState,
  });

  FutureManagerValue.initial()
      : data = null,
        error = null,
        viewState = ViewState.loading,
        processState = ProcessState.idle;

  FutureManagerValue<T> addData(T data) {
    return FutureManagerValue<T>(
      error: null,
      processState: ProcessState.ready,
      data: data,
      viewState: ViewState.ready,
    );
  }

  FutureManagerValue<T> addError(
    FutureManagerError error,
    bool updateViewState,
  ) {
    return FutureManagerValue<T>(
      error: error,
      processState: ProcessState.error,
      data: updateViewState ? null : data,
      viewState: updateViewState ? ViewState.error : viewState,
    );
  }

  FutureManagerValue<T> clearError() {
    return FutureManagerValue(
      error: null,
      processState: processState,
      data: data,
      viewState: viewState,
    );
  }

  FutureManagerValue<T> reset(bool updateViewState) {
    return FutureManagerValue(
      error: updateViewState ? null : error,
      data: updateViewState ? null : data,
      viewState: updateViewState ? ViewState.loading : viewState,
      processState: ProcessState.processing,
    );
  }
}
