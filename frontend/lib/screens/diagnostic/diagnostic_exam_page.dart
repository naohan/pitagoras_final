import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/route_paths.dart';

/// Pantalla legacy: el examen real vive en [ExamPage].
/// Redirige al inicio del flujo de diagnóstico.
class DiagnosticExamPage extends StatefulWidget {
  const DiagnosticExamPage({
    super.key,
    required this.careerName,
    required this.universityName,
  });

  final String careerName;
  final String universityName;

  @override
  State<DiagnosticExamPage> createState() => _DiagnosticExamPageState();
}

class _DiagnosticExamPageState extends State<DiagnosticExamPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.go(
        RoutePaths.diagnosticPath(
          careerName: widget.careerName,
          universityName: widget.universityName,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
