import 'package:flutter/material.dart';
import 'package:future_manager/future_manager.dart';
import 'package:skadi/skadi.dart';

final provider = ManagerProvider((ref) {
  ref.onDispose(() {
    infoLog("Manager is disposing");
  });
  print("simple provider created");
  return FutureManager<int>(
    futureFunction: () => Future.delayed(const Duration(seconds: 2), () => 2),
  );
});

final familyProvider = ManagerProvider<String, String>.family((ref, param) {
  ref.onDispose(() {
    infoLog("Manager is disposing");
  });
  print("Family provider created");
  return FutureManager<String>(
    futureFunction: () => Future.delayed(const Duration(seconds: 2), () => "2"),
  );
});

class TestManagerProvider extends StatefulWidget {
  const TestManagerProvider({Key? key}) : super(key: key);

  @override
  State<TestManagerProvider> createState() => _TestManagerProviderState();
}

class _TestManagerProviderState extends State<TestManagerProvider> with ManagerProviderMixin {
  late final manager = ref.read(provider(2));
  late final familyManager = ref.read(familyProvider("2"));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manager Provider test")),
      body: manager.when(
        ready: (data) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("$data"),
                const StatelessManagerStore(),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          SkadiNavigator.push(
            context,
            ManagerConsumerBuilder(
              builder: (context, ref) {
                return Scaffold(
                  appBar: AppBar(),
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        ref.read(provider).modifyData((p0) => p0! + 30);
                      },
                      child: const Text("Add 30"),
                    ),
                  ),
                );
              },
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class StatelessManagerStore extends ManagerConsumer {
  const StatelessManagerStore({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    return Container(
      margin: const EdgeInsets.only(top: 32),
      child: ref.read(provider).listen(
        ready: (data) {
          return ElevatedButton(
            child: Text("This Button is in another file: $data"),
            onPressed: () {
              ref.read(provider).modifyData((data) => data! + 10);
            },
          );
        },
      ),
    );
  }
}
