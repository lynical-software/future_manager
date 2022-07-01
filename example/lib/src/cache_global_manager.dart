import 'dart:math';

import 'package:flutter/material.dart';
import 'package:future_manager/future_manager.dart';
import 'package:sura_flutter/sura_flutter.dart';

final FutureManager<int> globalManager = FutureManager(
  cacheOption: const ManagerCacheOption(
    cacheTime: Duration(seconds: 10),
  ),
);

class CacheGlobalManager extends StatefulWidget {
  const CacheGlobalManager({Key? key}) : super(key: key);

  @override
  State<CacheGlobalManager> createState() => _CacheGlobalManagerState();
}

class _CacheGlobalManagerState extends State<CacheGlobalManager> {
  @override
  void initState() {
    globalManager.execute(
      () async {
        await SuraUtils.wait(2000);
        return Random().nextInt(999);
      },
    );
    globalManager.addListener(() {
      infoLog(globalManager.toString());
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manager data Cache"),
      ),
      body: globalManager.when(ready: (data) {
        return Center(
          child: Text("My data: $data"),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          globalManager.refresh();
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
