import '../dto/saved_answer_dto.dart';
import '../models/saved_answer_model.dart';

class SavedAnswerMapper {
  const SavedAnswerMapper._();

  static SavedAnswerItem toItem(SavedAnswerItemDto dto) {
    return SavedAnswerItem(
      studentAnswerId: dto.studentAnswerId,
      studentExamId: dto.studentExamId,
      questionId: dto.questionId,
      stem: dto.stem,
      areaName: dto.areaName,
      selectedOptionId: dto.selectedOptionId,
      isCorrect: dto.isCorrect,
      isSaved: dto.isSaved,
      answeredAt: dto.answeredAt,
      displayOrder: dto.displayOrder,
      options: dto.options
          .map(
            (opt) => QuestionOptionReview(
              id: opt.id,
              label: opt.label,
              text: opt.text,
              isCorrect: opt.isCorrect,
              displayOrder: opt.displayOrder,
            ),
          )
          .toList(),
    );
  }

  static List<SavedAnswerItem> toList(List<SavedAnswerItemDto> dtos) {
    return dtos.map(toItem).toList();
  }
}
