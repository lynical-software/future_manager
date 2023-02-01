import 'package:flutter/material.dart';

import '../future_manager.dart';

/// A widget that build base on the state a [FutureManager]
class FutureManagerBuilder<T extends Object> extends StatefulWidget {
  ///A required [FutureManager] that this widget depends on
  final FutureManager<T> futureManager;

  ///A widget to show when [FutureManager] state is loading
  final Widget? loading;

  ///A widget to show when [FutureManager] state is error
  final Widget Function(FutureManagerError)? error;

  ///A callback function that call when [FutureManager] state is error
  final void Function(FutureManagerError)? onError;

  ///A callback function that call when [FutureManager] state has data
  final void Function(T)? onData;

  ///A callback function that call when [FutureManager] state has data once
  final void Function(T)? onReadyOnce;

  ///A widget to show on top of this widget when refreshing
  final Widget Function()? onRefreshing;

  ///A widget to show when [FutureManager] has a data
  final Widget Function(BuildContext, T) ready;

  // A widget that build base on the state a [FutureManager]
  const FutureManagerBuilder({
    Key? key,
    required this.futureManager,
    required this.ready,
    this.loading,
    this.error,
    this.onError,
    this.onRefreshing,
    this.onData,
    this.onReadyOnce,
  }) : super(key: key);
  @override
  State<FutureManagerBuilder<T>> createState() =>
      _FutureManagerBuilderState<T>();
}

class _FutureManagerBuilderState<T extends Object>
    extends State<FutureManagerBuilder<T>> {
  //
  FutureManagerProvider? managerProvider;
  bool readyOnceChecked = false;
  late int widgetHash = widget.hashCode;

  //
  void managerListener() {
    if (mounted) {
      setState(() {});
      ProcessState state = widget.futureManager.value.processState;
      switch (state) {
        case ProcessState.idle:
          break;
        case ProcessState.processing:
          break;
        case ProcessState.ready:
          T? data = widget.futureManager.data;
          if (data != null) {
            if (!readyOnceChecked && widget.onReadyOnce != null) {
              readyOnceChecked = true;
              widget.onReadyOnce?.call(data);
            }
            widget.onData?.call(data);
          }
          break;
        case ProcessState.error:
          final error = widget.futureManager.error;
          if (error != null) {
            widget.onError?.call(error);
            if (widget.futureManager
                .canThisWidgetCallErrorListener(widgetHash)) {
              managerProvider?.onFutureManagerError?.call(error, context);
            }
          }
          break;
      }
    }
  }

  void checkOnReadyOnce() {
    if (widget.futureManager.hasData && widget.onReadyOnce != null) {
      readyOnceChecked = true;
      widget.onReadyOnce?.call(widget.futureManager.data!);
    }
  }

  @override
  void initState() {
    checkOnReadyOnce();
    widget.futureManager.addCustomListener(managerListener, widgetHash);
    super.initState();
  }

  @override
  void dispose() {
    widget.futureManager.removeCustomListener(managerListener, widgetHash);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant FutureManagerBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.futureManager != oldWidget.futureManager) {
      oldWidget.futureManager
          .removeCustomListener(managerListener, oldWidget.hashCode);
      widget.futureManager.addCustomListener(managerListener, widgetHash);
    }
  }

  @override
  Widget build(BuildContext context) {
    managerProvider = FutureManagerProvider.of(context);
    final Widget managerWidget = _buildWidgetByState();

    if (widget.onRefreshing == null) {
      return managerWidget;
    }

    //
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        managerWidget,
        if (widget.futureManager.isRefreshing &&
            widget.onRefreshing != null) ...[
          widget.onRefreshing!.call(),
        ],
      ],
    );
  }

  Widget _buildWidgetByState() {
    switch (widget.futureManager.value.viewState) {
      case ViewState.loading:
        if (widget.loading != null) {
          return widget.loading!;
        }
        return managerProvider?.loadingBuilder?.call() ??
            const Center(child: CircularProgressIndicator());

      case ViewState.error:
        final error = widget.futureManager.error!;
        if (widget.error != null) {
          return widget.error!.call(error);
        }
        return managerProvider?.errorBuilder?.call(
              error,
              widget.futureManager.refresh,
            ) ??
            Center(
              child: Text(
                error.toString(),
                textAlign: TextAlign.center,
              ),
            );
      case ViewState.ready:
        return widget.ready(context, widget.futureManager.data!);
    }
  }
}
