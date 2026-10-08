class StreakInfo {
  const StreakInfo({
    required this.currentStreak,
    required this.longestStreak,
    required this.weekMask,
    this.lastActivityDate,
  });

  final int currentStreak;
  final int longestStreak;
  final List<bool> weekMask;
  final String? lastActivityDate;

  static const empty = StreakInfo(
    currentStreak: 0,
    longestStreak: 0,
    weekMask: [false, false, false, false, false, false, false],
  );
}

abstract final class StudyActivityTypes {
  static const exam = 'exam';
  static const flashcards = 'flashcards';
  static const pomodoro = 'pomodoro';
  static const material = 'material';
  static const motivator = 'motivator';
}
