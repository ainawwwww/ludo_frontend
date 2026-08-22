import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/core/network/api_client.dart';
import 'package:ludo_vibe/core/network/api_endpoints.dart';
import 'package:ludo_vibe/core/network/websocket_service.dart';
import 'package:ludo_vibe/core/storage/storage_service.dart';
import 'package:ludo_vibe/features/auth/models/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final storageService = ref.watch(storageServiceProvider);
  final webSocketService = ref.watch(webSocketServiceProvider);
  return AuthRepository(
    apiClient: apiClient,
    storageService: storageService,
    webSocketService: webSocketService,
  );
});

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(AuthState()) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authRepository.getMe();
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(user: null, isLoading: false);
    }
  }

  Future<bool> guestLogin() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authRepository.guestLogin();
      state = state.copyWith(user: user, isLoading: false);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Guest login failed.');
      return false;
    }
  }

  Future<bool> login(String usernameOrEmail, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authRepository.login(usernameOrEmail: usernameOrEmail, password: password);
      state = state.copyWith(user: user, isLoading: false);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Login failed.');
      return false;
    }
  }

  Future<bool> register(String username, String email, String password, {String country = 'PK'}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authRepository.register(
        username: username,
        email: email,
        password: password,
        country: country,
      );
      state = state.copyWith(user: user, isLoading: false);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Registration failed.');
      return false;
    }
  }


  Future<bool> googleSignIn(String idToken) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authRepository.googleSignIn(idToken: idToken);
      state = state.copyWith(user: user, isLoading: false);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Google sign-in failed.');
      return false;
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    state = AuthState();
  }
}

class AuthRepository {
  final ApiClient _apiClient;
  final StorageService _storageService;
  final WebSocketService _webSocketService;

  AuthRepository({
    required ApiClient apiClient,
    required StorageService storageService,
    required WebSocketService webSocketService,
  })  : _apiClient = apiClient,
        _storageService = storageService,
        _webSocketService = webSocketService;

  Future<UserModel> guestLogin() async {
    final deviceId = await _storageService.getDeviceId();
    debugPrint('🔐 [GUEST] Calling POST ${ApiEndpoints.guest} with device_id: $deviceId');
    
    final response = await _apiClient.post(
      ApiEndpoints.guest,
      data: {'device_id': deviceId},
    );

    debugPrint('🔐 [GUEST] Raw response: $response');

    final user = UserModel.fromJson(response);
    debugPrint('🔐 [GUEST] Parsed user: id=${user.id}, username=${user.username}, token=${user.token != null ? "present" : "MISSING!"}');
    
    if (user.token != null) {
      await _storageService.saveToken(user.token!);
      await _storageService.saveUserInfo(user.id, user.username);
      
      // Connect WS & subscribe to user private channel
      await _webSocketService.connect();
      _webSocketService.subscribeToUserChannel(user.id);
    } else {
      debugPrint('⚠️ [GUEST] WARNING: No token received from backend! User will be unauthenticated.');
    }
    return user;
  }

  Future<UserModel> login({required String usernameOrEmail, required String password}) async {
    debugPrint('🔐 [LOGIN] Calling POST ${ApiEndpoints.login} for: $usernameOrEmail');
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: {
        'username': usernameOrEmail,
        'email': usernameOrEmail,
        'password': password,
      },
    );

    debugPrint('🔐 [LOGIN] Response: $response');
    final user = UserModel.fromJson(response);
    if (user.token != null) {
      await _storageService.saveToken(user.token!);
      await _storageService.saveUserInfo(user.id, user.username);
      
      await _webSocketService.connect();
      _webSocketService.subscribeToUserChannel(user.id);
    }
    return user;
  }

  Future<UserModel> register({
    required String username,
    required String email,
    required String password,
    String country = 'PK',
  }) async {
    debugPrint('🔐 [REGISTER] Calling POST ${ApiEndpoints.register} for: $username, $email');
    final response = await _apiClient.post(
      ApiEndpoints.register,
      data: {
        'username': username,
        'email': email,
        'password': password,
        'password_confirmation': password,
        'country': country,
      },
    );

    debugPrint('🔐 [REGISTER] Response: $response');
    final user = UserModel.fromJson(response);
    if (user.token != null) {
      await _storageService.saveToken(user.token!);
      await _storageService.saveUserInfo(user.id, user.username);
      
      await _webSocketService.connect();
      _webSocketService.subscribeToUserChannel(user.id);
    }
    return user;
  }

  Future<UserModel> googleSignIn({required String idToken}) async {
    debugPrint('🔐 [GOOGLE AUTH] Calling POST ${ApiEndpoints.google} with id_token length: ${idToken.length}');
    final response = await _apiClient.post(
      ApiEndpoints.google,
      data: {'id_token': idToken},
    );

    debugPrint('🔐 [GOOGLE AUTH] Response: $response');
    final user = UserModel.fromJson(response);
    if (user.token != null) {
      await _storageService.saveToken(user.token!);
      await _storageService.saveUserInfo(user.id, user.username);
      
      await _webSocketService.connect();
      _webSocketService.subscribeToUserChannel(user.id);
    }
    return user;
  }


  Future<UserModel?> getMe() async {
    final token = await _storageService.getToken();
    if (token == null || token.isEmpty) return null;

    final response = await _apiClient.get(ApiEndpoints.me);
    final user = UserModel.fromJson(response, token: token);
    
    await _webSocketService.connect();
    _webSocketService.subscribeToUserChannel(user.id);

    return user;
  }

  Future<void> logout() async {
    try {
      await _apiClient.post(ApiEndpoints.logout);
    } catch (_) {}
    _webSocketService.disconnect();
    await _storageService.clearAll();
  }
}
