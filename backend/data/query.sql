SELECT 
    e.id AS exam_id,
    e.title AS exam_title,
    e.start_time,
    e.end_time,
    -- Tổng số lượt làm bài (bao gồm chưa nộp)
    COUNT(ea.id) AS total_attempts,
    -- Số lượng sinh viên đã nộp bài (submitted = TRUE)
    COUNT(ea.id) FILTER (WHERE ea.submitted = TRUE) AS total_submitted,
    -- Điểm trung bình (làm tròn 2 chữ số thập phân)
    ROUND(AVG(ea.score) FILTER (WHERE ea.submitted = TRUE), 2) AS avg_score,
    -- Điểm cao nhất và thấp nhất
    MAX(ea.score) FILTER (WHERE ea.submitted = TRUE) AS max_score,
    MIN(ea.score) FILTER (WHERE ea.submitted = TRUE) AS min_score
FROM 
    exams e
LEFT JOIN 
    exam_attempts ea ON e.id = ea.exam_id
WHERE 
    e.created_by = 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12' 
GROUP BY 
    e.id, e.title
ORDER BY 
    e.created_at DESC;






SELECT 
    c.name AS class_name,
    COUNT(DISTINCT s.id) AS student_count,
    ROUND(AVG(ea.score), 2) AS avg_score_per_class
FROM 
    exam_attempts ea
JOIN 
    students s ON ea.student_id = s.id
JOIN 
    classes c ON s.class_id = c.id
WHERE 
    ea.exam_id = 1
    AND ea.submitted = TRUE
GROUP BY 
    c.name
ORDER BY 
    avg_score_per_class DESC;








-- SELECT 
--     e.title,
--     COUNT(ea.id) FILTER (WHERE ea.score >= 9) AS excellent_count, -- Giỏi (>=9)
--     COUNT(ea.id) FILTER (WHERE ea.score >= 7 AND ea.score < 9) AS good_count, -- Khá (7-9)
--     COUNT(ea.id) FILTER (WHERE ea.score >= 5 AND ea.score < 7) AS average_count, -- Trung bình (5-7)
--     COUNT(ea.id) FILTER (WHERE ea.score < 5) AS fail_count -- Trượt (<5)
-- FROM 
--     exams e
-- JOIN 
--     exam_attempts ea ON e.id = ea.exam_id
-- WHERE 
--     e.created_by = 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12' 
--     AND ea.submitted = TRUE
-- GROUP BY 
--     e.id, e.title;

WITH exam_total_points AS (
    SELECT 
        e.id AS exam_id,
        CASE 
            WHEN e.max_questions IS NOT NULL THEN e.max_questions
            ELSE COALESCE(SUM(q.points), 0)
        END AS total_points
    FROM exams e
    LEFT JOIN questions q ON q.exam_id = e.id
    GROUP BY e.id, e.max_questions
)

SELECT 
    e.title,

    COUNT(ea.id) FILTER (
        WHERE (ea.score * 100.0 / etp.total_points) >= 90
    ) AS excellent_count, -- Giỏi

    COUNT(ea.id) FILTER (
        WHERE (ea.score * 100.0 / etp.total_points) >= 70
          AND (ea.score * 100.0 / etp.total_points) < 90
    ) AS good_count, -- Khá

    COUNT(ea.id) FILTER (
        WHERE (ea.score * 100.0 / etp.total_points) >= 50
          AND (ea.score * 100.0 / etp.total_points) < 70
    ) AS average_count, -- Trung bình

    COUNT(ea.id) FILTER (
        WHERE (ea.score * 100.0 / etp.total_points) < 50
    ) AS fail_count -- Trượt

FROM 
    exams e
JOIN 
    exam_attempts ea ON e.id = ea.exam_id
JOIN 
    exam_total_points etp ON etp.exam_id = e.id
WHERE 
    e.created_by = 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12'
    AND ea.submitted = TRUE
GROUP BY 
    e.id, e.title, etp.total_points;





SELECT 
    s.student_code,
    u.full_name,
    c.name AS class_name,
    ea.start_time,
    ea.end_time,
    -- Tính thời gian làm bài (phút)
    EXTRACT(EPOCH FROM (ea.end_time - ea.start_time))/60 AS duration_minutes,
    ea.score,
    ea.submitted
FROM 
    exam_attempts ea
JOIN 
    students s ON ea.student_id = s.id
JOIN 
    users u ON s.user_id = u.id
LEFT JOIN 
    classes c ON s.class_id = c.id
WHERE 
    ea.exam_id = 1
ORDER BY 
    ea.score DESC, ea.end_time ASC; -- Điểm cao nhất xếp trên, nộp sớm xếp trên








SELECT 
    q.content AS question_content,
    COUNT(ans.id) AS total_answers,
    -- Số người trả lời đúng
    COUNT(ans.id) FILTER (WHERE ans.is_correct = TRUE) AS correct_count,
    -- Số người trả lời sai
    COUNT(ans.id) FILTER (WHERE ans.is_correct = FALSE) AS wrong_count,
    -- Tỷ lệ trả lời đúng (%)
    ROUND(
        (COUNT(ans.id) FILTER (WHERE ans.is_correct = TRUE)::DECIMAL / COUNT(ans.id)) * 100, 
        2
    ) AS correct_rate
FROM 
    exam_answers ans
JOIN 
    questions q ON ans.question_id = q.id
WHERE 
    q.exam_id = 1
GROUP BY 
    q.id, q.content
ORDER BY 
    correct_rate ASC; -- Câu sai nhiều nhất lên đầu
