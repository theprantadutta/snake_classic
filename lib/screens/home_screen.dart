import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../utils/constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              gameProvider.gameState.currentTheme.backgroundColor,
              gameProvider.gameState.currentTheme.gridColor,
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Adjust padding based on screen size
              final double horizontalPadding = constraints.maxWidth > 600 ? 40.0 : 20.0;
              final double verticalPadding = constraints.maxHeight > 800 ? 40.0 : 20.0;
              
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - verticalPadding * 2,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Animated snake title
                          const SnakeTitle(),
                          const SizedBox(height: 30),
                          
                          // High score display
                          HighScoreDisplay(gameProvider: gameProvider),
                          const SizedBox(height: 30),
                          
                          // Play button
                          PlayButton(onPressed: () {
                            gameProvider.startGame();
                            Navigator.pushNamed(context, '/game');
                          }),
                          const SizedBox(height: 20),
                          
                          // Theme selector
                          ThemeSelector(gameProvider: gameProvider),
                          const SizedBox(height: 20),
                          
                          // Control type selector
                          ControlTypeSelector(gameProvider: gameProvider),
                          const SizedBox(height: 20),
                          
                          // Settings button
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/settings');
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              // Adjust button size based on screen width
                              minimumSize: Size(
                                constraints.maxWidth > 600 ? 200 : 150,
                                50,
                              ),
                            ),
                            child: const Text(
                              'SETTINGS',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class SnakeTitle extends StatelessWidget {
  const SnakeTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return const LinearGradient(
          colors: [Colors.green, Colors.blue, Colors.purple],
          tileMode: TileMode.mirror,
        ).createShader(bounds);
      },
      child: const Text(
        'SNAKE',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 64,
          fontWeight: FontWeight.bold,
          fontFamily: 'Arial',
        ),
      ),
    );
  }
}

class HighScoreDisplay extends StatelessWidget {
  final GameProvider gameProvider;

  const HighScoreDisplay({super.key, required this.gameProvider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: gameProvider.gameState.currentTheme.snakeColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: gameProvider.gameState.currentTheme.snakeColor,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          const Text(
            'HIGH SCORE',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            gameProvider.gameState.highScore.toString(),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class PlayButton extends StatelessWidget {
  final VoidCallback onPressed;

  const PlayButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 10,
      ),
      child: const Text(
        'PLAY',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

class ThemeSelector extends StatelessWidget {
  final GameProvider gameProvider;

  const ThemeSelector({super.key, required this.gameProvider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: gameProvider.gameState.currentTheme.backgroundColor.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: gameProvider.gameState.currentTheme.gridColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Theme',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            children: GameTheme.values.map((theme) {
              return ChoiceChip(
                label: Text(
                  theme.name,
                  style: TextStyle(
                    color: gameProvider.gameState.currentTheme == theme 
                        ? Colors.white 
                        : Colors.grey,
                  ),
                ),
                selected: gameProvider.gameState.currentTheme == theme,
                selectedColor: gameProvider.gameState.currentTheme.snakeColor,
                backgroundColor: Colors.transparent,
                onSelected: (selected) {
                  if (selected) {
                    gameProvider.changeTheme(theme);
                  }
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class ControlTypeSelector extends StatelessWidget {
  final GameProvider gameProvider;

  const ControlTypeSelector({super.key, required this.gameProvider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: gameProvider.gameState.currentTheme.backgroundColor.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: gameProvider.gameState.currentTheme.gridColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Controls',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          ToggleButtons(
            isSelected: [
              gameProvider.gameState.controlType == ControlType.swipe,
              gameProvider.gameState.controlType == ControlType.buttons,
            ],
            onPressed: (index) {
              gameProvider.changeControlType(
                index == 0 ? ControlType.swipe : ControlType.buttons,
              );
            },
            borderRadius: BorderRadius.circular(8),
            selectedColor: Colors.white,
            fillColor: gameProvider.gameState.currentTheme.snakeColor,
            color: Colors.grey,
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Swipe'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Buttons'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}