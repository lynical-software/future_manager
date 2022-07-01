import 'package:flutter/material.dart';

import '../future_manager.dart';

class FutureManagerProvider extends InheritedWidget {
  const FutureManagerProvider({
    Key? key,
    required Widget child,
    this.managerLoadingBuilder,
    this.errorBuilder,
    this.onFutureManagerError,
  }) : super(child: child, key: key);

  ///Loading widget use in [Manager] builder class
  final Widget? managerLoadingBuilder;

  ///Error widget use in [Manager] builder class
  final ManagerErrorBuilder? errorBuilder;

  ///A callback function that run if FutureManagerBuilder has an error
  final OnManagerError? onFutureManagerError;

  static FutureManagerProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<FutureManagerProvider>();
  }

  @override
  bool updateShouldNotify(FutureManagerProvider oldWidget) => true;
}
