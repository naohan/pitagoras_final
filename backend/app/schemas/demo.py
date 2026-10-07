from pydantic import BaseModel, EmailStr


class HackathonProfileResponse(BaseModel):
    email: EmailStr
    full_name: str
    student_id: int
    university_id: int
    university_name: str
    career_id: int
    career_name: str
    admission_process_id: int
    ordinario_template_id: int | None = None
    diagnostic_student_exam_id: int
    last_student_exam_id: int
    diagnostic_completed: bool = True
