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
  @override
  void initState() {
    futureManager.execute(() => Future.value(2));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              futureManager.addError("error occur");
            },
            icon: const Icon(Icons.error),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                switchAll = !switchAll;
              });
            },
            icon: const Icon(Icons.swipe),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            switchWidget = !switchWidget;
          });
        },
      ),
    );
  }
}
