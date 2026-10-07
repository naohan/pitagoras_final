import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/providers/providers.dart';
import '../../core/router/route_paths.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/preparation_model.dart';
import 'widgets/onboarding_scaffold.dart';
import 'widgets/onboarding_selection_card.dart';
import '../../widgets/topic_theory_sheet.dart';

class TopicLearningPage extends ConsumerStatefulWidget {
  const TopicLearningPage({super.key});

  @override
  ConsumerState<TopicLearningPage> createState() => _TopicLearningPageState();
}

class _TopicLearningPageState extends ConsumerState<TopicLearningPage> {
  bool _loading = true;
  String? _error;
  CurriculumCatalog _catalog = CurriculumCatalog.empty;
  final Set<String> _expandedAreas = {};
  final Set<String> _expandedCourses = {};
  int? _selectedId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  List<LearnableTopic> get _allTopics => [
        for (final area in _catalog.areas)
          for (final course in area.courses)
            for (final topic in course.topics) topic,
      ];

  String _courseKey(String areaName, String courseName) => '$areaName::$courseName';

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      var catalog = await ref.read(preparationProvider).getCurriculumCatalog();
      if (catalog.areas.isEmpty) {
        final flat = await ref.read(preparationProvider).listLearnableTopics();
        catalog = _catalogFromFlat(flat);
      }
      if (!mounted) return;
      _applyCatalog(catalog);
    } catch (_) {
      try {
        final flat = await ref.read(preparationProvider).listLearnableTopics();
        final catalog = _catalogFromFlat(flat);
        if (!mounted) return;
        _applyCatalog(
          catalog,
          errorIfEmpty: AppStrings.onboardingTopicEmpty,
        );
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _loading = false;
          _error = AppStrings.onboardingTopicLoadError;
        });
      }
    }
  }

  void _applyCatalog(CurriculumCatalog catalog, {String? errorIfEmpty}) {
    setState(() {
      _catalog = catalog;
      _expandedAreas
        ..clear()
        ..addAll(catalog.areas.map((a) => a.areaName));
      _expandedCourses.clear();
      // Abrir el primer curso de cada área para que se vea la jerarquía
      for (final area in catalog.areas) {
        if (area.courses.isNotEmpty) {
          _expandedCourses.add(_courseKey(area.areaName, area.courses.first.courseName));
        }
      }
      _selectedId = _allTopics.isEmpty ? null : _allTopics.first.subtopicId;
      _loading = false;
      _error = catalog.areas.isEmpty ? errorIfEmpty : null;
    });
  }

  CurriculumCatalog _catalogFromFlat(List<LearnableTopic> topics) {
    final areaOrder = <String>[];
    final areas = <String, Map<String, List<LearnableTopic>>>{};
    final courseOrder = <String, List<String>>{};

    for (final topic in topics) {
      final areaName = topic.areaName.isEmpty ? 'General' : topic.areaName;
      final courseName =
          topic.courseName.isEmpty ? topic.topicName : topic.courseName;
      if (!areas.containsKey(areaName)) {
        areas[areaName] = {};
        courseOrder[areaName] = [];
        areaOrder.add(areaName);
      }
      final courses = areas[areaName]!;
      if (!courses.containsKey(courseName)) {
        courses[courseName] = [];
        courseOrder[areaName]!.add(courseName);
      }
      courses[courseName]!.add(topic);
    }

    return CurriculumCatalog(
      areas: [
        for (final areaName in areaOrder)
          CurriculumArea(
            areaName: areaName,
            courses: [
              for (final courseName in courseOrder[areaName]!)
                CurriculumCourse(
                  courseId: 0,
                  courseName: courseName,
                  topics: areas[areaName]![courseName]!,
                ),
            ],
          ),
      ],
    );
  }

  Future<void> _continue() async {
    final selected =
        _allTopics.where((t) => t.subtopicId == _selectedId).firstOrNull;
    if (selected == null) return;

    final session = ref.read(sessionManagerProvider);
    await session.saveStudyPurpose(StudyPurposes.topicLearning);
    await session.saveFocusTopic(
      subtopicId: selected.subtopicId,
      subtopicName: selected.subtopicName,
      areaName: selected.areaName,
    );
    await session.saveStudyProfile(
      careerName: selected.subtopicName,
      universityName: AppStrings.curriculumOriginCneb,
    );

    final profile = await ref.read(preparationProvider).updateProfile(
          purpose: StudyPurposes.topicLearning,
          focusSubtopicId: selected.subtopicId,
        );
    if (profile?.learningTitle != null) {
      await session.saveMetaTitle(profile!.learningTitle);
    }

    if (!mounted) return;
    context.go(RoutePaths.homeTab(1));
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      showBackButton: true,
      onBack: () => context.go(RoutePaths.onboardingPurpose),
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
                  const OnboardingPageTitle(
                    title: AppStrings.onboardingTopicTitle,
                    subtitle: AppStrings.onboardingTopicSubtitle,
                  ),
                  const SizedBox(height: 16),
                  if (_error != null)
                    Text(_error!, style: AppTextStyles.cardSubtitle)
                  else if (_catalog.areas.isEmpty)
                    Text(
                      AppStrings.onboardingTopicEmpty,
                      style: AppTextStyles.cardSubtitle,
                    )
                  else
                    ..._catalog.areas.map(_buildAreaBlock),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: AppSizes.buttonHeight,
                    child: ElevatedButton(
                      onPressed: _selectedId == null ? null : _continue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        AppStrings.onboardingTopicContinue,
                        style: AppTextStyles.buttonLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildAreaBlock(CurriculumArea area) {
    final expanded = _expandedAreas.contains(area.areaName);
    final courseCount = area.courses.length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                setState(() {
                  if (expanded) {
                    _expandedAreas.remove(area.areaName);
                  } else {
                    _expandedAreas.add(area.areaName);
                  }
                });
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.chipBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _areaIcon(area.areaName),
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            area.areaName,
                            style: AppTextStyles.cardTitle.copyWith(fontSize: 16),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            AppStrings.onboardingTopicAreaCoursesOnly(courseCount),
                            style: AppTextStyles.cardSubtitle.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      expanded
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
              ),
            ),
            if (expanded) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
                child: Column(
                  children: [
                    for (final course in area.courses)
                      _buildCourseBlock(area.areaName, course),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCourseBlock(String areaName, CurriculumCourse course) {
    final key = _courseKey(areaName, course.courseName);
    final expanded = _expandedCourses.contains(key);
    final topicCount = course.topics.length;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                setState(() {
                  if (expanded) {
                    _expandedCourses.remove(key);
                  } else {
                    _expandedCourses.add(key);
                  }
                });
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.onboardingTopicCourseTitle(course.courseName),
                            style: AppTextStyles.selectionTitle.copyWith(fontSize: 14),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            AppStrings.onboardingTopicCourseMeta(topicCount),
                            style: AppTextStyles.cardSubtitle.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      expanded
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
              ),
            ),
            if (expanded) ...[
              const Divider(height: 1, color: AppColors.divider),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Column(
                  children: [
                    for (final topic in course.topics)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            OnboardingSelectionCard(
                              title: topic.subtopicName,
                              subtitle: topic.topicName.isEmpty
                                  ? topic.originLabel
                                  : '${topic.topicName}\n${AppStrings.onboardingTopicTapTheory}',
                              isSelected: _selectedId == topic.subtopicId,
                              onTap: () {
                                setState(() => _selectedId = topic.subtopicId);
                                _openTheorySheet(topic);
                              },
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _openTheorySheet(LearnableTopic topic) async {
    await showTopicTheorySheet(
      context,
      topic: topic,
      primaryLabel: AppStrings.onboardingTopicSelectTheory,
      onPrimary: () {
        setState(() => _selectedId = topic.subtopicId);
        _continue();
      },
    );
  }

  IconData _areaIcon(String areaName) {
    final lower = areaName.toLowerCase();
    if (lower.contains('matem')) return Icons.calculate_outlined;
    if (lower.contains('comunica')) return Icons.menu_book_outlined;
    if (lower.contains('ciencia') || lower.contains('tecnolog')) {
      return Icons.science_outlined;
    }
    return Icons.school_outlined;
  }
}
