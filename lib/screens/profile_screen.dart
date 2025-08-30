import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snake_classic/providers/user_provider.dart';
import 'package:snake_classic/providers/theme_provider.dart';
import 'package:snake_classic/widgets/gradient_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: themeProvider.currentTheme.primaryColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              themeProvider.currentTheme.backgroundColor,
              themeProvider.currentTheme.backgroundColor.withValues(alpha:0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: userProvider.isSignedIn 
              ? _buildProfileContent(context, userProvider, themeProvider)
              : _buildSignInContent(context, userProvider, themeProvider),
          ),
        ),
      ),
    );
  }

  Widget _buildSignInContent(
    BuildContext context, 
    UserProvider userProvider, 
    ThemeProvider themeProvider,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.person_outline,
          size: 100,
          color: themeProvider.currentTheme.primaryColor.withValues(alpha:0.7),
        ),
        const SizedBox(height: 30),
        
        const Text(
          'Sign in to save your progress',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        
        Text(
          'Track your high scores, unlock achievements,\nand compete with players worldwide!',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withValues(alpha:0.8),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        
        if (userProvider.isLoading)
          const CircularProgressIndicator()
        else ...[
          GradientButton(
            text: 'Sign in with Google',
            icon: Icons.login,
            primaryColor: themeProvider.currentTheme.accentColor,
            secondaryColor: themeProvider.currentTheme.primaryColor,
            onPressed: () async {
              final success = await userProvider.signInWithGoogle();
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Successfully signed in!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to sign in. Please try again.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 15),
          
          GradientButton(
            text: 'Continue as Guest',
            icon: Icons.person,
            primaryColor: themeProvider.currentTheme.primaryColor,
            secondaryColor: themeProvider.currentTheme.accentColor,
            onPressed: () async {
              await userProvider.signInAnonymously();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Signed in as guest'),
                    backgroundColor: Colors.blue,
                  ),
                );
              }
            },
          ),
        ],
      ],
    );
  }

  Widget _buildProfileContent(
    BuildContext context, 
    UserProvider userProvider, 
    ThemeProvider themeProvider,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Profile Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: themeProvider.currentTheme.primaryColor.withValues(alpha:0.2),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: themeProvider.currentTheme.primaryColor.withValues(alpha:0.3),
              ),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: userProvider.photoURL != null 
                    ? NetworkImage(userProvider.photoURL!)
                    : null,
                  backgroundColor: themeProvider.currentTheme.primaryColor,
                  child: userProvider.photoURL == null
                    ? Icon(
                        Icons.person,
                        size: 50,
                        color: themeProvider.currentTheme.backgroundColor,
                      )
                    : null,
                ),
                const SizedBox(height: 15),
                
                Text(
                  userProvider.displayName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (userProvider.isAnonymous)
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha:0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withValues(alpha:0.5)),
                    ),
                    child: const Text(
                      'Guest Account',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          
          // Stats Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: themeProvider.currentTheme.primaryColor.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: themeProvider.currentTheme.primaryColor.withValues(alpha:0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Statistics',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 15),
                
                _buildStatItem(
                  'High Score',
                  userProvider.highScore.toString(),
                  Icons.emoji_events,
                  themeProvider,
                ),
                _buildStatItem(
                  'Games Played',
                  userProvider.totalGamesPlayed.toString(),
                  Icons.games,
                  themeProvider,
                ),
                _buildStatItem(
                  'Total Score',
                  userProvider.totalScore.toString(),
                  Icons.star,
                  themeProvider,
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          
          // Sign Out Button
          if (!userProvider.isLoading)
            GradientButton(
              text: 'Sign Out',
              icon: Icons.logout,
              primaryColor: Colors.red,
              secondaryColor: Colors.red.withValues(alpha: 0.8),
              onPressed: () async {
                await userProvider.signOut();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Signed out successfully'),
                      backgroundColor: Colors.blue,
                    ),
                  );
                }
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    ThemeProvider themeProvider,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: themeProvider.currentTheme.primaryColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha:0.8),
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}