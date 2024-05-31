/// A collection of utilities for [Iterable].
extension IterableEx<T> on Iterable<T> {
  /// Calculates items of iterable and separates them by [separator].
  ///
  /// **Example**
  /// ```dart
  /// final list = ['foo', 'bar'];
  /// final result = list.separatedBy('test');
  /// print(list); // ['foo', 'test', 'bar']
  /// ```
  Iterable<T> separatedBy(T separator) sync* {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return;

    yield iterator.current;
    while (iterator.moveNext()) {
      yield separator;
      yield iterator.current;
    }
  }

  /// Adds [prefix] and [postfix] to the beginning and end
  /// of the iterable respectively.
  ///
  /// **Example**
  /// ```dart
  /// final list = ['foo', 'bar'];
  /// final result = list.surroundWith(['pre'], ['post']);
  /// print(list); // ['pre', 'foo', 'bar', 'post']
  /// ```
  Iterable<T> surroundWith({
    required Iterable<T> prefix,
    required Iterable<T> postfix,
  }) sync* {
    yield* prefix;
    yield* this;
    yield* postfix;
  }
}
