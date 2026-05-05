import '../api/api_types.dart';
import '../domain/learning_models.dart';

JsonMap requireObject(Object? data) {
  if (data is Map) {
    return data.map((key, value) => MapEntry(key.toString(), value));
  }
  throw const ApiError(status: 200, errorCode: 'GLOBAL_BAD_RESPONSE');
}

JsonMap objectFromData(Object? data) {
  if (data is Map) {
    return data.map((key, value) => MapEntry(key.toString(), value));
  }
  return const {};
}

String stringFromData(Object? data, {String fallback = ''}) {
  return data is String ? data : fallback;
}

int intFromData(Object? data) {
  if (data is int) {
    return data;
  }
  if (data is num) {
    return data.toInt();
  }
  return 0;
}

List<String> stringListFromData(Object? data) {
  if (data is List) {
    return data.whereType<String>().toList(growable: false);
  }
  return const [];
}

RecoveryMission? recoveryMissionFromDataOrNull(Object? data) {
  if (data == null) {
    return null;
  }
  return recoveryMissionFromData(data);
}

RecoveryMission recoveryMissionFromData(Object? data) {
  final object = requireObject(data);
  final hints = stringListFromData(object['hints']);
  final estimatedMinutes = intFromData(object['estimatedMinutes']);
  final prompt = stringFromData(
    object['prompt'],
    fallback: '오늘의 미션을 차근차근 풀어보세요.',
  );

  return RecoveryMission(
    id: stringFromData(object['id']),
    diagnosticSessionId: stringFromData(object['diagnosticSessionId']),
    title: stringFromData(object['title'], fallback: '10분 회복 미션'),
    estimatedTime: estimatedMinutes > 0
        ? '예상 시간 $estimatedMinutes분'
        : '예상 시간 10분',
    explanation: prompt,
    challenge: prompt,
    hint: hints.isEmpty ? '처음 떠오르는 단서부터 적어보세요.' : hints.first,
    status: stringFromData(object['status'], fallback: 'IN_PROGRESS'),
  );
}
