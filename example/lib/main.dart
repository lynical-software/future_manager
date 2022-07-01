import 'package:flutter/material.dart';
import 'package:future_manager/future_manager.dart';

import 'home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureManagerProvider(
      onFutureManagerError: (error, context) {},
      child: MaterialApp(
        title: 'Future Manager Example',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: false
            ? const ExamplePage()
            : MyHomePage(
                dataManager: () => FutureManager(
                  reloading: true,
                  cacheOption: const ManagerCacheOption.non(),
                ),
              ),
      ),
    );
  }
}

class ExamplePage extends StatefulWidget {
  const ExamplePage({Key? key}) : super(key: key);

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  FutureManager<int> dataManager = FutureManager();

  @override
  void initState() {
    dataManager.execute(() async {
      await Future.delayed(const Duration(seconds: 2));
      return 10;
    });
    super.initState();
  }

  @override
  void dispose() {
    dataManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("FutureManager Example")),
      body: FutureManagerBuilder<int>(
        futureManager: dataManager,
        ready: (context, data) {
          return Center(
            child: ElevatedButton(
              child: Text("My data: $data"),
              onPressed: () {
                dataManager.refresh();
              },
            ),
          );
        },
      ),
    );
  }
}
