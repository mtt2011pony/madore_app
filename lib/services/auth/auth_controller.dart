import 'package:flutter/foundation.dart';

import '../../models/auth_user.dart';
import '../../models/user_session.dart';
import '../api/auth_api_service.dart';
import 'auth_storage.dart';

class AuthController extends ChangeNotifier {
  AuthController({
    required AuthStorage storage,
    AuthApiService? apiService,
  })  : _storage = storage,
        _apiService = apiService ?? AuthApiService();

  final AuthStorage _storage;
  final AuthApiService _apiService;

  UserSession? _session;
  AuthUser? _user;

  bool _initialized = false;
  bool _isLoading = false;

  String? _errorMessage;

  // ---------------------------------------------------------------------------
  // Public state
  // ---------------------------------------------------------------------------

  bool get initialized => _initialized;

  bool get isAuthenticated {
    return _session != null && _user != null;
  }

  bool get isLoggedIn => isAuthenticated;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  AuthUser? get user => _user;

  UserSession? get session => _session;

  String? get token => _session?.token;

  // ---------------------------------------------------------------------------
  // Initialization
  // ---------------------------------------------------------------------------

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    _setLoading(true);

    try {
      final token = _storage.getToken();

      debugPrint(
        '[AuthController] stored token: '
        '${token == null ? 'NULL' : 'FOUND'}',
      );

      if (token == null || token.isEmpty) {
        debugPrint(
          '[AuthController] no stored token',
        );

        return;
      }

      final user = await _apiService.getMe(
        token: token,
      );

      debugPrint(
        '[AuthController] /me success: '
        '${user.email}',
      );

      _session = UserSession(
        token: token,
        user: user,
      );

      _user = user;

      debugPrint(
        '[AuthController] session restored: '
        'authenticated=$isAuthenticated',
      );
    } catch (e) {
      debugPrint(
        '[AuthController] restore failed: $e',
      );

      _session = null;
      _user = null;

      await _storage.clearToken();

      _errorMessage =
          _errorMessageFromException(e);
    } finally {
      _initialized = true;

      _setLoading(false);

      notifyListeners();

      debugPrint(
        '[AuthController] initialize finished: '
        'initialized=$_initialized, '
        'authenticated=$isAuthenticated',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Login
  // ---------------------------------------------------------------------------

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    clearError();

    try {
      final session = await _apiService.login(
        email: email.trim(),
        password: password,
      );

      _session = session;
      _user = session.user;

      await _storage.saveToken(
        session.token,
      );

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage =
          _errorMessageFromException(e);

      notifyListeners();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ---------------------------------------------------------------------------
  // Register
  // ---------------------------------------------------------------------------

  Future<bool> register({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    clearError();

    try {
      final session =
          await _apiService.register(
        email: email.trim(),
        password: password,
      );

      _session = session;
      _user = session.user;

      await _storage.saveToken(
        session.token,
      );

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage =
          _errorMessageFromException(e);

      notifyListeners();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ---------------------------------------------------------------------------
  // Current user
  // ---------------------------------------------------------------------------

  Future<bool> loadCurrentUser() async {
    final currentSession = _session;

    if (currentSession == null) {
      return false;
    }

    _setLoading(true);
    clearError();

    try {
      final user = await _apiService.getMe(
        token: currentSession.token,
      );

      _user = user;

      notifyListeners();

      return true;
    } catch (e) {
      _session = null;
      _user = null;

      await _storage.clearToken();

      _errorMessage =
          _errorMessageFromException(e);

      notifyListeners();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ---------------------------------------------------------------------------
  // Logout
  // ---------------------------------------------------------------------------

  Future<void> logout() async {
    final currentSession = _session;

    _session = null;
    _user = null;

    clearError();

    await _storage.clearToken();

    notifyListeners();

    if (currentSession == null) {
      return;
    }

    try {
      await _apiService.logout(
        token: currentSession.token,
      );
    } catch (_) {
      // 本地已经退出。
      // 后端 logout 失败不影响本地登录状态。
    }
  }

  // ---------------------------------------------------------------------------
  // Session
  // ---------------------------------------------------------------------------

  void setSession(
    UserSession session,
  ) {
    _session = session;
    _user = session.user;

    clearError();

    notifyListeners();
  }

  void clearSession() {
    _session = null;
    _user = null;

    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Error
  // ---------------------------------------------------------------------------

  void clearError() {
    if (_errorMessage == null) {
      return;
    }

    _errorMessage = null;

    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Loading
  // ---------------------------------------------------------------------------

  void _setLoading(
    bool value,
  ) {
    if (_isLoading == value) {
      return;
    }

    _isLoading = value;

    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _errorMessageFromException(
    Object error,
  ) {
    final message = error.toString();

    if (message.startsWith(
      'Exception: ',
    )) {
      return message.substring(
        'Exception: '.length,
      );
    }

    return message;
  }

  // ---------------------------------------------------------------------------
  // Dispose
  // ---------------------------------------------------------------------------

  @override
  void dispose() {
    _apiService.dispose();

    super.dispose();
  }
}
