import 'dart:math';

import 'package:flutter/material.dart';
import 'package:future_manager/future_manager.dart';
import 'package:skadi/skadi.dart';

import 'src/cache_global_manager.dart';
import 'src/multiple_listener.dart';
import 'src/test_manager_provider.dart';
import 'src/test_pagination.dart';

class MyHomePage extends StatefulWidget {
  final FutureManager<int> Function() dataManager;
  const MyHomePage({Key? key, required this.dataManager}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late FutureManager<int> dataManager = widget.dataManager();

  void listener() {
    infoLog(dataManager.toString());
  }

  @override
  void initState() {
    dataManager.execute(() async {
      await Future.delayed(const Duration(milliseconds: 1500));
      return 10;
    });
    dataManager.addListener(listener);
    super.initState();
  }

  @override
  void dispose() {
    dataManager.removeListener(listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //Use with FutureManagerBuilder
    return Scaffold(
      appBar: AppBar(
        title: dataManager.listen(ready: (data) {
          return Text("FutureManager example: $data");
        }),
        actions: [
          IconButton(
            onPressed: () {
              dataManager.refresh(reloading: false);
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureManagerBuilder<int>(
        futureManager: dataManager,
        onReadyOnce: (data) {
          infoLog("This called only once");
        },
        onRefreshing: () => const RefreshProgressIndicator(),
        loading: const Center(child: CircularProgressIndicator()),
        error: (error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(error.toString()),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  key: const ValueKey("error-refresh"),
                  onPressed: () => dataManager.refresh(reloading: false),
                  icon: const Icon(Icons.refresh),
                  label: const Text("Refresh"),
                ),
                // AnimatedBuilder(animation: animation, builder: builder)
              ],
            ),
          );
        },
        onError: (err) {
          errorLog("Manager has an error", err);
        },
        onData: (data) {
          infoLog("Manager has a new data", data);
        },
        ready: (context, data) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "$data",
                  key: const ValueKey("data"),
                ),
                const SpaceY(24),
                ElevatedButton(
                  key: const ValueKey("add"),
                  onPressed: () async {
                    await dataManager.modifyData((data) {
                      return data! + 10;
                    });
                  },
                  child: const Text("Add 10"),
                ),
                const SpaceY(24),
                ElevatedButton(
                  key: const ValueKey("refresh"),
                  onPressed: dataManager.refresh,
                  child: const Text("Refresh"),
                ),
                const SpaceY(24),
                ElevatedButton(
                  key: const ValueKey("refresh-no-reload"),
                  onPressed: () => dataManager.refresh(reloading: false),
                  child: const Text("Refresh without reload"),
                ),
                const SpaceY(24),
                ElevatedButton(
                  key: const ValueKey("add-error"),
                  onPressed: () async {
                    dataManager.addError("My Exception");
                  },
                  child: const Text("Add error"),
                ),
                const SpaceY(24),
                ElevatedButton(
                  key: const ValueKey("add-error-soft"),
                  onPressed: () async {
                    dataManager.addError(
                      "My Exception",
                      updateViewState: false,
                    );
                  },
                  child: const Text("Add error without Clear Data"),
                ),
                if (dataManager.hasError) Text(dataManager.error.toString()),
                const SpaceY(24),
                ElevatedButton(
                  key: const ValueKey("reset"),
                  onPressed: () => dataManager.resetData(),
                  child: const Text("Reset"),
                ),
                const SpaceY(24),
                ElevatedButton(
                  onPressed: () {
                    dataManager.execute(
                      () => throw "Exception",
                      onError: (error) {
                        if (Random().nextBool()) {
                          return false;
                        }
                        return const FutureManagerError(
                          exception: "Override exception",
                        );
                      },
                    );
                  },
                  child: const Text("Override exception"),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            onPressed: () {
              SkadiNavigator.push(
                context,
                const MultipleListenr(),
              );
            },
            child: const Text("Multiple Listener"),
          ),
          const SpaceX(16),
          ElevatedButton(
            onPressed: () {
              SkadiNavigator.push(
                context,
                SuraManagerWithPagination(
                  dataManager: dataManager,
                ),
              );
            },
            child: const Text("Pagination"),
          ),
          const SpaceX(16),
          ElevatedButton(
            onPressed: () {
              SkadiNavigator.push(
                context,
                const TestManagerProvider(),
              );
            },
            child: const Text("Provider"),
          ),
          const SpaceX(16),
          ElevatedButton(
            onPressed: () {
              SkadiNavigator.push(
                context,
                const CacheGlobalManager(),
              );
            },
            child: const Text("Cache"),
          ),
        ],
      ),
    );
  }
}
