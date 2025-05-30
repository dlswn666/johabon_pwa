import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum FormFieldType {
    input,
    dropdown,
    checkbox,
    checkboxGroup,
    radio,
    datepicker,
    attachment,
    htmlEditor,
}

class FormFieldRow extends StatelessWidget {

    final String label;
    final FormFieldType type;
    final double? labelWidth;
    final List<String>? options;
    final dynamic value;
    final Function(dynamic)? onChanged;

    const FormFieldRow({
        super.key,
        required this.label,
        required this.type,
        this.labelWidth,
        this.options,
        this.value,
        this.onChanged,
    });

    @override
    Widget build(BuildContext context) {
        final double calculatedWidth = labelWidth ?? _calculateTextWidth(context, label);

        return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                SizedBox(
                    width: calculatedWidth,
                    child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, fontFamily: 'Wanted Sans'),)
                ),
                const SizedBox(width: 12),
                Expanded(
                    child: _buildInputWidget(context),
                )
            ]
        );
    }

    Widget _buildInputWidget(BuildContext context){
        switch (type) {
            case FormFieldType.input:
                return TextFormField(
                    initialValue: value?.toString(),
                    onChanged: onChanged,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(),
                    )
                );
            case FormFieldType.dropdown:
                return DropdownButtonFormField<String>(
                    value: value?.toString(),
                    items: options?.map((option) => DropdownMenuItem<String>(value: option, child: Text(option))).toList(),
                    onChanged: onChanged,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(),
                    ),
                    
                );
            case FormFieldType.checkbox:
                return CheckboxListTile(
                    value: value == true,
                    onChanged: onChanged,
                    title: const Text(''),
                );
            case FormFieldType.checkboxGroup:
                return Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: options?.map((option) {
                        final selectedList = (value ?? []) as List<String>;
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
                                onChanged?.call(updatedList);
                            },
                        );
                    }).toList() ?? [],
                );
            case FormFieldType.radio:
                return Wrap(
                    spacing: 12,
                    children: options?.map((option) {
                        return Row(
                            mainAxisSize: MainAxisSize.min,
                            children:[
                                Radio<String>(
                                    value: option,
                                    groupValue: value,
                                    onChanged: onChanged,
                                ),
                                Text(option)
                            ],
                        );
                    }).toList() ?? [],
                );
            case FormFieldType.datepicker:
                return _buildDatePicker(context);
            case FormFieldType.attachment:
                // attachment는 CustomGridForm에서 처리하므로 여기서는 빈 Container 반환
                return Container();
            case FormFieldType.htmlEditor:
                // htmlEditor는 CustomGridForm에서 처리하므로 여기서는 빈 Container 반환
                return Container();
        }
    }

    Widget _buildDatePicker(BuildContext context){
        String formattedValue = value is DateTime ? DateFormat('yyyy-MM-dd').format(value) : '';

        return InkWell(
            onTap: () async {
                DateTime now = DateTime.now();
                
                final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: value is DateTime ? value : now,
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100),
                );

                if (picked != null){
                    onChanged?.call(picked);
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

    double _calculateTextWidth(BuildContext context, String text) {
        final TextPainter painter = TextPainter(
            text: TextSpan(text: text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, fontFamily: 'Wanted Sans')),
            textDirection: Directionality.of(context),
        )..layout();

        return painter.size.width + 20;
    }

}