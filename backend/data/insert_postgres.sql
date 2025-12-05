-- =============================================
-- DATA SEED FOR POSTGRESQL
-- Logic: Mỗi câu đúng = 10 điểm (INTEGER)
-- =============================================

-- 1. USERS
INSERT INTO users (id, username, password_hash, full_name, email, role, status, created_at, updated_at, avatar_url) VALUES
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'admin', '$2a$10$fsxxNTnoL9KZZhqleSuk5uWO0UUCLKjAkZ4cDLYbD4ljXZkxCS4Ki', 'Quản trị viên', 'admin@qnu.edu.vn', 'ADMIN', 'ACTIVE', NOW(), NOW(), NULL),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12', 'teacher1', '$2a$10$fsxxNTnoL9KZZhqleSuk5uWO0UUCLKjAkZ4cDLYbD4ljXZkxCS4Ki', 'Nguyễn Văn An (GV)', 'gv.an@qnu.edu.vn', 'TEACHER', 'ACTIVE', NOW(), NOW(), 'https://heucollege.edu.vn/upload/2025/02/hinh-dai-dien-anime-nu-10.webp'),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13', 'teacher2', '$2a$10$fsxxNTnoL9KZZhqleSuk5uWO0UUCLKjAkZ4cDLYbD4ljXZkxCS4Ki', 'Trần Thị Bình (GV)', 'gv.binh@qnu.edu.vn', 'TEACHER', 'ACTIVE', NOW(), NOW(), 'https://cdn-media.sforum.vn/storage/app/media/THANHAN/avartar-anime-91.jpg'),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a14', 'teacher3', '$2a$10$fsxxNTnoL9KZZhqleSuk5uWO0UUCLKjAkZ4cDLYbD4ljXZkxCS4Ki', 'Lê Văn Cường (GV)', 'gv.cuong@qnu.edu.vn', 'TEACHER', 'INACTIVE', NOW(), NOW(), 'https://jbagy.me/wp-content/uploads/2025/03/Hinh-anh-anime-dang-yeu-khong-the-cuong-duoc-3.jpg'),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a15', 'student1', '$2a$10$fsxxNTnoL9KZZhqleSuk5uWO0UUCLKjAkZ4cDLYbD4ljXZkxCS4Ki', 'Phạm Thị Dung (SV)', 'sv.dung@qnu.edu.vn', 'STUDENT', 'ACTIVE', NOW(), NOW(), 'https://cellphones.com.vn/sforum/wp-content/uploads/2024/01/avartar-anime-6.jpg'),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a16', 'student2', '$2a$10$fsxxNTnoL9KZZhqleSuk5uWO0UUCLKjAkZ4cDLYbD4ljXZkxCS4Ki', 'Hoàng Văn Em (SV)', 'sv.em@qnu.edu.vn', 'STUDENT', 'ACTIVE', NOW(), NOW(), 'https://jbagy.me/wp-content/uploads/2025/03/Hinh-anh-avatar-anime-nu-cute-1.jpg'),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a17', 'student3', '$2a$10$fsxxNTnoL9KZZhqleSuk5uWO0UUCLKjAkZ4cDLYbD4ljXZkxCS4Ki', 'Vũ Thị Hà (SV)', 'sv.ha@qnu.edu.vn', 'STUDENT', 'ACTIVE', NOW(), NOW(), 'https://jbagy.me/wp-content/uploads/2025/03/Hinh-anh-anime-dang-yeu-khong-the-cuong-duoc-2.jpg');

-- 2. DEPARTMENTS
INSERT INTO departments (name, description, created_at) VALUES
('Khoa Công nghệ Thông tin', 'Đào tạo kỹ sư CNTT và các ngành liên quan', NOW()),
('Khoa Kinh tế & Kế toán', 'Đào tạo cử nhân kinh tế, kế toán, tài chính', NOW()),
('Khoa Ngoại ngữ', 'Đào tạo cử nhân ngôn ngữ Anh, Nhật, Trung', NOW());

-- 3. CLASSES
INSERT INTO classes (name, department_id, advisor_teacher_id, created_at) VALUES
('K43A - CNTT', 1, 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12', NOW()),
('K43B - CNTT', 1, 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13', NOW()),
('K43A - Kế toán', 2, 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a14', NOW());

-- 4. STUDENTS
INSERT INTO students (user_id, student_code, class_id, department_id, gpa, created_at) VALUES
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a15', '111111', 1, 1, 3.20, NOW()),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a16', '222222', 1, 1, 3.00, NOW()),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a17', '333333', 2, 1, 2.80, NOW());

-- 5. TEACHERS
INSERT INTO teachers (user_id, teacher_code, department_id, title, created_at) VALUES
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12', 'GV001', 1, 'Thạc sĩ', NOW()),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13', 'GV002', 1, 'Tiến sĩ', NOW()),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a14', 'GV003', 2, 'Thạc sĩ', NOW());

-- 6. EXAM CATEGORIES
INSERT INTO exam_categories (id, name, description, created_at) VALUES
(1, 'Lập trình Java', 'Các bài thi về ngôn ngữ Java, OOP, Spring Boot', NOW()),
(2, 'Cơ sở dữ liệu', 'Các bài thi về SQL, NoSQL, thiết kế CSDL', NOW()),
(3, 'Mạng máy tính', 'Các bài thi về mô hình OSI, TCP/IP', NOW());

-- 7. EXAMS
INSERT INTO exams (title, description, category_id, created_by, start_time, end_time, duration_minutes, status, created_at, updated_at, random) VALUES
('Thi cuối kỳ Java', 'Đề thi 60 phút, 40 câu', 1, 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12', NOW() + INTERVAL '1 day', NOW() + INTERVAL '1 day 2 hours', 60, 'PUBLISHED', NOW(), NOW(), FALSE),
('Thi giữa kỳ CSDL', 'Đề thi 45 phút, 30 câu', 2, 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13', NOW() + INTERVAL '2 days', NOW() + INTERVAL '2 days 2 hours', 45, 'DRAFT', NOW(), NOW(), FALSE),
('Kiểm tra 15p Mạng', '5 câu trắc nghiệm', 3, 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12', NOW() + INTERVAL '3 days', NOW() + INTERVAL '3 days 2 hours', 15, 'PUBLISHED', NOW(), NOW(), TRUE);

-- 8. QUESTIONS
INSERT INTO questions (exam_id, content, type, created_by, created_at, updated_at) VALUES
(1, 'Java là ngôn ngữ lập trình gì?', 'MULTIPLE_CHOICE', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12', NOW(), NOW()), -- ID 1
(1, 'Đa hình (Polymorphism) là một trong 4 tính chất của OOP. Đúng hay Sai?', 'TRUE_FALSE', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12', NOW(), NOW()), -- ID 2
(2, 'Câu lệnh nào dùng để truy vấn dữ liệu từ bảng?', 'MULTIPLE_CHOICE', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13', NOW(), NOW()); -- ID 3

-- 9. QUESTION OPTIONS
INSERT INTO question_options (question_id, content, is_correct, position, created_at) VALUES
-- Câu 1 (ID 1)
(1, 'Ngôn ngữ thông dịch', FALSE, 1, NOW()),
(1, 'Ngôn ngữ biên dịch và thông dịch', TRUE, 2, NOW()),
(1, 'Ngôn ngữ kịch bản', FALSE, 3, NOW()),
-- Câu 2 (ID 2)
(2, 'Đúng', TRUE, 1, NOW()),
(2, 'Sai', FALSE, 2, NOW()),
-- Câu 3 (ID 3)
(3, 'SELECT', TRUE, 1, NOW()),
(3, 'UPDATE', FALSE, 2, NOW()),
(3, 'INSERT', FALSE, 3, NOW()),
(3, 'DELETE', FALSE, 4, NOW());

-- 10. EXAM ATTEMPTS
-- Ghi chú: Trigger `trg_auto_calculate_score` sẽ chạy khi insert exam_answers.
-- Tuy nhiên, để an toàn cho script seed, ta insert giá trị đúng luôn.
INSERT INTO exam_attempts (exam_id, student_id, start_time, end_time, score, submitted, created_at) VALUES
(1, 1, NOW() - INTERVAL '1 hour', NOW() - INTERVAL '30 minutes', 10, TRUE, NOW()),
(1, 2, NOW() - INTERVAL '1 hour', NOW() - INTERVAL '25 minutes', 0, TRUE, NOW()),
(3, 1, NOW() - INTERVAL '2 hours', NULL, 0, FALSE, NOW());

-- 11. EXAM ANSWERS
INSERT INTO exam_answers (attempt_id, question_id, selected_option_id, is_correct, created_at) VALUES
(1, 1, 2, TRUE, NOW()),  -- Đúng
(1, 2, 5, FALSE, NOW()), -- Sai
(2, 1, 1, FALSE, NOW()); -- Sai

-- 12. FEEDBACKS
-- Note: exam_id is derived from question_id:
--   Question 1 → Exam 1 (Thi cuối kỳ Java)
--   Question 2 → Exam 1 (Thi cuối kỳ Java)
--   Question 3 → Exam 2 (Thi giữa kỳ CSDL)
INSERT INTO feedbacks (user_id, exam_id, question_id, content, rating, status, created_at, reviewed_by, reviewed_at, teacher_reply) VALUES
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a15', 1, 2, 'Câu hỏi 2 (True/False) hình như có vấn đề ạ.', 3, 'PENDING', NOW(), NULL, NULL, NULL),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a16', 1, 1, 'Câu 1 nên có thêm giải thích.', 4, 'REVIEWED', NOW(), 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12', NOW(), 'Cảm ơn góp ý, câu hỏi đã được bổ sung giải thích.'),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a15', 2, 3, 'Câu 3 đáp án A là SELECT mới đúng.', 5, 'RESOLVED', NOW(), 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13', NOW(), 'Đã chỉnh đáp án lại cho chính xác.');

-- 13. ANNOUNCEMENTS
INSERT INTO announcements (title, content, author_id, target, target_class_id, target_department_id, created_at, published_at) VALUES
('Thông báo nghỉ lễ 30/4', 'Toàn trường được nghỉ lễ 30/4 và 1/5.', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'ALL', NULL, NULL, NOW(), NOW()),
('Thông báo lịch thi CSDL', 'Lớp K43B-CNTT thi CSDL vào ngày 20/12.', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13', 'CLASS', 2, NULL, NOW(), NOW()),
('Học bổng Doanh nghiệp', 'Thông tin học bổng cho sinh viên khoa CNTT.', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'DEPARTMENT', NULL, 1, NOW(), NOW());

-- 14. FAQS
INSERT INTO faqs (question, answer, created_at) VALUES
('Làm thế nào để đổi mật khẩu?', 'Bạn vui lòng truy cập trang thông tin cá nhân và chọn mục "Đổi mật khẩu".', NOW()),
('Xem điểm thi ở đâu?', 'Bạn có thể xem điểm thi ở mục "Kết quả học tập" hoặc xem chi tiết ở từng bài thi đã làm.', NOW()),
('Nếu quên mật khẩu thì phải làm sao?', 'Vui lòng liên hệ quản trị viên (email: admin@qnu.edu.vn) để được cấp lại mật khẩu.', NOW());

-- 15. LEADERBOARD
INSERT INTO leaderboard (exam_id, student_id, score, rank, generated_at) VALUES
(1, 1, 10, 1, NOW()),
(1, 2, 0, 2, NOW());

-- 16. MEDIA FILES
INSERT INTO media_files (file_name, file_url, mime_type, size_bytes, uploaded_by, related_table, related_id, created_at) VALUES
('avatar_sv1.png', 'https://guchat.vn/wp-content/uploads/2025/04/Avatar-Doi-Cute-2-1.jpg', 'image/png', 102400, 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a15', 'users', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a15', NOW()),
('hinh_minh_hoa_cau_1.jpg', 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRoRWtWLW-17WQA1Entsh3iwNesdYClwiMCyg&s', 'image/jpeg', 204800, 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12', 'questions', '1', NOW()),
('thong_bao_hoc_bong.pdf', 'https://storage.googleapis.com/qnuquiz/announcements/hocbong.pdf', 'application/pdf', 512000, 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'announcements', '3', NOW());