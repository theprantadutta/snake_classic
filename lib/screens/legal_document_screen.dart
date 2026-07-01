import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:snake_classic/presentation/bloc/theme/theme_cubit.dart';
import 'package:snake_classic/widgets/app_background.dart';

/// Full-screen viewer for a bundled legal document (Privacy Policy or Terms of
/// Use). Loads the markdown asset and renders it scrollable. Used from the
/// Settings screen so both documents are reachable in-app.
class LegalDocumentScreen extends StatefulWidget {
  const LegalDocumentScreen({
    super.key,
    required this.title,
    required this.assetPath,
    required this.icon,
    this.fallbackUrl,
  });

  final String title;
  final String assetPath;
  final IconData icon;

  /// Shown as a hint if the bundled asset can't be loaded.
  final String? fallbackUrl;

  @override
  State<LegalDocumentScreen> createState() => _LegalDocumentScreenState();
}

class _LegalDocumentScreenState extends State<LegalDocumentScreen> {
  String _content = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final content = await rootBundle.loadString(widget.assetPath);
      if (mounted) setState(() => _content = content);
    } catch (_) {
      if (mounted) {
        setState(() => _content = widget.fallbackUrl != null
            ? 'This document is available at ${widget.fallbackUrl}.'
            : 'This document is currently unavailable. Please try again later.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeCubit>().state.currentTheme;
    final isSmall = MediaQuery.of(context).size.height < 800;

    return Scaffold(
      body: AnimatedAppBackground(
        theme: theme,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                // Header with back button
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(isSmall ? 16 : 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.accentColor.withValues(alpha: 0.2),
                        theme.accentColor.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.accentColor.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: theme.accentColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(widget.icon,
                            color: theme.accentColor, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          widget.title,
                          style: TextStyle(
                            color: theme.accentColor,
                            fontSize: isSmall ? 20 : 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(Icons.close, color: theme.accentColor),
                        tooltip: 'Close',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Document content
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          theme.backgroundColor.withValues(alpha: 0.4),
                          theme.backgroundColor.withValues(alpha: 0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.accentColor.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: _content.isEmpty
                        ? Center(
                            child: CircularProgressIndicator(
                              color: theme.accentColor,
                            ),
                          )
                        : SingleChildScrollView(
                            child: Text(
                              _content,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
