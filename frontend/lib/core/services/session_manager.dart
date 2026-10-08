import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/storage_keys.dart';
import '../models/unsa_exam_target.dart';
import '../utils/text_encoding.dart';

/// Persistencia segura de credenciales y datos de sesión.
///
/// Sin lógica de negocio: solo lectura/escritura de claves.
class SessionManager {
  SessionManager({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  final FlutterSecureStorage _storage;

  Future<String?> getAccessToken() =>
      _storage.read(key: StorageKeys.accessToken);

  Future<void> saveAccessToken(String token) =>
      _storage.write(key: StorageKeys.accessToken, value: token);

  Future<String?> getRefreshToken() =>
      _storage.read(key: StorageKeys.refreshToken);

  Future<void> saveRefreshToken(String? token) async {
    if (token == null || token.isEmpty) {
      await _storage.delete(key: StorageKeys.refreshToken);
      return;
    }
    await _storage.write(key: StorageKeys.refreshToken, value: token);
  }

  Future<String?> getTokenType() => _storage.read(key: StorageKeys.tokenType);

  Future<void> saveTokenType(String tokenType) =>
      _storage.write(key: StorageKeys.tokenType, value: tokenType);

  Future<int?> getStudentId() async {
    final value = await _storage.read(key: StorageKeys.studentId);
    if (value == null) return null;
    return int.tryParse(value);
  }

  Future<void> saveStudentId(int? studentId) async {
    if (studentId == null) {
      await _storage.delete(key: StorageKeys.studentId);
      return;
    }
    await _storage.write(
      key: StorageKeys.studentId,
      value: studentId.toString(),
    );
  }

  Future<String?> getUserEmail() => _storage.read(key: StorageKeys.userEmail);

  Future<void> saveUserEmail(String? email) async {
    if (email == null) {
      await _storage.delete(key: StorageKeys.userEmail);
      return;
    }
    await _storage.write(key: StorageKeys.userEmail, value: email);
  }

  Future<String?> getUserFullName() =>
      _storage.read(key: StorageKeys.userFullName);

  Future<void> saveUserFullName(String? fullName) async {
    if (fullName == null) {
      await _storage.delete(key: StorageKeys.userFullName);
      return;
    }
    await _storage.write(key: StorageKeys.userFullName, value: fullName);
  }

  Future<int?> getStudentExamId() async {
    final value = await _storage.read(key: StorageKeys.studentExamId);
    if (value == null) return null;
    return int.tryParse(value);
  }

  Future<void> saveStudentExamId(int studentExamId) => _storage.write(
        key: StorageKeys.studentExamId,
        value: studentExamId.toString(),
      );

  Future<void> clearStudentExamId() =>
      _storage.delete(key: StorageKeys.studentExamId);

  Future<int?> getDiagnosticStudentExamId() async {
    final value = await _storage.read(key: StorageKeys.diagnosticStudentExamId);
    if (value == null) return null;
    return int.tryParse(value);
  }

  Future<void> saveDiagnosticStudentExamId(int studentExamId) => _storage.write(
        key: StorageKeys.diagnosticStudentExamId,
        value: studentExamId.toString(),
      );

  Future<void> clearDiagnosticStudentExamId() =>
      _storage.delete(key: StorageKeys.diagnosticStudentExamId);

  Future<String?> getCareerName() async {
    final value = await _storage.read(key: StorageKeys.careerName);
    if (value == null) return null;
    final fixed = fixMojibake(value);
    if (fixed != value) {
      await _storage.write(key: StorageKeys.careerName, value: fixed);
    }
    return fixed;
  }

  Future<void> saveCareerName(String? careerName) async {
    if (careerName == null || careerName.isEmpty) {
      await _storage.delete(key: StorageKeys.careerName);
      return;
    }
    await _storage.write(
      key: StorageKeys.careerName,
      value: fixMojibake(careerName),
    );
  }

  Future<String?> getUniversityName() async {
    final value = await _storage.read(key: StorageKeys.universityName);
    if (value == null) return null;
    final fixed = fixMojibake(value);
    if (fixed != value) {
      await _storage.write(key: StorageKeys.universityName, value: fixed);
    }
    return fixed;
  }

  Future<void> saveUniversityName(String? universityName) async {
    if (universityName == null || universityName.isEmpty) {
      await _storage.delete(key: StorageKeys.universityName);
      return;
    }
    await _storage.write(
      key: StorageKeys.universityName,
      value: fixMojibake(universityName),
    );
  }

  Future<int?> getUniversityId() async {
    final value = await _storage.read(key: StorageKeys.universityId);
    if (value == null) return null;
    return int.tryParse(value);
  }

  Future<void> saveUniversityId(int? universityId) async {
    if (universityId == null) {
      await _storage.delete(key: StorageKeys.universityId);
      return;
    }
    await _storage.write(
      key: StorageKeys.universityId,
      value: universityId.toString(),
    );
  }

  Future<int?> getCareerId() async {
    final value = await _storage.read(key: StorageKeys.careerId);
    if (value == null) return null;
    return int.tryParse(value);
  }

  Future<void> saveCareerId(int? careerId) async {
    if (careerId == null) {
      await _storage.delete(key: StorageKeys.careerId);
      return;
    }
    await _storage.write(
      key: StorageKeys.careerId,
      value: careerId.toString(),
    );
  }

  Future<int?> getExamTemplateId() async {
    final value = await _storage.read(key: StorageKeys.examTemplateId);
    if (value == null) return null;
    return int.tryParse(value);
  }

  Future<void> saveExamTemplateId(int? examTemplateId) async {
    if (examTemplateId == null) {
      await _storage.delete(key: StorageKeys.examTemplateId);
      return;
    }
    await _storage.write(
      key: StorageKeys.examTemplateId,
      value: examTemplateId.toString(),
    );
  }

  Future<int?> getAdmissionProcessId() async {
    final value = await _storage.read(key: StorageKeys.admissionProcessId);
    if (value == null) return null;
    return int.tryParse(value);
  }

  Future<void> saveAdmissionProcessId(int? admissionProcessId) async {
    if (admissionProcessId == null) {
      await _storage.delete(key: StorageKeys.admissionProcessId);
      return;
    }
    await _storage.write(
      key: StorageKeys.admissionProcessId,
      value: admissionProcessId.toString(),
    );
  }

  Future<void> saveStudyProfile({
    required String careerName,
    required String universityName,
    int? universityId,
    int? careerId,
  }) async {
    await saveCareerName(careerName);
    await saveUniversityName(universityName);
    if (universityId != null) await saveUniversityId(universityId);
    if (careerId != null) await saveCareerId(careerId);
  }

  Future<bool> isDiagnosticCompleted() async {
    final value = await _storage.read(key: StorageKeys.diagnosticCompleted);
    return value == 'true';
  }

  Future<void> setDiagnosticCompleted(bool completed) async {
    if (completed) {
      await _storage.write(key: StorageKeys.diagnosticCompleted, value: 'true');
      return;
    }
    await _storage.delete(key: StorageKeys.diagnosticCompleted);
  }

  Future<UnsaExamTarget?> getUnsaExamTarget() async {
    final value = await _storage.read(key: StorageKeys.unsaExamTarget);
    return UnsaExamTarget.fromStorage(value);
  }

  Future<void> saveUnsaExamTarget(UnsaExamTarget? target) async {
    if (target == null) {
      await _storage.delete(key: StorageKeys.unsaExamTarget);
      return;
    }
    await _storage.write(key: StorageKeys.unsaExamTarget, value: target.storageKey);
  }

  Future<String?> getExamTargetCode() async {
    return _storage.read(key: StorageKeys.examTargetCode);
  }

  Future<void> saveExamTargetCode(String? code) async {
    if (code == null || code.isEmpty) {
      await _storage.delete(key: StorageKeys.examTargetCode);
      return;
    }
    await _storage.write(key: StorageKeys.examTargetCode, value: code);
  }

  Future<double?> getCareerTargetScore() async {
    final value = await _storage.read(key: StorageKeys.careerTargetScore);
    return double.tryParse(value ?? '');
  }

  Future<void> saveCareerTargetScore(double? score) async {
    if (score == null) {
      await _storage.delete(key: StorageKeys.careerTargetScore);
      return;
    }
    await _storage.write(
      key: StorageKeys.careerTargetScore,
      value: score.toString(),
    );
  }

  Future<String?> getMetaTitle() async {
    return _storage.read(key: StorageKeys.metaTitle);
  }

  Future<void> saveMetaTitle(String? title) async {
    if (title == null || title.isEmpty) {
      await _storage.delete(key: StorageKeys.metaTitle);
      return;
    }
    await _storage.write(key: StorageKeys.metaTitle, value: title);
  }

  Future<String?> getStudyPurpose() async {
    return _storage.read(key: StorageKeys.studyPurpose);
  }

  Future<void> saveStudyPurpose(String? purpose) async {
    if (purpose == null || purpose.isEmpty) {
      await _storage.delete(key: StorageKeys.studyPurpose);
      return;
    }
    await _storage.write(key: StorageKeys.studyPurpose, value: purpose);
  }

  Future<String?> getFocusSubtopicName() async {
    return _storage.read(key: StorageKeys.focusSubtopicName);
  }

  Future<int?> getFocusSubtopicId() async {
    final value = await _storage.read(key: StorageKeys.focusSubtopicId);
    return int.tryParse(value ?? '');
  }

  Future<void> saveFocusTopic({
    required int subtopicId,
    required String subtopicName,
    String? areaName,
  }) async {
    await _storage.write(
      key: StorageKeys.focusSubtopicId,
      value: subtopicId.toString(),
    );
    await _storage.write(key: StorageKeys.focusSubtopicName, value: subtopicName);
    if (areaName != null && areaName.isNotEmpty) {
      await _storage.write(key: StorageKeys.focusAreaName, value: areaName);
    }
  }

  Future<int> getPomodoroPoints() async {
    final value = await _storage.read(key: StorageKeys.pomodoroPoints);
    return int.tryParse(value ?? '') ?? 0;
  }

  Future<void> addPomodoroPoints(int delta) async {
    final current = await getPomodoroPoints();
    await _storage.write(
      key: StorageKeys.pomodoroPoints,
      value: (current + delta).toString(),
    );
  }

  Future<int> getPomodoroCycles() async {
    final value = await _storage.read(key: StorageKeys.pomodoroCycles);
    return int.tryParse(value ?? '') ?? 0;
  }

  Future<void> setPomodoroCycles(int cycles) async {
    await _storage.write(
      key: StorageKeys.pomodoroCycles,
      value: cycles.toString(),
    );
  }

  Future<bool> hasSession() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clearSession() async {
    await _storage.delete(key: StorageKeys.accessToken);
    await _storage.delete(key: StorageKeys.refreshToken);
    await _storage.delete(key: StorageKeys.tokenType);
    await _storage.delete(key: StorageKeys.studentId);
    await _storage.delete(key: StorageKeys.userEmail);
    await _storage.delete(key: StorageKeys.userFullName);
    await _storage.delete(key: StorageKeys.studentExamId);
    await _storage.delete(key: StorageKeys.diagnosticStudentExamId);
    await _storage.delete(key: StorageKeys.careerName);
    await _storage.delete(key: StorageKeys.universityName);
    await _storage.delete(key: StorageKeys.universityId);
    await _storage.delete(key: StorageKeys.careerId);
    await _storage.delete(key: StorageKeys.examTemplateId);
    await _storage.delete(key: StorageKeys.admissionProcessId);
    await _storage.delete(key: StorageKeys.diagnosticCompleted);
    await _storage.delete(key: StorageKeys.unsaExamTarget);
    await _storage.delete(key: StorageKeys.examTargetCode);
    await _storage.delete(key: StorageKeys.careerTargetScore);
    await _storage.delete(key: StorageKeys.metaTitle);
    await _storage.delete(key: StorageKeys.studyPurpose);
    await _storage.delete(key: StorageKeys.focusSubtopicId);
    await _storage.delete(key: StorageKeys.focusSubtopicName);
    await _storage.delete(key: StorageKeys.focusAreaName);
  }
}
