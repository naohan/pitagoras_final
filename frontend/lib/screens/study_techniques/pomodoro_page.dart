import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/study_activity_model.dart';

enum _PomodoroPhase { focus, shortBreak, longBreak }

class PomodoroPage extends ConsumerStatefulWidget {
  const PomodoroPage({super.key});

  @override
  ConsumerState<PomodoroPage> createState() => _PomodoroPageState();
}

class _PomodoroPageState extends ConsumerState<PomodoroPage> {
  static const _focusSeconds = 25 * 60;
  static const _shortBreakSeconds = 5 * 60;
  static const _longBreakSeconds = 15 * 60;

  _PomodoroPhase _phase = _PomodoroPhase.focus;
  int _remaining = _focusSeconds;
  int _completedFocusSessions = 0;
  int _points = 0;
  bool _running = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadStats());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadStats() async {
    final session = ref.read(sessionManagerProvider);
    final points = await session.getPomodoroPoints();
    final cycles = await session.getPomodoroCycles();
    if (!mounted) return;
    setState(() {
      _points = points;
      _completedFocusSessions = cycles % 4;
    });
  }

  String get _phaseLabel {
    switch (_phase) {
      case _PomodoroPhase.focus:
        return AppStrings.pomodoroFocus;
      case _PomodoroPhase.shortBreak:
        return AppStrings.pomodoroShortBreak;
      case _PomodoroPhase.longBreak:
        return AppStrings.pomodoroLongBreak;
    }
  }

  void _toggleTimer() {
    if (_running) {
      _timer?.cancel();
      setState(() => _running = false);
      return;
    }
    setState(() => _running = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  Future<void> _tick() async {
    if (_remaining <= 1) {
      _timer?.cancel();
      await _onPhaseComplete();
      return;
    }
    setState(() => _remaining--);
  }

  Future<void> _onPhaseComplete() async {
    final session = ref.read(sessionManagerProvider);
    if (_phase == _PomodoroPhase.focus) {
      await session.addPomodoroPoints(10);
      final cycles = await session.getPomodoroCycles();
      final nextCycles = cycles + 1;
      await session.setPomodoroCycles(nextCycles);
      await ref.read(studyActivityProvider).recordActivity(
            StudyActivityTypes.pomodoro,
            refId: 'pomodoro-$nextCycles',
          );
      if (!mounted) return;
      setState(() {
        _points += 10;
        _completedFocusSessions = nextCycles % 4;
        _running = false;
        if (nextCycles % 4 == 0) {
          _phase = _PomodoroPhase.longBreak;
          _remaining = _longBreakSeconds;
        } else {
          _phase = _PomodoroPhase.shortBreak;
          _remaining = _shortBreakSeconds;
        }
      });
    } else {
      if (!mounted) return;
      setState(() {
        _phase = _PomodoroPhase.focus;
        _remaining = _focusSeconds;
        _running = false;
      });
    }
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _running = false;
      _phase = _PomodoroPhase.focus;
      _remaining = _focusSeconds;
    });
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBottom,
      appBar: AppBar(title: const Text(AppStrings.pomodoroTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(AppStrings.pomodoroSubtitle, style: AppTextStyles.welcome),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Text(_phaseLabel, style: AppTextStyles.cardTitle),
                    const SizedBox(height: 16),
                    Text(
                      _formatTime(_remaining),
                      style: AppTextStyles.greeting.copyWith(fontSize: 48),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.pomodoroCycleProgress(_completedFocusSessions),
                      style: AppTextStyles.cardSubtitle,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _StatChip(
                      label: AppStrings.pomodoroPoints,
                      value: '$_points',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatChip(
                      label: AppStrings.pomodoroReward,
                      value: '+10',
                    ),
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                height: AppSizes.buttonHeight,
                child: FilledButton(
                  onPressed: _toggleTimer,
                  child: Text(_running ? AppStrings.pomodoroPause : AppStrings.pomodoroStart),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _running ? null : _reset,
                child: const Text(AppStrings.pomodoroReset),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.aiCardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value, style: AppTextStyles.cardTitle.copyWith(color: AppColors.primary)),
          Text(label, style: AppTextStyles.cardSubtitle, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
