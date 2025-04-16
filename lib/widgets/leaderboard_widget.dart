import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../utils/app_logger.dart';
import '../services/friends_manager.dart';
import 'add_friend_dialog.dart';

enum LeaderboardType { allTime, daily }

class LeaderboardEntry {
  final String userId;
  final String displayName;
  final int score;
  final int? level;
  final bool isCurrentUser;

  LeaderboardEntry({
    required this.userId,
    required this.displayName,
    required this.score,
    this.level,
    this.isCurrentUser = false,
  });
}

class LeaderboardWidget extends StatefulWidget {
  const LeaderboardWidget({super.key});

  @override
  State<LeaderboardWidget> createState() => _LeaderboardWidgetState();
}

class _LeaderboardWidgetState extends State<LeaderboardWidget> {
  List<LeaderboardEntry> _leaderboard = [];
  bool _isLoading = true;
  String? _errorMessage;
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;
  LeaderboardType _leaderboardType = LeaderboardType.allTime;

  @override
  void initState() {
    super.initState();
    if (_currentUserId != null) {
      _fetchLeaderboardData();
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = "User not logged in.";
      });
    }
  }

  Future<void> _fetchLeaderboardData() async {
    if (_currentUserId == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_leaderboardType == LeaderboardType.allTime) {
        await _fetchAllTimeLeaderboard();
      } else {
        await _fetchDailyLeaderboard();
      }
    } catch (e, stacktrace) {
      AppLogger.e("Error fetching leaderboard data",
          error: e, stackTrace: stacktrace);
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Failed to load leaderboard.";
        });
      }
    }
  }

  Future<void> _fetchAllTimeLeaderboard() async {
    final firestore = FirebaseFirestore.instance;
    final currentUserDoc =
        await firestore.collection('users').doc(_currentUserId).get();

    if (!currentUserDoc.exists) {
      throw Exception("Current user data not found.");
    }

    final currentUserData = currentUserDoc.data() ?? {};
    final currentUsername = currentUserData['username'] ?? 'You';
    final currentUserXp = currentUserData['currentXP'] ?? 0;
    final currentUserLevel =
        await FriendsManager.calculateLevelFromXP(currentUserXp);

    List<LeaderboardEntry> leaderboard = [
      LeaderboardEntry(
        userId: _currentUserId!,
        displayName: currentUsername,
        score: currentUserXp,
        level: currentUserLevel,
        isCurrentUser: true,
      ),
    ];

    // Get friends info using FriendsManager
    final friendsInfo = await FriendsManager.getAllFriendsInfo();
    for (var friend in friendsInfo) {
      leaderboard.add(LeaderboardEntry(
        userId: friend['uid'],
        displayName: friend['username'],
        score: friend['currentXP'],
        level: friend['level'],
      ));
    }

    leaderboard.sort((a, b) => b.score.compareTo(a.score));

    if (mounted) {
      setState(() {
        _leaderboard = leaderboard;
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchDailyLeaderboard() async {
    final firestore = FirebaseFirestore.instance;
    final currentUserDoc =
        await firestore.collection('users').doc(_currentUserId).get();

    if (!currentUserDoc.exists) {
      throw Exception("Current user data not found.");
    }

    final currentUserData = currentUserDoc.data() ?? {};
    final currentUsername = currentUserData['username'] ?? 'You';

    int currentUserCompletedToday =
        await FriendsManager.getFriendDailyActivity(_currentUserId!);

    List<LeaderboardEntry> leaderboard = [
      LeaderboardEntry(
        userId: _currentUserId!,
        displayName: currentUsername,
        score: currentUserCompletedToday,
        isCurrentUser: true,
      ),
    ];

    // Get friends info using FriendsManager
    final friendsInfo = await FriendsManager.getAllFriendsInfo();
    for (var friend in friendsInfo) {
      final friendCompletedToday =
          await FriendsManager.getFriendDailyActivity(friend['uid']);
      leaderboard.add(LeaderboardEntry(
        userId: friend['uid'],
        displayName: friend['username'],
        score: friendCompletedToday,
      ));
    }

    leaderboard.sort((a, b) => b.score.compareTo(a.score));

    if (mounted) {
      setState(() {
        _leaderboard = leaderboard;
        _isLoading = false;
      });
    }
  }

  void _toggleLeaderboardType(LeaderboardType type) {
    if (_leaderboardType != type) {
      setState(() {
        _leaderboardType = type;
      });
      _fetchLeaderboardData();
    }
  }

  void _showAddFriendDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddFriendDialog(),
    ).then((_) {
      // Refresh the leaderboard after the dialog is closed
      _fetchLeaderboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final Color secondaryColor = Theme.of(context).colorScheme.secondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
              left: 4.0, right: 4.0, bottom: 8.0, top: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const SizedBox(width: 6),
                  Text(
                    'Friend Leaderboard',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  // Add Friend Button
                  IconButton(
                    icon: const Icon(Icons.person_add_rounded),
                    onPressed: _showAddFriendDialog,
                    tooltip: "Add Friend",
                  ),
                  // Dropdown for leaderboard type
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          primaryColor.withOpacity(0.1),
                          primaryColor.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<LeaderboardType>(
                        value: _leaderboardType,
                        icon: Container(
                          padding: const EdgeInsets.only(left: 4),
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: primaryColor,
                            size: 20,
                          ),
                        ),
                        elevation: 4,
                        isDense: true,
                        borderRadius: BorderRadius.circular(12),
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                        onChanged: (LeaderboardType? newValue) {
                          if (newValue != null) {
                            _toggleLeaderboardType(newValue);
                          }
                        },
                        items: [
                          DropdownMenuItem<LeaderboardType>(
                            value: LeaderboardType.allTime,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.whatshot_outlined,
                                  size: 16,
                                  color: primaryColor,
                                ),
                                const SizedBox(width: 6),
                                const Text('All-Time XP'),
                              ],
                            ),
                          ),
                          DropdownMenuItem<LeaderboardType>(
                            value: LeaderboardType.daily,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.today_outlined,
                                  size: 16,
                                  color: primaryColor,
                                ),
                                const SizedBox(width: 6),
                                const Text('Today\'s Activity'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          constraints: const BoxConstraints(maxHeight: 180),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: _buildContent(context),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_isLoading) {
      return const Center(
          child: Padding(
        padding: EdgeInsets.all(16.0),
        child: CircularProgressIndicator(),
      ));
    }

    if (_errorMessage != null) {
      return Center(
          child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(_errorMessage!),
      ));
    }

    if (_leaderboard.isEmpty ||
        (_leaderboard.length == 1 &&
            _leaderboard[0].isCurrentUser &&
            _leaderboard[0].score == 0)) {
      return Center(
          child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _leaderboardType == LeaderboardType.allTime
                  ? Icons.group_add_rounded
                  : Icons.calendar_today_rounded,
              size: 36,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            Text(
              _leaderboardType == LeaderboardType.allTime
                  ? "Add friends to see the leaderboard!"
                  : "No activity today yet!",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ));
    }

    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 4),
      physics: const BouncingScrollPhysics(),
      itemCount: _leaderboard.length,
      separatorBuilder: (context, index) => Divider(
        height: 0.5,
        thickness: 0.5,
        indent: 50,
        endIndent: 16,
        color: Colors.grey.shade200,
      ),
      itemBuilder: (context, index) {
        final entry = _leaderboard[index];
        final rank = index + 1;
        final highlightColor = Theme.of(context).colorScheme.primaryContainer;

        Color? medalColor;
        IconData? medalIcon;
        if (rank == 1) {
          medalColor = const Color(0xFFFFD700); // Gold
          medalIcon = Icons.workspace_premium;
        } else if (rank == 2) {
          medalColor = const Color(0xFFC0C0C0); // Silver
          medalIcon = Icons.workspace_premium;
        } else if (rank == 3) {
          medalColor = const Color(0xFFCD7F32); // Bronze
          medalIcon = Icons.workspace_premium;
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
          decoration: BoxDecoration(
            color: entry.isCurrentUser
                ? highlightColor.withOpacity(0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            dense: true,
            visualDensity: VisualDensity.compact,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2),
            leading: Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 15,
                  backgroundColor: medalColor != null
                      ? medalColor.withOpacity(0.2)
                      : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  child: medalIcon != null
                      ? Icon(medalIcon, color: medalColor, size: 14)
                      : Text(
                          '$rank',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 10,
                          ),
                        ),
                ),
                if (entry.isCurrentUser)
                  Positioned.fill(
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: Colors.transparent,
                      child: CircularProgressIndicator(
                        value: 1,
                        strokeWidth: 1.5,
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.3),
                      ),
                    ),
                  ),
              ],
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(
                    entry.displayName,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: entry.isCurrentUser || rank <= 3
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: entry.isCurrentUser
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                if (_leaderboardType == LeaderboardType.allTime &&
                    entry.level != null)
                  Container(
                    margin: const EdgeInsets.only(left: 10),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.deepPurple,
                          size: 11,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          'Level ${entry.level}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                const Spacer(),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: rank <= 3
                    ? medalColor?.withOpacity(0.1)
                    : Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              ),
              child: _leaderboardType == LeaderboardType.allTime
                  ? _buildXPScore(entry.score)
                  : _buildDailyScore(entry, context),
            ),
          ),
        );
      },
    );
  }

  // Widget to display just XP value (not level)
  Widget _buildXPScore(int score) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$score',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontSize: 14,
          ),
        ),
        Text(
          ' XP',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  // Widget to display daily score
  Widget _buildDailyScore(LeaderboardEntry entry, BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${entry.score}',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontSize: 14,
          ),
        ),
        Text(
          ' Subtopics',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}
