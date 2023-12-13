import 'package:flutter/material.dart';
import 'package:future_manager/future_manager.dart';
import 'package:skadi/skadi.dart';

class MultipleListenr extends StatefulWidget {
  const MultipleListenr({super.key});

  @override
  State<MultipleListenr> createState() => _MultipleListenrState();
}

class _MultipleListenrState extends State<MultipleListenr> {
  FutureManager<int> futureManager = FutureManager();

  bool switchWidget = true;

  bool switchAll = false;

  VoidCallback? canceller;

  @override
  void initState() {
    futureManager.execute(() => Future.value(2));
    canceller = futureManager.eventListener((data) {
      infoLog("Event listener called: $data");
    });
    super.initState();
  }

  @override
  void dispose() {
    canceller?.call();
    futureManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          ElevatedButton(
            onPressed: () {
              futureManager.addError("error occur");
            },
            child: const Text("Add error"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                switchAll = !switchAll;
              });
            },
            child: const Text("Switch all"),
          ),
        ],
      ),
      body: switchAll
          ? emptySizedBox
          : Column(
              children: [
                if (switchWidget)
                  futureManager.when(
                    ready: (data) {
                      return Text("This is a data from first :$data");
                    },
                  ),
                futureManager.when(
                  ready: (data) {
                    return Text("This is a data from second :$data");
                  },
                ),
                futureManager.when(
                  ready: (data) {
                    return Text("This is a data from third :$data");
                  },
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text("Disable one widget"),
        onPressed: () {
          setState(() {
            switchWidget = !switchWidget;
          });
        },
      ),
    );
  }
}
