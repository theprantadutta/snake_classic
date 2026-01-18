import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snake_classic/models/user_profile.dart';
import 'package:snake_classic/services/social_service.dart';
import 'package:snake_classic/providers/providers.dart';

/// State for friends/social data
class FriendsState {
  final List<UserProfile> friends;
  final List<FriendRequest> friendRequests;
  final List<UserProfile> searchResults;
  final bool isLoading;
  final bool isSearching;
  final String searchQuery;
  final String? error;

  const FriendsState({
    this.friends = const [],
    this.friendRequests = const [],
    this.searchResults = const [],
    this.isLoading = false,
    this.isSearching = false,
    this.searchQuery = '',
    this.error,
  });

  /// Get received friend requests
  List<FriendRequest> get receivedRequests =>
      friendRequests.where((r) => r.type == FriendRequestType.received).toList();

  /// Get sent friend requests
  List<FriendRequest> get sentRequests =>
      friendRequests.where((r) => r.type == FriendRequestType.sent).toList();

  /// Check if there are pending received requests
  bool get hasReceivedRequests => receivedRequests.isNotEmpty;

  FriendsState copyWith({
    List<UserProfile>? friends,
    List<FriendRequest>? friendRequests,
    List<UserProfile>? searchResults,
    bool? isLoading,
    bool? isSearching,
    String? searchQuery,
    String? error,
  }) {
    return FriendsState(
      friends: friends ?? this.friends,
      friendRequests: friendRequests ?? this.friendRequests,
      searchResults: searchResults ?? this.searchResults,
      isLoading: isLoading ?? this.isLoading,
      isSearching: isSearching ?? this.isSearching,
      searchQuery: searchQuery ?? this.searchQuery,
      error: error,
    );
  }
}

/// Notifier for friends with TTL-based auto-refresh
class FriendsNotifier extends StateNotifier<FriendsState> {
  final Ref _ref;
  final SocialService _service;
  Timer? _ttlTimer;
  Timer? _searchDebounce;

  static const _ttl = Duration(minutes: 2);
  static const _searchDebounceDelay = Duration(milliseconds: 300);

  FriendsNotifier(this._ref)
      : _service = SocialService(),
        super(const FriendsState(isLoading: true)) {
    _initialize();
  }

  void _initialize() {
    // Initial load
    _loadData();

    // Set up TTL-based refresh
    _startTtlTimer();

    // Listen for connectivity changes - refresh when coming online
    _ref.listen<AsyncValue<bool>>(isOnlineProvider, (previous, next) {
      final wasOffline = previous?.value == false;
      final isNowOnline = next.value == true;
      if (wasOffline && isNowOnline) {
        refresh();
      }
    });
  }

  void _startTtlTimer() {
    _ttlTimer?.cancel();
    _ttlTimer = Timer.periodic(_ttl, (_) {
      final isOnline = _ref.read(isOnlineSyncProvider);
      if (isOnline) {
        refresh();
      }
    });
  }

  Future<void> _loadData() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final results = await Future.wait([
        _service.getFriends(),
        _service.getFriendRequests(),
      ]);

      state = state.copyWith(
        friends: results[0] as List<UserProfile>,
        friendRequests: results[1] as List<FriendRequest>,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load friends',
      );
    }
  }

  /// Refresh friends data from the server
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final results = await Future.wait([
        _service.getFriends(),
        _service.getFriendRequests(),
      ]);

      state = state.copyWith(
        friends: results[0] as List<UserProfile>,
        friendRequests: results[1] as List<FriendRequest>,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to refresh friends',
      );
    }
  }

  /// Search for users (debounced)
  void searchUsers(String query) {
    state = state.copyWith(searchQuery: query);

    if (query.length < 2) {
      state = state.copyWith(
        searchResults: [],
        isSearching: false,
      );
      return;
    }

    state = state.copyWith(isSearching: true);

    // Debounce search
    _searchDebounce?.cancel();
    _searchDebounce = Timer(_searchDebounceDelay, () async {
      try {
        final results = await _service.searchUsers(query);
        state = state.copyWith(
          searchResults: results,
          isSearching: false,
        );
      } catch (e) {
        state = state.copyWith(
          isSearching: false,
          error: 'Search failed',
        );
      }
    });
  }

  /// Clear search results
  void clearSearch() {
    _searchDebounce?.cancel();
    state = state.copyWith(
      searchQuery: '',
      searchResults: [],
      isSearching: false,
    );
  }

  /// Send friend request
  Future<bool> sendFriendRequest(String userId) async {
    final success = await _service.sendFriendRequest(userId);
    if (success) {
      // Refresh to get updated requests list
      await refresh();
    }
    return success;
  }

  /// Accept friend request
  Future<bool> acceptFriendRequest(String fromUserId) async {
    final success = await _service.acceptFriendRequest(fromUserId);
    if (success) {
      // Refresh to get updated friends and requests lists
      await refresh();
    }
    return success;
  }

  /// Reject friend request
  Future<bool> rejectFriendRequest(String fromUserId) async {
    final success = await _service.rejectFriendRequest(fromUserId);
    if (success) {
      // Refresh to get updated requests list
      await refresh();
    }
    return success;
  }

  /// Remove friend
  Future<bool> removeFriend(String friendUserId) async {
    final success = await _service.removeFriend(friendUserId);
    if (success) {
      // Refresh to get updated friends list
      await refresh();
    }
    return success;
  }

  /// Get user profile
  Future<UserProfile?> getUserProfile(String userId) async {
    return await _service.getUserProfile(userId);
  }

  /// Check if a user is already a friend
  bool isFriend(String userId) {
    return state.friends.any((f) => f.uid == userId);
  }

  /// Check if a friend request has been sent to a user
  bool hasSentRequestTo(String userId) {
    return state.sentRequests.any((r) => r.toUserId == userId);
  }

  /// Check if a friend request has been received from a user
  bool hasReceivedRequestFrom(String userId) {
    return state.receivedRequests.any((r) => r.fromUserId == userId);
  }

  @override
  void dispose() {
    _ttlTimer?.cancel();
    _searchDebounce?.cancel();
    super.dispose();
  }
}

/// Provider for friends state
final friendsProvider =
    StateNotifierProvider<FriendsNotifier, FriendsState>((ref) {
  return FriendsNotifier(ref);
});

/// Convenience provider for friends list
final friendsListProvider = Provider<List<UserProfile>>((ref) {
  return ref.watch(friendsProvider).friends;
});

/// Convenience provider for friend requests
final friendRequestsProvider = Provider<List<FriendRequest>>((ref) {
  return ref.watch(friendsProvider).friendRequests;
});

/// Convenience provider for received friend requests
final receivedRequestsProvider = Provider<List<FriendRequest>>((ref) {
  return ref.watch(friendsProvider).receivedRequests;
});

/// Convenience provider for sent friend requests
final sentRequestsProvider = Provider<List<FriendRequest>>((ref) {
  return ref.watch(friendsProvider).sentRequests;
});

/// Convenience provider for search results
final friendSearchResultsProvider = Provider<List<UserProfile>>((ref) {
  return ref.watch(friendsProvider).searchResults;
});

/// Convenience provider for loading state
final friendsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(friendsProvider).isLoading;
});

/// Convenience provider for searching state
final friendsSearchingProvider = Provider<bool>((ref) {
  return ref.watch(friendsProvider).isSearching;
});

/// Convenience provider for pending requests count
final pendingRequestsCountProvider = Provider<int>((ref) {
  return ref.watch(friendsProvider).receivedRequests.length;
});
