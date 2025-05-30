import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'form_field_row.dart';
import 'attachment_field.dart';
import 'html_editor_field.dart';

class FormFieldConfig {
    final String keyName;
    final String label;
    final FormFieldType type;
    final dynamic value;
    final List<String>? options;
    final double? height; // HTML 에디터용 높이
    final String? hintText; // HTML 에디터용 힌트 텍스트
    final Widget? customWidget; // 커스텀 위젯

    FormFieldConfig({
        required this.keyName,
        required this.label,
        required this.type,
        this.value,
        this.options,
        this.height,
        this.hintText,
        this.customWidget,
    });
}

class FormFieldGroup {
    final List<FormFieldConfig> fields;
    final int columnCount;
    final String? title; // 그룹 제목 (선택사항)

    FormFieldGroup({
        required this.fields,
        required this.columnCount,
        this.title,
    });
}

class CustomGridForm extends StatelessWidget {

    final List<FormFieldConfig> fields;
    final int columnCount;
    final Map<String, dynamic> formValues;
    final void Function(String key, dynamic value) onChanged;

    const CustomGridForm({
        super.key,
        required this.fields,
        required this.columnCount,
        required this.formValues,
        required this.onChanged,
    });
    
    @override
    Widget build(BuildContext context){
        return LayoutBuilder(
            builder: (context, constraints){
                final double totalWidth = constraints.maxWidth;
                
                // spacing을 고려한 올바른 itemWidth 계산
                const double spacing = 16.0;
                final double itemWidth = columnCount == 1 
                    ? totalWidth 
                    : (totalWidth - spacing * (columnCount - 1)) / columnCount;
                
                // 모든 라벨의 너비를 계산하고 최대값 찾기
                double maxLabelWidth = 0;
                for (final field in fields) {
                    final labelWidth = _calculateTextWidth(field.label);
                    if (labelWidth > maxLabelWidth) {
                        maxLabelWidth = labelWidth;
                    }
                }

                // 최소 라벨 너비 보장 (120px)
                maxLabelWidth = maxLabelWidth < 120 ? 120 : maxLabelWidth;

                return Wrap(
                    spacing: 16,
                    runSpacing: 20,
                    children: fields.map((field){
                        return SizedBox(
                            width: itemWidth,
                            child: _buildFieldWidget(field, context, maxLabelWidth),
                        );
                    }).toList(),
                );
            },
        );
    }

    Widget _buildFieldWidget(FormFieldConfig field, BuildContext context, double labelWidth) {
        // 커스텀 위젯이 있는 경우
        if (field.customWidget != null) {
            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    SizedBox(
                        width: labelWidth,
                        child: Text(
                            field.label,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Wanted Sans',
                            ),
                        ),
                    ),
                    const SizedBox(height: 8),
                    field.customWidget!,
                ],
            );
        }

        // 기본 필드 렌더링
        return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                SizedBox(
                    width: labelWidth,
                    child: Text(
                        field.label,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Wanted Sans'
                        ),
                    )
                ),
                const SizedBox(width: 12),
                Expanded(
                    child: _buildInputWidget(field, context),
                )
            ]
        );
    }

    Widget _buildInputWidget(FormFieldConfig field, BuildContext context) {
        switch (field.type) {
            case FormFieldType.attachment:
                return AttachmentField(
                    onChanged: (files) {
                        onChanged(field.keyName, files);
                    },
                );
            case FormFieldType.htmlEditor:
                return HtmlEditorField(
                    initialContent: formValues[field.keyName]?.toString(),
                    hintText: field.hintText ?? '내용을 입력해주세요',
                    height: field.height ?? 300,
                    onChange: (content) {
                        onChanged(field.keyName, content);
                    },
                );
            case FormFieldType.input:
                return TextFormField(
                    initialValue: formValues[field.keyName]?.toString(),
                    onChanged: (value) => onChanged(field.keyName, value),
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(),
                    )
                );
            case FormFieldType.dropdown:
                return DropdownButtonFormField<String>(
                    value: formValues[field.keyName]?.toString(),
                    items: field.options?.map((option) => DropdownMenuItem<String>(value: option, child: Text(option))).toList(),
                    onChanged: (value) => onChanged(field.keyName, value),
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(),
                    ),
                );
            case FormFieldType.checkbox:
                return Align(
                    alignment: Alignment.centerLeft,
                    child: Checkbox(
                        value: formValues[field.keyName] == true,
                        onChanged: (value) => onChanged(field.keyName, value),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                    ),
                );
            case FormFieldType.checkboxGroup:
                return Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: field.options?.map((option) {
                        final selectedList = (formValues[field.keyName] ?? []) as List<String>;
                        final isSelected = selectedList.contains(option);

                        return FilterChip(
                            label: Text(option),
                            selected: isSelected,
                            onSelected: (bool selected) {
                                final updatedList = [...selectedList];
                                if (selected) {
                                    updatedList.add(option);
                                } else {
                                    updatedList.remove(option);
                                }
                                onChanged(field.keyName, updatedList);
                            },
                        );
                    }).toList() ?? [],
                );
            case FormFieldType.radio:
                return Wrap(
                    spacing: 12,
                    children: field.options?.map((option) {
                        return Row(
                            mainAxisSize: MainAxisSize.min,
                            children:[
                                Radio<String>(
                                    value: option,
                                    groupValue: formValues[field.keyName],
                                    onChanged: (value) => onChanged(field.keyName, value),
                                ),
                                Text(option)
                            ],
                        );
                    }).toList() ?? [],
                );
            case FormFieldType.datepicker:
                return _buildDatePicker(field, context);
        }
    }

    Widget _buildDatePicker(FormFieldConfig field, BuildContext context) {
        String formattedValue = formValues[field.keyName] is DateTime 
            ? DateFormat('yyyy-MM-dd').format(formValues[field.keyName]) 
            : '';

        return InkWell(
            onTap: () async {
                DateTime now = DateTime.now();
                
                final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: formValues[field.keyName] is DateTime ? formValues[field.keyName] : now,
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100),
                );

                if (picked != null){
                    onChanged(field.keyName, picked);
                }
            },
            child: InputDecorator(
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(),
                ),
                child: Text(formattedValue.isEmpty ? '날짜를 선택해주세요' : formattedValue, style: const TextStyle(fontSize: 16, fontFamily: 'Wanted Sans'),)
            )
        );
    }

    double _calculateTextWidth(String text) {
        // 한글과 영문을 구분해서 계산
        double width = 0;
        for (int i = 0; i < text.length; i++) {
            final char = text[i];
            if (char.codeUnitAt(0) >= 0xAC00 && char.codeUnitAt(0) <= 0xD7AF) {
                // 한글: 더 넓음
                width += 16.0;
            } else {
                // 영문/숫자: 좁음
                width += 9.0;
            }
        }
        return width + 30; // 여백 추가
    }

}

class CustomGroupedForm extends StatelessWidget {
    final List<FormFieldGroup> groups;
    final Map<String, dynamic> formValues;
    final void Function(String key, dynamic value) onChanged;

    const CustomGroupedForm({
        super.key,
        required this.groups,
        required this.formValues,
        required this.onChanged,
    });

    @override
    Widget build(BuildContext context) {
        // 모든 그룹의 라벨 너비를 한번에 계산해서 통일된 너비 적용
        double globalMaxLabelWidth = 0;
        
        for (final group in groups) {
            // 그룹 제목도 포함해서 계산
            if (group.title != null && group.title!.trim().isNotEmpty) {
                final titleWidth = _calculateTextWidth(group.title!);
                if (titleWidth > globalMaxLabelWidth) {
                    globalMaxLabelWidth = titleWidth;
                }
            }
            
            // 그룹 내 모든 필드 라벨 계산
            for (final field in group.fields) {
                final labelWidth = _calculateTextWidth(field.label);
                if (labelWidth > globalMaxLabelWidth) {
                    globalMaxLabelWidth = labelWidth;
                }
            }
        }
        
        // 최소 라벨 너비 보장 (120px)
        globalMaxLabelWidth = globalMaxLabelWidth < 120 ? 120 : globalMaxLabelWidth;
        
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: groups.map((group) {
                return _buildGroup(context, group, globalMaxLabelWidth);
            }).toList(),
        );
    }

    Widget _buildGroup(BuildContext context, FormFieldGroup group, double globalMaxLabelWidth) {
        return LayoutBuilder(
            builder: (context, constraints) {
                final double totalWidth = constraints.maxWidth;
                
                // spacing을 고려한 올바른 itemWidth 계산
                const double spacing = 16.0;
                final double itemWidth = group.columnCount == 1 
                    ? totalWidth 
                    : (totalWidth - spacing * (group.columnCount - 1)) / group.columnCount;

                return Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            // 그룹 제목 표시 (null이 아니고 빈 문자열이 아닌 경우만)
                            if (group.title != null && group.title!.trim().isNotEmpty) ...[
                                SizedBox(
                                    width: globalMaxLabelWidth,
                                    child: Text(
                                        group.title!,
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Wanted Sans',
                                            color: Color(0xFF41505D),
                                        ),
                                    ),
                                ),
                                const SizedBox(height: 16),
                            ],
                            // 필드들 - 각 그룹 내에서 라벨 너비 통일
                            Wrap(
                                spacing: 16,
                                runSpacing: 20,
                                children: group.fields.map((field) {
                                    return SizedBox(
                                        width: itemWidth,
                                        child: _buildFieldWidget(
                                            field, 
                                            context, 
                                            globalMaxLabelWidth
                                        ),
                                    );
                                }).toList(),
                            ),
                        ],
                    ),
                );
            },
        );
    }

    Widget _buildFieldWidget(FormFieldConfig field, BuildContext context, double labelWidth) {
        // 커스텀 위젯이 있는 경우
        if (field.customWidget != null) {
            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    SizedBox(
                        width: labelWidth,
                        child: Text(
                            field.label,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Wanted Sans',
                            ),
                        ),
                    ),
                    const SizedBox(height: 8),
                    field.customWidget!,
                ],
            );
        }

        // 기본 필드 렌더링
        return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                SizedBox(
                    width: labelWidth,
                    child: Text(
                        field.label,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Wanted Sans'
                        ),
                    )
                ),
                const SizedBox(width: 12),
                Expanded(
                    child: _buildInputWidget(field, context),
                )
            ]
        );
    }

    Widget _buildInputWidget(FormFieldConfig field, BuildContext context) {
        switch (field.type) {
            case FormFieldType.attachment:
                return AttachmentField(
                    onChanged: (files) {
                        onChanged(field.keyName, files);
                    },
                );
            case FormFieldType.htmlEditor:
                return HtmlEditorField(
                    initialContent: formValues[field.keyName]?.toString(),
                    hintText: field.hintText ?? '내용을 입력해주세요',
                    height: field.height ?? 300,
                    onChange: (content) {
                        onChanged(field.keyName, content);
                    },
                );
            case FormFieldType.input:
                return TextFormField(
                    initialValue: formValues[field.keyName]?.toString(),
                    onChanged: (value) => onChanged(field.keyName, value),
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(),
                    )
                );
            case FormFieldType.dropdown:
                return DropdownButtonFormField<String>(
                    value: formValues[field.keyName]?.toString(),
                    items: field.options?.map((option) => DropdownMenuItem<String>(value: option, child: Text(option))).toList(),
                    onChanged: (value) => onChanged(field.keyName, value),
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(),
                    ),
                );
            case FormFieldType.checkbox:
                return Align(
                    alignment: Alignment.centerLeft,
                    child: Checkbox(
                        value: formValues[field.keyName] == true,
                        onChanged: (value) => onChanged(field.keyName, value),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                    ),
                );
            case FormFieldType.checkboxGroup:
                return Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: field.options?.map((option) {
                        final selectedList = (formValues[field.keyName] ?? []) as List<String>;
                        final isSelected = selectedList.contains(option);

                        return FilterChip(
                            label: Text(option),
                            selected: isSelected,
                            onSelected: (bool selected) {
                                final updatedList = [...selectedList];
                                if (selected) {
                                    updatedList.add(option);
                                } else {
                                    updatedList.remove(option);
                                }
                                onChanged(field.keyName, updatedList);
                            },
                        );
                    }).toList() ?? [],
                );
            case FormFieldType.radio:
                return Wrap(
                    spacing: 12,
                    children: field.options?.map((option) {
                        return Row(
                            mainAxisSize: MainAxisSize.min,
                            children:[
                                Radio<String>(
                                    value: option,
                                    groupValue: formValues[field.keyName],
                                    onChanged: (value) => onChanged(field.keyName, value),
                                ),
                                Text(option)
                            ],
                        );
                    }).toList() ?? [],
                );
            case FormFieldType.datepicker:
                return _buildDatePicker(field, context);
        }
    }

    Widget _buildDatePicker(FormFieldConfig field, BuildContext context) {
        String formattedValue = formValues[field.keyName] is DateTime 
            ? DateFormat('yyyy-MM-dd').format(formValues[field.keyName]) 
            : '';

        return InkWell(
            onTap: () async {
                DateTime now = DateTime.now();
                
                final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: formValues[field.keyName] is DateTime ? formValues[field.keyName] : now,
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100),
                );

                if (picked != null){
                    onChanged(field.keyName, picked);
                }
            },
            child: InputDecorator(
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(),
                ),
                child: Text(formattedValue.isEmpty ? '날짜를 선택해주세요' : formattedValue, style: const TextStyle(fontSize: 16, fontFamily: 'Wanted Sans'),)
            )
        );
    }

    double _calculateTextWidth(String text) {
        // 한글과 영문을 구분해서 계산
        double width = 0;
        for (int i = 0; i < text.length; i++) {
            final char = text[i];
            if (char.codeUnitAt(0) >= 0xAC00 && char.codeUnitAt(0) <= 0xD7AF) {
                // 한글: 더 넓음
                width += 16.0;
            } else {
                // 영문/숫자: 좁음
                width += 9.0;
            }
        }
        return width + 30; // 여백 추가
    }
}
