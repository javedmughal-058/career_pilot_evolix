sealed class Result<T> {
  const Result();
  R fold<R>(R Function(T data) ok, R Function(Object error) fail) =>
      switch (this) {
        Success<T>(:final data) => ok(data),
        Failure<T>(:final error) => fail(error),
      };
}

class Success<T> extends Result<T> {
  const Success(this.data);
  final T data;
}

class Failure<T> extends Result<T> {
  const Failure(this.error);
  final Object error;
}
