import 'package:flutter/material.dart';
import 'package:future_manager/future_manager.dart';
import 'package:skadi/skadi.dart';

import 'home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureManagerProvider(
      onFutureManagerError: (error, context) {
        errorLog("On FutureManager error called");
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Future Manager Example',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(
          dataManager: () => FutureManager(
            reloading: true,
            cacheOption: const ManagerCacheOption.non(),
          ),
        ),
      ),
    );
  }
}
