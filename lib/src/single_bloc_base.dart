import 'dart:async';

import 'package:meta/meta.dart';

/// Base class for objects that can be disposed.
abstract class BlocBase {
  Future<void> dispose() async {}
}

/// Makes initializers disposable by moving the disposal
/// process to the next microtask.
class HookBloc implements BlocBase {
  static HookBloc _context;

  /// You must call [disposeSink] before the constructor is called.
  /// That means calling HookBloc.disposeSink like the following example:
  ///
  /// ```
  /// final SomeObject object = SomeObject(onInit: HookBloc.disposeSink);
  /// ```
  static void disposeSink(Sink sink) => disposeEffect(() async => sink.close());

  /// See [disposeSink]
  static void disposeBloc(BlocBase bloc) => disposeEffect(bloc.dispose);

  /// See [disposeSink]
  static void disposeEffect(Future<void> Function() effect) =>
      scheduleMicrotask(() {
        if (_context != null) {
          _context.disposeLater(effect);
        } else {
          throw Exception(
              "HookBloc.disposeSink used outside of class member contructor.");
        }
      });

  HookBloc() {
    _context = this;
  }

  final List<Future<void> Function()> onDispose = [];

  void disposeSinkLater(Sink sink) {
    onDispose.add(() async => sink.close());
  }

  void disposeLater(void Function() dispose) {
    onDispose.add(() async => dispose());
  }

  @override
  @mustCallSuper
  Future<void> dispose() async {
    scheduleMicrotask(() async {
      await Future.forEach(onDispose, (Future<void> Function() a) => a());
    });
    scheduleMicrotask(() async {
      _context = null;
    });
  }
}

/// Base class for objects that can be initialized.
abstract class Initializable {
  Future<void> init();
}

/// Base class for objects that can be initialized and disposed.
abstract class InitializableBlocBase implements BlocBase, Initializable {}

class BaggedInitializableBlocBase implements InitializableBlocBase {
  final List<Future<void> Function()> onInit = [];

  final List<Future<void> Function()> onDispose = [];

  /// Disposes and initializes passed [InitializableBlocBase] objects
  /// together with this object.
  T bagState<T extends InitializableBlocBase>(T t) {
    onDispose.add(() => t.dispose());
    onInit.add(() => t.init());
    return t;
  }

  T bagBloc<T extends BlocBase>(T t) {
    onDispose.add(() => t.dispose());
    return t;
  }

  void disposeLater(void Function() dispose) {
    onDispose.add(() async => dispose());
  }

  void initLater(void Function() init) {
    onInit.add(() async => init());
  }

  @override
  @mustCallSuper
  Future<void> init() async {
    await Future.forEach(onInit, (Future<void> Function() a) => a());
  }

  @override
  @mustCallSuper
  Future<void> dispose() async {
    await Future.forEach(onDispose, (Future<void> Function() a) => a());
  }
}
