import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/app_config.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/providers/providers.dart';
import '../../core/router/route_paths.dart';
import '../../core/services/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/api/interceptors/error_interceptor.dart';
import '../../data/models/rag_model.dart';
import '../../data/models/study_activity_model.dart';

class StudyMaterialPage extends ConsumerStatefulWidget {
  const StudyMaterialPage({super.key});

  @override
  ConsumerState<StudyMaterialPage> createState() => _StudyMaterialPageState();
}

class _StudyMaterialPageState extends ConsumerState<StudyMaterialPage> {
  final _titleController = TextEditingController();
  final _subtopicController = TextEditingController();
  final _pasteController = TextEditingController();

  PlatformFile? _selectedFile;
  RagStats? _stats;
  RagIngestResult? _lastUpload;
  RagContext? _suggestedContext;
  bool _loadingStats = true;
  bool _uploading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStats();
      _loadSuggestedSubtopic();
    });
  }

  Future<void> _loadSuggestedSubtopic() async {
    final careerId = await ref.read(sessionManagerProvider).getCareerId();
    final context = await ref.read(studyMaterialProvider).getContextForCareer(careerId);
    if (!mounted || context?.subtopicId == null) return;
    setState(() {
      _suggestedContext = context;
      _subtopicController.text = context!.subtopicId.toString();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtopicController.dispose();
    _pasteController.dispose();
    super.dispose();
  }

  int? _parseSubtopicId() {
    final subtopicRaw = _subtopicController.text.trim();
    if (subtopicRaw.isEmpty) return null;
    return int.tryParse(subtopicRaw);
  }

  Future<void> _loadStats() async {
    setState(() {
      _loadingStats = true;
      _errorMessage = null;
    });

    try {
      final stats = await ref.read(studyMaterialProvider).getStats();
      if (!mounted) return;
      setState(() {
        _stats = stats;
        _loadingStats = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadingStats = false;
        _errorMessage = _resolveErrorMessage(error);
      });
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'txt', 'md'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.single;
    if (file.bytes == null && file.path == null) {
      setState(() => _errorMessage = AppStrings.studyMaterialPickError);
      return;
    }

    setState(() {
      _selectedFile = file;
      _lastUpload = null;
      _errorMessage = null;
      if (_titleController.text.trim().isEmpty) {
        _titleController.text = file.name;
      }
    });
  }

  Future<void> _upload() async {
    final file = _selectedFile;
    if (file == null) {
      setState(() => _errorMessage = AppStrings.studyMaterialNoFile);
      return;
    }

    final subtopicId = _parseSubtopicId();
    if (_subtopicController.text.trim().isNotEmpty && subtopicId == null) {
      setState(() => _errorMessage = AppStrings.studyMaterialInvalidSubtopic);
      return;
    }

    MultipartFile multipart;
    try {
      final bytes = file.bytes;
      if (bytes != null && bytes.isNotEmpty) {
        multipart = MultipartFile.fromBytes(
          bytes,
          filename: file.name,
        );
      } else if (!kIsWeb && file.path != null) {
        multipart = await MultipartFile.fromFile(
          file.path!,
          filename: file.name,
        );
      } else {
        setState(() => _errorMessage = AppStrings.studyMaterialPickError);
        return;
      }
    } catch (_) {
      setState(() => _errorMessage = AppStrings.studyMaterialPickError);
      return;
    }

    await _runUpload(() => ref.read(studyMaterialProvider).uploadFile(
          file: multipart,
          subtopicId: subtopicId,
          title: _titleController.text.trim().isEmpty
              ? null
              : _titleController.text.trim(),
        ));
  }

  Future<void> _uploadPastedText() async {
    final text = _pasteController.text.trim();
    if (text.isEmpty) {
      setState(() => _errorMessage = AppStrings.studyMaterialPasteHint);
      return;
    }

    final subtopicId = _parseSubtopicId();
    if (_subtopicController.text.trim().isNotEmpty && subtopicId == null) {
      setState(() => _errorMessage = AppStrings.studyMaterialInvalidSubtopic);
      return;
    }

    await _runUpload(() => ref.read(studyMaterialProvider).uploadText(
          text: text,
          subtopicId: subtopicId,
          title: _titleController.text.trim().isEmpty
              ? 'Texto manual'
              : _titleController.text.trim(),
        ));
  }

  Future<void> _runUpload(Future<RagIngestResult> Function() upload) async {
    setState(() {
      _uploading = true;
      _errorMessage = null;
    });

    try {
      final result = await upload();
      if (!mounted) return;
      setState(() {
        _uploading = false;
        _lastUpload = result;
        _selectedFile = null;
      });
      await ref.read(studyActivityProvider).recordActivity(
            StudyActivityTypes.material,
            refId: result.source,
          );
      await _loadStats();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _uploading = false;
        _errorMessage = _resolveErrorMessage(error);
      });
    }
  }

  String _resolveErrorMessage(Object error) {
    final apiException = readApiException(error);
    if (apiException != null) {
      if (apiException.code == 'timeout') {
        return AppStrings.studyMaterialUploadTimeout;
      }
      if (apiException.code == 'connection_error') {
        return 'Sin conexión con el backend en ${AppConfig.apiBaseUrl}. '
            'Verifica que uvicorn esté activo en el puerto 8000.';
      }
      return apiException.message;
    }
    if (error is ApiException) return error.message;
    if (error is DioException) {
      return error.message ?? error.toString();
    }
    final text = error.toString();
    if (text.isNotEmpty && text != 'null') return text;
    return AppStrings.studyMaterialUploadError;
  }

  double? get _selectedFileSizeMb {
    final file = _selectedFile;
    if (file == null) return null;
    final size = file.size;
    if (size <= 0 && file.bytes != null) return file.bytes!.length / (1024 * 1024);
    if (size <= 0) return null;
    return size / (1024 * 1024);
  }

  Future<void> _openDiagram({String? source, String? title}) {
    return context.push(
      RoutePaths.materialDiagramPath(
        source: source,
        title: title ??
            (_titleController.text.trim().isEmpty ? null : _titleController.text.trim()),
        subtopicId: source != null ? null : _parseSubtopicId(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fileSizeMb = _selectedFileSizeMb;

    return Scaffold(
      backgroundColor: AppColors.backgroundBottom,
      appBar: AppBar(
        title: const Text(AppStrings.studyMaterialTitle),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.padding),
          children: [
            _InfoBanner(
              offline: AppConfig.offlineMode,
              chunkCount: _stats?.chunkCount,
              loading: _loadingStats,
            ),
            const SizedBox(height: 20),
            Text(AppStrings.studyMaterialHowItWorks, style: AppTextStyles.cardTitle),
            const SizedBox(height: 8),
            Text(
              AppStrings.studyMaterialHowItWorksBody,
              style: AppTextStyles.cardSubtitle,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: AppStrings.studyMaterialTitleLabel,
                hintText: AppStrings.studyMaterialTitleHint,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            if (_suggestedContext != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.diagnosticCardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${AppStrings.studyMaterialSuggestedSubtopic}: '
                      '${_suggestedContext!.topicName ?? ''} → ${_suggestedContext!.subtopicName ?? ''} '
                      '(ID ${_suggestedContext!.subtopicId})',
                      style: AppTextStyles.cardSubtitle,
                    ),
                    if (_suggestedContext!.curriculumOrigins.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: _suggestedContext!.curriculumOrigins
                            .map(
                              (origin) => Chip(
                                label: Text(origin),
                                visualDensity: VisualDensity.compact,
                                backgroundColor: const Color(0xFFEEF2FF),
                                labelStyle: AppTextStyles.cardSubtitle.copyWith(
                                  fontSize: 10,
                                  color: const Color(0xFF4338CA),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            TextField(
              controller: _subtopicController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: AppStrings.studyMaterialSubtopicLabel,
                helperText: AppStrings.studyMaterialSubtopicHelper,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: _uploading ? null : _pickFile,
              icon: const Icon(Icons.upload_file_outlined),
              label: Text(
                _selectedFile == null
                    ? AppStrings.studyMaterialPickFile
                    : _selectedFile!.name,
              ),
            ),
            if (fileSizeMb != null) ...[
              const SizedBox(height: 8),
              Text(
                AppStrings.studyMaterialFileSizeHint(fileSizeMb),
                style: AppTextStyles.cardSubtitle.copyWith(
                  color: fileSizeMb > 25 ? Colors.orange : AppColors.textMuted,
                ),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _uploading || _selectedFile == null ? null : _upload,
              child: _uploading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(AppStrings.studyMaterialUpload),
            ),
            if (_uploading) ...[
              const SizedBox(height: 12),
              Text(
                AppStrings.studyMaterialUploadingHint,
                style: AppTextStyles.cardSubtitle.copyWith(color: AppColors.primary),
              ),
            ],
            const SizedBox(height: 28),
            Text(AppStrings.studyMaterialPasteTitle, style: AppTextStyles.cardTitle),
            const SizedBox(height: 8),
            Text(
              AppStrings.studyMaterialPasteHint,
              style: AppTextStyles.cardSubtitle,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _pasteController,
              minLines: 5,
              maxLines: 10,
              decoration: const InputDecoration(
                hintText: 'Pega aquí el contenido del capítulo…',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _uploading ? null : _uploadPastedText,
              icon: const Icon(Icons.content_paste_go_outlined),
              label: const Text(AppStrings.studyMaterialPasteButton),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: AppTextStyles.cardSubtitle.copyWith(color: Colors.red),
              ),
            ],
            if (_lastUpload != null) ...[
              const SizedBox(height: 24),
              _SuccessCard(
                result: _lastUpload!,
                onGenerateDiagram: () => _openDiagram(
                  source: _lastUpload!.source,
                  title: _titleController.text.trim().isEmpty
                      ? null
                      : _titleController.text.trim(),
                ),
              ),
            ],
            if (!AppConfig.offlineMode && (_stats?.chunkCount ?? 0) > 0) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _uploading ? null : () => _openDiagram(),
                icon: const Icon(Icons.account_tree_outlined),
                label: const Text(AppStrings.studyMaterialViewDiagrams),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({
    required this.offline,
    required this.loading,
    this.chunkCount,
  });

  final bool offline;
  final bool loading;
  final int? chunkCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.padding),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.menu_book_outlined, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppStrings.studyMaterialBannerTitle,
                  style: AppTextStyles.cardTitle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            offline
                ? AppStrings.studyMaterialOfflineHint
                : AppStrings.studyMaterialBannerBody,
            style: AppTextStyles.cardSubtitle,
          ),
          if (!offline && !loading && chunkCount != null) ...[
            const SizedBox(height: 8),
            Text(
              AppStrings.studyMaterialIndexedChunks(chunkCount!),
              style: AppTextStyles.cardSubtitle.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SuccessCard extends StatelessWidget {
  const _SuccessCard({
    required this.result,
    required this.onGenerateDiagram,
  });

  final RagIngestResult result;
  final VoidCallback onGenerateDiagram;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.padding),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_outline, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                AppStrings.studyMaterialUploadSuccess,
                style: AppTextStyles.cardTitle,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.studyMaterialUploadSuccessDetail(
              result.chunksIndexed,
              result.source,
            ),
            style: AppTextStyles.cardSubtitle,
          ),
          if (result.warning != null && result.warning!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              result.warning!,
              style: AppTextStyles.cardSubtitle.copyWith(color: Colors.orange),
            ),
          ],
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onGenerateDiagram,
            icon: const Icon(Icons.account_tree_outlined),
            label: const Text(AppStrings.studyMaterialGenerateDiagram),
          ),
        ],
      ),
    );
  }
}
