import '../api/api_client.dart';
import '../api/api_http_client.dart';
import '../auth/auth_store.dart';
import '../data/auth_api_repository.dart';
import '../data/diagnostic_api_repository.dart';
import '../data/learning_api_repository.dart';
import '../data/mock_repositories.dart';
import '../data/recovery_api_repository.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/diagnostic_repository.dart';
import '../domain/repositories/learning_repository.dart';
import '../domain/repositories/recovery_repository.dart';

class NarooDependencies {
  const NarooDependencies({
    required this.authRepository,
    required this.learningRepository,
    required this.diagnosticRepository,
    required this.recoveryRepository,
  });

  factory NarooDependencies.real() {
    final authStore = AuthStore();
    final apiClient = ApiClient(
      authStore: authStore,
      httpClient: createApiHttpClient(),
    );

    return NarooDependencies(
      authRepository: AuthApiRepository(
        apiClient: apiClient,
        authStore: authStore,
      ),
      learningRepository: LearningApiRepository(apiClient: apiClient),
      diagnosticRepository: DiagnosticApiRepository(apiClient: apiClient),
      recoveryRepository: RecoveryApiRepository(apiClient: apiClient),
    );
  }

  factory NarooDependencies.mock() {
    return NarooDependencies(
      authRepository: MockAuthRepository(),
      learningRepository: MockLearningRepository(),
      diagnosticRepository: MockDiagnosticRepository(),
      recoveryRepository: MockRecoveryRepository(),
    );
  }

  final AuthRepository authRepository;
  final LearningRepository learningRepository;
  final DiagnosticRepository diagnosticRepository;
  final RecoveryRepository recoveryRepository;
}
