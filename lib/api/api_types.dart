class ApiError implements Exception {
  const ApiError({required this.status, required this.errorCode});

  final int status;
  final String errorCode;

  @override
  String toString() => 'ApiError(status: $status, errorCode: $errorCode)';
}

sealed class ApiResult<T> {
  const ApiResult();
}

class ApiSuccess<T> extends ApiResult<T> {
  const ApiSuccess(this.data);

  final T data;
}

class ApiFailure<T> extends ApiResult<T> {
  const ApiFailure({required this.status, required this.errorCode});

  final int status;
  final String errorCode;

  ApiError toError() => ApiError(status: status, errorCode: errorCode);
}

typedef JsonMap = Map<String, Object?>;
