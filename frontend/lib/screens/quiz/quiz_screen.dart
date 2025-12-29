import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/exam_result_model.dart';
import 'package:frontend/models/question_model.dart';
import 'package:frontend/providers/service_providers.dart'; // Import service providers
import 'package:shared_preferences/shared_preferences.dart';

import 'quiz_result_screen.dart';
import 'widgets/quiz_answer_options.dart';
import 'widgets/quiz_completion_dialog.dart';
import 'widgets/quiz_header.dart';
import 'widgets/quiz_progress.dart';
import 'widgets/quiz_question.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final String examTitle;
  final int totalQuestions;
  final int examId;
  final int attemptId;
  final int? durationMinutes;

  const QuizScreen({
    super.key,
    required this.examTitle,
    this.totalQuestions = 50,
    required this.examId,
    required this.attemptId,
    required this.durationMinutes,
  });

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int currentQuestionIndex = 0;
  int selectedAnswerIndex = -1;
  int questionsCompleted = 0;
  late List<int?> answeredQuestions;

  // Timer variables
  late Timer _timer;
  int _remainingSeconds = 0;
  bool _isTimeUp = false;
  bool _isTimerRunning = false;

  late Future<List<QuestionModel>> _quizDataFuture;
  List<QuestionModel> quizData = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                'Lỗi: $errorMessage',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      );
    }

    if (quizData.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(child: Text('Không có câu hỏi')),
      );
    }

    final currentQuestion = quizData[currentQuestionIndex];
    final options = currentQuestion.options;
    final correctOptionIndex = options != null && options.isNotEmpty
        ? options.indexWhere((option) => option.correct)
        : -1;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: QuizHeader(
          currentQuestion: currentQuestionIndex + 1,
          totalQuestions: quizData.length,
          onBackPressed: _showPauseDialog,
          answeredQuestions: answeredQuestions,
          durationMinutes: widget.durationMinutes,
          remainingSeconds: _remainingSeconds,
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

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: QuizQuestion(
                  questionText: currentQuestion.content ?? '',
                  imageUrl: currentQuestion.mediaUrl,
                  mediaFiles: currentQuestion.mediaFiles,
                ),
              ),

              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: options != null && options.isNotEmpty
                    ? QuizAnswerOptions(
                        answers: options.map((o) => o.content).toList(),
                        selectedAnswerIndex: selectedAnswerIndex,
                        correctAnswerIndex: correctOptionIndex,
                        answered: false,
                        onSelectAnswer: _selectAnswer,
                      )
                    : const Center(
                        child: Text('Không có đáp án cho câu hỏi này'),
                      ),
              ),

              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: (!_isTimeUp && selectedAnswerIndex != -1)
                        ? () {
                            if (_areAllQuestionsAnswered()) {
                              _handleCompleteQuiz();
                            } else {
                              _nextQuestion();
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: (!_isTimeUp && selectedAnswerIndex != -1)
                          ? Colors.blue
                          : Colors.grey.shade300,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      disabledBackgroundColor: Colors.grey.shade300,
                    ),
                    child: Text(
                      _isTimeUp
                          ? 'Hết thời gian'
                          : (_areAllQuestionsAnswered()
                                ? 'Hoàn thành'
                                : 'Tiếp tục'),
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

  @override
  void dispose() {
    if (_isTimerRunning) {
      _timer.cancel();
    }
    _saveQuizState();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _quizDataFuture = ref
        .read(examServiceProvider)
        .getQuestionByExam(widget.examId);

    _loadQuizData().then((_) {
      if (quizData.isNotEmpty) {
        _loadQuizState();
      }
    });

    _startTimer();
  }

  bool _areAllQuestionsAnswered() {
    return answeredQuestions.every((answer) => answer != null);
  }

  Future<void> _autoSubmitExam() async {
    setState(() => isLoading = true);

    try {
      final examResult = await _submitAndFinishExam();
      if (!mounted) return;
      _showResultScreen(examResult);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi nộp bài: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _handleCompleteQuiz() async {
    if (!_areAllQuestionsAnswered()) {
      _showIncompleteWarning();
      return;
    }

    setState(() => isLoading = true);

    try {
      await _submitAllAnswers();

      final examResult = await ref
          .read(examServiceProvider)
          .finishExam(widget.attemptId);

      if (!mounted) return;
      _showResultScreen(examResult);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi nộp bài: $e')));
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _loadQuizData() async {
    try {
      final data = await _quizDataFuture;
      if (!mounted) return;
      setState(() {
        quizData = data;
        answeredQuestions = List<int?>.filled(quizData.length, null);
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  Future<void> _loadQuizState() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'quiz_state_${widget.attemptId}';

    final savedAnswers = prefs.getStringList('${key}_answeredQuestions');

    setState(() {
      currentQuestionIndex = prefs.getInt('${key}_currentQuestionIndex') ?? 0;

      // Load remaining seconds từ SharedPreferences
      // Nếu không có hoặc = 0, dùng thời gian mặc định từ exam
      final savedRemainingSeconds = prefs.getInt('${key}_remainingSeconds');
      if (savedRemainingSeconds != null && savedRemainingSeconds > 0) {
        _remainingSeconds = savedRemainingSeconds;
      } else if (widget.durationMinutes != null &&
          widget.durationMinutes! > 0) {
        _remainingSeconds = widget.durationMinutes! * 60;
      } else {
        _remainingSeconds = 0; // Không giới hạn thời gian
      }

      if (savedAnswers != null) {
        answeredQuestions = savedAnswers
            .map((e) => e.isNotEmpty ? int.parse(e) : null)
            .toList();

        if (answeredQuestions.length != quizData.length) {
          answeredQuestions = List<int?>.filled(quizData.length, null);
        }
      } else {
        answeredQuestions = List<int?>.filled(quizData.length, null);
      }

      if (currentQuestionIndex >= quizData.length) {
        currentQuestionIndex = 0;
      }

      selectedAnswerIndex = answeredQuestions[currentQuestionIndex] ?? -1;
    });
  }

  void _nextQuestion() {
    if (currentQuestionIndex < quizData.length - 1) {
      if (selectedAnswerIndex != -1) {
        questionsCompleted++;
      }

      setState(() {
        currentQuestionIndex++;
        selectedAnswerIndex = answeredQuestions[currentQuestionIndex] ?? -1;
      });
    } else {
      if (selectedAnswerIndex != -1) {
        questionsCompleted++;
      }

      if (!_areAllQuestionsAnswered()) {
        _showIncompleteWarning();
        return;
      }
    }
  }

  Future<void> _saveQuizState() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'quiz_state_${widget.attemptId}';
    await prefs.setInt('${key}_currentQuestionIndex', currentQuestionIndex);
    await prefs.setInt('${key}_remainingSeconds', _remainingSeconds);
    await prefs.setStringList(
      '${key}_answeredQuestions',
      answeredQuestions.map((e) => e?.toString() ?? '').toList(),
    );
  }

  void _selectAnswer(int index) {
    if (_isTimeUp) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thời gian đã hết, không thể chọn đáp án'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      if (selectedAnswerIndex == index) {
        selectedAnswerIndex = -1;
        answeredQuestions[currentQuestionIndex] = null;
      } else {
        selectedAnswerIndex = index;
        answeredQuestions[currentQuestionIndex] = index;
      }
    });
  }

  void _showIncompleteWarning() {
    final unansweredCount = answeredQuestions.where((a) => a == null).length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chưa hoàn thành'),
        content: Text(
          'Bạn còn $unansweredCount câu chưa trả lời.\n\n'
          'Bạn muốn nộp bài ngay hay tiếp tục chọn đáp án?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tiếp tục chọn'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => isLoading = true);

              try {
                final examResult = await _submitAndFinishExam();

                if (!context.mounted) return;
                _showResultScreen(examResult);
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Lỗi khi nộp bài: $e')));
              } finally {
                if (mounted) {
                  setState(() => isLoading = false);
                }
              }
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

  void _showPauseDialog() {
    if (_isTimerRunning) {
      _timer.cancel();
      _isTimerRunning = false;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => QuizCompletionDialog(
        totalQuestions: quizData.length,
        questionsCompleted: questionsCompleted,
        onExit: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
        onContinue: () {
          Navigator.pop(context);
          _startTimer();
        },
      ),
    );
  }

  void _showResultScreen(ExamResultModel examResult) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QuizResultScreen(
          totalQuestions: quizData.length,
          result: examResult,
          attemptId: widget.attemptId,
          examTitle: widget.examTitle,
          examId: widget.examId,
          onBackHome: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _showTimeUpDialog() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _isTimeUp) {
        Navigator.of(context, rootNavigator: true).pop();
        _autoSubmitExam();
      }
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Hết thời gian'),
        content: const Text(
          'Thời gian làm bài của bạn đã hết.\n'
          'Bài thi sẽ được nộp tự động trong 5 giây.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              _autoSubmitExam();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Nộp bài ngay'),
          ),
        ],
      ),
    );
  }

  void _startTimer() {
    if (widget.durationMinutes == null || widget.durationMinutes == 0) {
      return;
    }

    if (_isTimerRunning) {
      return;
    }

    if (_remainingSeconds == 0) {
      _remainingSeconds = widget.durationMinutes! * 60;
    }

    _isTimerRunning = true;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
          } else {
            _remainingSeconds = 0;
            _isTimeUp = true;
            _isTimerRunning = false;
            timer.cancel();
            _showTimeUpDialog();
          }
        });
      }
    });
  }

  Future<void> _submitAllAnswers() async {
    final examService = ref.read(
      examServiceProvider,
    ); // Get service from provider
    for (int i = 0; i < quizData.length; i++) {
      final question = quizData[i];
      final selectedIndex = answeredQuestions[i];

      if (selectedIndex == null) continue;

      if (question.options == null || question.options!.isEmpty) {
        continue;
      }

      if (selectedIndex < 0 || selectedIndex >= question.options!.length) {
        continue;
      }

      final selectedOption = question.options![selectedIndex];
      final optionId = selectedOption.id;
      if (optionId == null) continue;

      if (question.id == null) continue;

      await examService.submitAnswer(
        attemptId: widget.attemptId,
        questionId: question.id!,
        optionId: optionId,
      );
    }
  }

  Future<ExamResultModel> _submitAndFinishExam() async {
    await _submitAllAnswers();

    return await ref.read(examServiceProvider).finishExam(widget.attemptId);
  }
}
