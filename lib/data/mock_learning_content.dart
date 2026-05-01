import '../domain/diagnostic_models.dart';

const diagnosticQuestions = [
  DiagnosticQuestion(
    id: 'graph_1',
    concept: '함수 그래프 읽기',
    prompt: '그래프에서 x값이 커질수록 y값이 일정하게 커지고 있어요. 이 그래프와 가장 가까운 설명은 무엇인가요?',
    correctAnswerId: 'linear_up',
    choices: [
      AnswerChoice(id: 'linear_up', label: '일차함수처럼 일정하게 증가해요'),
      AnswerChoice(id: 'linear_down', label: '일정하게 감소해요'),
      AnswerChoice(id: 'not_function', label: '함수라고 볼 수 없어요'),
    ],
  ),
  DiagnosticQuestion(
    id: 'graph_2',
    concept: '기울기 감각',
    prompt: '두 점 (1, 2), (3, 6)을 지나는 직선에서 x가 2만큼 늘 때 y는 얼마나 늘어나나요?',
    correctAnswerId: 'plus_four',
    choices: [
      AnswerChoice(id: 'plus_two', label: '2만큼 늘어나요'),
      AnswerChoice(id: 'plus_four', label: '4만큼 늘어나요'),
      AnswerChoice(id: 'plus_six', label: '6만큼 늘어나요'),
    ],
  ),
  DiagnosticQuestion(
    id: 'graph_3',
    concept: '식과 그래프 연결',
    prompt: 'y = 2x + 1에서 x = 0일 때 그래프는 y축의 어느 값을 지나나요?',
    correctAnswerId: 'one',
    choices: [
      AnswerChoice(id: 'zero', label: '0을 지나요'),
      AnswerChoice(id: 'one', label: '1을 지나요'),
      AnswerChoice(id: 'two', label: '2를 지나요'),
    ],
  ),
];

const startingPointOptions = [
  '식을 어떻게 바꿀지 모르겠어요',
  '함수 그래프가 나오면 막혀요',
  '도형 조건을 어디에 써야 할지 모르겠어요',
  '확률과 통계에서 기준을 못 잡겠어요',
  '수열 규칙을 식으로 못 바꾸겠어요',
  '어디서부터 다시 해야 할지 모르겠어요',
];

const mathStatusOptions = [
  '수업을 따라가고 있어요',
  '간신히 따라가고 있어요',
  '거의 놓친 것 같아요',
  '아직 모르겠어요',
];
