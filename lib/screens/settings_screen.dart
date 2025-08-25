import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          return Container(
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
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Game Settings',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // Theme selector
                  _buildThemeSelector(gameProvider),
                  const SizedBox(height: 20),
                  
                  // Control type selector
                  _buildControlTypeSelector(gameProvider),
                  const SizedBox(height: 20),
                  
                  // Difficulty selector
                  _buildDifficultySelector(gameProvider),
                  const SizedBox(height: 20),
                  
                  // Sound toggle
                  _buildSoundToggle(gameProvider),
                  const SizedBox(height: 20),
                  
                  // High score display
                  _buildHighScoreDisplay(gameProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildThemeSelector(GameProvider gameProvider) {
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

  Widget _buildControlTypeSelector(GameProvider gameProvider) {
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

  Widget _buildDifficultySelector(GameProvider gameProvider) {
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
            'Difficulty',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            children: Difficulty.values.map((difficulty) {
              return ChoiceChip(
                label: Text(
                  difficulty.name,
                  style: TextStyle(
                    color: gameProvider.gameState.difficulty == difficulty 
                        ? Colors.white 
                        : Colors.grey,
                  ),
                ),
                selected: gameProvider.gameState.difficulty == difficulty,
                selectedColor: gameProvider.gameState.currentTheme.snakeColor,
                backgroundColor: Colors.transparent,
                onSelected: (selected) {
                  if (selected) {
                    gameProvider.changeDifficulty(difficulty);
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          const Text(
            'Higher difficulty means faster snake movement.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoundToggle(GameProvider gameProvider) {
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
            'Sound',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          SwitchListTile(
            title: const Text(
              'Enable Sound Effects',
              style: TextStyle(color: Colors.white),
            ),
            value: gameProvider.soundEnabled,
            onChanged: (bool value) {
              gameProvider.toggleSound();
            },
            activeThumbColor: gameProvider.gameState.currentTheme.snakeColor,
          ),
        ],
      ),
    );
  }

  Widget _buildHighScoreDisplay(GameProvider gameProvider) {
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
            'High Score',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            gameProvider.gameState.highScore.toString(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.yellow,
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              // In a real implementation, we might have a reset high score feature
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.withValues(alpha: 0.7),
            ),
            child: const Text('Reset High Score'),
          ),
        ],
      ),
    );
  }
}