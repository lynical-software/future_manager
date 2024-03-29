import 'package:flutter/material.dart';

import '../future_manager.dart';

/// A widget that build base on the state a [FutureManager]
class FutureManagerBuilder<T extends Object> extends StatefulWidget {
  ///A required [FutureManager] that this widget depends on
  final FutureManager<T> futureManager;

  ///A widget to show when [FutureManager] state is loading
  final Widget? loading;

  ///A widget to show when [FutureManager] state is error
  final ManagerErrorBuilder? error;

  ///A callback function that call when [FutureManager] state is error
  final ManagerErrorListener? onError;

  ///A callback function that call when [FutureManager] state has data
  final void Function(T data)? onData;

  ///A callback function that call when [FutureManager] state has data once
  final void Function(T data)? onReadyOnce;

  ///A widget to show on top of this widget when refreshing
  final Widget Function()? onRefreshing;

  ///A widget to show when [FutureManager] has a data
  final Widget Function(BuildContext context, T data) ready;

  ///Custom builder that mostly use from animation
  final Widget Function(Widget child)? customBuilder;

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
    this.customBuilder,
  }) : super(key: key);
  @override
  State<FutureManagerBuilder<T>> createState() =>
      _FutureManagerBuilderState<T>();
}

class _FutureManagerBuilderState<T extends Object>
    extends State<FutureManagerBuilder<T>> {
  //
  late FutureManagerProvider? managerProvider =
      FutureManagerProvider.of(context);
  bool readyOnceChecked = false;
  late int widgetHash = widget.hashCode;

  late Future<int> _delayFt;

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
          _handleReadyState();
          break;
        case ProcessState.error:
          _handleErrorState();
          break;
      }
    }
  }

  void _handleErrorState() {
    final error = widget.futureManager.error!;
    widget.onError?.call(error);
    if (widget.futureManager.canThisWidgetCallErrorListener(widgetHash) &&
        widget.futureManager.reportError) {
      managerProvider?.onFutureManagerError?.call(error, context);
    }
  }

  void _handleReadyState() {
    final data = widget.futureManager.data!;
    if (widget.onReadyOnce != null && readyOnceChecked == false) {
      readyOnceChecked = true;
      widget.onReadyOnce!.call(data);
    }
    widget.onData?.call(data);
  }

  void checkInitialStatus() {
    if (widget.futureManager.value.processState == ProcessState.processing) {
      return;
    }
    if (widget.futureManager.hasData && widget.futureManager.data != null) {
      _handleReadyState();
    }
    if (widget.futureManager.hasError && widget.futureManager.error != null) {
      _handleErrorState();
    }
  }

  @override
  void initState() {
    _delayFt = Future.microtask(() => 1);
    Future.microtask(() => checkInitialStatus());
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

  late Widget loadingBuilder = managerProvider?.loadingBuilder?.call() ??
      const Center(
        child: CircularProgressIndicator(),
      );

  @override
  Widget build(BuildContext context) {
    //
    Widget managerWidget;

    if (widget.futureManager.preReload) {
      managerWidget = FutureBuilder(
        future: _delayFt,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return _buildWidgetByState();
          }
          return loadingBuilder;
        },
      );
    } else {
      managerWidget = _buildWidgetByState();
    }

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
    Widget child = () {
      switch (widget.futureManager.value.viewState) {
        case ViewState.loading:
          if (widget.loading != null) {
            return widget.loading!;
          }
          return loadingBuilder;

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
    }();

    if (widget.customBuilder != null) {
      return widget.customBuilder!(child);
    }
    return child;
  }
}
