# single_base

DEPRECATED: Please use [single_bloc_base](https://github.com/modulovalue/single_bloc_base) & [single_storage_base](https://github.com/modulovalue/single_storage_base)

Platform agnostic bloc and storage interfaces for dart.

Provides interfaces for:
- Disposable Blocs: 
```dart
class ExampleBloc implements BlocBase {
  const ExampleBloc();

  @override
  Future<void> dispose() async {
  }
}
```
- Initializable Blocs:
```dart
class ExampleBlocWithInit implements InitializableBlocBase {
  const ExampleBlocWithInit();

  @override
  Future<void> dispose() async {
  }

  @override
  Future<void> init() async {
  }
}
```
- Disposable & Initializable Blocs:
```dart
class ExampleBaggedBloc extends BaggedInitializableBlocBase {
  ExampleBaggedBloc(Iterable<BlocBase> blocs,
      Iterable<InitializableBlocBase> initializableBlocs) {
    blocs.forEach(bagBloc);
    initializableBlocs.forEach(bagState);
    disposeLater(() => print("dispose me later"));
    initLater(() => print("init me later"));
  }
}
```
- Hook Blocs that give you the ability to schedule objects for disposal in one line during their initialization:
```dart

class ExampleHookBloc extends HookBloc {
  final MyOtherBloc otherBloc = MyOtherBloc(onInit: HookBloc.disposeBloc);
}

class MyOtherBloc extends BlocBase {
  MyOtherBloc({void Function(BlocBase) onInit}) {
    onInit(this);
  }
}
```

- Platform agnostic storage base class:
```dart
class MyStorage extends StorageBase<String> {
  @override
  Future<bool> exists(String key) async {
    return false;
  }

  @override
  Future<String> get(String key) async {
    return "todo";
  }

  @override
  String location(String key) {
    return key;
  }

  @override
  Future<void> remove(String key) async {
    // remove
  }

  @override
  Future<void> set(String key, String value) async {
    // set
  }
}

final storage = MyStorage();
final storageAt = storage.at("somewhere");
final storageSomewhereElse = storage.map((key) => "somewhere/$key");
```
