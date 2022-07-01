import 'package:flutter/material.dart';
import 'package:future_manager/future_manager.dart';
import 'package:sura_flutter/sura_flutter.dart';

import 'cache_global_manager.dart';
import 'test_manager_provider.dart';
import 'test_pagination.dart';

class MyHomePage extends StatefulWidget {
  final FutureManager<int> Function() dataManager;
  const MyHomePage({Key? key, required this.dataManager}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late FutureManager<int> dataManager = widget.dataManager();

  @override
  void initState() {
    dataManager.execute(() async {
      await Future.delayed(const Duration(milliseconds: 1500));
      return 10;
    });
    dataManager.addListener(() {
      infoLog(dataManager.toString());
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //Use with FutureManagerBuilder
    return Scaffold(
      appBar: AppBar(
        title: const Text("FutureManager example"),
      ),
      body: FutureManagerBuilder<int>(
        futureManager: dataManager,
        onRefreshing: () => const RefreshProgressIndicator(),
        loading: const Center(child: CircularProgressIndicator()),
        error: (err) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(err.toString()),
                SuraAsyncButton(
                  fullWidth: false,
                  onPressed: () {
                    dataManager.refresh(reloading: false);
                  },
                  child: const Text("Refresh"),
                ),
              ],
            ),
          );
        },
        onError: (err) {},
        onData: (data) {},
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
                    dataManager.addError(const FutureManagerError(exception: "exception"));
                  },
                  child: const Text("Add error"),
                ),
                const SpaceY(24),
                ElevatedButton(
                  key: const ValueKey("reset"),
                  onPressed: () => dataManager.resetData(),
                  child: const Text("Reset"),
                ),
                const SpaceY(24),
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
              SuraPageNavigator.push(
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
              SuraPageNavigator.push(
                context,
                const TestManagerProvider(),
              );
            },
            child: const Text("Manager Provider"),
          ),
          const SpaceX(16),
          ElevatedButton(
            onPressed: () {
              SuraPageNavigator.push(
                context,
                const CacheGlobalManager(),
              );
            },
            child: const Text("Cache Manager"),
          ),
        ],
      ),
    );
  }
}
