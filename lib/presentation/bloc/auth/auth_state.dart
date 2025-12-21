import 'package:equatable/equatable.dart';
import 'package:snake_classic/services/unified_user_service.dart';

/// Authentication status
enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// State class for AuthCubit
class AuthState extends Equatable {
  final AuthStatus status;
  final UnifiedUser? user;
  final String? errorMessage;
  final bool isLoading;
  final bool isFirstTimeUser;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.isLoading = false,
    this.isFirstTimeUser = true, // Default to true - assume first time until checked
  });

  /// Initial state
  factory AuthState.initial() => const AuthState();

  /// Create a copy with updated values
  AuthState copyWith({
    AuthStatus? status,
    UnifiedUser? user,
    String? errorMessage,
    bool? isLoading,
    bool? isFirstTimeUser,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isLoading: isLoading ?? this.isLoading,
      isFirstTimeUser: isFirstTimeUser ?? this.isFirstTimeUser,
    );
  }

  /// Whether user is signed in
  bool get isSignedIn => status == AuthStatus.authenticated && user != null;

  /// Whether user is anonymous
  bool get isAnonymous => user?.userType == UserType.anonymous;

  /// Whether user is a guest (offline user)
  bool get isGuestUser => user?.userType == UserType.guest;

  /// Whether user signed in with Google
  bool get isGoogleUser => user?.userType == UserType.google;

  /// User's display name
  String get displayName => user?.displayName ?? 'Player';

  /// User's username
  String get username => user?.username ?? 'Guest';

  /// User's photo URL
  String? get photoURL => user?.photoURL;

  /// User's high score
  int get highScore => user?.highScore ?? 0;

  /// User's total games played
  int get totalGamesPlayed => user?.totalGamesPlayed ?? 0;

  /// User's total score
  int get totalScore => user?.totalScore ?? 0;

  /// Current user ID
  String? get userId => user?.uid;

  @override
  List<Object?> get props => [
    status,
    user,
    errorMessage,
    isLoading,
    isFirstTimeUser,
  ];
}
