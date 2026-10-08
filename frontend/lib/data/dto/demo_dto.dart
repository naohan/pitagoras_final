class HackathonProfileDto {
  const HackathonProfileDto({
    required this.email,
    required this.fullName,
    required this.studentId,
    required this.universityId,
    required this.universityName,
    required this.careerId,
    required this.careerName,
    required this.admissionProcessId,
    this.ordinarioTemplateId,
    required this.diagnosticStudentExamId,
    required this.lastStudentExamId,
    required this.diagnosticCompleted,
  });

  final String email;
  final String fullName;
  final int studentId;
  final int universityId;
  final String universityName;
  final int careerId;
  final String careerName;
  final int admissionProcessId;
  final int? ordinarioTemplateId;
  final int diagnosticStudentExamId;
  final int lastStudentExamId;
  final bool diagnosticCompleted;

  factory HackathonProfileDto.fromJson(Map<String, dynamic> json) {
    return HackathonProfileDto(
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      studentId: json['student_id'] as int,
      universityId: json['university_id'] as int,
      universityName: json['university_name'] as String,
      careerId: json['career_id'] as int,
      careerName: json['career_name'] as String,
      admissionProcessId: json['admission_process_id'] as int,
      ordinarioTemplateId: json['ordinario_template_id'] as int?,
      diagnosticStudentExamId: json['diagnostic_student_exam_id'] as int,
      lastStudentExamId: json['last_student_exam_id'] as int,
      diagnosticCompleted: json['diagnostic_completed'] as bool? ?? true,
    );
  }
}
