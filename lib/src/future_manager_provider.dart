import 'package:flutter/material.dart';

import '../future_manager.dart';

class FutureManagerProvider extends InheritedWidget {
  const FutureManagerProvider({
    Key? key,
    required Widget child,
    this.loadingBuilder,
    this.errorBuilder,
    this.onFutureManagerError,
  }) : super(child: child, key: key);

  ///Loading widget use in [Manager] builder class
  final Widget Function()? loadingBuilder;

  ///Error widget use in [Manager] builder class
  final ManagerErrorBuilderProvider? errorBuilder;

  ///A callback function that run if FutureManagerBuilder has an error
  final ManagerErrorListenerProvider? onFutureManagerError;

  static FutureManagerProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<FutureManagerProvider>();
  }

  @override
  bool updateShouldNotify(FutureManagerProvider oldWidget) => true;
}
