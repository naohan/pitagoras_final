/// Enums alineados a `backend/app/models/enums.py` y schemas Pydantic.
enum QuestionLevel {
  basic('basic'),
  intermediate('intermediate'),
  advanced('advanced');

  const QuestionLevel(this.value);

  final String value;

  static QuestionLevel fromString(String value) {
    return QuestionLevel.values.firstWhere(
      (e) => e.value == value,
      orElse: () => QuestionLevel.intermediate,
    );
  }
}

enum StudentExamStatus {
  pending('pending'),
  inProgress('in_progress'),
  completed('completed'),
  expired('expired');

  const StudentExamStatus(this.value);

  final String value;

  static StudentExamStatus fromString(String value) {
    return StudentExamStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => StudentExamStatus.pending,
    );
  }
}

enum UserRole {
  student('student'),
  parent('parent');

  const UserRole(this.value);

  final String value;

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (e) => e.value == value,
      orElse: () => UserRole.student,
    );
  }
}

/// Alineado a `backend/app/schemas/diagnostic.py` — `PerformanceLevel`.
enum PerformanceLevel {
  strength('strength'),
  neutral('neutral'),
  weakness('weakness');

  const PerformanceLevel(this.value);

  final String value;

  static PerformanceLevel fromString(String value) {
    return PerformanceLevel.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PerformanceLevel.neutral,
    );
  }
}
