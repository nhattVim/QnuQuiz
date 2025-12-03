-- =============================================
-- DATA SEED FOR H2 DATABASE
-- Logic: Mỗi câu đúng = 10 điểm (INTEGER)
-- =============================================

-- 1. USERS
INSERT INTO users (id, username, password_hash, full_name, email, role, status, created_at, updated_at, avatar_url) VALUES
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'admin', '$2a$10$fsxxNTnoL9KZZhqleSuk5uWO0UUCLKjAkZ4cDLYbD4ljXZkxCS4Ki', 'Quản trị viên', 'admin@qnu.edu.vn', 'ADMIN', 'ACTIVE', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12', 'teacher1', '$2a$10$fsxxNTnoL9KZZhqleSuk5uWO0UUCLKjAkZ4cDLYbD4ljXZkxCS4Ki', 'Nguyễn Văn An (GV)', 'gv.an@qnu.edu.vn', 'TEACHER', 'ACTIVE', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'https://heucollege.edu.vn/upload/2025/02/hinh-dai-dien-anime-nu-10.webp'),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13', 'teacher2', '$2a$10$fsxxNTnoL9KZZhqleSuk5uWO0UUCLKjAkZ4cDLYbD4ljXZkxCS4Ki', 'Trần Thị Bình (GV)', 'gv.binh@qnu.edu.vn', 'TEACHER', 'ACTIVE', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'https://cdn-media.sforum.vn/storage/app/media/THANHAN/avartar-anime-91.jpg'),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a14', 'teacher3', '$2a$10$fsxxNTnoL9KZZhqleSuk5uWO0UUCLKjAkZ4cDLYbD4ljXZkxCS4Ki', 'Lê Văn Cường (GV)', 'gv.cuong@qnu.edu.vn', 'TEACHER', 'INACTIVE', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'https://jbagy.me/wp-content/uploads/2025/03/Hinh-anh-anime-dang-yeu-khong-the-cuong-duoc-3.jpg'),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a15', 'student1', '$2a$10$fsxxNTnoL9KZZhqleSuk5uWO0UUCLKjAkZ4cDLYbD4ljXZkxCS4Ki', 'Phạm Thị Dung (SV)', 'sv.dung@qnu.edu.vn', 'STUDENT', 'ACTIVE', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'https://cellphones.com.vn/sforum/wp-content/uploads/2024/01/avartar-anime-6.jpg'),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a16', 'student2', '$2a$10$fsxxNTnoL9KZZhqleSuk5uWO0UUCLKjAkZ4cDLYbD4ljXZkxCS4Ki', 'Hoàng Văn Em (SV)', 'sv.em@qnu.edu.vn', 'STUDENT', 'ACTIVE', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'https://jbagy.me/wp-content/uploads/2025/03/Hinh-anh-avatar-anime-nu-cute-1.jpg'),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a17', 'student3', '$2a$10$fsxxNTnoL9KZZhqleSuk5uWO0UUCLKjAkZ4cDLYbD4ljXZkxCS4Ki', 'Vũ Thị Hà (SV)', 'sv.ha@qnu.edu.vn', 'STUDENT', 'ACTIVE', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'https://jbagy.me/wp-content/uploads/2025/03/Hinh-anh-anime-dang-yeu-khong-the-cuong-duoc-2.jpg');

-- 2. DEPARTMENTS
INSERT INTO departments (name, description, created_at) VALUES
('Khoa Công nghệ Thông tin', 'Đào tạo kỹ sư CNTT và các ngành liên quan', CURRENT_TIMESTAMP),
('Khoa Kinh tế & Kế toán', 'Đào tạo cử nhân kinh tế, kế toán, tài chính', CURRENT_TIMESTAMP),
('Khoa Ngoại ngữ', 'Đào tạo cử nhân ngôn ngữ Anh, Nhật, Trung', CURRENT_TIMESTAMP);

-- 3. CLASSES
INSERT INTO classes (name, department_id, advisor_teacher_id, created_at) VALUES
('K43A - CNTT', 1, 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12', CURRENT_TIMESTAMP),
('K43B - CNTT', 1, 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13', CURRENT_TIMESTAMP),
('K43A - Kế toán', 2, 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a14', CURRENT_TIMESTAMP);

-- 4. STUDENTS
INSERT INTO students (user_id, student_code, class_id, department_id, gpa, created_at) VALUES
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a15', '111111', 1, 1, 3.20, CURRENT_TIMESTAMP),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a16', '222222', 1, 1, 3.00, CURRENT_TIMESTAMP),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a17', '333333', 2, 1, 2.80, CURRENT_TIMESTAMP);

-- 5. TEACHERS
INSERT INTO teachers (user_id, teacher_code, department_id, title, created_at) VALUES
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12', 'GV001', 1, 'Thạc sĩ', CURRENT_TIMESTAMP),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13', 'GV002', 1, 'Tiến sĩ', CURRENT_TIMESTAMP),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a14', 'GV003', 2, 'Thạc sĩ', CURRENT_TIMESTAMP);

-- 6. EXAM CATEGORIES
INSERT INTO exam_categories (id, name, description, created_at) VALUES
(1, 'Lập trình Java', 'Các bài thi về ngôn ngữ Java, OOP, Spring Boot', CURRENT_TIMESTAMP),
(2, 'Cơ sở dữ liệu', 'Các bài thi về SQL, NoSQL, thiết kế CSDL', CURRENT_TIMESTAMP),
(3, 'Mạng máy tính', 'Các bài thi về mô hình OSI, TCP/IP', CURRENT_TIMESTAMP);

-- 7. EXAMS
INSERT INTO exams (title, description, category_id, created_by, start_time, end_time, duration_minutes, status, created_at, updated_at, random) VALUES
('Thi cuối kỳ Java', 'Đề thi 60 phút, 40 câu', 1, 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12', DATEADD('DAY', 1, NOW()), DATEADD('HOUR', 2, DATEADD('DAY', 1, NOW())), 60, 'PUBLISHED', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
('Thi giữa kỳ CSDL', 'Đề thi 45 phút, 30 câu', 2, 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13', DATEADD('DAY', 2, NOW()), DATEADD('HOUR', 2, DATEADD('DAY', 2, NOW())), 45, 'DRAFT', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE),
('Kiểm tra 15p Mạng', '5 câu trắc nghiệm', 3, 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12', DATEADD('DAY', 3, NOW()), DATEADD('HOUR', 2, DATEADD('DAY', 3, NOW())), 15, 'PUBLISHED', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, TRUE);

-- 8. QUESTIONS
INSERT INTO questions (exam_id, content, type, created_by, created_at, updated_at) VALUES
(1, 'Java là ngôn ngữ lập trình gì?', 'MULTIPLE_CHOICE', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP), -- ID 1
(1, 'Đa hình (Polymorphism) là một trong 4 tính chất của OOP. Đúng hay Sai?', 'TRUE_FALSE', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP), -- ID 2
(2, 'Câu lệnh nào dùng để truy vấn dữ liệu từ bảng?', 'MULTIPLE_CHOICE', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP); -- ID 3

-- 9. QUESTION OPTIONS
INSERT INTO question_options (question_id, content, is_correct, position, created_at) VALUES
-- Câu 1 (ID 1)
(1, 'Ngôn ngữ thông dịch', FALSE, 1, CURRENT_TIMESTAMP),
(1, 'Ngôn ngữ biên dịch và thông dịch', TRUE, 2, CURRENT_TIMESTAMP),
(1, 'Ngôn ngữ kịch bản', FALSE, 3, CURRENT_TIMESTAMP),
-- Câu 2 (ID 2)
(2, 'Đúng', TRUE, 1, CURRENT_TIMESTAMP),
(2, 'Sai', FALSE, 2, CURRENT_TIMESTAMP),
-- Câu 3 (ID 3)
(3, 'SELECT', TRUE, 1, CURRENT_TIMESTAMP),
(3, 'UPDATE', FALSE, 2, CURRENT_TIMESTAMP),
(3, 'INSERT', FALSE, 3, CURRENT_TIMESTAMP),
(3, 'DELETE', FALSE, 4, CURRENT_TIMESTAMP);

-- 10. EXAM ATTEMPTS
-- Lưu ý: SCORE là INTEGER.
-- SV1 làm bài 1: Đúng 1 câu (Câu 1) = 10 điểm.
-- SV2 làm bài 1: Sai hết = 0 điểm (Giả lập).
INSERT INTO exam_attempts (exam_id, student_id, start_time, end_time, score, submitted, created_at) VALUES
(1, 1, DATEADD('HOUR', -1, NOW()), DATEADD('MINUTE', -30, NOW()), 10, TRUE, CURRENT_TIMESTAMP),
(1, 2, DATEADD('HOUR', -1, NOW()), DATEADD('MINUTE', -25, NOW()), 0, TRUE, CURRENT_TIMESTAMP),
(3, 1, DATEADD('HOUR', -2, NOW()), NULL, 0, FALSE, CURRENT_TIMESTAMP);

-- 11. EXAM ANSWERS
-- SV1 (Attempt 1): Câu 1 đúng, Câu 2 sai.
-- SV2 (Attempt 2): Câu 1 sai.
INSERT INTO exam_answers (attempt_id, question_id, selected_option_id, is_correct, created_at) VALUES
(1, 1, 2, TRUE, CURRENT_TIMESTAMP),  -- Đúng
(1, 2, 5, FALSE, CURRENT_TIMESTAMP), -- Sai (Chọn sai)
(2, 1, 1, FALSE, CURRENT_TIMESTAMP); -- Sai (Chọn ngôn ngữ thông dịch)

-- 12. FEEDBACKS
INSERT INTO feedbacks (user_id, question_id, content, rating, status, created_at, reviewed_by, reviewed_at, teacher_reply) VALUES
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a15', 2, 'Câu hỏi 2 (True/False) hình như có vấn đề ạ.', 3, 'PENDING', CURRENT_TIMESTAMP, NULL, NULL, NULL),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a16', 1, 'Câu 1 nên có thêm giải thích.', 4, 'REVIEWED', CURRENT_TIMESTAMP, 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12', NOW(), 'Cảm ơn góp ý, câu hỏi đã được bổ sung giải thích.'),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a15', 3, 'Câu 3 đáp án A là SELECT mới đúng.', 5, 'RESOLVED', CURRENT_TIMESTAMP, 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13', NOW(), 'Đã chỉnh đáp án lại cho chính xác.');

-- 13. ANNOUNCEMENTS
INSERT INTO announcements (title, content, author_id, target, target_class_id, target_department_id, created_at, published_at) VALUES
('Thông báo nghỉ lễ 30/4', 'Toàn trường được nghỉ lễ 30/4 và 1/5.', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'ALL', NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('Thông báo lịch thi CSDL', 'Lớp K43B-CNTT thi CSDL vào ngày 20/12.', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13', 'CLASS', 2, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('Học bổng Doanh nghiệp', 'Thông tin học bổng cho sinh viên khoa CNTT.', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'DEPARTMENT', NULL, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- 14. FAQS
INSERT INTO faqs (question, answer, created_at) VALUES
('Làm thế nào để đổi mật khẩu?', 'Bạn vui lòng truy cập trang thông tin cá nhân và chọn mục "Đổi mật khẩu".', CURRENT_TIMESTAMP),
('Xem điểm thi ở đâu?', 'Bạn có thể xem điểm thi ở mục "Kết quả học tập" hoặc xem chi tiết ở từng bài thi đã làm.', CURRENT_TIMESTAMP),
('Nếu quên mật khẩu thì phải làm sao?', 'Vui lòng liên hệ quản trị viên (email: admin@qnu.edu.vn) để được cấp lại mật khẩu.', CURRENT_TIMESTAMP);

-- 15. LEADERBOARD
INSERT INTO leaderboard (exam_id, student_id, score, rank, generated_at) VALUES
(1, 1, 10, 1, CURRENT_TIMESTAMP),
(1, 2, 0, 2, CURRENT_TIMESTAMP);

-- 16. MEDIA FILES
INSERT INTO media_files (file_name, file_url, mime_type, size_bytes, uploaded_by, related_table, related_id, created_at) VALUES
('avatar_sv1.png', 'https://guchat.vn/wp-content/uploads/2025/04/Avatar-Doi-Cute-2-1.jpg', 'image/png', 102400, 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a15', 'users', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a15', CURRENT_TIMESTAMP),
('hinh_minh_hoa_cau_1.jpg', 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRoRWtWLW-17WQA1Entsh3iwNesdYClwiMCyg&s', 'image/jpeg', 204800, 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12', 'questions', '1', CURRENT_TIMESTAMP),
('thong_bao_hoc_bong.pdf', 'https://storage.googleapis.com/qnuquiz/announcements/hocbong.pdf', 'application/pdf', 512000, 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'announcements', '3', CURRENT_TIMESTAMP);