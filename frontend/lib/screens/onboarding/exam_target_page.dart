import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/models/unsa_exam_target.dart';
import '../../core/providers/providers.dart';
import '../../core/router/route_paths.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/preparation_model.dart';
import 'widgets/onboarding_scaffold.dart';
import 'widgets/onboarding_selection_card.dart';

class ExamTargetPage extends ConsumerStatefulWidget {
  const ExamTargetPage({
    super.key,
    required this.universityId,
    required this.universityName,
  });

  final String universityId;
  final String universityName;

  @override
  ConsumerState<ExamTargetPage> createState() => _ExamTargetPageState();
}

class _ExamTargetPageState extends ConsumerState<ExamTargetPage> {
  bool _loading = true;
  List<AdmissionExamTarget> _targets = const [];
  String? _selectedCode;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final universityId = int.tryParse(widget.universityId);
    final saved = await ref.read(sessionManagerProvider).getUnsaExamTarget();

    List<AdmissionExamTarget> targets = const [];
    if (universityId != null) {
      try {
        targets = await ref.read(preparationProvider).listExamTargets(universityId);
      } catch (_) {
        targets = const [];
      }
    }

    if (targets.isEmpty &&
        UnsaExamTarget.isUnsaUniversity(widget.universityName)) {
      targets = UnsaExamTarget.values
          .map(
            (t) => AdmissionExamTarget(
              id: t.index,
              universityId: universityId ?? 0,
              code: t.storageKey,
              label: t.label,
              shortLabel: t.shortLabel,
              description: t.description,
              simulacroFocus: t.simulacroFocus,
              displayOrder: t.index,
            ),
          )
          .toList();
    }

    if (!mounted) return;
    setState(() {
      _targets = targets;
      _selectedCode = saved?.storageKey ??
          (targets.isNotEmpty ? targets.first.code : null);
      _loading = false;
    });
  }

  Future<void> _continue() async {
    final code = _selectedCode;
    if (code == null) return;

    final legacy = UnsaExamTarget.fromStorage(code);
    if (legacy != null) {
      await ref.read(sessionManagerProvider).saveUnsaExamTarget(legacy);
    }
    await ref.read(sessionManagerProvider).saveExamTargetCode(code);

    if (!mounted) return;
    context.push(
      RoutePaths.onboardingCareerPath(
        universityId: widget.universityId,
        universityName: widget.universityName,
        areaId: '0',
        areaName: '',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      showBackButton: true,
      onBack: () => context.pop(),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.padding,
                8,
                AppSizes.padding,
                AppSizes.padding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OnboardingPageTitle(
                    title: AppStrings.onboardingExamTargetTitle(widget.universityName),
                    subtitle: AppStrings.onboardingExamTargetSubtitle,
                  ),
                  const SizedBox(height: 20),
                  if (_targets.isEmpty)
                    Text(
                      AppStrings.onboardingExamTargetEmpty,
                      style: AppTextStyles.cardSubtitle,
                    )
                  else
                    ..._targets.map((target) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: OnboardingSelectionCard(
                          title: target.label,
                          subtitle: target.description,
                          isSelected: _selectedCode == target.code,
                          onTap: () => setState(() => _selectedCode = target.code),
                          leading: _ExamTargetIcon(code: target.code),
                        ),
                      );
                    }),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.onboardingExamTargetNote,
                    style: AppTextStyles.cardSubtitle.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: AppSizes.buttonHeight,
                    child: ElevatedButton(
                      onPressed: _selectedCode == null || _targets.isEmpty
                          ? null
                          : _continue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        AppStrings.onboardingExamTargetContinue,
                        style: AppTextStyles.buttonLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _ExamTargetIcon extends StatelessWidget {
  const _ExamTargetIcon({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    final IconData icon = switch (code) {
      'quinto' => Icons.school_outlined,
      'cepreunsa' || 'cepre' => Icons.menu_book_outlined,
      _ => Icons.emoji_events_outlined,
    };
    return CircleAvatar(
      backgroundColor: AppColors.chipBg,
      child: Icon(icon, color: AppColors.primary, size: 22),
    );
  }
}
