import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/providers/providers.dart';
import '../../core/router/route_paths.dart';
import '../../core/services/exam_template_resolver.dart';
import '../../core/services/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/text_encoding.dart';
import '../../data/api/interceptors/error_interceptor.dart';
import '../../data/models/catalog_model.dart';
import '../../data/models/preparation_model.dart';
import 'models/onboarding_mock_data.dart';
import 'widgets/onboarding_scaffold.dart';
import 'widgets/onboarding_selection_card.dart';

class CareerPage extends ConsumerStatefulWidget {
  const CareerPage({
    super.key,
    required this.universityId,
    required this.universityName,
    required this.areaId,
    required this.areaName,
  });

  final String universityId;
  final String universityName;
  final String areaId;
  final String areaName;

  @override
  ConsumerState<CareerPage> createState() => _CareerPageState();
}

class _CareerPageState extends ConsumerState<CareerPage> {
  bool _loading = true;
  String? _errorMessage;
  List<Career> _careers = const [];
  int? _selectedId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCareers());
  }

  Future<void> _loadCareers() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    final parsedId = int.tryParse(widget.universityId);
    if (parsedId == null) {
      setState(() {
        _loading = false;
        _careers = const [];
      });
      return;
    }

    try {
      final items = await ref.read(catalogProvider).listCareers(parsedId);
      if (!mounted) return;
      setState(() {
        _careers = items;
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

  List<CareerOption> get _displayCareers {
    // Solo carreras del API (id numérico). El mock local usa ids como
    // "industrial" y rompe simulacros/diagnóstico al no existir en el servidor.
    return _careers
        .map(
          (c) => CareerOption(
            id: c.id.toString(),
            name: fixMojibake(c.name),
            areaName: fixMojibake(widget.areaName),
            iconAsset: AppAssets.iconSistemas,
            minScore: c.scoreMin ?? 0,
            maxScore: c.scoreMax ?? 100,
          ),
        )
        .toList();
  }

  String get _mascotMessage {
    final careers = _displayCareers;
    final selected = careers.where((c) => c.id == _selectedId?.toString()).firstOrNull;
    if (selected == null) return AppStrings.onboardingCareerMascotDefault;
    return AppStrings.onboardingCareerMascot(selected.name);
  }

  void _selectCareer(CareerOption career) {
    setState(() => _selectedId = int.tryParse(career.id));

    Future<void>.delayed(const Duration(milliseconds: 300), () async {
      if (!mounted) return;
      final universityId = int.tryParse(widget.universityId);
      final careerId = int.tryParse(career.id);
      if (careerId == null) {
        if (!mounted) return;
        setState(() {
          _errorMessage =
              'Carrera inválida. Elige una carrera del servidor (Sistemas o Civil).';
        });
        return;
      }
      final session = ref.read(sessionManagerProvider);
      // Guardar id primero: sin esto el simulacro/diagnóstico no resuelve plantilla.
      await session.saveCareerId(careerId);
      await session.saveStudyProfile(
            careerName: career.name,
            universityName: widget.universityName,
            universityId: universityId,
            careerId: careerId,
          );
      final examTargetCode = await session.getExamTargetCode();
      if (universityId != null) {
        var profile = await ref.read(preparationProvider).updateProfile(
              purpose: StudyPurposes.admission,
              universityId: universityId,
              careerId: careerId,
              examTargetCode: examTargetCode,
            );
        // Si la modalidad no aplica a esta universidad, reintenta sin ella.
        profile ??= await ref.read(preparationProvider).updateProfile(
              purpose: StudyPurposes.admission,
              universityId: universityId,
              careerId: careerId,
            );
        if (profile != null) {
          if (profile.careerId != null) {
            await session.saveCareerId(profile.careerId);
          }
          if (profile.universityId != null) {
            await session.saveUniversityId(profile.universityId);
          }
          await session.saveCareerTargetScore(profile.targetScore);
          await session.saveMetaTitle(profile.metaTitle);
          if (profile.admissionProcessId != null) {
            await session.saveAdmissionProcessId(profile.admissionProcessId);
          }
        } else {
          final selectedCareer = _careers.where((c) => c.id == careerId).firstOrNull;
          await session.saveCareerTargetScore(selectedCareer?.targetScore);
          await session.saveMetaTitle(
            AppStrings.inicioMetaTitleFor(widget.universityName),
          );
        }
      }
      if (careerId != null) {
        try {
          final template = await ref
              .read(examProvider)
              .getDefaultTemplateForCareer(careerId);
          await ExamTemplateResolver.remember(session, template);
        } catch (_) {
          // Se resolverá al iniciar diagnóstico con fallback.
        }
      }
      if (!mounted) return;
      final completed = await session.isDiagnosticCompleted();
      if (!mounted) return;
      if (completed) {
        context.go(RoutePaths.home);
        return;
      }
      context.push(
        RoutePaths.diagnosticPath(
          careerName: career.name,
          universityName: widget.universityName,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final careers = _displayCareers;

    return OnboardingScaffold(
      bottomWidget: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.padding,
          0,
          AppSizes.padding,
          12,
        ),
        child: MascotConfirmationBubble(
          message: _mascotMessage,
          mascotAsset: AppAssets.mascotPose3,
        ),
      ),
      body: _buildBody(careers),
    );
  }

  Widget _buildBody(List<CareerOption> careers) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
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
            title: AppStrings.onboardingCareerTitle(widget.universityName),
            subtitle: AppStrings.onboardingCareerSubtitle,
          ),
          if (widget.areaName.isNotEmpty) ...[
            const SizedBox(height: 14),
            SelectedAreaChip(areaName: widget.areaName),
          ],
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: AppTextStyles.cardSubtitle.copyWith(color: AppColors.danger),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _loadCareers,
              child: const Text(AppStrings.retryAction),
            ),
          ],
          if (careers.isEmpty && _errorMessage == null) ...[
            const SizedBox(height: 12),
            Text(
              AppStrings.onboardingCareerEmpty,
              style: AppTextStyles.cardSubtitle.copyWith(color: AppColors.danger),
            ),
            TextButton(
              onPressed: _loadCareers,
              child: const Text(AppStrings.retryAction),
            ),
          ],
          const SizedBox(height: 20),
          ...careers.map((career) {
            final isSelected = _selectedId?.toString() == career.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: OnboardingSelectionCard(
                title: career.name,
                subtitle: career.areaName,
                scoreRange: career.scoreRange,
                isSelected: isSelected,
                onTap: () => _selectCareer(career),
                leading: CareerIconAvatar(asset: career.iconAsset),
              ),
            );
          }),
          if (careers.isNotEmpty) ...[
            const SizedBox(height: 8),
            const VocationalWarningBanner(),
          ],
        ],
      ),
    );
  }
}
