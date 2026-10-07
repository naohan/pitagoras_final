import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/route_paths.dart';
import '../../widgets/app_bottom_nav.dart';
import 'evaluations_tab.dart';
import 'inicio_tab.dart';
import 'profile_tab.dart';
import 'ranking_tab.dart';
import 'study_tab.dart';

class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  late int _currentIndex;

  static const _tabs = <Widget>[
    InicioTab(),
    StudyTab(),
    EvaluationsTab(),
    RankingTab(),
    ProfileTab(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab.clamp(0, AppBottomNav.tabCount - 1);
  }

  @override
  void didUpdateWidget(covariant MainShellPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab) {
      _currentIndex = widget.initialTab.clamp(0, AppBottomNav.tabCount - 1);
    }
  }

  void _onTabSelected(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    context.go(RoutePaths.homeTab(index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
      ),
    );
  }
}
