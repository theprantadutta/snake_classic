import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/services/app_release_policy.dart';
import 'package:snake_classic/services/app_release_service.dart';
import 'package:snake_classic/utils/logger.dart';

/// Tell an iOS player there is a newer build on the App Store.
///
/// Two shapes from one widget, because the two cases differ only in whether
/// there is a way out:
///
///   [UpdatePrompt.optional]  title, body, Later + Update. Dismissible by
///                            barrier or back; declining snoozes 24h.
///   [UpdatePrompt.required]  no Later, no barrier dismiss, and a PopScope
///                            that refuses the system back gesture. The
///                            build has been declared unfit to keep using,
///                            so the dialog is the whole app until it is
///                            resolved.
///
/// The required case does NOT force-quit or block the game loop; it just
/// cannot be dismissed. If the store link fails to open, the player is told
/// and the dialog stays — which is a dead end by design, but an honest one,
/// and it is reachable only when an operator has deliberately raised the
/// floor above the running build.
Future<void> showAppUpdateDialog(
  BuildContext context,
  UpdatePrompt prompt,
) async {
  if (prompt == UpdatePrompt.none) return;

  final service = AppReleaseService();
  final storeUrl = service.storeUrl;
  // Nothing to send them to — saying "update" with no way to do it is worse
  // than saying nothing.
  if (storeUrl == null) return;

  final blocking = prompt == UpdatePrompt.required;
  final l10n = AppLocalizations.of(context)!;

  await showDialog<void>(
    context: context,
    barrierDismissible: !blocking,
    builder: (dialogContext) => PopScope(
      canPop: !blocking,
      child: AlertDialog(
        backgroundColor: const Color(0xFF1A1A1F),
        title: Text(
          blocking ? l10n.updateRequiredTitle : l10n.updateAvailableTitle,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          blocking
              ? l10n.updateRequiredBody
              : l10n.updateAvailableBody(service.latestVersion ?? ''),
          style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
        ),
        actions: [
          if (!blocking)
            TextButton(
              onPressed: () {
                // Record the refusal before closing so the snooze is
                // written even if the frame after this is the last one.
                service.recordDeclined();
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                l10n.updateActionLater,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
              ),
            ),
          FilledButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.maybeOf(dialogContext);
              final opened = await _openStore(storeUrl);
              if (!opened) {
                messenger?.showSnackBar(
                  SnackBar(content: Text(l10n.updateOpenStoreFailed)),
                );
                return;
              }
              // Close only the dismissible one. The blocking dialog stays
              // up behind the App Store so that returning without having
              // updated does not silently drop the player into a build we
              // have already said is unfit.
              if (!blocking && dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }
            },
            child: Text(l10n.updateActionUpdate),
          ),
        ],
      ),
    ),
  );
}

Future<bool> _openStore(String url) async {
  try {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (e, stackTrace) {
    AppLogger.error('Could not open the App Store', e, stackTrace);
    return false;
  }
}
