import 'package:hive/hive.dart';

import '../../models/daily_data.dart';

class LocalStorageService {
  final Box box;

  LocalStorageService(this.box);

  DailyData getDailyData(String key) {
    final data = box.get(key);

    if (data == null) {
      return DailyData.empty();
    }

    if (data is Map) {
      return DailyData.fromMap(data);
    }

    return DailyData.empty();
  }

  Future<void> saveDailyData(
    String key,
    DailyData data,
  ) async {
    await box.put(
      key,
      data.toMap(),
    );
  }

  List<String> getDayKeys() {
    return box.keys
        .whereType<String>()
        .toList();
  }

  dynamic getRaw(String key) {
    return box.get(key);
  }
}