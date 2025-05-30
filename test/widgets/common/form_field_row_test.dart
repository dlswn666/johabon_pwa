import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import '../../../lib/widgets/common/form_field_row.dart';

void main() {
  group('FormFieldRow Widget Tests', () {
    
    group('기본 렌더링 테스트', () {
      testWidgets('FormFieldRow가 올바른 구조로 렌더링되는지 확인', (WidgetTester tester) async {
        const widget = FormFieldRow(
          label: '테스트 라벨',
          type: FormFieldType.input,
        );

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: widget,
            ),
          ),
        );

        // Row 구조 확인
        expect(find.byType(Row), findsOneWidget);
        
        // 라벨 텍스트 확인
        expect(find.text('테스트 라벨'), findsOneWidget);
        
        // SizedBox (라벨 너비) 확인
        expect(find.byType(SizedBox), findsAtLeastNWidgets(1));
        
        // Expanded 위젯 확인
        expect(find.byType(Expanded), findsOneWidget);
      });

      testWidgets('라벨 스타일이 올바르게 적용되는지 확인', (WidgetTester tester) async {
        const widget = FormFieldRow(
          label: '테스트 라벨',
          type: FormFieldType.input,
        );

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: widget,
            ),
          ),
        );

        final labelText = tester.widget<Text>(find.text('테스트 라벨'));
        expect(labelText.style?.fontSize, 16);
        expect(labelText.style?.fontWeight, FontWeight.w500);
        expect(labelText.style?.fontFamily, 'Wanted Sans');
      });
    });

    group('Input 필드 테스트', () {
      testWidgets('TextFormField가 올바르게 렌더링되는지 확인', (WidgetTester tester) async {
        const widget = FormFieldRow(
          label: '입력 필드',
          type: FormFieldType.input,
          value: '초기값',
        );

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: widget,
            ),
          ),
        );

        expect(find.byType(TextFormField), findsOneWidget);
        
        final textField = tester.widget<TextFormField>(find.byType(TextFormField));
        expect(textField.initialValue, '초기값');
      });

      testWidgets('Input 필드의 onChanged가 동작하는지 확인', (WidgetTester tester) async {
        String? capturedValue;
        
        final widget = FormFieldRow(
          label: '입력 필드',
          type: FormFieldType.input,
          onChanged: (value) {
            capturedValue = value;
          },
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: widget,
            ),
          ),
        );

        await tester.enterText(find.byType(TextFormField), '테스트 입력');
        expect(capturedValue, '테스트 입력');
      });
    });

    group('Dropdown 필드 테스트', () {
      testWidgets('DropdownButtonFormField가 올바르게 렌더링되는지 확인', (WidgetTester tester) async {
        const widget = FormFieldRow(
          label: '드롭다운',
          type: FormFieldType.dropdown,
          options: ['옵션1', '옵션2', '옵션3'],
          value: '옵션1',
        );

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: widget,
            ),
          ),
        );

        expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
      });
    });

    group('Checkbox 필드 테스트', () {
      testWidgets('CheckboxListTile이 올바르게 렌더링되는지 확인', (WidgetTester tester) async {
        const widget = FormFieldRow(
          label: '체크박스',
          type: FormFieldType.checkbox,
          value: true,
        );

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: widget,
            ),
          ),
        );

        expect(find.byType(CheckboxListTile), findsOneWidget);
        
        final checkbox = tester.widget<CheckboxListTile>(find.byType(CheckboxListTile));
        expect(checkbox.value, true);
      });

      testWidgets('Checkbox가 탭되면 onChanged가 호출되는지 확인', (WidgetTester tester) async {
        bool? capturedValue;
        
        final widget = FormFieldRow(
          label: '체크박스',
          type: FormFieldType.checkbox,
          value: false,
          onChanged: (value) {
            capturedValue = value;
          },
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: widget,
            ),
          ),
        );

        await tester.tap(find.byType(Checkbox));
        expect(capturedValue, true);
      });
    });

    group('Radio 필드 테스트', () {
      testWidgets('Radio 버튼들이 올바르게 렌더링되는지 확인', (WidgetTester tester) async {
        const widget = FormFieldRow(
          label: '라디오',
          type: FormFieldType.radio,
          options: ['옵션1', '옵션2', '옵션3'],
          value: '옵션1',
        );

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: widget,
            ),
          ),
        );

        expect(find.byType(Wrap), findsOneWidget);
        expect(find.byType(Radio<String>), findsNWidgets(3));
        expect(find.text('옵션1'), findsAtLeastNWidgets(1));
        expect(find.text('옵션2'), findsOneWidget);
        expect(find.text('옵션3'), findsOneWidget);
      });

      testWidgets('Radio 버튼 선택이 올바르게 동작하는지 확인', (WidgetTester tester) async {
        String? capturedValue;
        
        final widget = FormFieldRow(
          label: '라디오',
          type: FormFieldType.radio,
          options: ['옵션1', '옵션2', '옵션3'],
          value: '옵션1',
          onChanged: (value) {
            capturedValue = value;
          },
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: widget,
            ),
          ),
        );

        // 두 번째 라디오 버튼 탭
        await tester.tap(find.byType(Radio<String>).at(1));
        expect(capturedValue, '옵션2');
      });

      testWidgets('options가 null일 때 빈 Wrap이 렌더링되는지 확인', (WidgetTester tester) async {
        const widget = FormFieldRow(
          label: '라디오',
          type: FormFieldType.radio,
        );

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: widget,
            ),
          ),
        );

        expect(find.byType(Wrap), findsOneWidget);
        expect(find.byType(Radio<String>), findsNothing);
      });
    });

    group('DatePicker 필드 테스트', () {
      testWidgets('DatePicker가 올바르게 렌더링되는지 확인', (WidgetTester tester) async {
        final testDate = DateTime(2023, 12, 25);
        
        final widget = FormFieldRow(
          label: '날짜',
          type: FormFieldType.datepicker,
          value: testDate,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: widget,
            ),
          ),
        );

        expect(find.byType(InkWell), findsOneWidget);
        expect(find.byType(InputDecorator), findsOneWidget);
        
        final formattedDate = DateFormat('yyyy-MM-dd').format(testDate);
        expect(find.text(formattedDate), findsOneWidget);
      });

      testWidgets('날짜가 없을 때 플레이스홀더가 표시되는지 확인', (WidgetTester tester) async {
        const widget = FormFieldRow(
          label: '날짜',
          type: FormFieldType.datepicker,
        );

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: widget,
            ),
          ),
        );

        expect(find.text('날짜를 선택해주세요'), findsOneWidget);
      });

      testWidgets('DatePicker를 탭하면 날짜 선택 다이얼로그가 열리는지 확인', (WidgetTester tester) async {
        const widget = FormFieldRow(
          label: '날짜',
          type: FormFieldType.datepicker,
        );

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: widget,
            ),
          ),
        );

        await tester.tap(find.byType(InkWell));
        await tester.pumpAndSettle();

        expect(find.byType(DatePickerDialog), findsOneWidget);
      });
    });

    group('접근성 테스트', () {
      testWidgets('라벨이 접근성 정보를 제공하는지 확인', (WidgetTester tester) async {
        const widget = FormFieldRow(
          label: '접근성 테스트',
          type: FormFieldType.input,
        );

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: widget,
            ),
          ),
        );

        expect(tester.getSemantics(find.text('접근성 테스트')), isNotNull);
      });
    });

    group('FormFieldType enum 테스트', () {
      test('모든 FormFieldType 값이 정의되어 있는지 확인', () {
        expect(FormFieldType.values.length, 5);
        expect(FormFieldType.values, contains(FormFieldType.input));
        expect(FormFieldType.values, contains(FormFieldType.dropdown));
        expect(FormFieldType.values, contains(FormFieldType.checkbox));
        expect(FormFieldType.values, contains(FormFieldType.radio));
        expect(FormFieldType.values, contains(FormFieldType.datepicker));
      });
    });
  });
} 