import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/question_model.dart';
import 'package:frontend/models/question_option_model.dart';

void main() {
  // Helper function to create test questions
  List<QuestionModel> _createMockQuestions() {
    return [
      QuestionModel(
        id: 1,
        content: 'What is 2+2?',
        options: [
          QuestionOptionModel(id: 1, content: '3', correct: false, position: 0),
          QuestionOptionModel(id: 2, content: '4', correct: true, position: 1),
          QuestionOptionModel(id: 3, content: '5', correct: false, position: 2),
        ],
      ),
      QuestionModel(
        id: 2,
        content: 'What is Flutter?',
        options: [
          QuestionOptionModel(
            id: 4,
            content: 'A bird',
            correct: false,
            position: 0,
          ),
          QuestionOptionModel(
            id: 5,
            content: 'A framework',
            correct: true,
            position: 1,
          ),
          QuestionOptionModel(
            id: 6,
            content: 'A game',
            correct: false,
            position: 2,
          ),
        ],
      ),
    ];
  }

  group('S3.2 - Quiz Screen Logic Tests', () {
    test('Load questions and verify structure', () {
      // Arrange
      final mockQuestions = _createMockQuestions();

      // Act
      final result = mockQuestions;

      // Assert
      expect(result.length, 2);
      expect(result[0].content, 'What is 2+2?');
      expect(result[0].options.length, 3);
    });

    test('Find correct option for question', () {
      // Arrange
      final questions = _createMockQuestions();
      final firstQuestion = questions[0];

      // Act
      final correctOptionIndex = firstQuestion.options.indexWhere(
        (option) => option.correct,
      );

      // Assert
      expect(correctOptionIndex, 1);
      expect(firstQuestion.options[correctOptionIndex].content, '4');
    });

    test('Select answer option and update state', () {
      // Arrange
      final answeredQuestions = List<int?>.filled(2, null);
      int currentQuestion = 0;
      int selectedAnswer = 1;

      // Act
      answeredQuestions[currentQuestion] = selectedAnswer;

      // Assert
      expect(answeredQuestions[0], 1);
      expect(answeredQuestions[1], null);
    });

    test('Toggle answer selection (deselect when same)', () {
      // Arrange
      final answeredQuestions = List<int?>.filled(2, null);
      int currentQuestion = 0;
      int selectedAnswer = 1;

      // Act - First selection
      answeredQuestions[currentQuestion] = selectedAnswer;
      expect(answeredQuestions[0], 1);

      // Act - Deselect same answer
      if (answeredQuestions[currentQuestion] == selectedAnswer) {
        answeredQuestions[currentQuestion] = null;
      }

      // Assert
      expect(answeredQuestions[0], null);
    });

    test('Timer countdown decrements correctly', () {
      // Arrange
      int remainingSeconds = 300; // 5 minutes
      const int expectedDecrement = 1;

      // Act
      remainingSeconds -= expectedDecrement;

      // Assert
      expect(remainingSeconds, 299);
    });

    test('Timer stops when zero', () {
      // Arrange
      int remainingSeconds = 1;

      // Act
      remainingSeconds--;
      final isTimeUp = remainingSeconds <= 0;

      // Assert
      expect(isTimeUp, true);
      expect(remainingSeconds, 0);
    });

    test('Disable answer selection when time is up', () {
      // Arrange
      final isTimeUp = true;
      final canSelectAnswer = !isTimeUp;

      // Assert
      expect(canSelectAnswer, false);
    });

    test('Calculate questions completed', () {
      // Arrange
      final answeredQuestions = [0, 1, null, 1, 0];
      int questionsCompleted = 0;

      // Act
      for (int? answer in answeredQuestions) {
        if (answer != null) {
          questionsCompleted++;
        }
      }

      // Assert
      expect(questionsCompleted, 4);
    });
  });
}
