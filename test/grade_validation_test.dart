import 'package:flutter_test/flutter_test.dart';
import 'package:oxschool/core/reusable_methods/academic_functions.dart';

void main() {
  group('Grade Validation Tests', () {
    test(
        'validateNewGradeValue - Calif column - value less than 50 should return 50',
        () {
      expect(validateNewGradeValue(30, 'Calif'), 50);
      expect(validateNewGradeValue(0, 'Calif'), 50);
      expect(validateNewGradeValue(49, 'Calif'), 50);
    });

    test(
        'validateNewGradeValue - Calif column - value greater than 100 should return 100',
        () {
      expect(validateNewGradeValue(101, 'Calif'), 100);
      expect(validateNewGradeValue(150, 'Calif'), 100);
      expect(validateNewGradeValue(999, 'Calif'), 100);
    });

    test(
        'validateNewGradeValue - Calif column - value between 50-100 should return same value',
        () {
      expect(validateNewGradeValue(50, 'Calif'), 50);
      expect(validateNewGradeValue(75, 'Calif'), 75);
      expect(validateNewGradeValue(100, 'Calif'), 100);
    });

    test(
        'validateNewGradeValue - Calif column - double values should be converted to int',
        () {
      expect(validateNewGradeValue(75.5, 'Calif'), 75);
      expect(validateNewGradeValue(100.9, 'Calif'), 100);
      expect(validateNewGradeValue(49.9, 'Calif'),
          50); // 49.9 becomes 49, which is < 50, so returns 50
    });

    test(
        'validateNewGradeValue - Calif column - string values should be parsed',
        () {
      expect(validateNewGradeValue('75', 'Calif'), 75);
      expect(validateNewGradeValue('100', 'Calif'), 100);
      expect(validateNewGradeValue('45', 'Calif'), 50);
      expect(validateNewGradeValue('150', 'Calif'), 100);
    });

    test(
        'validateNewGradeValue - Calif column - invalid string should return 50',
        () {
      expect(validateNewGradeValue('abc', 'Calif'), 50);
      expect(validateNewGradeValue('', 'Calif'), 50);
    });

    test(
        'validateNewGradeValue - non-validated columns should return original value',
        () {
      expect(validateNewGradeValue(200, 'Comentarios'), 200);
      expect(validateNewGradeValue(-10, 'SomeOtherColumn'), -10);
    });

    // Additional tests for grades_per_student.dart compatibility
    group('Grades Per Student Validation', () {
      test('validateNewGradeValue - evaluation field works same as Calif', () {
        expect(validateNewGradeValue(30, 'Calif'), 50);
        expect(validateNewGradeValue(150, 'Calif'), 100);
        expect(validateNewGradeValue(75, 'Calif'), 75);
      });

      test('validateNewGradeValue - handles various grade column titles', () {
        expect(validateNewGradeValue(30, 'Conducta'), 50);
        expect(validateNewGradeValue(150, 'Tareas'), 100);
        expect(validateNewGradeValue(75, 'Ausencia'), 75);
      });
    });
  });
}
