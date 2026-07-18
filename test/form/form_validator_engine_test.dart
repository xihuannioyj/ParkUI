import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/src/form/validators/form_validator.dart';
import 'package:park_ui/src/form/validators/form_validator_result.dart';
import 'package:park_ui/src/form/models/form_field_schema.dart';

ParkFormFieldSchema _createField({
  String labelName = 'Field',
  bool isRequired = false,
  int? minLength,
  int? maxLength,
  int fieldLength = 0,
  String? regexExpression,
  String? validatorMessage,
}) {
  return ParkFormFieldSchema(
    fieldId: 'test',
    fieldType: ParkFieldType.text,
    labelName: labelName,
    fieldName: 'test_field',
    isRequired: isRequired,
    minLength: minLength,
    maxLength: maxLength,
    fieldLength: fieldLength,
    regexExpression: regexExpression,
    validatorMessage: validatorMessage,
    fieldPrompt: '',
    defaultValue: null,
    isReadonly: false,
    hidden: false,
    dataSourceType: ParkDataSourceType.none,
    dataSourceParams: const {},
    options: const [],
    optionLabelKey: 'label',
    optionValueKey: 'value',
  );
}

void main() {
  late ParkFormFieldSchema field;

  group('ParkFormValidators.required', () {
    test('passes when field is not required', () {
      field = _createField(isRequired: false);
      final result = ParkFormValidators.required(null, field);
      expect(result.isValid, isTrue);
    });

    test('fails when required field is null', () {
      field = _createField(isRequired: true, labelName: 'Name');
      final result = ParkFormValidators.required(null, field);
      expect(result.isValid, isFalse);
      expect(result.message, contains('Name'));
    });

    test('fails when required field is empty string', () {
      field = _createField(isRequired: true, labelName: 'Email');
      final result = ParkFormValidators.required('', field);
      expect(result.isValid, isFalse);
      expect(result.message, contains('Email'));
    });

    test('fails when required field is whitespace only', () {
      field = _createField(isRequired: true);
      final result = ParkFormValidators.required('   ', field);
      expect(result.isValid, isFalse);
    });

    test('passes when required field has value', () {
      field = _createField(isRequired: true);
      final result = ParkFormValidators.required('test value', field);
      expect(result.isValid, isTrue);
    });

    test('fails when required list is empty', () {
      field = _createField(isRequired: true);
      final result = ParkFormValidators.required(<dynamic>[], field);
      expect(result.isValid, isFalse);
    });

    test('passes when required list has items', () {
      field = _createField(isRequired: true);
      final result = ParkFormValidators.required([1, 2, 3], field);
      expect(result.isValid, isTrue);
    });

    test('uses custom validator message', () {
      field = _createField(
        isRequired: true,
        validatorMessage: 'Custom error message',
      );
      final result = ParkFormValidators.required(null, field);
      expect(result.isValid, isFalse);
      expect(result.message, 'Custom error message');
    });
  });

  group('ParkFormValidators.length', () {
    test('passes when value is null', () {
      field = _createField(minLength: 5);
      final result = ParkFormValidators.length(null, field);
      expect(result.isValid, isTrue);
    });

    test('passes when value is empty string', () {
      field = _createField(minLength: 5);
      final result = ParkFormValidators.length('', field);
      expect(result.isValid, isTrue);
    });

    test('fails when value is shorter than minLength', () {
      field = _createField(labelName: 'Password', minLength: 8);
      final result = ParkFormValidators.length('123', field);
      expect(result.isValid, isFalse);
      expect(result.message, contains('Password'));
      expect(result.message, contains('8'));
    });

    test('passes when value meets minLength', () {
      field = _createField(minLength: 5);
      final result = ParkFormValidators.length('12345', field);
      expect(result.isValid, isTrue);
    });

    test('fails when value exceeds maxLength', () {
      field = _createField(labelName: 'Username', maxLength: 10);
      final result = ParkFormValidators.length('12345678901', field);
      expect(result.isValid, isFalse);
      expect(result.message, contains('Username'));
      expect(result.message, contains('10'));
    });

    test('passes when value is within maxLength', () {
      field = _createField(maxLength: 10);
      final result = ParkFormValidators.length('12345', field);
      expect(result.isValid, isTrue);
    });

    test('fieldLength acts as maxLength', () {
      field = _createField(fieldLength: 5);
      final result = ParkFormValidators.length('123456', field);
      expect(result.isValid, isFalse);
    });

    test('passes when value length is exactly at boundaries', () {
      field = _createField(minLength: 3, maxLength: 5);
      expect(ParkFormValidators.length('123', field).isValid, isTrue);
      expect(ParkFormValidators.length('12345', field).isValid, isTrue);
    });
  });

  group('ParkFormValidators.regex', () {
    test('passes when no regex pattern is set', () {
      field = _createField();
      final result = ParkFormValidators.regex('any value', field);
      expect(result.isValid, isTrue);
    });

    test('passes when value is null', () {
      field = _createField(regexExpression: r'^\d+$');
      final result = ParkFormValidators.regex(null, field);
      expect(result.isValid, isTrue);
    });

    test('passes when value is empty string', () {
      field = _createField(regexExpression: r'^\d+$');
      final result = ParkFormValidators.regex('', field);
      expect(result.isValid, isTrue);
    });

    test('passes when value matches regex', () {
      field = _createField(regexExpression: r'^\d+$');
      final result = ParkFormValidators.regex('12345', field);
      expect(result.isValid, isTrue);
    });

    test('fails when value does not match regex', () {
      field = _createField(labelName: 'Code', regexExpression: r'^\d+$');
      final result = ParkFormValidators.regex('abc', field);
      expect(result.isValid, isFalse);
      expect(result.message, contains('Code'));
    });

    test('email regex validation', () {
      field = _createField(regexExpression: r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      expect(ParkFormValidators.regex('test@example.com', field).isValid, isTrue);
      expect(ParkFormValidators.regex('invalid-email', field).isValid, isFalse);
    });

    test('phone regex validation', () {
      field = _createField(regexExpression: r'^1[3-9]\d{9}$');
      expect(ParkFormValidators.regex('13800138000', field).isValid, isTrue);
      expect(ParkFormValidators.regex('12345678901', field).isValid, isFalse);
    });

    test('url regex validation', () {
      field = _createField(regexExpression: r'^https?://');
      expect(ParkFormValidators.regex('https://example.com', field).isValid, isTrue);
      expect(ParkFormValidators.regex('ftp://example.com', field).isValid, isFalse);
    });

    test('uses custom validator message', () {
      field = _createField(
        regexExpression: r'^\d+$',
        validatorMessage: 'Only numbers allowed',
      );
      final result = ParkFormValidators.regex('abc', field);
      expect(result.isValid, isFalse);
      expect(result.message, 'Only numbers allowed');
    });

    test('handles invalid regex gracefully', () {
      field = _createField(regexExpression: r'[invalid(');
      final result = ParkFormValidators.regex('test', field);
      expect(result.isValid, isFalse);
      expect(result.message, contains('格式校验规则无效'));
    });
  });

  group('FormValidatorResult', () {
    test('success result is valid', () {
      final result = FormValidatorResult.success();
      expect(result.isValid, isTrue);
      expect(result.message, isNull);
    });

    test('error result is invalid', () {
      final result = FormValidatorResult.error('Error message');
      expect(result.isValid, isFalse);
      expect(result.message, 'Error message');
    });
  });
}
