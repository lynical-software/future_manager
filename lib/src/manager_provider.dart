import 'package:flutter/material.dart';

import '../future_manager.dart';

///Mixin on StatefulWidget's state class to access [ManagerRef]
mixin ManagerProviderMixin<T extends StatefulWidget> on State<T> {
  final ManagerRef ref = ManagerRef();

  @override
  void dispose() {
    ref._dispose();
    super.dispose();
  }
}

///Extends this class instead of Stateless widget to access [ManagerRef]
abstract class ManagerConsumer extends StatefulWidget {
  const ManagerConsumer({Key? key}) : super(key: key);

  Widget build(BuildContext context, ManagerRef ref);

  @override
  State<ManagerConsumer> createState() => _ManagerConsumerState();
}

class _ManagerConsumerState extends State<ManagerConsumer>
    with ManagerProviderMixin {
  @override
  Widget build(BuildContext context) {
    return widget.build(context, ref);
  }
}

///Consumer widget for ManagerProvider
class ManagerConsumerBuilder extends ManagerConsumer {
  final Widget Function(BuildContext, ManagerRef) builder;
  const ManagerConsumerBuilder({Key? key, required this.builder})
      : super(key: key);

  @override
  Widget build(BuildContext context, ManagerRef ref) {
    return builder(context, ref);
  }
}

///
abstract class _ManagerDisposable {
  void onDispose(void Function() cb);
}

class ManagerRef extends _ManagerDisposable {
  final List<ManagerProvider> _providers = [];
  // ignore: prefer_function_declarations_over_variables
  VoidCallback _disposeCallBack = () {};
  @override
  void onDispose(void Function() cb) {
    _disposeCallBack = cb;
  }

  ///Read FutureManager from our store
  FutureManager<T> read<T extends Object, P>(ManagerProvider<T, P> provider) {
    if (!_ManagerStore.instance.providerExist(provider)) {
      provider._manager = () {
        if (provider.isFamily && provider._param == null) {
          throw ("Please provide a param when you first time read a ManagerProvider.family");
        }
        return provider.isFamily
            // ignore: null_check_on_nullable_type_parameter
            ? provider._createFamily!(this, provider._param!)
            : provider._create!(this);
      }();
    }
    _providers.add(provider);
    _ManagerStore.instance.addListener(provider);
    return provider._manager as FutureManager<T>;
  }

  ///This method is called when StatefulWidget that ManagerRef created is dispose
  void _dispose() {
    for (var provider in _providers) {
      _ManagerStore.instance.removeListener(provider, _disposeCallBack);
    }
    _providers.clear();
  }
}

class _ManagerStore {
  _ManagerStore._();
  static _ManagerStore instance = _ManagerStore._();
  final Map<ManagerProvider, int> _store = {};

  bool providerExist(ManagerProvider provider) {
    return _store[provider] != null;
  }

  void addListener<T extends Object, P>(
    ManagerProvider<T, P> provider,
  ) {
    _store[provider] ??= 0;
    _store[provider] = _store[provider]! + 1;
  }

  void removeListener<T extends Object, P>(
    ManagerProvider<T, P> provider,
    VoidCallback onDispose,
  ) {
    if (_store[provider] == null) return;
    _store[provider] = _store[provider]! - 1;
    if (_store[provider] == 0) {
      onDispose.call();
      provider._manager?.dispose();
      _store.remove(provider);
    }
  }
}

///Create a provider for [FutureManager]
class ManagerProvider<T extends Object, P> {
  FutureManager? _manager;
  P? _param;
  FutureManager<T> Function(ManagerRef)? _create;
  FutureManager<T> Function(ManagerRef, P)? _createFamily;

  final bool isFamily;
  ManagerProvider(this._create) : isFamily = false;

  ManagerProvider.family(this._createFamily) : isFamily = true;

  ManagerProvider<T, P> call(P param) {
    _param = param;
    return this;
  }

  FutureManager<T> of(ManagerRef ref) {
    return ref.read(this);
  }
}
