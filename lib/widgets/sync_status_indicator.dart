import 'package:flutter/material.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/services/connectivity_service.dart';
import 'package:get_it/get_it.dart';
import 'package:snake_classic/services/data_sync_service.dart';
import 'package:snake_classic/services/sync/sync_engine.dart';
import 'package:snake_classic/services/sync/sync_status.dart';

/// A subtle sync status indicator widget that shows connectivity and sync state.
///
/// Designed to be minimal and non-intrusive - a small icon in the corner.
/// States:
/// - Online + synced: Small green dot (barely visible)
/// - Online + syncing: Small spinning sync icon
/// - Online + pending: Small cloud with number badge
/// - Offline: Small gray cloud icon
class SyncStatusIndicator extends StatefulWidget {
  final double size;
  final Color? onlineColor;
  final Color? offlineColor;
  final Color? syncingColor;
  final Color? pendingColor;

  const SyncStatusIndicator({
    super.key,
    this.size = 18,
    this.onlineColor,
    this.offlineColor,
    this.syncingColor,
    this.pendingColor,
  });

  @override
  State<SyncStatusIndicator> createState() => _SyncStatusIndicatorState();
}

class _SyncStatusIndicatorState extends State<SyncStatusIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _spinController;
  final ConnectivityService _connectivityService = ConnectivityService();
  final SyncEngine _syncEngine = GetIt.I<SyncEngine>();

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Reads the CANONICAL engine, not the legacy transport.
    //
    // This used to render DataSyncService, which by now owns little beyond
    // FCM token registration — so it could show a contented "all synced"
    // while the real outbox held pending scores and a dead-lettered
    // submission the player was never told about.
    return StreamBuilder<SyncStatusSnapshot>(
      initialData: _syncEngine.status,
      stream: _syncEngine.statusStream,
      builder: (context, statusSnapshot) {
        return ListenableBuilder(
          listenable: _connectivityService,
          builder: (context, child) {
            return _buildIndicator(
              context,
              statusSnapshot.data ?? const SyncStatusSnapshot(),
            );
          },
        );
      },
    );
  }

  Widget _buildIndicator(BuildContext context, SyncStatusSnapshot status) {
    final isOnline = _connectivityService.isOnline;
    final syncStatus = status.isDraining ? SyncStatus.syncing : SyncStatus.idle;

    // Pending includes the legacy FCM queue so nothing is invisible, but the
    // two are counted separately in the snapshot so the legacy queue can be
    // retired without changing what this means.
    final pendingCount = status.pendingCount + status.legacyPendingCount;

    // Dead letters are permanent rejections — the server will never take
    // them without intervention. They matter more than a transient backlog,
    // which is why they drive the warning state.
    final failedCount = status.deadLetterCount;

    // Update spin animation
    if (syncStatus == SyncStatus.syncing) {
      _spinController.repeat();
    } else {
      _spinController.stop();
    }

    // Determine icon and color
    IconData icon;
    Color color;
    Widget? badge;

    if (!isOnline) {
      // Offline
      icon = Icons.cloud_off_outlined;
      color = widget.offlineColor ?? Colors.grey.shade500;
    } else if (syncStatus == SyncStatus.syncing) {
      // Syncing
      icon = Icons.sync;
      color = widget.syncingColor ?? Colors.blue.shade400;
    } else if (failedCount > 0) {
      // Has failures
      icon = Icons.cloud_off;
      color = Colors.orange.shade400;
      badge = _buildBadge(failedCount, Colors.orange);
    } else if (pendingCount > 0) {
      // Has pending items
      icon = Icons.cloud_upload_outlined;
      color = widget.pendingColor ?? Colors.blue.shade300;
      badge = _buildBadge(pendingCount, Colors.blue);
    } else {
      // Online and synced
      icon = Icons.cloud_done_outlined;
      color =
          widget.onlineColor ?? Colors.green.shade400.withValues(alpha: 0.7);
    }

    return Tooltip(
      message: _getTooltipMessage(
        AppLocalizations.of(context)!,
        isOnline,
        syncStatus,
        pendingCount,
        failedCount,
      ),
      child: SizedBox(
        width: widget.size + 8,
        height: widget.size + 8,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (syncStatus == SyncStatus.syncing)
              RotationTransition(
                turns: _spinController,
                child: Icon(icon, size: widget.size, color: color),
              )
            else
              Icon(icon, size: widget.size, color: color),
            if (badge != null) Positioned(top: 0, right: 0, child: badge),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      constraints: const BoxConstraints(minWidth: 12, minHeight: 12),
      child: Text(
        count > 9 ? '9+' : count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  String _getTooltipMessage(
    AppLocalizations l10n,
    bool isOnline,
    SyncStatus status,
    int pendingCount,
    int failedCount,
  ) {
    if (!isOnline) {
      return l10n.ssiOfflinePending;
    }

    switch (status) {
      case SyncStatus.syncing:
        return l10n.ssiSyncing;
      case SyncStatus.synced:
        return l10n.ssiAllSynced;
      case SyncStatus.error:
        return l10n.ssiFailedCount(failedCount);
      case SyncStatus.idle:
        return l10n.ssiPendingCount(pendingCount);
      case SyncStatus.offline:
        return l10n.ssiOffline;
    }
  }
}
