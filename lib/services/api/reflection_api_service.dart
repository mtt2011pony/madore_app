import 'api_client.dart';

class ReflectionApiService {
  final ApiClient apiClient;

  ReflectionApiService(
    this.apiClient,
  );

  Future<String> getReflection(
    String date,
  ) async {
    final result = await apiClient.get(
      '/api/reflections/?date=$date',
    );

    final data = result['data'];

    if (data == null) {
      return '';
    }

    if (data is Map) {
      return data['content']?.toString() ?? '';
    }

    if (data is String) {
      return data;
    }

    return '';
  }

  Future<void> saveReflection({
    required String date,
    required String content,
  }) async {
    await apiClient.put(
      '/api/reflections/',
      body: {
        'date': date,
        'content': content,
      },
    );
  }
}