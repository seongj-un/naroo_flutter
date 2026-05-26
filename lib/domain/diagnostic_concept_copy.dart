import 'learning_models.dart';

class DiagnosticConceptCopy {
  const DiagnosticConceptCopy({
    required this.title,
    required this.weakLinkBody,
    required this.missionTitle,
  });

  final String title;
  final String weakLinkBody;
  final String missionTitle;
}

const Map<String, DiagnosticConceptCopy> _diagnosticConceptCopies = {
  'equation_balance': DiagnosticConceptCopy(
    title: '등식의 균형',
    weakLinkBody: '등호 양쪽에 같은 연산을 해야 한다는 감각부터 다시 잡으면 돼요.',
    missionTitle: '등식의 균형 다시 잡기',
  ),
  'equation_distribution': DiagnosticConceptCopy(
    title: '분배법칙',
    weakLinkBody: '괄호 앞 숫자가 안의 모든 항에 곱해진다는 연결만 먼저 다시 보면 돼요.',
    missionTitle: '분배법칙 다시 연결하기',
  ),
  'function_substitution': DiagnosticConceptCopy(
    title: '함수값 대입',
    weakLinkBody: '식에 x값을 넣고 계산 순서를 한 줄씩 다시 확인하면 좋아요.',
    missionTitle: '함수값 대입 10분 복구 미션',
  ),
  'linear_function_slope': DiagnosticConceptCopy(
    title: '일차함수 기울기',
    weakLinkBody: 'x 앞의 숫자와 부호가 기울기라는 연결부터 다시 잡으면 돼요.',
    missionTitle: '일차함수 기울기 10분 복구 미션',
  ),
  'triangle_angle_sum': DiagnosticConceptCopy(
    title: '삼각형 각의 합',
    weakLinkBody: '삼각형의 세 각을 더하면 180도라는 기준부터 다시 연결하면 돼요.',
    missionTitle: '삼각형 각도 합 복구 미션',
  ),
  'coordinate_distance': DiagnosticConceptCopy(
    title: '좌표 사이 거리',
    weakLinkBody: 'x좌표와 y좌표 중 무엇이 달라지는지만 분리해서 보면 부담이 줄어요.',
    missionTitle: '좌표 사이 거리 읽기',
  ),
  'sample_space_count': DiagnosticConceptCopy(
    title: '경우의 수',
    weakLinkBody: '가능한 결과를 하나씩 빠뜨리지 않고 펼쳐 보는 연습부터 다시 하면 좋아요.',
    missionTitle: '경우의 수 펼쳐 보기',
  ),
  'mean_interpretation': DiagnosticConceptCopy(
    title: '평균 해석',
    weakLinkBody: '전체를 더한 뒤 개수로 나눈다는 두 단계를 다시 분리해서 보면 돼요.',
    missionTitle: '평균 계산 다시 정리하기',
  ),
  'sequence_common_difference': DiagnosticConceptCopy(
    title: '수열의 차이',
    weakLinkBody: '앞뒤 항이 얼마나 일정하게 늘어나는지부터 다시 확인하면 좋아요.',
    missionTitle: '수열의 차이 찾기',
  ),
  'sequence_sum_basics': DiagnosticConceptCopy(
    title: '수열의 합 기초',
    weakLinkBody: '작은 수부터 차례대로 더하며 중간 합을 적어 보면 실수가 줄어요.',
    missionTitle: '작은 합부터 다시 묶기',
  ),
  'linear_equation': DiagnosticConceptCopy(
    title: '일차방정식 정리',
    weakLinkBody: '숫자는 숫자끼리, x는 x끼리 모으는 한 줄 정리부터 다시 보면 돼요.',
    missionTitle: '일차방정식 한 줄 정리 미션',
  ),
  'equation_modeling': DiagnosticConceptCopy(
    title: '문장제 식 세우기',
    weakLinkBody: '문장에서 기준이 되는 수를 먼저 정하고 작은 식으로 쪼개 보면 쉬워져요.',
    missionTitle: '문장 식 세우기 10분 미션',
  ),
  'coordinate_translation': DiagnosticConceptCopy(
    title: '좌표 이동',
    weakLinkBody: 'x축 이동과 y축 이동이 좌표의 어느 숫자를 바꾸는지 따로 보면 돼요.',
    missionTitle: '좌표 이동 한 칸씩 확인 미션',
  ),
  'basic_probability': DiagnosticConceptCopy(
    title: '기본 확률',
    weakLinkBody: '전체 경우와 원하는 경우를 분수의 분모, 분자로 나눠 다시 보면 좋아요.',
    missionTitle: '기본 확률 분수 미션',
  ),
  'permutation_counting': DiagnosticConceptCopy(
    title: '순서 세기',
    weakLinkBody: '자리를 하나씩 채우며 선택지가 몇 개씩 남는지 곱해서 보면 돼요.',
    missionTitle: '순서 세기 10분 복구 미션',
  ),
  'arithmetic_sequence_pattern': DiagnosticConceptCopy(
    title: '등차 패턴',
    weakLinkBody: '연속한 두 수의 차이가 일정한지부터 다시 확인하면 패턴이 보여요.',
    missionTitle: '등차 패턴 찾기 미션',
  ),
  'arithmetic_sequence_nth_term': DiagnosticConceptCopy(
    title: '등차수열 n번째 항',
    weakLinkBody: '첫째항에서 공차를 몇 번 더해야 하는지 세는 순서부터 다시 잡으면 돼요.',
    missionTitle: '등차수열 n번째 항 미션',
  ),
};

WeakLink diagnosticWeakLink(String rawValue, {String? fallbackBody}) {
  final value = rawValue.trim();
  final mappedCopy = _diagnosticConceptCopies[value];
  if (mappedCopy != null) {
    return WeakLink(title: mappedCopy.title, body: mappedCopy.weakLinkBody);
  }

  final safeBody = _safeFallbackBody(fallbackBody);
  if (_looksLikeConceptTag(value)) {
    return WeakLink(
      title: _humanizeConceptTag(value),
      body: safeBody ?? '가장 먼저 다시 연결할 부분부터 천천히 확인해 볼게요.',
    );
  }

  return WeakLink(
    title: value,
    body: safeBody ?? '가장 먼저 다시 연결할 부분부터 천천히 확인해 볼게요.',
  );
}

String diagnosticMissionTitleFor(String conceptTag, {String? fallbackTitle}) {
  final title = fallbackTitle?.trim();
  if (title != null &&
      title.isNotEmpty &&
      !_looksLikeLeakyMissionTitle(title)) {
    return title;
  }

  final mappedCopy = _diagnosticConceptCopies[conceptTag.trim()];
  if (mappedCopy != null) {
    return mappedCopy.missionTitle;
  }

  return '첫 10분 복구 미션';
}

String? _safeFallbackBody(String? fallbackBody) {
  final body = fallbackBody?.trim();
  if (body == null || body.isEmpty || _containsLeakyConceptKey(body)) {
    return null;
  }
  return body;
}

bool _looksLikeLeakyMissionTitle(String value) {
  final parts = value.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty) {
    return false;
  }
  return _looksLikeConceptTag(parts.first);
}

bool _containsLeakyConceptKey(String value) {
  return RegExp(r'[a-z0-9]+(?:[_-][a-z0-9]+)+').hasMatch(value);
}

bool _looksLikeConceptTag(String value) {
  return value.isNotEmpty && RegExp(r'^[a-z0-9_-]+$').hasMatch(value);
}

String _humanizeConceptTag(String value) {
  return value
      .split(RegExp(r'[_-]+'))
      .where((part) => part.isNotEmpty)
      .join(' ');
}
