import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:snake_classic/presentation/bloc/theme/theme_cubit.dart';
import 'package:snake_classic/presentation/bloc/premium/premium_cubit.dart';
import 'package:snake_classic/services/purchase_service.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/game_animations.dart';
import 'package:snake_classic/widgets/app_background.dart';

class ThemeSelectorScreen extends StatelessWidget {
  const ThemeSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeState = context.watch<ThemeCubit>().state;
    final premiumState = context.watch<PremiumCubit>().state;
    final currentTheme = themeState.currentTheme;

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
          icon: Icon(Icons.arrow_back, color: currentTheme.primaryColor),
          onPressed: () => context.pop(),
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
                ).gameEntrance(),

                const SizedBox(height: 8),

                Text(
                      'Select a theme that matches your mood',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    )
                    .gameEntrance(delay: 100.ms),

                const SizedBox(height: 30),

                // Theme Grid
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.85,
                        ),
                    itemCount: GameTheme.values.length,
                    itemBuilder: (context, index) {
                      final theme = GameTheme.values[index];
                      final isSelected = themeState.currentTheme == theme;

                      return _buildThemeCard(
                        context,
                        theme,
                        isSelected,
                        themeState,
                        premiumState,
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
    ThemeState themeState,
    PremiumState premiumState,
    int index,
  ) {
    final isLocked = !premiumState.isThemeUnlocked(theme);
    final isPremiumTheme = PremiumContent.premiumThemes.contains(theme);

    return GestureDetector(
          onTap: () async {
            if (isLocked) {
              _showPremiumThemeDialog(context, theme, premiumState);
            } else {
              context.read<ThemeCubit>().setTheme(theme);
            }
          },
          child: Stack(
            children: [
              Container(
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
                        : isLocked
                        ? Colors.orange.withValues(alpha: 0.6)
                        : theme.primaryColor.withValues(alpha: 0.3),
                    width: isSelected
                        ? 3
                        : isLocked
                        ? 2
                        : 1,
                  ),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: theme.accentColor.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    if (isLocked)
                      BoxShadow(
                        color: Colors.orange.withValues(alpha: 0.2),
                        blurRadius: 15,
                        spreadRadius: 1,
                      ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Theme Name and Premium Badge
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  theme.name,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isLocked
                                        ? Colors.white.withValues(alpha: 0.6)
                                        : theme.accentColor,
                                  ),
                                ),
                                if (isPremiumTheme) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFFFD700),
                                          Color(0xFFFFA500),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'PRO',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          if (isSelected && !isLocked)
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
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: theme.backgroundColor.withValues(
                                  alpha: 0.5,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: theme.primaryColor.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                              child: _buildMiniGamePreview(theme),
                            ),
                            if (isLocked)
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.lock,
                                    color: Colors.orange,
                                    size: 32,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Theme Description or Price
                      if (isLocked)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getThemePrice(theme),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        )
                      else
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
                          _buildColorDot(
                            theme.snakeColor,
                            'Snake',
                            isLocked: isLocked,
                          ),
                          _buildColorDot(
                            theme.foodColor,
                            'Food',
                            isLocked: isLocked,
                          ),
                          _buildColorDot(
                            theme.accentColor,
                            'UI',
                            isLocked: isLocked,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Premium Badge Overlay
              if (isPremiumTheme && !isLocked)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.star,
                      color: Colors.black,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
        )
        .gameGridItem(index);
  }

  Widget _buildMiniGamePreview(GameTheme theme) {
    return CustomPaint(
      painter: MiniGamePainter(theme),
      child: const SizedBox.expand(),
    );
  }

  Widget _buildColorDot(Color color, String label, {bool isLocked = false}) {
    return Column(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: isLocked ? color.withValues(alpha: 0.4) : color,
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
            color: Colors.white.withValues(alpha: isLocked ? 0.4 : 0.6),
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
      case GameTheme.cyberpunk:
        return 'Digital matrix with electric cyan and hot pink';
      case GameTheme.forest:
        return 'Natural greens with organic leaf patterns';
      case GameTheme.desert:
        return 'Warm sand tones with desert wind effects';
      case GameTheme.crystal:
        return 'Prismatic purples with crystalline light rays';
    }
  }

  String _getThemePrice(GameTheme theme) {
    switch (theme) {
      case GameTheme.crystal:
      case GameTheme.cyberpunk:
      case GameTheme.space:
      case GameTheme.ocean:
      case GameTheme.desert:
      case GameTheme.forest:
        return '\$1.99';
      default:
        return 'FREE';
    }
  }

  void _showPremiumThemeDialog(
    BuildContext context,
    GameTheme theme,
    PremiumState premiumState,
  ) {
    final themePrice = _getThemePrice(theme);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black.withValues(alpha: 0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: theme.accentColor.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          title: Row(
            children: [
              Icon(Icons.lock, color: Colors.orange, size: 24),
              const SizedBox(width: 8),
              Text(
                'Premium Theme',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Theme preview
              Container(
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.backgroundColor,
                      theme.backgroundColor.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.accentColor.withValues(alpha: 0.3),
                  ),
                ),
                child: _buildMiniGamePreview(theme),
              ),

              const SizedBox(height: 16),

              Text(
                theme.name,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.accentColor,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                _getThemeDescription(theme),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 16),

              // Purchase options
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange.withValues(alpha: 0.1),
                      Colors.amber.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Purchase Options',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Individual theme purchase
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Individual Theme',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Unlock just ${theme.name}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          themePrice,
                          style: TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Bundle purchase
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.green.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Premium Themes Bundle',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'BEST VALUE',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'All 5 premium themes + future releases',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$7.99',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Save \$2.00',
                                style: TextStyle(
                                  color: Colors.green.withValues(alpha: 0.8),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Pro subscription option
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.diamond,
                                    color: Colors.black,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Snake Classic Pro',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'All themes + premium features',
                                style: TextStyle(
                                  color: Colors.black.withValues(alpha: 0.8),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '\$4.99/mo',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
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
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                context.pop();
                _handleThemePurchase(context, theme, 'individual');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: Text('Buy Theme - $themePrice'),
            ),
            ElevatedButton(
              onPressed: () {
                context.pop();
                _handleThemePurchase(context, theme, 'bundle');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: Text('Buy Bundle - \$7.99'),
            ),
          ],
        );
      },
    );
  }

  void _handleThemePurchase(
    BuildContext context,
    GameTheme theme,
    String purchaseType,
  ) {
    final purchaseService = PurchaseService();

    String productId;
    switch (purchaseType) {
      case 'individual':
        switch (theme) {
          case GameTheme.crystal:
            productId = ProductIds.crystalTheme;
            break;
          case GameTheme.cyberpunk:
            productId = ProductIds.cyberpunkTheme;
            break;
          case GameTheme.space:
            productId = ProductIds.spaceTheme;
            break;
          case GameTheme.ocean:
            productId = ProductIds.oceanTheme;
            break;
          case GameTheme.desert:
            productId = ProductIds.desertTheme;
            break;
          case GameTheme.forest:
            productId = ProductIds.forestTheme;
            break;
          default:
            return;
        }
        break;
      case 'bundle':
        productId = ProductIds.themesBundle;
        break;
      default:
        return;
    }

    final product = purchaseService.getProduct(productId);
    if (product != null) {
      purchaseService.buyProduct(product);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Initiating purchase for ${theme.name}...'),
          backgroundColor: theme.accentColor,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product not available. Please try again later.'),
          backgroundColor: Colors.red,
        ),
      );
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
