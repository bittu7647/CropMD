import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../models/user_profile.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

final userProfileProvider = StreamProvider<UserProfile?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(null);
  
  final authService = ref.watch(authServiceProvider);
  return authService.getUserProfile(user.uid);
});

class AuthStateModel {
  final bool isLoading;
  final String? error;

  AuthStateModel({this.isLoading = false, this.error});

  AuthStateModel copyWith({bool? isLoading, String? error}) {
    return AuthStateModel(
      isLoading: isLoading ?? this.isLoading,
      error: error, // Error can be set to null explicitly
    );
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthStateModel>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthController(authService);
});

class AuthController extends StateNotifier<AuthStateModel> {
  final AuthService _authService;

  AuthController(this._authService) : super(AuthStateModel());

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authService.signInWithEmail(email, password);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authService.signUpWithEmail(email, password);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> saveProfile(UserProfile profile) async {
    await _authService.saveUserProfile(profile);
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await _authService.signOut();
    state = AuthStateModel();
  }
}
