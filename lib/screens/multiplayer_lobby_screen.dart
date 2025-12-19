import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:snake_classic/models/multiplayer_game.dart';
import 'package:snake_classic/providers/multiplayer_provider.dart';
import 'package:snake_classic/providers/theme_provider.dart';
import 'package:snake_classic/providers/user_provider.dart';
import 'package:snake_classic/screens/multiplayer_game_screen.dart';
import 'package:snake_classic/services/connectivity_service.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/app_background.dart';
import 'package:snake_classic/widgets/gradient_button.dart';

class MultiplayerLobbyScreen extends StatefulWidget {
  final String? gameId;

  const MultiplayerLobbyScreen({super.key, this.gameId});

  @override
  State<MultiplayerLobbyScreen> createState() => _MultiplayerLobbyScreenState();
}

class _MultiplayerLobbyScreenState extends State<MultiplayerLobbyScreen> {
  final TextEditingController _roomCodeController = TextEditingController();
  final ConnectivityService _connectivityService = ConnectivityService();
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _isOffline = !_connectivityService.isOnline;
    _connectivityService.addListener(_onConnectivityChanged);

    // If gameId is provided, join that game
    if (widget.gameId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_connectivityService.isOnline) {
          context.read<MultiplayerProvider>().joinGame(widget.gameId!);
        } else {
          _showOfflineMessage();
        }
      });
    }
  }

  @override
  void dispose() {
    _connectivityService.removeListener(_onConnectivityChanged);
    _roomCodeController.dispose();
    super.dispose();
  }

  void _onConnectivityChanged() {
    setState(() {
      _isOffline = !_connectivityService.isOnline;
    });
  }

  void _showOfflineMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.cloud_off, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'You\'re offline. Multiplayer requires an internet connection.',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.grey.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  bool _checkConnectivity() {
    if (_isOffline) {
      _showOfflineMessage();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<MultiplayerProvider, ThemeProvider, UserProvider>(
      builder: (context, multiplayerProvider, themeProvider, userProvider, child) {
        final theme = themeProvider.currentTheme;

        // Navigate to game screen when game starts
        if (multiplayerProvider.isGameActive) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const MultiplayerGameScreen(),
              ),
            );
          });
        }

        return Scaffold(
          body: AppBackground(
            theme: theme,
            child: SafeArea(
              child: multiplayerProvider.isInGame
                  ? _buildGameLobby(context, multiplayerProvider, theme, userProvider)
                  : _buildMainLobby(context, multiplayerProvider, theme, userProvider),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainLobby(
    BuildContext context,
    MultiplayerProvider multiplayerProvider,
    GameTheme theme,
    UserProvider userProvider,
  ) {
    return Column(
      children: [
        // Header
        _buildHeader(theme),
        
        // Main content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Quick Match Section
                _buildQuickMatchSection(context, multiplayerProvider, theme),
                
                const SizedBox(height: 32),
                
                // Join Game Section
                _buildJoinGameSection(context, multiplayerProvider, theme),
                
                const SizedBox(height: 32),
                
                // Create Game Section
                _buildCreateGameSection(context, multiplayerProvider, theme),
                
                if (multiplayerProvider.availableGames.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  _buildAvailableGamesSection(context, multiplayerProvider, theme),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGameLobby(
    BuildContext context,
    MultiplayerProvider multiplayerProvider,
    GameTheme theme,
    UserProvider userProvider,
  ) {
    final game = multiplayerProvider.currentGame!;
    
    return Column(
      children: [
        // Header with room info
        _buildGameHeader(theme, game),
        
        // Game info and players
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Game mode info
                _buildGameModeCard(theme, game),
                
                const SizedBox(height: 24),
                
                // Players list
                _buildPlayersSection(theme, game, userProvider),
                
                const Spacer(),
                
                // Ready/Leave buttons
                _buildLobbyActions(context, multiplayerProvider, theme, game, userProvider),
                
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(GameTheme theme) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          
          const SizedBox(width: 16),
          
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MULTIPLAYER',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: theme.accentColor,
                  letterSpacing: 2,
                ),
              ).animate().fadeIn().slideX(begin: -0.3),
              
              Text(
                'Play with friends online',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.accentColor.withValues(alpha: 0.7),
                ),
              ).animate().fadeIn(delay: 200.ms),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGameHeader(GameTheme theme, MultiplayerGame game) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              context.read<MultiplayerProvider>().leaveGame();
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.arrow_back,
              color: theme.accentColor,
              size: 24,
            ),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  game.modeDisplayName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: theme.accentColor,
                  ),
                ),
                
                if (game.roomCode != null)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.foodColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: theme.foodColor.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.key,
                          size: 16,
                          color: theme.foodColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Room: ${game.roomCode}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: theme.foodColor,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: game.roomCode!));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Room code copied!'),
                                backgroundColor: theme.foodColor,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Icon(
                            Icons.copy,
                            size: 14,
                            color: theme.foodColor,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickMatchSection(
    BuildContext context,
    MultiplayerProvider multiplayerProvider,
    GameTheme theme,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.withValues(alpha: 0.15),
            Colors.green.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.green.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.flash_on,
            size: 40,
            color: Colors.green,
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'QUICK MATCH',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.accentColor,
              letterSpacing: 1,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Jump into a game instantly',
            style: TextStyle(
              fontSize: 14,
              color: theme.accentColor.withValues(alpha: 0.7),
            ),
          ),
          
          const SizedBox(height: 20),
          
          GradientButton(
            onPressed: multiplayerProvider.isLoading ? null : () {
              multiplayerProvider.quickMatch(MultiplayerGameMode.classic);
            },
            text: multiplayerProvider.isLoading ? 'FINDING...' : 'PLAY NOW',
            primaryColor: Colors.green,
            secondaryColor: Colors.green.withValues(alpha: 0.8),
            icon: Icons.play_arrow,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3);
  }

  Widget _buildJoinGameSection(
    BuildContext context,
    MultiplayerProvider multiplayerProvider,
    GameTheme theme,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.withValues(alpha: 0.15),
            Colors.blue.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.blue.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.meeting_room,
            size: 40,
            color: Colors.blue,
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'JOIN ROOM',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.accentColor,
              letterSpacing: 1,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Enter room code to join',
            style: TextStyle(
              fontSize: 14,
              color: theme.accentColor.withValues(alpha: 0.7),
            ),
          ),
          
          const SizedBox(height: 20),
          
          TextField(
            controller: _roomCodeController,
            decoration: InputDecoration(
              hintText: 'Enter room code',
              hintStyle: TextStyle(
                color: theme.accentColor.withValues(alpha: 0.5),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.blue.withValues(alpha: 0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.blue.withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.blue,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: theme.backgroundColor.withValues(alpha: 0.5),
            ),
            style: TextStyle(color: theme.accentColor),
            textAlign: TextAlign.center,
            textCapitalization: TextCapitalization.characters,
          ),
          
          const SizedBox(height: 16),
          
          GradientButton(
            onPressed: multiplayerProvider.isLoading || _roomCodeController.text.isEmpty 
                ? null 
                : () {
                    multiplayerProvider.joinGame(_roomCodeController.text.trim());
                  },
            text: 'JOIN ROOM',
            primaryColor: Colors.blue,
            secondaryColor: Colors.blue.withValues(alpha: 0.8),
            icon: Icons.login,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3);
  }

  Widget _buildCreateGameSection(
    BuildContext context,
    MultiplayerProvider multiplayerProvider,
    GameTheme theme,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withValues(alpha: 0.15),
            Colors.purple.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.purple.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.add_circle,
            size: 40,
            color: Colors.purple,
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'CREATE ROOM',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.accentColor,
              letterSpacing: 1,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Start your own game',
            style: TextStyle(
              fontSize: 14,
              color: theme.accentColor.withValues(alpha: 0.7),
            ),
          ),
          
          const SizedBox(height: 20),
          
          Row(
            children: [
              Expanded(
                child: GradientButton(
                  onPressed: multiplayerProvider.isLoading ? null : () {
                    _showCreateGameDialog(context, multiplayerProvider, theme, false);
                  },
                  text: 'PUBLIC',
                  primaryColor: Colors.purple,
                  secondaryColor: Colors.purple.withValues(alpha: 0.8),
                  icon: Icons.public,
                ),
              ),
              
              const SizedBox(width: 12),
              
              Expanded(
                child: GradientButton(
                  onPressed: multiplayerProvider.isLoading ? null : () {
                    _showCreateGameDialog(context, multiplayerProvider, theme, true);
                  },
                  text: 'PRIVATE',
                  primaryColor: Colors.purple,
                  secondaryColor: Colors.purple.withValues(alpha: 0.8),
                  icon: Icons.lock,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3);
  }

  Widget _buildAvailableGamesSection(
    BuildContext context,
    MultiplayerProvider multiplayerProvider,
    GameTheme theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AVAILABLE GAMES',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.accentColor,
            letterSpacing: 1,
          ),
        ),
        
        const SizedBox(height: 16),
        
        ...multiplayerProvider.availableGames.map((game) =>
          _buildGameCard(context, multiplayerProvider, theme, game)
        ),
      ],
    );
  }

  Widget _buildGameCard(
    BuildContext context,
    MultiplayerProvider multiplayerProvider,
    GameTheme theme,
    MultiplayerGame game,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.backgroundColor.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.accentColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                game.modeEmoji,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  game.modeDisplayName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.accentColor,
                  ),
                ),
                Text(
                  '${game.players.length}/${game.maxPlayers} players',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.accentColor.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          
          GradientButton(
            onPressed: () {
              multiplayerProvider.joinGame(game.id);
            },
            text: 'JOIN',
            primaryColor: theme.accentColor,
            secondaryColor: theme.foodColor,
            width: 80,
            height: 40,
          ),
        ],
      ),
    );
  }

  Widget _buildGameModeCard(GameTheme theme, MultiplayerGame game) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.withValues(alpha: 0.15),
            Colors.orange.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                game.modeEmoji,
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  game.modeDisplayName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.accentColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getGameModeDescription(game.mode),
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.accentColor.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayersSection(GameTheme theme, MultiplayerGame game, UserProvider userProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.backgroundColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.accentColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PLAYERS (${game.players.length}/${game.maxPlayers})',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: theme.accentColor.withValues(alpha: 0.8),
              letterSpacing: 1,
            ),
          ),
          
          const SizedBox(height: 16),
          
          ...game.players.map((player) => _buildPlayerItem(theme, player, userProvider)),
          
          if (!game.isFull)
            _buildWaitingSlot(theme),
        ],
      ),
    );
  }

  Widget _buildPlayerItem(GameTheme theme, MultiplayerPlayer player, UserProvider userProvider) {
    final currentUserId = userProvider.currentUserId;
    final isCurrentUser = currentUserId == player.userId;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentUser 
            ? theme.accentColor.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isCurrentUser 
            ? Border.all(color: theme.accentColor.withValues(alpha: 0.3))
            : null,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: player.photoUrl != null 
                ? NetworkImage(player.photoUrl!)
                : null,
            backgroundColor: theme.accentColor.withValues(alpha: 0.2),
            child: player.photoUrl == null 
                ? Icon(
                    Icons.person,
                    color: theme.accentColor,
                    size: 24,
                  )
                : null,
          ),
          
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      player.displayName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: theme.accentColor,
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.accentColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'YOU',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: theme.accentColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _getStatusColor(player.status),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _getStatusText(player.status),
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.accentColor.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingSlot(GameTheme theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.3),
          style: BorderStyle.solid,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey.withValues(alpha: 0.3),
            child: Icon(
              Icons.person_add,
              color: Colors.grey,
              size: 24,
            ),
          ),
          
          const SizedBox(width: 12),
          
          Text(
            'Waiting for player...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLobbyActions(
    BuildContext context,
    MultiplayerProvider multiplayerProvider,
    GameTheme theme,
    MultiplayerGame game,
    UserProvider userProvider,
  ) {
    final currentUserId = userProvider.currentUserId;
    final currentPlayer = game.getPlayer(currentUserId ?? '');
    final isReady = currentPlayer?.status == PlayerStatus.ready;
    
    return Row(
      children: [
        Expanded(
          child: GradientButton(
            onPressed: () {
              multiplayerProvider.leaveGame();
              Navigator.of(context).pop();
            },
            text: 'LEAVE',
            primaryColor: Colors.red,
            secondaryColor: Colors.red.withValues(alpha: 0.8),
            icon: Icons.exit_to_app,
            outlined: true,
          ),
        ),
        
        const SizedBox(width: 16),
        
        Expanded(
          child: GradientButton(
            onPressed: multiplayerProvider.isLoading || isReady 
                ? null
                : () {
                    multiplayerProvider.markPlayerReady();
                  },
            text: isReady ? 'READY!' : 'READY',
            primaryColor: isReady ? Colors.green : theme.accentColor,
            secondaryColor: isReady ? Colors.green.withValues(alpha: 0.8) : theme.foodColor,
            icon: isReady ? Icons.check : Icons.check_circle,
          ),
        ),
      ],
    );
  }

  void _showCreateGameDialog(
    BuildContext context,
    MultiplayerProvider multiplayerProvider,
    GameTheme theme,
    bool isPrivate,
  ) {
    MultiplayerGameMode selectedMode = MultiplayerGameMode.classic;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: theme.backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Create ${isPrivate ? 'Private' : 'Public'} Room',
            style: TextStyle(
              color: theme.accentColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choose game mode:',
                style: TextStyle(
                  color: theme.accentColor.withValues(alpha: 0.8),
                ),
              ),
              
              const SizedBox(height: 16),
              
              ...MultiplayerGameMode.values.map((mode) => 
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: selectedMode == mode 
                      ? theme.accentColor.withValues(alpha: 0.1)
                      : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: selectedMode == mode 
                      ? Border.all(color: theme.accentColor.withValues(alpha: 0.3))
                      : null,
                  ),
                  child: ListTile(
                    leading: Icon(
                      selectedMode == mode 
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                      color: theme.accentColor,
                    ),
                    title: Text(
                      '${mode.modeEmoji} ${mode.modeDisplayName}',
                      style: TextStyle(color: theme.accentColor),
                    ),
                    subtitle: Text(
                      _getGameModeDescription(mode),
                      style: TextStyle(
                        color: theme.accentColor.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        selectedMode = mode;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: theme.accentColor.withValues(alpha: 0.7)),
              ),
            ),
            GradientButton(
              onPressed: () {
                Navigator.of(context).pop();
                multiplayerProvider.createGame(
                  mode: selectedMode,
                  isPrivate: isPrivate,
                );
              },
              text: 'CREATE',
              primaryColor: theme.accentColor,
              secondaryColor: theme.foodColor,
              width: 100,
              height: 40,
            ),
          ],
        ),
      ),
    );
  }

  String _getGameModeDescription(MultiplayerGameMode mode) {
    switch (mode) {
      case MultiplayerGameMode.classic:
        return 'Traditional Snake battle';
      case MultiplayerGameMode.speedRun:
        return 'Speed increases over time';
      case MultiplayerGameMode.survival:
        return 'Last snake standing wins';
      case MultiplayerGameMode.powerUpMadness:
        return 'Power-ups everywhere!';
    }
  }

  Color _getStatusColor(PlayerStatus status) {
    switch (status) {
      case PlayerStatus.waiting:
        return Colors.orange;
      case PlayerStatus.ready:
        return Colors.green;
      case PlayerStatus.playing:
        return Colors.blue;
      case PlayerStatus.crashed:
        return Colors.red;
      case PlayerStatus.disconnected:
        return Colors.grey;
    }
  }

  String _getStatusText(PlayerStatus status) {
    switch (status) {
      case PlayerStatus.waiting:
        return 'Waiting';
      case PlayerStatus.ready:
        return 'Ready';
      case PlayerStatus.playing:
        return 'Playing';
      case PlayerStatus.crashed:
        return 'Crashed';
      case PlayerStatus.disconnected:
        return 'Disconnected';
    }
  }
}