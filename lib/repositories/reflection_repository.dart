import '../services/api/reflection_api_service.dart';

class ReflectionRepository {
  final ReflectionApiService apiService;

  ReflectionRepository(
    this.apiService,
  );

  Future<String> getReflection(
    String dayKey,
  ) {
    return apiService.getReflection(
      dayKey,
    );
  }

  Future<void> saveReflection(
    String dayKey,
    String reflection,
  ) {
    return apiService.saveReflection(
      date: dayKey,
      content: reflection,
    );
  }
}