import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/score_utils.dart';
import '../../data/api/interceptors/error_interceptor.dart';
import '../../data/enums.dart';
import '../../data/models/study_tools_model.dart';

class ConceptMapPage extends ConsumerStatefulWidget {
  const ConceptMapPage({super.key, required this.studentExamId});

  final int studentExamId;

  @override
  ConsumerState<ConceptMapPage> createState() => _ConceptMapPageState();
}

class _ConceptMapPageState extends ConsumerState<ConceptMapPage> {
  bool _loading = true;
  String? _errorMessage;
  List<ConceptMapNode> _nodes = [];

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
      final nodes =
          await ref.read(studyToolsProvider).getConceptMap(widget.studentExamId);
      if (!mounted) return;
      setState(() {
        _nodes = nodes;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = readApiException(error)?.message ?? error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBottom,
      appBar: AppBar(
        title: const Text(AppStrings.conceptMapPageTitle),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
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

    if (_nodes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.padding),
          child: Text(
            AppStrings.conceptMapEmpty,
            textAlign: TextAlign.center,
            style: AppTextStyles.welcome,
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
            child: Text(
              AppStrings.conceptMapLegend,
              style: AppTextStyles.cardSubtitle,
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSizes.padding),
              children: _nodes
                  .map((node) => _ConceptMapTile(node: node, depth: 0))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConceptMapTile extends StatelessWidget {
  const _ConceptMapTile({required this.node, required this.depth});

  final ConceptMapNode node;
  final int depth;

  Color? _levelColor(String? level) {
    if (level == null) return null;
    final parsed = PerformanceLevel.fromString(level);
    switch (parsed) {
      case PerformanceLevel.weakness:
        return AppColors.danger;
      case PerformanceLevel.strength:
        return AppColors.success;
      case PerformanceLevel.neutral:
        return AppColors.progressOrange;
    }
  }

  String? _trailingLabel() {
    if (node.entityType != 'subtopic') return null;
    if (node.scorePercent == null) return 'Sin datos';
    final level = node.level != null ? ' · ${node.level}' : '';
    return '${ScoreUtils.formatPercent(node.scorePercent!)}$level';
  }

  @override
  Widget build(BuildContext context) {
    final trailing = _trailingLabel();
    final levelColor = _levelColor(node.level);

    if (node.children.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(left: depth * 12.0, bottom: 6),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          tileColor: levelColor?.withValues(alpha: 0.08) ?? Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          leading: levelColor != null
              ? Icon(Icons.circle, size: 10, color: levelColor)
              : Icon(_iconForType(node.entityType), color: AppColors.primary, size: 20),
          title: Text(node.name, style: AppTextStyles.selectionTitle),
          trailing: trailing != null
              ? Text(
                  trailing,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: levelColor ?? AppColors.primary,
                  ),
                )
              : null,
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(left: depth * 8.0, bottom: 4),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: depth < 2,
            leading: Icon(_iconForType(node.entityType), color: AppColors.primary),
            title: Text(node.name, style: AppTextStyles.cardTitle.copyWith(fontSize: 15)),
            children: node.children
                .map((child) => _ConceptMapTile(node: child, depth: depth + 1))
                .toList(),
          ),
        ),
      ),
    );
  }

  IconData _iconForType(String entityType) {
    switch (entityType) {
      case 'area':
        return Icons.category_outlined;
      case 'component':
        return Icons.view_module_outlined;
      case 'topic':
        return Icons.topic_outlined;
      case 'subtopic':
        return Icons.adjust;
      default:
        return Icons.circle_outlined;
    }
  }
}
