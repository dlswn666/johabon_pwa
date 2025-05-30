import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../lib/widgets/common/custom_grid_form.dart';
import '../../../lib/widgets/common/form_field_row.dart';

void main() {
  group('CustomGridForm Widget Tests', () {
    late List<FormFieldConfig> testFields;
    late Map<String, dynamic> testFormValues;
    late Map<String, dynamic> capturedChanges;
    late CustomGridForm widget;

    setUp(() {
      testFields = [
        FormFieldConfig(
          keyName: 'name',
          label: '이름',
          type: FormFieldType.input,
        ),
        FormFieldConfig(
          keyName: 'email',
          label: '이메일',
          type: FormFieldType.input,
        ),
        FormFieldConfig(
          keyName: 'gender',
          label: '성별',
          type: FormFieldType.dropdown,
          options: ['남성', '여성'],
        ),
      ];

      testFormValues = {
        'name': '홍길동',
        'email': 'hong@example.com',
        'gender': '남성',
      };

      capturedChanges = {};

      widget = CustomGridForm(
        fields: testFields,
        columnCount: 2,
        formValues: testFormValues,
        onChanged: (key, value) {
          capturedChanges[key] = value;
        },
      );
    });

    group('기본 렌더링 테스트', () {
      testWidgets('CustomGridForm이 올바른 구조로 렌더링되는지 확인', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 600,
                height: 400,
                child: widget,
              ),
            ),
          ),
        );

        // LayoutBuilder 확인
        expect(find.byType(LayoutBuilder), findsOneWidget);
        
        // Wrap 확인
        expect(find.byType(Wrap), findsOneWidget);
        
        // FormFieldRow 확인 - 3개의 필드
        expect(find.byType(FormFieldRow), findsNWidgets(3));
      });

      testWidgets('필드들이 올바르게 표시되는지 확인', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 600,
                height: 400,
                child: widget,
              ),
            ),
          ),
        );

        // 라벨 텍스트 확인
        expect(find.text('이름'), findsOneWidget);
        expect(find.text('이메일'), findsOneWidget);
        expect(find.text('성별'), findsOneWidget);
      });

      testWidgets('초기값이 올바르게 설정되는지 확인', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 600,
                height: 400,
                child: widget,
              ),
            ),
          ),
        );

        // TextFormField의 초기값 확인
        final nameField = find.byType(TextFormField).first;
        final TextFormField nameWidget = tester.widget(nameField);
        expect(nameWidget.initialValue, '홍길동');
      });
    });

    group('FormFieldConfig 클래스 테스트', () {
      test('FormFieldConfig가 올바르게 생성되는지 확인', () {
        final config = FormFieldConfig(
          keyName: 'test',
          label: '테스트',
          type: FormFieldType.input,
          value: '테스트 값',
          options: ['옵션1', '옵션2'],
        );

        expect(config.keyName, 'test');
        expect(config.label, '테스트');
        expect(config.type, FormFieldType.input);
        expect(config.value, '테스트 값');
        expect(config.options, ['옵션1', '옵션2']);
      });

      test('FormFieldConfig options가 null일 수 있는지 확인', () {
        final config = FormFieldConfig(
          keyName: 'test',
          label: '테스트',
          type: FormFieldType.input,
        );

        expect(config.options, isNull);
        expect(config.value, isNull);
      });
    });

    group('columnCount 파라미터 테스트', () {
      testWidgets('columnCount가 올바르게 적용되는지 확인', (WidgetTester tester) async {
        final singleColumnWidget = CustomGridForm(
          fields: testFields,
          columnCount: 1,
          formValues: testFormValues,
          onChanged: (key, value) {},
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 600,
                height: 400,
                child: singleColumnWidget,
              ),
            ),
          ),
        );

        expect(find.byType(CustomGridForm), findsOneWidget);
        expect(find.byType(FormFieldRow), findsNWidgets(3));
      });
    });
  });
} 