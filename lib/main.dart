import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'services/api/api_client.dart';
import 'services/api/auth_api_service.dart';
import 'services/api/calendar_api_service.dart';
import 'services/api/reflection_api_service.dart';
import 'services/api/task_api_service.dart';

import 'services/auth/auth_controller.dart';
import 'services/auth/auth_storage.dart';

import 'services/local/local_storage_service.dart';

import 'repositories/reflection_repository.dart';
import 'repositories/task_repository.dart';

import 'pages/auth/auth_page.dart';
import 'pages/today/today_controller.dart';
import 'pages/today/today_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding
      .ensureInitialized();

  await Hive.initFlutter();

  final localBox =
      await Hive.openBox(
    'madore',
  );

  final authBox =
      await Hive.openBox(
    'madore_auth',
  );

  final localStorage =
      LocalStorageService(
    localBox,
  );

  final authStorage =
      AuthStorage(
    authBox,
  );

  final apiClient =
      ApiClient(
    authStorage: authStorage,
  );

  final authApiService =
      AuthApiService();

  final authController =
      AuthController(
    apiService:
        authApiService,
    storage:
        authStorage,
  );

  await authController
      .initialize();

  final taskApiService =
      TaskApiService(
    apiClient,
  );

  final reflectionApiService =
      ReflectionApiService(
    apiClient,
  );

  final calendarApiService =
      CalendarApiService(
    apiClient,
  );

  final taskRepository =
      TaskRepository(
    taskApiService,
  );

  final reflectionRepository =
      ReflectionRepository(
    reflectionApiService,
  );

  final todayController =
      TodayController(
    taskRepository:
        taskRepository,
    reflectionRepository:
        reflectionRepository,
    calendarApiService:
        calendarApiService,
    localStorage:
        localStorage,
  );

  runApp(
    MadoreApp(
      authController:
          authController,
      todayController:
          todayController,
      apiClient:
          apiClient,
    ),
  );
}

class MadoreApp extends StatefulWidget {
  final AuthController authController;
  final TodayController todayController;
  final ApiClient apiClient;

  const MadoreApp({
    super.key,
    required this.authController,
    required this.todayController,
    required this.apiClient,
  });

  @override
  State<MadoreApp> createState() =>
      _MadoreAppState();
}

class _MadoreAppState
    extends State<MadoreApp> {
  @override
  void dispose() {
    widget.todayController
        .dispose();

    widget.apiClient.dispose();

    widget.authController
        .dispose();

    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return MaterialApp(
      title: 'Madore',
      debugShowCheckedModeBanner:
          false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed:
            Colors.indigo,
        scaffoldBackgroundColor:
            const Color(
          0xFFF6F7F9,
        ),
      ),
      home: AnimatedBuilder(
        animation:
            widget.authController,
        builder:
            (context, child) {
          if (!widget.authController
              .initialized) {
            return const Scaffold(
              body: Center(
                child:
                    CircularProgressIndicator(),
              ),
            );
          }

          if (widget.authController
              .isAuthenticated) {
            return TodayPage(
              controller:
                  widget.todayController,
              authController:
                  widget.authController,
            );
          }

          return AuthPage(
            controller:
                widget.authController,
          );
        },
      ),
    );
  }
}