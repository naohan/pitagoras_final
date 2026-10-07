import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_strings.dart';
import '../../core/router/route_paths.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/motivator_fab.dart';
import 'session_profile_mixin.dart';

class RankingTab extends ConsumerStatefulWidget {
  const RankingTab({super.key});

  @override
  ConsumerState<RankingTab> createState() => _RankingTabState();
}

class _RankingTabState extends ConsumerState<RankingTab> with SessionProfileMixin {
  static const _mockEntries = [
    _RankingEntry(rank: 1, name: 'María L.', points: 2840, isCurrentUser: false),
    _RankingEntry(rank: 2, name: 'Carlos R.', points: 2710, isCurrentUser: false),
    _RankingEntry(rank: 3, name: 'Ana P.', points: 2655, isCurrentUser: false),
    _RankingEntry(rank: 4, name: 'Diego M.', points: 2480, isCurrentUser: false),
    _RankingEntry(rank: 5, name: 'Lucía V.', points: 2390, isCurrentUser: false),
    _RankingEntry(rank: 12, name: 'Tú', points: 1980, isCurrentUser: true),
  ];

  @override
  Widget build(BuildContext context) {
    final displayName = userName?.trim();
    final currentUserName =
        displayName != null && displayName.isNotEmpty ? displayName : 'Tú';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          profileLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _RankingHeader(),
                        const SizedBox(height: 6),
                        Text(
                          AppStrings.rankingTabTitle,
                          style: AppTextStyles.greeting.copyWith(fontSize: 24),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppStrings.rankingTabSubtitle,
                          style: AppTextStyles.cardSubtitle.copyWith(fontSize: 13),
                        ),
                        const SizedBox(height: 16),
                        _YourRankCard(
                          rank: 12,
                          points: 1980,
                          userName: currentUserName,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const Icon(Icons.workspace_premium_rounded,
                                color: Color(0xFF7C3AED), size: 20),
                            const SizedBox(width: 6),
                            Text(
                              AppStrings.rankingTabLeaderboard,
                              style: AppTextStyles.cardTitle.copyWith(fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ..._mockEntries.map(
                          (entry) => _RankingRow(
                            entry: entry.name == 'Tú'
                                ? entry.copyWith(name: currentUserName)
                                : entry,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.chipBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.bar_chart_rounded,
                                  color: AppColors.primary.withValues(alpha: 0.8), size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  AppStrings.rankingTabDemoNote,
                                  style: AppTextStyles.cardSubtitle.copyWith(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          Positioned(
            right: 16,
            bottom: 16,
            child: MotivatorFab(
              onTap: () => context.push(RoutePaths.motivator),
            ),
          ),
        ],
      ),
    );
  }
}

class _RankingHeader extends StatelessWidget {
  const _RankingHeader();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Text(
          AppStrings.rankingTabTitle,
          style: AppTextStyles.cardTitle.copyWith(fontSize: 16),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.info_outline_rounded, color: AppColors.textMuted, size: 20),
            visualDensity: VisualDensity.compact,
          ),
        ),
      ],
    );
  }
}

class _RankingEntry {
  const _RankingEntry({
    required this.rank,
    required this.name,
    required this.points,
    required this.isCurrentUser,
  });

  final int rank;
  final String name;
  final int points;
  final bool isCurrentUser;

  _RankingEntry copyWith({String? name}) => _RankingEntry(
        rank: rank,
        name: name ?? this.name,
        points: points,
        isCurrentUser: isCurrentUser,
      );
}

class _YourRankCard extends StatelessWidget {
  const _YourRankCard({
    required this.rank,
    required this.points,
    required this.userName,
  });

  final int rank;
  final int points;
  final String userName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF60A5FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(10),
            child: Image.asset(AppAssets.iconTrophy),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    AppStrings.rankingTabYourPosition(rank),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  AppStrings.rankingTabEncouragement,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.92),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AppStrings.rankingTabPointsLabel,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.85),
                  letterSpacing: 0.5,
                  height: 1.0,
                ),
              ),
              Text(
                '$points',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RankingRow extends StatelessWidget {
  const _RankingRow({required this.entry});

  final _RankingEntry entry;

  String get _initials {
    final parts = entry.name.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final bg = entry.isCurrentUser ? AppColors.chipBg : Colors.white;
    final borderColor = entry.isCurrentUser ? AppColors.primary : AppColors.border;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: entry.isCurrentUser ? 1.5 : 1),
        boxShadow: entry.isCurrentUser
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        children: [
          _RankBadge(rank: entry.rank),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 18,
            backgroundColor: entry.isCurrentUser
                ? AppColors.primary.withValues(alpha: 0.15)
                : AppColors.diagnosticCardBg,
            child: Text(
              _initials,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: entry.isCurrentUser ? AppColors.primary : AppColors.navy,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              entry.name,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: entry.isCurrentUser ? FontWeight.w700 : FontWeight.w500,
                color: AppColors.navy,
                height: 1.1,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(AppAssets.iconFire, width: 16, height: 16),
              const SizedBox(width: 4),
              Text(
                '${entry.points}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.navy,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.rank});

  final int rank;

  @override
  Widget build(BuildContext context) {
    if (rank == 1) {
      return _MedalBadge(
        rank: rank,
        gradient: const [Color(0xFFFDE68A), Color(0xFFF59E0B)],
        borderColor: const Color(0xFFD97706),
        textColor: const Color(0xFF92400E),
      );
    }
    if (rank == 2) {
      return _MedalBadge(
        rank: rank,
        gradient: const [Color(0xFFE5E7EB), Color(0xFF9CA3AF)],
        borderColor: const Color(0xFF6B7280),
        textColor: const Color(0xFF374151),
      );
    }
    if (rank == 3) {
      return _MedalBadge(
        rank: rank,
        gradient: const [Color(0xFFFED7AA), Color(0xFFEA580C)],
        borderColor: const Color(0xFFC2410C),
        textColor: const Color(0xFF7C2D12),
      );
    }

    return SizedBox(
      width: 28,
      child: Text(
        '$rank',
        textAlign: TextAlign.center,
        style: AppTextStyles.cardSubtitle.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}

class _MedalBadge extends StatelessWidget {
  const _MedalBadge({
    required this.rank,
    required this.gradient,
    required this.borderColor,
    required this.textColor,
  });

  final int rank;
  final List<Color> gradient;
  final Color borderColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient, begin: Alignment.topCenter, end: Alignment.bottomCenter),
        shape: BoxShape.circle,
        border: Border.all(color: borderColor),
      ),
      child: Text(
        '$rank',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: textColor,
          height: 1.0,
        ),
      ),
    );
  }
}
