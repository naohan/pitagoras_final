import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/providers/providers.dart';
import '../../core/router/route_paths.dart';
import '../../core/services/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/api/interceptors/error_interceptor.dart';
import '../../data/models/catalog_model.dart';
import 'models/onboarding_mock_data.dart';
import 'widgets/onboarding_scaffold.dart';
import 'widgets/onboarding_selection_card.dart';

class AreaPage extends ConsumerStatefulWidget {
  const AreaPage({
    super.key,
    required this.universityId,
    required this.universityName,
  });

  final String universityId;
  final String universityName;

  @override
  ConsumerState<AreaPage> createState() => _AreaPageState();
}

class _AreaPageState extends ConsumerState<AreaPage> {
  bool _loading = true;
  String? _errorMessage;
  List<AreaOption> _areas = const [];
  final Map<String, int> _admissionProcessByAreaId = {};
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAreas());
  }

  Future<void> _loadAreas() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final items = await ref.read(catalogProvider).listAreas();
      if (!mounted) return;

      if (items.isNotEmpty) {
        _admissionProcessByAreaId
          ..clear()
          ..addEntries(
            items.map((a) => MapEntry(a.id.toString(), a.admissionProcessId)),
          );
      }

      final options = items.isNotEmpty
          ? items.map(_areaToOption).toList()
          : OnboardingMockData.areas;

      setState(() {
        _areas = options;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _areas = OnboardingMockData.areas;
        _loading = false;
        _errorMessage = _resolveError(error);
      });
    }
  }

  AreaOption _areaToOption(AcademicArea area) {
    return AreaOption(
      id: area.id.toString(),
      title: area.name,
      description: AppStrings.onboardingAreaFromBackend(area.name),
      iconAsset: _iconForArea(area.name),
    );
  }

  String _iconForArea(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('matem') || lower.contains('ingenier')) {
      return AppAssets.iconIngenieria;
    }
    if (lower.contains('bio') || lower.contains('medic')) {
      return AppAssets.iconMedicina;
    }
    if (lower.contains('social') || lower.contains('human')) {
      return AppAssets.iconSociales;
    }
    return AppAssets.iconTopics;
  }

  String _resolveError(Object error) {
    final apiException = readApiException(error);
    if (apiException != null) return apiException.message;
    if (error is ApiException) return error.message;
    return AppStrings.simulacroLoadError;
  }

  void _selectArea(AreaOption area) {
    setState(() => _selectedId = area.id);

    Future<void>.delayed(const Duration(milliseconds: 250), () async {
      if (!mounted) return;

      final admissionProcessId = _admissionProcessByAreaId[area.id];
      if (admissionProcessId != null) {
        await ref
            .read(sessionManagerProvider)
            .saveAdmissionProcessId(admissionProcessId);
      }

      if (!mounted) return;
      context.push(
        RoutePaths.onboardingCareerPath(
          universityId: widget.universityId,
          universityName: widget.universityName,
          areaId: area.id,
          areaName: area.title,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

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
          OnboardingPageTitle(
            title: AppStrings.onboardingAreaTitle(widget.universityName),
            subtitle: AppStrings.onboardingAreaSubtitle,
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: AppTextStyles.cardSubtitle.copyWith(color: AppColors.danger),
            ),
          ],
          const SizedBox(height: 20),
          ..._areas.map((area) {
            final isSelected = _selectedId == area.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: OnboardingSelectionCard(
                title: area.title,
                subtitle: area.description,
                isSelected: isSelected,
                onTap: () => _selectArea(area),
                leading: AreaIconAvatar(asset: area.iconAsset),
              ),
            );
          }),
          const SizedBox(height: 8),
          const VocationalWarningBanner(),
          const SizedBox(height: 20),
          Center(
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(
                Icons.open_in_new_rounded,
                size: 18,
                color: AppColors.primary,
              ),
              label: Text(
                AppStrings.onboardingNotSureYet,
                style: AppTextStyles.linkAction,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
