import 'dart:math';

import 'package:flutter/material.dart';
import 'package:future_manager/future_manager.dart';
import 'package:skadi/skadi.dart';

final FutureManager<int> globalManager = FutureManager(reloading: false);

class GlobalManager extends StatefulWidget {
  const GlobalManager({Key? key}) : super(key: key);

  @override
  State<GlobalManager> createState() => _GlobalManagerState();
}

class _GlobalManagerState extends State<GlobalManager> {
  void listener() {
    infoLog("Global:", globalManager.toString());
  }

  @override
  void initState() {
    globalManager.execute(
      () async {
        await SkadiUtils.wait(2500);
        return Random().nextInt(999);
      },
    );
    globalManager.addListener(listener);
    super.initState();
  }

  @override
  void dispose() {
    globalManager.removeListener(listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manager data Cache"),
      ),
      body: globalManager.when(
        onReadyOnce: (data) {},
        ready: (data) {
          return Center(
            child: Text("My data: $data"),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          globalManager.addError("We got an error");
        },
        child: const Icon(Icons.error_outline),
      ),
    );
  }
}
