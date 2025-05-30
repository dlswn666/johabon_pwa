import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';

import '../../../lib/widgets/common/attachment_field.dart';

void main() {
  group('AttachmentField Widget Tests', () {
    late List<dynamic> capturedFiles;
    late AttachmentField widget;

    setUp(() {
      capturedFiles = [];
      widget = AttachmentField(
        onChanged: (files) {
          capturedFiles = files;
        },
      );
    });

    testWidgets('첨부파일 위젯이 올바르게 렌더링되는지 확인', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: widget,
          ),
        ),
      );

      // 라벨 텍스트 확인
      expect(find.text('첨부파일'), findsOneWidget);
      
      // 파일 선택 버튼 확인
      expect(find.text('내 PC'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      
      // 드래그앤드롭 영역 확인
      expect(find.text('드래그해서 파일을 올려주세요'), findsOneWidget);
      expect(find.byType(DropzoneView), findsOneWidget);
    });

    testWidgets('파일 선택 버튼이 존재하고 탭 가능한지 확인', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: widget,
          ),
        ),
      );

      final button = find.byType(ElevatedButton);
      expect(button, findsOneWidget);
      
      // 버튼이 탭 가능한지 확인
      await tester.tap(button);
      await tester.pump();
      
      // 에러가 발생하지 않으면 성공
    });

    testWidgets('DropzoneView가 올바른 설정으로 생성되는지 확인', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: widget,
          ),
        ),
      );

      final dropzoneView = tester.widget<DropzoneView>(find.byType(DropzoneView));
      
      expect(dropzoneView.operation, DragOperation.copy);
      expect(dropzoneView.cursor, CursorType.grab);
      expect(dropzoneView.onCreated, isNotNull);
      expect(dropzoneView.onDrop, isNotNull);
    });

    testWidgets('드래그앤드롭 영역의 스타일이 올바른지 확인', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: widget,
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.ancestor(
          of: find.byType(DropzoneView),
          matching: find.byType(Container),
        ).first,
      );

      expect(container.constraints?.maxHeight, 62);
      final decoration = container.decoration as BoxDecoration?;
      expect(decoration?.border, isNotNull);
    });

    testWidgets('레이아웃 구조가 올바른지 확인', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: widget,
          ),
        ),
      );

      // Row 구조 확인
      expect(find.byType(Row), findsOneWidget);
      
      // Column 구조 확인 (파일 업로드 영역)
      expect(find.byType(Column), findsAtLeastNWidgets(1));
      
      // Expanded 위젯 확인
      expect(find.byType(Expanded), findsOneWidget);
      
      // SizedBox 간격 확인
      expect(find.byType(SizedBox), findsAtLeastNWidgets(1));
    });

    testWidgets('초기 상태에서 파일 목록이 표시되지 않는지 확인', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: widget,
          ),
        ),
      );

      // 파일 아이템이 없어야 함
      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('텍스트 스타일이 올바르게 적용되는지 확인', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: widget,
          ),
        ),
      );

      // 라벨 텍스트 스타일 확인
      final labelText = tester.widget<Text>(find.text('첨부파일'));
      expect(labelText.style?.fontSize, 16);
      expect(labelText.style?.fontWeight, FontWeight.w600);
      expect(labelText.style?.fontFamily, 'Wanted Sans');

      // 버튼 텍스트 스타일 확인
      final buttonText = tester.widget<Text>(find.text('내 PC'));
      expect(buttonText.style?.fontSize, 14);
      expect(buttonText.style?.fontFamily, 'Wanted Sans');
      expect(buttonText.style?.color, const Color(0xFF41505D));

      // 드롭존 텍스트 스타일 확인
      final dropzoneText = tester.widget<Text>(find.text('드래그해서 파일을 올려주세요'));
      expect(dropzoneText.style?.fontSize, 14);
      expect(dropzoneText.style?.fontFamily, 'Wanted Sans');
      expect(dropzoneText.style?.color, const Color(0xFF41505D));
    });

    group('콜백 함수 테스트', () {
      testWidgets('onChanged가 null일 때 에러가 발생하지 않는지 확인', (WidgetTester tester) async {
        final widgetWithoutCallback = const AttachmentField();
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: widgetWithoutCallback,
            ),
          ),
        );

        expect(find.byType(AttachmentField), findsOneWidget);
      });
    });

    group('접근성 테스트', () {
      testWidgets('Semantics가 올바르게 설정되는지 확인', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: widget,
            ),
          ),
        );

        // 기본적인 접근성 확인
        expect(tester.getSemantics(find.text('첨부파일')), isNotNull);
        expect(tester.getSemantics(find.text('내 PC')), isNotNull);
      });
    });
  });
} 