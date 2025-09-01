import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:snake_classic/providers/theme_provider.dart';
import 'package:snake_classic/models/user_profile.dart';
import 'package:snake_classic/services/social_service.dart';
import 'package:snake_classic/utils/constants.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> with SingleTickerProviderStateMixin {
  final SocialService _socialService = SocialService();
  final TextEditingController _searchController = TextEditingController();
  
  late TabController _tabController;
  List<UserProfile> _friends = [];
  List<FriendRequest> _friendRequests = [];
  List<UserProfile> _searchResults = [];
  bool _isLoading = false;
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final results = await Future.wait([
        _socialService.getFriends(),
        _socialService.getFriendRequests(),
      ]);
      
      setState(() {
        _friends = results[0] as List<UserProfile>;
        _friendRequests = results[1] as List<FriendRequest>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _searchUsers(String query) async {
    if (query.length < 2) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      final results = await _socialService.searchUsers(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = themeProvider.currentTheme;

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.backgroundColor,
                  theme.backgroundColor.withValues(alpha: 0.8),
                  theme.accentColor.withValues(alpha: 0.1),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildHeader(theme),
                  _buildSearchBar(theme),
                  _buildTabBar(theme),
                  Expanded(
                    child: _isLoading
                        ? _buildLoadingIndicator(theme)
                        : TabBarView(
                            controller: _tabController,
                            children: [
                              _buildFriendsList(theme),
                              _buildFriendRequestsList(theme),
                              _buildSearchResults(theme),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(GameTheme theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.arrow_back,
              color: theme.accentColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.people,
            color: theme.accentColor,
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            'Friends',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.accentColor,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: _loadData,
            icon: Icon(
              Icons.refresh,
              color: theme.accentColor.withValues(alpha: 0.7),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(GameTheme theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.backgroundColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.accentColor.withValues(alpha: 0.2)),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by name or email...',
          hintStyle: TextStyle(
            color: theme.accentColor.withValues(alpha: 0.5),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: theme.accentColor.withValues(alpha: 0.7),
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                      _searchResults = [];
                    });
                    _tabController.animateTo(0);
                  },
                  icon: Icon(
                    Icons.clear,
                    color: theme.accentColor.withValues(alpha: 0.7),
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        style: TextStyle(color: theme.accentColor),
        onChanged: (value) {
          setState(() => _searchQuery = value);
          _searchUsers(value);
          if (value.isNotEmpty) {
            _tabController.animateTo(2);
          }
        },
      ),
    );
  }

  Widget _buildTabBar(GameTheme theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: TabBar(
        controller: _tabController,
        indicatorColor: theme.accentColor,
        labelColor: theme.accentColor,
        unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
        tabs: [
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Friends'),
                if (_friends.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.accentColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_friends.length}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Requests'),
                if (_friendRequests.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_friendRequests.length}',
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Tab(text: 'Search'),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator(GameTheme theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(theme.accentColor),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading friends...',
            style: TextStyle(
              color: theme.accentColor.withValues(alpha: 0.8),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendsList(GameTheme theme) {
    if (_friends.isEmpty) {
      return _buildEmptyState(
        icon: Icons.people_outline,
        title: 'No Friends Yet',
        subtitle: 'Search for users to add as friends!',
        theme: theme,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _friends.length,
      itemBuilder: (context, index) {
        final friend = _friends[index];
        return _buildUserCard(
          user: friend,
          theme: theme,
          trailing: PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: theme.accentColor.withValues(alpha: 0.7),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'view_profile',
                child: Row(
                  children: [
                    Icon(Icons.person, color: theme.accentColor),
                    const SizedBox(width: 8),
                    const Text('View Profile'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'remove_friend',
                child: Row(
                  children: [
                    const Icon(Icons.person_remove, color: Colors.red),
                    const SizedBox(width: 8),
                    const Text('Remove Friend'),
                  ],
                ),
              ),
            ],
            onSelected: (value) => _handleFriendAction(value, friend),
          ),
        ).animate().fadeIn(delay: (100 * index).ms).slideX(begin: 0.2);
      },
    );
  }

  Widget _buildFriendRequestsList(GameTheme theme) {
    final receivedRequests = _friendRequests.where((r) => r.type == FriendRequestType.received).toList();
    final sentRequests = _friendRequests.where((r) => r.type == FriendRequestType.sent).toList();

    if (receivedRequests.isEmpty && sentRequests.isEmpty) {
      return _buildEmptyState(
        icon: Icons.mail_outline,
        title: 'No Friend Requests',
        subtitle: 'Friend requests will appear here',
        theme: theme,
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (receivedRequests.isNotEmpty) ...[
          Text(
            'Received (${receivedRequests.length})',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.accentColor,
            ),
          ),
          const SizedBox(height: 12),
          ...receivedRequests.map((request) => _buildFriendRequestCard(request, theme)),
          const SizedBox(height: 20),
        ],
        if (sentRequests.isNotEmpty) ...[
          Text(
            'Sent (${sentRequests.length})',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.accentColor.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 12),
          ...sentRequests.map((request) => _buildSentRequestCard(request, theme)),
        ],
      ],
    );
  }

  Widget _buildSearchResults(GameTheme theme) {
    if (_searchQuery.isEmpty) {
      return _buildEmptyState(
        icon: Icons.search,
        title: 'Search for Friends',
        subtitle: 'Enter a name or email to find friends',
        theme: theme,
      );
    }

    if (_isSearching) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(theme.accentColor),
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return _buildEmptyState(
        icon: Icons.search_off,
        title: 'No Users Found',
        subtitle: 'Try searching with a different name or email',
        theme: theme,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        return _buildUserCard(
          user: user,
          theme: theme,
          trailing: _buildSearchUserActions(user, theme),
        ).animate().fadeIn(delay: (100 * index).ms).slideX(begin: 0.2);
      },
    );
  }

  Widget _buildUserCard({
    required UserProfile user,
    required GameTheme theme,
    Widget? trailing,
  }) {
    return Card(
      color: theme.backgroundColor.withValues(alpha: 0.5),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.accentColor.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: theme.accentColor.withValues(alpha: 0.2),
              backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
              child: user.photoUrl == null
                  ? Text(
                      user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : 'U',
                      style: TextStyle(
                        color: theme.accentColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          user.displayName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.accentColor,
                          ),
                        ),
                      ),
                      Text(
                        user.status.emoji,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        user.status.displayName,
                        style: TextStyle(
                          fontSize: 12,
                          color: _getStatusColor(user.status),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.emoji_events,
                        size: 14,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${user.highScore}',
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.accentColor.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.games,
                        size: 14,
                        color: theme.accentColor.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${user.totalGamesPlayed} games',
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.accentColor.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                  if (user.statusMessage != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      user.statusMessage!,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.accentColor.withValues(alpha: 0.5),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildFriendRequestCard(FriendRequest request, GameTheme theme) {
    return Card(
      color: theme.backgroundColor.withValues(alpha: 0.5),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.blue.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: theme.accentColor.withValues(alpha: 0.2),
              backgroundImage: request.fromUserPhotoUrl != null 
                  ? NetworkImage(request.fromUserPhotoUrl!) 
                  : null,
              child: request.fromUserPhotoUrl == null
                  ? Text(
                      request.fromUserName.isNotEmpty ? request.fromUserName[0].toUpperCase() : 'U',
                      style: TextStyle(
                        color: theme.accentColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.fromUserName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.accentColor,
                    ),
                  ),
                  Text(
                    'Sent ${request.formattedDate}',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.accentColor.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () => _rejectFriendRequest(request.fromUserId),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                  child: const Text('Reject'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _acceptFriendRequest(request.fromUserId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.accentColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Accept'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSentRequestCard(FriendRequest request, GameTheme theme) {
    return Card(
      color: theme.backgroundColor.withValues(alpha: 0.3),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.accentColor.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: theme.accentColor.withValues(alpha: 0.1),
              child: Text(
                request.toUserName.isNotEmpty ? request.toUserName[0].toUpperCase() : 'U',
                style: TextStyle(
                  color: theme.accentColor.withValues(alpha: 0.7),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.toUserName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.accentColor.withValues(alpha: 0.8),
                    ),
                  ),
                  Text(
                    'Sent ${request.formattedDate}',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.accentColor.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Pending',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchUserActions(UserProfile user, GameTheme theme) {
    // Check if already friends or have pending request
    final isFriend = _friends.any((f) => f.uid == user.uid);
    final hasSentRequest = _friendRequests.any(
      (r) => r.toUserId == user.uid && r.type == FriendRequestType.sent,
    );
    final hasReceivedRequest = _friendRequests.any(
      (r) => r.fromUserId == user.uid && r.type == FriendRequestType.received,
    );

    if (isFriend) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '✓ Friends',
          style: TextStyle(
            fontSize: 12,
            color: Colors.green,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    if (hasSentRequest) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Pending',
          style: TextStyle(
            fontSize: 12,
            color: Colors.orange,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    if (hasReceivedRequest) {
      return ElevatedButton(
        onPressed: () => _acceptFriendRequest(user.uid),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.accentColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text('Accept'),
      );
    }

    return ElevatedButton(
      onPressed: () => _sendFriendRequest(user.uid),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: const Text('Add Friend'),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required GameTheme theme,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: theme.accentColor.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.accentColor.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: theme.accentColor.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(UserStatus status) {
    switch (status) {
      case UserStatus.online:
        return Colors.green;
      case UserStatus.playing:
        return Colors.blue;
      case UserStatus.offline:
        return Colors.grey;
    }
  }

  Future<void> _sendFriendRequest(String userId) async {
    final success = await _socialService.sendFriendRequest(userId);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Friend request sent!')),
      );
      _loadData();
    }
  }

  Future<void> _acceptFriendRequest(String fromUserId) async {
    final success = await _socialService.acceptFriendRequest(fromUserId);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Friend request accepted!')),
      );
      _loadData();
    }
  }

  Future<void> _rejectFriendRequest(String fromUserId) async {
    final success = await _socialService.rejectFriendRequest(fromUserId);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Friend request rejected')),
      );
      _loadData();
    }
  }

  void _handleFriendAction(String action, UserProfile friend) {
    switch (action) {
      case 'view_profile':
        // TODO: Navigate to user profile screen
        break;
      case 'remove_friend':
        _showRemoveFriendDialog(friend);
        break;
    }
  }

  void _showRemoveFriendDialog(UserProfile friend) {
    final theme = context.read<ThemeProvider>().currentTheme;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: theme.accentColor.withValues(alpha: 0.3)),
        ),
        title: Text(
          'Remove Friend',
          style: TextStyle(color: theme.accentColor),
        ),
        content: Text(
          'Remove ${friend.displayName} from your friends list?',
          style: TextStyle(color: theme.accentColor.withValues(alpha: 0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: theme.accentColor.withValues(alpha: 0.7)),
            ),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              navigator.pop();
              final success = await _socialService.removeFriend(friend.uid);
              if (success && mounted) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(content: Text('${friend.displayName} removed from friends')),
                );
                _loadData();
              }
            },
            child: const Text(
              'Remove',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}