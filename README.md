# FutureManager

ValueNotifier and ValueListenableBuilder but for asynchronous value.

[![pub package](https://img.shields.io/badge/pub-1.0.0-blueviolet.svg)](https://pub.dev/packages/future_manager) ![Latest commit](https://badgen.net/github/last-commit/lynical-software/future_manager)

# Installation

Add this to pubspec.yaml

```dart
dependencies:
  future_manager: ^1.0.0
```

### Use case and motivation:

Now imagine that you're fetching data from an API or working with a Future function that reflects the change to UI. Traditionally you could use **setState** or **FutureBuilder** to handle this case. But both of them create a boilerplate code and lack some functionality like refresh, event callback ..etc.

FutureManager provides you a solution with mainly focus on 3 main state of Future value: **Loading**,**Error** and **Done** where you can handle the UI with those states with FutureManagerBuilder.

#### Short example:

```dart
  FutureManager<int> dataManager = FutureManager();

  @override
  void initState() {
    dataManager.execute(() => Future.value(2));
    super.initState();
  }

  @override
  void dispose() {
    dataManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureManagerBuilder<int>(
      futureManager: dataManager,
      ready: (context, data) {
        return ElevatedButton(
          child: Text("My data: $data"),
          onPressed: () {
            dataManager.refresh();
          },
        );
      },
    );
  }
```

# FutureManager

| Property       | description                                                                                    | default |
| -------------- | ---------------------------------------------------------------------------------------------- | ------- |
| futureFunction | a function to run and return data                                                              | null    |
| reloading      | Reset a state to loading or not when you call refresh or execute                        | true    |
| onSuccess      | a callback function called after operation is success                                          | null    |
| onDone         | a callback function called after operation is completely done, similar to finally in try-catch | null    |
| onError        | a callback function called after operation has an error                                        | null    |
| cacheOption    | an option to cache data.                                                                       | non     |

| field        | description                                |
| ------------ | ------------------------------------------ |
| data         | current data in the Manager                |
| error        | error in the Manager                       |
| hasData      | check if our Manager has a data            |
| hasError     | check if our Manager has an error          |
| future       | future field of the current futureFunction |
| isRefreshing | check if our Manager is refreshing         |

| Method         | description                                                                                                                                                         |
| -------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| when           | A method similar to FutureManagerBuilder                                                                                                                            |
| execute | run futureFunction that will return a data to our Manager                                                                                                           |
| refresh        | call the execute again. we have to assign futureFunction from the constructor or call execute once to run this method, otherwise it will log an error |
| updateData     | a method to update data in our Manager                                                                                                                              |
| modifyData     | a method to update data in our Manager with data callback, prefer using this method to update data.                                                                 |
| resetData      | reset everything to loading or null state                                                                                                                            |
| addError       | add error into our manager                                                                                                                                          |
| clearError     | clear error in the manager but only work if ViewState isn't in error state                                                                                          |

# FutureManagerBuilder

## Example

```dart
class _HomePageState extends State<NewPage> {

  FutureManager<int> dataManager = FutureManager();
  @override
  void initState() {
    dataManager.execute(()async{
      await Future.delayed(Duration(seconds: 2));
      //Add 10 into our dataManager
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
    //Use with FutureManagerBuilder
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon:Icon(Icons.refresh),
            onPressed:(){
              //call our execute again
              dataManager.refresh();
            },
          )
        ]
      ),
      body: FutureManagerBuilder<int>(
        futureManager: dataManager,
        error: (error) => YourErrorWidget(),
        loading: YourLoadingWidget(),
        ready: (context, data){
          //result: My data: 10
          return Text("My data: ${data}"),
        }
      ),
    );
  }
}
```

## Documentation

| Property      | description                                                                            | default                   |
| ------------- | -------------------------------------------------------------------------------------- | ------------------------- |
| futureManager | our FutureManager object                                                               | required                  |
| ready         | A widget builder show when [FutureManager] has a data                                  | required                  |
| loading       | A widget show when [FutureManager] state is loading                                    | CircularProgressIndicator |
| error         | A widget show when [FutureManager] state is error                                      | Text(error.toString())    |
| onError       | A callback function that call when [FutureManager] state is error                      | null                      |
| onData        | A callback function that call when [FutureManager] state has a data or data is updated | null                      |
| onRefreshing  | A widget to show on top of this widget when refreshing                                 | null                      |



## Ecosystem and usage

- Q: when to use `cacheOption`? 
A: When you have a global manager and want to preserve data on a period of time without running `execute` logic or futureFunction again.
- Q: when to use `ManagerProvider`?
A: When you want to use FutureManager across multiple widget(but not global) without declaring it as a global variable. By doing this, FutureManager will be auto dispose and recreate each time its first used. This work the same way as RiverPod with autoDispose.