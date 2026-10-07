import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/providers/providers.dart';
import '../../core/models/unsa_exam_target.dart';
import '../../core/router/route_paths.dart';
import '../../core/services/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/api/interceptors/error_interceptor.dart';
import '../../data/models/catalog_model.dart';
import 'models/onboarding_mock_data.dart';
import 'widgets/onboarding_scaffold.dart';
import 'widgets/onboarding_selection_card.dart';

class UniversityPage extends ConsumerStatefulWidget {
  const UniversityPage({super.key});

  @override
  ConsumerState<UniversityPage> createState() => _UniversityPageState();
}

class _UniversityPageState extends ConsumerState<UniversityPage> {
  bool _loading = true;
  String? _errorMessage;
  List<University> _universities = const [];
  int? _selectedId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadUniversities());
  }

  Future<void> _loadUniversities() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final items = await ref.read(catalogProvider).listUniversities();
      if (!mounted) return;
      setState(() {
        _universities = items;
        _selectedId = items.isNotEmpty ? items.first.id : null;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = _resolveError(error);
      });
    }
  }

  String _resolveError(Object error) {
    final apiException = readApiException(error);
    if (apiException != null) return apiException.message;
    if (error is ApiException) return error.message;
    return AppStrings.simulacroLoadError;
  }

  void _selectUniversity(University university) {
    setState(() => _selectedId = university.id);

    Future<void>.delayed(const Duration(milliseconds: 250), () async {
      if (!mounted) return;
      final id = university.id.toString();

      var hasTargets = UnsaExamTarget.isUnsaUniversity(
        university.name,
        code: university.code,
      );
      try {
        final targets =
            await ref.read(preparationProvider).listExamTargets(university.id);
        hasTargets = targets.isNotEmpty;
      } catch (_) {
        // Fallback: solo UNSA usa la pantalla de modalidad local.
      }

      if (!mounted) return;
      if (hasTargets) {
        context.push(
          RoutePaths.onboardingExamTargetPath(
            universityId: id,
            universityName: university.name,
          ),
        );
        return;
      }
      context.push(
        RoutePaths.onboardingCareerPath(
          universityId: id,
          universityName: university.name,
          areaId: '0',
          areaName: '',
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      showBackButton: true,
      onBack: () => context.go(RoutePaths.login),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!, style: AppTextStyles.welcome, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: _loadUniversities, child: const Text(AppStrings.retry)),
          ],
        ),
      );
    }

    if (_universities.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.padding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppStrings.onboardingNoUniversities,
                style: AppTextStyles.welcome,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: _loadUniversities,
                child: const Text(AppStrings.retry),
              ),
            ],
          ),
        ),
      );
    }

    return _UniversityList(
      universities: _universities
          .map(
            (u) => UniversityOption(
              id: u.id.toString(),
              acronym: u.code,
              fullName: u.name,
              logoAsset: _logoForCode(u.code),
              initials: u.code.length <= 4 ? u.code : u.code.substring(0, 3),
            ),
          )
          .toList(),
      selectedId: _selectedId?.toString(),
      onSelect: (item) {
        final university = _universities.firstWhere((u) => u.id.toString() == item.id);
        _selectUniversity(university);
      },
    );
  }

  String? _logoForCode(String code) {
    switch (code.toUpperCase()) {
      case 'UNSA':
        return AppAssets.logoUnsa;
      case 'UCSM':
        return AppAssets.logoCato;
      default:
        return null;
    }
  }
}

class _UniversityList extends StatelessWidget {
  const _UniversityList({
    required this.universities,
    required this.selectedId,
    required this.onSelect,
  });

  final List<UniversityOption> universities;
  final String? selectedId;
  final ValueChanged<UniversityOption> onSelect;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.padding,
        8,
        AppSizes.padding,
        AppSizes.padding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const OnboardingPageTitle(title: AppStrings.onboardingUniversityTitle),
          const SizedBox(height: 20),
          const LocationSelector(),
          const SizedBox(height: 20),
          ...universities.map((university) {
            final isSelected = selectedId == university.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: OnboardingSelectionCard(
                title: university.acronym,
                subtitle: university.fullName,
                isSelected: isSelected,
                onTap: () => onSelect(university),
                leading: UniversityLogoAvatar(
                  logoAsset: university.logoAsset,
                  initials: university.initials,
                  initialsColor: university.initialsColor,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
