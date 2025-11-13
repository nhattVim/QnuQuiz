import 'package:flutter/material.dart';
import 'widgets/quiz_header.dart';
import 'widgets/quiz_progress.dart';
import 'widgets/quiz_question.dart';
import 'widgets/quiz_answer_options.dart';
import 'widgets/quiz_completion_dialog.dart';
import 'quiz_result_screen.dart';

class QuizScreen extends StatefulWidget {
  final String quizTitle;
  final int totalQuestions;

  const QuizScreen({
    super.key,
    this.quizTitle = 'Quiz',
    this.totalQuestions = 50,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestionIndex = 0;
  int selectedAnswerIndex = -1;
  int correctAnswers = 0;
  late List<int?> answeredQuestions; // Track đáp án đã chọn cho mỗi câu

  // Sample quiz data
  final Map<String, dynamic> singleQuestion = {
    'question':
        'Trong thủ tục nhập học đại học, giấy tờ nào sau đây thường được yêu cầu là bắt buộc bao gồm chứng chỉ để hoàn thành học?',
    'answers': [
      'Giấy chứng nhận tham gia hoạt động tình nguyện của cấp xã',
      'Giấy báo trúng tuyển đại học',
      'Số hộ khẩu của hàng xóm',
      'Thẻ thư viện trường cấp 3',
    ],
    'correctAnswerIndex': 1,
  };

  late final List<Map<String, dynamic>> quizData = List.generate(
    10,
    (index) => {
      ...singleQuestion, // sao chép dữ liệu gốc
      'questionNumber': index + 1, // thêm số thứ tự câu hỏi
    },
  );

  @override
  void initState() {
    super.initState();
    answeredQuestions = List<int?>.filled(quizData.length, null);
  }

  void _selectAnswer(int index) {
    setState(() {
      if (selectedAnswerIndex == index) {
        // Nếu bấm cùng đáp án → bỏ chọn
        selectedAnswerIndex = -1;
        answeredQuestions[currentQuestionIndex] = null;
      } else {
        // Bấm đáp án khác → đổi lựa chọn
        selectedAnswerIndex = index;
        answeredQuestions[currentQuestionIndex] = index;
      }
    });
  }

  bool _areAllQuestionsAnswered() {
    return answeredQuestions.every((answer) => answer != null);
  }

  void _nextQuestion() {
    if (currentQuestionIndex < quizData.length - 1) {
      // Kiểm tra đáp án trước khi qua câu tiếp theo
      if (selectedAnswerIndex ==
          quizData[currentQuestionIndex]['correctAnswerIndex']) {
        correctAnswers++;
      }

      setState(() {
        currentQuestionIndex++;
        selectedAnswerIndex = answeredQuestions[currentQuestionIndex] ?? -1;
      });
    } else {
      // Kiểm tra đáp án câu cuối cùng
      if (selectedAnswerIndex ==
          quizData[currentQuestionIndex]['correctAnswerIndex']) {
        correctAnswers++;
      }

      // Kiểm tra xem đã trả lời hết tất cả câu chưa
      if (_areAllQuestionsAnswered()) {
        _showResultScreen();
      } else {
        _showIncompleteWarning();
      }
    }
  }

  void _handleCompleteQuiz() {
    // Tính điểm từ tất cả câu đã trả lời
    correctAnswers = 0;
    for (int i = 0; i < quizData.length; i++) {
      if (answeredQuestions[i] == quizData[i]['correctAnswerIndex']) {
        correctAnswers++;
      }
    }

    // Kiểm tra xem đã trả lời hết tất cả câu chưa
    if (_areAllQuestionsAnswered()) {
      _showResultScreen();
    } else {
      _showIncompleteWarning();
    }
  }

  void _showIncompleteWarning() {
    final unansweredCount = answeredQuestions.where((a) => a == null).length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chưa hoàn thành'),
        content: Text(
          'Bạn còn $unansweredCount câu chưa trả lời.\n\nBạn muốn nộp bài ngay hay tiếp tục chọn đáp án?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tiếp tục chọn'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showResultScreen();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Nộp bài'),
          ),
        ],
      ),
    );
  }

  void _showResultScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QuizResultScreen(
          totalQuestions: quizData.length,
          correctAnswers: correctAnswers,
          quizData: quizData,
          answeredQuestions: answeredQuestions,
          onBackHome: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _showPauseDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => QuizCompletionDialog(
        totalQuestions: quizData.length,
        correctAnswers: correctAnswers,
        onExit: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
        onContinue: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = quizData[currentQuestionIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: QuizHeader(
          currentQuestion: currentQuestionIndex + 1,
          totalQuestions: quizData.length,
          onBackPressed: _showPauseDialog,
          answeredQuestions: answeredQuestions,
          onQuestionSelected: (index) {
            setState(() {
              currentQuestionIndex = index;
              selectedAnswerIndex = answeredQuestions[index] ?? -1;
            });
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Progress
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: QuizProgress(
                  currentQuestion: currentQuestionIndex + 1,
                  totalQuestions: quizData.length,
                ),
              ),

              const SizedBox(height: 16),

              // Question
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: QuizQuestion(
                  questionText: currentQuestion['question'],
                  imageUrl: null,
                ),
              ),

              const SizedBox(height: 16),

              // Answer Options
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: QuizAnswerOptions(
                  answers: List<String>.from(
                    currentQuestion['answers'] as List,
                  ),
                  selectedAnswerIndex: selectedAnswerIndex,
                  correctAnswerIndex:
                      currentQuestion['correctAnswerIndex'] as int,
                  answered: false,
                  onSelectAnswer: _selectAnswer,
                ),
              ),

              const SizedBox(height: 16),

              // Next Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: selectedAnswerIndex != -1
                        ? () {
                            if (_areAllQuestionsAnswered()) {
                              // Tất cả câu đã trả lời → submit ngay
                              _handleCompleteQuiz();
                            } else {
                              // Chưa trả lời hết → tiếp tục
                              _nextQuestion();
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedAnswerIndex != -1
                          ? Colors.blue
                          : Colors.grey.shade300,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      disabledBackgroundColor: Colors.grey.shade300,
                    ),
                    child: Text(
                      _areAllQuestionsAnswered() ? 'Hoàn thành' : 'Tiếp tục',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
