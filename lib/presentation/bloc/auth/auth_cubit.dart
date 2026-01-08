import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snake_classic/services/unified_user_service.dart';

import 'auth_state.dart';

export 'auth_state.dart';

/// Cubit for managing authentication state
class AuthCubit extends Cubit<AuthState> {
  final UnifiedUserService _userService;
  VoidCallback? _userServiceListener;

  AuthCubit(this._userService) : super(AuthState.initial());

  /// Initialize the auth cubit
  Future<void> initialize() async {
    if (state.status == AuthStatus.authenticated) return;

    emit(state.copyWith(status: AuthStatus.loading, isLoading: true));

    try {
      // Initialize the user service if not already initialized
      if (!_userService.isInitialized) {
        await _userService.initialize();
      }

      // Check if first time user
      final isFirstTime = await _isFirstTimeUser();

      // Listen to user service changes
      _userServiceListener = () {
        _onUserServiceChanged();
      };
      _userService.addListener(_userServiceListener!);

      // Update state based on current user
      _updateFromUserService(isFirstTime: isFirstTime);
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: e.toString(),
          isLoading: false,
        ),
      );
    }
  }

  void _onUserServiceChanged() {
    _updateFromUserService();
  }

  void _updateFromUserService({bool? isFirstTime}) {
    final user = _userService.currentUser;

    if (user != null) {
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          isLoading: false,
          isFirstTimeUser: isFirstTime ?? state.isFirstTimeUser,
          clearError: true,
        ),
      );
    } else {
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          clearUser: true,
          isLoading: false,
          isFirstTimeUser: isFirstTime ?? state.isFirstTimeUser,
        ),
      );
    }
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final result = await _userService.signInWithGoogle();

      if (!result) {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: 'Google sign-in failed',
          ),
        );
      }

      return result;
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
      return false;
    }
  }

  /// Sign in anonymously (guest mode)
  Future<bool> signInAnonymously() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final result = await _userService.signInAnonymously();

      if (!result) {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: 'Anonymous sign-in failed',
          ),
        );
      }

      return result;
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    emit(state.copyWith(isLoading: true));

    try {
      await _userService.signOut();
      // User service listener will update the state
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  /// Update username
  Future<bool> updateUsername(String newUsername) async {
    try {
      final result = await _userService.updateUsername(newUsername);
      return result;
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
      return false;
    }
  }

  /// Update guest username
  Future<bool> updateGuestUsername(String newUsername) async {
    try {
      final result = await _userService.updateGuestUsername(newUsername);
      return result;
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
      return false;
    }
  }

  /// Update authenticated username
  Future<bool> updateAuthenticatedUsername(String newUsername) async {
    try {
      final result = await _userService.updateAuthenticatedUsername(
        newUsername,
      );
      return result;
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
      return false;
    }
  }

  /// Update game stats
  Future<void> updateGameStats({
    int? newHighScore,
    int? gamesPlayed,
    int? totalScore,
    int? level,
  }) async {
    await _userService.updateGameStats(
      newHighScore: newHighScore,
      gamesPlayed: gamesPlayed,
      totalScore: totalScore,
      level: level,
    );
  }

  /// Check if this is a first-time user
  Future<bool> _isFirstTimeUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return !(prefs.getBool('first_time_setup_complete') ?? false);
    } catch (e) {
      return true;
    }
  }

  /// Mark first-time setup as complete
  Future<void> markFirstTimeSetupComplete() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('first_time_setup_complete', true);
      emit(state.copyWith(isFirstTimeUser: false));
    } catch (e) {
      // Ignore error, not critical
    }
  }

  /// Clear any error message
  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  @override
  Future<void> close() {
    if (_userServiceListener != null) {
      _userService.removeListener(_userServiceListener!);
    }
    return super.close();
  }
}
