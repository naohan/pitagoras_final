import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/api/interceptors/error_interceptor.dart';
import '../../data/models/rag_model.dart';
import 'diagram_export.dart';

class MaterialDiagramPage extends ConsumerStatefulWidget {
  const MaterialDiagramPage({
    super.key,
    this.title,
    this.source,
    this.subtopicId,
  });

  final String? title;
  final String? source;
  final int? subtopicId;

  @override
  ConsumerState<MaterialDiagramPage> createState() => _MaterialDiagramPageState();
}

class _MaterialDiagramPageState extends ConsumerState<MaterialDiagramPage> {
  bool _loading = true;
  bool _exporting = false;
  String? _errorMessage;
  MaterialDiagram? _diagram;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final diagram = await ref.read(studyMaterialProvider).buildDiagram(
            title: widget.title,
            source: widget.source,
            subtopicId: widget.subtopicId,
          );
      if (!mounted) return;
      setState(() {
        _diagram = diagram;
        _loading = false;
        if (diagram.nodes.isEmpty) {
          _errorMessage = null;
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = readApiException(error)?.message ?? error.toString();
      });
    }
  }

  Future<void> _showExportOptions() async {
    final diagram = _diagram;
    if (diagram == null || diagram.nodes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.materialDiagramExportEmpty)),
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.copy_rounded),
                title: const Text(AppStrings.materialDiagramExportCopy),
                onTap: () {
                  Navigator.pop(context);
                  _copyDiagram(diagram);
                },
              ),
              ListTile(
                leading: const Icon(Icons.download_rounded),
                title: const Text(AppStrings.materialDiagramExportSave),
                onTap: () {
                  Navigator.pop(context);
                  _saveDiagram(diagram);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _copyDiagram(MaterialDiagram diagram) async {
    setState(() => _exporting = true);
    try {
      await Clipboard.setData(ClipboardData(text: materialDiagramToText(diagram)));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.materialDiagramExportSuccess)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.materialDiagramExportError)),
      );
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _saveDiagram(MaterialDiagram diagram) async {
    setState(() => _exporting = true);
    try {
      final text = materialDiagramToText(diagram);
      final bytes = Uint8List.fromList(utf8.encode(text));
      final path = await FilePicker.platform.saveFile(
        dialogTitle: AppStrings.materialDiagramExportSave,
        fileName: materialDiagramFileName(diagram.title),
        bytes: bytes,
      );
      if (!mounted) return;
      if (path != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.materialDiagramExportSaved)),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.materialDiagramExportError)),
      );
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canExport = _diagram != null && _diagram!.nodes.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(AppStrings.materialDiagramTitle),
        actions: [
          if (canExport)
            IconButton(
              onPressed: _exporting ? null : _showExportOptions,
              icon: _exporting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.ios_share_rounded),
              tooltip: AppStrings.materialDiagramExport,
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 16),
            Text(AppStrings.materialDiagramLoading, style: AppTextStyles.cardSubtitle),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.padding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(onPressed: _load, child: const Text('Reintentar')),
            ],
          ),
        ),
      );
    }

    final diagram = _diagram;
    if (diagram == null || diagram.nodes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.padding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppStrings.materialDiagramEmpty,
                textAlign: TextAlign.center,
                style: AppTextStyles.welcome,
              ),
              const SizedBox(height: 16),
              FilledButton(onPressed: _load, child: const Text('Reintentar')),
            ],
          ),
        ),
      );
    }

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(diagram.title, style: AppTextStyles.cardTitle.copyWith(fontSize: 18)),
                const SizedBox(height: 4),
                Text(
                  AppStrings.materialDiagramSubtitle,
                  style: AppTextStyles.cardSubtitle.copyWith(fontSize: 12),
                ),
                if (diagram.chunkCount > 0) ...[
                  const SizedBox(height: 6),
                  Text(
                    '${AppStrings.materialDiagramChunksUsed}: ${diagram.chunkCount}',
                    style: AppTextStyles.cardSubtitle.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSizes.padding),
              children: diagram.nodes
                  .map((node) => _DiagramTile(node: node, depth: 0))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiagramTile extends StatelessWidget {
  const _DiagramTile({required this.node, required this.depth});

  final MaterialDiagramNode node;
  final int depth;

  @override
  Widget build(BuildContext context) {
    if (node.children.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(left: depth * 14.0, bottom: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(node.label, style: AppTextStyles.cardSubtitle.copyWith(fontSize: 13)),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(left: depth * 8.0, bottom: 8),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.border),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: depth < 2,
            leading: Icon(
              depth == 0 ? Icons.account_tree_outlined : Icons.folder_outlined,
              color: depth == 0 ? const Color(0xFF7C3AED) : AppColors.primary,
            ),
            title: Text(
              node.label,
              style: AppTextStyles.cardTitle.copyWith(fontSize: depth == 0 ? 15 : 14),
            ),
            children: node.children
                .map((child) => _DiagramTile(node: child, depth: depth + 1))
                .toList(),
          ),
        ),
      ),
    );
  }
}
