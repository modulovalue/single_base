import 'package:single_base/single_base.dart';

// ignore_for_file: unused_local_variable
Future<void> main() async {
  print("---------Simple Bloc---------");
  const simpleBloc = ExampleBloc();
  await simpleBloc.dispose();

  print("---------Initializable Bloc---------");
  const initializableBloc = ExampleBlocWithInit();
  await initializableBloc.init();
  await initializableBloc.dispose();

  print("--------Hook Bloc----------");
  final hookBloc = ExampleHookBloc();
  await hookBloc.dispose();

  final hookBloc2 = ExampleHookBloc();
  await hookBloc2.dispose();

  print("---------Bagged Bloc---------");
  final baggedBloc = ExampleBaggedBloc(
    [const ExampleBloc(), ExampleHookBloc()],
    [const ExampleBlocWithInit()],
  );
  await baggedBloc.init();
  await baggedBloc.dispose();

  print("---------Storage---------");
  final storage = MyStorage();
  final storageAt = storage.at("somewhere");
  final storageSomewhereElse = storage.map((key) => "somewhere/$key");
}

class ExampleBloc implements BlocBase {
  const ExampleBloc();

  @override
  Future<void> dispose() async {
    print("ExampleBloc dispose");
  }
}

class ExampleBlocWithInit implements InitializableBlocBase {
  const ExampleBlocWithInit();

  @override
  Future<void> dispose() async {
    print("ExampleBlocWithInit dispose");
  }

  @override
  Future<void> init() async {
    print("ExampleBlocWithInit init");
  }
}

class ExampleHookBloc extends HookBloc {
  final MyOtherBloc otherBloc = MyOtherBloc(onInit: HookBloc.disposeBloc);
}

class MyOtherBloc extends BlocBase {
  MyOtherBloc({void Function(BlocBase) onInit}) {
    onInit(this);
  }

  @override
  Future<void> dispose() async {
    print("MyOtherBloc dispose");
  }
}

class ExampleBaggedBloc extends BaggedInitializableBlocBase {
  ExampleBaggedBloc(Iterable<BlocBase> blocs,
      Iterable<InitializableBlocBase> initializableBlocs) {
    blocs.forEach(bagBloc);
    initializableBlocs.forEach(bagState);
    disposeLater(() => print("dispose me later"));
    initLater(() => print("init me later"));
  }
}

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
