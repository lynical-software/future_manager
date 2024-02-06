import 'dart:math';

import 'package:flutter/material.dart';
import 'package:future_manager/future_manager.dart';
import 'package:skadi/skadi.dart';

class AnimatedManagerBottomSheet extends StatefulWidget {
  const AnimatedManagerBottomSheet({super.key});

  @override
  State<AnimatedManagerBottomSheet> createState() =>
      _AnimatedManagerBottomSheetState();
}

class _AnimatedManagerBottomSheetState
    extends State<AnimatedManagerBottomSheet> {
  FutureManager<int> manager = FutureManager<int>();

  @override
  void initState() {
    super.initState();
    manager.execute(() async {
      await SkadiUtils.wait();
      return Random().nextInt(99);
    });
  }

  @override
  void dispose() {
    manager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: double.infinity,
      ),
      padding: const EdgeInsets.all(24),
      child: FutureManagerBuilder(
        futureManager: manager,
        loading: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircularLoading(size: 32),
          ],
        ),
        ready: (context, data) {
          return SingleChildScrollView(
            child: Column(
              children: [
                SkadiIconButton(
                  onTap: () => manager.refresh(),
                  icon: const Icon(Icons.refresh),
                ),
                for (var i in List.generate(
                    int.parse(data.toString()), (index) => index))
                  ListTile(
                    title: Text("Title of $i"),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
