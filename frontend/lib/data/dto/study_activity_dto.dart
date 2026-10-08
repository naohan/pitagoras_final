class StudyActivityRecordRequestDto {
  const StudyActivityRecordRequestDto({
    required this.activityType,
    this.refId,
  });

  final String activityType;
  final String? refId;

  Map<String, dynamic> toJson() => {
        'activity_type': activityType,
        if (refId != null && refId!.isNotEmpty) 'ref_id': refId,
      };
}

class StudyActivityRecordDto {
  const StudyActivityRecordDto({
    required this.id,
    required this.studentId,
    required this.activityType,
    required this.activityDate,
    required this.refId,
  });

  final int id;
  final int studentId;
  final String activityType;
  final String activityDate;
  final String refId;

  factory StudyActivityRecordDto.fromJson(Map<String, dynamic> json) {
    return StudyActivityRecordDto(
      id: json['id'] as int,
      studentId: json['student_id'] as int,
      activityType: json['activity_type'] as String,
      activityDate: json['activity_date'] as String,
      refId: json['ref_id'] as String? ?? '',
    );
  }
}

class StreakDto {
  const StreakDto({
    required this.currentStreak,
    required this.longestStreak,
    required this.weekMask,
    this.lastActivityDate,
  });

  final int currentStreak;
  final int longestStreak;
  final List<bool> weekMask;
  final String? lastActivityDate;

  factory StreakDto.fromJson(Map<String, dynamic> json) {
    final mask = (json['week_mask'] as List<dynamic>? ?? [])
        .map((e) => e == true)
        .toList();
    while (mask.length < 7) {
      mask.add(false);
    }
    return StreakDto(
      currentStreak: json['current_streak'] as int? ?? 0,
      longestStreak: json['longest_streak'] as int? ?? 0,
      weekMask: mask.take(7).toList(),
      lastActivityDate: json['last_activity_date'] as String?,
    );
  }
}
