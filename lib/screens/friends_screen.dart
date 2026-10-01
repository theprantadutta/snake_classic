import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snake_classic/core/di/injection.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/l10n/catalog_l10n.dart';
import 'package:snake_classic/models/user_profile.dart';
import 'package:snake_classic/providers/friends_provider.dart';
import 'package:snake_classic/services/analytics/analytics_facade.dart';
import 'package:snake_classic/services/api_service.dart';
import 'package:snake_classic/widgets/arcade_snackbar.dart';
import 'package:snake_classic/widgets/lb/lb.dart';
import 'package:snake_classic/widgets/lb_screens/profile/lb_profile_parts.dart';

/// Friends on the Living Board: search, the friends list, requests in and
/// out, and the per-friend actions (challenge, profile, remove, block).
class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> {
  final TextEditingController _searchController = TextEditingController();

  /// 0 friends · 1 requests · 2 search.
  int _tab = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await ref.read(friendsProvider.notifier).refresh();
  }

  void _searchUsers(String query) {
    ref.read(friendsProvider.notifier).searchUsers(query);
  }

  @override
  Widget build(BuildContext context) {
    // Watch the friends state from Riverpod
    final friendsState = ref.watch(friendsProvider);
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final g = context.lbGutter;
    final cell = context.lbCell;

    return LBScaffold(
      title: l10n.lbFriends,
      subtitle: l10n.lbFriendsSubtitle,
      trailing: LBIconBlock(
        icon: LBIcon.lock,
        semanticLabel: l10n.frBlockedUsers,
        onTap: _showBlockedUsersDialog,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(g, cell * .9, g, 0),
            child: _buildSearchBar(friendsState),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: g),
            child: LBTabStrip(
              labels: [l10n.frTitle, l10n.frRequests, l10n.frSearch],
              index: _tab,
              counts: [friendsState.friends.length, friendsState.friendRequests.length, null],
              alertAt: 1,
              onChanged: (i) => setState(() => _tab = i),
            ),
          ),
          // "Updated X ago" — Drift cache freshness signal so an offline
          // view doesn't look identical to a live one.
          _buildStalenessChip(friendsState),
          Expanded(
            child: friendsState.isLoading
                ? LBLoadingCells(label: l10n.frLoadingFriends)
                : RefreshIndicator(
                    onRefresh: _loadData,
                    color: p.lime,
                    backgroundColor: p.deep,
                    child: switch (_tab) {
                      1 => _buildFriendRequestsList(friendsState),
                      2 => _buildSearchResults(friendsState),
                      _ => _buildFriendsList(friendsState),
                    },
                  ),
          ),
        ],
      ),
    );
  }

  EdgeInsets _listPadding(BuildContext context) {
    final g = context.lbGutter;
    return EdgeInsets.fromLTRB(g, context.lbCell * .3, g, context.lbCell * 1.5);
  }

  Widget _buildSearchBar(FriendsState friendsState) {
    final p = context.lb;
    final l10n = AppLocalizations.of(context)!;
    return LBBlock(
      padding: const EdgeInsetsDirectional.only(start: 14, end: 2),
      height: context.lbCell * 2.5 - LB.inset * 2,
      child: Row(
        children: [
          LBPixelIcon(LBIcon.eye, cell: 2.6, color: p.inkMuted),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              cursorColor: p.lime,
              style: LBText.body(p, color: p.ink, size: 13),
              decoration: InputDecoration(
                hintText: l10n.frSearchHint,
                hintStyle: LBText.body(p, color: p.inkDim, size: 12.5),
                border: InputBorder.none,
                isDense: true,
              ),
              onChanged: (value) {
                _searchUsers(value);
                if (value.isNotEmpty && _tab != 2) setState(() => _tab = 2);
              },
            ),
          ),
          if (friendsState.searchQuery.isNotEmpty)
            LBIconBlock(
              icon: LBIcon.x,
              size: context.lbCell * 2,
              semanticLabel: MaterialLocalizations.of(context).deleteButtonTooltip,
              onTap: () {
                _searchController.clear();
                ref.read(friendsProvider.notifier).clearSearch();
                setState(() => _tab = 0);
              },
            ),
        ],
      ),
    );
  }

  /// Inline line surfacing Drift cache freshness for the active tab.
  /// Tap → forced refresh. Hidden when the cache has never been populated
  /// AND there's no data — avoids a "Never updated" label on a first-launch
  /// offline session.
  Widget _buildStalenessChip(FriendsState state) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    DateTime? ts;
    bool hasData;
    switch (_tab) {
      case 1:
        ts = state.requestsLastRefreshedAt;
        hasData = state.friendRequests.isNotEmpty;
        break;
      case 2:
        // Search tab — no cache. The search box itself is the freshness
        // signal there.
        return SizedBox(height: context.lbCell * .3);
      case 0:
      default:
        ts = state.friendsLastRefreshedAt;
        hasData = state.friends.isNotEmpty;
    }
    if (ts == null && !hasData) return SizedBox(height: context.lbCell * .3);
    // "Updated 3h ago" alone reads as healthy — append the failure note
    // when the latest refresh attempt errored behind the cached view.
    final failed = state.refreshFailed;
    final base = ts == null ? l10n.frNoCacheYet : l10n.frUpdatedAgo(_relativeAge(l10n, ts));
    final label = failed ? l10n.frRefreshFailed(base) : base;
    final color = failed ? LB.gold : p.inkMuted;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.lbGutter),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Semantics(
          button: true,
          label: label,
          excludeSemantics: true,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              LBFeedback.tap();
              ref.read(friendsProvider.notifier).refresh();
            },
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 40),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LBPixelIcon(failed ? LBIcon.x : LBIcon.hourglass, cell: 2, color: color),
                  const SizedBox(width: 7),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: LBText.body(p, color: color, size: 10.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _relativeAge(AppLocalizations l10n, DateTime ts) {
    final diff = DateTime.now().difference(ts);
    if (diff.inSeconds < 5) return l10n.frJustNow;
    if (diff.inSeconds < 60) return l10n.frSecondsAgo(diff.inSeconds);
    if (diff.inMinutes < 60) return l10n.frMinutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return l10n.frHoursAgo(diff.inHours);
    return l10n.frDaysAgo(diff.inDays);
  }

  Widget _emptyList(LBIcon icon, String title, String subtitle) => LBCenteredScroll(
        padding: _listPadding(context),
        child: LBEmptyBlock(icon: icon, title: title, subtitle: subtitle),
      );

  Widget _buildFriendsList(FriendsState friendsState) {
    final l10n = AppLocalizations.of(context)!;
    final friends = friendsState.friends;

    if (friends.isEmpty) {
      return _emptyList(LBIcon.friends, l10n.frNoFriendsYet, l10n.frNoFriendsSub);
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: _listPadding(context),
      itemCount: friends.length,
      itemBuilder: (context, index) {
        final friend = friends[index];
        return _UserRow(
          user: friend,
          onTap: () => _showFriendActions(friend),
          trailing: LBPixelIcon(LBIcon.next, cell: 2, color: context.lb.lime),
        );
      },
    );
  }

  Widget _buildFriendRequestsList(FriendsState friendsState) {
    final l10n = AppLocalizations.of(context)!;
    final receivedRequests = friendsState.receivedRequests;
    final sentRequests = friendsState.sentRequests;

    if (receivedRequests.isEmpty && sentRequests.isEmpty) {
      return _emptyList(LBIcon.invite, l10n.frNoRequests, l10n.frNoRequestsSub);
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: _listPadding(context),
      children: [
        if (receivedRequests.isNotEmpty) ...[
          LBSectionLabel(l10n.frReceivedHeader(receivedRequests.length)),
          ...receivedRequests.map(_buildFriendRequestCard),
          SizedBox(height: context.lbCell),
        ],
        if (sentRequests.isNotEmpty) ...[
          LBSectionLabel(l10n.frSentHeader(sentRequests.length)),
          ...sentRequests.map(_buildSentRequestCard),
        ],
      ],
    );
  }

  Widget _buildSearchResults(FriendsState friendsState) {
    final l10n = AppLocalizations.of(context)!;
    final searchQuery = friendsState.searchQuery;
    final isSearching = friendsState.isSearching;
    final searchResults = friendsState.searchResults;

    if (searchQuery.isEmpty) {
      return _emptyList(LBIcon.eye, l10n.frSearchTitle, l10n.frSearchSubtitle);
    }

    if (isSearching) {
      return LBLoadingCells(label: l10n.frSearching);
    }

    if (searchResults.isEmpty) {
      return _emptyList(LBIcon.x, l10n.frNoUsersFound, l10n.frNoUsersFoundSub);
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: _listPadding(context),
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final user = searchResults[index];
        return _UserRow(
          user: user,
          trailing: _buildSearchUserActions(user),
        );
      },
    );
  }

  Widget _buildFriendRequestCard(FriendRequest request) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    return LBBlock(
      padding: const EdgeInsets.fromLTRB(10, 10, 6, 10),
      child: Row(
        children: [
          LBInitialAvatar(name: request.fromUserName, size: context.lbCell * 2.5),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.fromUserName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LBText.button(p, color: p.ink, size: 12.5),
                ),
                const SizedBox(height: 2),
                Text(l10n.frSentDate(request.formattedDate), style: LBText.body(p, size: 10.5)),
              ],
            ),
          ),
          LBIconBlock(
            icon: LBIcon.x,
            kind: LBBlockKind.danger,
            color: LB.bonk,
            semanticLabel: l10n.frReject,
            onTap: () => _rejectFriendRequest(request.fromUserId),
          ),
          LBIconBlock(
            icon: LBIcon.check,
            semanticLabel: l10n.frAccept,
            onTap: () => _acceptFriendRequest(request.fromUserId),
          ),
        ],
      ),
    );
  }

  Widget _buildSentRequestCard(FriendRequest request) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    return LBBlock(
      kind: LBBlockKind.muted,
      padding: const EdgeInsets.fromLTRB(10, 10, 6, 10),
      child: Row(
        children: [
          LBInitialAvatar(name: request.toUserName, size: context.lbCell * 2.5, dim: true),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.toUserName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LBText.button(p, color: p.inkMuted, size: 12.5),
                ),
                const SizedBox(height: 2),
                Text(l10n.frSentDate(request.formattedDate), style: LBText.body(p, color: p.inkDim, size: 10.5)),
              ],
            ),
          ),
          LBChip(label: l10n.frPending.toUpperCase(), kind: LBChipKind.gold),
          // Withdraw the request — the sender's counterpart to the
          // recipient's reject button.
          LBIconBlock(
            icon: LBIcon.x,
            kind: LBBlockKind.muted,
            color: p.inkMuted,
            semanticLabel: l10n.frCancelRequest,
            onTap: () => _cancelSentRequest(request.toUserId),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchUserActions(UserProfile user) {
    final l10n = AppLocalizations.of(context)!;
    // Check if already friends or have pending request using provider helper methods
    final notifier = ref.read(friendsProvider.notifier);
    final isFriend = notifier.isFriend(user.uid);
    final hasSentRequest = notifier.hasSentRequestTo(user.uid);
    final hasReceivedRequest = notifier.hasReceivedRequestFrom(user.uid);

    if (isFriend) {
      return LBChip(label: l10n.frAlreadyFriends.toUpperCase());
    }

    if (hasSentRequest) {
      return LBChip(label: l10n.frPending.toUpperCase(), kind: LBChipKind.gold);
    }

    if (hasReceivedRequest) {
      return _SmallAction(
        label: l10n.frAccept,
        icon: LBIcon.check,
        onTap: () => _acceptFriendRequest(user.uid),
      );
    }

    return _SmallAction(
      label: l10n.frAddFriend,
      icon: LBIcon.plus,
      onTap: () => _sendFriendRequest(user.uid),
    );
  }

  /// Failure feedback for friend mutations. Previously failures were
  /// SILENT (snackbar only on success) — a guest with no backend JWT, or
  /// any network error, tapped the button and nothing happened at all.
  void _showMutationError(String failureMessage) {
    if (!mounted) return;
    final signedIn = ApiService().isAuthenticated;
    ScaffoldMessenger.of(context).showSnackBar(
      arcadeSnackBar(
        context,
        message: signedIn ? failureMessage : AppLocalizations.of(context)!.frSignInSocial,
        tone: ArcadeSnackTone.error,
      ),
    );
  }

  Future<void> _sendFriendRequest(String userId) async {
    final l10n = AppLocalizations.of(context)!;
    final success = await ref.read(friendsProvider.notifier).sendFriendRequest(userId);
    if (!mounted) return;
    if (success) {
      getIt<AnalyticsFacade>().trackFriendAdded();
      ScaffoldMessenger.of(context).showSnackBar(arcadeSnackBar(context, message: l10n.frRequestSent));
    } else {
      _showMutationError(l10n.frSendRequestFailed);
    }
  }

  Future<void> _acceptFriendRequest(String fromUserId) async {
    final l10n = AppLocalizations.of(context)!;
    final success = await ref.read(friendsProvider.notifier).acceptFriendRequest(fromUserId);
    if (!mounted) return;
    if (success) {
      getIt<AnalyticsFacade>().trackFriendAdded();
      ScaffoldMessenger.of(context).showSnackBar(arcadeSnackBar(context, message: l10n.frRequestAccepted));
    } else {
      _showMutationError(l10n.frAcceptFailed);
    }
  }

  Future<void> _rejectFriendRequest(String fromUserId) async {
    final l10n = AppLocalizations.of(context)!;
    final success = await ref.read(friendsProvider.notifier).rejectFriendRequest(fromUserId);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(arcadeSnackBar(context, message: l10n.frRequestRejected));
    } else {
      _showMutationError(l10n.frRejectFailed);
    }
  }

  /// The per-friend menu (was a popup menu): challenge, profile, remove,
  /// block — the same four actions, as a sheet.
  void _showFriendActions(UserProfile friend) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    showLBSheet<void>(
      context: context,
      title: friend.publicLabel,
      builder: (sheetContext) {
        void run(String action) {
          Navigator.of(sheetContext).pop();
          _handleFriendAction(action, friend);
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LBRow(
                title: l10n.frChallengeMenu,
                leading: LBPixelIcon(LBIcon.swords, cell: 3, color: p.lime),
                onTap: () => run('ping_match'),
              ),
              LBRow(
                title: l10n.frViewProfile,
                leading: LBPixelIcon(LBIcon.user, cell: 3, color: p.lime),
                onTap: () => run('view_profile'),
              ),
              LBRow(
                title: l10n.frRemoveFriend,
                kind: LBBlockKind.danger,
                leading: const LBPixelIcon(LBIcon.x, cell: 3, color: LB.bonk),
                onTap: () => run('remove_friend'),
              ),
              LBRow(
                title: l10n.frBlockUser,
                kind: LBBlockKind.danger,
                leading: const LBPixelIcon(LBIcon.lock, cell: 3, color: LB.bonk),
                onTap: () => run('block'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleFriendAction(String action, UserProfile friend) {
    switch (action) {
      case 'ping_match':
        _pingFriendForMatch(friend);
        break;
      case 'view_profile':
        _showUserProfile(friend);
        break;
      case 'remove_friend':
        _showRemoveFriendDialog(friend);
        break;
      case 'block':
        _showBlockUserDialog(friend);
        break;
    }
  }

  Future<void> _cancelSentRequest(String toUserId) async {
    final l10n = AppLocalizations.of(context)!;
    final success = await ref.read(friendsProvider.notifier).cancelSentRequest(toUserId);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(arcadeSnackBar(context, message: l10n.frRequestCancelled));
    } else {
      _showMutationError(l10n.frCancelFailed);
    }
  }

  /// "Wanna play?" ping — the server enforces a 10-minute per-friend
  /// cooldown and returns the reason when refusing, which we surface
  /// verbatim so the user knows when to retry.
  Future<void> _pingFriendForMatch(UserProfile friend) async {
    final l10n = AppLocalizations.of(context)!;
    final (sent, message) = await ref.read(friendsProvider.notifier).pingFriendForMatch(friend.uid);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      arcadeSnackBar(
        context,
        message: sent ? l10n.frChallengeSent(friend.displayName) : (message ?? l10n.frChallengeFailed),
        tone: sent ? ArcadeSnackTone.success : ArcadeSnackTone.error,
      ),
    );
  }

  Future<void> _showBlockUserDialog(UserProfile friend) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showLBDialog<bool>(
      context: context,
      title: l10n.frBlockTitle(friend.displayName),
      body: l10n.frBlockBody,
      primaryLabel: l10n.frBlock,
      primaryKind: LBBlockKind.danger,
      onPrimary: () => Navigator.of(context, rootNavigator: true).pop(true),
      secondaryLabel: l10n.commonCancel,
      onSecondary: () => Navigator.of(context, rootNavigator: true).pop(false),
    );
    if (confirmed != true || !mounted) return;
    final success = await ref.read(friendsProvider.notifier).blockUser(friend.uid);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        arcadeSnackBar(context, message: l10n.frBlocked(friend.displayName)),
      );
    } else {
      _showMutationError(l10n.frBlockFailed);
    }
  }

  /// Blocked-users manager — live-fetched list with per-row unblock.
  Future<void> _showBlockedUsersDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final blocked = await ref.read(friendsProvider.notifier).getBlockedUsers();
    if (!mounted) return;
    final p = context.lb;
    showLBSheet<void>(
      context: context,
      title: l10n.frBlockedUsers,
      builder: (sheetContext) => SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (blocked.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(l10n.frNoBlocked, style: LBText.body(p, size: 12)),
              )
            else
              for (final user in blocked)
                LBRow(
                  title: user.displayName,
                  leading: LBInitialAvatar(name: user.displayName, size: context.lbCell * 2, dim: true),
                  trailing: _SmallAction(
                    label: l10n.frUnblock,
                    icon: LBIcon.lock,
                    onTap: () async {
                      Navigator.of(sheetContext).pop();
                      final ok = await ref.read(friendsProvider.notifier).unblockUser(user.uid);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        arcadeSnackBar(
                          context,
                          message: ok ? l10n.frUnblocked(user.displayName) : l10n.frUnblockFailed,
                        ),
                      );
                    },
                  ),
                ),
            const SizedBox(height: 8),
            LBBlock(
              kind: LBBlockKind.muted,
              height: 46,
              alignment: Alignment.center,
              onTap: () => Navigator.of(sheetContext).pop(),
              child: Text(l10n.commonClose.toUpperCase(), style: LBText.button(p, color: p.inkMuted, size: 12)),
            ),
          ],
        ),
      ),
    );
  }

  void _showUserProfile(UserProfile friend) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    Widget line(String text) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(text, style: LBText.body(p, color: p.ink.withValues(alpha: .85), size: 12.5)),
        );
    showLBSheet<void>(
      context: context,
      title: friend.username,
      builder: (sheetContext) => SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            line(l10n.frHighScoreLine(friend.highScore)),
            line(l10n.frTotalGamesLine(friend.totalGamesPlayed)),
            line(l10n.frLevelLine(friend.level)),
            if (friend.statusMessage?.isNotEmpty == true)
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 8),
                child: Text(
                  l10n.frStatusLine(friend.statusMessage!),
                  style: LBText.body(p, size: 12).copyWith(fontStyle: FontStyle.italic),
                ),
              ),
            const SizedBox(height: 8),
            LBBlock(
              kind: LBBlockKind.muted,
              height: 46,
              alignment: Alignment.center,
              onTap: () => Navigator.of(sheetContext).pop(),
              child: Text(l10n.commonClose.toUpperCase(), style: LBText.button(p, color: p.inkMuted, size: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showRemoveFriendDialog(UserProfile friend) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showLBDialog<bool>(
      context: context,
      title: l10n.frRemoveFriend,
      body: l10n.frRemoveBody(friend.displayName),
      primaryLabel: l10n.frRemove,
      primaryKind: LBBlockKind.danger,
      onPrimary: () => Navigator.of(context, rootNavigator: true).pop(true),
      secondaryLabel: l10n.commonCancel,
      onSecondary: () => Navigator.of(context, rootNavigator: true).pop(false),
    );
    if (confirmed != true || !mounted) return;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final success = await ref.read(friendsProvider.notifier).removeFriend(friend.uid);
    if (success) {
      getIt<AnalyticsFacade>().trackFriendRemoved();
    }
    if (success && mounted) {
      scaffoldMessenger.showSnackBar(
        arcadeSnackBar(context, message: l10n.frRemoved(friend.displayName)),
      );
    }
  }
}

/// A player row: initial avatar, name, presence, best score and games.
class _UserRow extends StatelessWidget {
  const _UserRow({required this.user, this.trailing, this.onTap});

  final UserProfile user;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final here = user.status != UserStatus.offline;
    final status = user.status.localizedName(l10n);
    return LBBlock(
      onTap: onTap,
      semanticLabel: onTap == null ? null : '${user.publicLabel}, $status',
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Row(
        children: [
          LBInitialAvatar(name: user.publicLabel, size: context.lbCell * 2.5, dim: !here),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.publicLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LBText.button(p, color: p.ink, size: 12.5),
                ),
                const SizedBox(height: 3),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  runSpacing: 2,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox.square(
                          dimension: 7,
                          child: CustomPaint(painter: _Dot(here ? p.lime : p.cellOff)),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          status.toUpperCase(),
                          style: LBText.label(p, color: here ? p.lime : p.inkDim).copyWith(fontSize: 8.5),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const LBPixelIcon(LBIcon.trophy, cell: 1.8, color: LB.gold),
                        const SizedBox(width: 5),
                        Text(
                          context.formatInt(user.highScore),
                          style: LBText.body(p, color: LB.gold, size: 10.5).copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    Text(
                      l10n.frGamesCount(user.totalGamesPlayed),
                      style: LBText.body(p, size: 10.5),
                    ),
                  ],
                ),
                if (user.statusMessage != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    user.statusMessage!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: LBText.body(p, color: p.inkDim, size: 10.5).copyWith(fontStyle: FontStyle.italic),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );
  }
}

/// A compact labelled action (ADD FRIEND, ACCEPT, UNBLOCK).
class _SmallAction extends StatelessWidget {
  const _SmallAction({required this.label, required this.icon, required this.onTap});

  final String label;
  final LBIcon icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    return LBBlock(
      selected: true,
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      alignment: Alignment.center,
      semanticLabel: label,
      onTap: onTap,
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            LBPixelIcon(icon, cell: 2, color: p.lime),
            const SizedBox(width: 7),
            Text(label.toUpperCase(), style: LBText.button(p, size: 10.5)),
          ],
        ),
      ),
    );
  }
}

class _Dot extends CustomPainter {
  _Dot(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRRect(lbCellRect(0, 0, size.width), Paint()..color = color);
  }

  @override
  bool shouldRepaint(_Dot old) => old.color != color;
}
