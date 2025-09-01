import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:snake_classic/providers/theme_provider.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/app_background.dart';

class ThemeSelectorScreen extends StatelessWidget {
  const ThemeSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentTheme = themeProvider.currentTheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Visual Themes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: currentTheme.primaryColor,
            shadows: [
              Shadow(
                offset: const Offset(0, 2),
                blurRadius: 4,
                color: Colors.black.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: currentTheme.primaryColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: AppBackground(
        theme: currentTheme,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose your style',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: currentTheme.accentColor,
                  ),
                ).animate().fadeIn().slideX(begin: -0.3, duration: 500.ms),
                
                const SizedBox(height: 8),
                
                Text(
                  'Select a theme that matches your mood',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.3, duration: 500.ms),
                
                const SizedBox(height: 30),
                
                // Theme Grid
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: GameTheme.values.length,
                    itemBuilder: (context, index) {
                      final theme = GameTheme.values[index];
                      final isSelected = themeProvider.currentTheme == theme;
                      
                      return _buildThemeCard(
                        context,
                        theme,
                        isSelected,
                        themeProvider,
                        index,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeCard(
    BuildContext context,
    GameTheme theme,
    bool isSelected,
    ThemeProvider themeProvider,
    int index,
  ) {
    return GestureDetector(
      onTap: () {
        themeProvider.setTheme(theme);
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.backgroundColor,
              theme.backgroundColor.withValues(alpha: 0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
              ? theme.accentColor 
              : theme.primaryColor.withValues(alpha: 0.3),
            width: isSelected ? 3 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: theme.accentColor.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Theme Name
              Row(
                children: [
                  Expanded(
                    child: Text(
                      theme.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.accentColor,
                      ),
                    ),
                  ),
                  
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: theme.accentColor,
                      size: 24,
                    ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Theme Preview - Mini Game Board
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.backgroundColor.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.primaryColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: _buildMiniGamePreview(theme),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Theme Description
              Text(
                _getThemeDescription(theme),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              
              // Color Palette
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildColorDot(theme.snakeColor, 'Snake'),
                  _buildColorDot(theme.foodColor, 'Food'),
                  _buildColorDot(theme.accentColor, 'UI'),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate(delay: (index * 100).ms)
     .fadeIn(duration: 500.ms)
     .scale(begin: const Offset(0.8, 0.8), duration: 500.ms, curve: Curves.elasticOut);
  }

  Widget _buildMiniGamePreview(GameTheme theme) {
    return CustomPaint(
      painter: MiniGamePainter(theme),
      child: const SizedBox.expand(),
    );
  }

  Widget _buildColorDot(Color color, String label) {
    return Column(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  String _getThemeDescription(GameTheme theme) {
    switch (theme) {
      case GameTheme.classic:
        return 'Retro green monochrome inspired by the original Snake';
      case GameTheme.modern:
        return 'Clean and contemporary with cool blue tones';
      case GameTheme.neon:
        return 'Electric cyberpunk vibes with glowing colors';
      case GameTheme.retro:
        return 'Warm earth tones with vintage gaming feel';
      case GameTheme.space:
        return 'Cosmic purple hues for interstellar adventures';
      case GameTheme.ocean:
        return 'Deep sea blues with coral accents';
    }
  }
}

class MiniGamePainter extends CustomPainter {
  final GameTheme theme;

  MiniGamePainter(this.theme);

  @override
  void paint(Canvas canvas, Size size) {
    const gridSize = 6;
    final cellSize = size.width / gridSize;

    // Draw grid background (subtle)
    final gridPaint = Paint()
      ..color = theme.primaryColor.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (int i = 0; i <= gridSize; i++) {
      // Vertical lines
      canvas.drawLine(
        Offset(i * cellSize, 0),
        Offset(i * cellSize, size.height),
        gridPaint,
      );
      // Horizontal lines
      canvas.drawLine(
        Offset(0, i * cellSize),
        Offset(size.width, i * cellSize),
        gridPaint,
      );
    }

    // Draw snake (simplified)
    final snakePaint = Paint()
      ..color = theme.snakeColor
      ..style = PaintingStyle.fill;

    // Snake body positions (simple L-shape)
    final snakePositions = [
      Offset(2 * cellSize + cellSize * 0.1, 3 * cellSize + cellSize * 0.1),
      Offset(3 * cellSize + cellSize * 0.1, 3 * cellSize + cellSize * 0.1),
      Offset(4 * cellSize + cellSize * 0.1, 3 * cellSize + cellSize * 0.1),
      Offset(4 * cellSize + cellSize * 0.1, 2 * cellSize + cellSize * 0.1),
    ];

    for (int i = 0; i < snakePositions.length; i++) {
      final rect = Rect.fromLTWH(
        snakePositions[i].dx,
        snakePositions[i].dy,
        cellSize * 0.8,
        cellSize * 0.8,
      );
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(cellSize * 0.1)),
        snakePaint,
      );
    }

    // Draw food
    final foodPaint = Paint()
      ..color = theme.foodColor
      ..style = PaintingStyle.fill;

    final foodRect = Rect.fromLTWH(
      1 * cellSize + cellSize * 0.1,
      1 * cellSize + cellSize * 0.1,
      cellSize * 0.8,
      cellSize * 0.8,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(foodRect, Radius.circular(cellSize * 0.2)),
      foodPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}