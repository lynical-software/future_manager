import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:future_manager/future_manager.dart';
import 'package:future_manager_example/src/home.dart';

void main() {
  testWidgets('FutureManagerBuilder test all state',
      (WidgetTester tester) async {
    const twosecond = Duration(seconds: 2);

    final FutureManager<int> manager = FutureManager(reloading: true);

    ///Pump the app
    await tester.pumpWidget(
      MaterialApp(
        home: MyHomePage(dataManager: () => manager),
      ),
    );
    await tester.pump(twosecond);

    ///Modified value test
    final add = find.byKey(const ValueKey("add"));
    await tester.tap(add);
    await tester.pump();
    final result = find.text("20");
    expect(result, findsOneWidget);

    ///Refresh test
    await tester.tap(find.byKey(const ValueKey("refresh")));
    await tester.pump();
    expect(manager.viewState, ManagerViewState.loading);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text("20"), findsNothing);
    await tester.pump(twosecond);
    expect(find.text("10"), findsOneWidget);

    //Refresh no reloading test
    //add 10 before test reloading
    await tester.tap(add);
    await tester.pump();
    expect(find.text("20"), findsOneWidget);
    //Tap refresh with no reloading
    await tester.tap(find.byKey(const ValueKey("refresh-no-reload")));
    await tester.pump();
    expect(manager.viewState, ManagerViewState.ready);
    expect(manager.processingState.value, ManagerProcessState.processing);
    expect(find.text("20"), findsOneWidget);
    expect(find.byType(RefreshProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle(twosecond);
    expect(find.text("10"), findsOneWidget);
    expect(manager.processingState.value, ManagerProcessState.ready);

    //Add error test
    await tester.tap(find.byKey(const ValueKey("add-error")));
    await tester.pump();
    expect(find.text("exception"), findsOneWidget);
    expect(manager.error != null, true);
    expect(manager.data == null, true);
    expect(manager.error!.exception.runtimeType, String);

    ///Refresh from Error
    await tester.tap(find.text("Refresh"));
    await tester.pump();
    expect(find.byType(RefreshProgressIndicator), findsOneWidget);
    expect(find.text("20"), findsNothing);
    await tester.pump(twosecond);
    expect(find.text("10"), findsOneWidget);

    //Reset
    await tester.tap(find.byKey(const ValueKey("reset")));
    await tester.pump();
    expect(find.text("10"), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
