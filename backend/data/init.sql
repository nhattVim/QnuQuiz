CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ========================
-- ENUMs
-- ========================
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_role') THEN
    CREATE TYPE user_role AS ENUM ('STUDENT','TEACHER','ADMIN');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_status') THEN
    CREATE TYPE user_status AS ENUM ('ACTIVE','INACTIVE');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'question_type') THEN
    CREATE TYPE question_type AS ENUM ('MULTIPLE_CHOICE','TRUE_FALSE');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'exam_status') THEN
    CREATE TYPE exam_status AS ENUM ('DRAFT','PUBLISHED');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'feedback_status') THEN
    CREATE TYPE feedback_status AS ENUM ('PENDING','REVIEWED','RESOLVED');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'announcement_target') THEN
    CREATE TYPE announcement_target AS ENUM ('ALL','STUDENT','TEACHER','CLASS','DEPARTMENT');
  END IF;
END
$$;

-- ========================
-- TABLE: users
-- ========================
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  username VARCHAR(128) NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  full_name VARCHAR(256),
  email VARCHAR(256),
  phone_number VARCHAR(16),
  avatar_url TEXT,
  role user_role NOT NULL DEFAULT 'STUDENT',
  status user_status NOT NULL DEFAULT 'ACTIVE',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);

CREATE OR REPLACE FUNCTION trg_set_timestamp()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_users_updated BEFORE UPDATE ON users
FOR EACH ROW EXECUTE PROCEDURE trg_set_timestamp();

-- ========================
-- TABLE: departments
-- ========================
CREATE TABLE IF NOT EXISTS departments (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(256) NOT NULL UNIQUE,
  description TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ========================
-- TABLE: classes
-- ========================
CREATE TABLE IF NOT EXISTS classes (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(128) NOT NULL,
  thumbnail_url TEXT,
  department_id BIGINT REFERENCES departments(id) ON DELETE SET NULL,
  advisor_teacher_id UUID REFERENCES users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(name, department_id)
);

CREATE INDEX IF NOT EXISTS idx_classes_department ON classes(department_id);

-- ========================
-- TABLE: students
-- ========================
CREATE TABLE IF NOT EXISTS students (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  student_code VARCHAR(64) NOT NULL UNIQUE,
  class_id BIGINT REFERENCES classes(id) ON DELETE SET NULL,
  department_id BIGINT REFERENCES departments(id) ON DELETE SET NULL,
  gpa NUMERIC(3,2) CHECK (gpa >= 0 AND gpa <= 10),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_students_class ON students(class_id);
CREATE INDEX IF NOT EXISTS idx_students_department ON students(department_id);

-- ========================
-- TABLE: teachers
-- ========================
CREATE TABLE IF NOT EXISTS teachers (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  teacher_code VARCHAR(64) UNIQUE,
  department_id BIGINT REFERENCES departments(id) ON DELETE SET NULL,
  title VARCHAR(128),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_teachers_department ON teachers(department_id);

-- ========================
-- TABLE: exam_categories 
-- ========================
CREATE TABLE IF NOT EXISTS exam_categories (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(256) NOT NULL UNIQUE,
  description TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ========================
-- TABLE: exams
-- ========================
CREATE TABLE IF NOT EXISTS exams (
  id BIGSERIAL PRIMARY KEY,
  title VARCHAR(256) NOT NULL,
  description TEXT,
  banner_url TEXT,
  category_id BIGINT REFERENCES exam_categories(id) ON DELETE SET NULL,
  created_by UUID REFERENCES users(id) ON DELETE SET NULL,
  start_time TIMESTAMPTZ,
  end_time TIMESTAMPTZ,
  random BOOLEAN NOT NULL DEFAULT FALSE,
  max_questions INT,
  duration_minutes INT,
  status exam_status NOT NULL DEFAULT 'DRAFT',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  
  CONSTRAINT chk_exams_time CHECK (end_time > start_time),
  CONSTRAINT chk_exams_random CHECK (
    (random = FALSE) OR (random = TRUE AND max_questions > 0)
  )
);

CREATE TRIGGER trg_exams_updated BEFORE UPDATE ON exams
FOR EACH ROW EXECUTE PROCEDURE trg_set_timestamp();

CREATE INDEX IF NOT EXISTS idx_exams_status ON exams(status);
CREATE INDEX IF NOT EXISTS idx_exams_category ON exams(category_id);

-- ========================
-- TABLE: questions
-- ========================
CREATE TABLE IF NOT EXISTS questions (
  id BIGSERIAL PRIMARY KEY,
  exam_id BIGINT NOT NULL REFERENCES exams(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  type question_type NOT NULL DEFAULT 'MULTIPLE_CHOICE',
  created_by UUID REFERENCES users(id) ON DELETE SET NULL,
  ordering INT DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_questions_exam ON questions(exam_id);

CREATE TRIGGER trg_questions_updated BEFORE UPDATE ON questions
FOR EACH ROW EXECUTE PROCEDURE trg_set_timestamp();

-- ========================
-- TABLE: question_options
-- ========================
CREATE TABLE IF NOT EXISTS question_options (
  id BIGSERIAL PRIMARY KEY,
  question_id BIGINT NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  is_correct BOOLEAN NOT NULL DEFAULT FALSE,
  position INT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_question_options_question ON question_options(question_id);

-- ========================
-- TABLE: exam_attempts
-- ========================
CREATE TABLE IF NOT EXISTS exam_attempts (
  id BIGSERIAL PRIMARY KEY,
  exam_id BIGINT REFERENCES exams(id) ON DELETE CASCADE,
  student_id BIGINT REFERENCES students(id) ON DELETE CASCADE,
  start_time TIMESTAMPTZ NOT NULL DEFAULT now(),
  end_time TIMESTAMPTZ,
  score INTEGER DEFAULT 0,
  submitted BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_attempts_exam ON exam_attempts(exam_id);
CREATE INDEX IF NOT EXISTS idx_attempts_student ON exam_attempts(student_id);

-- ========================
-- TABLE: exam_answers
-- ========================
CREATE TABLE IF NOT EXISTS exam_answers (
  id BIGSERIAL PRIMARY KEY,
  attempt_id BIGINT NOT NULL REFERENCES exam_attempts(id) ON DELETE CASCADE,
  question_id BIGINT NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
  selected_option_id BIGINT REFERENCES question_options(id) ON DELETE SET NULL,
  is_correct BOOLEAN,
  answer_text TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_answers_attempt ON exam_answers(attempt_id);
CREATE INDEX IF NOT EXISTS idx_answers_question_id ON exam_answers(question_id);

-- ========================
-- TABLE: feedbacks
-- ========================
CREATE TABLE IF NOT EXISTS feedbacks (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE SET NULL,
  exam_id BIGINT REFERENCES exams(id) ON DELETE CASCADE,
  question_id BIGINT REFERENCES questions(id) ON DELETE SET NULL,
  content TEXT NOT NULL,
  rating INT CHECK (rating BETWEEN 1 AND 5),
  status feedback_status NOT NULL DEFAULT 'PENDING',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  reviewed_by UUID REFERENCES users(id) ON DELETE SET NULL,
  reviewed_at TIMESTAMPTZ,
  teacher_reply TEXT
);

CREATE INDEX IF NOT EXISTS idx_feedbacks_user ON feedbacks(user_id);
CREATE INDEX IF NOT EXISTS idx_feedbacks_question ON feedbacks(question_id);

-- Mỗi user chỉ được feedback 1 lần cho 1 câu hỏi hoặc 1 bài thi
CREATE UNIQUE INDEX IF NOT EXISTS ux_feedback_user_question
  ON feedbacks(user_id, question_id)
  WHERE question_id IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS ux_feedback_user_exam
  ON feedbacks(user_id, exam_id)
  WHERE exam_id IS NOT NULL;

-- ========================
-- TABLE: announcements
-- ========================
CREATE TABLE IF NOT EXISTS announcements (
  id BIGSERIAL PRIMARY KEY,
  title VARCHAR(256) NOT NULL,
  content TEXT NOT NULL,
  author_id UUID REFERENCES users(id) ON DELETE SET NULL,
  target announcement_target NOT NULL DEFAULT 'ALL',
  target_class_id BIGINT REFERENCES classes(id) ON DELETE SET NULL,
  target_department_id BIGINT REFERENCES departments(id) ON DELETE SET NULL,
  published_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_announcements_target ON announcements(target);

-- ========================
-- TABLE: faqs
-- ========================
CREATE TABLE IF NOT EXISTS faqs (
  id BIGSERIAL PRIMARY KEY,
  question VARCHAR(512) NOT NULL,
  answer TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ========================
-- TABLE: leaderboard
-- ========================
CREATE TABLE IF NOT EXISTS leaderboard (
  id BIGSERIAL PRIMARY KEY,
  exam_id BIGINT REFERENCES exams(id) ON DELETE CASCADE,
  student_id BIGINT REFERENCES students(id) ON DELETE CASCADE,
  score INTEGER DEFAULT 0,
  rank INTEGER,
  generated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_leaderboard_exam ON leaderboard(exam_id);
CREATE INDEX IF NOT EXISTS idx_leaderboard_student ON leaderboard(student_id);

-- ========================
-- TABLE: media_files
-- ========================
CREATE TABLE IF NOT EXISTS media_files (
  id BIGSERIAL PRIMARY KEY,
  file_name VARCHAR(512) NOT NULL,
  file_url TEXT NOT NULL,
  mime_type VARCHAR(128),
  size_bytes BIGINT,
  uploaded_by UUID REFERENCES users(id) ON DELETE SET NULL,
  related_table VARCHAR(128), 
  related_id VARCHAR(256),
   
  description TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_media_related ON media_files(related_table, related_id);
